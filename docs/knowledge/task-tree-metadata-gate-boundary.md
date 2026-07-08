---
id: task-tree-metadata-gate-boundary
title: "Task-tree metadata gate checks completed-tree Current Frontier rows only"
answers:
  - "what does the TASK-TREE-METADATA doctrine check enforce"
  - "does the task-tree metadata gate scan historical changelog prose"
  - "does the task-tree metadata gate require old commit fields to be backfilled"
  - "why is the task-tree metadata check narrow"
  - "which script checks stale Current Frontier rows"
date: 2026-07-08
status: current
tags: [task-trees, doctrine-enforcement, metadata-hygiene]
evidence: "scripts/check_task_tree_metadata.sh; scripts/check_doctrines.sh; DOCTRINE_ENFORCEMENT.md §10; docs/tasks/TASK-TREE-METADATA-HYGIENE.md"
reverify: "bash scripts/check_task_tree_metadata.sh && rg -n 'TASK-TREE-METADATA|check_task_tree_metadata' scripts/check_doctrines.sh DOCTRINE_ENFORCEMENT.md docs/tasks/TASK-TREE-METADATA-HYGIENE.md"
---

`TASK-TREE-METADATA-HYGIENE.3` adds a narrow structural doctrine check:
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
