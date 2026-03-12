#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# about-me.sh — Configure CLAUDE/ABOUT-ME/about-me.md
# Can run standalone (make about-me) or as part of init flow.
# ─────────────────────────────────────────────────────────────────

require_cowork_dir
require_target_dir

HAS_CLAUDE=false
if has_command claude; then
    HAS_CLAUDE=true
fi

step_header "about-me.md" "Your developer profile, project context, and preferences."

prompt_choice_skip "Context" "Customize"

case $PROMPT_RESULT in
3)
    state_set "SKIP_ABOUT_ME" "true"
    success "about-me.md — skipped"
    ;;
1)
    # ── Context: analyze the parent project ──
    ensure_about_me_dir
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
        copy_template "ABOUT-ME/about-me.md"
        dim "Using default template. You can edit it manually later."
    fi
    ;;
2)
    # ── Customize: guided question flow ──
    ensure_about_me_dir
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
