# Agents.md Stack Integration Analysis

## 1. What Agents.md Provides

AGENTS.md is a Markdown file placed in a repository root (or subdirectories in monorepos) that gives AI coding agents project-specific instructions. It was released in August 2025, adopted by 60,000+ open-source projects, and is now stewarded by the Agentic AI Foundation under the Linux Foundation (co-founded by Anthropic, OpenAI, and Block in December 2025).

**Purpose.** It standardizes the location and format for agent-facing project metadata. README.md tells humans how to contribute. AGENTS.md tells agents how to work on the codebase: build commands, test commands, coding conventions, PR formatting rules, linting expectations.

**Core concepts.**

- Plain Markdown. No JSON schema, no YAML, no proprietary syntax. Agents and humans read the same file.
- Directory-scoped. In monorepos, each package can have its own AGENTS.md. The nearest file in the directory tree takes precedence.
- Agent-agnostic. Supported by Codex, Cursor, Devin, Factory, Gemini CLI, GitHub Copilot, Jules, and VS Code. It is the closest thing to a universal cross-tool standard.

**Typical sections.**

| Section | Content |
|---------|---------|
| Dev environment | Package manager, workspace setup, build commands |
| Testing | CI/CD workflows, test runners, linting, type checking |
| PR instructions | Commit format, branch naming, review checklist |
| Coding conventions | Style preferences, architectural constraints |

**What it is not.** AGENTS.md does not orchestrate workflows, enforce development methodology, manage multi-agent coordination, or define agent behavior. It is a static configuration file, not a runtime system.


## 2. Compatibility Analysis

### 2.1 Layer Map

Each tool operates at a distinct layer:

| Layer | Tool | Function |
|-------|------|----------|
| Project context | AGENTS.md | Static repo metadata for agents |
| Development discipline | Superpowers | TDD, planning, code review enforcement |
| Project orchestration | GSD | Multi-phase planning, research, execution, verification |

There is no architectural overlap between the three.

### 2.2 Agents.md vs. GSD

GSD manages the full project lifecycle: roadmap creation, phase planning, parallel research, dependency-aware execution waves, and verification loops. It operates through slash commands (`/gsd:new-project`, `/gsd:plan-phase`, `/gsd:execute-phase`, etc.) and maintains state in `.planning/` files (PROJECT.md, ROADMAP.md, STATE.md, plan XMLs).

AGENTS.md provides none of this. It tells an agent "run `pnpm test` before committing" and "use conventional commits." GSD tells agents *what* to build, *when*, and *how to coordinate*.

**Overlap:** Zero. AGENTS.md is a passive configuration file. GSD is an active orchestration system.

**Complementarity:** When GSD spawns a fresh subagent to execute a task, that subagent inherits no project context from the orchestrator's memory. AGENTS.md gives it immediate access to build commands, test commands, and coding conventions without consuming context budget on boilerplate instructions that GSD would otherwise need to repeat per-agent.

**Conflicts:** None identified. GSD's `.planning/` directory and AGENTS.md occupy different namespaces and serve different purposes.

### 2.3 Agents.md vs. Superpowers

Superpowers enforces development methodology: TDD cycles (red-green-refactor), Socratic brainstorming, structured planning, inter-agent code review, and subagent-driven development. It operates as a Claude Code plugin with 14 composable skills.

AGENTS.md contains no methodology enforcement. It cannot mandate TDD, trigger code review, or structure planning sessions. It is inert text.

**Overlap:** Marginal. Both can contain testing instructions, but at different levels. AGENTS.md says "run `vitest` for unit tests." Superpowers says "write a failing test first, watch it fail, write minimal passing code, then refactor." One describes *what command to run*; the other enforces *when and why to run it*.

**Complementarity:** Superpowers' subagent-driven development spawns agents that need to know project-specific test commands, linting rules, and build steps. AGENTS.md provides exactly this. Without it, each Superpowers skill would need custom project configuration or rely on the agent discovering commands by reading package.json, Makefiles, or CI configs.

**Conflicts:** None identified.

### 2.4 Agents.md vs. CLAUDE.md

This is the critical compatibility question. Claude Code already reads CLAUDE.md from three locations (global, project root, subdirectories). As of March 2026, Claude Code does not natively auto-load AGENTS.md — this is an open feature request.

The practical resolution: CLAUDE.md contains Claude-specific behavioral instructions (tone, output format, tool preferences). AGENTS.md contains cross-tool project metadata (build, test, lint, conventions). They coexist. If Claude Code eventually adds AGENTS.md support, both files merge into the agent's context automatically. Until then, AGENTS.md content relevant to Claude can be referenced from CLAUDE.md, or the AGENTS.md content can be duplicated into CLAUDE.md.


## 3. Stack Evaluation

### 3.1 Does it improve the architecture?

Yes, at the project-context layer. The current stack has:

- GSD for *what to build and when* (orchestration)
- Superpowers for *how to build it* (methodology)
- No standardized mechanism for *project-specific technical context* that persists across agents and tools

AGENTS.md fills this gap. When GSD spawns four parallel research agents or Superpowers launches a subagent for TDD execution, each agent currently relies on either (a) the orchestrator passing project context in the prompt, consuming context budget, or (b) the agent discovering context by reading files, consuming time and tokens.

AGENTS.md provides a single canonical source of project-specific instructions that every agent — regardless of which tool spawned it — can read on startup.

### 3.2 Does it duplicate existing capabilities?

No. Neither GSD nor Superpowers serve as a static project-context file. GSD's PROJECT.md describes the project vision and roadmap, not build commands and coding conventions. Superpowers' skills describe methodology, not project-specific tooling.

