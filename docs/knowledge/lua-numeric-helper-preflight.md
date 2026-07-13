---
id: lua-numeric-helper-preflight
title: Lua numeric helpers require separate scalar, receiver, aggregate, and closeout mechanisms
answers:
  - "how is Lua numeric helper parity split"
  - "does Lua already canonicalize numeric aliases and symbol callees"
  - "where should Lua number receiver chains be implemented"
  - "which Lua leaf owns numeric aggregate reducers"
  - "what is next after Lua string helper parity"
date: 2026-07-12
status: current
tags: [lua, numeric, helpers, receivers, reducers, actionir, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.3.0 audited the public helper catalog, Perl/Rust/Dart/Julia runtime tests, lua/src/linkedspec/action_contracts.lua, and lua/src/linkedspec/interpreter.lua. Lua already mapped numeric word and symbol spellings to num_* contracts. LUA-BACKEND-PARITY.4.3.3.1.4 adds the strict canonical scalar evaluator and closes .1 at 89/89 on both ABIs plus exact six-runtime 55-case proof. Numeric receiver injection/terminal policy remains .2; aggregate reducer dispatch remains .3; .4 owns focused public no-drift."
reverify: "bash tools/check_scalar_numeric_six_runtime.sh && rg -n 'ALIAS_CANONICAL_NAMES|fluent_chain' lua/src/linkedspec/action_contracts.lua lua/src/linkedspec/interpreter.lua"
---

`lua/src/linkedspec/action_contracts.lua` canonicalizes arithmetic and comparison symbol callees plus every numeric
word alias to the governed `num_*` family. `scalar_numeric.lua` and `interpreter.lua` now execute canonical calls.
The next boundary is deliberate: generic fluent chains still do not inject a numeric or array receiver into numeric
calls, and exact alias/symbol/receiver proof remains active under `.4.3.3.2`.

The executable order is therefore:

1. `.4.3.3.1` — strict finite decimal scalar evaluation, arithmetic/unary/clamp/min/max/comparisons, and invalid
   result fences (done);
2. `.4.3.3.2` — canonical alias/symbol admission plus first-argument number receiver composition and terminal
   comparisons;
3. `.4.3.3.3` — array-consuming reducers and terminal array receiver forms;
4. `.4.3.3.4` — dual-ABI and public-surface no-drift closeout.

Exact shipped-corpus execution remains under phase 6, after dependent array/control/output families and the corpus
runner exist.
