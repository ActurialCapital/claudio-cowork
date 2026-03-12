# HOW-TO Guide

A complete walkthrough for setting up, customizing, and extending the claudio-cowork system.

---

## Table of Contents

1. [How It Works End-to-End](#how-it-works-end-to-end)
2. [Prerequisites](#prerequisites)
3. [Initial Setup](#initial-setup)
4. [The `make init` Process](#the-make-init-process)
5. [Configuring Cowork Settings](#configuring-cowork-settings)
6. [Personalizing Your Profile](#personalizing-your-profile)
7. [Configuring Global Instructions](#configuring-global-instructions)
8. [Setting Up the Prompt Template and Mac Shortcut](#setting-up-the-prompt-template-and-mac-shortcut)
9. [The Meta-Prompt Generator Skill](#the-meta-prompt-generator-skill)
10. [The Feedback Loop](#the-feedback-loop)
11. [Scheduled Output Audit](#scheduled-output-audit)
12. [Adding Your Own Skills](#adding-your-own-skills)
13. [Folder Architecture Deep Dive](#folder-architecture-deep-dive)
14. [Troubleshooting](#troubleshooting)

---

## How It Works End-to-End

This section walks through what happens from cloning the repo to receiving finished deliverables.

### Setup Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  1. CLONE INSIDE YOUR PROJECT                                    │
│     cd your-project/                                             │
│     git clone <repo-url> claudio-cowork                          │
│     cd claudio-cowork                                            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  2. RUN make init                                                │
│     Step-by-step setup (each offers: 1. Default  2. Customize):  │
│       → about-me.md         (project analysis or your answers)   │
│       → anti-ai-writing-style.md   (accept or customize rules)   │
│       → GLOBAL-INSTRUCTIONS.md     (accept or customize config)  │
│       → Outputs final Global Instructions for copy/paste         │
│     Then:                                                        │
│       → Copies CLAUDE/ to your project root                      │
│       → Asks whether to install skills (1. Yes / 2. No)          │
│       → Adds claudio-cowork/ to .gitignore                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  3. PASTE GLOBAL INSTRUCTIONS                                    │
│     Settings → Cowork → Edit Global Instructions                 │
│     Paste the output from make init                              │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  4. MOUNT YOUR PROJECT                                           │
│     Start Cowork session → Add Folder → select your project      │
│     CLAUDE/ is now at your project root                          │
└─────────────────────────────────────────────────────────────────┘
```

### The Session Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│  1. SESSION START                                                │
│     You open Cowork → Add Folder → select your project           │
│     Claude sees the folder structure but hasn't read anything    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  2. BOOT SEQUENCE (triggered by Global Instructions)             │
│     Claude reads:                                                │
│       → about-me.md         (who you are, your stack)            │
│       → anti-ai-writing-style.md  (how to write for you)         │
│       → feedback.md         (accumulated corrections)            │
│     Result: Claude has your full profile loaded in memory        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  3. YOU SEND A PROMPT                                            │
│     Example (using /prompt shortcut):                            │
│     "I want to build a funding rate arb strategy across BTC      │
│      perps on Binance and Bybit. First, explore my CLAUDE        │
│      folder. Then, ask me questions..."                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  4. CONTEXT LOADING                                              │
│     Claude checks CLAUDE/PROJECTS/ for project context           │
│     Claude checks installed skills for matching pattern           │
│     If meta-prompt-generator matches → loads SKILL.md            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  5. CLARIFICATION (AskUserQuestion)                              │
│     Claude surfaces ambiguities as structured multiple-choice    │
│     questions instead of guessing. You refine the approach       │
│     before any code is written.                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  6. EXECUTION                                                    │
│     Claude writes code/docs/specs following:                     │
│       → Your communication style (from about-me.md)              │
│       → Your writing rules (from anti-ai-writing-style.md)       │
│       → Domain defaults (from Global Instructions)               │
│       → All corrections (from feedback.md)                       │
│     Output saved to CLAUDE/OUTPUTS/ with naming convention       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  7. POST-SESSION                                                 │
│     If Claude made a mistake → add correction to feedback.md     │
│     If output quality was off → add style note to feedback.md    │
│     Weekly audit (optional) → automated review of all outputs    │
└─────────────────────────────────────────────────────────────────┘
```

### What Makes This Different from Vanilla Cowork

Without this system, every session is a blank slate. Claude doesn't know your stack, doesn't know you hate "Let me break this down," doesn't know you need Sharpe ratios on every backtest, and doesn't remember that last week you told it to stop using f-strings for SQL.

With this system, Claude starts every session already knowing all of that. The prompt template forces a clarification step before execution. The feedback log means corrections compound across sessions. The scheduled audit catches drift before you do.

### The Meta-Prompt Generator: End-to-End

When you trigger the meta-prompt-generator skill, a more specific pipeline runs inside step 6:

```
Input (idea / code / docs)
    │
    ▼
┌─────────────────────────┐
│ 1. CLASSIFY INPUT       │  Raw idea? Codebase? API docs?
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ 2. EXTRACTION PROTOCOL  │  Pull out: objective, scope, inputs,
│                         │  outputs, grounding, constraints,
│                         │  unresolved decisions
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ 3. RESOLVE AMBIGUITIES  │  AskUserQuestion for each decision
│                         │  point (target weight method? valuation
│                         │  currency? auth pattern?)
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ 4. GENERATE YAML        │  Single source of truth:
│    FRONTMATTER          │  scope, grounding, data_contracts,
│                         │  numeric_policy, runtime_config,
│                         │  requirements (FR/NFR with IDs),
│                         │  workflow steps, failure_policy,
│                         │  observability, acceptance_tests
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ 5. GENERATE MARKDOWN    │  Three sections only:
│    BODY                 │  - Examples (realistic data)
│                         │  - Anti-patterns (task-specific)
│                         │  - Implementation guidance (non-normative)
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ 6. QUALITY CHECKS (×9)  │  Completeness, determinism, testability,
│                         │  no duplication, layer separation,
│                         │  grounding, no orphaned steps,
│                         │  constants configurable, formulas correct
└────────────┬────────────┘
             ▼
         spec.md
    (agent-executable)
```

The output spec is designed so that any autonomous agent (Claude, GPT, a custom framework) can execute it without additional clarification. The YAML frontmatter is also convertible to XML schema using the mapping in `references/yaml-to-xml-mapping.md`.

---

## Prerequisites

You need Claude Desktop with Cowork mode enabled. Cowork is available on macOS and is currently in research preview. You also need an existing project (or at least a directory) where claudio-cowork will be cloned into.

---

## Initial Setup

### Step 1: Clone Inside Your Project

Navigate to your existing project directory and clone claudio-cowork inside it:

```bash
cd /path/to/your-project
git clone https://github.com/<your-username>/claudio-cowork.git
cd claudio-cowork
```

Your directory structure before init:

```
your-project/
├── your existing files (package.json, src/, etc.)
└── claudio-cowork/
    ├── Makefile
    ├── CLAUDE/
    ├── SKILLS/
    ├── scripts/
    │   └── init.sh
    └── ...
```

### Step 2: Run `make init`

```bash
make init
```

This launches the full setup sequence. First, `make init` copies the `CLAUDE/` template directory to your project root (templates inside `claudio-cowork/` are never modified). Then each configuration step presents a choice:

```
1. Use default
2. Customize
```

Select **1** to accept the default and move on, or **2** to enter a guided customization flow where you answer targeted questions. All changes are written to `project-root/CLAUDE/`. Once configuration completes, `make init`:

1. Asks whether to install skills (**1. Yes** / **2. No**). If yes, packages and installs all skills from `SKILLS/` (runs `make skills`). If no, skips — you can always run `make skills` later.
2. Adds `claudio-cowork/` to the project root `.gitignore` (creating the file if it does not exist)

After `make init`, your project looks like this:

```
your-project/
├── .gitignore                            ← claudio-cowork/ entry added
├── your existing files (package.json, src/, etc.)
├── claudio-cowork/                       ← Stays local, git-ignored
└── CLAUDE/                               ← Installed by make init
    ├── ABOUT-ME/
    ├── PROJECTS/
    ├── OUTPUTS/
    ├── GLOBAL-INSTRUCTIONS.md
    └── PROMPT-TEMPLATE.md
```

The `claudio-cowork/` directory remains on disk but is git-ignored — it is never committed to your repository.

See [The `make init` Process](#the-make-init-process) for the full step-by-step breakdown.

### Step 3: Paste Global Instructions

During `make init`, Claude outputs the final `GLOBAL-INSTRUCTIONS.md` content in the terminal. Copy it and paste into **Settings → Cowork → Edit Global Instructions** in Claude Desktop.

### Step 4: Accept Skill Installs

During `make init`, you are asked whether to install skills. If you select **1 (Yes)**, skills are packaged and opened for install — accept the install prompts in Claude Desktop for each skill. If you skipped, you can run `make skills` later from the `claudio-cowork/` directory.

### Step 5: Mount Your Project

Start a new Cowork session and click **Add Folder** → select your project directory (which now contains `CLAUDE/`). Claude will automatically detect the folder structure and follow the Global Instructions protocol.

### Step 6: Verify

Start a new Cowork session and type:

```
Summarize what you know about me from the CLAUDE folder.
```

Claude should read your `about-me.md`, `anti-ai-writing-style.md`, and `feedback.md`, then give you a summary that reflects your profile. If it doesn't reference your specific stack, domains, or writing rules, check that the folder was mounted correctly.

---

## The `make init` Process

`make init` orchestrates a complete setup sequence. Template files inside `claudio-cowork/CLAUDE/` are never modified — all configuration writes go to `project-root/CLAUDE/`.

### Step 1: Install Templates into Project Root

The `CLAUDE/` template directory is copied from `claudio-cowork/` to your project root. If `CLAUDE/` already exists at the project root, files are merged without overwriting existing files. This happens before any configuration so that all subsequent writes target the project-root copy.

### Step 2: Configure `about-me.md`

This step uses a different prompt from the other steps:

```
1. Context        → Claude analyzes the project root (repo structure, configs,
                    README, codebase signals) and generates about-me.md
                    automatically. Requires the Claude CLI.
2. Customize      → Guided questions: what you're building, who you are,
                    daily work, domains, goals, stack, communication style,
                    intended outcomes, and output values.
                    Generates a profile from your answers.
```

### Step 3: Configure `anti-ai-writing-style.md`

Writing rules for tone, banned phrases, and domain conventions.

```
1. Use default    → Keeps the template as-is.
2. Customize      → Asks: preferred tone, phrases to ban, domain-specific
                    writing conventions, and additional rules.
                    Appends your customizations to the project-root copy.
```

### Step 4: Configure `GLOBAL-INSTRUCTIONS.md`

Boot sequence, folder protocol, naming conventions, and operating rules.

```
1. Use default    → Keeps the template as-is.
2. Customize      → Asks: naming convention, domain-specific defaults,
                    and additional operating rules.
                    Appends your customizations to the project-root copy.
```

### Step 5: Finalize Global Instructions

The script outputs the final `GLOBAL-INSTRUCTIONS.md` content between clearly marked copy lines. Copy everything between the markers and paste it into **Settings → Cowork → Edit Global Instructions**.

After this step the script exits and `make init` continues automatically with the remaining steps.

### Step 6: Install Skills (Optional)

You are prompted to install skills:

```
1. Yes
2. No
```

Select **1** to package and install all skills from `SKILLS/` as `.skill` files, opened for install in Claude Desktop. Accept the install prompts for each skill. Select **2** to skip — you can always run `make skills` later.

### Step 7: Add `claudio-cowork/` to `.gitignore`

The `claudio-cowork/` entry is added to the project root `.gitignore`. If `.gitignore` does not exist, it is created automatically. If the entry already exists, this step is a no-op.

The directory is not deleted. It stays on disk for future reference (re-running `make skills`, checking documentation, etc.) but is never committed to your repository.

---

## Configuring Cowork Settings

Cowork has a settings panel where you configure Global Instructions, manage connectors, and control Claude's behavior. This section walks through every relevant setting.

### Accessing Settings

Open Claude Desktop and click the **gear icon** (Settings) in the bottom-left corner. Navigate to the **Cowork** section in the sidebar.

### Global Instructions

This is the most important setting. Global Instructions are injected into every Cowork session before Claude processes your first message. They act as a persistent system prompt.

**To configure:**
1. Run `make init` (which generates and outputs the instructions) OR open `CLAUDE/GLOBAL-INSTRUCTIONS.md` manually
2. In Settings, find **Cowork → Edit Global Instructions**
3. Paste everything below the dotted line into the text area
4. Click **Save**

These instructions tell Claude to read your `CLAUDE/ABOUT-ME/` folder before every task, follow your writing rules, use the folder protocol, and apply your domain defaults. Without this step, the folder structure has no effect — Claude won't know to read it.

**When to update:** Any time you change `CLAUDE/GLOBAL-INSTRUCTIONS.md` in your project (adding new domain defaults, changing naming conventions, updating folder paths), re-paste the content into this settings field. The file in your project is the canonical version; the settings field is the deployed version.

### Connectors

Connectors link Claude to external services (Gmail, Google Calendar, Slack, GitHub, etc.). They appear in **Settings → Connectors** or are prompted during sessions when Claude detects a relevant tool.

Connectors relevant to this system:
- **Gmail** — if you want Claude to draft emails based on your writing style
- **Google Calendar** — for scheduling-aware tasks
- **GitHub** — for code review and PR workflows that follow your conventions

Each connector requires OAuth authentication. Claude will prompt you to connect when a task requires it.

### Plugins

Plugins are bundles of skills, connectors, and tools that extend Cowork's capabilities. They appear in **Settings → Plugins**. The meta-prompt-generator skill in this repo is a standalone skill (not a plugin), but you can package it as a plugin if you want to distribute it.

### Folder Access

When you start a Cowork session, you select folders via **Add Folder** on the session start screen. Cowork remembers previously selected folders but you can change them per session. After running `make init`, mount your project directory — it now contains `CLAUDE/` at the root with your profile, projects, and outputs.

### Scheduled Tasks

Scheduled tasks run automatically on a cron schedule. They're configured via the Cowork interface or by asking Claude to create one. See [Scheduled Output Audit](#scheduled-output-audit) for the specific audit task included in this system.

To view and manage scheduled tasks: ask Claude "list my scheduled tasks" in any Cowork session, or check the scheduled tasks panel in Settings.

---

## Personalizing Your Profile

After running `make init`, your `about-me.md` will already be populated. You can further refine it at any time.

### `CLAUDE/ABOUT-ME/about-me.md`

**Sections to customize:**

| Section | What to Include | Example |
|---------|----------------|---------|
| Who I Am | Name, role, one-sentence description | "Alex — backend engineer and data scientist at a Series B fintech" |
| What I Do Day-to-Day | 3-5 bullet points of your actual daily work | "Build recommendation engine, maintain ETL pipelines, review PRs" |
| Domains | Your specialty areas | "NLP, time-series forecasting, payment systems" |
| Current Priorities | What you're focused on right now (update monthly) | "Migrating from Airflow to Dagster, launching v2 API" |
| Tech Stack | Languages, frameworks, databases, infra — be specific | "Python 3.12, FastAPI, PostgreSQL 16, Kubernetes, Terraform" |
| Communication Style | How you want Claude to talk to you | "Terse. No hand-holding. Assume I know the stdlib." |
| What I Value in Output | Quality standards for deliverables | "Type hints on everything. Tests alongside code. No TODO comments." |

The more specific you are, the better Claude calibrates. Saying "Python" is less useful than "Python 3.12, heavy numpy/pandas, some Cython for hot paths." Saying "ML" is less useful than "gradient boosted trees for tabular data, PyTorch for sequence models, no deep learning hype."

### `CLAUDE/ABOUT-ME/anti-ai-writing-style.md`

This file has two parts: a kill list (what Claude must never do) and positive rules (how Claude should write instead).

**Customizing the kill list:** Review each category (filler phrases, meta-explanatory phrases, engagement loops, closure templates, reassurance language, corporate buzzwords). Remove items that don't bother you. Add phrases you've noticed Claude using that you dislike.

**Customizing positive rules:** The template includes rules for tone (neutral, analytic), structure (lead with the answer), technical writing (domain vocabulary, runnable code), financial writing (risk metrics, standard notation), and math (LaTeX over prose). Adjust these to your domain. A designer might replace the financial writing section with design system conventions. A lawyer might add citation format rules.

**The test at the bottom** is the quality gate. Replace the reference persona with your own: "Would a senior [your role] find this useful, or would they skim past it?"

---

## Configuring Global Instructions

Global Instructions are the control plane. They tell Claude what to read, where to write, and what rules to follow before every task. `make init` handles the initial configuration, but you can edit them at any time.

### Key Sections

**BEFORE EVERY TASK** — This is the boot sequence. Claude reads all files in `CLAUDE/ABOUT-ME/` (including `feedback.md`), checks for relevant project context, and loads applicable skills. Never remove the instruction to read `feedback.md` — that's how corrections accumulate.

**FOLDER PROTOCOL** — Defines read-only folders and one write folder. Adjust the folder names if your structure differs:

```
Read-only — never create, edit, or delete anything here:
  CLAUDE/ABOUT-ME/     → Identity and preferences
  CLAUDE/PROJECTS/     → Project-specific context

Write:
  CLAUDE/OUTPUTS/      → Everything Claude creates goes here
```

**NAMING CONVENTION** — The default format is `project_content-type_v1.ext`. Content types include: analysis, model, pipeline, report, spec, script, notebook, doc. Modify these to match your domain.

**OPERATING RULES** — Domain-specific rules that apply unless overridden. The template includes sensible defaults for code quality, data pipelines, and technical writing. Replace or extend with your domain's conventions.

### Updating Global Instructions

When you change `CLAUDE/GLOBAL-INSTRUCTIONS.md` in your project, you also need to re-paste it into **Settings → Cowork → Edit Global Instructions**. The file in your project is the canonical version; the Cowork settings are the deployed version.

---

## Setting Up the Prompt Template and Mac Shortcut

### The Template

The core prompt template is deliberately simple:

```
I want to [TASK] to [SUCCESS CRITERIA]. First, explore my CLAUDE folder.
Then, ask me questions using the AskUserQuestion tool. I want to refine the
approach with you before you execute.
```

This does three things: (1) states the task and success criteria, (2) forces Claude to read your context folder before acting, and (3) makes Claude ask clarifying questions instead of guessing. The result is that Claude works with your full profile loaded and confirms its understanding before writing code.

### Setting Up the Mac Text Shortcut

macOS has a built-in text replacement feature that works system-wide.

1. Open **System Settings** (or System Preferences on older macOS)
2. Go to **Keyboard → Text Replacements** (or search "Text Replacement" in the search bar)
3. Click the **+** button in the bottom-left corner
4. In the **Replace** field, type: `/prompt`
5. In the **With** field, paste the full template text:
   ```
   I want to [TASK] to [SUCCESS CRITERIA]. First, explore my CLAUDE folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
   ```
6. Click **Add** or press Enter

Now, anywhere on your Mac — in the Claude Desktop chat, in Notes, in any text field — typing `/prompt` followed by a space expands to the full template. Replace `[TASK]` and `[SUCCESS CRITERIA]` with your specifics and send.

**Tips:**
- The shortcut works in Claude Desktop's chat input field
- You can create multiple shortcuts: `/prompt-backtest`, `/prompt-pipeline`, `/prompt-dashboard` — each pre-filled with domain-specific task language
- If the shortcut doesn't expand, check that text replacement is enabled in **System Settings → Keyboard → Text Input → Text Replacements**

---

## The Meta-Prompt Generator Skill

This is a custom Cowork skill — a reusable set of instructions that Claude loads when triggered by specific phrases. It transforms unstructured input into structured, contract-grade agent specifications.

### What It Does

You give it one of three input types:
- A **raw idea** ("I want a service that monitors portfolio positions and sends Slack alerts")
- A **codebase** ("Here's my Backtester class; extend it with walk-forward optimization")
- **API documentation** ("Here are Binance WebSocket docs; build a real-time order book aggregator")

It produces a YAML+Markdown specification with: objective, scope/out-of-scope, grounding (facts vs. assumptions), typed input/output schemas, data contracts, numeric policy, runtime config, numbered requirements, workflow steps with dependencies, failure policy with severity taxonomy, observability rules, and acceptance tests.

### How to Install the Skill

**Automatic (via `make init`).** Skills are automatically packaged and installed during `make init`. Claude Desktop will show an install prompt for each skill — accept it. Once installed, skills auto-trigger by phrase matching in every future session.

**Manual (if needed later).** The `claudio-cowork/` directory stays on disk (git-ignored). Navigate into it and run `make skills` to package and install new or updated skills.

**What gets installed:** Only `SKILL.md` and `references/` are included in the `.skill` package. The `evals/` folder is excluded — it's for testing and improving the skill, not for runtime use.

### How to Trigger It

**If installed as a skill (Option A),** say any of the following (or similar):

- "Turn this into a spec"
- "Write an agent prompt for this"
- "Create an agent prompt from this code"
- "Spec this out for automation"
- "Make this executable by an agent"

Or drop in a codebase, doc, or braindump and say:

- "Make this actionable"
- "Productionize this"
- "Write instructions an AI can follow"

Skills are installed automatically during `make init`, so manual triggering is typically not needed.

### How It Works Internally

**Step 1 — Input classification.** The skill identifies the input type: raw idea, codebase, or documentation. Each gets different treatment.

**Step 2 — Extraction protocol.** From the input, it extracts 8 categories: objective, scope, out-of-scope, inputs, outputs, grounding, constraints, and unresolved decisions. Ambiguities are surfaced via `AskUserQuestion`.

**Step 3 — YAML frontmatter generation.** The single source of truth for all machine-readable rules. Every rule appears exactly once here.

**Step 4 — Markdown body.** Three sections only: concrete examples with realistic data, anti-patterns specific to the task, and implementation guidance labeled non-normative.

**Step 5 — Quality checks (9 total).**

| Check | What It Verifies |
|-------|-----------------|
| Completeness | Could an agent with zero context execute this? |
| Determinism | Same inputs → same outputs? |
| Testability | Every acceptance test has concrete input/expected output; math verified step-by-step |
| No duplication | Every rule stated exactly once in YAML |
| Layer separation | Requirements, guidance, and examples in distinct sections |
| Grounding | Every claim labeled as fact (with source) or assumption |
| No orphaned steps | Every workflow step's output is consumed downstream |
| Constants configurable | No magic numbers; everything in `runtime_config` |
| Formulas correct | All math verified against standard definitions |

### The Spec Output Format

The generated spec follows a YAML+Markdown hybrid structure:

```
---
(YAML frontmatter — all rules, schemas, workflows, tests)
---

# Title

## Examples
(Concrete input→output scenarios with realistic data)

## Anti-Patterns
(Task-specific failure modes)

## Implementation Guidance (Non-Normative)
(Suggested approaches — agent may deviate)
```

The YAML is designed for programmatic conversion to XML schema. See `references/yaml-to-xml-mapping.md` for the mapping rules and `references/output-format-rationale.md` for the full analysis of why YAML+Markdown was chosen over XML, structured Markdown, and flexible formats — including pipeline stability analysis, a comparison matrix, and the recommended hybrid architecture for human-in-the-loop workflows.

### Evaluating and Improving the Skill

The `evals/evals.json` file contains three test cases covering all three input types (raw idea, codebase, documentation). To evaluate the skill:

1. Run each test case with and without the skill loaded
2. Grade the output against the expected assertions
3. If issues are found, update `SKILL.md` and re-run

The skill went through two iteration cycles with detailed human evaluation feedback before reaching v2.1.

---

## The Feedback Loop

`CLAUDE/ABOUT-ME/feedback.md` is the simplest and most powerful component. It's a plain text file with one correction per line:

```markdown
- [2026-03-10] Initial setup. Add corrections here as they come up.
- [2026-03-15] Don't use f-strings for SQL queries. Use parameterized queries.
- [2026-03-18] When showing backtest results, always include the benchmark comparison.
- [2026-03-22] Stop suggesting Redis for everything. Check if PostgreSQL is sufficient first.
```

Global Instructions tell Claude to read this file before every task and apply corrections as overrides. Over time, this file becomes a personalized fine-tuning layer that accumulates your preferences without requiring any changes to prompts or instructions.

**When to add entries:**
- Claude makes a mistake you've seen before
- Claude uses a pattern you dislike
- Claude misses a convention specific to your codebase
- Claude suggests a tool/library you don't want to use

**Format:** `- [YYYY-MM-DD] correction` — one line, plain language.

---

## Scheduled Output Audit

The system includes an optional scheduled task that automatically reviews Claude's outputs against your writing rules and domain standards. It runs on a recurring schedule without manual intervention.

### What It Does

The `weekly-output-audit` task:
1. Opens a new Cowork session at the scheduled time
2. Reads your `CLAUDE/ABOUT-ME/` folder (profile, writing rules, feedback log)
3. Scans the `CLAUDE/OUTPUTS/` folder for files created since the last audit
4. Grades each file against your `anti-ai-writing-style.md` rules
5. Checks domain-specific requirements (risk metrics in financial outputs, type hints in code, etc.)
6. Produces an audit report with specific violations, quality scores, and suggested corrections
7. Lists corrections that should be added to `feedback.md`

### Why It Matters

Without automated review, style drift accumulates silently. Claude may start slipping in filler phrases, skipping risk metrics, or using patterns you've already corrected. The audit catches these before they become habits.

### How to Create It

In any Cowork session, ask Claude:

```
Create a scheduled task called "weekly-output-audit" that runs every Friday at 1pm.
It should review all files in CLAUDE/OUTPUTS/ created this week, grade them against
my anti-ai-writing-style.md and Global Instructions, and produce an audit report
with specific violations and suggested feedback.md corrections.
```

Claude will use the scheduled task system to create a task with:
- **Task ID:** `weekly-output-audit`
- **Schedule:** `0 13 * * 5` (Fridays at 1:00 PM local time)
- **Prompt:** The full audit instructions

The task is stored in `~/Documents/Claude/Scheduled/weekly-output-audit/SKILL.md` and executes in its own Cowork session at the scheduled time.

### Managing the Task

| Action | How |
|--------|-----|
| View all tasks | Ask Claude: "list my scheduled tasks" |
| Pause the audit | Ask Claude: "pause the weekly-output-audit task" |
| Change the schedule | Ask Claude: "change weekly-output-audit to run Mondays at 9am" |
| Update the prompt | Ask Claude: "update the weekly-output-audit prompt to also check for..." |
| Run manually | Ask Claude: "run the weekly-output-audit task now" |

### Customizing the Audit

The audit task's prompt is fully customizable. Common modifications:

- **Change frequency:** Daily for high-output periods, biweekly for slower ones
- **Add domain checks:** "Verify all Python files have type hints and docstrings"
- **Add format checks:** "Verify all markdown files have proper heading hierarchy"
- **Change output format:** "Produce the audit as a markdown checklist" or "Send results to my email via Gmail connector"
- **Scope by project:** "Only audit files in the `trading-strategies/` subfolder"

### Example Audit Output

```markdown
# Weekly Output Audit — 2026-03-14

## Files Reviewed: 6

### momentum_backtest_v1.py ✓
- Writing style: PASS
- Domain requirements: PASS (Sharpe, max drawdown, Sortino present)
- Code quality: PASS (type hints, docstrings, error handling)

### portfolio_risk_dashboard_v1.html ⚠
- Writing style: 1 violation
  → Line 42: "Here's a breakdown of your portfolio" (meta-explanatory phrase)
- Domain requirements: PASS
- Suggested feedback.md entry:
  `- [2026-03-14] Don't use "here's a breakdown" in dashboard labels. Use direct labels.`

### macro_regime_analysis_v1.md ⚠
- Writing style: 2 violations
  → Para 3: "Interestingly, the model shows..." (filler)
  → Para 7: "In summary, ..." (closure template)
- Domain requirements: MISSING benchmark comparison
- Suggested feedback.md entries:
  `- [2026-03-14] Always include benchmark comparison in regime analysis outputs.`

## Summary
- 4/6 files passed all checks
- 3 style violations across 2 files
- 1 missing domain requirement
- 3 suggested feedback.md entries
```

---

## Adding Your Own Skills

Skills are folders containing a `SKILL.md` file with instructions that Claude loads when triggered. The `claudio-cowork/` directory remains on disk after `make init` (git-ignored), so you can add new skills directly to `SKILLS/` and re-run `make skills`.

**Option A — Add to `SKILLS/` and re-run `make skills`:**

1. Create a folder under `claudio-cowork/SKILLS/`:
   ```
   claudio-cowork/SKILLS/
   └── my-new-skill/
       ├── SKILL.md          ← Required: instructions
       └── references/       ← Optional: reference docs
   ```

2. Write the `SKILL.md` with YAML frontmatter (name, description, trigger phrases) and markdown body (instructions). The description field controls when the skill triggers — be specific:
   ```yaml
   ---
   name: my-new-skill
   description: |
     Use this skill when the user says "generate API docs",
     "document this endpoint", or "write OpenAPI spec".
   ---
   ```

3. Run `make skills` from `claudio-cowork/` to package and install the new skill.

**Option B — Use the skill-creator skill:** In any Cowork session, ask Claude to create a new skill. The skill-creator skill guides you through the process.

Test the skill by asking Claude to perform the task in a Cowork session with your project folder mounted.

---

## Folder Architecture Deep Dive

The system uses a strict read/write separation to prevent Claude from accidentally modifying your context files.

### Read-Only Folders

| Folder | Purpose | Contents |
|--------|---------|----------|
| `CLAUDE/ABOUT-ME/` | Identity and preferences | Profile, writing rules, correction log |
| `CLAUDE/PROJECTS/` | Project-specific context | Briefs, datasets, reference code |

After `make init`, these live at your project root inside `CLAUDE/`. Claude reads from these folders to build context. It never creates, edits, or deletes files here (enforced by Global Instructions). Skills are installed separately in Claude Desktop and trigger automatically by phrase matching.

### Write Folder

| Folder | Purpose | Contents |
|--------|---------|----------|
| `CLAUDE/OUTPUTS/` | Deliverables | Everything Claude creates, organized by project |

Claude writes all outputs here, using the naming convention defined in Global Instructions (`project_content-type_v1.ext`). It creates project subfolders as needed.

### Why This Separation Matters

Without explicit folder protocols, Claude may write outputs alongside your context files, overwrite templates, or create files in unexpected locations. The read/write separation makes Claude's behavior predictable: context flows in from the left (read folders), work product flows out to the right (write folder).

---

## Troubleshooting

**Claude doesn't reference my profile.** Verify your project folder is mounted in the current session (check the session start screen) and that it contains `CLAUDE/` at the root. Global Instructions must also be pasted into Settings — the `CLAUDE/GLOBAL-INSTRUCTIONS.md` file is not automatically loaded.

**Claude uses AI-speak despite the writing rules.** Add the specific phrase to `feedback.md` with the date. This creates an explicit override. If a pattern persists across sessions, check that `anti-ai-writing-style.md` has the phrase in the kill list and that Global Instructions include the line "Follow every rule in `anti-ai-writing-style.md` for all outputs."

**The meta-prompt skill doesn't trigger.** Skills are installed automatically during `make init`. If a skill isn't triggering, check that you accepted the install prompt in Claude Desktop. You can reinstall by navigating to `claudio-cowork/` and running `make skills`.

**Mac text shortcut doesn't expand.** Check **System Settings → Keyboard → Text Input → Text Replacements**. The shortcut must be listed there. Some apps (particularly Electron-based) may delay expansion — press space or return after typing `/prompt` to trigger it.

**Claude writes to the wrong folder.** Check that Global Instructions specify the correct write folder path. The instructions must match the actual `CLAUDE/OUTPUTS/` folder in your project.

**`make init` doesn't find my project context.** Make sure you cloned `claudio-cowork` inside your project directory (not alongside it). Claude looks at the parent directory (`../`) for project files. If your project has an unusual structure, you can always answer Claude's questions manually during the init process.

**`make init` hangs or doesn't accept input.** The init script reads input from stdin. Make sure you're running `make init` in a standard terminal (not piped, not inside another Claude session). If the script hangs after printing "Configuration complete," check that `scripts/init.sh` is executable (`chmod +x scripts/init.sh`).

**Need to re-run setup.** `claudio-cowork/` is not deleted — it stays on disk, git-ignored. Navigate into it and run `make init` again. If `CLAUDE/` already exists at the project root, existing files are preserved during the copy.
