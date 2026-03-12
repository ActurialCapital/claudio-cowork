#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# Package and open skills for install in Claude Desktop.
# Expects .skill files to already exist in dist/ (built by Make).
# ─────────────────────────────────────────────────────────────────

DIST_DIR="$COWORK_DIR/dist"

# ── Confirmation prompt (standalone mode only) ──
if [ "${CLAUDIO_NESTED:-}" != "1" ]; then
    echo ""
    info "Install skills?"
    if ! prompt_yesno; then
        success "Skipped skills installation"
        echo ""
        exit 0
    fi
fi

echo ""
info "Opening skills for install..."
echo ""

if [ ! -d "$DIST_DIR" ] || [ -z "$(ls "$DIST_DIR"/*.skill 2>/dev/null)" ]; then
    warn "No .skill files found in dist/. Run 'make skills' to package them."
    exit 0
fi

for f in "$DIST_DIR"/*.skill; do
    name=$(basename "$f" .skill)
    if open_file "$f"; then
        success "$name"
    else
        printf "    ${GRAY}→${RESET} %s: open %s manually\n" "$name" "$f"
    fi
done

echo ""
printf "  ${TERRA}◆${RESET} ${BOLD}Accept the install prompt${RESET} in Claude Desktop for each skill.\n"
echo ""
divider
printf "  ${BOLD}${CREAM}  Finish setup — 3 steps${RESET}\n"
divider
echo ""
printf "  ${BROWN}1.${RESET}  ${CREAM}Global Instructions${RESET}\n"
printf "      Open ${BOLD}GLOBAL-INSTRUCTIONS.md${RESET} in this repo.\n"
printf "      Copy everything below the dotted line.\n"
printf "      Paste into ${DIM}Settings → Cowork → Edit Global Instructions${RESET}\n"
echo ""
printf "  ${BROWN}2.${RESET}  ${CREAM}Make it yours${RESET}\n"
printf "      Replace files in ${BOLD}ABOUT-ME/${RESET} with your profile and writing rules.\n"
printf "      Edit ${BOLD}anti-ai-writing-style.md${RESET} to match your voice.\n"
echo ""
printf "  ${BROWN}3.${RESET}  ${CREAM}Mount this folder${RESET}\n"
printf "      Start a Cowork session → ${BOLD}Add Folder${RESET} → select ${DIM}claudio-cowork/${RESET}\n"
printf "      Claude will read your context automatically on every task.\n"
echo ""
divider
printf "  ${DIM}${CREAM}  Done. Start a new Cowork session.${RESET}\n"
divider
echo ""
