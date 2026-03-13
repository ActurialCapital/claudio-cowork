# HOW-TO Guide

Actionable steps for setting up, customizing, and extending claudio-cowork. For conceptual explanations — how orchestration works, responsibility division, and architecture — see [`README.md`](README.md).

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [The `make init` Process](#the-make-init-process)
4. [Plugins Installation](#plugins-installation)
5. [Personalizing Your Profile](#personalizing-your-profile)
6. [The Feedback Loop](#the-feedback-loop)
7. [Prompt Template & Mac Shortcut](#prompt-template--mac-shortcut)
8. [The Meta-Prompt Generator Skill](#the-meta-prompt-generator-skill)
9. [Scheduled Output Audit](#scheduled-output-audit)
10. [Adding Your Own Skills](#adding-your-own-skills)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Claude Desktop with Cowork mode enabled (macOS, research preview)
- An existing project directory
- Node.js (for GSD plugin, optional)
- Claude CLI (for Superpowers plugin, about-me Context mode, and instruction file Context mode — optional)

---

## Initial Setup

### 1. Clone and Run

```bash
cd /path/to/your-project
git clone https://github.com/<your-username>/claudio-cowork.git
cd claudio-cowork
make init
```

### 2. Paste Global Instructions

During `make init`, the final `GLOBAL-INSTRUCTIONS.md` content is output between copy markers. Paste it into **Settings → Cowork → Edit Global Instructions**.

### 3. Accept Skill Installs

If you selected Yes for skills, accept each install prompt in Claude Desktop. If skipped, run `make skills` later.

### 4. Mount Your Project

Start a Cowork session → **Add Folder** → select your project directory (which now contains `CLAUDE/`).

### 5. Verify

```
Summarize what you know about me from the CLAUDE folder.
```

Claude should reference your specific stack, domains, and writing rules. If not, check that the folder is mounted and Global Instructions are pasted.

---

## The `make init` Process

Template files inside `claudio-cowork/CLAUDE/` are never modified — all writes go to `project-root/CLAUDE/`.

### Step 1: Install Structure

Creates the `CLAUDE/` directory skeleton at your project root: `PROJECTS/`, `OUTPUTS/`, `TEMPLATES/`, and `PROMPT-TEMPLATE.md`. Configurable files (`about-me.md`, `anti-ai-writing-style.md`, `feedback.md`, `GLOBAL-INSTRUCTIONS.md`) are created in subsequent steps only if you configure them. Existing files are never overwritten.

### Step 2: Configure `about-me.md`

```
1. Context     → Auto-generate from project analysis (requires Claude CLI)
2. Customize   → Answer guided questions about your role, stack, and goals
3. Skip        → File not created; excluded from GLOBAL-INSTRUCTIONS.md
```

### Step 3: Configure `anti-ai-writing-style.md`

```
1. Use default → Copy the template as-is
2. Customize   → Set tone, banned phrases, domain conventions
3. Skip        → File not created; writing rules excluded from GLOBAL-INSTRUCTIONS.md
```

### Step 4: Configure `feedback.md`

```
1. Yes → Create feedback.md (correction log for the agent)
2. No  → File not created; feedback excluded from GLOBAL-INSTRUCTIONS.md
```

If Steps 2, 3, and 4 are all skipped/disabled, the `ABOUT-ME/` directory is not created.

### Step 5: Configure `GLOBAL-INSTRUCTIONS.md`

```
1. Use default → Generate standard control plane (accounts for skipped sections above)
2. Customize   → Set naming conventions, domain defaults, operating rules
3. Skip        → File not created
```

### Step 6: Finalize

If not skipped, the script outputs `GLOBAL-INSTRUCTIONS.md` between copy markers. The script lists which files were configured and which were skipped.

### Step 7: Install Skills

```
1. Yes → Package and install all skills from SKILLS/
2. No  → Skip (run make skills later)
```

### Step 8: Update `.gitignore`

Adds `claudio-cowork/` to project root `.gitignore`. Creates the file if needed. Idempotent.

### Step 9: Install Plugins

```
1. Yes → Install GSD + Superpowers (runs make plugins)
2. No  → Skip (run make plugins later)
```

### Step 10: Configure Instruction Files

```
1. Yes → Configure AGENTS.md and CLAUDE.md (each with its own flow)
2. No  → Skip (run make instructions later)
```

Two instruction files are configured in sequence:

**AGENTS.md** — cross-tool project context (build commands, test runners, conventions, boundaries). Used by any AI coding agent that supports the standard. Options: Context (auto-generate from project config files, requires Claude CLI) / Customize (guided Q&A) / Skip.

**CLAUDE.md** — Claude-specific behavior rules (think-before-coding, simplicity, surgical changes, goal-driven execution) and a dated mistake log. Options: Use default (copy the template with proven behavior rules) / Customize (tailor strictness, TDD preference, communication style) / Skip.

---

## Standalone Targets

Each configuration module can run independently, outside the full `make init` flow. Useful for reconfiguring a single section after initial setup.

| Command | What it does |
|---------|-------------|
| `make about-me` | Configure `about-me.md` (Context / Customize / Skip) |
| `make code-style` | Configure `anti-ai-writing-style.md` (Default / Customize / Skip) |
| `make feedback` | Configure `feedback.md` (Yes / No) |
| `make global-instructions` | Configure `GLOBAL-INSTRUCTIONS.md` — infers which ABOUT-ME/ files exist on disk |
| `make instructions` | Configure both `AGENTS.md` and `CLAUDE.md` |
| `make agents-md` | Configure `AGENTS.md` standalone (Context / Customize / Skip) |
| `make claude-md` | Configure `CLAUDE.md` standalone (Default / Customize / Skip) |

Standalone targets create the `CLAUDE/` skeleton if it doesn't exist and use the same prompts as `make init`. The `global-instructions` target automatically detects which files are present to generate correct references.

---

## Plugins Installation

```bash
make plugins
```

Installs the recommended agent stack independently of `make init`.

**What it installs:**
- **GSD** — project-level planning, task decomposition, wave-based parallel execution, cost tracking. Requires Node.js (`npx`).
- **Superpowers** — TDD enforcement, structured planning, dual-stage code review. Requires Claude CLI (`claude`).

**Idempotency:** GSD is detected by `.claude/gsd-manifest.json`. Superpowers is detected via `claude plugin list`. Already-installed plugins are skipped.

**Missing dependencies:** If `npx` or `claude` is unavailable, the command prints the manual install command instead of failing.

**After installation:** Restart Claude Code. GSD commands are available via `/gsd`. Superpowers skills activate automatically by context.

For how GSD and Superpowers interact during development, see [Agent Orchestration](README.md#agent-orchestration) in the README.

---

## Personalizing Your Profile

### `about-me.md`

| Section | What to Include | Example |
|---------|----------------|---------|
| Who I Am | Name, role, one-sentence description | "Alex — backend engineer at a Series B fintech" |
| What I Do Day-to-Day | 3-5 bullet points of actual daily work | "Build recommendation engine, maintain ETL pipelines" |
| Domains | Specialty areas | "NLP, time-series forecasting, payment systems" |
| Current Priorities | What you're focused on now (update monthly) | "Migrating from Airflow to Dagster" |
| Tech Stack | Be specific | "Python 3.12, FastAPI, PostgreSQL 16, Kubernetes" |
| Communication Style | How Claude should talk to you | "Terse. No hand-holding. Assume I know the stdlib." |
| What I Value in Output | Quality standards | "Type hints on everything. Tests alongside code." |

The more specific, the better. "Python 3.12, heavy numpy/pandas, some Cython for hot paths" beats "Python."

### `anti-ai-writing-style.md`

Two parts: a kill list (what Claude must never do) and positive rules (how Claude should write).

Customize the kill list by removing items that don't bother you and adding phrases you've noticed. Customize positive rules by adjusting for your domain — a designer might replace financial writing rules with design system conventions.

The test at the bottom is the quality gate. Replace the reference persona with your own: "Would a senior [your role] find this useful?"

---

## The Feedback Loop

`CLAUDE/ABOUT-ME/feedback.md` — one correction per line:

```markdown
- [2026-03-10] Initial setup. Add corrections here as they come up.
- [2026-03-15] Don't use f-strings for SQL queries. Use parameterized queries.
- [2026-03-22] Stop suggesting Redis for everything. Check if PostgreSQL is sufficient first.
```

**When to add entries:** Claude makes a repeated mistake, uses a pattern you dislike, misses a convention, or suggests a tool you don't want.

**Format:** `- [YYYY-MM-DD] correction`

Global Instructions tell Claude to read this file before every task. Over time it becomes a personalized fine-tuning layer.

---

## Prompt Template & Mac Shortcut

### The Template

```
I want to [TASK] to [SUCCESS CRITERIA]. First, explore my CLAUDE folder.
Then, ask me questions using the AskUserQuestion tool. I want to refine the
approach with you before you execute.
```

This forces Claude to: (1) load your context, (2) clarify before acting, (3) execute with full profile.

### Mac Text Replacement

1. **System Settings → Keyboard → Text Replacements**
2. **Replace:** `/prompt` → **With:** the full template text
3. Type `/prompt` + space in any text field to expand

You can create multiple shortcuts: `/prompt-backtest`, `/prompt-pipeline`, `/prompt-dashboard` — each pre-filled with domain-specific language.

---

## The Meta-Prompt Generator Skill

Transforms unstructured input into structured, contract-grade agent specifications.

### Trigger Phrases

Say any of: "turn this into a spec", "write an agent prompt for this", "spec this out for automation", "make this actionable", or drop in a codebase/doc and say "write instructions an AI can follow."

### What It Produces

A YAML+Markdown spec with: objective, scope, typed schemas, data contracts, numeric policy, numbered requirements, workflow steps, failure policy, observability, and acceptance tests. All verified by 9 quality checks.

### Installation

Installed automatically during `make init`. To reinstall or add new skills, run `make skills` from `claudio-cowork/`.

---

## Scheduled Output Audit

An optional automated task that reviews Claude's outputs against your standards.

### Create It

In any Cowork session:

```
Create a scheduled task called "weekly-output-audit" that runs every Friday at 1pm.
It should review all files in CLAUDE/OUTPUTS/ created this week, grade them against
my anti-ai-writing-style.md and Global Instructions, and produce an audit report
with specific violations and suggested feedback.md corrections.
```

### Manage It

| Action | Command |
|--------|---------|
| View tasks | "list my scheduled tasks" |
| Pause | "pause the weekly-output-audit task" |
| Reschedule | "change weekly-output-audit to Mondays at 9am" |
| Run now | "run the weekly-output-audit task now" |

---

## Adding Your Own Skills

1. Create a folder under `claudio-cowork/SKILLS/`:
   ```
   SKILLS/my-new-skill/
   ├── SKILL.md          ← Required
   └── references/       ← Optional
   ```

2. Write `SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: my-new-skill
   description: |
     Use this skill when the user says "generate API docs",
     "document this endpoint", or "write OpenAPI spec".
   ---
   ```

3. Run `make skills` to package and install.

Alternatively, ask Claude to create one using the skill-creator skill.

---

## Troubleshooting

**Claude doesn't reference my profile.** Check: (1) project folder mounted in current session, (2) `CLAUDE/` exists at project root, (3) Global Instructions pasted into Settings.

**Claude uses AI-speak despite writing rules.** Add the specific phrase to `feedback.md`. If it persists, check that `anti-ai-writing-style.md` has the phrase in the kill list.

**Skills don't trigger.** Re-run `make skills` and accept install prompts in Claude Desktop.

**Mac shortcut doesn't expand.** Check **System Settings → Keyboard → Text Replacements**. Press space after typing `/prompt`.

**`make init` hangs.** Run in a standard terminal (not piped or inside another Claude session). Check that `scripts/init.sh` is executable (`chmod +x scripts/init.sh`).

**`make init` doesn't find project context.** Ensure `claudio-cowork` is cloned inside your project (not alongside it). Claude looks at `../` for project files.

**Need to re-run setup.** `claudio-cowork/` stays on disk, git-ignored. Run `make init` again — existing files are preserved. To reconfigure a single section, use standalone targets: `make about-me`, `make code-style`, `make feedback`, `make global-instructions`, `make instructions`, `make agents-md`, or `make claude-md`.

**Plugins dependencies missing.** `make plugins` prints manual install commands if `npx` or `claude` is unavailable. Install the dependencies and re-run.

**AGENTS.md generated with wrong commands.** The Context mode infers commands from config files on disk. If your project uses non-standard commands or the generated output is inaccurate, edit `AGENTS.md` directly at project root. Lines marked `(verify)` were inferred with lower confidence. To regenerate from scratch, delete `AGENTS.md` at project root and run `make agents-md`.

**CLAUDE.md behavior rules not applied.** Ensure `CLAUDE.md` exists at project root and contains the `## Behavior` section. To regenerate, delete `CLAUDE.md` at project root and run `make claude-md`.
