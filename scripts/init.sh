#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# init.sh — Orchestrator for interactive configuration
#
# Dependency hierarchy:
#   GLOBAL-INSTRUCTIONS (parent — Yes/No gatekeeper)
#     ├─ about-me        (Context / Customize / Skip)
#     ├─ code-style      (Use default / Customize / Skip)
#     └─ feedback         (Yes / No)
#
# If GLOBAL-INSTRUCTIONS is disabled, all children are auto-skipped
# and the CLAUDE/ directory is not created at the project root.
# If enabled, each child retains its own prompt options.
# GLOBAL-INSTRUCTIONS.md is generated dynamically from children.
# ─────────────────────────────────────────────────────────────────

require_cowork_dir

# Initialize inter-module state
state_init

# ── Show workflow tree ──
printf "  ${CREAM}Workflow:${RESET}\n\n"
printf "  ${BOLD}${CREAM}GLOBAL-INSTRUCTIONS${RESET}\n"
printf "  ${GRAY}├─${RESET} about-me\n"
printf "  ${GRAY}├─${RESET} code-style\n"
printf "  ${GRAY}└─${RESET} feedback\n"
printf "  ${BOLD}${CREAM}Plugins${RESET}\n"
printf "  ${BOLD}${CREAM}Skills${RESET}\n"
echo ""

divider
echo ""

# ── Gatekeeper: GLOBAL-INSTRUCTIONS (Yes/No) ──
info "GLOBAL-INSTRUCTIONS"
dim "Parent module — controls about-me, code-style, and feedback."
printf "\n  ${CREAM}Enable Global Instruction style?${RESET}\n"

if prompt_yesno; then
    # ── Yes: configure children, then generate GLOBAL-INSTRUCTIONS.md ──
    echo ""

    # Install CLAUDE/ structure first
    bash "$SCRIPT_DIR/templates.sh"

    divider
    echo ""

    # Children — each retains its original prompt (Context/Customize/Skip, etc.)
    INIT_STEP="Step 1/3" bash "$SCRIPT_DIR/about-me.sh"

    divider
    echo ""

    INIT_STEP="Step 2/3" bash "$SCRIPT_DIR/code-style.sh"

    divider
    echo ""

    INIT_STEP="Step 3/3" bash "$SCRIPT_DIR/feedback.sh"

    divider
    echo ""

    # Generate GLOBAL-INSTRUCTIONS.md dynamically from children's choices
    INIT_STEP="generate" bash "$SCRIPT_DIR/global-instructions.sh"

    divider
    echo ""

    # Finalize — summary and copy-paste output
    bash "$SCRIPT_DIR/finalize.sh"
else
    # ── No: skip everything ──
    state_set "SKIP_GLOBAL" "true"
    state_set "SKIP_ABOUT_ME" "true"
    state_set "SKIP_WRITING_STYLE" "true"
    state_set "SKIP_FEEDBACK" "true"
    echo ""
    success "GLOBAL-INSTRUCTIONS — disabled"
    dim "  Children auto-skipped. CLAUDE/ directory will not be created."
    echo ""
    printf "  ${GREEN}✓${RESET} Configuration complete — no files created.\n"
    echo ""
    # Clean up state
    state_cleanup
fi
