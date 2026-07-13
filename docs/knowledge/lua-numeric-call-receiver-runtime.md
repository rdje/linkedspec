---
id: lua-numeric-call-receiver-runtime
title: Lua numeric calls and number receivers share one strict evaluator
answers:
  - "does Lua support numeric word aliases and symbol callees"
  - "does Lua support integer and float number receiver chains"
  - "are Lua numeric comparison receiver methods terminal"
  - "how does Lua distinguish division symbol calls from regex literals"
date: 2026-07-12
status: current
tags: [lua, luajit, numeric, aliases, symbols, receivers, regex, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.3.2 routes all 18 scalar numeric word aliases and 11 arithmetic/comparison symbol callees through scalar_numeric.lua. interpreter.lua injects integer/float/bare-scalar fluent receivers, composes numeric results, and terminates comparison continuations. action_parser.lua distinguishes a complete parenthesized slash callee from regex start after harray colons. The focused fixture plus grouped/class/zero-width/invalid regex regression cases pass 90/90 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh && bash tools/check_scalar_numeric_six_runtime.sh"
---

Direct numeric calls already canonicalized word and symbol names before `.4.3.3.2`; the missing runtime mechanism
was fluent receiver injection. The numeric fluent branch now supplies the current value as argument one to the same
strict scalar evaluator used by canonical calls. Integer literals, float literals, and bare scalar bindings work;
number-returning methods compose; `eq`, `ne`, `gt`, `ge`, `lt`, and `le` return numeric truth but reject any later
receiver continuation with typed null.

The focused all-spelling fixture exposed a separate parser ambiguity: after an harray `:`, `/` was always considered
a possible regex opener, so nested `/(lhs, rhs)` became raw fallback even though the same call parsed alone.
Slash-call recognition now requires a structurally complete parenthesized callee and leaves `/pattern/flags`
literals—including grouped, character-class, zero-width, and deliberately invalid patterns—on the regex path.

Aggregate `sum`/`avg`/`median`/`range` and one-array `min`/`max`, including array receiver terminals, are not scalar
receiver behavior. They remain owned by `.4.3.3.3`.
