#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# claudio-cowork interactive configuration
# Configures about-me.md, anti-ai-writing-style.md, and
# GLOBAL-INSTRUCTIONS.md in project-root/CLAUDE/.
# All writes go to $TARGET (project root CLAUDE/).
# Template files in claudio-cowork/CLAUDE/ are never modified.
#
# Skip tracking: each section can be skipped. Skipped sections are
# excluded from GLOBAL-INSTRUCTIONS.md references.
# ─────────────────────────────────────────────────────────────────

require_cowork_dir
require_target_dir

HAS_CLAUDE=false
if has_command claude; then
    HAS_CLAUDE=true
fi

# ── Skip tracking ──
SKIP_ABOUT_ME=false
SKIP_WRITING_STYLE=false
SKIP_GLOBAL=false


# ── Helper: generate GLOBAL-INSTRUCTIONS.md dynamically ──
# Reads the skip flags and produces a clean file that only
# references sections the user actually configured.

generate_global_instructions() {
    local out="$TARGET/GLOBAL-INSTRUCTIONS.md"

    # Determine whether ABOUT-ME/ folder should be referenced.
    # The folder is relevant if any of its files (about-me.md or
    # anti-ai-writing-style.md) were configured.
    local has_about_me_folder=false
    if ! $SKIP_ABOUT_ME || ! $SKIP_WRITING_STYLE; then
        has_about_me_folder=true
    fi

    {
        echo "# GLOBAL INSTRUCTIONS"
        echo ""
        echo "## BEFORE EVERY TASK"

        # Boot sequence — only reference sections that exist
        local step=1

        if $has_about_me_folder; then
            echo "${step}. Read all files in \`CLAUDE/ABOUT-ME/\`, including \`feedback.md\`. No task starts without reading them."
            step=$((step + 1))
            echo "${step}. Apply every correction in \`feedback.md\`. These override any conflicting defaults."
            step=$((step + 1))
        fi

        echo "${step}. If the task relates to a project, read everything in the matching \`CLAUDE/PROJECTS/\` subfolder before proceeding."
        step=$((step + 1))
        echo "${step}. If the task involves a content type that has a matching skill, study that skill's structure first. Use the structure."
        step=$((step + 1))

        if ! $SKIP_WRITING_STYLE; then
            echo "${step}. Follow every rule in \`anti-ai-writing-style.md\` for all outputs. No exceptions."
            step=$((step + 1))
        fi

        echo ""
        echo "## FOLDER PROTOCOL"

        # Count read-only folders dynamically:
        # PROJECTS/ is always present; ABOUT-ME/ only when configured
        if $has_about_me_folder; then
            echo "You have two read-only folders and one write folder."
        else
            echo "You have one read-only folder and one write folder."
        fi

        echo ""
        echo "### Read-only — never create, edit, or delete anything here:"

        if $has_about_me_folder; then
            # Build description based on which files are configured
            local about_desc=""
            if ! $SKIP_ABOUT_ME && ! $SKIP_WRITING_STYLE; then
                about_desc="My identity, stack, communication preferences, writing rules, and correction log."
            elif ! $SKIP_ABOUT_ME; then
                about_desc="My identity, stack, communication preferences, and correction log."
            else
                about_desc="Writing rules and correction log."
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


# ═════════════════════════════════════════════════════════════════
# STEP 1: about-me.md
# ═════════════════════════════════════════════════════════════════

printf "\n  ${GREEN}◆ Step 1/4 — about-me.md${RESET}\n"
dim "Your developer profile, project context, and preferences."

prompt_choice_skip "Context" "Customize"

case $PROMPT_RESULT in
3)
    SKIP_ABOUT_ME=true
    success "about-me.md — skipped"
    ;;
1)
    # ── Context: analyze the parent project ──
    printf "\n"
    dim "Analyzing project root..."

    ANALYSIS=""

    if $HAS_CLAUDE; then
        PROJECT_CONTEXT=""
        for f in ../package.json ../pyproject.toml ../Cargo.toml ../go.mod ../pom.xml ../build.gradle ../Gemfile ../composer.json ../Makefile; do
            if [ -f "$f" ]; then
                PROJECT_CONTEXT+="=== $(basename "$f") ===
$(head -80 "$f")

"
            fi
        done
        for f in ../README.md ../README.rst ../README.txt ../README; do
            if [ -f "$f" ]; then
                PROJECT_CONTEXT+="=== $(basename "$f") (first 50 lines) ===
