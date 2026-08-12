---
id: task-index-marker-anchor-hazard
title: Immutable closeout markers anchored in the mutable task-index row cause avoidable canonical restarts
answers:
  - "why did the repeated-action checker fail after updating docs TASK_TREE"
  - "which marker must survive FUTURE-PARITY-BACKLOG active row rewrites"
  - "why does canonical CI keep losing the repeated-action closeout marker"
  - "where is the task-index marker-anchor repair tracked"
  - "why did Dart calls canonical CI fail on repeated-action governance"
  - "which repeated-action handoff must remain in bounded MEMORY"
  - "why did Julia recursive observation canonical CI fail on repeated-action governance"
date: 2026-07-21
status: current
tags: [task-tree, doctrine, governance, repeated-action, local-ci, no-drift]
evidence: docs/TASK_TREE.md; MEMORY.md; capability_conformance/repeated_action_result_contract.json; docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.2, .10.3.0, .10.3.2.0, .10.4.0.1, .10.4.1, .10.5.2.3, and .10.5.3.1
evidence_update_2026_08_12: "FUTURE-PARITY-BACKLOG.14.4.5 repeated the bounded-memory half of this known coupling: its first fully staged canonical run passed every earlier contract, then rejected MEMORY.md because the current rewrite omitted historical next owner FUTURE-PARITY-BACKLOG.10.1. Restoring one compact marker within the unchanged 60-line cap returned the exact repeated-action checker to 8 complete / 0 pending / 54 mutations. The unchanged canonical restart passed that checkpoint; no checker, runtime, public surface, or task-tree ownership changed."
reverify: "bash tools/run_python_project_data.sh tools/check_repeated_action_result_contract.py; rg -n 'repeated-action recurring/public no-drift is closed' docs/TASK_TREE.md capability_conformance/repeated_action_result_contract.json"
---

The repeated-action public no-drift contract currently requires the exact sentence
`repeated-action recurring/public no-drift is closed` in `docs/TASK_TREE.md`. That true immutable closeout marker
has repeatedly lived inside the `FUTURE-PARITY-BACKLOG` active-row summary, which is rewritten whenever the
frontier advances. Semantic leaves `.10.2`, `.10.3.0`, `.10.3.2.0`, `.10.4.0.1`, and `.10.4.1` each displaced it;
the checker correctly prevented every bad commit, but only after canonical work had begun.

Restore the exact marker before rerunning the focused checker. Do not weaken or delete its public claim. The
structural defect is the marker's mutable home, not the checker. Pending task `FUTURE-PARITY-BACKLOG.22` owns an
inventory of similarly coupled markers and a stable governed/derived home plus a test proving that active-row
rewrites cannot erase unrelated closed-contract state. Until that task lands, every active-row rewrite must retain
the exact repeated-action sentence. See the task's acceptance criteria rather than re-deriving this history.

The `.10.5.2.3` active-row rewrite repeated the failure: it removed the old row marker while the new canonical
closed-capability section retained only the near-match `repeated-action public closeout has since completed it`.
The `.10.5.3.1` canonical gate correctly rejected that wording, then exposed the paired handoff coupling after the
exact task-index marker was restored: overwrite-only `MEMORY.md` must also retain the historical next owner
`FUTURE-PARITY-BACKLOG.10.1`. The bounded repair is to keep the exact closeout sentence in the stable marker section
and the compact handoff fact in current memory until `.22` moves both requirements to a governed home. Do not
weaken the checker, and do not pivot from an already dirty semantic leaf merely to perform the structural repair.

Julia recursive-observation leaf `.14.4.5` reproduced only the paired `MEMORY.md` failure after its bounded pointer
was rewritten for atomic 213. The focused checker proved the root cause, and the same compact historical owner was
restored without exceeding the 60-line cap. This recurrence reinforces `.22` as the structural owner; it does not
justify copying more history into layer-A memory or weakening the exact handoff assertion.
