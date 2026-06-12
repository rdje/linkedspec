# LINKEDSPEC-LOW-EFFORT: Low-Effort LinkedSpec Improvements

## Metadata

- Tree ID: `LINKEDSPEC-LOW-EFFORT`
- Status: `active`
- Roadmap lane: `Overall roadmap`
- Created: `2026-06-12`
- Last updated: `2026-06-12`
- Owner: repo-local workflow

## Goal

Three low-effort, high-signal improvements: sweep for remaining deleted-.plg test references, automate commit-workflow MEMORY.md regeneration via post-commit hook, and backfill the book with the accumulator convention audit conclusion.

## Non-Goals

- Adding new DSL features.
- Changing the plugin infrastructure.
- Full test suite restructuring (done in LINKEDSPEC-ENHANCEMENTS.3).

## Acceptance Criteria

- .1: Zero `slurp()` calls in phase0_regression.t reference deleted `.plg` files. Phase0 1005 PASS.
- .2: `.githooks/post-commit` regenerates MEMORY.md current-state block from `git log` + task-tree frontiers. Hook is tested and working.
- .3: Book `value-container-flow-helper-reference.md` (or appropriate chapter) documents the accumulator convention (`push(Child)` is idiomatic, `push_value` preferred, 95.5% explicit). USER_GUIDE cross-reference updated.
- Each leaf committed through `COMMIT.md`.

## Task Tree

- ID: `LINKEDSPEC-LOW-EFFORT`
  Status: `active`
  Goal: `Sweep deleted-.plg references, automate commit workflow, backfill accumulator docs.`
  Children: `LINKEDSPEC-LOW-EFFORT.1`, `LINKEDSPEC-LOW-EFFORT.2`, `LINKEDSPEC-LOW-EFFORT.3`

- ID: `LINKEDSPEC-LOW-EFFORT.1`
  Status: `pending`
  Goal: `Sweep all slurp() calls in phase0_regression.t for references to deleted .plg files. Fix any remaining stale references.`
  Acceptance: `Every slurp() call referencing a plugin/ path targets an existing file. Phase0 1005 PASS.`
  Verification: `pending`
  Commit: `pending`

- ID: `LINKEDSPEC-LOW-EFFORT.2`
  Status: `pending`
  Goal: `Automate MEMORY.md current-state regeneration. Add post-commit hook (or update existing) that derives latest_commit, active_work_unit, next_action from git log + task-tree frontiers + git status.`
  Acceptance: `After a commit, MEMORY.md current-state block is automatically correct. Manual drift (like the stale hash found this session) becomes impossible. Hook is tested with a dummy commit.`
  Verification: `pending`
  Commit: `pending`

- ID: `LINKEDSPEC-LOW-EFFORT.3`
  Status: `pending`
  Goal: `Backfill accumulator convention documentation in the book. Cover: push(Child) is idiomatic convention, push_value is preferred explicit form, 95.5% of accumulator ops already explicit, only 3 specs use convention-based push. Cross-reference from USER_GUIDE.`
  Acceptance: `Book has a clear section explaining when to use push_value vs push(Child). USER_GUIDE links to it. ACCUMULATOR-CONVENTION-AUDIT conclusion is user-visible.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `LINKEDSPEC-LOW-EFFORT.1` | `pending` | Test cleanup: lowest risk, mechanical sweep. |
| 2 | `LINKEDSPEC-LOW-EFFORT.2` | `pending` | Commit hook: prevents future drift. |
| 3 | `LINKEDSPEC-LOW-EFFORT.3` | `pending` | Book backfill: closes audit loop. |

## Decisions

- `2026-06-12`: Created task tree. Ordered by dependency: cleanup first (may touch test file), hook second (touches .githooks), book last (touches docs only).

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `pending` | `pending` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `LINKEDSPEC-LOW-EFFORT.1` | `pending` | — |
| `LINKEDSPEC-LOW-EFFORT.2` | `pending` | — |
| `LINKEDSPEC-LOW-EFFORT.3` | `pending` | — |

## Changelog

- `2026-06-12`: Created task tree with 3 leaves.
