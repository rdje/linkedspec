---
id: typed-authoring-model-public-no-drift
title: Final typed authoring-model no-drift composes six existing recurring authorities
answers:
  - "what completes recurring_public_no_drift"
  - "which command verifies the complete typed authoring model"
  - "what does LINKEDSPEC_RUN_TYPED_AUTHORING_MODEL_MATRIX run"
  - "how many typed source location rollout rows are complete"
  - "does final typed authoring closeout add a fifteenth rollout row"
  - "are capture_take_slice and capture_take_slice_len public helpers"
  - "can save_cursor restore_cursor roll back AST or output"
  - "can a parent override a child recursive cursor policy"
date: 2026-08-28
status: current complete authoring-model recurrence and public no-drift
tags: [source-location, authoring-model, recurring-gate, public-no-drift, cursor-safety, conformance, local-ci]
evidence: "FUTURE-PARITY-BACKLOG.14.8 adds tools/check_typed_authoring_model_six_runtime.sh as ordered composition of six existing recurring authorities and promotes only the accepted final recurring_public_no_drift row. The exact 14-row ledger is complete with 231 reason-checked mutations; public governance binds eight current documents, eight stale claims, six helper/cursor safety claims, and ten outward surfaces."
last_verified: 2026-08-28
reverify:
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "bash tools/check_typed_authoring_model_six_runtime.sh"
---

# Typed authoring-model public no-drift

The final combined authoring-model row is current: 14 complete / 0 pending under one composed six-runtime proof.

The composed driver calls, in order, the already-authoritative typed-source value/projection, recognition-
transaction, recursive-observation, typed-gap, progressive-span, and staged-AST recurring drivers. It is not a
replacement oracle. It adds no parser/compiler/runtime/value/helper/carrier/facade/schema/capability/CLI/storage
behavior and does not add a fifteenth rollout row.

The public safety boundary also stays exact. `capture_take_slice` and `capture_take_slice_len` are internal
contract/scanner identifiers whose canonical authored helper spellings remain `capture_take()` and
`capture_take_len()`. `save_cursor()` / `restore_cursor()` remain cursor-only LIFO compatibility controls; they do
not snapshot boundaries or marks and cannot roll back variables, AST mutation, diagnostics, output, registry
effects, external calls, or host state. Recursive children derive cursor policy from their own family, and
progress requires cursor advance or a separately proven well-founded decreasing measure.

Related: [[typed-source-location-runtime-rollout-plan]], [[typed-source-location-recurring-gate]],
[[recognition-transaction-recurring-gate]], [[recursive-observation-recurring-gate]],
[[progressive-span-dispatch-recurring-gate]], and [[staged-ast-enrichment-recurring-gate]].
