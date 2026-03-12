#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# Install recommended agent stack: GSD + Superpowers
# Idempotent — safe to run multiple times.
# ─────────────────────────────────────────────────────────────────

# When called from make init, skip the logo (already shown).
if [ "${CLAUDIO_NESTED:-}" != "1" ]; then
    echo ""
    info "Installing recommended agent stack"
    dim "GSD (orchestration) + Superpowers (quality enforcement)"
    echo ""
    divider
    echo ""
fi

# ── Step 1: GSD ──
info "Step 1/2 — Get Shit Done (GSD)"
dim "Project-level planning, task decomposition, parallel execution."
echo ""

if [ -f "$PROJECT_ROOT/.claude/gsd-manifest.json" ]; then
    success "GSD already installed (gsd-manifest.json found)"
elif ! has_command npx; then
    warn "npx not found. Install Node.js, then run:"
    hint "cd $PROJECT_ROOT && npx get-shit-done-cc --claude --local"
else
    dim "Running: npx get-shit-done-cc --claude --local"
    if (cd "$PROJECT_ROOT" && npx get-shit-done-cc@latest --claude --local); then
        success "GSD installed into .claude/"
    else
        warn "GSD installation failed. Run manually:"
        hint "cd $PROJECT_ROOT && npx get-shit-done-cc --claude --local"
    fi
fi

echo ""

# ── Step 2: Superpowers ──
info "Step 2/2 — Superpowers"
dim "TDD enforcement, structured planning, dual-stage code review."
echo ""

if ! has_command claude; then
    warn "Claude CLI not found. Install Superpowers manually:"
    hint "claude plugin install superpowers@superpowers-marketplace"
else
    installed=$(claude plugin list 2>/dev/null | grep -c "superpowers" || true)
    if [ "$installed" -gt 0 ]; then
        success "Superpowers already installed"
    else
        dim "Running: claude plugin install superpowers@superpowers-marketplace"
        if claude plugin install superpowers@superpowers-marketplace; then
            success "Superpowers installed"
        else
            warn "Superpowers installation failed. Run manually:"
            hint "claude plugin install superpowers@superpowers-marketplace"
        fi
    fi
fi

echo ""
divider
printf "  ${DIM}${CREAM}Agent stack installation complete.${RESET}\n"
divider
echo ""

printf "  ${CREAM}What was installed:${RESET}\n"
printf "    ${BROWN}GSD${RESET}          Project planning, wave-based parallel execution,\n"
printf "                  cost tracking. Adds /gsd commands to Claude Code.\n"
printf "    ${BROWN}Superpowers${RESET}  TDD, structured planning, dual-stage code review.\n"
printf "                  Adds /superpowers commands to Claude Code.\n"
echo ""
printf "  ${CREAM}Next steps:${RESET}\n"
printf "    1. Restart Claude Code for plugins to take effect\n"
printf "    2. Use ${BOLD}/gsd${RESET} commands for project orchestration\n"
printf "    3. Superpowers skills activate automatically by context\n"
echo ""
