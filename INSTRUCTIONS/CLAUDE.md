# CLAUDE.md

@AGENTS.md

## Behavior

### 1. Think Before Coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

Touch only what you must. Clean up only your own mess.

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

Frame every task as a verifiable outcome, not an open-ended activity.

Before starting, answer: "How will I know this is done?" If the answer is vague, sharpen it. "Add validation" becomes "invalid inputs are rejected with typed errors." "Fix the bug" becomes "the specific failure case no longer reproduces." "Refactor X" becomes "behavior is identical, structure is improved."

The goal defines the work. If you can't state the success condition, you don't understand the task yet — go back to §1.

---

These guidelines are working if: fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Mistakes Log

[REPLACE] Add entries as they accumulate. One per line, dated.
[REPLACE] Example:
[REPLACE] - [2025-01-15] Used `any` type when strict types were available. Always use specific types.
[REPLACE] - [2025-01-20] Forgot to run tests before committing. Always verify before commit.
