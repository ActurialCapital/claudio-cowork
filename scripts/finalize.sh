#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# finalize.sh — Post-configuration cleanup and summary
# Reads skip flags from state file (init) or filesystem (standalone).
# ─────────────────────────────────────────────────────────────────

require_cowork_dir
require_target_dir

# ── Resolve skip flags ──
if [ -f "$INIT_STATE_FILE" ]; then
    SKIP_ABOUT_ME=$(state_get "SKIP_ABOUT_ME" "false")
    SKIP_WRITING_STYLE=$(state_get "SKIP_WRITING_STYLE" "false")
    SKIP_FEEDBACK=$(state_get "SKIP_FEEDBACK" "false")
    SKIP_GLOBAL=$(state_get "SKIP_GLOBAL" "false")
else
    SKIP_ABOUT_ME=true
    SKIP_WRITING_STYLE=true
    SKIP_FEEDBACK=true
    SKIP_GLOBAL=true
    [ -f "$TARGET/ABOUT-ME/about-me.md" ]              && SKIP_ABOUT_ME=false
    [ -f "$TARGET/ABOUT-ME/anti-ai-writing-style.md" ]  && SKIP_WRITING_STYLE=false
    [ -f "$TARGET/ABOUT-ME/feedback.md" ]               && SKIP_FEEDBACK=false
    [ -f "$TARGET/GLOBAL-INSTRUCTIONS.md" ]             && SKIP_GLOBAL=false
fi

step_header "Finalize"

# ── Post-config cleanup ──
# Remove ABOUT-ME/ entirely if all its sections were skipped.
if [ "$SKIP_ABOUT_ME" = "true" ] && [ "$SKIP_WRITING_STYLE" = "true" ] && [ "$SKIP_FEEDBACK" = "true" ]; then
    rm -rf "$TARGET/ABOUT-ME"
fi

if [ "$SKIP_GLOBAL" = "false" ]; then
    printf "\n  ${CREAM}Copy the content below and paste into:${RESET}\n"
    printf "  ${BOLD}Settings → Cowork → Edit Global Instructions${RESET}\n"

    printf "\n  ${TERRA}━━━━━━━━━ COPY BELOW THIS LINE ━━━━━━━━━${RESET}\n\n"
    cat "$TARGET/GLOBAL-INSTRUCTIONS.md"
    printf "\n\n  ${TERRA}━━━━━━━━━ COPY ABOVE THIS LINE ━━━━━━━━━${RESET}\n"
else
    dim "GLOBAL-INSTRUCTIONS.md was skipped. No content to paste."
fi

printf "\n  ${GREEN}✓${RESET} Interactive configuration complete.\n\n"

# List configured files (excluding skipped ones)
CONFIGURED=()
[ "$SKIP_ABOUT_ME" = "false" ]      && CONFIGURED+=("CLAUDE/ABOUT-ME/about-me.md")
[ "$SKIP_WRITING_STYLE" = "false" ] && CONFIGURED+=("CLAUDE/ABOUT-ME/anti-ai-writing-style.md")
[ "$SKIP_FEEDBACK" = "false" ]      && CONFIGURED+=("CLAUDE/ABOUT-ME/feedback.md")
[ "$SKIP_GLOBAL" = "false" ]        && CONFIGURED+=("CLAUDE/GLOBAL-INSTRUCTIONS.md")

if [ ${#CONFIGURED[@]} -gt 0 ]; then
    printf "  ${CREAM}Files configured:${RESET}\n"
    for f in "${CONFIGURED[@]}"; do
        printf "    • %s\n" "$f"
    done
else
    dim "No files were configured (all steps skipped)."
fi

# List skipped sections
SKIPPED=()
[ "$SKIP_ABOUT_ME" = "true" ]      && SKIPPED+=("about-me.md")
[ "$SKIP_WRITING_STYLE" = "true" ] && SKIPPED+=("anti-ai-writing-style.md")
[ "$SKIP_FEEDBACK" = "true" ]      && SKIPPED+=("feedback.md")
[ "$SKIP_GLOBAL" = "true" ]        && SKIPPED+=("GLOBAL-INSTRUCTIONS.md")

if [ ${#SKIPPED[@]} -gt 0 ]; then
    printf "\n  ${DIM}Skipped: %s${RESET}\n" "$(IFS=', '; echo "${SKIPPED[*]}")"
fi

printf "\n  ${DIM}Continuing with installation steps...${RESET}\n\n"

# Clean up state file if it exists
state_cleanup
