---
id: capture-reset-value-block-dart-compatibility
title: Dart already executes anonymous reset statements inside ordinary value blocks
answers:
  - "does Dart start_capture_slice work inside a cat operand block"
  - "does Dart capture_slice_here preserve local return and lazy skip"
  - "can Dart literal callbacks reset their caller capture boundary"
date: 2026-10-28
status: bounded35.3 targeted-checked without runtime edits; peer/isolated-package/context admission open
tags: [dart, blocks, capture, void, methods, callbacks, function]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.35.3 at clean425b8ce78; capture-reset-value-block-dart-intake.json.gz retains14-source/four-route intake, emitted libraries/caller and normal regression outputs."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/capture_reset_value_block_test.dart test/capture_boundary_number_results_test.dart"
---

Existing _evaluateBlockValue/_executeValueBlockStatements execute nonfinal effects
before final values and keep return local to the value block. Canonical reset
calls context.startCaptureSlice and returns null; existing alias/function owners
retain original helper names. Runtime/frontend/emitter need no repair. New3 plus
Number6 tests pass with changed-file format/fatal analysis after independent
fourteen-source native/restored SpecFile/generated-plan/fresh VM intake.

Eight ordinary controls preserve4! snapshot, boundary2/6 and rest4/0, SA order,
return before/after reset, T skip/action continuation and defined lazy fallback
suppression. Both existing literal callback aliases yield x!/6; direct pure
functions and callbacks invoked by pure apply reject the authored helper with
native/restored RuntimeInterpreterException versus plan/fresh GeneratedSourceException.
No mutator-as-data or new body-vocabulary grant is inferred from this existing
Dart support. Strict JSON verification keeps Bool/Number/null/Array distinct.

Actual fourteen emitted libraries and fresh caller/source/channels are retained.
The caller uses current project package configuration, not isolated dependencies.
No new temp owner, schema, shared expected bytes or global source/context/backend
admission moves. Julia35.4 independently follows; full admission remains23.4.
