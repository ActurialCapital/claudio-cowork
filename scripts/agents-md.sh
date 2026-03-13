#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# agents-md.sh — Install and populate AGENTS.md at project root.
# Context mode: scans project files + Claude CLI → filled-in AGENTS.md.
# Customize mode: interactive Q&A → Claude generates from answers.
# Skip mode: copies generic template as-is.
# ─────────────────────────────────────────────────────────────────

AGENTS_DEST="$PROJECT_ROOT/AGENTS.md"
AGENTS_TEMPLATE="$COWORK_DIR/INSTRUCTIONS/AGENTS.md"

# ── Idempotency: if AGENTS.md exists, nothing to do ──
if [ -f "$AGENTS_DEST" ]; then
    success "AGENTS.md already installed"
    exit 0
fi

HAS_CLAUDE=false
if has_command claude; then
    HAS_CLAUDE=true
fi

step_header "AGENTS.md" "Cross-tool project context for AI coding agents."

prompt_choice_skip "Context" "Customize"

# ── Helper: ensure @AGENTS.md reference in CLAUDE.md ──
ensure_agents_import() {
    local claude_md="$PROJECT_ROOT/CLAUDE.md"
    if [ -f "$claude_md" ]; then
        if ! grep -qF '@AGENTS.md' "$claude_md"; then
            printf '\n@AGENTS.md\n' >> "$claude_md"
        fi
    else
        printf '@AGENTS.md\n' > "$claude_md"
    fi
}

# ── Helper: gather project context from files on disk ──
gather_project_context() {
    local ctx=""

    # Dependency / build files
    for f in package.json pyproject.toml Cargo.toml go.mod pom.xml build.gradle Gemfile composer.json Makefile CMakeLists.txt; do
        if [ -f "$PROJECT_ROOT/$f" ]; then
            ctx+="=== ${f} ===
$(head -80 "$PROJECT_ROOT/$f")

"
        fi
    done

    # Config files (testing, linting, style)
    for f in jest.config.js jest.config.ts vitest.config.ts vitest.config.js pytest.ini setup.cfg tox.ini .eslintrc .eslintrc.js .eslintrc.json .eslintrc.yml .prettierrc .prettierrc.json tsconfig.json rustfmt.toml .clang-format .rubocop.yml; do
        if [ -f "$PROJECT_ROOT/$f" ]; then
            ctx+="=== ${f} ===
$(head -40 "$PROJECT_ROOT/$f")

"
        fi
    done

    # CI/CD
    for f in .github/workflows/ci.yml .github/workflows/ci.yaml .gitlab-ci.yml Jenkinsfile; do
        if [ -f "$PROJECT_ROOT/$f" ]; then
            ctx+="=== ${f} ===
$(head -40 "$PROJECT_ROOT/$f")

"
            break
        fi
    done

    # README (first 40 lines)
    for f in README.md README.rst README.txt README; do
        if [ -f "$PROJECT_ROOT/$f" ]; then
            ctx+="=== $(basename "$f") (first 40 lines) ===
$(head -40 "$PROJECT_ROOT/$f")

"
            break
        fi
    done

    # .gitignore (boundary signals)
    if [ -f "$PROJECT_ROOT/.gitignore" ]; then
        ctx+="=== .gitignore ===
$(head -30 "$PROJECT_ROOT/.gitignore")

"
    fi

    # Directory listing (top level)
    ctx+="=== Directory listing (project root) ===
$(ls -1 "$PROJECT_ROOT" 2>/dev/null | head -40)

"

    # Second-level listing for src/ or lib/ if present
    for d in src lib app packages; do
        if [ -d "$PROJECT_ROOT/$d" ]; then
            ctx+="=== ${d}/ contents ===
$(ls -1 "$PROJECT_ROOT/$d" 2>/dev/null | head -20)

"
        fi
    done

    echo "$ctx"
}

case $PROMPT_RESULT in
3)
    # ── Skip ──
    state_set "SKIP_AGENTS_MD" "true"
    success "AGENTS.md — skipped"
    ;;
