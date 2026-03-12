<p align="center">
  <img src="docs/claudio-logo.png" alt="Claudio" width="160"/>
</p>

<h1 align="center">Claudio-Cowork</h1>

<p align="center">
  Persistent memory and custom skills for <a href="https://claude.ai">Claude Cowork</a>.<br/>
  Clone it inside your project. Run <code>make init</code>. Claude configures everything and installs <code>CLAUDE/</code> into your project root.
</p>

<p align="center">
  <a href="HOW-TO.md">Setup Guide</a> &middot;
  <a href="HOW-TO.md#the-meta-prompt-generator-skill">Meta-Prompt Generator</a> &middot;
  <a href="HOW-TO.md#how-it-works-end-to-end">How It Works</a>
</p>

---

## The Problem

Claude Cowork starts every session with zero context about you. You re-explain your stack, re-correct the same writing habits, and re-describe your project conventions each time.

This repository eliminates that. Clone it inside your existing project, run `make init`, and Claude analyzes your project, builds your profile, configures everything interactively, installs the `CLAUDE/` directory into your project root, and packages and installs skills. The `claudio-cowork/` directory is automatically added to `.gitignore` so it stays local and is never committed.

## How It Works

```
You clone claudio-cowork inside your project
    ↓
cd claudio-cowork && make init
    ↓
Each file: choose 1) Use default  or  2) Customize
    ↓
about-me.md → anti-ai-writing-style.md → GLOBAL-INSTRUCTIONS.md
    ↓
Copy the output into Cowork Global Instructions
    ↓
CLAUDE/ is copied to your project root automatically
    ↓
Choose whether to install skills (1. Yes / 2. No)
    ↓
claudio-cowork/ is added to .gitignore (stays local, never committed)
    ↓
Your project now has CLAUDE/ at the root — mount it in Cowork
    ↓
Every session begins with Claude reading your full context
```

Four mechanisms compound over time:

- **Static context** (`CLAUDE/ABOUT-ME/`) — your profile, stack, and communication preferences, read every session
- **Dynamic corrections** (`feedback.md`) — one-line fixes that accumulate into a personalized fine-tuning layer
- **Structural guardrails** (`CLAUDE/GLOBAL-INSTRUCTIONS.md`) — folder protocol, naming conventions, domain defaults
- **Automated audit** (scheduled task) — weekly review of outputs against your standards, catching drift before it compounds

The prompts stay simple. The context does the heavy lifting.

## What `make init` Produces

After `make init` completes, your project looks like this:

```
your-project/
├── .gitignore                            ← claudio-cowork/ entry added automatically
├── your existing files...
├── claudio-cowork/                       ← Stays local, git-ignored
│   ├── Makefile
│   ├── SKILLS/
│   ├── scripts/
│   └── ...
└── CLAUDE/                               ← Installed by make init
    ├── ABOUT-ME/                         ← Your profile, writing rules, correction log
    │   ├── about-me.md                   ← Generated from project analysis or your answers
    │   ├── anti-ai-writing-style.md      ← Default or customized during init
    │   └── feedback.md                   ← Running correction log
    ├── PROJECTS/                         ← Your briefs, references, data (per project)
    ├── OUTPUTS/                          ← Where Claude delivers work
    ├── GLOBAL-INSTRUCTIONS.md            ← Paste into Settings → Cowork
    └── PROMPT-TEMPLATE.md                ← Reusable prompt + Mac shortcut setup
```

Skills from `SKILLS/` are packaged as `.skill` files and opened for install in Claude Desktop. The `claudio-cowork/` directory remains on disk but is git-ignored — it is never committed to your repository.

## Quick Start

```bash
# From inside your existing project directory:
git clone https://github.com/<your-username>/claudio-cowork.git
cd claudio-cowork
make init
```

`make init` runs a complete setup sequence:

