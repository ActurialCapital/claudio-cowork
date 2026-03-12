# Agent Framework Evaluation

Technical evaluation of four Claude Code orchestration repositories for multi-agent software development.

---

## 1. Repository Summaries

### Get Shit Done (GSD)

**Repository**: `gsd-build/get-shit-done`

GSD is a meta-prompting and spec-driven development system that transforms Claude Code (and other runtimes) into an autonomous development engine. The core insight is that agent quality degrades over long sessions due to "context rot" — as context accumulates, output quality drops. GSD solves this by decomposing work into small plans executed in fresh subagent contexts.

**Architecture**: Three-tier orchestration — user-facing commands delegate to workflow orchestrators, which spawn specialized subagents. All state lives in a `.planning/` directory as structured markdown with YAML frontmatter. The filesystem is the database.

**Workflow**: Discussion → Planning → Execution → Verification. Plans are grouped into dependency graphs called "Waves" and executed in parallel where possible. Each task gets a fresh 200K token context window — task 50 has the same quality as task 1.

**Intended use case**: Large-scale autonomous development where Claude works for extended periods without human intervention. Atomic commits per task create bisectable git history. Branch-per-slice isolation keeps parallel work clean.

**Runtime support**: Claude Code, OpenCode, Gemini CLI, and Codex. A single installer applies runtime-specific transformations to the same source.

---

### Superpowers

**Repository**: `obra/superpowers`

Superpowers is an agentic skills framework that enforces disciplined development practices — TDD, structured planning, dual-stage code review — through composable skills that activate automatically based on context. It transforms Claude Code from a code generator into a process-aware senior developer.

**Architecture**: Two-tier skill system (core + personal skills with shadowing). Skills are markdown files with YAML frontmatter that inject behavioral rules into the agent session. A SessionStart hook loads the skill-checking protocol on every session initialization.

**Workflow**: Brainstorming → Planning → Execution → Verification. The execution phase spawns fresh subagents per task with mandatory dual-stage code review (spec compliance, then code quality). TDD is enforced as an iron rule — code written before a failing test is deleted.

**Intended use case**: Teams and individuals who want Claude Code to follow rigorous engineering practices. The framework is opinionated: it prescribes how work should be done, not just what tools are available.

**Ecosystem**: Accepted into Anthropic's Claude plugins marketplace. Separate repositories for community skills (`superpowers-skills`), experimental skills (`superpowers-lab`), and a curated marketplace (`superpowers-marketplace`). Supports Claude Code, Codex, OpenCode, Cursor, and Gemini CLI.

---

### Oh My OpenAgent (OmO)

**Repository**: `code-yeongyu/oh-my-openagent`

OmO is a multi-model agent orchestration harness that coordinates specialized agents across different LLM providers. Its defining contribution is "Hashline" — hash-anchored code edits where every line includes a content hash, catching mismatches before corruption. The project claims this improved coding benchmark success rates from 6.7% to 68.3%.

**Architecture**: Named discipline agents — Sisyphus (orchestrator, Claude/Kimi/GLM), Hephaestus (autonomous deep worker, GPT Codex), Prometheus (strategic planner), Oracle (architecture), Librarian (documentation), Explore (navigation). Category-based routing (`visual-engineering`, `deep`, `quick`, `ultrabrain`) auto-selects model and tier.

**Intended use case**: Developers who want multi-model orchestration — using each provider's strengths for specific tasks — while maintaining Claude Code compatibility. The `ultrawork` command triggers full team coordination from a single keyword.

**Technical differentiators**: LSP + AST-Grep integration for IDE-grade refactoring across 25+ languages. Skill-embedded MCPs that activate on demand without polluting the main context. Tmux-based terminal sessions for interactive debugging.

---

### Oh My ClaudeCode (OMC)

**Repository**: `yeachan-heo/oh-my-claudecode`

OMC is a teams-first multi-agent framework built specifically for Claude Code. It provides 32 specialized agents organized by complexity tier (Haiku for low, Sonnet for medium, Opus for high), with intelligent model routing that claims 30-50% token savings.

