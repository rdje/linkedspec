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
evidence: "LUA-BACKEND-PARITY.4.3.3.0 audited the public helper catalog, Perl/Rust/Dart/Julia runtime tests, lua/src/linkedspec/action_contracts.lua, and lua/src/linkedspec/interpreter.lua. LUA-BACKEND-PARITY.4.3.3.1.4 adds the strict canonical scalar evaluator at 89/89 and exact six-runtime 55-case proof. LUA-BACKEND-PARITY.4.3.3.2 admits every word/symbol call and numeric receiver composition/terminality at 90/90 on both ABIs, including slash-callee/regex disambiguation. Aggregate reducer dispatch remains .3; .4 owns focused public no-drift."
reverify: "bash tools/check_scalar_numeric_six_runtime.sh && rg -n 'ALIAS_CANONICAL_NAMES|fluent_chain' lua/src/linkedspec/action_contracts.lua lua/src/linkedspec/interpreter.lua"
---

`lua/src/linkedspec/action_contracts.lua` canonicalizes arithmetic and comparison symbol callees plus every numeric
word alias to the governed `num_*` family. `scalar_numeric.lua` and `interpreter.lua` now execute canonical calls.
Scalar call and receiver admission is now complete. The next boundary is deliberate: array-consuming reducers and
array receiver terminals remain absent until `.4.3.3.3`.

The executable order is therefore:

1. `.4.3.3.1` — strict finite decimal scalar evaluation, arithmetic/unary/clamp/min/max/comparisons, and invalid
   result fences (done);
2. `.4.3.3.2` — canonical alias/symbol admission plus first-argument number receiver composition and terminal
   comparisons (done);
3. `.4.3.3.3` — array-consuming reducers and terminal array receiver forms;
4. `.4.3.3.4` — dual-ABI and public-surface no-drift closeout.

Exact shipped-corpus execution remains under phase 6, after dependent array/control/output families and the corpus
runner exist.
