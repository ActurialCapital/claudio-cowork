#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/parse-yaml.sh"

# ─────────────────────────────────────────────────────────────────
# Prompt user to install plugins during make init.
# Plugin names and descriptions are read from plugins.yaml.
# Receives the Make executable as $1 to delegate to `make plugin`.
# ─────────────────────────────────────────────────────────────────

MAKE_CMD="${1:-make}"
PLUGINS_FILE="$COWORK_DIR/plugins.yaml"

if [ ! -f "$PLUGINS_FILE" ]; then
    dim "No plugins.yaml found. Skipping plugin prompt."
    exit 0
fi

yaml_parse "$PLUGINS_FILE"

if [ "$YAML_COUNT" -eq 0 ]; then
    dim "No plugins defined. Skipping."
    exit 0
fi

info "Install plugins?"
# Display each plugin name + description from config
for ((i = 0; i < YAML_COUNT; i++)); do
    p_name="$(yaml_get "$i" "name" || true)"
    p_desc="$(yaml_get "$i" "description" || true)"
    dim "${p_name} — ${p_desc}"
done

if prompt_yesno; then
    CLAUDIO_NESTED=1 $MAKE_CMD --no-print-directory plugin
else
    success "Skipped plugin installation"
fi
echo ""
