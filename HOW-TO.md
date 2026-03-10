# HOW-TO Guide

A complete walkthrough for setting up, customizing, and extending the claudio-cowork system.

---

## Table of Contents

1. [How It Works End-to-End](#how-it-works-end-to-end)
2. [Prerequisites](#prerequisites)
3. [Initial Setup](#initial-setup)
4. [Configuring Cowork Settings](#configuring-cowork-settings)
5. [Personalizing Your Profile](#personalizing-your-profile)
6. [Configuring Global Instructions](#configuring-global-instructions)
7. [Setting Up the Prompt Template and Mac Shortcut](#setting-up-the-prompt-template-and-mac-shortcut)
8. [The Meta-Prompt Generator Skill](#the-meta-prompt-generator-skill)
9. [The Feedback Loop](#the-feedback-loop)
10. [Scheduled Output Audit](#scheduled-output-audit)
11. [Adding Your Own Skills](#adding-your-own-skills)
12. [Folder Architecture Deep Dive](#folder-architecture-deep-dive)
13. [Troubleshooting](#troubleshooting)

---

## How It Works End-to-End

This section walks through what happens from the moment you open Claude Cowork to the moment you receive a finished deliverable.

### The Session Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│  1. SESSION START                                               │
│     You open Cowork → Add Folder → select claudio-cowork/       │
│     Claude sees the folder structure but hasn't read anything   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  2. BOOT SEQUENCE (triggered by Global Instructions)            │
│     Claude reads:                                               │
│       → about-me.md         (who you are, your stack)           │
│       → anti-ai-writing-style.md  (how to write for you)        │
│       → feedback.md         (accumulated corrections)           │
│     Result: Claude has your full profile loaded in memory       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  3. YOU SEND A PROMPT                                           │
│     Example (using /prompt shortcut):                           │
│     "I want to build a funding rate arb strategy across BTC     │
│      perps on Binance and Bybit. First, explore my CLAUDE       │
│      COWORK folder. Then, ask me questions..."                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  4. CONTEXT LOADING                                             │
│     Claude checks PROJECTS/ for relevant project context        │
│     Claude checks TEMPLATES/ for matching skill or pattern      │
│     If meta-prompt-generator matches → loads SKILL.md           │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  5. CLARIFICATION (AskUserQuestion)                             │
│     Claude surfaces ambiguities as structured multiple-choice   │
│     questions instead of guessing. You refine the approach      │
│     before any code is written.                                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  6. EXECUTION                                                   │
│     Claude writes code/docs/specs following:                    │
│       → Your communication style (from about-me.md)             │
│       → Your writing rules (from anti-ai-writing-style.md)      │
│       → Domain defaults (from Global Instructions)              │
│       → All corrections (from feedback.md)                      │
│     Output saved to CLAUDE OUTPUTS/ with naming convention      │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  7. POST-SESSION                                                │
│     If Claude made a mistake → add correction to feedback.md    │
│     If output quality was off → add style note to feedback.md   │
│     Weekly audit (optional) → automated review of all outputs   │
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

You need Claude Desktop with Cowork mode enabled. Cowork is available on macOS and is currently in research preview. You also need a folder on your filesystem where this repo will live — Claude Cowork reads from and writes to this folder during sessions.

---

## Initial Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/<your-username>/claudio-cowork.git
cd claudio-cowork
```

### Step 2: Add Two Folders to Cowork

Cowork supports multiple folders. You need to create one additional folder on your machine before starting:

```
CLAUDE OUTPUTS/
```

This is the write folder where Claude delivers finished work. Create it anywhere convenient (e.g., next to the cloned repo, or inside it if you prefer a single root). The `claudio-cowork/` repo itself is the read folder.

When you start a new Cowork session, click **Add Folder** in the session start screen and select both:
1. The `claudio-cowork/` directory (read context)
2. The `CLAUDE OUTPUTS/` directory (write target)

Claude will automatically detect the folder structure and follow the Global Instructions protocol.

### Step 3: Paste Global Instructions

Open Claude Desktop, go to **Settings → Cowork → Edit Global Instructions**, and paste everything from `GLOBAL-INSTRUCTIONS.md` below the dotted line. This tells Claude how to use the folder system for every session going forward.

### Step 4: Verify

Start a new Cowork session and type:

```
Summarize what you know about me from the CLAUDE COWORK folder.
```

Claude should read your `about-me.md`, `anti-ai-writing-style.md`, and `feedback.md`, then give you a summary that reflects your profile. If it doesn't reference your specific stack, domains, or writing rules, check that the folder was mounted correctly.

---

## Configuring Cowork Settings

Cowork has a settings panel where you configure Global Instructions, manage connectors, and control Claude's behavior. This section walks through every relevant setting.

### Accessing Settings

Open Claude Desktop and click the **gear icon** (Settings) in the bottom-left corner. Navigate to the **Cowork** section in the sidebar.

### Global Instructions

This is the most important setting. Global Instructions are injected into every Cowork session before Claude processes your first message. They act as a persistent system prompt.

**To configure:**
1. In Settings, find **Cowork → Edit Global Instructions**
2. Paste everything from `GLOBAL-INSTRUCTIONS.md` (below the dotted line) into the text area
3. Click **Save**

These instructions tell Claude to read your `ABOUT-ME/` folder before every task, follow your writing rules, use the folder protocol, and apply your domain defaults. Without this step, the folder structure has no effect — Claude won't know to read it.

**When to update:** Any time you change `GLOBAL-INSTRUCTIONS.md` in the repo (adding new domain defaults, changing naming conventions, updating folder paths), re-paste the content into this settings field. The file in the repo is the canonical version; the settings field is the deployed version.

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

When you start a Cowork session, you select folders via **Add Folder** on the session start screen. Cowork remembers previously selected folders but you can change them per session. The system expects at minimum:

1. **The claudio-cowork/ directory** — contains your profile, templates, and skills
2. **A write directory** (e.g., `CLAUDE OUTPUTS/`) — where Claude delivers work

If you want Claude to access project-specific files, add a `PROJECTS/` folder as a third mount point.

### Scheduled Tasks

Scheduled tasks run automatically on a cron schedule. They're configured via the Cowork interface or by asking Claude to create one. See [Scheduled Output Audit](#scheduled-output-audit) for the specific audit task included in this system.

To view and manage scheduled tasks: ask Claude "list my scheduled tasks" in any Cowork session, or check the scheduled tasks panel in Settings.

---

## Personalizing Your Profile

### `ABOUT-ME/about-me.md`

This file is a template. Replace every section with your own information.

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

### `ABOUT-ME/anti-ai-writing-style.md`

This file has two parts: a kill list (what Claude must never do) and positive rules (how Claude should write instead).

**Customizing the kill list:** Review each category (filler phrases, meta-explanatory phrases, engagement loops, closure templates, reassurance language, corporate buzzwords). Remove items that don't bother you. Add phrases you've noticed Claude using that you dislike.

**Customizing positive rules:** The template includes rules for tone (neutral, analytic), structure (lead with the answer), technical writing (domain vocabulary, runnable code), financial writing (risk metrics, standard notation), and math (LaTeX over prose). Adjust these to your domain. A designer might replace the financial writing section with design system conventions. A lawyer might add citation format rules.

**The test at the bottom** is the quality gate. Replace the reference persona with your own: "Would a senior [your role] find this useful, or would they skim past it?"

---

## Configuring Global Instructions

Global Instructions are the control plane. They tell Claude what to read, where to write, and what rules to follow before every task.

### Key Sections

**BEFORE EVERY TASK** — This is the boot sequence. Claude reads all files in `ABOUT-ME/` (including `feedback.md`), checks for relevant project context, and loads applicable templates. Never remove the instruction to read `feedback.md` — that's how corrections accumulate.

**FOLDER PROTOCOL** — Defines three read-only folders and one write folder. Adjust the folder names if your structure differs:

```
Read-only:
  ABOUT ME/     → Identity and preferences
  TEMPLATES/    → Reusable patterns
  PROJECTS/     → Project-specific context

Write:
  CLAUDE OUTPUTS/ → Everything Claude creates goes here
```

**NAMING CONVENTION** — The default format is `project_content-type_v1.ext`. Content types include: analysis, model, backtest, pipeline, dashboard, report, spec, script, notebook, doc. Modify these to match your domain.

**DOMAIN DEFAULTS** — Domain-specific rules that apply unless overridden. The template includes defaults for equities, crypto, macro, risk, and backtests. Replace with your domain's conventions. A web developer might add: "React: functional components only, no class components. CSS: Tailwind utility classes, no inline styles."

### Updating Global Instructions

When you change `GLOBAL-INSTRUCTIONS.md` in the repo, you also need to re-paste it into **Settings → Cowork → Edit Global Instructions**. The file in the repo is the canonical version; the Cowork settings are the deployed version.

---

## Setting Up the Prompt Template and Mac Shortcut

### The Template

The core prompt template is deliberately simple:

```
I want to [TASK] to [SUCCESS CRITERIA]. First, explore my CLAUDE COWORK folder.
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
   I want to [TASK] to [SUCCESS CRITERIA]. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
   ```
6. Click **Add** or press Enter

Now, anywhere on your Mac — in the Claude Desktop chat, in Notes, in any text field — typing `/prompt` followed by a space expands to the full template. Replace `[TASK]` and `[SUCCESS CRITERIA]` with your specifics and send.

**Tips:**
- The shortcut works in Claude Desktop's chat input field
- You can create multiple shortcuts: `/prompt-backtest`, `/prompt-pipeline`, `/prompt-dashboard` — each pre-filled with domain-specific task language
- If the shortcut doesn't expand, check that text replacement is enabled in **System Settings → Keyboard → Text Input → Text Replacements**

### Domain-Specific Shortcut Examples

The `PROMPT-TEMPLATE.md` file includes 8 ready-made examples across systematic equities, crypto, macro, data pipelines, full-stack features, ML models, portfolio analysis, and client deliverables. Use these as starting points for your own shortcuts.

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

**Option A — Point Cowork at the folder.** When you add the `claudio-cowork/` directory to a Cowork session, Claude can read `TEMPLATES/meta-prompt-generator/SKILL.md` when you ask it to generate a spec.

**Option B — Copy to the Cowork skills directory.** For the skill to trigger automatically by phrase matching (without you explicitly referencing the folder), copy the entire `meta-prompt-generator/` directory into Claude's skills folder:

```bash
cp -r TEMPLATES/meta-prompt-generator/ ~/path-to-cowork-skills/meta-prompt-generator/
```

The exact skills directory location depends on your Cowork configuration.

### How to Trigger It

Say any of the following (or similar):
- "Turn this into a spec"
- "Write an agent prompt for this"
- "Create an agent prompt from this code"
- "Spec this out for automation"
- "Make this executable by an agent"

Or drop in a codebase, doc, or braindump and say:
- "Make this actionable"
- "Productionize this"
- "Write instructions an AI can follow"

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

`ABOUT-ME/feedback.md` is the simplest and most powerful component. It's a plain text file with one correction per line:

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
2. Reads your `ABOUT-ME/` folder (profile, writing rules, feedback log)
3. Scans the `CLAUDE OUTPUTS/` folder for files created since the last audit
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
It should review all files in CLAUDE OUTPUTS/ created this week, grade them against
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

Skills are folders containing a `SKILL.md` file with instructions that Claude loads when triggered. To create a new skill:

1. Create a folder under `TEMPLATES/`:
   ```
   TEMPLATES/
   └── my-new-skill/
       ├── SKILL.md          ← Required: instructions
       └── references/       ← Optional: reference docs
   ```

2. Write the `SKILL.md` with YAML frontmatter (name, description, trigger phrases) and markdown body (instructions).

3. The description field controls when the skill triggers. Be specific about trigger phrases:
   ```yaml
   ---
   name: my-new-skill
   description: |
     Use this skill when the user says "generate API docs",
     "document this endpoint", or "write OpenAPI spec".
   ---
   ```

4. Test the skill by asking Claude to perform the task in a Cowork session with the folder mounted.

---

## Folder Architecture Deep Dive

The system uses a strict read/write separation to prevent Claude from accidentally modifying your context files.

### Read-Only Folders

| Folder | Purpose | Contents |
|--------|---------|----------|
| `ABOUT-ME/` | Identity and preferences | Profile, writing rules, correction log |
| `TEMPLATES/` | Reusable patterns and skills | Skill instructions, reference docs, eval configs |
| `PROJECTS/` | Project-specific context | Briefs, datasets, reference code (you create this) |

Claude reads from these folders to build context. It never creates, edits, or deletes files here (enforced by Global Instructions).

### Write Folder

| Folder | Purpose | Contents |
|--------|---------|----------|
| `CLAUDE OUTPUTS/` | Deliverables | Everything Claude creates, organized by project |

Claude writes all outputs here, using the naming convention defined in Global Instructions (`project_content-type_v1.ext`). It creates project subfolders as needed.

### Why This Separation Matters

Without explicit folder protocols, Claude may write outputs alongside your context files, overwrite templates, or create files in unexpected locations. The read/write separation makes Claude's behavior predictable: context flows in from the left (read folders), work product flows out to the right (write folder).

---

## Troubleshooting

**Claude doesn't reference my profile.** Verify the folder is mounted in the current session (check the session start screen). Global Instructions must also be pasted into Settings — the `GLOBAL-INSTRUCTIONS.md` file in the repo is not automatically loaded.

**Claude uses AI-speak despite the writing rules.** Add the specific phrase to `feedback.md` with the date. This creates an explicit override. If a pattern persists across sessions, check that `anti-ai-writing-style.md` has the phrase in the kill list and that Global Instructions include the line "Follow every rule in `anti-ai-writing-style.md` for all outputs."

**The meta-prompt skill doesn't trigger.** If the skill is only in the `TEMPLATES/` folder (not copied to the Cowork skills directory), you need to explicitly reference it: "Read the meta-prompt-generator skill and use it to spec this out." For automatic triggering, copy the skill folder to your Cowork skills directory.

**Mac text shortcut doesn't expand.** Check **System Settings → Keyboard → Text Input → Text Replacements**. The shortcut must be listed there. Some apps (particularly Electron-based) may delay expansion — press space or return after typing `/prompt` to trigger it.

**Claude writes to the wrong folder.** Check that Global Instructions specify the correct write folder path. The instructions must match the actual folder name you created and mounted.
