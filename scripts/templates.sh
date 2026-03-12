#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# Copy CLAUDE/ structural skeleton to project root.
# Only creates directories and files that are always present
# (PROJECTS/, OUTPUTS/, TEMPLATES/, PROMPT-TEMPLATE.md).
#
# Configurable files (about-me.md, anti-ai-writing-style.md,
# feedback.md, GLOBAL-INSTRUCTIONS.md) are created by init.sh
# only when the user does not skip them.
#
# Templates inside claudio-cowork/CLAUDE/ are never modified.
# ─────────────────────────────────────────────────────────────────

require_cowork_dir

info "Installing CLAUDE/ structure into project root..."

# Create the top-level directory
mkdir -p "$TARGET"

# Always-present directories
for dir in PROJECTS OUTPUTS TEMPLATES; do
    mkdir -p "$TARGET/$dir"
    # Copy .gitkeep if present in template
    if [ -f "$COWORK_DIR/CLAUDE/$dir/.gitkeep" ] && [ ! -f "$TARGET/$dir/.gitkeep" ]; then
        cp "$COWORK_DIR/CLAUDE/$dir/.gitkeep" "$TARGET/$dir/.gitkeep"
    fi
done

# Always-present files (copy without overwrite)
if [ -f "$COWORK_DIR/CLAUDE/PROMPT-TEMPLATE.md" ] && [ ! -f "$TARGET/PROMPT-TEMPLATE.md" ]; then
    cp "$COWORK_DIR/CLAUDE/PROMPT-TEMPLATE.md" "$TARGET/PROMPT-TEMPLATE.md"
fi

success "CLAUDE/ structure installed at project root"
echo ""
