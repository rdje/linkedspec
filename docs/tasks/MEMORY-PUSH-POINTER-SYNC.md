# MEMORY-PUSH-POINTER-SYNC: remove stale push-threshold claim from resume pointer

## Metadata

- Tree ID: `MEMORY-PUSH-POINTER-SYNC`
- Status: `done`
- Roadmap lane: `Overall roadmap - durable architecture / memory continuity`
- Created: `2026-07-08`
- Last updated: `2026-07-08` (`.1` done; tree complete)
- Owner: repo-local workflow

## Goal

Keep `MEMORY.md` resume guidance accurate after final status checks showed the branch is ahead 27, while the
resume pointer still said the branch was over the 300-commit push threshold.

## Non-Goals

- Changing push policy.
- Pushing the branch.
- Reworking the post-commit hook's soft `latest_commit` hash warning.
- Changing parser/runtime behavior or public mdBook content.

## Acceptance Criteria

- `MEMORY.md` no longer claims the branch is over the 300-commit threshold as a durable fact.
- The resume pointer still preserves the active push policy: do not push mid-PNT unless explicitly instructed or
  the threshold policy is deliberately invoked.
- Live docs record the continuity-only correction.
- Memory architecture, doctrine, task-tree metadata, and whitespace checks pass.
- The completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `MEMORY-PUSH-POINTER-SYNC`
  Status: `done`
  Goal: Remove stale branch-threshold wording from `MEMORY.md`.
  Children: `.1`

- ID: `MEMORY-PUSH-POINTER-SYNC.1`
  Status: `done`
  Goal: Replace the stale "branch is over 300" resume claim with policy-oriented guidance that remains valid
    across ordinary ahead-count changes.
  Acceptance: `MEMORY.md` no longer hardcodes the stale threshold state; focused scan passes; no parser/runtime or
    public-book behavior changes.
  Verification: Done - 2026-07-08. Focused scan confirms the stale threshold claim is gone; `git status -sb` was
    checked for the live ahead count; memory architecture, doctrine, task-tree metadata, and whitespace checks pass.
  Commit: `MEMORY-PUSH-POINTER-SYNC.1 - remove stale push threshold claim`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| - | _none_ | - | Tree complete; return to `docs/TASK_TREE.md` for the next PNT-eligible frontier. |

## Decisions

- `2026-07-08`: Treat the stale threshold sentence as a resume-pointer defect, not a push trigger. The policy
  remains "do not push mid-PNT unless explicitly instructed"; the threshold count should be checked from
  `git status -sb` when needed instead of fossilized in `MEMORY.md`.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- |
| `2026-07-08` | `MEMORY-PUSH-POINTER-SYNC.1` | Focused stale-threshold scan; `git status -sb`; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check` | PASS - resume pointer no longer hardcodes the stale threshold state |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `MEMORY-PUSH-POINTER-SYNC.1` | `MEMORY-PUSH-POINTER-SYNC.1 - remove stale push threshold claim` | Continuity-only memory pointer correction. |

## Changelog

- `2026-07-08`: Created task tree to own the stale push-threshold wording correction before editing `MEMORY.md`.
- `2026-07-08`: Completed `.1` by replacing the stale threshold-state sentence with policy-oriented push guidance.
