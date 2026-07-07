# TASK-TREE-METADATA-HYGIENE: reconcile stale task-tree file metadata

## Metadata

- Tree ID: `TASK-TREE-METADATA-HYGIENE`
- Status: `active` (created 2026-07-07 from the user-requested open-task-tree audit)
- Roadmap lane: `Overall roadmap - durable architecture / task-tree hygiene`
- Created: `2026-07-07`
- Last updated: `2026-07-07` (`.0` done; frontier `.1`)
- Owner: repo-local workflow

## Goal

Keep the central task-tree index, per-task metadata, current-frontier sections, and continuity docs aligned so
agents can determine the true open/closed task state without re-auditing old task files.

## Non-Goals

- Touching parser/runtime/source behavior.
- Reopening completed implementation work.
- Changing the priority of explicitly deferred or paused leaves.
- Updating the public mdBook unless a later cleanup leaf discovers user-facing behavior drift.

## Acceptance Criteria

- The user-requested audit of non-closed task trees is durably recorded.
- Stale top-level task metadata is reconciled or explicitly classified.
- Stale `Current Frontier`, verification, and commit rows in completed task files are reconciled or explicitly
  classified.
- `MEMORY.md`, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `LIVE_ACHIEVEMENT_STATUS.md` identify the active owner and
  next leaf.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `TASK-TREE-METADATA-HYGIENE`
  Status: `active`
  Goal: Reconcile stale task-tree metadata found during the 2026-07-07 bootstrap/open-tree audit.
  Children: `.0`, `.1`, `.2`, `.3`

- ID: `TASK-TREE-METADATA-HYGIENE.0`
  Status: `done`
  Goal: Capture and register the open-task-tree audit finding before any cleanup edits.
  Acceptance: This file exists, is registered in `docs/TASK_TREE.md`, and records both the authoritative non-closed
    tree inventory and the stale per-file metadata candidates found during the audit. Tracking-only: no old task
    file is modified in this leaf.
  Verification: Done - read-only audit of `docs/TASK_TREE.md`, active task files, `MEMORY.md`, and focused
    `rg`/`sed` scans over stale metadata candidates. Closeout checks: `bash scripts/check_memory_architecture.sh`,
    `bash scripts/check_doctrines.sh`, and `git diff --check` all pass.
  Commit: `TASK-TREE-METADATA-HYGIENE.0 - own task-tree metadata audit` (see Commit Log)

- ID: `TASK-TREE-METADATA-HYGIENE.1`
  Status: `pending`
  Goal: Reconcile top-level task metadata that still says active while the body says done or exhausted.
  Acceptance: `docs/tasks/FLUENT-BLOCK-EQUIVALENCE.md`, `docs/tasks/MEDIUM-IMPACT.md`, and
    `docs/tasks/PHASE0-BACKHALF-TRIAGE.md` no longer contradict their own internal status/body text. Any surviving
    `active` wording is justified by an explicit live frontier or an explicit deferral.
  Verification: `pending`
  Commit: `pending`

- ID: `TASK-TREE-METADATA-HYGIENE.2`
  Status: `pending`
  Goal: Reconcile stale current-frontier/verification rows in completed or completed-like task trees.
  Acceptance: The following candidates are corrected or explicitly classified:
    `COMPAT-ALIAS-TEST-CLEANUP.md`, `LIFECYCLE-FAMILY-AUDIT.md`, `LINKEDSPEC-LOW-EFFORT.md`,
    `RGX-BRANCH-TRACKING.md`, `PHASE8-MULTI-BACKEND-HANDOFF.md`,
    `COMPAT-ALIAS-RETIREMENT-V2.md`. `COMPAT-ALIAS-RETIREMENT.md` and `NONCORE-QUARANTINE.md` are classified as
    explicit deferred/non-goal cases before any edit.
  Verification: `pending`
  Commit: `pending`

- ID: `TASK-TREE-METADATA-HYGIENE.3`
  Status: `pending` (deferred until `.1` and `.2` reveal the stable invariant)
  Goal: Decide whether to add a lightweight doctrine/check for stale task-tree metadata.
  Acceptance: Either a focused check is added to the doctrine registry with low false-positive risk, or the tree
    records why a manual audit is the safer policy for now.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TASK-TREE-METADATA-HYGIENE.1` | `pending` | Top-level metadata contradictions are the highest-risk drift because they can make a completed tree look live. |
| 2 | `TASK-TREE-METADATA-HYGIENE.2` | `pending` | Stale frontier rows are next; they are noisier but mostly within already completed task files. |
| - | `TASK-TREE-METADATA-HYGIENE.3` | `pending` (deferred) | Gate design should wait until `.1`/`.2` show the real invariant and false-positive risk. |

## Decisions

- `2026-07-07`: The authoritative live non-closed inventory comes from `docs/TASK_TREE.md` plus `MEMORY.md`, not
  isolated stale rows inside old task files. Current live non-closed rows are:
  `SPEC-FORMAT-TERSE` (active but no PNT-eligible leaf; deferred `.10`, `.12`, `.13`, `.14`),
  `STAGED-LINKED-PARSING` (active metadata; prototype complete; frontier empty),
  `DOCTRINE-ENFORCEMENT-ADOPT` (`.3` pending deferred),
  `SPEC-LANG-REFERENCE` (paused scorch leaves `.10.5.5` through `.10.5.19`), and
  `ROADMAP-DRIFT-RECONCILE` (`.1`/`.2` pending deferred).
- `2026-07-07`: The audit found stale per-file metadata that should be reconciled under this tree, not edited
  opportunistically during bootstrap. Three files have top metadata that still says active while internal text says
  done/exhausted: `FLUENT-BLOCK-EQUIVALENCE.md`, `MEDIUM-IMPACT.md`, and `PHASE0-BACKHALF-TRIAGE.md`.
- `2026-07-07`: Several completed or completed-like trees have stale frontier/verification/commit rows that can
  mislead automated or human readers: `COMPAT-ALIAS-TEST-CLEANUP.md`, `LIFECYCLE-FAMILY-AUDIT.md`,
  `LINKEDSPEC-LOW-EFFORT.md`, `RGX-BRANCH-TRACKING.md`, `PHASE8-MULTI-BACKEND-HANDOFF.md`, and
  `COMPAT-ALIAS-RETIREMENT-V2.md`. `COMPAT-ALIAS-RETIREMENT.md` and `NONCORE-QUARANTINE.md` appear to include
  explicit deferred/non-goal leaves and must be classified carefully before any edit.

## Open Questions

- None blocking `.1`. The `.3` gate design question is intentionally deferred until the cleanup leaves clarify the
  stable checkable pattern.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-07` | `TASK-TREE-METADATA-HYGIENE.0` | Read-only audit of central index, active task files, and stale metadata candidates; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `git diff --check` | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `TASK-TREE-METADATA-HYGIENE.0` | `TASK-TREE-METADATA-HYGIENE.0 - own task-tree metadata audit` | Tracking-only owner for the user-requested open-task-tree audit finding. |

## Changelog

- `2026-07-07`: Created task tree to own stale task-tree metadata found during the user-requested audit of
  non-closed task trees. `.0` records the finding only; `.1` and `.2` own cleanup leaves; `.3` owns the future
  gate decision.
