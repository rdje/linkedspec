---
id: lua-string-helper-parity-closeout
title: Lua scalar and string helper parity closes at 76 tests on both ABIs
answers:
  - is Lua scalar string helper parity complete
  - what is the Lua test count after string helper closeout
  - what Lua helper family follows string helpers
date: 2026-07-12
status: current
tags: [lua, runtime, strings, regex, split, mutation, no-drift, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.2.2.5.1 closes deterministic strings, Unicode 17 casing, scalar text coercion, strict helper regex/matches, pure split, scalar regex mutation, explicit array split mutation, and focused/public no-drift. PUC Lua and LuaJIT pass 76/76. Public active references lead with cat; the former concat spelling remains retirement prose only. Broader named shipped fixtures retain exact expectations under phase 6. Numeric helpers .4.3.3 are active."
reverify: "bash tools/run_lua_local.sh && rg -n --pcre2 '(?<!\\.)\\bconcat\\s*\\(' lua specs capability_conformance docs/linkedspec-book/src ROADMAP.md ROADMAP_V2.md"
---

## Fact

Lua scalar/string helper parity is closed at 76/76 on both PUC Lua and LuaJIT. The closed family includes pure
deterministic and Unicode strings, cross-variant scalar text conversion, helper regex/matches, pure split, scalar
regex substitution, explicit array split replacement, and their focused public no-drift.

Current public examples lead with `cat`; the former spelling is mentioned only as retired history. Exact broader
shipped fixtures remain unchanged under phase 6 because they require later control/output/array/child-flow owners.
Numeric helpers `LUA-BACKEND-PARITY.4.3.3` are the next execution frontier.
