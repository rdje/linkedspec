---
id: lua-scalar-numeric-runtime
title: Lua scalar numeric v1 has one portable evaluator and exact six-runtime proof
answers:
  - "how does Lua implement scalar numeric v1"
  - "does Lua match all 55 scalar numeric cases"
  - "how is six-runtime scalar numeric parity checked"
  - "how does Lua avoid tonumber modulo and rounding drift"
date: 2026-07-12
status: current
tags: [lua, luajit, numeric, helpers, runtime, contract, parity, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.3.1.4 adds lua/src/linkedspec/scalar_numeric.lua and canonical dispatch in interpreter.lua. The unchanged linkedspec-scalar-numeric-v1 fixture is executed directly by lua/test/run.lua. PUC Lua and LuaJIT each pass 89/89 plus the exact 105-manifest/CLI scaffold. tools/check_scalar_numeric_six_runtime.sh proves the same 55-case expected value through Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT."
reverify: "bash tools/check_scalar_numeric_six_runtime.sh"
---

`lua/src/linkedspec/scalar_numeric.lua` is the single policy owner for the 18 canonical scalar helpers. It accepts
only finite numbers or untrimmed decimal strings matching the neutral grammar; rejects booleans, null, aggregate
values, codeblocks, host-only number syntax, and wrong arities; and maps invalid operations or non-finite results to
typed null. It implements half-away rounding directly and floor signed modulo as
`a - floor(a / b) * b`, then normalizes negative zero.

`lua/src/linkedspec/interpreter.lua` evaluates canonical call arguments and delegates to that module. Generic scalar
conversion is unchanged. Numeric aliases, symbol call spellings, first-argument number receiver injection, and
aggregate reducers remain separate downstream mechanisms rather than accidental claims of this scalar leaf.

The Lua test reads `capability_conformance/scalar_numeric_contract.json`, executes its exact `spec_source`, and
compares the complete returned JSON value with `expected`. The composed checker then runs the same contract through
all six runtime variants, so admission means exact structured results rather than similar happy paths.
