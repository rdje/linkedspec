---
id: lua-staged-function-runtime-closeout
title: Lua staged-function runtime closes as one owned native pipeline
answers:
  - "is Lua staged function runtime complete"
  - "what does LUA-BACKEND-PARITY 5.1.5 close"
  - "what is next after Lua staged functions"
  - "which Lua staged function features are implemented"
  - "which Lua function features remain after 5.1"
date: 2026-07-15
status: current
tags: [lua, staged-parsing, functions, variadic, codeblock, closeout, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.1.5 audits source, exports, tests, public docs, task state, and Knowledge Map. .5.1.1-.5 close at 146/146 on PUC Lua and LuaJIT with status runtime-user-functions-contextual-codeblock-v1; .5.2 activates."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_callable_signature_contract.py && python3 tools/check_callable_codeblock_contract.py"
---

Lua's native staged-function parent is complete as one dependency-ordered pipeline. The spec-owned function shell
produces typed payloads/jobs; the staged registry validates, orders, executes, and immutably stitches ActionIR body
ASTs; the immutable function registry prepares isolated copied frames; and the interpreter executes fixed-v1,
variadic-v2, and metadata-governed contextual final blocks. Public exports expose the same native seams tested by
the dual-ABI suite.

Closeout found no unowned implementation gap. It corrected one live Lua README sentence that still described
staged body dispatch as absent. Public status remains `runtime-user-functions-contextual-codeblock-v1`, focused
tests remain 146/146 on PUC Lua and LuaJIT, and capability remains 64/0/0 because no new cross-backend capability
was admitted. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 644 seconds. Mutation testing remains
a separately scheduled manual campaign and was not part of the closeout gate.

Planning `.5.2.0` splits portable native loading into resolve/load `.5.2.1`, automatic spec-defined function-shell
parsing `.5.2.2`, full compile/engine composition `.5.2.3`, and no-drift `.5.2.4`. Resolve/load is now complete at
149/149 on both ABIs and `.5.2.2` is active. Outward
descriptors plus full-pipeline trace remain `.5.3`; generated preservation and
execution remain `.8`; corpus and parser CLI have later owners; explicit `{|params| ...}` literals and general
bound dynamic calls remain `.11.7`.

Related facts: [[lua-staged-function-execution-split]], [[lua-staged-function-body-registry]],
[[lua-fixed-v1-user-function-runtime]], [[lua-variadic-v2-runtime]],
[[lua-contextual-user-function-codeblock-runtime]], [[lua-native-spec-resolution]].
