#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# claudio-cowork shared library
# Source this file from any script: source "$(dirname "$0")/lib.sh"
# ─────────────────────────────────────────────────────────────────

# ── Colors (single source of truth for the entire project) ──
GREEN='\033[38;5;108m'
CREAM='\033[38;5;223m'
BROWN='\033[38;5;130m'
TERRA='\033[38;5;173m'
GRAY='\033[38;5;245m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Paths ──
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COWORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$COWORK_DIR/.." && pwd)"
TARGET="$PROJECT_ROOT/CLAUDE"

# ── Output helpers ──

info() {
    printf "  ${GREEN}◆ %s${RESET}\n" "$1"
}

success() {
    printf "    ${GREEN}✓${RESET} ${CREAM}%s${RESET}\n" "$1"
}

warn() {
    printf "    ${BROWN}⚠${RESET} ${CREAM}%s${RESET}\n" "$1"
}

hint() {
    printf "      ${DIM}%s${RESET}\n" "$1"
}

dim() {
    printf "  ${DIM}%s${RESET}\n" "$1"
}

divider() {
    printf "\n  ${TERRA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

# ── Validation ──

has_command() {
    command -v "$1" >/dev/null 2>&1
}

require_cowork_dir() {
    if [ ! -f "$COWORK_DIR/Makefile" ] || [ ! -d "$COWORK_DIR/CLAUDE" ]; then
        printf "  ${BROWN}⚠${RESET}  Error: must run from the claudio-cowork/ directory.\n"
        exit 1
    fi
}

require_target_dir() {
    if [ ! -d "$TARGET" ]; then
        printf "  ${BROWN}⚠${RESET}  Error: ${TARGET} not found. Run this script via 'make init'.\n"
        exit 1
    fi
}

# ── Interactive prompts ──

# Generic two-option prompt. Returns 0 for option 1, 1 for option 2.
# Usage: prompt_choice "Use default" "Customize" && echo "chose 1" || echo "chose 2"
prompt_choice() {
    local label1="${1:-Use default}"
    local label2="${2:-Customize}"
    while true; do
        printf "\n    ${BROWN}1.${RESET} %s\n" "$label1"
        printf "    ${BROWN}2.${RESET} %s\n\n" "$label2"
        read -rp "    Selection [1/2]: " choice
        case "$choice" in
            1) return 0 ;;
            2) return 1 ;;
            *) printf "    ${BROWN}⚠${RESET}  Invalid selection. Enter 1 or 2.\n" ;;
        esac
    done
}

# Yes/No prompt. Returns 0 for Yes, 1 for No.
prompt_yesno() {
    prompt_choice "Yes" "No"
}

# Three-option prompt with Skip. Sets PROMPT_RESULT to 1, 2, or 3.
# Usage: prompt_choice_skip "Context" "Customize"
#        case $PROMPT_RESULT in 1) ... ;; 2) ... ;; 3) skip ;; esac
prompt_choice_skip() {
    local label1="${1:-Use default}"
    local label2="${2:-Customize}"
    while true; do
        printf "\n    ${BROWN}1.${RESET} %s\n" "$label1"
        printf "    ${BROWN}2.${RESET} %s\n" "$label2"
        printf "    ${BROWN}3.${RESET} Skip\n\n"
        read -rp "    Selection [1/2/3]: " choice
        case "$choice" in
            1) PROMPT_RESULT=1; return 0 ;;
            2) PROMPT_RESULT=2; return 0 ;;
            3) PROMPT_RESULT=3; return 0 ;;
            *) printf "    ${BROWN}⚠${RESET}  Invalid selection. Enter 1, 2, or 3.\n" ;;
        esac
    done
}

# ── Filesystem helpers ──

# Ensure an entry exists in a file (idempotent append).
# Usage: ensure_line_in_file "/path/to/.gitignore" "claudio-cowork/"
ensure_line_in_file() {
    local file="$1"
    local line="$2"
    if [ ! -f "$file" ]; then
        printf "%s\n" "$line" > "$file"
        return 0  # created
    elif ! grep -qxF "$line" "$file"; then
        printf "\n%s\n" "$line" >> "$file"
        return 0  # appended
    fi
    return 1  # already present
}

# Copy a directory tree without overwriting existing files.
# Usage: copy_no_clobber "source/" "dest/"
copy_no_clobber() {
    local src="$1"
    local dst="$2"
    cp -rn "$src" "$dst" 2>/dev/null ||
    cp -r --no-clobber "$src" "$dst" 2>/dev/null ||
    cp -r "$src" "$dst"
}

# Open a file with the platform-appropriate handler.
# Usage: open_file "path/to/file.skill"
open_file() {
    local file="$1"
    if [ "$(uname)" = "Darwin" ]; then
        open "$file" 2>/dev/null
    elif has_command xdg-open; then
        xdg-open "$file" 2>/dev/null
    else
        return 1
    fi
}
