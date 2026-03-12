#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# Copy CLAUDE/ templates to project root (idempotent merge).
# Templates inside claudio-cowork/CLAUDE/ are never modified.
# ─────────────────────────────────────────────────────────────────

require_cowork_dir

info "Installing CLAUDE/ templates into project root..."

if [ -d "$TARGET" ]; then
    warn "CLAUDE/ already exists in project root. Merging without overwrite..."
    copy_no_clobber "$COWORK_DIR/CLAUDE/" "$TARGET/"
else
    cp -r "$COWORK_DIR/CLAUDE/" "$TARGET/"
fi

success "CLAUDE/ installed at project root"
echo ""