1. **Install templates** — Copies the `CLAUDE/` template directory to your project root. Templates inside `claudio-cowork/` are never modified.
2. **`about-me.md`** — Select **1 (Context)** to have Claude analyze your project and generate a profile automatically, or **2 (Customize)** to answer guided questions and build a profile from your answers.
3. **`anti-ai-writing-style.md`** — Select **1** to keep the default writing rules, or **2** to customize tone, banned phrases, and domain conventions.
4. **`GLOBAL-INSTRUCTIONS.md`** — Select **1** to keep the default control plane, or **2** to customize naming conventions, domain defaults, and operating rules.
5. **Finalize** — Outputs the final `GLOBAL-INSTRUCTIONS.md` content in the terminal. Copy and paste it into **Settings → Cowork → Edit Global Instructions**.
6. **Install skills** — Select **1 (Yes)** to package and install all skills from `SKILLS/`, or **2 (No)** to skip. Skills can always be installed later with `make skills`.
7. **Update `.gitignore`** — Adds `claudio-cowork/` to the project root `.gitignore` (creates the file if needed).

All configuration writes go to `project-root/CLAUDE/`. The template files in `claudio-cowork/CLAUDE/` are read-only and always reusable.

After `make init` completes:

1. Accept the skill install prompts in Claude Desktop
2. Open Claude Desktop → **Settings → Cowork → Edit Global Instructions** → paste the output from step 4
3. Start a Cowork session → **Add Folder** → select your project directory (which now contains `CLAUDE/`)
4. (Optional) Set up the [`/prompt` Mac text shortcut](HOW-TO.md#setting-up-the-prompt-template-and-mac-shortcut)
5. (Optional) Create the [weekly output audit](HOW-TO.md#scheduled-output-audit)

Full walkthrough: [`HOW-TO.md`](HOW-TO.md)

## What's Inside CLAUDE/

| File | Purpose |
|------|---------|
| `CLAUDE/ABOUT-ME/about-me.md` | Identity file — name, role, domains, tech stack, priorities, communication style. Claude reads this first to calibrate every output. |
| `CLAUDE/ABOUT-ME/anti-ai-writing-style.md` | Kill list of AI writing patterns (filler, engagement loops, closure templates, buzzwords) plus positive rules for tone, structure, and domain conventions. |
| `CLAUDE/ABOUT-ME/feedback.md` | Running correction log. One line per fix. Read before every task, applied as overrides. Grows over time into a personalized fine-tuning layer. |
| `CLAUDE/GLOBAL-INSTRUCTIONS.md` | Control plane. Folder protocol (read-only + write), naming conventions, domain defaults. Paste into Cowork settings. |
| `CLAUDE/PROMPT-TEMPLATE.md` | Reusable prompt that forces context loading → clarification → execution. Includes Mac text shortcut setup. |
| `CLAUDE/PROJECTS/` | Project-specific briefs, references, datasets, and finished work. One subfolder per project. Claude reads the matching subfolder when a task relates to a project. |

## The Meta-Prompt Generator

The most complex component. It compiles unstructured input into deterministic, contract-grade agent specifications. Installed as a skill during `make init`.

```
raw idea / codebase / API docs
    ↓
meta-prompt → prompt → spec → code
```

The skill classifies your input, extracts requirements through structured questions, generates a YAML frontmatter (single source of truth) with a Markdown body (examples, anti-patterns, implementation guidance), then runs 9 quality checks before delivering the spec.

Output format rationale — why YAML+Markdown over XML, structured Markdown, or flexible formats — is documented in the skill's `references/output-format-rationale.md`. The short version: YAML+MD wins for human-in-the-loop workflows; XML wins for pure automation; the recommended architecture is hybrid (YAML+MD early, XML late).

## Methodology

Follows a "context over prompting" philosophy, inspired by [Ruben Hassid's Cowork customization guide](https://ruben.substack.com/p/claude-cowork). Instead of crafting perfect prompts per task, give Claude persistent context about who you are and how you work. Output quality improves over time without changing any prompts.

This system was built for a quantitative engineering workflow (systematic trading, ML research, full-stack development), but the architecture is domain-agnostic. Fork it, replace the content, and it works for any domain.
