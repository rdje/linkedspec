# RUST-DIAGNOSTICS: Runtime diagnostics for unknown helpers and regex errors

## Metadata

- Tree ID: `RUST-DIAGNOSTICS`
- Status: `done`
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
  Status: `done`
  Goal: `Add runtime warning for unknown helper calls.`
  Acceptance: `Unknown helper emits warning to stderr. Existing tests pass.`
  Verification: `Unknown helper → eprintln warning with name + rule label. 126/126 PASS.`
  Commit: `6298d59`

- ID: `RUST-DIAGNOSTICS.2`
  Status: `done`
  Goal: `Add runtime warning for regex compile failures in filter_match and matches.`
  Acceptance: `Regex errors emit warning to stderr. Existing tests pass.`
  Verification: `filter_match/matches regex errors → eprintln warning with pattern + error. 126/126 PASS.`
  Commit: `6298d59` (bundled with .1)

- ID: `RUST-DIAGNOSTICS.3`
  Status: `done`
  Goal: `Finalization: update live docs, close tree.`
  Acceptance: `Live docs reflect runtime diagnostics. Tree moved to Completed.`
  Verification: `Live docs updated. Tree closed.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | — | — | Tree complete |

## Decisions

- `2026-06-15`: **Runtime warnings only.** Compile-time helper validation requires ActionIR infrastructure (like Perl's Diagnostics.pm). Runtime warnings are pragmatic and immediately useful.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-15` | `.1` | Unknown helper emits eprintln warning; 126/126 PASS | PASS |
| `2026-06-15` | `.2` | Regex errors in filter_match/matches emit warnings; 126/126 PASS | PASS |
| `2026-06-15` | `.3` | Live docs updated; tree closed | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `6298d59` — "Feat: RUST-DIAGNOSTICS.1/.2 — runtime warnings for silent failure paths" | Unknown helper + regex warnings |
| `.2` | (bundled with .1) | Regex error warnings |
| `.3` | `pending` | Live docs + finalization |

## Changelog

- `2026-06-15`: Created task tree.
- `2026-06-15`: **Closed.** All 3 leaves done. Three silent-failure paths now emit runtime warnings.

