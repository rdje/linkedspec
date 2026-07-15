---
id: lua-native-spec-loading-closeout
title: Lua portable native loading closes without a second adapter or behavior change
answers:
  - how did Lua native spec loading close
  - what did LUA-BACKEND-PARITY 5.2.4 verify
  - is Lua native spec loading complete
  - what is active after Lua native loading
  - did Lua native loading closeout change behavior
  - does Lua native loading claim parser CLI corpus or generated source
date: 2026-07-15
status: current
tags: [lua, native-api, resolution, compilation, runtime, no-drift, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.2.4 inventories exact Lua exports, loader ownership, focused tests, neutral 14/9/4 fixture use, public docs, status, task metadata, and Knowledge Map; both ABIs remain 153/153, canonical CI passes CLI 61x2 and Phase 0 1..1031 in 607 seconds, parent .5.2 closes, and .5.3 activates without behavior/capability change."
reverify: "bash tools/run_lua_local.sh && perl tools/check_native_spec_resolution_contract.pl && perl tools/check_capability_conformance.pl && perl tools/check_language_capability_coverage.pl"
---

`LUA-BACKEND-PARITY.5.2.4` audits the complete Lua portable native-loading chain: typed name/path requests,
deterministic resolve/load and strict UTF-8, cached execution of the spec-owned function-shell grammar, staged body
dispatch, validation/compilation, typed `LoadedCompiledSpec`, source-identified engine construction, neutral
pipeline errors, focused tests, public status/docs, and later-owner fences. It finds no unowned implementation or
public-contract seam, so no second adapter or corrective source change is warranted.

PUC Lua and LuaJIT remain 153/153. The native contract remains 14 name-validation, nine resolution/file-kind, and
four text cases; capability stays 64/0/0 and coverage stays 246/105+1/122. The public status remains
`native-spec-pipeline-v1`. Closing parent `.5.2` changes no behavior, capability, or test count.

Outward function/rule descriptors and one-emitter loading/frontend/validation/compiler/function/staged/runtime
trace are now active under `.5.3`. Generated Lua source remains `.8`, corpus execution remains `.6`, and the exact
parser CLI remains `.7`; the native-loading closeout does not claim those surfaces.

Related facts: [[lua-native-spec-loading-split]], [[lua-native-spec-resolution]],
[[lua-spec-defined-function-parser]], [[lua-native-spec-pipeline]],
[[native-in-memory-backend-contract]], [[lua-backend-full-parity-plan]].
