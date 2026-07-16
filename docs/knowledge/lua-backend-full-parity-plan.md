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
evidence_update_2026_07_15_native_loading: "LUA-BACKEND-PARITY.5.2.1 implements typed deterministic resolve/load plus strict UTF-8, consumes every 14/9/4 case at 149/149 on PUC Lua and LuaJIT, and activates automatic spec-defined function parsing .5.2.2."
evidence_update_2026_07_15_automatic_function_parser: "LUA-BACKEND-PARITY.5.2.2 adds module-relative one-build spec-owned function parsing and automatic Unicode projection/body dispatch at 151/151 on both ABIs; .5.2.3 is active."
evidence_update_2026_07_15_native_spec_pipeline: "LUA-BACKEND-PARITY.5.2.3 adds typed LoadedCompiledSpec, exact neutral source-stage errors, and named/path-identified engines with loaded function execution at 153/153 on both ABIs; .5.2.4 is active."
evidence_update_2026_07_15_native_loading_closeout: "LUA-BACKEND-PARITY.5.2.4 confirms exact source/API/test/public-doc/KM no-drift at 153/153, closes parent .5.2 without behavior change, and activates descriptors/full trace .5.3."
evidence_update_2026_07_15_full_pipeline_trace: "LUA-BACKEND-PARITY.5.3.1 admits exact v1/v2/v3 descriptors; .5.3.2 passes one caller emitter through IO/frontend/compiler/function/staged/engine/runtime at 155/155 on both ABIs with status native-full-pipeline-trace-v1; .5.3.3 is active."
evidence_update_2026_07_15_descriptor_trace_closeout: "LUA-BACKEND-PARITY.5.3.3 closes exact descriptor/full-trace no-drift and parents .5.3/.5 without source/census change; controlled/core corpus .6.1 is active."
evidence_update_2026_07_15_controlled_corpus_split: "LUA-BACKEND-PARITY.6.1.0 measures exact offsets 0-39 and 99-104 at 45/46 on PUC Lua and LuaJIT, isolates offset 20 nested-assignment segment-kind drift under .6.1.1, and orders executor/core/capability leaves .6.1.2-.4 before behavior code."
evidence_update_2026_07_15_nested_path_repair: "LUA-BACKEND-PARITY.6.1.1 preserves typed key/index traversal, governed segment/RHS order, and atomic failed writes. Exact offset 20 and both owned windows now pass 46/46 on PUC Lua and LuaJIT at 157/157 focused tests; reusable executor .6.1.2 is active."
evidence_update_2026_07_15_controlled_corpus_execution: "LUA-BACKEND-PARITY.6.1.2 validates the full strict manifest before selection, composes automatic parse/validate/compile/source-identified runtime, compares exact wrapped typed JSON, and retains per-fixture observations/failures without aborting later cases. Controlled proof passes 160/160 on both ABIs; ordered core window .6.1.3 is active."
evidence_update_2026_07_15_core_prefix_admission: "LUA-BACKEND-PARITY.6.1.3 permanently locks exact manifest offsets 0-39 at 40/40 with exact wrapped expected output and endpoint 1/1. PUC Lua and LuaJIT pass 161/161; capability/no-drift .6.1.4 is active."
evidence_update_2026_07_15_controlled_corpus_closeout: "LUA-BACKEND-PARITY.6.1.4 permanently locks governed offsets 99-104 at 6/6 with exact ordered names, wrapped expected outputs, and endpoints 2,1,2,1,5,5. PUC Lua and LuaJIT pass 162/162; .6.1 closes with coverage 246/105+1/122 and census 64/0/0 unchanged, and .6.2 activates for offsets 40-98."
evidence_update_2026_07_15_full_corpus: "LUA-BACKEND-PARITY.6.3 executes one ordered 105/105 no-selector library gate and bare developer-runner --execute. PUC Lua and LuaJIT pass 167/167 with status runtime-corpus-full; parent .6 closes, primary CLI .7.1 activates, and census 64/0/0 remains unchanged."
evidence_update_2026_07_15_primary_cli: "LUA-BACKEND-PARITY.7.1 implements exact ADR 0023 arguments, strict UTF-8, native execution, canonical JSON, stable phase exits, and ADR 0024 trace at 169/169 per ABI plus diagnostic shared CLI 61x2. Recurring process/matrix admission .7.2 is active; status stays runtime-corpus-full."
evidence_update_2026_07_15_primary_cli_admission: "LUA-BACKEND-PARITY.7.2 makes focused default/POSIX 61x2 recurring, adds PUC Lua to the warmed shared matrix at 5x2x61, and advances status to runtime-corpus-primary-cli; final no-drift .7.3 is active."
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
foundation time, so `.1.1` locked a reproducible repository-owned dependency/test/cache strategy. Automatic
spec-owned top-level function-shell parsing and loaded-source identity/compile/engine composition are complete;
native-loading no-drift, exact descriptors, and caller-owned full-pipeline trace are complete. Census-preserving
no-drift `.5.3.3` closes parents `.5.3`/`.5`. Controlled/core planning `.6.1.0` measured exact offsets 0-39 plus
99-104 at 45/46 on both ABIs. Typed nested-path repair `.6.1.1` closes the sole residual and both windows at
46/46, with focused suites at 157/157. Reusable executor `.6.1.2` precedes permanent core/capability and advanced
window admission. Complete `.6.3` now executes the ordered 105/105 manifest through the library and developer
runner at 167/167 per ABI with status `runtime-corpus-full` and closes parent `.6`. Primary adapter `.7.1` now
implements the exact thin command at 169/169 per ABI. Admission `.7.2` makes shared CLI 61x2 recurring, extends
the matrix to 5x2x61, and advances status to `runtime-corpus-primary-cli`; final no-drift `.7.3` is active.

Related facts: [[native-in-memory-backend-contract]], [[user-observable-backend-cli-parity-contract]],
[[backend-capability-census]], [[generated-source-contract-v1]], [[language-agnostic-backend-vision]],
[[dart-backend-interpreter-first-plan]], [[julia-backend-interpreter-first-plan]],
[[lua-runtime-diagnostics-trace-split]], [[lua-runtime-structured-diagnostics]],
[[lua-trace-controls-sinks]], [[lua-native-spec-resolution]], [[lua-spec-defined-function-parser]],
[[lua-native-spec-pipeline]], [[lua-native-spec-loading-closeout]], [[lua-native-full-pipeline-trace]],
[[lua-controlled-corpus-admission-split]], [[lua-full-corpus-gate]], [[lua-primary-cli-adapter]],
[[lua-primary-cli-recurring-admission]].
