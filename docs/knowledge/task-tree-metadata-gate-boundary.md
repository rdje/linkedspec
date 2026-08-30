---
id: task-tree-metadata-gate-boundary
title: "Task-tree metadata gate checks completed frontiers and narrow pending-node evidence contradictions"
answers:
  - "what does the TASK-TREE-METADATA doctrine check enforce"
  - "does the task-tree metadata gate scan historical changelog prose"
  - "does the task-tree metadata gate require old commit fields to be backfilled"
  - "why is the task-tree metadata check narrow"
  - "which script checks stale Current Frontier rows"
  - "can a pending task node claim task tree first activation"
  - "can a pending task node name another leaf as its commit"
date: 2026-07-08
status: current
tags: [task-trees, doctrine-enforcement, metadata-hygiene]
evidence: "TASK-TREE-METADATA-HYGIENE.3 originally adopted the completed-tree Current Frontier invariant. FUTURE-PARITY-BACKLOG.24.0.1 later proves two cross-slice patches contaminated pending .2 with an activation claim and a foreign same-tree commit id. scripts/check_task_tree_metadata.sh now retains the original invariant and adds only those two pending-node contradictions, with four in-memory self-test fixtures. scripts/check_doctrines.sh and DOCTRINE_ENFORCEMENT.md §10 remain the registry and human mirror."
evidence_update_2026_08_30: "FUTURE-PARITY-BACKLOG.22.2 composes scripts/check_task_tree_current_ids.pl after the strict partition checker. The repository now has 1,718 exact definitions / 1,718 unique current IDs across 96 current task files; only one tracked-index-registered immutable history path is excluded. Ten mutations reject same-file, cross-file, and partitioned/unpartitioned duplicates and guard exact-line, closed-index-registry, plus history-registration boundaries."
reverify: "bash scripts/check_task_tree_metadata.sh && rg -n 'TASK-TREE-METADATA|check_task_tree_metadata' scripts/check_doctrines.sh DOCTRINE_ENFORCEMENT.md docs/tasks/TASK-TREE-METADATA-HYGIENE.md"
---

`TASK-TREE-METADATA-HYGIENE.3` originally added a narrow structural doctrine check:
`scripts/check_task_tree_metadata.sh`. The check reads task files under
`docs/tasks/`, selects only files whose top-level metadata status is
`done`, `completed`, or `exhausted`, and inspects only the status cell in the
`## Current Frontier` table. It fails if such a completed tree advertises a
live frontier status: `pending`, `active`, `in_progress`, or `blocked`.

The check is intentionally not a broad historical cleanup gate. It does not
scan changelog prose, does not require old per-leaf `Commit:` fields to be
backfilled, and does not judge explicitly active or deferred trees. The narrower
boundary was chosen because exploratory scans found substantial legacy metadata
debt outside the current-frontier invariant; gating all of it would create
false positives and unrelated cleanup pressure.

`FUTURE-PARITY-BACKLOG.24.0.1` later extends that same low-noise boundary after Git proved two broad-context patch
errors in a pending node. A pending node now fails if its `Verification:` says it was “activated task-tree-first,”
because activation and pending status contradict each other, or if its `Commit:` names a different node from the
same tree, because that field cannot be another slice's completion identity. The checker still permits historical
verification prose, ordinary dependency references, missing legacy fields, explicit supersession/replacement, and
all other previously excluded historical debt. Four in-memory fixtures prove ordinary pending and superseded forms
pass while each exact contradiction fails.

`FUTURE-PARITY-BACKLOG.22.2` adds one independent low-noise invariant to the same doctrine: every exact current
task ID is repository-wide unique across partitioned and unpartitioned storage. Only history paths registered by a
tracked task-tree index as immutable parts are outside the current census; unregistered history-named files remain
current. See [[current-task-id-uniqueness]] for the Git-proven duplicate root cause and mutation boundary.
