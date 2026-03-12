#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# ─────────────────────────────────────────────────────────────────
# init.sh — Orchestrator for interactive configuration
# Calls modular scripts in sequence with step numbering.
# Each module is self-contained and can also run standalone.
# ─────────────────────────────────────────────────────────────────

require_cowork_dir

# Initialize inter-module state
state_init

# Step 1: about-me.md
INIT_STEP="Step 1/5" bash "$SCRIPT_DIR/about-me.sh"

divider

# Step 2: anti-ai-writing-style.md
INIT_STEP="Step 2/5" bash "$SCRIPT_DIR/code-style.sh"

divider

# Step 3: feedback.md
INIT_STEP="Step 3/5" bash "$SCRIPT_DIR/feedback.sh"

divider

# Step 4: GLOBAL-INSTRUCTIONS.md
INIT_STEP="Step 4/5" bash "$SCRIPT_DIR/global-instructions.sh"

divider

# Step 5: Finalize
INIT_STEP="Step 5/5" bash "$SCRIPT_DIR/finalize.sh"
