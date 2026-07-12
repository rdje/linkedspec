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
evidence: "LUA-BACKEND-PARITY.4.3.3.0 audited the public helper catalog, Perl/Rust/Dart/Julia runtime tests, lua/src/linkedspec/action_contracts.lua, and lua/src/linkedspec/interpreter.lua. Lua already maps numeric word and symbol spellings to num_* contracts, but its runtime has no numeric evaluator, numeric receiver injection/terminal policy, or aggregate reducer dispatch. The parent is split into .1 strict scalar evaluation, .2 aliases/symbols/number receivers, .3 aggregate reducers/array receiver terminals, and .4 focused public no-drift."
reverify: "rg -n 'num_abs|num_sum|ALIAS_CANONICAL_NAMES|evaluate_call|fluent_chain' lua/src/linkedspec/action_contracts.lua lua/src/linkedspec/interpreter.lua docs/linkedspec-book/src/appendix/helper-contract-catalog.md && bash tools/run_lua_local.sh"
---

`lua/src/linkedspec/action_contracts.lua` already canonicalizes arithmetic and comparison symbol callees plus every
numeric word alias to the governed `num_*` family. That frontend fact does not provide runtime execution:
`lua/src/linkedspec/interpreter.lua` currently routes pure strings only, and generic fluent chains do not inject a
numeric or array receiver into numeric calls.

The executable order is therefore:

1. `.4.3.3.1` — strict finite decimal scalar evaluation, arithmetic/unary/clamp/min/max/comparisons, and invalid
   result fences;
2. `.4.3.3.2` — canonical alias/symbol admission plus first-argument number receiver composition and terminal
   comparisons;
3. `.4.3.3.3` — array-consuming reducers and terminal array receiver forms;
4. `.4.3.3.4` — dual-ABI and public-surface no-drift closeout.

Exact shipped-corpus execution remains under phase 6, after dependent array/control/output families and the corpus
runner exist.
