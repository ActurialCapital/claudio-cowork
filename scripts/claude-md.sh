#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# claude-md.sh — Install and populate CLAUDE.md at project root.
# Use default: copies the template with behavior rules + @AGENTS.md.
# Context: merges existing project content into the template structure.
# Customize: interactive Q&A → Claude generates tailored behavior.
# Skip: no file created.
# ─────────────────────────────────────────────────────────────────

CLAUDE_MD_DEST="$PROJECT_ROOT/CLAUDE.md"
CLAUDE_MD_TEMPLATE="$COWORK_DIR/INSTRUCTIONS/CLAUDE.md"

# ── Idempotency: if CLAUDE.md exists AND has behavior section, nothing to do ──
if [ -f "$CLAUDE_MD_DEST" ] && grep -q '## Behavior' "$CLAUDE_MD_DEST"; then
    # Ensure @AGENTS.md import is present
    if ! grep -qF '@AGENTS.md' "$CLAUDE_MD_DEST"; then
        sed -i '1,/^# /{ /^# /a\
\
@AGENTS.md
}' "$CLAUDE_MD_DEST"
    fi
    success "CLAUDE.md already installed"
    exit 0
fi

HAS_CLAUDE=false
if has_command claude; then
    HAS_CLAUDE=true
fi

step_header "CLAUDE.md" "Claude-specific behavior rules and mistake log."

prompt_four_skip "Use default" "Context" "Customize"

# ── Helper: warn before overwriting an existing CLAUDE.md ──
# Returns 0 if user confirms overwrite, 1 if user aborts.
confirm_overwrite() {
    if [ ! -f "$CLAUDE_MD_DEST" ]; then
        return 0
    fi
    local line_count
    line_count=$(wc -l < "$CLAUDE_MD_DEST" | tr -d ' ')
    printf "\n    ${BROWN}⚠${RESET}  ${CREAM}CLAUDE.md already exists at project root (${line_count} lines).${RESET}\n"
    printf "    ${DIM}Overwriting will replace all existing content.${RESET}\n\n"
    printf "    ${CREAM}Overwrite?${RESET}\n"
    if prompt_yesno; then
        return 0
    else
        return 1
    fi
}

# ── Helper: gather project context from files on disk ──
# Mirrors agents-md.sh gather_project_context but includes CLAUDE.md-relevant files.
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
4)
    # ── Skip ──
    state_set "SKIP_CLAUDE_MD" "true"
    success "CLAUDE.md — skipped"
    ;;
1)
    # ── Use default: copy template ──
    if [ -f "$CLAUDE_MD_DEST" ]; then
        # CLAUDE.md exists but without behavior section — append behavior rules
        if ! grep -q '## Behavior' "$CLAUDE_MD_DEST"; then
            printf "\n" >> "$CLAUDE_MD_DEST"
            # Skip the first line (# CLAUDE.md) and @AGENTS.md from template
            tail -n +3 "$CLAUDE_MD_TEMPLATE" >> "$CLAUDE_MD_DEST"
            success "CLAUDE.md — behavior rules appended to existing file"
        fi
    else
        cp "$CLAUDE_MD_TEMPLATE" "$CLAUDE_MD_DEST"
        success "CLAUDE.md — installed with default behavior rules"
    fi
    dim "Review and adjust: $CLAUDE_MD_DEST"
    ;;
