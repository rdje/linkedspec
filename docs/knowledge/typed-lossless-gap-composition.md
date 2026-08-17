---
id: typed-lossless-gap-composition
title: Lossless gaps compose through the existing typed span without a second behavior owner
answers:
  - "how are inter-match gaps represented in the typed source-location algebra"
  - "which command checks typed lossless-gap composition on all six runtimes"
  - "what does LINKEDSPEC_RUN_TYPED_GAP_COMPOSITION_MATRIX run"
  - "does gap_span copy source text or retain a typed span"
  - "who owns gap syntax lifecycle implementation compatibility and migration"
  - "what is the current typed source-location rollout after gap composition"
  - "how many typed source-location mutations exist after lossless-gap composition"
  - "which typed rollout row did FUTURE-PARITY-BACKLOG.14.5.1 complete"
  - "is recurring_public_no_drift complete after lossless-gap composition"
  - "what exact gap and public authorities does typed gap composition bind"
date: 2026-08-17
status: current at typed source 10 complete / 4 pending / 126 mutations
tags: [source-location, span, gap, segmentation, composition, recurring-gate, local-ci, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.5.1 adds one exact lossless_gap_composition section to the typed-source contract. It binds the separately owned inter-match gap authority at 9/0/63 plus public 6 documents / 12 stale denials / 10 outward guards / 29 mutations. The projection is the already-current gap_span: a detached same-source half-open Unicode-scalar span with source identity and gap provenance; prefix/interstitial/tail are segment positions, gap_text materializes on demand, and entry_slot independently retains named or positional provenance. Twelve new drift mutations and one repository-routed driver advance typed governance from 9/5/114 to 10/4/126 by promoting only lossless_gap_composition. The driver runs typed validation, the complete neutral/Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT gap route, recognition ownership, and generated-source/capability/language ledgers. Canonical signoff passes nine doctrines, repository containment/relocation, CLI 66/66 twice, RAM 51%, Phase 0 1031/1031 in 729 seconds, and the exact opt-in success marker. INTER-MATCH-GAP-CAPTURE.1-.7 remains the sole syntax, lifecycle, implementation, compatibility, migration, and public-admission owner; recurring_public_no_drift remains pending under .14.8."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "bash tools/check_typed_gap_composition_six_runtime.sh"
  - "bash tools/test_project_data_workflow_routing.sh"
  - "LINKEDSPEC_RUN_TYPED_GAP_COMPOSITION_MATRIX=1 bash tools/run_ci_local.sh"
---

# Typed lossless-gap composition

The gap program already owns the language and runtime mechanisms. Typed-source composition only records that its
`gap_span()` carrier is the common immutable source-location representation. It is one detached span over one
decoded source, with half-open Unicode-scalar offsets and `provenance = "gap"`. The separate `gap_text()` call
materializes text on demand, while `entry_slot()` retains the selected named or positional slot provenance.

Run the focused composed proof with:

```bash
bash tools/check_typed_gap_composition_six_runtime.sh
```

The order is contract-first: typed validation, the complete gap checker and six runtime consumers, recognition
ownership, then generated-source, capability, and language coverage. The local-CI opt-in is
`LINKEDSPEC_RUN_TYPED_GAP_COMPOSITION_MATRIX=1`.

Only the typed `lossless_gap_composition` row is complete because of this leaf. `progressive_span_dispatch`,
`staged_span_dispatch`, transaction safety in the typed ledger, and combined `recurring_public_no_drift` remain
separately owned pending rows. No new public `Span` value or parser-dispatch authority is implied.

Related: [[lossless-gap-cross-tree-handoff]], [[inter-match-gap-recurring-public-closeout-plan]],
[[typed-source-location-runtime-rollout-plan]], and [[typed-source-location-recurring-gate]].
