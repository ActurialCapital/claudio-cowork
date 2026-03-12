#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# finalize.sh — Post-configuration cleanup and summary
# Only called when GLOBAL-INSTRUCTIONS is enabled (init flow).
# Reads skip flags from state file (init) or filesystem (standalone).
# ─────────────────────────────────────────────────────────────────

require_cowork_dir
require_target_dir

# ── Resolve skip flags ──
if [ -f "$INIT_STATE_FILE" ]; then
    SKIP_ABOUT_ME=$(state_get "SKIP_ABOUT_ME" "false")
    SKIP_WRITING_STYLE=$(state_get "SKIP_WRITING_STYLE" "false")
    SKIP_FEEDBACK=$(state_get "SKIP_FEEDBACK" "false")
else
    SKIP_ABOUT_ME=true
    SKIP_WRITING_STYLE=true
    SKIP_FEEDBACK=true
    [ -f "$TARGET/ABOUT-ME/about-me.md" ]              && SKIP_ABOUT_ME=false
    [ -f "$TARGET/ABOUT-ME/anti-ai-writing-style.md" ]  && SKIP_WRITING_STYLE=false
    [ -f "$TARGET/ABOUT-ME/feedback.md" ]               && SKIP_FEEDBACK=false
fi

step_header "Finalize"

# ── Post-config cleanup ──
# Remove ABOUT-ME/ entirely if all its sections were skipped.
if [ "$SKIP_ABOUT_ME" = "true" ] && [ "$SKIP_WRITING_STYLE" = "true" ] && [ "$SKIP_FEEDBACK" = "true" ]; then
    rm -rf "$TARGET/ABOUT-ME"
fi

# ── Show copy-paste output for GLOBAL-INSTRUCTIONS.md ──
if [ -f "$TARGET/GLOBAL-INSTRUCTIONS.md" ]; then
    printf "\n  ${CREAM}Copy the content below and paste into:${RESET}\n"
    printf "  ${BOLD}Settings → Cowork → Edit Global Instructions${RESET}\n"

    printf "\n  ${TERRA}━━━━━━━━━ COPY BELOW THIS LINE ━━━━━━━━━${RESET}\n\n"
    cat "$TARGET/GLOBAL-INSTRUCTIONS.md"
    printf "\n\n  ${TERRA}━━━━━━━━━ COPY ABOVE THIS LINE ━━━━━━━━━${RESET}\n"
fi

printf "\n  ${GREEN}✓${RESET} Configuration complete.\n\n"

# ── Summary with tree structure ──
printf "  ${CREAM}Configured:${RESET}\n"
printf "  ${BOLD}GLOBAL-INSTRUCTIONS.md${RESET}\n"

# Show children with tree connectors
declare -a children=()
[ "$SKIP_ABOUT_ME" = "false" ]      && children+=("about-me.md")
[ "$SKIP_WRITING_STYLE" = "false" ] && children+=("anti-ai-writing-style.md")
[ "$SKIP_FEEDBACK" = "false" ]      && children+=("feedback.md")

if [ ${#children[@]} -gt 0 ]; then
    local_count=${#children[@]}
    local_i=0
    for child in "${children[@]}"; do
        local_i=$((local_i + 1))
        if [ $local_i -eq "$local_count" ]; then
            printf "  ${GRAY}└─${RESET} ${GREEN}✓${RESET} %s\n" "$child"
        else
            printf "  ${GRAY}├─${RESET} ${GREEN}✓${RESET} %s\n" "$child"
        fi
    done
fi

# Show skipped children
declare -a skipped_children=()
[ "$SKIP_ABOUT_ME" = "true" ]      && skipped_children+=("about-me.md")
[ "$SKIP_WRITING_STYLE" = "true" ] && skipped_children+=("anti-ai-writing-style.md")
[ "$SKIP_FEEDBACK" = "true" ]      && skipped_children+=("feedback.md")

if [ ${#skipped_children[@]} -gt 0 ]; then
    # Determine connector based on whether configured children exist
    total=$((${#children[@]} + ${#skipped_children[@]}))
    local_i=${#children[@]}
    for child in "${skipped_children[@]}"; do
        local_i=$((local_i + 1))
        if [ $local_i -eq "$total" ]; then
            printf "  ${GRAY}└─ ○ %s (skipped)${RESET}\n" "$child"
        else
            printf "  ${GRAY}├─ ○ %s (skipped)${RESET}\n" "$child"
        fi
    done
fi

printf "\n  ${DIM}Continuing with installation steps...${RESET}\n\n"

# Clean up state file if it exists
state_cleanup