2)
    # ── Context: merge existing project content into template structure ──
    printf "\n"
    dim "Scanning project root for context..."

    GENERATED=""

    if $HAS_CLAUDE; then
        PROJECT_CONTEXT="$(gather_project_context)"
        EXISTING_CLAUDE_MD=""

        if [ -f "$CLAUDE_MD_DEST" ]; then
            EXISTING_CLAUDE_MD="$(cat "$CLAUDE_MD_DEST")"
        fi

        TEMPLATE_CONTENT="$(cat "$CLAUDE_MD_TEMPLATE")"

        if [ -n "$PROJECT_CONTEXT" ] || [ -n "$EXISTING_CLAUDE_MD" ]; then
            dim "Generating CLAUDE.md from project context..."

            GENERATED=$(claude -p "Generate a CLAUDE.md file by merging the default template with project context and any existing CLAUDE.md content.

=== DEFAULT TEMPLATE (structural baseline — use this format) ===
${TEMPLATE_CONTENT}

=== PROJECT FILES (context signals) ===
${PROJECT_CONTEXT}

=== EXISTING CLAUDE.md (if any — preserve useful content) ===
${EXISTING_CLAUDE_MD:-[no existing file]}

Instructions:
1. Use the default template as the structural baseline. Keep the exact section structure: # CLAUDE.md, @AGENTS.md import, ## Behavior (with all four subsections), ## Mistakes Log.
2. Preserve the four behavior subsections (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) from the template. Their wording is deliberate — do not water down or genericize.
3. If the existing CLAUDE.md contains useful project-specific content that does NOT belong in AGENTS.md (behavioral rules, workflow preferences, Claude-specific instructions, mistake entries), integrate it into the appropriate section. Behavioral content goes under ## Behavior. Mistake entries go under ## Mistakes Log.
4. If the existing CLAUDE.md contains project data that belongs in AGENTS.md (build commands, test commands, architecture map, conventions), do NOT include it — that content lives in AGENTS.md, not here.
5. If project files reveal useful behavioral signals (e.g., strict TypeScript config suggests strict typing discipline, presence of .husky suggests commit hooks), weave them into the behavior subsections as concrete rules.
6. Deduplicate. If the existing file and the template say the same thing differently, keep the template wording.
7. Replace [REPLACE] markers with real content where possible. If the existing file has dated mistake entries, carry them over.

Rules:
- Output ONLY the markdown. No preamble, no explanation.
- The @AGENTS.md line must appear exactly as shown (import directive).
- Keep total length under 100 lines.
- Every rule must be concrete and actionable.
- The result must read as a single coherent document, not a concatenation." 2>/dev/null || true)
        fi
    fi

    if [ -n "$GENERATED" ]; then
        echo "$GENERATED" > "$CLAUDE_MD_DEST"
        success "CLAUDE.md — generated from project context"
        dim "Review and adjust: $CLAUDE_MD_DEST"
    else
        warn "Could not analyze project (Claude CLI unavailable or no project files found)."
        # Fall back to Use default behavior
        if [ -f "$CLAUDE_MD_DEST" ]; then
            if ! grep -q '## Behavior' "$CLAUDE_MD_DEST"; then
                printf "\n" >> "$CLAUDE_MD_DEST"
                tail -n +3 "$CLAUDE_MD_TEMPLATE" >> "$CLAUDE_MD_DEST"
                dim "Behavior rules appended to existing file."
            fi
        else
            cp "$CLAUDE_MD_TEMPLATE" "$CLAUDE_MD_DEST"
        fi
        dim "Using template. Replace [REPLACE] lines manually."
    fi
    ;;
3)
    # ── Customize: guided question flow ──
    # Safety: warn before overwriting an existing file
    if ! confirm_overwrite; then
        success "CLAUDE.md — existing file preserved"
        exit 0
    fi

    printf "\n  ${CREAM}Answer a few questions to tailor Claude's behavior rules.${RESET}\n\n"

    read -rp "    How strict should Claude be about code changes? (strict/balanced/permissive) [strict]: " Q_STRICTNESS
    Q_STRICTNESS="${Q_STRICTNESS:-strict}"
    read -rp "    Should Claude always write tests first (TDD)? (yes/no) [yes]: " Q_TDD
    Q_TDD="${Q_TDD:-yes}"
    read -rp "    Communication style — how should Claude respond? (terse/balanced/detailed) [terse]: " Q_COMM
    Q_COMM="${Q_COMM:-terse}"
    read -rp "    Should Claude ask before refactoring? (yes/no) [yes]: " Q_ASK_REFACTOR
    Q_ASK_REFACTOR="${Q_ASK_REFACTOR:-yes}"
    read -rp "    Max acceptable complexity — what's the line count ceiling before a rewrite? [50]: " Q_MAX_LINES
    Q_MAX_LINES="${Q_MAX_LINES:-50}"
    read -rp "    Any specific mistakes or anti-patterns to seed the log? (or press Enter to skip): " Q_MISTAKES

    CUSTOM=""
    if $HAS_CLAUDE; then
        printf "\n"
        dim "Generating CLAUDE.md..."
        CUSTOM=$(claude -p "Generate a CLAUDE.md file from these developer preferences.

The file must start with:
# CLAUDE.md

@AGENTS.md

Then include a ## Behavior section with numbered subsections that encode the developer's preferences:
- Strictness level: ${Q_STRICTNESS}
- TDD preference: ${Q_TDD}
- Communication style: ${Q_COMM}
- Ask before refactoring: ${Q_ASK_REFACTOR}
- Max complexity threshold: ${Q_MAX_LINES} lines before requiring a rewrite
- Mistakes to avoid: ${Q_MISTAKES:-none specified}

The behavior section must include these four core subsections (adapt wording to match preferences):
### 1. Think Before Coding
### 2. Simplicity First
### 3. Surgical Changes
### 4. Goal-Driven Execution

End with a ## Mistakes Log section. If specific mistakes were provided, seed it with dated entries.

Rules:
- Output ONLY the markdown. No preamble, no explanation.
- Keep total length under 100 lines.
- Every rule must be concrete and actionable. No generic advice.
- The @AGENTS.md line must appear exactly as shown (it's an import directive)." 2>/dev/null || true)
    fi

    if [ -n "$CUSTOM" ]; then
        echo "$CUSTOM" > "$CLAUDE_MD_DEST"
    else
        # Fallback: use template and append any seeded mistakes
        cp "$CLAUDE_MD_TEMPLATE" "$CLAUDE_MD_DEST"
        if [ -n "$Q_MISTAKES" ]; then
            printf "\n- [$(date +%Y-%m-%d)] %s\n" "$Q_MISTAKES" >> "$CLAUDE_MD_DEST"
        fi
    fi

    success "CLAUDE.md — customized and saved"
    ;;
esac
