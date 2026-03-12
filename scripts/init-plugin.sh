#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# Prompt user to install plugins during make init.
# Receives the Make executable as $1 to delegate to `make plugin`.
# ─────────────────────────────────────────────────────────────────

MAKE_CMD="${1:-make}"

info "Install plugins?"
dim "GSD (orchestration) + Superpowers (quality enforcement)"

if prompt_yesno; then
    CLAUDIO_NESTED=1 $MAKE_CMD --no-print-directory plugin
else
    success "Skipped plugin installation"
fi
echo ""
