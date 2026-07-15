---
id: lua-backend-full-parity-plan
title: Lua backend planning inherits the complete LinkedSpec parity contract
answers:
  - what is the Lua LinkedSpec backend plan
  - which Lua runtime is primary for LinkedSpec
  - is LuaJIT required for LinkedSpec
  - is LPeg automatically the LinkedSpec regex engine
  - what command will the Lua backend expose
  - must Lua support native in-memory LinkedSpec
  - must Lua support generated source
  - what task implements the Lua backend
  - what is the first Lua backend task
date: 2026-07-13
status: current
tags: [lua, backend, parity, embedding, cli, corpus, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.3 creates docs/tasks/LUA-BACKEND-PARITY.md after generated-source .3 closes at 60/0/0. FUTURE-PARITY-BACKLOG.16.6 proves punctuation-light aliases through typed AST, serialized SpecFile/ActionIR reconstruction, and native execution on PUC Lua and LuaJIT; Lua generated-source ownership remains LUA-BACKEND-PARITY.8.1-.8.4."
evidence_update_2026_07_15_diagnostics_trace_split: "LUA-BACKEND-PARITY.4.4.0 splits structured runtime diagnostics, controls/sinks, runtime instrumentation, and closeout. Full frontend/compiler/function/staged propagation remains dependency-correct .5.3 after general staged-function .5.1 and native loading .5.2."
evidence_update_2026_07_15_structured_diagnostics: "LUA-BACKEND-PARITY.4.4.1 adds neutral typed RuntimeDiagnostic payloads with optional spec identity, specific top/input/lookup/execution stages, deepest-rule/handler preservation, deterministic JSON, unchanged success output, and runtime-structured-diagnostics status at 126/126 on both ABIs."
evidence_update_2026_07_15_trace_controls: "LUA-BACKEND-PARITY.4.4.2 adds typed ordered levels/config/events, environment controls, caller-owned stdout/route/mirror sinks, reset/append, and result-neutral traced runtime entrypoints at 128/128 on both ABIs; .4.4.3 owns deeper instrumentation."
evidence_update_2026_07_15_runtime_trace_events: "LUA-BACKEND-PARITY.4.4.3 instruments rule scopes, regex decisions, action/blind dispatch, recursion, lifecycle, cursor, source-boundary, and governed mark/capture events at 129/129 on both ABIs; .4.4.4 owns no-drift."
evidence_update_2026_07_15_runtime_trace_closeout: "LUA-BACKEND-PARITY.4.4.4 closes scoped runtime diagnostics/trace no-drift at 129/129, closes parent .4.4, and activates staged-function/native-loading .5.1; full-pipeline trace remains .5.3."
evidence_update_2026_07_15_staged_function_split: "LUA-BACKEND-PARITY.5.1.0 splits minimal staged dispatch, fixed-v1 runtime, variadic-v2 metadata/runtime, contextual-codeblock metadata/runtime, and no-drift; .5.1.1 is active."
evidence_update_2026_07_15_staged_registry: "LUA-BACKEND-PARITY.5.1.1 adds the deterministic actionir-body.spec provider, governed cache/compiled identity, stable queue, immutable body_ast stitching, composed shell dispatch, and typed failure fences at 130/130 on PUC Lua and LuaJIT; status is runtime-staged-registry and .5.1.2 is active."
evidence_update_2026_07_15_fixed_runtime: "LUA-BACKEND-PARITY.5.1.2 adds registry-first fixed-v1 calls over verified staged bodies and isolated copied stores at 133/133 on PUC Lua and LuaJIT; status is runtime-user-functions-fixed-v1 and .5.1.3.1 is active."
evidence_update_2026_07_15_staged_function_closeout: "LUA-BACKEND-PARITY.5.1.3-.5 close variadic-v2 and contextual-codeblock runtime plus no-drift at 146/146 with status runtime-user-functions-contextual-codeblock-v1; native loading .5.2 is active."
reverify: "lua -v; luajit -v; lua -e 'print(pcall(require,\"lpeg\"))'; rg -n 'LUA-BACKEND-PARITY|linkedspec-lua|Generated Lua source' docs/tasks/LUA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`docs/tasks/LUA-BACKEND-PARITY.md` is the dedicated third-backend rollout plan. PUC Lua 5.4 is the primary
conformance runtime. LuaJIT is a secondary compatibility leg because its language baseline is Lua 5.1; it may not
fork or weaken public behavior.

The primary product is a native in-process Lua module accepting `.spec` source and input values and returning
structured Lua results/diagnostics. `linkedspec-lua` is a thin adapter with the exact 61-case CLI interface, not a
separate product or semantics owner.

The plan inherits every admitted contract: universal source/ActionIR, scalar/array/harray/codeblock values,
newline-only statement separation with semicolons only between same-line statements, single/double quotes,
generic final-codeblock equivalence, matching/cursor/capture semantics, staged functions, descriptors,
diagnostics/trace, native resolution, 105/105 corpus, capability census, and generated-source v1 with ten families
and exact 8/105 admission.

Cross-backend syntax work may validate Lua today through the implemented typed AST,
serialized `SpecFile`/ActionIR state, and native PUC Lua/LuaJIT execution. It must not
claim a generated-Lua preservation path before the distinct generated-source lane
`LUA-BACKEND-PARITY.8.1-.8.4` implements and admits that product surface.

LPeg loads on both installed runtimes, but this does not make it the selected regex engine. Lua patterns and LPeg
must be compared with the neutral regex/match-state fixtures; a native adapter is permissible if it preserves the
native in-memory module contract and exact behavior. LuaRocks and the common test/lint/format tools were absent at
foundation time, so `.1.1` locked a reproducible repository-owned dependency/test/cache strategy. The current
frontier is native named/path loading `.5.2`.

Related facts: [[native-in-memory-backend-contract]], [[user-observable-backend-cli-parity-contract]],
[[backend-capability-census]], [[generated-source-contract-v1]], [[language-agnostic-backend-vision]],
[[dart-backend-interpreter-first-plan]], [[julia-backend-interpreter-first-plan]],
[[lua-runtime-diagnostics-trace-split]], [[lua-runtime-structured-diagnostics]],
[[lua-trace-controls-sinks]].
