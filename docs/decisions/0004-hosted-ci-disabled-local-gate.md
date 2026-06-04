# 0004 — Hosted GitHub Actions CI is disabled; `tools/run_ci_local.sh` is the source of truth

- Date: 2026-06-04
- Status: accepted
- Tags: ci, environment

## Context

To preserve the account's included GitHub Actions minutes, hosted CI is intentionally
turned off. A future agent might otherwise "fix" the disabled workflow or assume server
CI runs on push — both wrong. The canonical gate runs locally.

## Decision

- The canonical regression/quality gate is `bash tools/run_ci_local.sh` (run from the
  repo root), which executes `perl -c`, the phase-0 regression suite
  (`t/phase0_regression.t`), repo-hygiene audits, and — once installed — the
  memory-architecture self-check (`scripts/check_memory_architecture.sh`).
- `.github/workflows/ci.yml` stays **tracked but guarded off** (`workflow_dispatch`
  only, job `if: false`). It exists so the local gate can audit that hosted CI, when
  re-enabled, delegates to the same repo-root script. Do not re-enable it without an
  explicit decision (supersede this record).
- Run the local gate before committing/pushing; it is the build's source of truth.

## Consequences

- "Green CI" means `tools/run_ci_local.sh` exits 0 locally, not a hosted run.
- The memory-architecture enforcement (E4) lives inside that same local gate, so it
  cannot be skipped by the normal workflow.

## Links

- `tools/run_ci_local.sh`, `.github/workflows/ci.yml`, `README.md` (Local CI).
- `MEMORY_ARCHITECTURE.md` §9 (enforcement), `docs/tasks/MEMORY-ARCHITECTURE-DOC.md`.
