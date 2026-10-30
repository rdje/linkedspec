---
id: julia-gap-string-result-guards
title: Julia gap String results use canonical actual-kind operand guards
answers:
  - "why does Julia gap_text take execute incompatible operands"
  - "which Julia owner guards gap_kind result methods"
  - "does Julia gap String recovery already work"
  - "does Julia gap String composition alter helper frames or diagnostics"
date: 2026-10-30
status: bounded Julia57.4 repaired/targeted-checked; full admission separate
tags: [julia, gap, string, fluent, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.57.4; gap-string-result-julia-intake.json.gz retains unchanged100 assertions92PASS/8RED to100PASS, record98/computed25/strict depwarn and actual producer/source/inputs.92 original passes include2 scaffolds in failing groups."
reverify: "bash tools/run_julia_project_data.sh --project=julia --depwarn=error julia/test/gap_string_result_test.jl"
---

Atb9b31ae8c primitive/compatible Strings/read recovery/with returned kinds/Unicode
character length/context/function/arity work. Shared/direct consumer guards bypass
actual-kind checks. _runtime_is_input_cursor_value_source and
_runtime_is_ordinary_computed_read omit gap_text/gap_kind. Two existing
canonical-zero/source_method/name/no-trailing sets now admit these names. Getter/
helper bodies/parser/state/diagnostics/function/arity/schema and all remaining
Interpreter bytes exact. Runner gains one include.

Unchanged100 assertions92PASS/8RED to100PASS, record98/computed25 strict depwarn
pass. Original92 includes2 route-key scaffold checks in failing groups, no
inflated healthy-value count. Eight values/12 function-context-arity observations
retain native/restoredSpec/generated-plan/fresh Module in one process; six
healthy values/all errors byte-equal. Successful package precompile output
retained. Bare-variable classifications stay under unchanged paths; no complete
named-value runtime census. Rebuild runtime/apps; no isolated package/new state/
schema/error-phase/full admission. Safe Lua57.5 follows independently.
