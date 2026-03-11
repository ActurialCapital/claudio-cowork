# Output Format Rationale

> **Q:** Which workflow do you find yourself repeating most? That becomes your first custom skill.
>
> **A:** Construct a meta-prompt that ingests ideas, a codebase, or documentation and transforms them into a structured prompt. The resulting prompt must instruct an AI system to generate a clear, optimized specification suitable for execution by an autonomous agent. The meta-prompt should enforce structured inputs, extract requirements and constraints, normalize context from the provided materials, and produce a deterministic prompt that reliably yields a high-quality agent-ready specification.

---

## Goal

```
meta-prompt → prompt → spec → code
```

Primary requirement: deterministic transformation across stages. Each step must be machine-parseable and enforceable.

---

## Output Format Options

The generated prompt must enforce a specific output structure. Four candidates were evaluated.

### 1. Structured Markdown with Sections

**Advantages**

- Human-readable and easy to review.
- Natural fit for documentation workflows.
- Widely supported in developer tooling (GitHub, editors, docs systems).
- Flexible structure; easy to expand sections.
- Low friction for iteration and manual editing.

**Disadvantages**

- Weak machine parsing unless conventions are enforced.
- Models sometimes reorder or omit sections.
- Ambiguity in formatting (lists vs paragraphs).
- Harder to validate deterministically.

**Best use:** Human-in-the-loop workflows. Spec writing and architecture documentation. Situations where readability matters more than strict parsing.

### 2. XML-Tagged Prompt

**Advantages**

- Highly structured and deterministic.
- Easy for agents or parsers to extract fields.
- Explicit boundaries reduce hallucinated structure.
- Works well with schema validation.

**Disadvantages**

- Verbose.
- Harder for humans to read and edit.
- LLMs sometimes break tag nesting.
- Requires strict format discipline.

**Best use:** Agent pipelines. Tool-calling systems. Programmatic parsing and validation.

### 3. YAML Frontmatter + Markdown Body

**Advantages**

- Separates structured metadata from human-readable content.
- Easy machine extraction from YAML.
- Markdown body allows expressive explanation.
- Common in modern tooling (static sites, docs systems, LLM prompts).

**Disadvantages**

- Dual-format complexity.
- YAML formatting errors are common.
- Requires parsers that handle both YAML and Markdown.

**Best use:** Hybrid systems (human + machine). Prompt libraries and reusable specs. Systems with metadata requirements.

### 4. Flexible / Agent-Dependent Structure

**Advantages**

- Maximum adaptability.
- Can optimize format for each agent or tool.
- Supports multi-agent ecosystems with differing interfaces.

**Disadvantages**

- No standardization.
- Harder to reuse prompts.
- Higher maintenance cost.
- Increased cognitive load for developers.

**Best use:** Experimental systems. Multi-agent research environments. Systems integrating heterogeneous frameworks.

---

## Comparison Matrix

| Structure | Machine Parsing | Human Readability | Reliability | Flexibility | Typical Use |
|-----------|----------------|-------------------|-------------|-------------|-------------|
| Structured Markdown | Medium | Very High | Medium | High | Documentation + prompt design |
| XML Tagged | Very High | Low | High | Medium | Agent pipelines |
| YAML + Markdown | High | High | High | High | Hybrid prompt systems |
| Flexible | Variable | Variable | Low | Very High | Research / experimental agents |

---

## Pipeline Analysis by Format

### Structured Markdown

Properties: human-optimized, weak structural guarantees, high formatting variance across model outputs.

```
meta-prompt → prompt: acceptable
    prompt → spec: unstable
       spec → code: requires heuristic parsing
```

Failure modes: section drift, missing headings, non-deterministic ordering.

**Verdict:** Unsuitable for automated multi-stage pipelines.

### XML

Properties: explicit hierarchical structure, deterministic boundaries, easily schema-validated.

```
meta-prompt → prompt: deterministic
    prompt → spec: strongly constrained
       spec → code: trivial parsing
```

Failure modes: tag nesting errors, verbosity. Mitigation: strict tag schema.

**Verdict:** Strongest option for machine pipelines.

### YAML Frontmatter + Markdown

Properties: structured metadata, flexible descriptive body.

```
meta-prompt → prompt: stable
    prompt → spec: partially structured
       spec → code: requires partial parsing
```