**Architecture**: Skill-based routing with three composition layers — guarantee (completion enforcement), enhancement (parallelism, git mastery, UI/UX), and execution (planning, orchestration). 31 lifecycle hooks manage the full agent lifecycle from prompt submission through tool use to session end.

**Workflow modes**: Team (canonical staged pipeline), Autopilot (autonomous execution), Ultrawork (maximum parallelism), Ralph (persistent verify/fix loops), Pipeline (sequential processing), and CCG (tri-model advisory synthesizing Codex, Gemini, and Claude).

**Intended use case**: Claude Code users who want sophisticated multi-agent coordination without learning complex commands. Magic keywords (`autopilot:`, `ralph:`, `ulw`) trigger different orchestration modes from natural language. The verification protocol requires fresh evidence (within 5 minutes) with actual command output to confirm completion.

---

## 2. Comparison

### Feature Matrix

| Capability | GSD | Superpowers | OmO | OMC |
|---|---|---|---|---|
| Multi-agent orchestration | Yes (wave-based) | Yes (subagent per task) | Yes (named discipline agents) | Yes (32 specialized agents) |
| Context rot mitigation | Core focus | Fresh subagents | Fresh contexts | Fresh contexts |
| TDD enforcement | No (spec-driven) | Iron rule | Not enforced | Not enforced |
| Multi-model support | Single-model, multi-runtime | Single-model, multi-runtime | Multi-model core design | Multi-model (Claude + Codex + Gemini) |
| Code review gates | Verification phase | Dual-stage (spec + quality) | Ralph loop | Evidence-based verification |
| Parallel execution | Wave-based dependency graph | Git worktree isolation | Background agents (5+) | Ultrawork mode |
| State management | `.planning/` filesystem | Skills in session context | `.sisyphus/` rules | `.omc/state/` JSON |
| Git integration | Branch-per-slice, atomic commits | Worktree isolation | Standard | Git-master skill |
| Plugin marketplace | No | Yes (Anthropic official) | No | Yes (Claude plugin) |
| Cost tracking | Built-in token/cost accounting | No | No | Model routing saves 30-50% |
| CLI distribution | `npx get-shit-done-cc@latest` | Claude plugin install | `npm oh-my-openagent` | `npm oh-my-claude-sisyphus` |

### Strengths

**GSD**: Context engineering is the most deliberate of the four. The `.planning/` directory as a filesystem database is elegant — every piece of state is inspectable, diffable, and version-controllable. Wave-based execution with dependency analysis is the most sophisticated parallelism model. Cost tracking gives visibility that others lack. The spec-driven approach (write specs first, implement to match) is well-suited to large projects where requirements are known.

**Superpowers**: The most mature ecosystem — official Anthropic marketplace acceptance, community skills repository, and a clear separation between core and personal skills. TDD enforcement is unique and valuable for production codebases. The dual-stage code review (spec compliance then quality) catches both "did it do the right thing" and "did it do it well." The brainstorming phase with Socratic questioning is effective for requirements clarification.

**OmO**: Hashline (hash-anchored edits) solves a real problem — edit reliability is one of the most common failure modes in agent frameworks. Multi-model routing is the most sophisticated, using each provider's strengths rather than forcing everything through one model. LSP + AST-Grep integration provides IDE-grade precision that the others lack.

**OMC**: The 32-agent roster with tiered model routing (Haiku/Sonnet/Opus) is the most granular delegation system. Magic keywords provide the lowest-friction entry point. The verification protocol (fresh evidence within 5 minutes) is the most rigorous completion check. The lifecycle hook system (31 hooks) offers the most extensibility.

### Limitations

**GSD**: Rate limiting is a real concern — parallel research, plan verification, and wave execution can exhaust Claude Team rate limits mid-project. The spec-driven approach requires upfront requirements clarity that exploratory projects may not have. Token overhead from organizing work into small plans is non-trivial.

