---
id: lua-typed-source-location-dormant-red
title: Lua typed source location has one dormant shared dual-ABI RED consumer with nested core and projection modes
answers:
  - "where is the dormant Lua typed source location RED consumer"
  - "why does ordinary Lua discovery omit the typed source location consumer"
  - "what is the first Lua typed source location RED failure"
  - "how do I run the Lua typed source core RED on PUC Lua and LuaJIT"
  - "how do I run the Lua typed source projection RED on PUC Lua and LuaJIT"
  - "why is Lua typed source projection lookup nested after the immutable core"
  - "which Lua typed source API does the dormant consumer require"
  - "which Lua test freezes the 3 7 6 3 source location fixtures"
  - "which Lua test freezes the 92 plus 7 typed source projection catalogs"
  - "does the dormant Lua typed source consumer change current runtime behavior"
  - "where are the Lua typed source core projection and admission task leaves defined"
date: 2026-08-07
status: dormant RED frozen by FUTURE-PARITY-BACKLOG.14.2.5.0.2; core, projection, and admission pending
tags: [lua, PUC-Lua, LuaJIT, source-location, spans, cursor, helpers, RED, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.2.5.0.2 adds lua/test/typed_source_location_contract_test.lua at its final path while leaving it outside tools/run_lua_local.sh ordinary discovery and tools/run_ci_local.sh canonical registration. LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE selects core or projection. Both modes parse completely and exit 1 identically on PUC Lua and LuaJIT with the sole stable boundary 'Lua typed source RED: missing linkedspec.source_location'. Projection lookup is strictly after that module, so immutable core .14.2.5.1 can make core mode green and advance projection mode to missing linkedspec.typed_source_projection_rows. The consumer freezes exact 3/7/6/3 immutable fixtures, four private diagnostics, detached values, Unicode-scalar/UTF-8-byte evidence, 47/30/11/4 catalogs plus seven aliases, rule-local marks, anonymous capture boundary, cursor save/rewind/restore, and native/reconstructed/generated-plan results. Production, ordinary tests, current aliases, byte registers, external values, neutral 7/7/41, lua_dual_abi pending state, schemas, and sole-facing behavior do not move. Retrieval also found that parent .14.2.5 named .1-.3 but no explicit records had ever existed; .0.2 materializes their already-declared core/projection/admission boundaries before handoff."
evidence_update_2026_08_07_signoff: "Complete Lua preserves its byte-fresh 83166-byte MCP binding, alias 638/638 and package 177/177 per ABI, CLI 66x2, corpus 105/105, storage 18/3, language 246/105+1/122, and exact marker. The source-unchanged sole-facing book builds 79 files/14180 KiB with separate rendered blocks; Knowledge is 789/6504 and all seven doctrines pass. An initial canonical attempt reached process containment before the outer execution sandbox denied nested macOS sandbox-exec; the isolated proof passed with permission. One uninterrupted approved canonical rerun preserves capability 80/0/0 and typed source 7/7/41, executes all admitted typed-source and composed semantic/MCP consumers, proves six-family containment plus relocated/moved/outside-CWD execution, passes CLI 66x2, reports RAM 60%, and passes Phase 0 1031/1031 in 667 seconds before the exact local-CI marker and exit 0."
reverify: "lua -e 'assert(loadfile(\"lua/test/typed_source_location_contract_test.lua\"))' && luajit -e 'assert(loadfile(\"lua/test/typed_source_location_contract_test.lua\"))' && test ! -e lua/src/linkedspec/source_location.lua && ! rg -q 'typed_source_location_contract_test[.]lua' tools/run_lua_local.sh tools/run_ci_local.sh"
---

# Lua typed source-location dormant RED

The final-path consumer is `lua/test/typed_source_location_contract_test.lua`. Lua's ordinary test gate is an
explicit file list, so merely tracking the file does not execute it. The complete gate still syntax-checks every
Lua file, which proves the dormant consumer parses without admitting its future assertions.

Set `LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE` to `core` or `projection` and run through
`tools/run_lua_project_data.sh` with ABI `puc` or `luajit`. All four current combinations stop at the same private
missing-module boundary:

```text
Lua typed source RED: missing linkedspec.source_location
```

The consumer catches only Lua's ordinary module-not-found diagnostic for that exact name. Any syntax error or
other module load failure propagates unchanged. Projection catalog lookup is ordered after the core require; after
`.14.2.5.1` lands, projection mode must advance to the absent `linkedspec.typed_source_projection_rows` function
instead of hiding the remaining work behind the old core failure.

Core mode consumes all neutral decoded sources, positions, direct spans, derived texts, and the four value errors.
Projection mode additionally requires fresh detached 47/30/11/4 family catalogs plus seven aliases and proves
existing named-mark, anonymous-boundary, and cursor-stack results through native, reconstructed, and generated-plan
execution. It does not create a second interpreter or change the existing UTF-8-byte registers.

The parent had named `.14.2.5.1-.3` since the typed-source rollout plan, but history proves their concrete records
were never written. The RED slice materializes those exact core, projection, and admission leaves in the task tree
so the next activation has a durable frontier rather than an implicit conversational handoff.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.14.2.5.0.2`.
- Architecture and rollout: [[typed-source-location-runtime-rollout-plan]].
- Neutral fixtures: [[typed-source-location-neutral-contract-plan]].
- Alias prerequisite: [[lua-typed-source-compatibility-alias-gap]].
- Runtime state and carriers: [[lua-runtime-matching-state]], [[lua-capture-cursor-runtime-audit]],
  [[lua-generated-source-family-plan]], and [[lua-native-spec-pipeline]].