$(head -50 "$f")

"
                break
            fi
        done
        PROJECT_CONTEXT+="=== Directory listing (project root) ===
$(ls -1 ../ 2>/dev/null | head -40)

"

        if [ -n "$PROJECT_CONTEXT" ]; then
            ANALYSIS=$(claude -p "Based on these project files, generate a developer profile in markdown.

${PROJECT_CONTEXT}

Generate ONLY markdown with these sections:
# About Me
## Who I Am
(use placeholder [YOUR NAME] — infer role from the stack and project type)
## What I Do Day-to-Day
(3-5 bullets inferred from project structure, dependencies, and documentation)
## Domains
(inferred from project type, libraries, and documentation)
## Current Priorities
(what seems active based on project state and recent structure)
## Tech Stack
(specific tools, languages, versions where detectable from configs)
## Communication Style
Direct and technical. No hand-holding.
## What I Value in Output
Type-safe, tested, documented code.

Output ONLY the markdown content. No preamble, no explanation." 2>/dev/null || true)
        fi
    fi

    if [ -n "$ANALYSIS" ]; then
        echo "$ANALYSIS" > "$TARGET/ABOUT-ME/about-me.md"
        success "about-me.md — generated from project context"
    else
        warn "Could not analyze project (Claude CLI unavailable or no project files found)."
        dim "Keeping default template. You can edit it manually later."
    fi
    ;;
2)
    # ── Customize: guided question flow ──
    printf "\n  ${CREAM}Answer a few questions to build your profile.${RESET}\n\n"

    read -rp "    What are you building? " P_BUILDING
    read -rp "    Who are you? (name, role, background) " P_WHO
    read -rp "    What do you do day-to-day? " P_DAILY
    read -rp "    Key domains or specialties? " P_DOMAINS
    read -rp "    Project goals? " P_GOALS
    read -rp "    Tech stack (languages, frameworks, infra)? " P_STACK
    read -rp "    Communication style (terse/detailed/balanced) [balanced]: " P_COMM
    P_COMM="${P_COMM:-balanced}"
    read -rp "    Intended outcomes for this project? " P_OUTCOMES
    read -rp "    What do you value in output? " P_VALUES

    CUSTOM=""
    if $HAS_CLAUDE; then
        printf "\n"
        dim "Generating profile..."
        CUSTOM=$(claude -p "Generate a developer profile as a clean markdown document.
Details provided by the user:
- Who: ${P_WHO}
- Building: ${P_BUILDING}
- Day-to-day: ${P_DAILY}
- Domains: ${P_DOMAINS}
- Goals: ${P_GOALS}
- Stack: ${P_STACK}
- Communication: ${P_COMM}
- Intended outcomes: ${P_OUTCOMES}
- Values in output: ${P_VALUES}

Use these exact sections: # About Me, ## Who I Am, ## What I Do Day-to-Day, ## Domains, ## Current Priorities, ## Tech Stack, ## Communication Style, ## What I Value in Output.
Make each section specific and actionable based on the answers. Output ONLY markdown." 2>/dev/null || true)
    fi

    if [ -n "$CUSTOM" ]; then
        echo "$CUSTOM" > "$TARGET/ABOUT-ME/about-me.md"
    else
        cat > "$TARGET/ABOUT-ME/about-me.md" <<EOF
# About Me

## Who I Am
${P_WHO}

## What I Do Day-to-Day
${P_DAILY}

## Domains
${P_DOMAINS}

## Current Priorities
${P_GOALS}

## Tech Stack
${P_STACK}

## Communication Style
${P_COMM}

## What I Value in Output
${P_VALUES}
EOF
    fi

    success "about-me.md — customized and saved"
    ;;
esac


# ═════════════════════════════════════════════════════════════════
# STEP 2: anti-ai-writing-style.md
# ═════════════════════════════════════════════════════════════════

divider
printf "\n  ${GREEN}◆ Step 2/4 — anti-ai-writing-style.md${RESET}\n"
dim "Rules for how Claude should (and should not) write."

prompt_choice_skip "Use default" "Customize"

case $PROMPT_RESULT in
3)
    SKIP_WRITING_STYLE=true
    success "anti-ai-writing-style.md — skipped"
    ;;
1)
    success "anti-ai-writing-style.md — default accepted"
    ;;
