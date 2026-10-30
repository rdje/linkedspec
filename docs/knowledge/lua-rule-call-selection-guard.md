---
id: lua-rule-call-selection-guard
title: Safe Lua static rule-call selections reuse the actual-kind operand guard
answers:
  - "why does Lua selected call Child String execute incompatible Array operands"
  - "which Lua owner guards static rule-call result selections"
  - "does Lua selected-call guard repair add interpreter chunk locals"
date: 2026-10-30
status: bounded installed PUC5.5.1/LuaJIT54.5 repaired/targeted-checked; full admission separate
tags: [lua, selection, rule-call, fluent, guards, effects]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.54.5; rule-call-result-lua-intake.json.gz retains actual39healthy/4RED→43GREEN per host, boundary81/existing computed controls/loadfile/runner and actual source/normal/producers/inputs."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/rule_call_result_selection_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/rule_call_result_selection_test.lua"
---

At915dbf41c, both installed hosts already preserve direct brackets/kinds/static
lookup. All four shared13 routes instead execute BAD/return[] after selected
String because typed_source.receiver_mutation.is_ordinary_computed_read excludes
call. A single canonical bare Variable-shaped positional label now joins its
existing operand guard. Nine lines/body locals only; no new interpreter chunk
local/function or remaining interpreter/invocation/parser/reader/schema change.

Same new43/boundary81/existing six computed programs pass per host, stderr empty.
New sources use native/restored SpecFile/plan/fresh same-process modules; old
computed controls use native/plan/fresh. Shared13/kinds/once/order/live-origin/
null/missing/normalized skips/static lookup/typed function fence/explicit arguments
and bound callable counts hold. Exact three-line runner/loadfile guards register
the normal. No unsafe full runner/formatter/declared5.4/isolated package/quoted-
dynamic-extra-argument source/child-error-deferred/schema/portable admission.
