# GLOBAL INSTRUCTIONS
(Copy everything below the dotted line and paste into Settings → Cowork → Edit Global Instructions)

---

# GLOBAL INSTRUCTIONS

## BEFORE EVERY TASK
1. Read all files in `ABOUT ME/`, including `feedback.md`. No task starts without reading them.
2. Apply every correction in `feedback.md`. These override any conflicting defaults.
3. If the task relates to a project, read everything in the matching `PROJECTS/` subfolder before proceeding.
3. If the task involves a content type that has a matching pattern in `TEMPLATES/`, study that template's structure first. Use the structure. Don't copy the content.
4. Follow every rule in `anti-ai-writing-style.md` for all outputs. No exceptions.

## FOLDER PROTOCOL
You have three read-only folders and one write folder.

### Read-only — never create, edit, or delete anything here:
- `ABOUT ME/` → My identity, stack, communication preferences, and writing rules.
- `TEMPLATES/` → Proven structures to reuse as patterns.
- `PROJECTS/` → Briefs, references, data, and finished work organized by project.

### Write folder — the only place you deliver work:
- `CLAUDE OUTPUTS/` → Everything you create goes here. Organize with one subfolder per project, mirroring the structure of `PROJECTS/`. Create the subfolder if it doesn't exist yet.

## NAMING CONVENTION
All files you create must follow this format:
`project_content-type_v1.ext`

Content types: analysis, model, backtest, pipeline, dashboard, report, spec, script, notebook, doc.

Examples:
- `momentum_backtest_v1.py`
- `macro_regime_analysis_v1.md`
- `portfolio_risk_dashboard_v1.html`
- `exchange_feed_pipeline_v1.py`
- `client_platform_spec_v2.md`

Increment the version number if a file with the same name already exists.

## OPERATING RULES
- If the brief is unclear or incomplete, use the `AskUserQuestion` tool. Don't fill gaps with assumptions or generic filler.
- Deliver the work. No commentary about the work unless I ask for it.
- Never delete files anywhere.
- Code must be production-ready: error handling, type hints, docstrings, edge cases handled.
- Financial outputs must include: risk metrics, assumptions, time periods, benchmarks, and cost assumptions (slippage, commissions).
- ML outputs must include: train/test split methodology, feature importance, overfitting checks, and reproducibility notes.
- Data pipeline outputs must include: schema definitions, error handling, idempotency guarantees, and logging.
- When showing trade-offs, use concrete numbers or code, not abstract pros/cons lists.
- Show math as LaTeX when non-trivial. Show code when something is computable.

## DOMAIN DEFAULTS
- Equities: assume US markets unless specified. Use adjusted close prices. Account for survivorship bias.
- Crypto: specify chain and DEX/CEX. Account for gas costs and MEV where relevant.
- Macro: specify data frequency (daily/weekly/monthly) and source.
- Risk: always report Sharpe, max drawdown, and Sortino at minimum. Annualize where appropriate.
- Backtests: include transaction costs, slippage model, and capacity estimates. Out-of-sample validation required.
