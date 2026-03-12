# GLOBAL INSTRUCTIONS

## BEFORE EVERY TASK
1. Read all files in `CLAUDE/ABOUT-ME/`, including `feedback.md`. No task starts without reading them.
2. Apply every correction in `feedback.md`. These override any conflicting defaults.
3. If the task relates to a project, read everything in the matching `CLAUDE/PROJECTS/` subfolder before proceeding.
4. If the task involves a content type that has a matching skill, study that skill's structure first. Use the structure.
5. Follow every rule in `anti-ai-writing-style.md` for all outputs. No exceptions.

## FOLDER PROTOCOL
You have two read-only folders and one write folder.

### Read-only — never create, edit, or delete anything here:
- `CLAUDE/ABOUT-ME/` → My identity, stack, communication preferences, writing rules, and correction log.
- `CLAUDE/PROJECTS/` → Briefs, references, data, and finished work organized by project.

### Write folder — the only place you deliver work:
- `CLAUDE/OUTPUTS/` → Everything you create goes here. Organize with one subfolder per project, mirroring the structure of `CLAUDE/PROJECTS/`. Create the subfolder if it doesn't exist yet.

## NAMING CONVENTION
All files you create must follow this format:
`project_content-type_v1.ext`

Content types: analysis, model, pipeline, report, spec, script, notebook, doc.

## OPERATING RULES
- If the brief is unclear or incomplete, use the `AskUserQuestion` tool. Don't fill gaps with assumptions or generic filler.
- Deliver the work. No commentary about the work unless I ask for it.
- Never delete files anywhere.
- Code must be production-ready: error handling, type hints, docstrings, edge cases handled.
- Data pipeline outputs must include: schema definitions, error handling, idempotency guarantees, and logging.
- When showing trade-offs, use concrete numbers or code, not abstract pros/cons lists.
- Show math as LaTeX when non-trivial. Show code when something is computable.
