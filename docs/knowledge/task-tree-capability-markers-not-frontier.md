---
id: task-tree-capability-markers-not-frontier
title: "Canonical closed-capability markers must not live only in mutable task-frontier summaries"
answers:
  - "where should a canonical capability completion marker live in docs TASK_TREE"
  - "why did the logical helper checker lose its task tree completion marker"
  - "why can a later PNT update erase a public no-drift marker"
  - "what is the difference between a task frontier summary and a stable capability marker"
  - "how should checker-owned historical facts be recorded in docs TASK_TREE"
date: 2026-07-18
status: current
tags: [task-tree, doctrine, capability-conformance, public-no-drift, logical-helper, canonical-ci]
evidence: "During FUTURE-PARITY-BACKLOG.9.1.1.2.2.2, generated-source changes activated `tools/check_logical_helper_contract.py`. It found that required text `Logical helper parent .5.2 is closed at 8/0` was absent from `docs/TASK_TREE.md`. Git `-S` history showed the marker had originally lived only in the mutable `FUTURE-PARITY-BACKLOG` current-frontier table cell and was removed by later legitimate PNT frontier rewrites. The repair adds `Canonical Closed-Capability Markers` outside the mutable table. No logical-helper behavior or contract changed."
reverify: "bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py && rg -n 'Canonical Closed-Capability Markers|Logical helper parent' docs/TASK_TREE.md"
---

The active-tree table is overwrite-style live state: its current-frontier cells are expected to change after every
completed slice. A checker-owned historical completion fact cannot safely live only in one of those cells. Store
such text in a stable, explicitly named section or another canonical immutable-status document, while the table
continues to summarize only the current frontier.

This distinction prevents legitimate PNT updates from silently erasing public no-drift evidence. The logical-
helper marker loss was latent because canonical CI conditionally activates capability checkers based on changed
paths; a later generated-source slice activated the checker and surfaced the missing durable text.

Related: [[logical-helper-neutral-contract]] and [[task-tree-metadata-gate-boundary]].
