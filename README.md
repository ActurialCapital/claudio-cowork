<p align="center">
  <img src="docs/claudio-logo.png" alt="Claudio" width="160"/>
</p>

<h1 align="center">Claudio-Cowork</h1>

<p align="center">
  Persistent memory and custom skills for <a href="https://claude.ai">Claude Cowork</a>.<br/>
  Clone it. Make it yours. Claude starts every session knowing who you are.
</p>

<p align="center">
  <a href="HOW-TO.md">Setup Guide</a> &middot;
  <a href="HOW-TO.md#the-meta-prompt-generator-skill">Meta-Prompt Generator</a> &middot;
  <a href="HOW-TO.md#how-it-works-end-to-end">How It Works</a>
</p>

---

## The Problem

Claude Cowork starts every session with zero context about you. You re-explain your stack, re-correct the same writing habits, and re-describe your project conventions each time.

This repository eliminates that. Point Cowork at a structured folder, paste one block of Global Instructions, and every session begins with Claude reading your profile, your writing rules, and your correction log before it writes a single line.

## How It Works

```
You open Cowork
    ↓
Global Instructions trigger the boot sequence
    ↓
Claude reads ABOUT-ME/ (profile + writing rules + corrections)
    ↓
You send a prompt (using /prompt shortcut)
    ↓
Claude loads relevant TEMPLATES/ and PROJECTS/
    ↓
Claude asks clarifying questions before executing
    ↓
Output lands in CLAUDE OUTPUTS/ — named, styled, reviewed
```

Four mechanisms compound over time:

- **Static context** (`ABOUT-ME/`) — your profile, stack, and communication preferences, read every session
- **Dynamic corrections** (`feedback.md`) — one-line fixes that accumulate into a personalized fine-tuning layer
- **Structural guardrails** (`GLOBAL-INSTRUCTIONS.md`) — folder protocol, naming conventions, domain defaults
- **Automated audit** (scheduled task) — weekly review of outputs against your standards, catching drift before it compounds

The prompts stay simple. The context does the heavy lifting.

## Repository Structure

```
claudio-cowork/
├── README.md
├── docs/
│   ├── HOW-TO.md                          ← Setup, customization, and extension guide
│   └── claudio-logo.svg                   ← Logo asset
├── ABOUT-ME/
│   ├── about-me.md                        ← Your profile: stack, domains, priorities
│   ├── anti-ai-writing-style.md           ← Writing rules and kill list
│   └── feedback.md                        ← Running correction log
├── GLOBAL-INSTRUCTIONS.md                 ← Paste into Settings → Cowork
├── PROMPT-TEMPLATE.md                     ← Reusable prompt + Mac shortcut setup
└── TEMPLATES/
    └── meta-prompt-generator/             ← Custom skill: idea → agent-ready spec
        ├── SKILL.md                       ← Skill instructions (v2.1)
        ├── references/
        │   ├── output-format-rationale.md ← Why YAML+MD over XML/Markdown/flexible
        │   └── yaml-to-xml-mapping.md     ← YAML → XML conversion rules
        └── evals/
            └── evals.json                 ← Test cases for skill validation
```

## Quick Start

```bash
git clone https://github.com/<your-username>/claudio-cowork.git
```

1. Replace `ABOUT-ME/` files with your own profile and writing rules
2. Open Claude Desktop → **Settings → Cowork → Edit Global Instructions** → paste from `GLOBAL-INSTRUCTIONS.md`
3. Start a Cowork session → **Add Folder** → select the cloned directory
4. (Optional) Set up the [`/prompt` Mac text shortcut](HOW-TO.md#setting-up-the-prompt-template-and-mac-shortcut)
5. (Optional) Install the [meta-prompt-generator skill](HOW-TO.md#the-meta-prompt-generator-skill)
6. (Optional) Create the [weekly output audit](HOW-TO.md#scheduled-output-audit)

Full walkthrough: [`HOW-TO.md`](HOW-TO.md)

## What's Inside

| File | Purpose |
|------|---------|
| `ABOUT-ME/about-me.md` | Identity file — name, role, domains, tech stack, priorities, communication style. Claude reads this first to calibrate every output. |
| `ABOUT-ME/anti-ai-writing-style.md` | Kill list of AI writing patterns (filler, engagement loops, closure templates, buzzwords) plus positive rules for tone, structure, and domain conventions. |
| `ABOUT-ME/feedback.md` | Running correction log. One line per fix. Read before every task, applied as overrides. Grows over time into a personalized fine-tuning layer. |
| `GLOBAL-INSTRUCTIONS.md` | Control plane. Folder protocol (3 read-only + 1 write), naming conventions, domain defaults. Paste into Cowork settings. |
| `PROMPT-TEMPLATE.md` | Reusable prompt that forces context loading → clarification → execution. Includes Mac text shortcut setup and 8 domain examples. |
| `TEMPLATES/meta-prompt-generator/` | Custom skill that transforms ideas, codebases, or docs into structured YAML+Markdown specs for autonomous agent execution. [Details →](HOW-TO.md#the-meta-prompt-generator-skill) |

## The Meta-Prompt Generator

The most complex component. It compiles unstructured input into deterministic, contract-grade agent specifications.

```
raw idea / codebase / API docs
    ↓
meta-prompt → prompt → spec → code
```

The skill classifies your input, extracts requirements through structured questions, generates a YAML frontmatter (single source of truth) with a Markdown body (examples, anti-patterns, implementation guidance), then runs 9 quality checks before delivering the spec.

Output format rationale — why YAML+Markdown over XML, structured Markdown, or flexible formats — is documented in [`references/output-format-rationale.md`](TEMPLATES/meta-prompt-generator/references/output-format-rationale.md). The short version: YAML+MD wins for human-in-the-loop workflows; XML wins for pure automation; the recommended architecture is hybrid (YAML+MD early, XML late).

## Methodology

Follows a "context over prompting" philosophy, inspired by [Ruben Hassid's Cowork customization guide](https://ruben.substack.com/p/claude-cowork). Instead of crafting perfect prompts per task, give Claude persistent context about who you are and how you work. Output quality improves over time without changing any prompts.

This system was built for a quantitative engineering workflow (systematic trading, ML research, full-stack development), but the architecture is domain-agnostic. Fork it, replace the content, and it works for any domain.

## License

MIT
