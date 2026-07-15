---
id: lua-contextual-user-function-codeblock-runtime
title: Lua invokes contextual final blocks in the current isolated user-function frame
answers:
  - "does Lua execute callback codeblock parameters"
  - "what context does a Lua user function contextual block see"
  - "are Lua contextual callback mutations restored"
  - "can a Lua contextual callback result feed a receiver chain"
  - "what happens when a Lua callback parameter collides with a helper"
  - "what errors do Lua contextual callback calls produce"
  - "does Lua support explicit callable codeblock literals yet"
date: 2026-07-15
status: current
tags: [lua, functions, codeblock, dynamic-scope, diagnostics, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.1.4.2 passes 146/146 on PUC Lua and LuaJIT. Focused tests prove both contextual spellings, current-frame reads/writes, outer restoration, result chaining, static helper/function precedence, and typed missing/harray/arity/recursion failures."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_callable_codeblock_contract.py"
---

Lua normalizes attached `apply(value) { ... }` and parenthesized `apply(value, { ... })` blocks before ordinary
argument evaluation when the registered definition declares a final `callback: codeblock`. The resulting inert
zero-positional `codeblock_argument` is recursively copied into the same isolated invocation frame as every other
user-function argument.

Calling the declared slot inside that function evaluates the stored ActionIR block against the function's current
dynamic stores. It can read and update copied parameters, and nonparameter writes remain visible to later
statements in the same invocation. The protected function boundary restores the entire outer caller on success or
failure. Callback results are ordinary copied LinkedSpec values and may feed compatible receiver chains.

Registered functions and governed helpers resolve before a colliding declared slot. A missing or harray final
value reports `final_argument_not_codeblock`; a contextual call with arguments reports `codeblock_arity_mismatch`;
active self-invocation reports `codeblock_recursion_unsupported` with a cycle. This is a narrow
metadata-governed contextual path. Explicit `{|params| ...}` literals and general bound dynamic calls remain
`FUTURE-PARITY-BACKLOG.11.7`; descriptors remain `.5.3` and generated source remains `.8`.

Related facts: [[lua-final-codeblock-metadata]], [[perl-generic-final-codeblock-normalization]],
[[callable-codeblock-literal-contract]], [[lua-fixed-v1-user-function-runtime]].
