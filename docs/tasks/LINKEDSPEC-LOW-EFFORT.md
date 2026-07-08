# LINKEDSPEC-LOW-EFFORT: Low-Effort LinkedSpec Improvements

## Metadata

- Tree ID: `LINKEDSPEC-LOW-EFFORT`
- Status: `done`
- Roadmap lane: `Overall roadmap`
- Created: `2026-06-12`
- Last updated: `2026-06-12`
- Owner: repo-local workflow

## Goal

Three low-effort, high-signal improvements: sweep for remaining deleted-.plg test references, add commit-workflow
MEMORY.md verification via post-commit hook, and backfill the book with the accumulator convention audit conclusion.

## Non-Goals

- Adding new DSL features.
- Changing the plugin infrastructure.
- Full test suite restructuring (done in LINKEDSPEC-ENHANCEMENTS.3).

## Acceptance Criteria

- .1: Zero `slurp()` calls in phase0_regression.t reference deleted `.plg` files. Phase0 1005 PASS.
- .2: `.githooks/post-commit` verifies the MEMORY.md current-state pointer after commits and warns on drift.
- .3: Book `value-container-flow-helper-reference.md` (or appropriate chapter) documents the accumulator convention (`push(Child)` is idiomatic, `push_value` preferred, 95.5% explicit). USER_GUIDE cross-reference updated.
- Each leaf committed through `COMMIT.md`.

## Task Tree

- ID: `LINKEDSPEC-LOW-EFFORT`
  Status: `done`
  Goal: `Sweep deleted-.plg references, automate commit workflow, backfill accumulator docs.`
  Children: `LINKEDSPEC-LOW-EFFORT.1`, `LINKEDSPEC-LOW-EFFORT.2`, `LINKEDSPEC-LOW-EFFORT.3`

- ID: `LINKEDSPEC-LOW-EFFORT.1`
  Status: `done`
  Goal: `Sweep all slurp() calls in phase0_regression.t for references to deleted .plg files. Fix any remaining stale references.`
  Acceptance: `Every slurp() call referencing a plugin/ path targets an existing file. Phase0 1005 PASS.`
  Verification: `classified complete by TASK-TREE-METADATA-HYGIENE.2; central index marks all three leaves complete`
  Commit: `not backfilled in this file; classified stale metadata by TASK-TREE-METADATA-HYGIENE.2`

- ID: `LINKEDSPEC-LOW-EFFORT.2`
  Status: `done` (verification-only hook; auto-regeneration wording superseded)
  Goal: `Add post-commit verification for the MEMORY.md current-state pointer.`
  Acceptance: `After a commit, .githooks/post-commit checks whether MEMORY.md latest_commit contains the current HEAD hash and emits a soft warning on drift. The hook does not rewrite MEMORY.md automatically.`
  Verification: `classified by TASK-TREE-METADATA-HYGIENE.2 from .githooks/post-commit: the hook is verification-only and warns when latest_commit lacks a parseable hash`
  Commit: `not backfilled in this file; classified stale metadata by TASK-TREE-METADATA-HYGIENE.2`

- ID: `LINKEDSPEC-LOW-EFFORT.3`
  Status: `done`
  Goal: `Backfill accumulator convention documentation in the book. Cover: push(Child) is idiomatic convention, push_value is preferred explicit form, 95.5% of accumulator ops already explicit, only 3 specs use convention-based push. Cross-reference from USER_GUIDE.`
  Acceptance: `Book has a clear section explaining when to use push_value vs push(Child). USER_GUIDE links to it. ACCUMULATOR-CONVENTION-AUDIT conclusion is user-visible.`
  Verification: `classified complete by TASK-TREE-METADATA-HYGIENE.2; central index marks all three leaves complete`
  Commit: `not backfilled in this file; classified stale metadata by TASK-TREE-METADATA-HYGIENE.2`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `LINKEDSPEC-LOW-EFFORT.1` | `done` | Test sweep completed. |
| 2 | `LINKEDSPEC-LOW-EFFORT.2` | `done` | Post-commit MEMORY verification hook active; automatic rewriting is not current behavior. |
| 3 | `LINKEDSPEC-LOW-EFFORT.3` | `done` | Accumulator book backfill completed. |

## Decisions

- `2026-06-12`: Created task tree. Ordered by dependency: cleanup first (may touch test file), hook second (touches .githooks), book last (touches docs only).

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-07` | `LINKEDSPEC-LOW-EFFORT.1` | Classified from central index during `TASK-TREE-METADATA-HYGIENE.2` | COMPLETE; historical command detail not backfilled here |
| `2026-07-07` | `LINKEDSPEC-LOW-EFFORT.2` | `.githooks/post-commit` source read | Hook is verification-only and emits soft warnings on MEMORY hash drift; auto-regeneration wording superseded |
| `2026-07-07` | `LINKEDSPEC-LOW-EFFORT.3` | Classified from central index during `TASK-TREE-METADATA-HYGIENE.2` | COMPLETE; historical command detail not backfilled here |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `LINKEDSPEC-LOW-EFFORT.1` | not backfilled | Classified stale commit metadata by `TASK-TREE-METADATA-HYGIENE.2`. |
| `LINKEDSPEC-LOW-EFFORT.2` | not backfilled | Classified stale commit metadata by `TASK-TREE-METADATA-HYGIENE.2`. |
| `LINKEDSPEC-LOW-EFFORT.3` | not backfilled | Classified stale commit metadata by `TASK-TREE-METADATA-HYGIENE.2`. |

## Changelog

- `2026-06-12`: Created task tree with 3 leaves.
- `2026-07-07`: `TASK-TREE-METADATA-HYGIENE.2` reconciled stale frontier, verification, and commit rows against
  the central completed-tree index. The post-commit hook wording was corrected to match the current implementation:
  verification-only soft warning, not automatic MEMORY.md rewriting.
