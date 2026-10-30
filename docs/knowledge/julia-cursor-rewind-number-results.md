---
id: julia-cursor-rewind-number-results
title: Julia rewind Number results reuse validated positions and canonical guards
answers:
  - "why does Julia rewind_entry_start return null after moving the cursor"
  - "which Julia owner returns rewind Number results"
  - "does Julia reject surplus cursor rewind arguments"
  - "are Julia rewind result positions character offsets"
date: 2026-10-30
status: bounded56.4 result repaired/targeted-checked; immediate P1 arity56.4.0 pending
tags: [julia, cursor, rewind, number, fluent, arity]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.56.4; cursor-rewind-result-julia-intake.json.gz retains55PASS/20RED to75PASS, gap98/computed25/strict depwarn/retained successful precompile progress and actual source/producers/inputs.20 original passing assertions preserve known malformed forms, no healthy arity credit."
reverify: "bash tools/run_julia_project_data.sh --project=julia --depwarn=error julia/test/cursor_rewind_result_test.jl"
---

At9a9fe0655 original _evaluate_runtime_call! rewind branches validate/move/trace
but discard Position and return nothing. They now cache that same validation
result and return SourceLocation.position_offset after the original cursor setter
for canonical-zero calls. _runtime_is_input_cursor_value_source and
_runtime_is_ordinary_computed_read admit just two canonical-zero rewind names to
existing actual-kind guards. The runner gains one include; other inputs exact.

Unchanged75-assertion normal55PASS/20RED to75PASS, gap98/computed25 strict
depwarn pass; stderr retains successful package-precompilation progress only.
Original55 includes20 known-malformed-preservation
checks plus5 route-key scaffolding in failing groups; not55 healthy-positive
behavior proofs. Thirteen actual results/two function fences retain native/
restoredSpec/generated-plan/fresh Module in one process. Shared12/snapshot2 then
consuming7/sum9/Unicode character1/3/zero defaults/consumer operand skips/Array
signed String/absence null/original physical and null save-restore hold.

Four surplus positional/keyword rewind forms still return null and move. They
are explicit known-defect controls with no supported-shape/healthy arity credit.
Immediate P1 child56.4.0 independently tests/fixes all four cursor controls
before safe Lua56.5. Rebuild runtime/apps; no isolated package or new state/
stack/anchor/error-schema/iteration/full admission follows.
