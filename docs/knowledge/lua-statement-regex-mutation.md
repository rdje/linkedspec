---
id: lua-statement-regex-mutation
title: Lua distinguishes dropped scalar regex mutation from pure substr slicing
answers:
  - does Lua support statement form substr regex substitution
  - does Lua regex_subst mutate scalar targets
  - how does Lua distinguish substr mutation from value slicing
  - does Lua regex replacement support dollar captures
  - how does Lua global regex replacement handle zero width
  - do Lua invalid substitution patterns include the rule label
date: 2026-07-12
status: current
tags: [lua, runtime, regex, mutation, substr, PCRE2, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.2.2.3 adds dropped-statement dispatch in lua/src/linkedspec/interpreter.lua for four-argument substr/regex_subst calls with bare scalar targets. String/regex patterns share strict helper compilation; g is global, imsx compile, o is a no-op, $0/$n expand from native group vectors, and zero-width global matches advance by a decoded UTF-8 scalar. Invalid patterns/flags carry rule_label. lua/test/run.lua locks mutation and pure discarded/value substr boundaries; PUC Lua and LuaJIT pass 75/75."
reverify: "bash tools/run_lua_local.sh"
---

## Fact

Lua spends statement context, arity, and target shape to disambiguate overloaded `substr`. A dropped
four-argument `substr(target, pattern, replacement, flags)` or `regex_subst(...)` call mutates only when `target`
is a bare scalar name. Numeric `substr(value,start,width?)` remains a pure value even when its result is discarded.

String and typed regex patterns use the same strict PCRE2 adapter. `g` selects global replacement, `i/m/s/x`
affect compilation, and `o` is a compatibility no-op. `$0` expands the whole match and `$n` indexes the native
full group vector. Global zero-width matching keeps separate output and search cursors, advancing search by one
decoded UTF-8 scalar without dropping source text. Unknown flags and invalid patterns raise a runtime diagnostic
with the active rule label. Explicit array-target split replacement has since landed under `.4.3.2.2.4`.
