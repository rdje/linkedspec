---
id: lua-cursor-rewind-number-results
title: Safe Lua rewind Numbers reuse successful physical setters and typed guards
answers:
  - "why does Lua rewind_entry_start return null after moving the cursor"
  - "which Lua owner returns rewind Number results"
  - "does Lua cursor result composition add interpreter chunk locals"
  - "what error envelope does Lua cursor control arity preserve"
date: 2026-10-30
status: installed PUC5.5.1/LuaJIT56.5 repaired/targeted-checked; full admission separate
tags: [lua, cursor, rewind, number, fluent, arity]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.56.5; cursor-rewind-result-lua-intake.json.gz retains unchanged calibrated183checks20RED to183PASS per host, gap126/six computed programs/loadfile/version and actual source/producers/inputs."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/cursor_rewind_result_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/cursor_rewind_result_test.lua"
---

Atd45426a6d evaluate_cursor_control moves through original validated bool setter
but discards the result and returns json.null. It now uses one function-local
result to project existing character offset only after successful rewind.
Original setter/arity/save/restore/trace remain exact. Existing
typed_source.receiver_mutation.is_input_cursor_value_source and
is_ordinary_computed_read admit two canonical-zero rewind names to actual-kind
guards; no new interpreter chunk local/function. Runner gains three lines.

Each installed host same calibrated183checks20RED to183PASS, gap126/six
computed programs/loadfile/version pass, stderr empty. Nine actual values/two
function fences/16 invalid-arity programs retain native/restoredSpec/plan/fresh
module in one process. Shared12/Unicode character1/3/zero defaults/skips/source2
before consuming7/sum9/Array-signed-String/absent null/original physical effects
pass. Existing cursor arity already rejects: native top-level code
helper_arity_mismatch/helper/count/expected, diagnostic stage runtime_execution
without diagnostic code; generated code generated_execution_failed and helper
message. Initial96 borrowed diagnostic assertions per host were calibration,
retained before corrected unchanged-production baseline, no product RED credit.

Rebuild runtime/apps. No isolated package/declared5.4/unsafe full runner/formatter
/new state/schema/ordinary progress/full admission follows. Remaining bounded
feature selection23.1.18 continues; full23.4/pressure/registration/progress owners
remain independent.
