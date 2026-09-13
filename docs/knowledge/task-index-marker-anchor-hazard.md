---
id: task-index-marker-anchor-hazard
title: Immutable closeout markers anchored in the mutable task-index row cause avoidable canonical restarts
answers:
  - "which checker mirrors the cursor migration census in the stable task index marker"
  - "why did the repeated-action checker fail after updating docs TASK_TREE"
  - "which marker must survive FUTURE-PARITY-BACKLOG active row rewrites"
  - "why does canonical CI keep losing the repeated-action closeout marker"
  - "where is the task-index marker-anchor repair tracked"
  - "why did Dart calls canonical CI fail on repeated-action governance"
  - "does repeated-action still require a historical handoff in bounded MEMORY"
  - "why did Julia recursive observation canonical CI fail on repeated-action governance"
date: 2026-07-21
status: current
tags: [task-tree, doctrine, governance, repeated-action, local-ci, no-drift]
evidence: docs/TASK_TREE.md; tools/check_task_tree_closed_capability_markers.py; tools/check_repeated_action_result_contract.py; capability_conformance/repeated_action_result_contract.json; docs/tasks/FUTURE-PARITY-BACKLOG.09.md; docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md leaf .22
evidence_update_2026_08_12: "FUTURE-PARITY-BACKLOG.14.4.5 repeated the bounded-memory half of this known coupling: its first fully staged canonical run passed every earlier contract, then rejected MEMORY.md because the current rewrite omitted historical next owner FUTURE-PARITY-BACKLOG.10.1. Restoring one compact marker within the unchanged 60-line cap returned the exact repeated-action checker to 8 complete / 0 pending / 54 mutations. The unchanged canonical restart passed that checkpoint; no checker, runtime, public surface, or task-tree ownership changed."
evidence_update_2026_08_13: "INTER-MATCH-GAP-CAPTURE.2.1 repeated the same bounded-memory omission: its first fully staged gap-opt-in canonical run passed all earlier gates through composed semantic-introspection, then the repeated-action checker rejected the missing historical next owner FUTURE-PARITY-BACKLOG.10.1. The active leaf restored one compact marker within the existing 60-line cap and reruns the unchanged gate; no product behavior, rollout, checker, or ownership boundary changes."
evidence_update_2026_08_29: "FUTURE-PARITY-BACKLOG.22 inventories all 8 closed-capability families, 12 exact task-index markers, and 15 consumers. The TASK-TREE-METADATA doctrine now requires those markers between stable sentinels outside the active table and proves arbitrary frontier-row replacement succeeds while repeated-action deletion/relocation and callable deletion fail. Repeated-action retains its durable next-owner assertion in the immutable task tree but no longer requires overwrite-only MEMORY.md to carry that historical fact."
reverify: "bash scripts/check_task_tree_metadata.sh; bash tools/run_python_project_data.sh tools/check_repeated_action_result_contract.py; rg -n 'BEGIN CANONICAL CLOSED-CAPABILITY MARKERS|repeated-action recurring/public no-drift is closed|END CANONICAL CLOSED-CAPABILITY MARKERS' docs/TASK_TREE.md"
---

The repeated-action public no-drift contract requires the exact sentence
`repeated-action recurring/public no-drift is closed` in `docs/TASK_TREE.md`. That immutable fact repeatedly lived
inside the `FUTURE-PARITY-BACKLOG` active-row summary, which is rewritten whenever the frontier advances. Semantic
leaves `.10.2`, `.10.3.0`, `.10.3.2.0`, `.10.4.0.1`, and `.10.4.1` each displaced it; the checker prevented every
bad commit, but only after canonical work had begun.

The structural repair is complete under `FUTURE-PARITY-BACKLOG.22`. The exact marker now lives between the
canonical closed-capability sentinels, and `tools/check_task_tree_closed_capability_markers.py` enforces its
location, the complete checker/marker consumer census, and mutation behavior. A current-frontier rewrite may now
replace the active row without copying any unrelated closeout sentence. Deleting the stable marker or relocating
it into the active row is rejected.

The paired historical handoff coupling is also removed from bounded memory. The repeated-action checker still
validates `FUTURE-PARITY-BACKLOG.10.1` as the durable next owner in its immutable task-tree evidence, but it no
longer searches overwrite-only `MEMORY.md`. Earlier failures in `.10.5.3.1`, Julia `.14.4.5`, and
`INTER-MATCH-GAP-CAPTURE.2.1` remain useful root-cause history; they no longer prescribe a current-memory guard.


## Legitimate census growth — September13

The closed cursor marker also contains the current migration-file census.
BACKEND-INTEGRATION-GUIDES.2.1 adds its guide to that inventory, advancing 74 to 75.
The same current count must change in the cursor contract/checker, the stable
Task Tree marker and tools/check_task_tree_closed_capability_markers.py. Its
second canonical attempt exposed the missed latter mirror before any commit.
Update that one constant; do not remove the stable marker or move it into a
mutable frontier. The eight families, twelve markers, fifteen consumers and
closed rollout remain unchanged. Current fact and public census owners move
together, while dated ADR0067 and architecture chronology retain their old counts.
