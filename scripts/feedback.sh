#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# feedback.sh — Configure CLAUDE/ABOUT-ME/feedback.md
# Can run standalone (make feedback) or as part of init flow.
# ─────────────────────────────────────────────────────────────────

require_cowork_dir
require_target_dir

step_header "feedback.md" "Define how the agent should request and handle feedback."
printf "\n  ${CREAM}Enable feedback configuration?${RESET}\n"

prompt_choice "Yes" "No" && FEEDBACK_CHOICE=1 || FEEDBACK_CHOICE=2

case $FEEDBACK_CHOICE in
1)
    ensure_about_me_dir
    copy_template "ABOUT-ME/feedback.md"
    success "feedback.md — enabled"
    ;;
2)
    state_set "SKIP_FEEDBACK" "true"
    success "feedback.md — disabled"
    ;;
esac