Failure modes: YAML indentation errors, ambiguity in markdown body.

**Verdict:** Good for human + machine hybrid systems, not pure automation.

### Flexible / Agent-Dependent

Properties: no schema, context dependent.

```
meta-prompt → prompt: unstable
    prompt → spec: inconsistent
       spec → code: unreliable
```

**Verdict:** Incompatible with deterministic pipelines.

---

## Optimal Architecture for Pure Automation

For `meta-prompt → prompt → spec → code`, use XML with a fixed schema.

Conceptual structure:

```xml
<agent_spec>
  <objective></objective>
  <inputs></inputs>
  <outputs></outputs>
  <constraints></constraints>
  <workflow>
    <step></step>
  </workflow>
  <interfaces>
    <api></api>
  </interfaces>
  <validation></validation>
</agent_spec>
```

Properties: deterministic parsing, schema validation possible, clean conversion to JSON / AST, direct code generation.

Pipeline:

```
meta-prompt
     ↓
XML prompt template
     ↓
XML specification
     ↓
AST / JSON conversion
     ↓
code generation
```

This minimizes ambiguity across transformations.

---

## Human-in-the-Loop: Why the Optimum Shifts

When a human participates in the pipeline, the system is no longer purely machine-first. Early stages need interpretability and editability. Later stages need determinism. The best choice is not a single format across the whole chain.

### Why Not XML Everywhere

At the start, the human needs to inspect assumptions, edit goals, correct ambiguity, add missing constraints, and reject bad decomposition. XML is poor for that — rigid, verbose, and cognitively noisy. Good for parsers, bad for thinking. Markdown is better for thinking, reviewing, and revising. YAML frontmatter adds enough structure to keep the prompt controlled.

Once the spec stabilizes, convert to a strict machine format for code generation.

### Format Roles Under Human-in-the-Loop Conditions

**Structured Markdown**

- Best for: ideation, collaborative refinement, reviewing prompt/spec quality.
- Advantages: easiest to read, easiest to edit, low friction, good for discussing requirements.
- Disadvantages: too loose for direct code generation, weak field-level consistency, harder to validate automatically.
- Role in pipeline: good at the beginning, weak at the end.

**XML**

- Best for: final structured spec, downstream agent execution, code generation, validation.
- Advantages: deterministic, parseable, schema-enforceable, reliable for automation.
- Disadvantages: bad for early collaborative drafting, visually noisy, cumbersome to edit manually.
- Role in pipeline: bad at the beginning, best at the end.

**YAML Frontmatter + Markdown Body**

- Best for: human review plus moderate structure, prompt authoring, spec drafting before codegen.
- Advantages: clear metadata at top, readable body below, balances machine structure with human usability, supports progressive formalization.
- Disadvantages: markdown body can still drift, not fully deterministic, YAML syntax can break.
- Role in pipeline: best compromise at the beginning and middle.

**Flexible / Agent-Dependent**

- Best for: experimentation only.
- Advantages: adaptable.
- Disadvantages: not reproducible, not scalable, creates format drift across stages.
- Role in pipeline: bad default.

---

## Recommended Architecture

For human-in-the-loop at the beginning, use YAML frontmatter + Markdown first, then convert to XML for the final spec-to-code step. This is the strongest architecture.

```
human ideas / codebase / docs
    ↓
meta-prompt
    ↓
YAML + Markdown prompt
    ↓
human review / edits
    ↓
YAML + Markdown spec draft
    ↓
formalization step
    ↓
XML spec
    ↓
code generation
```

### Decision Rule

- If humans still need to inspect and rewrite → YAML + Markdown.
- If the artifact is finalized and must drive generation reliably → XML.

### Bottom Line

For this system, YAML frontmatter + Markdown is best at the beginning. For the full end-to-end pipeline, hybrid is best: YAML + Markdown for meta-prompt and prompt, XML for final executable spec.

This is why the meta-prompt-generator skill outputs YAML+Markdown specs and includes `yaml-to-xml-mapping.md` as a reference for the conversion step.

---

## Practical Summary

For AI skill generation pipelines:

- **Best balance:** YAML frontmatter + Markdown body
- **Most deterministic for agents:** XML
- **Best for human design iteration:** Structured Markdown
- **Worst for reproducibility:** Flexible formats
