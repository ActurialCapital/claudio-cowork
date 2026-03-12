#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# Ensure claudio-cowork/ is in the project root .gitignore.
# Idempotent — creates the file if missing, appends if absent,
# no-ops if already present.
# ─────────────────────────────────────────────────────────────────

GITIGNORE="$PROJECT_ROOT/.gitignore"

info "Ensuring claudio-cowork/ is in .gitignore..."

if ensure_line_in_file "$GITIGNORE" "claudio-cowork/"; then
    if [ "$(wc -l < "$GITIGNORE" | tr -d ' ')" -le 1 ]; then
        success "Created .gitignore with claudio-cowork/"
    else
        success "Added claudio-cowork/ to .gitignore"
    fi
else
    success "claudio-cowork/ already in .gitignore"
fi
echo ""
