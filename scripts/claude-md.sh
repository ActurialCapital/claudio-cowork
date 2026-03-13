#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# claude-md.sh — Install and populate CLAUDE.md at project root.
# Use default mode: copies the template with behavior rules + @AGENTS.md.
# Customize mode: interactive Q&A → Claude generates tailored behavior.
# Skip mode: no file created.
# ─────────────────────────────────────────────────────────────────

CLAUDE_MD_DEST="$PROJECT_ROOT/CLAUDE.md"
CLAUDE_MD_TEMPLATE="$COWORK_DIR/INSTRUCTIONS/CLAUDE.md"

# ── Idempotency: if CLAUDE.md exists AND has behavior section, nothing to do ──
if [ -f "$CLAUDE_MD_DEST" ] && grep -q '## Behavior' "$CLAUDE_MD_DEST"; then
    # Ensure @AGENTS.md import is present
    if ! grep -qF '@AGENTS.md' "$CLAUDE_MD_DEST"; then
        # Insert @AGENTS.md after the first heading line
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

prompt_choice_skip "Use default" "Customize"

case $PROMPT_RESULT in
3)
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
    # ── Customize: guided question flow ──
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
