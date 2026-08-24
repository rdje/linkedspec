---
id: future-parity-task-partition-contract
title: Future parity task evidence has stable ID lookup over bounded semantic parts
answers:
  - where does a FUTURE-PARITY-BACKLOG stable task id live
  - how do I retrieve one future parity task without scanning the task collection
  - how do I update the future parity task partition index after editing a task
  - may I append new evidence to FUTURE-PARITY-BACKLOG history
  - how is the old future parity monolith preserved after partitioning
  - how many stable future parity task ids survived the partition
  - which machine consumers moved off FUTURE-PARITY-BACKLOG.md
  - why did the first future task consumer audit miss five executable checkers
  - what enforces future parity task partition bounds and digests
  - what is the clean source identity for the future parity partition
date: 2026-08-09
status: accepted under LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2; eighth semantic member implemented under FUTURE-PARITY-PARTITION-CAPACITY.1
tags: [task-tree, partition, retrieval, continuity, routing, doctrine]
evidence: "Clean 99fe03f3:docs/tasks/FUTURE-PARITY-BACKLOG.md is 26,979 lines / 2,720,175 bytes, blob f3b59f72..., SHA-256 48de44a5.... Exact source ranges now route once into a bounded root, eight mutable semantic parts, and one byte-exact 3,340-line immutable history part. The strict ten-record schema-v1 index preserves 547 unique stable IDs. Nine executable and two JSON consumers use bounded owners; capability exclusion reads all eight semantic parts. The initial audit history remains preserved, while the current metadata gate guards all consumers, passes 27/27 mutations, and proves the task collection remains within 128 files / 80,000 lines / 8 MiB."
last_verified: 2026-08-18
reverify:
  - "bash scripts/check_task_tree_metadata.sh"
  - "perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.3.1.1"
  - "sed -n '1,10p' docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl"
  - "rg -n 'docs/tasks/FUTURE-PARITY-BACKLOG\\.md' capability_conformance/*.json tools/check_*"
  - "sed -n '1,220p' docs/decisions/0068-future-parity-task-partitions.md"
---

# Stable task identity no longer requires one unbounded file

`docs/tasks/FUTURE-PARITY-BACKLOG.md` is the bounded current root and navigation surface. Resolve any stable leaf
with `perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id <stable-id>`; the tool derives the repository
root from its own path and prints the one bounded mutable semantic owner. After editing that owner, run
`perl tools/update_task_tree_index.pl --tree FUTURE-PARITY-BACKLOG` in the same slice so current counts and the
content digest remain exact.

The index separately retains clean-source provenance and same-commit current-file snapshots. Every clean source
line is accounted exactly once by root provenance, the eight semantic parts, or
`docs/tasks/FUTURE-PARITY-BACKLOG.history.md`. The history part is immutable positive evidence: never append new
task verification, commit, or changelog records there. Those records belong beside their stable ID in the mutable
semantic part returned by lookup.

Capability exclusion reads all eight semantic parts for its full task census and `.15-.24` for its public
projection. Repeated action reads `.09` plus the `.10.0-.6` handoff; root selection reads `.09`; semantic
introspection reads `.10.0-.6` for implementation ownership and `.10.7-.10` for its public projection. The
Generated source, native resolution, logical helpers, and diagnostic output also read `.00-08`; duplicate-slot
identity reads `.09`. The partition checker rejects restoration of the old monolith path in all eleven scopes.