The closest existing mechanism is CLAUDE.md, which can hold project context but is Claude-specific. AGENTS.md is tool-agnostic, which matters if the stack ever includes non-Claude agents (Codex, Cursor, Gemini CLI).

### 3.3 Does it introduce unnecessary complexity?

No. AGENTS.md is a single Markdown file. It requires no runtime, no dependencies, no configuration beyond writing the file. The maintenance cost is equivalent to maintaining a README.

### 3.4 Effect on agent orchestration

Neutral-to-positive. GSD's orchestration logic is unaffected. The marginal benefit: subagents spawned by GSD can read AGENTS.md for project context instead of receiving it through the orchestrator, reducing orchestrator context consumption.

### 3.5 Effect on multi-agent collaboration

Positive. Every agent — research agents, executor agents, verifier agents, code review agents — gets the same project context from the same source. No drift between agents receiving different instructions. No context budget wasted on redundant project metadata.

### 3.6 Effect on development workflow

Minimal change. The existing GSD + Superpowers workflow remains intact. AGENTS.md adds a pre-existing knowledge base that agents consult automatically (or will, once Claude Code adds native support).


## 4. Integration Strategy

### 4.1 Layer assignment

AGENTS.md belongs at the **project-context layer** — below orchestration (GSD), below methodology (Superpowers), at the same level as CLAUDE.md.

```
┌─────────────────────────────┐
│  GSD (orchestration)        │  /gsd:plan-phase, /gsd:execute-phase
├─────────────────────────────┤
│  Superpowers (methodology)  │  TDD, planning, code review
├─────────────────────────────┤
│  AGENTS.md + CLAUDE.md      │  Project context, agent config
│  (project context)          │
└─────────────────────────────┘
```

### 4.2 Interaction with GSD

GSD does not need modification. AGENTS.md supplements GSD by ensuring subagents have project context on startup. GSD's `.planning/PROJECT.md` describes *what the project does and where it's going*. AGENTS.md describes *how to build, test, and lint it*.

Recommended practice: GSD's `/gsd:new-project` or `/gsd:map-codebase` can reference AGENTS.md for initial project context during the research phase. No changes to GSD's command structure required.

### 4.3 Interaction with Superpowers

Superpowers does not need modification. Its TDD skill needs to know how to run tests — AGENTS.md provides this. Its code-review skill needs to know coding conventions — AGENTS.md provides this.

The integration is passive: Superpowers' agents read AGENTS.md the same way they read any project file.

### 4.4 Claude Code / Cowork usage

Two options, depending on Claude Code's current AGENTS.md support status:

**Option A (native support available).** Place AGENTS.md in the project root. Claude Code auto-loads it alongside CLAUDE.md. Done.

**Option B (native support not yet available — current state as of March 2026).** Add a reference in CLAUDE.md:

```markdown
## Project Context
See AGENTS.md in the project root for build, test, lint, and convention instructions.
All agents should read AGENTS.md before starting work.
```

This ensures Claude Code surfaces the file through its existing CLAUDE.md discovery mechanism.

### 4.5 Content boundaries

Keep the following separation to avoid duplication:

| File | Contains | Does not contain |
|------|----------|-----------------|
| AGENTS.md | Build commands, test commands, lint config, coding conventions, PR format, CI/CD instructions | Agent behavior, tone, output format, tool-specific config |
| CLAUDE.md | Claude-specific behavior, output preferences, tool configuration, references to AGENTS.md | Build/test commands (these go in AGENTS.md) |
| GSD .planning/ | Project vision, roadmap, phase plans, state, research | Static project config |
| Superpowers skills/ | Methodology enforcement (TDD, review, planning) | Project-specific commands |


## 5. Recommendation

Integrate AGENTS.md. It fills a real gap (standardized project context for multi-agent workflows) without duplicating GSD or Superpowers, adds zero runtime complexity, and future-proofs the stack for cross-tool agent compatibility.

The resulting stack architecture:

| Layer | Tool | Responsibility |
|-------|------|----------------|
| Orchestration | GSD | Project lifecycle, multi-phase planning, subagent coordination |
| Methodology | Superpowers | TDD, planning discipline, code review, quality enforcement |
| Project context | AGENTS.md | Build/test/lint commands, coding conventions, PR rules |
| Agent config | CLAUDE.md | Claude-specific behavior, output preferences, global instructions |

Implementation effort: write one Markdown file. No tooling changes, no workflow changes, no dependency additions.


## Sources

- [AGENTS.md specification (GitHub)](https://github.com/agentsmd/agents.md)
- [GSD — Get Shit Done (GitHub)](https://github.com/gsd-build/get-shit-done)
- [Superpowers (GitHub)](https://github.com/obra/superpowers)
- [AGENTS.md emerges as open standard — InfoQ](https://www.infoq.com/news/2025/08/agents-md/)
- [Complete guide to AI agent memory files](https://hackernoon.com/the-complete-guide-to-ai-agent-memory-files-claudemd-agentsmd-and-beyond)
- [AGENTS.md complete guide — Remio AI](https://www.remio.ai/post/what-is-agents-md-a-complete-guide-to-the-new-ai-coding-agent-standard-in-2025)
- [Superpowers explained — Dev Genius](https://blog.devgenius.io/superpowers-explained-the-claude-plugin-that-enforces-tdd-subagents-and-planning-c7fe698c3b82)
- [GSD workflow deep dive — Codecentric](https://www.codecentric.de/en/knowledge-hub/blog/the-anatomy-of-claude-code-workflows-turning-slash-commands-into-an-ai-development-system)