**Superpowers**: The rigid TDD enforcement is counterproductive for prototyping, data pipelines, infrastructure code, and other domains where tests-first is impractical. Overhead is not justified for quick fixes or single-file changes. The methodology is opinionated to the point of being prescriptive — it assumes a specific way of working.

**OmO**: Requires Tmux for full functionality, which limits Windows users. Managing API keys for multiple providers adds operational complexity. The framework is the most complex to configure. The benchmark claims (6.7% → 68.3%) are self-reported and lack independent verification.

**OMC**: Rapid release cadence (199 releases) suggests instability — features are added and deprecated quickly (Codex/Gemini MCP servers removed in v4.4.0, swarm keyword deprecated). The npm package name (`oh-my-claude-sisyphus`) doesn't match the repository name, suggesting identity churn. Full tri-provider support costs ~$60/month in subscriptions.

### Maturity

| Repository | Stars | Commits | Releases | Marketplace | Stability |
|---|---|---|---|---|---|
| GSD | 28.5K | Active | npm published | No | Moderate — v2 rewrite on Pi SDK |
| Superpowers | 79.4K | Active | Versioned (v5.0.1) | Anthropic official | High — clear versioning, community skills |
| OmO | 39.4K | 3,649 | npm published | No | Moderate — active development |
| OMC | 9.5K | 1,820 | 199 releases (v4.8.0) | Claude plugin | Low-moderate — rapid churn |

---

## 3. Compatibility Matrix

### Overlapping Responsibilities

All four repositories compete in the same space: they orchestrate subagents, manage context, and enforce development workflows for Claude Code. Running two simultaneously creates conflicts in prompt injection (competing system prompts), hook contention (multiple SessionStart hooks), state management (competing `.planning/` vs `.omc/` directories), and workflow control (conflicting phase definitions).

| Pair | Conflict Level | Nature |
|---|---|---|
| GSD + Superpowers | High | Both define the full development lifecycle. Competing planning phases, execution strategies, and verification protocols. |
| GSD + OmO | High | Both orchestrate subagents with different dispatch models. GSD uses wave-based execution; OmO uses named discipline agents. |
| GSD + OMC | High | Both manage multi-agent coordination. Competing state directories, lifecycle hooks, and execution models. |
| Superpowers + OmO | Medium-High | Superpowers enforces TDD and dual review; OmO has its own verification loops. Skill systems could shadow each other. |
| Superpowers + OMC | Medium-High | Both install as Claude plugins with SessionStart hooks. Competing skill activation and verification protocols. |
| OmO + OMC | Very High | Direct competitors — OMC is explicitly inspired by OmO. Nearly identical feature sets with incompatible implementations. |

### Combinations That Work

**Superpowers skills + GSD orchestration (with significant integration work)**: Superpowers' individual skills (TDD, systematic debugging, code review) are well-defined markdown files that could theoretically be injected into GSD's subagent contexts. This would give GSD's execution phase Superpowers' quality enforcement. However, this requires custom integration — they don't compose out of the box.

**Any framework + OmO's Hashline (if extracted)**: The hash-anchored edit system is a standalone improvement to edit reliability. If extracted as a library, it would benefit any framework. Currently, it's tightly coupled to OmO's harness.

### Combinations to Avoid

**OmO + OMC**: Nearly identical architectures with incompatible implementations. OMC was inspired by OmO; running both would create duplicate agents, conflicting hooks, and competing state management.

**Any two full frameworks simultaneously**: GSD, Superpowers, OmO, and OMC each assume they own the development lifecycle. Running two creates undefined behavior — competing prompts, duplicate subagent spawning, and conflicting state.

---

## 4. Recommended Architecture

### Context

The target environment is Claude Code or Claude Cowork for complex software projects requiring multiple agents working sequentially and in parallel.

### Recommended Stack

**Primary orchestration: GSD** for project-level planning and parallel execution.

**Quality enforcement: Superpowers skills** (selectively extracted) for TDD, code review, and debugging within individual task execution.

