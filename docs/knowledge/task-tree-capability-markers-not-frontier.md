---
id: task-tree-capability-markers-not-frontier
title: "Canonical closed-capability markers must not live only in mutable task-frontier summaries"
answers:
  - "where should a canonical capability completion marker live in docs TASK_TREE"
  - "why did the logical helper checker lose its task tree completion marker"
  - "why can a later PNT update erase a public no-drift marker"
  - "what is the difference between a task frontier summary and a stable capability marker"
  - "how should checker-owned historical facts be recorded in docs TASK_TREE"
  - "where is the capability exclusion public closeout 24.2 marker kept"
date: 2026-07-18
status: current
tags: [task-tree, doctrine, capability-conformance, public-no-drift, logical-helper, canonical-ci]
evidence: "During FUTURE-PARITY-BACKLOG.9.1.1.2.2.2, generated-source changes activated `tools/check_logical_helper_contract.py`. It found that required text `Logical helper parent .5.2 is closed at 8/0` was absent from `docs/TASK_TREE.md`. Git `-S` history showed the marker had originally lived only in the mutable `FUTURE-PARITY-BACKLOG` current-frontier table cell and was removed by later legitimate PNT frontier rewrites. The repair adds `Canonical Closed-Capability Markers` outside the mutable table. No logical-helper behavior or contract changed."
evidence_update_2026_08_17: "FUTURE-PARITY-BACKLOG.14.6.2.2 activated the full capability checker and found that the completed `.24.2` exclusion marker had suffered the same latent failure: later frontier-table rewrites erased the only `docs/TASK_TREE.md` copy. The repair restores both checker-required phrases in the stable Canonical Closed-Capability Markers section; capability semantics and the already-closed `.24.2` contract do not change."
evidence_update_2026_08_29: "FUTURE-PARITY-BACKLOG.22 converts the ad-hoc stable section into a governed boundary. One registry inventories 8 checker-owned families, 12 exact markers, and 15 code/contract consumers; the TASK-TREE-METADATA doctrine enforces one sentinel pair, forbids every marker in the mutable active surface, detects consumer census drift, and runs four mutations including arbitrary FUTURE row replacement. Semantic-introspection markers are moved into the stable section without changing its closed 9/9/128 contract."
reverify: "bash scripts/check_task_tree_metadata.sh; bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py; perl tools/check_capability_conformance.pl"
---

The active-tree table is overwrite-style live state: its current-frontier cells are expected to change after every
completed slice. A checker-owned historical completion fact cannot safely live only in one of those cells. Store
such text in a stable, explicitly named section or another canonical immutable-status document, while the table
continues to summarize only the current frontier.

This distinction prevents legitimate PNT updates from silently erasing public no-drift evidence. The logical-
helper marker loss was latent because canonical CI conditionally activates capability checkers based on changed
paths; a later generated-source slice activated the checker and surfaced the missing durable text.

The same mechanism later erased the already-closed capability-exclusion `.24.2` marker. Its repaired projection
now lives in this stable section as well. `.22` mechanically closes the broader class: every discovered marker and
consumer is registered, the section is sentinel-delimited, mutable frontier rows may not contain those markers,
and deletion, relocation, and active-row-rewrite mutations run through the existing task metadata doctrine.

Related: [[logical-helper-neutral-contract]] and [[task-tree-metadata-gate-boundary]].
