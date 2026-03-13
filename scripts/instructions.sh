#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# instructions.sh — Orchestrator for instruction file configuration.
# Runs agents-md.sh (cross-tool project context) then
# claude-md.sh (Claude-specific behavior rules).
#
# Used by: make instructions (standalone)
# ─────────────────────────────────────────────────────────────────

require_cowork_dir

printf "\n  ${CREAM}Instruction files:${RESET}\n\n"
printf "  ${BOLD}${CREAM}AGENTS.md${RESET}  ${DIM}— cross-tool project context (build, test, conventions)${RESET}\n"
printf "  ${BOLD}${CREAM}CLAUDE.md${RESET}  ${DIM}— Claude-specific behavior rules and mistake log${RESET}\n"
echo ""

divider
echo ""

bash "$SCRIPT_DIR/agents-md.sh"

divider
echo ""

bash "$SCRIPT_DIR/claude-md.sh"

echo ""
