#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# global-instructions.sh — Configure CLAUDE/GLOBAL-INSTRUCTIONS.md
# Can run standalone (make global-instructions) or as part of init.
#
# Init flow:  children have already been configured. Reads their
#             skip flags from the state file and generates the file.
# Standalone: prompts the user directly (Default / Customize / Skip).
# ─────────────────────────────────────────────────────────────────

require_cowork_dir
require_target_dir

# ── Resolve skip flags ──
# Init flow writes state; standalone infers from filesystem.
resolve_skip_flags() {
    if [ -f "$INIT_STATE_FILE" ]; then
        # Init flow — read from state file
        SKIP_ABOUT_ME=$(state_get "SKIP_ABOUT_ME" "false")
        SKIP_WRITING_STYLE=$(state_get "SKIP_WRITING_STYLE" "false")
        SKIP_FEEDBACK=$(state_get "SKIP_FEEDBACK" "false")
    else
        # Standalone — infer from filesystem
        SKIP_ABOUT_ME=true
        SKIP_WRITING_STYLE=true
        SKIP_FEEDBACK=true
        [ -f "$TARGET/ABOUT-ME/about-me.md" ]              && SKIP_ABOUT_ME=false
        [ -f "$TARGET/ABOUT-ME/anti-ai-writing-style.md" ]  && SKIP_WRITING_STYLE=false
        [ -f "$TARGET/ABOUT-ME/feedback.md" ]               && SKIP_FEEDBACK=false
    fi
}

