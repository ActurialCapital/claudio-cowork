#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/parse-yaml.sh"

# ─────────────────────────────────────────────────────────────────
# Install plugins defined in plugins.yaml
# Fully configuration-driven — no plugin names, commands, or
# descriptions are hardcoded in this script.
# Idempotent — safe to run multiple times.
# ─────────────────────────────────────────────────────────────────

PLUGINS_FILE="$COWORK_DIR/plugins.yaml"

if [ ! -f "$PLUGINS_FILE" ]; then
    warn "plugins.yaml not found at $PLUGINS_FILE"
    exit 1
fi

yaml_parse "$PLUGINS_FILE"

if [ "$YAML_COUNT" -eq 0 ]; then
    dim "No plugins defined in plugins.yaml."
    exit 0
fi

# ── Header (skip when called from make init) ──
if [ "${CLAUDIO_NESTED:-}" != "1" ]; then
    echo ""
    info "Installing plugins"
    # Show what will be installed, from config
    for ((i = 0; i < YAML_COUNT; i++)); do
        local_name="$(yaml_get "$i" "name" || true)"
        local_desc="$(yaml_get "$i" "description" || true)"
        dim "${local_name}: ${local_desc}"
    done
    echo ""
    divider
    echo ""
fi

# ── Install each plugin ──
for ((i = 0; i < YAML_COUNT; i++)); do
    p_name="$(yaml_get "$i" "name" || true)"
    p_desc="$(yaml_get "$i" "description" || true)"
    p_requires="$(yaml_get "$i" "requires" || true)"
    p_check_file="$(yaml_get "$i" "check_file" || true)"
    p_check_cmd="$(yaml_get "$i" "check_cmd" || true)"
    p_install_cmd="$(yaml_get "$i" "install_cmd" || true)"
    p_install_dir="$(yaml_get "$i" "install_dir" || true)"
    p_manual_hint="$(yaml_get "$i" "manual_hint" || true)"

    step_num=$((i + 1))
    info "Step ${step_num}/${YAML_COUNT} — ${p_name}"
    dim "${p_desc}"
    echo ""

    # ── Idempotency check: is this plugin already installed? ──
    already_installed=false

    if [ -n "$p_check_file" ]; then
        check_path="$PROJECT_ROOT/$p_check_file"
        if [ -f "$check_path" ]; then
            already_installed=true
        fi
    elif [ -n "$p_check_cmd" ]; then
        check_result=$(eval "$p_check_cmd" 2>/dev/null || true)
        if [ -n "$check_result" ] && [ "$check_result" -gt 0 ] 2>/dev/null; then
            already_installed=true
        fi
    fi

    if $already_installed; then
        success "${p_name} already installed"
        echo ""
        continue
    fi

    # ── Dependency check ──
    if [ -n "$p_requires" ] && ! has_command "$p_requires"; then
        warn "${p_requires} not found. Install manually:"
        # Replace <project-root> placeholder with actual path
        actual_hint="${p_manual_hint//<project-root>/$PROJECT_ROOT}"
        hint "$actual_hint"
        echo ""
        continue
    fi

    # ── Run installation ──
    if [ -z "$p_install_cmd" ]; then
        warn "No install_cmd defined for ${p_name}"
        echo ""
        continue
    fi

    dim "Running: ${p_install_cmd}"

    # Determine working directory
    install_dir="$COWORK_DIR"
    if [ "$p_install_dir" = "project_root" ]; then
        install_dir="$PROJECT_ROOT"
    fi

    if (cd "$install_dir" && eval "$p_install_cmd"); then
        success "${p_name} installed"
    else
        warn "${p_name} installation failed. Run manually:"
        actual_hint="${p_manual_hint//<project-root>/$PROJECT_ROOT}"
        hint "$actual_hint"
    fi

    echo ""
done

# ── Summary (from config) ──
divider
printf "  ${DIM}${CREAM}Plugin installation complete.${RESET}\n"
divider
echo ""

printf "  ${CREAM}What was installed:${RESET}\n"
for ((i = 0; i < YAML_COUNT; i++)); do
    p_name="$(yaml_get "$i" "name" || true)"
    p_summary="$(yaml_get "$i" "summary" || true)"
    printf "    ${BROWN}%-16s${RESET} %s\n" "$p_name" "$p_summary"
done
echo ""

printf "  ${CREAM}Next steps:${RESET}\n"
printf "    1. Restart Claude Code for plugins to take effect\n"
for ((i = 0; i < YAML_COUNT; i++)); do
    p_next="$(yaml_get "$i" "next_step" || true)"
    if [ -n "$p_next" ]; then
        printf "    %d. %s\n" "$((i + 2))" "$p_next"
    fi
done
echo ""
