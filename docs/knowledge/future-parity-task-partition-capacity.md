---
id: future-parity-task-partition-capacity
title: Future parity task evidence needs an eighth bounded semantic member at Julia progressive dispatch
answers:
  - "why can Julia progressive span dispatch not be split yet"
  - "why is the FUTURE-PARITY-BACKLOG .14 task member saturated"
  - "where will FUTURE-PARITY-BACKLOG.14.6.5 live"
  - "how many future parity semantic task parts will exist after the capacity extension"
  - "does the future parity partition capacity fix raise task evidence limits"
  - "which consumers must change for the future parity .14.6.5 partition"
date: 2026-08-18
status: accepted plan under FUTURE-PARITY-PARTITION-CAPACITY.0; canonical implementation and recomposition pending
tags: [task-tree, partition, retrieval, routing, pressure, continuity, doctrine]
evidence: "At clean 3ccaf7c3, docs/tasks/FUTURE-PARITY-BACKLOG.14.md is exactly 5,000 lines / 544,542 bytes and still uniquely owns pending FUTURE-PARITY-BACKLOG.14.6.5. ADR 0084 preserves every pressure ceiling and splits at the first unstarted boundary: the old member will own .14 through .14.6.4, while new bounded member docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md will own .14.6.5-.14.8. Schema v1 remains; semantic members increase 7→8, total part records 8→9, and index records 9→10. Canonical implementation must atomically update the index, lookup/update/build tools, partition checker/mutations, root navigation, route registry, and capability all-parts census before Julia behavior planning resumes."
reverify:
  - "wc -lc docs/tasks/FUTURE-PARITY-BACKLOG.14.md docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl"
  - "perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.6.5"
  - "bash scripts/check_task_tree_metadata.sh"
  - "bash scripts/check_readme_stability.sh"
---

# The Julia frontier exposed a bounded-storage boundary

The stable-ID owner for `.14.6.5` is full at its deliberately strict 5,000-line ceiling. This is not a Julia
runtime defect and does not authorize a larger file. It is a partition-topology capacity defect discovered before
the required Julia task split, so `FUTURE-PARITY-PARTITION-CAPACITY` owns the repair first.

ADR `0084` adds one equally bounded mutable semantic member at the first unstarted boundary. The existing pending
`.14.6.5-.14.8` blocks move byte-for-byte; all completed `.14` through `.14.6.4.3` evidence stays in the original
member. Stable IDs remain unchanged and unique, immutable history remains untouched, aggregate limits remain
fixed, and lookup continues through the same repository-relative command.

The plan is not implementation evidence. Until canonical leaf `.1` updates and verifies every authority and
consumer, `.14.6.5` remains in the original owner and Julia task expansion remains blocked. Leaf `.2` then
independently recomposes the committed topology before returning the frontier to Julia.
