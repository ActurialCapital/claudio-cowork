#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# Minimal YAML list parser for plugins.yaml
#
# Parses a flat YAML list-of-objects into indexed shell variables.
# No external dependencies (no yq, no python).
#
# Usage:
#   source parse-yaml.sh
#   yaml_parse "/path/to/plugins.yaml"
#
# After parsing, the following are available:
#   YAML_COUNT          Number of entries
#   yaml_get <i> <key>  Get field value for entry i (0-indexed)
#
# Limitations:
#   - Only handles a single top-level list (first `- name:` block)
#   - Values are single-line strings (no multiline, no nested objects)
#   - Comments and blank lines are ignored
# ─────────────────────────────────────────────────────────────────

declare -a _YAML_KEYS=()
declare -a _YAML_VALS=()
YAML_COUNT=0

yaml_parse() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "parse-yaml: file not found: $file" >&2
        return 1
    fi

    _YAML_KEYS=()
    _YAML_VALS=()
    YAML_COUNT=0

    local idx=-1
    local in_list=false

    while IFS= read -r line || [ -n "$line" ]; do
        # Strip trailing whitespace / carriage return
        line="${line%%[[:space:]]}"

        # Skip blank lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Detect list start (top-level key ending with colon, e.g. "plugins:")
        if [[ "$line" =~ ^[a-zA-Z_]+:$ ]] && ! $in_list; then
            in_list=true
            continue
        fi

        # Detect new list item: "  - key: value"
        if $in_list && [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.*) ]]; then
            idx=$((idx + 1))
            YAML_COUNT=$((idx + 1))
            # Parse the key: value on the same line as the dash
            local rest="${BASH_REMATCH[1]}"
            if [[ "$rest" =~ ^([a-zA-Z_][a-zA-Z0-9_]*):(.*)$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local val="${BASH_REMATCH[2]}"
                # Trim leading/trailing whitespace and optional quotes
                val="${val#"${val%%[![:space:]]*}"}"
                val="${val%"${val##*[![:space:]]}"}"
                val="${val#\"}" ; val="${val%\"}"
                val="${val#\'}" ; val="${val%\'}"
                _YAML_KEYS+=("${idx}:${key}")
                _YAML_VALS+=("$val")
            fi
            continue
        fi

        # Detect continuation field: "    key: value"
        if $in_list && [ "$idx" -ge 0 ] && [[ "$line" =~ ^[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*):(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local val="${BASH_REMATCH[2]}"
            val="${val#"${val%%[![:space:]]*}"}"
            val="${val%"${val##*[![:space:]]}"}"
            val="${val#\"}" ; val="${val%\"}"
            val="${val#\'}" ; val="${val%\'}"
            _YAML_KEYS+=("${idx}:${key}")
            _YAML_VALS+=("$val")
            continue
        fi
    done < "$file"
}

# Get a field value for entry at index $1, key $2.
# Returns empty string and exit code 1 if not found.
yaml_get() {
    local idx="$1"
    local key="$2"
    local lookup="${idx}:${key}"
    local i

    for i in "${!_YAML_KEYS[@]}"; do
        if [ "${_YAML_KEYS[$i]}" = "$lookup" ]; then
            printf '%s' "${_YAML_VALS[$i]}"
            return 0
        fi
    done
    return 1
}

# Get a summary line: "name — description" for each entry.
# Useful for init-plugins.sh prompt display.
yaml_summary() {
    local i
    for ((i = 0; i < YAML_COUNT; i++)); do
        local name desc
        name="$(yaml_get "$i" "name" || true)"
        desc="$(yaml_get "$i" "description" || true)"
        if [ -n "$name" ]; then
            printf '%s' "$name"
            [ -n "$desc" ] && printf ' — %s' "$desc"
            printf '\n'
        fi
    done
}
