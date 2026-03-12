#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# Prompt user to install skills during make init.
# Receives the Make executable as $1 to delegate to `make skills`.
# ─────────────────────────────────────────────────────────────────

MAKE_CMD="${1:-make}"

info "Install skills?"

if prompt_yesno; then
    $MAKE_CMD --no-print-directory skills
else
    success "Skipped skills installation"
fi
echo ""
