---
id: lua-interpreter-local-variable-ceiling
title: "The Lua interpreter chunk is at the Lua 5.1 top-level local-variable ceiling"
answers:
  - "why does adding a local to lua interpreter fail"
  - "why does luac report too many local variables in interpreter lua"
  - "what is the Lua interpreter local variable limit risk"
  - "how should new Lua interpreter helpers be added"
date: 2026-07-20
status: current maintenance constraint
tags: [lua, luajit, interpreter, architecture, maintenance, local-variable-limit, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.9.1.8.1.6, adding one top-level local module binding and one local trace helper made luac -p reject lua/src/linkedspec/interpreter.lua with 'too many local variables (limit is 200) in main function'. Removing the extra binding and publishing the helper through the existing module table restored PUC Lua and LuaJIT syntax and complete tests."
evidence_update_2026_08_07: "FUTURE-PARITY-BACKLOG.14.2.5.2 initially added a source-location module local plus seven local typed adapters; PUC Lua again rejected interpreter.lua at the exact 200-local ceiling before any test ran. Moving the module binding into one private typed_source table and publishing adapters as table fields restored PUC and LuaJIT loading. Core 133/133, projection 240/240, aliases 638/638, and complete package 177/177 then pass on each ABI."
evidence_update_2026_09_04: "FUTURE-PARITY-BACKLOG.19.6.2 again reached the 200-local load-time ceiling while adding receiver-mutation helpers. Publishing the coherent implementation under the existing private typed_source.receiver_mutation namespace instead of adding chunk locals restored both ABI syntax/load paths. The permanent map-leaves suite passes 530 assertions per ABI and the complete dual-ABI Lua gate passes."
reverify: "find lua/src/linkedspec -name '*.lua' -print0 | xargs -0 -n1 luac -p"
---

`lua/src/linkedspec/interpreter.lua` is a single large Lua chunk whose
top-level local declarations have reached the Lua 5.1 main-function ceiling.
PUC Lua and LuaJIT both inherit that compatibility constraint. A seemingly
small new `local` binding can therefore make the entire module fail at load
time even when the function itself is correct.

New interpreter helpers should use an existing module/table namespace or,
when a coherent boundary exists, move into a smaller required module. Every
interpreter change must retain a direct `luac -p` pass before runtime tests.
The duplicate-slot slice used `M.trace_regex_slot_selected` and an existing
required module rather than consuming another top-level local.

Typed source projection `.14.2.5.2` confirms the complementary safe pattern: one coherent private module owns the
large implementation, while the interpreter spends a single private table binding and table-field adapters. Do not
expand that table into separate chunk-local aliases; doing so recreates the load-time failure before tests execute.

Related: [[lua-duplicate-regex-slot-identity-admission]],
[[lua-runtime-rule-interpreter]], and [[FUTURE-PARITY-BACKLOG]].
