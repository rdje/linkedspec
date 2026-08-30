---
id: current-task-id-uniqueness
title: "Current task IDs are repository-wide unique across partitioned and unpartitioned storage"
answers:
  - "can two current task files define the same task id"
  - "does task id uniqueness apply across partitioned and unpartitioned task trees"
  - "why was RUST-FUNCTIONAL-PARITY.7 defined twice"
  - "which checker rejects duplicate current task ids"
  - "does a history filename bypass the current task id census"
  - "which task history files are excluded from current id uniqueness"
date: 2026-08-30
status: current
tags: [task-tree, metadata, doctrine, partitions, continuity, mutation-testing]
evidence: "FUTURE-PARITY-BACKLOG.22.2; scripts/check_task_tree_current_ids.pl; scripts/check_task_tree_metadata.sh; git show 0e43f4ae -- docs/tasks/RUST-FUNCTIONAL-PARITY.md"
reverify: "perl scripts/check_task_tree_current_ids.pl"
---

Every exact current task definition under `docs/tasks/*.md` participates in one repository-wide ID census,
regardless of whether its tree uses one file or bounded semantic partitions. The only exclusions are history paths
named by tracked task-tree indexes whose matching part records are explicitly immutable. A filename ending in
`.history.md` does not exclude itself.

The first global census found one defect: `RUST-FUNCTIONAL-PARITY.7` appeared as `active` and `done` in the same
legacy file. Git assigns the second block to finalization commit `0e43f4ae`, which inserted a completed parent
instead of updating the original parent. `FUTURE-PARITY-BACKLOG.22.2` collapses the adjacent pair into one
authoritative `done` parent at the same container position and preserves the event in Git history. The composed
`TASK-TREE-METADATA` doctrine now runs the global checker and its ten same-file, cross-file,
partitioned/unpartitioned, exact-line, closed-index-registry, and history-registration mutations.

Related: [[task-tree-metadata-gate-boundary]] and [[future-parity-task-partition-contract]].
