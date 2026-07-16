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
evidence_update_2026_07_15_descriptor_trace: "Later .5.3.1/.2 complete exact descriptors and one-emitter full native-pipeline trace at 155/155 on both ABIs; .5.3.3 closes no-drift and activates corpus .6.1."
evidence_update_2026_07_15_primary_cli: "LUA-BACKEND-PARITY.7.1 later consumes this native loader directly for named/path primary requests and implements the exact thin command at 169/169 per ABI plus diagnostic shared CLI 61x2."
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
trace are now implemented through `.5.3.1/.2`; `.5.3.3` closes no-drift. Generated Lua source remains `.8`, corpus
execution is active under `.6.1`, and the exact parser CLI remains `.7`; the native-loading closeout does not
claim those surfaces. `.6.3` and `.7.1` have since implemented the full corpus and thin primary adapter without
changing the loader ownership described here.

Related facts: [[lua-native-spec-loading-split]], [[lua-native-spec-resolution]],
[[lua-spec-defined-function-parser]], [[lua-native-spec-pipeline]],
[[native-in-memory-backend-contract]], [[lua-backend-full-parity-plan]],
[[lua-native-full-pipeline-trace]], [[lua-primary-cli-adapter]].