1)
    # ── Context: analyze project root ──
    printf "\n"
    dim "Scanning project root for build, test, and config files..."

    GENERATED=""

    if $HAS_CLAUDE; then
        PROJECT_CONTEXT="$(gather_project_context)"

        if [ -n "$PROJECT_CONTEXT" ]; then
            dim "Generating AGENTS.md from project context..."

            GENERATED=$(claude -p "Based on these project files, generate an AGENTS.md file.

${PROJECT_CONTEXT}

Generate ONLY markdown with these exact sections. Each section must contain concrete, actionable instructions — not descriptions or generic advice. Use the exact commands and conventions you can detect from the config files.

# AGENTS.md

## Commands
(exact build, run, install, and setup commands with the correct package manager and flags — inferred from dependency/build files)

## Testing
(exact test, lint, and type-check commands — inferred from test configs and dependency files. Include how to run a single test and the full suite.)

## Architecture
(2-5 line map of the codebase — inferred from directory structure. State which directories hold what: endpoints, business logic, data layer, etc.)

## Code style
(2-5 concrete conventions with short code snippets — inferred from linter configs, tsconfig, or language-specific style files. Only include conventions that differ from language defaults.)

## Git workflow
(commit format, branch naming, PR requirements — inferred from CI configs, README, or existing commit patterns. If not detectable, use conventional commits as default.)

## Boundaries
(3-5 explicit never-do-this rules — inferred from .gitignore, sensitive directories like migrations/, env files, vendor/. Include: never commit secrets, never modify generated files, never push to main.)

Rules:
- Output ONLY the markdown. No preamble, no explanation, no wrapping.
- Every instruction must be concrete. No 'follow best practices' or 'write clean code'.
- Commands must include the correct package manager (npm/pnpm/yarn/pip/cargo/go/make).
- If a section cannot be inferred from the available files, write 2-3 reasonable defaults and mark them with (verify) so the user knows to check.
- Keep total length under 150 lines." 2>/dev/null || true)
        fi
    fi

    if [ -n "$GENERATED" ]; then
        echo "$GENERATED" > "$AGENTS_DEST"
        ensure_agents_import
        success "AGENTS.md — generated from project context"
        dim "Review and adjust: $AGENTS_DEST"
    else
        warn "Could not analyze project (Claude CLI unavailable or no project files found)."
        cp "$AGENTS_TEMPLATE" "$AGENTS_DEST"
        ensure_agents_import
        dim "Using template. Replace [REPLACE] lines with your project's actual commands."
    fi
    ;;
2)
    # ── Customize: guided question flow ──
    printf "\n  ${CREAM}Answer a few questions to build your AGENTS.md.${RESET}\n\n"

    read -rp "    Package manager (npm/pnpm/yarn/pip/cargo/go/make) [npm]: " Q_PM
    Q_PM="${Q_PM:-npm}"
    read -rp "    Build command (e.g. npm run build): " Q_BUILD
    read -rp "    Dev command (e.g. npm run dev): " Q_DEV
    read -rp "    Test command (e.g. npm test): " Q_TEST
    read -rp "    Lint command (e.g. npm run lint): " Q_LINT
    read -rp "    Key directories and their purpose (e.g. src/api=endpoints, src/core=business logic): " Q_ARCH
    read -rp "    Code conventions (e.g. TypeScript strict, named exports, no abbreviations): " Q_STYLE
    read -rp "    Commit format (e.g. conventional commits) [conventional]: " Q_COMMITS
    Q_COMMITS="${Q_COMMITS:-conventional commits}"
    read -rp "    Files or directories agents should never touch (e.g. .env, migrations/, vendor/): " Q_BOUNDARIES

    CUSTOM=""
    if $HAS_CLAUDE; then
        printf "\n"
        dim "Generating AGENTS.md..."
        CUSTOM=$(claude -p "Generate an AGENTS.md file from these developer answers.

- Package manager: ${Q_PM}
- Build: ${Q_BUILD}
- Dev: ${Q_DEV}
- Test: ${Q_TEST}
- Lint: ${Q_LINT}
- Architecture: ${Q_ARCH}
- Style: ${Q_STYLE}
- Commits: ${Q_COMMITS}
- Boundaries: ${Q_BOUNDARIES}

Use these exact sections: # AGENTS.md, ## Commands, ## Testing, ## Architecture, ## Code style, ## Git workflow, ## Boundaries.
Make each section specific and actionable based on the answers. Output ONLY markdown. No preamble." 2>/dev/null || true)
    fi

    if [ -n "$CUSTOM" ]; then
        echo "$CUSTOM" > "$AGENTS_DEST"
    else
        # Fallback: assemble from raw answers
        cat > "$AGENTS_DEST" <<EOF
# AGENTS.md

## Commands

- \`${Q_PM} install\` — install dependencies.
- \`${Q_BUILD}\` — production build.
- \`${Q_DEV}\` — start dev server.

## Testing

- \`${Q_TEST}\` — run full test suite.
- \`${Q_LINT}\` — run linter.
- Always run tests before committing.

## Architecture

${Q_ARCH}

## Code style

${Q_STYLE}

## Git workflow

- ${Q_COMMITS}

## Boundaries

- Never commit .env or files containing secrets.
${Q_BOUNDARIES:+- Never modify ${Q_BOUNDARIES}.}
- Never push directly to main.
EOF
    fi

    ensure_agents_import
    success "AGENTS.md — customized and saved"
    ;;
esac