2)
    printf "\n  ${CREAM}Customize your writing rules.${RESET}\n\n"

    read -rp "    Preferred tone (formal/informal/neutral/academic) [neutral]: " S_TONE
    S_TONE="${S_TONE:-neutral}"
    read -rp "    Phrases to ban (comma-separated, or press Enter to skip): " S_BANNED
    read -rp "    Domain-specific writing conventions (or press Enter to skip): " S_DOMAIN
    read -rp "    Additional rules (or press Enter to skip): " S_RULES

    {
        echo ""
        echo "---"
        echo ""
        echo "## Custom Rules (added during init)"
        echo ""
        echo "**Tone:** ${S_TONE}"
        if [ -n "$S_BANNED" ]; then
            echo ""
            echo "**Additional banned phrases:**"
            IFS=',' read -ra PHRASES <<< "$S_BANNED"
            for phrase in "${PHRASES[@]}"; do
                trimmed=$(echo "$phrase" | xargs)
                echo "- ${trimmed}"
            done
        fi
        if [ -n "$S_DOMAIN" ]; then
            echo ""
            echo "**Domain conventions:** ${S_DOMAIN}"
        fi
        if [ -n "$S_RULES" ]; then
            echo ""
            echo "**Additional rules:** ${S_RULES}"
        fi
    } >> "$TARGET/ABOUT-ME/anti-ai-writing-style.md"

    success "anti-ai-writing-style.md — customized and saved"
    ;;
esac


# ═════════════════════════════════════════════════════════════════
# STEP 3: GLOBAL-INSTRUCTIONS.md
# ═════════════════════════════════════════════════════════════════

divider
printf "\n  ${GREEN}◆ Step 3/4 — GLOBAL-INSTRUCTIONS.md${RESET}\n"
dim "Boot sequence, folder protocol, naming, and domain defaults."

prompt_choice_skip "Use default" "Customize"

case $PROMPT_RESULT in
3)
    SKIP_GLOBAL=true
    success "GLOBAL-INSTRUCTIONS.md — skipped"
    ;;
1)
    generate_global_instructions
    success "GLOBAL-INSTRUCTIONS.md — generated"
    ;;
2)
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
    ;;
esac


# ═════════════════════════════════════════════════════════════════
# STEP 4: Finalize
# ═════════════════════════════════════════════════════════════════

divider
printf "\n  ${GREEN}◆ Step 4/4 — Finalize${RESET}\n\n"

if ! $SKIP_GLOBAL; then
    printf "  ${CREAM}Copy the content below and paste into:${RESET}\n"
    printf "  ${BOLD}Settings → Cowork → Edit Global Instructions${RESET}\n"

    printf "\n  ${TERRA}━━━━━━━━━ COPY BELOW THIS LINE ━━━━━━━━━${RESET}\n\n"
    cat "$TARGET/GLOBAL-INSTRUCTIONS.md"
    printf "\n\n  ${TERRA}━━━━━━━━━ COPY ABOVE THIS LINE ━━━━━━━━━${RESET}\n"
else
    dim "GLOBAL-INSTRUCTIONS.md was skipped. No content to paste."
fi

printf "\n  ${GREEN}✓${RESET} Interactive configuration complete.\n\n"

# List configured files (excluding skipped ones)
CONFIGURED=()
$SKIP_ABOUT_ME      || CONFIGURED+=("CLAUDE/ABOUT-ME/about-me.md")
$SKIP_WRITING_STYLE || CONFIGURED+=("CLAUDE/ABOUT-ME/anti-ai-writing-style.md")
$SKIP_GLOBAL        || CONFIGURED+=("CLAUDE/GLOBAL-INSTRUCTIONS.md")

if [ ${#CONFIGURED[@]} -gt 0 ]; then
    printf "  ${CREAM}Files configured:${RESET}\n"
    for f in "${CONFIGURED[@]}"; do
        printf "    • %s\n" "$f"
    done
else
    dim "No files were configured (all steps skipped)."
fi

# List skipped sections
SKIPPED=()
$SKIP_ABOUT_ME      && SKIPPED+=("about-me.md")
$SKIP_WRITING_STYLE && SKIPPED+=("anti-ai-writing-style.md")
$SKIP_GLOBAL        && SKIPPED+=("GLOBAL-INSTRUCTIONS.md")

if [ ${#SKIPPED[@]} -gt 0 ]; then
    printf "\n  ${DIM}Skipped: %s${RESET}\n" "$(IFS=', '; echo "${SKIPPED[*]}")"
fi

printf "\n  ${DIM}Continuing with installation steps...${RESET}\n\n"
