---
id: lua-native-spec-pipeline
title: Lua composes loaded specs into typed compiled state and source-identified runtime engines
answers:
  - how does Lua load and compile a named LinkedSpec file
  - what does Lua load_and_compile_spec return
  - how does Lua create an engine from a loaded compiled spec
  - does a Lua exact path request set spec_name
  - how does Lua retain spec name and path in runtime diagnostics
  - which Lua pipeline errors represent parse validation and compile failures
  - can Lua execute top level functions loaded from a spec file
  - what is native-spec-pipeline-v1
date: 2026-07-15
status: current
tags: [lua, native-api, resolution, compilation, runtime, diagnostics, functions, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.2.3 adds load_and_compile_spec, LoadedCompiledSpec, create_engine method/function forms, neutral source-stage errors, loaded function execution, and runtime identity proof at 153/153 on PUC Lua and LuaJIT; canonical CI passes CLI 61x2 and Phase 0 1..1031 in 616 seconds."
reverify: "bash tools/run_lua_local.sh && perl tools/check_native_spec_resolution_contract.pl"
---

`require("linkedspec").load_and_compile_spec(request, options)` first reuses the native resolver and strict UTF-8
loader. It then invokes the cached spec-owned top-level-function parser and staged body dispatcher, validates the
composed `SpecFile`, and compiles it without repeating validation. No CLI, subprocess, temporary file, serialized
handoff, or Lua-owned function grammar participates.

The typed `LoadedCompiledSpec` result has `loaded` and `compiled` fields. `loaded` retains the exact request kind
and value, candidate origin, resolved path, and unchanged decoded source; `compiled` is ordinary Lua backend-native
`CompiledSpec` state. `value:create_engine(options)` and `create_loaded_spec_engine(value, options)` are equivalent.
They copy the caller's options. A named request attaches its requested identity as `spec_name`; an exact-path
request attaches no logical name; both attach the resolved path as `spec_path`, which later runtime diagnostics
preserve.

Source failures become typed `SpecPipelineError` records at exact neutral boundaries: `parse_spec` /
`spec_parse_failed`, `validate_spec` / `spec_validation_failed`, and `compile_spec` / `spec_compile_failed`.
Resolution/loading errors keep their earlier owners unchanged. Focused tests prove loaded fixed-function execution,
named and exact-path identity, runtime diagnostic identity, inline API no-drift, exact missing-name JSON, and all
three source-stage mappings on PUC Lua and LuaJIT at 153/153 with status `native-spec-pipeline-v1`.

Related facts: [[lua-native-spec-resolution]], [[lua-spec-defined-function-parser]],
[[lua-native-spec-loading-split]], [[native-spec-resolution-contract]],
[[native-in-memory-backend-contract]].
