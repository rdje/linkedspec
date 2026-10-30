---
id: lua-gap-string-result-guards
title: Safe Lua gap String results reuse canonical actual-kind operand guards
answers:
  - "why does Lua gap_text take execute incompatible operands"
  - "which Lua owner guards gap_kind result methods"
  - "does Lua gap String recovery already work"
  - "does Lua gap String composition add interpreter chunk locals"
date: 2026-10-30
status: installed PUC5.5.1/LuaJIT57.5 repaired/targeted-checked; full admission separate
tags: [lua, gap, string, fluent, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.57.5; gap-string-result-lua-intake.json.gz retains unchanged148 checks140PASS/8RED to148PASS per host, record126/six computed programs/loadfile/version and actual source/producers/inputs. Original140 includes2 compile scaffolds in failing groups."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/gap_string_result_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/gap_string_result_test.lua"
---

At cb50b9d5204e primitive/compatible Strings/read recovery/with returned kinds/
Unicode/function/context/arity work. Shared/direct incompatible consumers bypass
actual-kind checks. typed_source.receiver_mutation.is_input_cursor_value_source
and is_ordinary_computed_read omit gap_text/gap_kind. Two existing canonical-zero
conditions now admit both, preserving original source_method/name/no-trailing/
zero-arity checks. Getter/helper bodies/parser/state/errors/function/arity/schema
and remaining interpreter bytes exact. Runner gains three lines; no interpreter
chunk locals/functions added.

Unchanged148 checks140PASS/8RED to148PASS per installed PUC5.5.1/LuaJIT host,
record126/six computed programs/loadfile/version pass, focused stderr empty.
Original140 includes2 compile scaffolds in failing groups. Eight values/12
function-context-arity source observations retain native/restoredSpec/generated-
plan/fresh module in one process; six healthy values/all errors byte-equal.
Bare-variable classifications stay unchanged, no complete named-value census.
Rebuild runtime/apps. No isolated package/declared5.4/unsafe runner/formatter/new
state/schema/error-phase/full admission. Selection23.1.19 continues features.
