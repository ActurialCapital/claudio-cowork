.PHONY: skills clean help

SKILLS_DIR := SKILLS
DIST_DIR := dist
SKILLS := $(wildcard $(SKILLS_DIR)/*/SKILL.md)
SKILL_DIRS := $(patsubst %/SKILL.md,%,$(SKILLS))
SKILL_FILES := $(patsubst $(SKILLS_DIR)/%,$(DIST_DIR)/%.skill,$(SKILL_DIRS))

# ── Claude color palette ──────────────────────────────────────────
# Terracotta (#D97757), warm brown, cream accents
# ANSI approximations for terminal output
RESET  := \033[0m
BOLD   := \033[1m
DIM    := \033[2m
TERRA  := \033[38;5;173m
BROWN  := \033[38;5;130m
CREAM  := \033[38;5;223m
GREEN  := \033[38;5;108m
GRAY   := \033[38;5;245m

# ── Header ────────────────────────────────────────────────────────
define LOGO

  $(TERRA)┌─────────────────────────────────────────┐$(RESET)
  $(TERRA)│$(RESET)  $(BOLD)$(BROWN)✦  C L A U D I O$(RESET)                       $(TERRA)│$(RESET)
  $(TERRA)│$(RESET)  $(DIM)$(CREAM)Claude Cowork customization system$(RESET)     $(TERRA)│$(RESET)
  $(TERRA)└─────────────────────────────────────────┘$(RESET)

endef
export LOGO

# ── Targets ───────────────────────────────────────────────────────

help: ## Show available commands
	@echo "$$LOGO"
	@printf "  $(CREAM)Commands:$(RESET)\n"
	@printf "  $(TERRA)make skills$(RESET)  $(DIM)Package and install all skills$(RESET)\n"
	@printf "  $(TERRA)make clean$(RESET)   $(DIM)Remove dist/$(RESET)\n"
	@printf "  $(TERRA)make help$(RESET)    $(DIM)Show this message$(RESET)\n"
	@echo ""

skills: $(SKILL_FILES) ## Package and install all skills
	@echo ""
	@printf "  $(GREEN)◆ Opening skills for install...$(RESET)\n"
	@echo ""
	@for f in $(SKILL_FILES); do \
		name=$$(basename "$$f" .skill); \
		if [ "$$(uname)" = "Darwin" ]; then \
			open "$$f" 2>/dev/null; \
			printf "    $(GREEN)✓$(RESET)  $(CREAM)$$name$(RESET)\n"; \
		elif command -v xdg-open >/dev/null 2>&1; then \
			xdg-open "$$f" 2>/dev/null; \
			printf "    $(GREEN)✓$(RESET)  $(CREAM)$$name$(RESET)\n"; \
		else \
			printf "    $(GRAY)→$(RESET)  $$name: open $$f manually\n"; \
		fi; \
	done
	@echo ""
	@printf "  $(TERRA)◆$(RESET) $(BOLD)Accept the install prompt$(RESET) in Claude Desktop for each skill.\n"
	@echo ""
	@printf "  $(TERRA)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@printf "  $(BOLD)$(CREAM)  Finish setup — 3 steps$(RESET)\n"
	@printf "  $(TERRA)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@echo ""
	@printf "  $(BROWN)1.$(RESET)  $(CREAM)Global Instructions$(RESET)\n"
	@printf "      Open $(BOLD)GLOBAL-INSTRUCTIONS.md$(RESET) in this repo.\n"
	@printf "      Copy everything below the dotted line.\n"
	@printf "      Paste into $(DIM)Settings → Cowork → Edit Global Instructions$(RESET)\n"
	@echo ""
	@printf "  $(BROWN)2.$(RESET)  $(CREAM)Make it yours$(RESET)\n"
	@printf "      Replace files in $(BOLD)ABOUT-ME/$(RESET) with your profile and writing rules.\n"
	@printf "      Edit $(BOLD)anti-ai-writing-style.md$(RESET) to match your voice.\n"
	@echo ""
	@printf "  $(BROWN)3.$(RESET)  $(CREAM)Mount this folder$(RESET)\n"
	@printf "      Start a Cowork session → $(BOLD)Add Folder$(RESET) → select $(DIM)claudio-cowork/$(RESET)\n"
	@printf "      Claude will read your context automatically on every task.\n"
	@echo ""
	@printf "  $(TERRA)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@printf "  $(DIM)$(CREAM)  Done. Start a new Cowork session.$(RESET)\n"
	@printf "  $(TERRA)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@echo ""

$(DIST_DIR)/%.skill: $(SKILLS_DIR)/%/SKILL.md
	@mkdir -p $(DIST_DIR)
	@printf "  $(BROWN)◇$(RESET)  Packaging $(CREAM)$*$(RESET)...\n"
	@cd $(SKILLS_DIR) && zip -r ../$(DIST_DIR)/$*.skill $*/ \
		-x "*/__pycache__/*" \
		-x "*/node_modules/*" \
		-x "*/.DS_Store" \
		-x "*.pyc" \
		-x "$*/evals/*" > /dev/null 2>&1

clean: ## Remove dist/
	@echo ""
	@if [ -d "$(DIST_DIR)" ]; then \
		count=$$(find $(DIST_DIR) -name "*.skill" 2>/dev/null | wc -l | tr -d ' '); \
		rm -rf $(DIST_DIR); \
		printf "  $(GREEN)✓$(RESET)  $(CREAM)Removed $(BOLD)$$count$(RESET)$(CREAM) skill package(s) from dist/$(RESET)\n"; \
	else \
		printf "  $(DIM)$(GRAY)◇  Nothing to clean$(RESET)\n"; \
	fi
	@echo ""
