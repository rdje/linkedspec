# RUST-DIAGNOSTICS: Runtime diagnostics for unknown helpers and regex errors

## Metadata

- Tree ID: `RUST-DIAGNOSTICS`
- Status: `active`
- Roadmap lane: `Phase 9 — Rust variant (engine quality)`
- Created: `2026-06-15`
- Last updated: `2026-06-15`
- Owner: repo-local workflow

## Goal

Improve runtime diagnostics in the Rust engine so spec authors get
actionable feedback when something goes wrong, instead of silent failure.

## Non-Goals

- Does NOT add compile-time ActionIR diagnostics (that requires ActionIR infrastructure).
- Does NOT change the Perl reference implementation.
- Does NOT add new DSL features.

## Acceptance Criteria

- Unknown helper calls emit a runtime warning via `eprintln!` (or equivalent).
- Regex compile failures in `filter_match`/`matches` emit a warning instead of silently returning empty/false.
- Existing tests continue to pass.
- `cargo test --workspace` passes.

## Task Tree

- ID: `RUST-DIAGNOSTICS`
  Status: `active`
  Goal: `Add runtime warnings for silent failure paths in the Rust engine.`
  Children: `.1, .2, .3`

- ID: `RUST-DIAGNOSTICS.1`
  Status: `pending`
  Goal: `Add runtime warning for unknown helper calls. Currently the _ => fallback in call_helper silently returns Undef. Emit eprintln!("warning: unknown helper '{}' — returning undef", name) so spec authors can detect typos.`
  Acceptance: `Unknown helper emits warning to stderr. Existing tests pass (no test expects warnings from valid helpers).`
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-DIAGNOSTICS.2`
  Status: `pending`
  Goal: `Add runtime warning for regex compile failures in filter_match and matches helpers. Currently they silently return empty array / false on regex compile error.`
  Acceptance: `Regex errors emit warning to stderr. Existing tests pass.`
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-DIAGNOSTICS.3`
  Status: `pending`
  Goal: `Finalization: update live docs, close tree.`
  Acceptance: `Live docs reflect runtime diagnostics. Tree moved to Completed.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `RUST-DIAGNOSTICS.1` | `pending` | Unknown helper warning — the biggest silent-failure gap |

## Decisions

- `2026-06-15`: **Runtime warnings only.** Compile-time helper validation requires ActionIR infrastructure (like Perl's Diagnostics.pm). Runtime warnings are pragmatic and immediately useful.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |

## Changelog

- `2026-06-15`: Created task tree. Unknown helpers silently returning undef is a concrete quality gap found during engine audit.
