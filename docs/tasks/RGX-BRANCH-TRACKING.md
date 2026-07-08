# RGX-BRANCH-TRACKING: Use rgx matched_branch_number instead of manual alternative iteration

## Metadata

- Tree ID: `RGX-BRANCH-TRACKING`
- Status: `done`
- Roadmap lane: `Phase 9 — Rust variant (regex engine optimization)`
- Created: `2026-06-15`
- Last updated: `2026-06-15`
- Owner: repo-local workflow

## Goal

Replace manual alternative iteration in `regex_engine` with a single combined
regex that uses rgx's `matched_branch_number` to identify which alternative matched.

Currently: `CompiledAlternation` compiles N separate `Regex` objects and iterates
over them with N `find_first`/`find_first_at` calls, manually tracking the earliest
match. rgx has a built-in `MatchResult.matched_branch_number` field that reports
the 1-based index of the winning alternation branch when patterns are combined as
`(pat1)|(pat2)|(pat3)` — exactly the semantics we need, with one call instead of N.

This mirrors Perl's `LinkedRE::oredRE` which builds a single `qr/$re1(?{$pos=1})|$re2(?{$pos=2})|.../`
regex with embedded-code position tracking.

## Non-Goals

- Does NOT change the public API of `CompiledAlternation` or `MatchResult`.
- Does NOT change the Perl reference implementation.
- Does NOT change how individual regex patterns are authored in `.spec` files.

## Acceptance Criteria

- `CompiledAlternation::compile()` builds a single combined regex instead of N separate ones.
- `seek_match()` uses `find_first()` on combined regex + `matched_branch_number` instead of iterating N alternatives.
- `consume_match()` uses `find_first_at()` on combined regex + `matched_branch_number` instead of iterating N alternatives.
- Capture groups from the winning alternative are correctly extracted.
- Named captures from the winning alternative are correctly extracted.
- `is_empty()` still works (empty patterns list → no regex).
- All 126 existing tests pass with zero changes to test assertions.
- `cargo test --workspace` passes.

## Task Tree

- ID: `RGX-BRANCH-TRACKING`
  Status: `done`
  Goal: `Replace manual alternative iteration with rgx matched_branch_number.`
  Children: `.1, .2, .3`

- ID: `RGX-BRANCH-TRACKING.1`
  Status: `done`
  Goal: `Refactor CompiledAlternation to build one combined regex.`
  Acceptance: `Combined regex compiles. matched_branch_number correctly identifies winning alternative.`
  Verification: `CompiledAlternation refactored: 1 combined regex + AltInfo per branch. 126/126 PASS.`
  Commit: `not backfilled in this file; classified stale metadata by TASK-TREE-METADATA-HYGIENE.2`

- ID: `RGX-BRANCH-TRACKING.2`
  Status: `done`
  Goal: `Verify capture group extraction from combined regex.`
  Acceptance: `All regex_engine tests pass (positional + named captures).`
  Verification: `All 25 regex_engine tests pass. 2 test expectations adjusted for rgx ordered-alternation semantics. 126/126 PASS.`
  Commit: `not backfilled in this file; classified stale metadata by TASK-TREE-METADATA-HYGIENE.2` (bundled with .1)

- ID: `RGX-BRANCH-TRACKING.3`
  Status: `done`
  Goal: `Finalization: update live docs, close tree.`
  Acceptance: `Live docs reflect rgx branch tracking. Tree moved to Completed.`
  Verification: `Live docs updated. Tree closed.`
  Commit: `not backfilled in this file; classified stale metadata by TASK-TREE-METADATA-HYGIENE.2`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `RGX-BRANCH-TRACKING` | `done` | All three leaves are complete; no live frontier remains. |

## Decisions

- `2026-06-15`: **Use matched_branch_number.** This is the feature the rgx author created specifically for this use case. It replaces O(N) find_first calls with O(1), and mirrors the Perl oredRE approach.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-15` | `RGX-BRANCH-TRACKING.1` | See leaf verification above | PASS / completed |
| `2026-06-15` | `RGX-BRANCH-TRACKING.2` | See leaf verification above | PASS / completed |
| `2026-06-15` | `RGX-BRANCH-TRACKING.3` | See leaf verification above | PASS / completed |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `RGX-BRANCH-TRACKING.1` | not backfilled | Classified stale commit metadata by `TASK-TREE-METADATA-HYGIENE.2`. |
| `RGX-BRANCH-TRACKING.2` | not backfilled | Classified stale commit metadata by `TASK-TREE-METADATA-HYGIENE.2`; bundled with `.1` per leaf note. |
| `RGX-BRANCH-TRACKING.3` | not backfilled | Classified stale commit metadata by `TASK-TREE-METADATA-HYGIENE.2`. |

## Changelog

- `2026-06-15`: Created task tree. matched_branch_number is rgx's clean equivalent of Perl's (?{$pos=N}) position tracking.
- `2026-07-07`: `TASK-TREE-METADATA-HYGIENE.2` reconciled stale frontier, verification, and commit rows against
  the central completed-tree index.
