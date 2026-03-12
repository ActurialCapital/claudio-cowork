#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
# claudio-cowork interactive initialization
# Handles user interaction via bash; uses claude -p for AI tasks.
# Exits naturally so the Makefile can continue post-config steps.
# ─────────────────────────────────────────────────────────────────

# ── Colors (match Makefile palette) ──
GREEN='\033[38;5;108m'
CREAM='\033[38;5;223m'
BROWN='\033[38;5;130m'
TERRA='\033[38;5;173m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Verify working directory ──
if [ ! -f "Makefile" ] || [ ! -d "CLAUDE" ]; then
    printf "  ${BROWN}⚠${RESET}  Error: must run from the claudio-cowork/ directory.\n"
    exit 1
fi

# ── Target directory (project root CLAUDE/, never the local templates) ──
TARGET="../CLAUDE"
if [ ! -d "$TARGET" ]; then
    printf "  ${BROWN}⚠${RESET}  Error: ${TARGET} not found. Run this script via 'make init'.\n"
    exit 1
fi

# ── Check for Claude CLI ──
HAS_CLAUDE=false
if command -v claude &>/dev/null; then
    HAS_CLAUDE=true
fi

# ── Utilities ──

divider() {
    printf "\n  ${TERRA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

prompt_choice() {
    # Returns 0 for "Use default", 1 for "Customize"
    while true; do
        printf "\n    ${BROWN}1.${RESET} Use default\n"
        printf "    ${BROWN}2.${RESET} Customize\n\n"
        read -rp "    Selection [1/2]: " choice
        case "$choice" in
            1) return 0 ;;
            2) return 1 ;;
            *) printf "    ${BROWN}⚠${RESET}  Invalid selection. Enter 1 or 2.\n" ;;
        esac
    done
}


# ═════════════════════════════════════════════════════════════════
# STEP 1: about-me.md
# ═════════════════════════════════════════════════════════════════

printf "\n  ${GREEN}◆ Step 1/4 — about-me.md${RESET}\n"
printf "  ${DIM}Your developer profile, project context, and preferences.${RESET}\n"

# Step 1 uses its own prompt: Context / Customize
STEP1_CHOICE=""
while true; do
    printf "\n    ${BROWN}1.${RESET} Context\n"
    printf "    ${BROWN}2.${RESET} Customize\n\n"
    read -rp "    Selection [1/2]: " STEP1_CHOICE
    case "$STEP1_CHOICE" in
        1|2) break ;;
        *) printf "    ${BROWN}⚠${RESET}  Invalid selection. Enter 1 or 2.\n" ;;
    esac
done

if [ "$STEP1_CHOICE" = "1" ]; then
    # ── Context: analyze the parent project ──
    printf "\n  ${DIM}Analyzing project root...${RESET}\n"

    ANALYSIS=""

    if $HAS_CLAUDE; then
        # Gather project file contents from the parent directory
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
        # Include directory listing for structural signals
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
        printf "    ${GREEN}✓${RESET} about-me.md — generated from project context\n"
    else
        printf "    ${BROWN}⚠${RESET}  Could not analyze project (Claude CLI unavailable or no project files found).\n"
        printf "    ${DIM}Keeping default template. You can edit it manually later.${RESET}\n"
    fi
else
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
        printf "\n  ${DIM}Generating profile...${RESET}\n"
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
        # Fallback: write directly from answers
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

    printf "  ${GREEN}✓${RESET} about-me.md — customized and saved\n"
fi


# ═════════════════════════════════════════════════════════════════
# STEP 2: anti-ai-writing-style.md
# ═════════════════════════════════════════════════════════════════

divider
printf "\n  ${GREEN}◆ Step 2/4 — anti-ai-writing-style.md${RESET}\n"
printf "  ${DIM}Rules for how Claude should (and should not) write.${RESET}\n"

if prompt_choice; then
    printf "    ${GREEN}✓${RESET} anti-ai-writing-style.md — default accepted\n"
else
    printf "\n  ${CREAM}Customize your writing rules.${RESET}\n\n"

    read -rp "    Preferred tone (formal/informal/neutral/academic) [neutral]: " S_TONE
    S_TONE="${S_TONE:-neutral}"
    read -rp "    Phrases to ban (comma-separated, or press Enter to skip): " S_BANNED
    read -rp "    Domain-specific writing conventions (or press Enter to skip): " S_DOMAIN
    read -rp "    Additional rules (or press Enter to skip): " S_RULES

    # Append customizations to the existing file
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

    printf "\n    ${GREEN}✓${RESET} anti-ai-writing-style.md — customized and saved\n"
fi


# ═════════════════════════════════════════════════════════════════
# STEP 3: GLOBAL-INSTRUCTIONS.md
# ═════════════════════════════════════════════════════════════════

divider
printf "\n  ${GREEN}◆ Step 3/4 — GLOBAL-INSTRUCTIONS.md${RESET}\n"
printf "  ${DIM}Boot sequence, folder protocol, naming, and domain defaults.${RESET}\n"

if prompt_choice; then
    printf "    ${GREEN}✓${RESET} GLOBAL-INSTRUCTIONS.md — default accepted\n"
else
    printf "\n  ${CREAM}Customize your global instructions.${RESET}\n\n"

    read -rp "    Output naming convention [project_content-type_v1.ext]: " G_NAMING
    G_NAMING="${G_NAMING:-project_content-type_v1.ext}"
    read -rp "    Domain-specific defaults (or press Enter to skip): " G_DEFAULTS
    read -rp "    Additional operating rules (or press Enter to skip): " G_RULES

    # Append customizations
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

    printf "\n    ${GREEN}✓${RESET} GLOBAL-INSTRUCTIONS.md — customized and saved\n"
fi


# ═════════════════════════════════════════════════════════════════
# STEP 4: Finalize
# ═════════════════════════════════════════════════════════════════

divider
printf "\n  ${GREEN}◆ Step 4/4 — Finalize${RESET}\n\n"
printf "  ${CREAM}Copy the content below and paste into:${RESET}\n"
printf "  ${BOLD}Settings → Cowork → Edit Global Instructions${RESET}\n"

printf "\n  ${TERRA}━━━━━━━━━ COPY BELOW THIS LINE ━━━━━━━━━${RESET}\n\n"
cat "$TARGET/GLOBAL-INSTRUCTIONS.md"
printf "\n\n  ${TERRA}━━━━━━━━━ COPY ABOVE THIS LINE ━━━━━━━━━${RESET}\n"

printf "\n  ${GREEN}✓${RESET} Interactive configuration complete.\n\n"
printf "  ${CREAM}Files configured:${RESET}\n"
printf "    • CLAUDE/ABOUT-ME/about-me.md\n"
printf "    • CLAUDE/ABOUT-ME/anti-ai-writing-style.md\n"
printf "    • CLAUDE/GLOBAL-INSTRUCTIONS.md\n"
printf "\n  ${DIM}Continuing with installation steps...${RESET}\n\n"