**Rationale**: GSD provides the strongest orchestration primitives — wave-based parallel execution with dependency analysis, filesystem-based state that survives context compaction, cost tracking, and the most deliberate context engineering. Superpowers provides the strongest individual-task quality enforcement — TDD, dual-stage review, systematic debugging.

The two address different concerns: GSD answers "how do I coordinate 20 parallel tasks across a large codebase" while Superpowers answers "how do I ensure each individual task produces production-quality code."

### Why Not the Others

**OmO** is compelling for its multi-model routing and Hashline reliability, but it requires Tmux and multiple provider subscriptions, adding operational complexity. For a Claude Code/Cowork primary environment, multi-model routing is less relevant — you're already committed to Anthropic's models.

**OMC** has the most agents and the fastest iteration, but its rapid release cadence and feature churn suggest it hasn't stabilized. The 199 releases in its lifetime means roughly one release every 2-3 days — useful for bleeding-edge experimentation, risky for production projects.

### How Agent Orchestration Would Work

```
Developer provides high-level objective
    ↓
GSD Discussion Phase
    Captures scope, constraints, decisions
    Produces REQUIREMENTS.md and PROJECT.md
    ↓
GSD Planning Phase
    Research subagents gather codebase context
    Planner creates small, verifiable .spec files
    Dependency analysis groups specs into Waves
    ↓
GSD Execution Phase (Wave-based)
    Wave 1: Independent tasks execute in parallel
        Each subagent gets:
        - Fresh 200K context window
        - Relevant .spec file
        - Superpowers TDD skill (write failing test → implement → pass)
        - Superpowers code review skill (spec compliance → quality)
        - Only the codebase files it needs (context engineering)
    Wave 2: Dependent tasks execute after Wave 1 completes
        Same pattern, with Wave 1 outputs available
    Wave N: Continues until all specs are implemented
    ↓
GSD Verification Phase
    Automated checks against original specs
    Human review of outputs
    Atomic commits per task → bisectable git history
```

### Responsibility Division

| Concern | Owner | Mechanism |
|---|---|---|
| Project decomposition | GSD | Discussion and planning phases |
| Dependency analysis | GSD | Wave-based execution groups |
| Parallel execution | GSD | Fresh subagent per task with isolated context |
| State persistence | GSD | `.planning/` directory with YAML frontmatter |
| Git strategy | GSD | Branch-per-slice, atomic commits |
| Cost visibility | GSD | Token tracking per phase/slice/model |
| Test-first discipline | Superpowers (skill) | TDD skill injected into execution subagents |
| Code review | Superpowers (skill) | Dual-stage review after each task |
| Debugging methodology | Superpowers (skill) | Systematic debugging skill when issues arise |
| Completion verification | GSD + Superpowers | GSD verification phase + Superpowers verification skill |

### Why This Works for Complex Projects

Complex projects fail in agent-assisted development for three reasons: context degrades over time, parallel work creates conflicts, and quality drops without review gates.

GSD directly addresses the first two. Its fresh-context-per-task model means the 50th task has the same quality as the first. Its wave-based execution with dependency analysis means parallel work is coordinated — if Task B depends on Task A, it waits. Branch-per-slice isolation prevents git conflicts.

Superpowers addresses the third. TDD enforcement means every implementation has a test that was written first and watched to fail. Dual-stage review means every task is checked against its spec and against code quality standards. These aren't suggestions — they're enforced behaviors.

The combination gives you an autonomous development pipeline where the orchestration is intelligent (GSD) and the individual execution is disciplined (Superpowers). Neither alone is sufficient: GSD without quality enforcement produces fast but brittle code; Superpowers without orchestration doesn't scale beyond single-task execution.

### Practical Caveat

This integration doesn't exist out of the box. GSD and Superpowers are independent projects with different architectures. Combining them requires injecting Superpowers skill files into GSD's subagent dispatch — feasible given that both use markdown-based skill/spec definitions, but it's custom work. The alternative is to pick one: GSD if orchestration scale matters most, Superpowers if individual task quality matters most.