# ── Generate GLOBAL-INSTRUCTIONS.md dynamically ──
# Only references sections the user actually configured.
generate_global_instructions() {
    local out="$TARGET/GLOBAL-INSTRUCTIONS.md"

    local has_about_me_folder=false
    if [ "$SKIP_ABOUT_ME" = "false" ] || [ "$SKIP_WRITING_STYLE" = "false" ] || [ "$SKIP_FEEDBACK" = "false" ]; then
        has_about_me_folder=true
    fi

    {
        echo "# GLOBAL INSTRUCTIONS"
        echo ""
        echo "## BEFORE EVERY TASK"

        local step=1

        if $has_about_me_folder; then
            if [ "$SKIP_FEEDBACK" = "false" ]; then
                echo "${step}. Read all files in \`CLAUDE/ABOUT-ME/\`, including \`feedback.md\`. No task starts without reading them."
                step=$((step + 1))
                echo "${step}. Apply every correction in \`feedback.md\`. These override any conflicting defaults."
                step=$((step + 1))
            else
                echo "${step}. Read all files in \`CLAUDE/ABOUT-ME/\`. No task starts without reading them."
                step=$((step + 1))
            fi
        fi

        echo "${step}. If the task relates to a project, read everything in the matching \`CLAUDE/PROJECTS/\` subfolder before proceeding."
        step=$((step + 1))
        echo "${step}. If the task involves a content type that has a matching skill, study that skill's structure first. Use the structure."
        step=$((step + 1))

        if [ "$SKIP_WRITING_STYLE" = "false" ]; then
            echo "${step}. Follow every rule in \`anti-ai-writing-style.md\` for all outputs. No exceptions."
            step=$((step + 1))
        fi

        echo ""
        echo "## FOLDER PROTOCOL"

        if $has_about_me_folder; then
            echo "You have two read-only folders and one write folder."
        else
            echo "You have one read-only folder and one write folder."
        fi

        echo ""
        echo "### Read-only — never create, edit, or delete anything here:"

        if $has_about_me_folder; then
            local about_parts=()
            [ "$SKIP_ABOUT_ME" = "false" ]      && about_parts+=("identity, stack, communication preferences")
            [ "$SKIP_WRITING_STYLE" = "false" ]  && about_parts+=("writing rules")
            [ "$SKIP_FEEDBACK" = "false" ]        && about_parts+=("correction log")

            local count=${#about_parts[@]}
            local about_desc="My "
            if [ "$count" -eq 1 ]; then
                about_desc+="${about_parts[0]}."
            elif [ "$count" -eq 2 ]; then
                about_desc+="${about_parts[0]} and ${about_parts[1]}."
            else
                local i=0
                for part in "${about_parts[@]}"; do
                    if [ $i -eq $((count - 1)) ]; then
                        about_desc+="and ${part}."
                    else
                        about_desc+="${part}, "
                    fi
                    i=$((i + 1))
                done
            fi
            echo "- \`CLAUDE/ABOUT-ME/\` → ${about_desc}"
        fi

        echo "- \`CLAUDE/PROJECTS/\` → Briefs, references, data, and finished work organized by project."
        echo ""
        echo "### Write folder — the only place you deliver work:"
        echo "- \`CLAUDE/OUTPUTS/\` → Everything you create goes here. Organize with one subfolder per project, mirroring the structure of \`CLAUDE/PROJECTS/\`. Create the subfolder if it doesn't exist yet."
        echo ""
        echo "## NAMING CONVENTION"
        echo "All files you create must follow this format:"
        echo "\`project_content-type_v1.ext\`"
        echo ""
        echo "Content types: analysis, model, pipeline, report, spec, script, notebook, doc."
        echo ""
        echo "## OPERATING RULES"
        echo "- If the brief is unclear or incomplete, use the \`AskUserQuestion\` tool. Don't fill gaps with assumptions or generic filler."
        echo "- Deliver the work. No commentary about the work unless I ask for it."
        echo "- Never delete files anywhere."
        echo "- Code must be production-ready: error handling, type hints, docstrings, edge cases handled."
        echo "- Data pipeline outputs must include: schema definitions, error handling, idempotency guarantees, and logging."
        echo "- When showing trade-offs, use concrete numbers or code, not abstract pros/cons lists."
        echo "- Show math as LaTeX when non-trivial. Show code when something is computable."
    } > "$out"
}

# ── Customize flow (shared between init and standalone) ──
run_customize() {
    printf "\n  ${CREAM}Customize your global instructions.${RESET}\n\n"

    read -rp "    Output naming convention [project_content-type_v1.ext]: " G_NAMING
    G_NAMING="${G_NAMING:-project_content-type_v1.ext}"
    read -rp "    Domain-specific defaults (or press Enter to skip): " G_DEFAULTS
    read -rp "    Additional operating rules (or press Enter to skip): " G_RULES

    generate_global_instructions

    if [ "$G_NAMING" != "project_content-type_v1.ext" ] || [ -n "$G_DEFAULTS" ] || [ -n "$G_RULES" ]; then
        {
            echo ""
            echo "---"
            echo ""
            echo "## Custom Configuration (added during init)"
            if [ "$G_NAMING" != "project_content-type_v1.ext" ]; then
                echo ""
                echo "**Naming convention:** ${G_NAMING}"
            fi
            if [ -n "$G_DEFAULTS" ]; then
                echo ""
                echo "**Domain defaults:** ${G_DEFAULTS}"
            fi
            if [ -n "$G_RULES" ]; then
                echo ""
                echo "**Operating rules:** ${G_RULES}"
            fi
        } >> "$TARGET/GLOBAL-INSTRUCTIONS.md"
    fi

    success "GLOBAL-INSTRUCTIONS.md — customized and saved"
}


# ── Main flow ──

resolve_skip_flags

if [ -f "$INIT_STATE_FILE" ] && [ "${INIT_STEP:-}" = "generate" ]; then
    # ── Init flow: gatekeeper said Yes, children already configured ──
    # Generate GLOBAL-INSTRUCTIONS.md dynamically from children's skip flags.
    info "Generating GLOBAL-INSTRUCTIONS.md..."
    generate_global_instructions
    success "GLOBAL-INSTRUCTIONS.md — generated"
else
    # ── Standalone mode: full prompt flow ──
    step_header "GLOBAL-INSTRUCTIONS.md" "Boot sequence, folder protocol, naming, and domain defaults."

    prompt_choice_skip "Use default" "Customize"

    case $PROMPT_RESULT in
    3)
        state_set "SKIP_GLOBAL" "true"
        rm -f "$TARGET/GLOBAL-INSTRUCTIONS.md"
        success "GLOBAL-INSTRUCTIONS.md — skipped"
        ;;
    1)
        generate_global_instructions
        success "GLOBAL-INSTRUCTIONS.md — generated"
        ;;
    2)
        run_customize
        ;;
    esac
fi
