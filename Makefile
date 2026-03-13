.PHONY: init about-me code-style feedback global-instructions instructions agents-md claude-md skills plugins clean help

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
	@printf "  $(TERRA)make init$(RESET)               $(DIM)Run interactive Claude-driven setup$(RESET)\n"
	@printf "  $(TERRA)make about-me$(RESET)            $(DIM)Configure about-me.md$(RESET)\n"
	@printf "  $(TERRA)make code-style$(RESET)          $(DIM)Configure anti-ai-writing-style.md$(RESET)\n"
	@printf "  $(TERRA)make feedback$(RESET)            $(DIM)Configure feedback.md$(RESET)\n"
	@printf "  $(TERRA)make global-instructions$(RESET) $(DIM)Configure GLOBAL-INSTRUCTIONS.md$(RESET)\n"
	@printf "  $(TERRA)make instructions$(RESET)        $(DIM)Configure AGENTS.md + CLAUDE.md$(RESET)\n"
	@printf "  $(TERRA)make agents-md$(RESET)           $(DIM)Configure AGENTS.md standalone$(RESET)\n"
	@printf "  $(TERRA)make claude-md$(RESET)           $(DIM)Configure CLAUDE.md standalone$(RESET)\n"
	@printf "  $(TERRA)make skills$(RESET)              $(DIM)Package and install all skills$(RESET)\n"
	@printf "  $(TERRA)make plugins$(RESET)             $(DIM)Install plugins from plugins.yaml$(RESET)\n"
	@printf "  $(TERRA)make clean$(RESET)               $(DIM)Remove dist/$(RESET)\n"
	@printf "  $(TERRA)make help$(RESET)                $(DIM)Show this message$(RESET)\n"
	@echo ""

init: ## Interactive Claude-driven setup for your project
	@echo "$$LOGO"
	@printf "  $(GREEN)◆ Starting interactive setup...$(RESET)\n"
	@echo ""
	@printf "  $(CREAM)Configure your project step by step.$(RESET)\n"
	@printf "  $(DIM)Each step lets you configure, use defaults, or skip.$(RESET)\n"
	@echo ""
	@printf "  $(TERRA)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@echo ""
	@bash scripts/init.sh
	@printf "  $(TERRA)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@echo ""
	@bash scripts/init-plugins.sh $(MAKE)
	@bash scripts/gitignore.sh
	@bash scripts/init-instructions.sh
	@bash scripts/init-skills.sh $(MAKE)
	@printf "  $(TERRA)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@printf "  $(DIM)$(CREAM)Setup complete.$(RESET)\n"
	@printf "  $(DIM)$(CREAM)claudio-cowork/ is git-ignored and stays local.$(RESET)\n"
	@printf "  $(TERRA)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@echo ""

about-me: ## Configure about-me.md standalone
	@echo "$$LOGO"
	@bash scripts/templates.sh
	@bash scripts/about-me.sh

code-style: ## Configure anti-ai-writing-style.md standalone
	@echo "$$LOGO"
	@bash scripts/templates.sh
	@bash scripts/code-style.sh

feedback: ## Configure feedback.md standalone
	@echo "$$LOGO"
	@bash scripts/templates.sh
	@bash scripts/feedback.sh

global-instructions: ## Configure GLOBAL-INSTRUCTIONS.md standalone
	@echo "$$LOGO"
	@bash scripts/templates.sh
	@bash scripts/global-instructions.sh

instructions: ## Configure AGENTS.md + CLAUDE.md
	@echo "$$LOGO"
	@bash scripts/instructions.sh

agents-md: ## Configure AGENTS.md standalone
	@echo "$$LOGO"
	@bash scripts/agents-md.sh

claude-md: ## Configure CLAUDE.md standalone
	@echo "$$LOGO"
	@bash scripts/claude-md.sh

plugins: ## Install plugins from plugins.yaml
	@echo "$$LOGO"
	@bash scripts/plugins.sh

skills: $(SKILL_FILES) ## Package and install all skills
	@bash scripts/skills.sh

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
		printf "  $(GREEN)✓$(RESET) $(CREAM)Removed $(BOLD)$$count$(RESET)$(CREAM) skill package(s) from dist/$(RESET)\n"; \
	else \
		printf "  $(DIM)$(GRAY)◇ Nothing to clean$(RESET)\n"; \
	fi
	@echo ""
