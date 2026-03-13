# AGENTS.md

## Commands

[REPLACE] Add your project's exact build, run, and setup commands.
[REPLACE] Example:
[REPLACE] - Monorepo managed with pnpm workspaces and Turborepo.
[REPLACE] - `pnpm install` — install all dependencies.
[REPLACE] - `pnpm dev` — start dev server.
[REPLACE] - `pnpm build` — production build.

## Testing

[REPLACE] Add your project's test, lint, and type-check commands.
[REPLACE] Example:
[REPLACE] - `pnpm test` — run full test suite.
[REPLACE] - `pnpm test <path>` — run a single test file.
[REPLACE] - `pnpm lint` — run ESLint.
[REPLACE] - `pnpm typecheck` — run TypeScript type checking.

## Architecture

[REPLACE] Add a brief map of your codebase (2-5 lines).
[REPLACE] Example:
[REPLACE] - `src/api/` — REST/GraphQL endpoints.
[REPLACE] - `src/core/` — business logic, domain models.
[REPLACE] - `src/db/` — database layer, migrations.
[REPLACE] - Dependency direction: core → domain → feature → app.

## Code style

[REPLACE] Add 2-5 concrete conventions with code snippets.
[REPLACE] Example:
[REPLACE] - Use TypeScript strict mode.
[REPLACE] - Prefer named exports over default exports.
[REPLACE] - Error handling: use typed errors, never bare catch.

## Git workflow

[REPLACE] Add your commit and branch naming conventions.
[REPLACE] Example:
[REPLACE] - Commit format: `type(scope): description`
[REPLACE] - Types: feat, fix, chore, docs, refactor, test.
[REPLACE] - Branch naming: `feature/description`, `fix/description`. GSD overrides branching during orchestrated execution.

## Boundaries

[REPLACE] Add explicit "never do X" instructions.
[REPLACE] Example:
[REPLACE] - Never commit `.env` or files containing secrets.
[REPLACE] - Never modify `migrations/` without explicit approval.
[REPLACE] - Never push directly to `main`.
[REPLACE] - Never delete or modify files in `vendor/` or `node_modules/`.
