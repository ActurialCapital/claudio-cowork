#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# code-style.sh — Configure CLAUDE/ABOUT-ME/anti-ai-writing-style.md
# Can run standalone (make code-style) or as part of init flow.
# ─────────────────────────────────────────────────────────────────

require_cowork_dir
require_target_dir

step_header "anti-ai-writing-style.md" "Rules for how Claude should (and should not) write."

prompt_choice_skip "Use default" "Customize"

case $PROMPT_RESULT in
3)
    state_set "SKIP_WRITING_STYLE" "true"
    success "anti-ai-writing-style.md — skipped"
    ;;
1)
    ensure_about_me_dir
    copy_template "ABOUT-ME/anti-ai-writing-style.md"
    success "anti-ai-writing-style.md — default accepted"
    ;;
2)
    ensure_about_me_dir
    copy_template "ABOUT-ME/anti-ai-writing-style.md"
    printf "\n  ${CREAM}Customize your writing rules.${RESET}\n\n"

    read -rp "    Preferred tone (formal/informal/neutral/academic) [neutral]: " S_TONE
    S_TONE="${S_TONE:-neutral}"
    read -rp "    Phrases to ban (comma-separated, or press Enter to skip): " S_BANNED
    read -rp "    Domain-specific writing conventions (or press Enter to skip): " S_DOMAIN
    read -rp "    Additional rules (or press Enter to skip): " S_RULES

    {
        echo ""
        echo "---"
        echo ""
        echo "## Custom Rules (added during init)"
        echo ""
        echo "**Tone:** ${S_TONE}"
        if [ -n "$S_BANNED" ]; then
            echo ""
            echo "**Additional banned phrases:**"
            IFS=',' read -ra PHRASES <<< "$S_BANNED"
            for phrase in "${PHRASES[@]}"; do
                trimmed=$(echo "$phrase" | xargs)
                echo "- ${trimmed}"
            done
        fi
        if [ -n "$S_DOMAIN" ]; then
            echo ""
            echo "**Domain conventions:** ${S_DOMAIN}"
        fi
        if [ -n "$S_RULES" ]; then
            echo ""
            echo "**Additional rules:** ${S_RULES}"
        fi
    } >> "$TARGET/ABOUT-ME/anti-ai-writing-style.md"

    success "anti-ai-writing-style.md — customized and saved"
    ;;
esac
