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

Related: [[lua-duplicate-regex-slot-identity-admission]],
[[lua-runtime-rule-interpreter]], and [[FUTURE-PARITY-BACKLOG]].
