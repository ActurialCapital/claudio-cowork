#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# Prompt user to configure instruction files during make init.
# Delegates to agents-md.sh and claude-md.sh.
# ─────────────────────────────────────────────────────────────────

info "Configure instruction files?"
dim "AGENTS.md — cross-tool project context (build, test, lint, conventions)."
dim "CLAUDE.md — Claude-specific behavior rules, workflow, and mistake log."

if prompt_yesno; then
    echo ""
    bash "$SCRIPT_DIR/agents-md.sh"
    divider
    echo ""
    bash "$SCRIPT_DIR/claude-md.sh"
else
    success "Skipped instruction files configuration"
fi
echo ""
