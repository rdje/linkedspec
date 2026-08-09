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
status: private core and projections implemented through FUTURE-PARITY-BACKLOG.14.2.5.2; admission pending
tags: [lua, PUC-Lua, LuaJIT, source-location, spans, cursor, helpers, RED, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.2.5.0.2 adds lua/test/typed_source_location_contract_test.lua at its final path while leaving it outside tools/run_lua_local.sh ordinary discovery and tools/run_ci_local.sh canonical registration. LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE selects core or projection. Both modes parse completely and exit 1 identically on PUC Lua and LuaJIT with the sole stable boundary 'Lua typed source RED: missing linkedspec.source_location'. Projection lookup is strictly after that module, so immutable core .14.2.5.1 can make core mode green and advance projection mode to missing linkedspec.typed_source_projection_rows. The consumer freezes exact 3/7/6/3 immutable fixtures, four private diagnostics, detached values, Unicode-scalar/UTF-8-byte evidence, 47/30/11/4 catalogs plus seven aliases, rule-local marks, anonymous capture boundary, cursor save/rewind/restore, and native/reconstructed/generated-plan results. Production, ordinary tests, current aliases, byte registers, external values, neutral 7/7/41, lua_dual_abi pending state, schemas, and sole-facing behavior do not move. Retrieval also found that parent .14.2.5 named .1-.3 but no explicit records had ever existed; .0.2 materializes their already-declared core/projection/admission boundaries before handoff."
evidence_update_2026_08_07_signoff: "Complete Lua preserves its byte-fresh 83166-byte MCP binding, alias 638/638 and package 177/177 per ABI, CLI 66x2, corpus 105/105, storage 18/3, language 246/105+1/122, and exact marker. The source-unchanged sole-facing book builds 79 files/14180 KiB with separate rendered blocks; Knowledge is 789/6504 and all seven doctrines pass. An initial canonical attempt reached process containment before the outer execution sandbox denied nested macOS sandbox-exec; the isolated proof passed with permission. One uninterrupted approved canonical rerun preserves capability 80/0/0 and typed source 7/7/41, executes all admitted typed-source and composed semantic/MCP consumers, proves six-family containment plus relocated/moved/outside-CWD execution, passes CLI 66x2, reports RAM 60%, and passes Phase 0 1031/1031 in 667 seconds before the exact local-CI marker and exit 0."
evidence_update_2026_08_07_core: "FUTURE-PARITY-BACKLOG.14.2.5.1 adds private lua/src/linkedspec/source_location.lua without exporting it from linkedspec/init.lua. One copied decoded-source authority owns validated UTF-8 text, a monotonic opaque identity, and Unicode-scalar boundary tables for zero-based UTF-8 bytes plus one-based line/column. Opaque Position, Span, DerivedText, context, and exception tokens keep all state in module-private weak-key storage; values retain no decoded text, path, parser/match object, or authority reference, and fresh json.harray/json.array records are detached. The authority alone validates coordinates and materializes same-source spans or concatenate_in_order provenance with only the four neutral private errors. Explicit core mode passes 133/133 on PUC Lua and LuaJIT. Projection mode advances identically to the sole missing linkedspec.typed_source_projection_rows API, while ordinary discovery, public helper routes/results, UTF-8-byte registers, neutral 7/7/41, and sole-facing admission truth remain unchanged."
evidence_update_2026_08_07_core_signoff: "Complete Lua preserves byte-fresh MCP 83166 bytes, package 177/177 and aliases 638/638 per ABI, CLI 66x2, corpus 105/105, storage 18/3, language 246/105+1/122, and its exact marker. Four synchronized sole-facing pages distinguish implemented private core from pending routing/admission; the 79-file/14180-KiB HTML keeps separate status/following blocks. Knowledge is 789/6504 and all seven doctrines pass. Definitive canonical CI preserves capability 80/0/0 and typed source 7/7/41, executes admitted typed-source plus every composed semantic/MCP consumer, proves six-family containment and relocated/moved/outside-CWD execution, passes CLI 66x2, reports RAM 65%, and passes Phase 0 1031/1031 in 672 seconds before the exact local-CI marker."
evidence_update_2026_08_07_projections: "FUTURE-PARITY-BACKLOG.14.2.5.2 gives each runtime input one copied private authority and exports fresh exact detached 47/30/11/4 projection rows plus seven aliases through engine-validated package functions. Entry/local-match text, positions, lengths, and coordinates; input/cursor views; anonymous and named spans; mark/capture-boundary reads and writes; rule-slot marks; and cursor controls now construct typed positions/spans and use authority-owned coordinates/materialization. Capture-group value/list/map/existence adapters retain their detached compatibility shapes. Existing UTF-8-byte cursor, match, capture-start, named-mark, and stack registers plus all public results and mutation timing remain unchanged. Core passes 133/133 and projection passes 240/240 on PUC Lua and LuaJIT across native, reconstructed, and generated-plan routes; aliases remain 638/638 per ABI across loaded and independently emitted execution. Ordinary/canonical discovery and neutral 7/7/41 remain pending exclusively for .14.2.5.3."
evidence_update_2026_08_07_projection_signoff: "The sole-facing book documents implemented-but-unadmitted Lua projection in four current pages and renders 79 files/14188 KiB with changed prose and commands in separate blocks. Knowledge remains 789/6504 and all seven doctrines pass. The definitive canonical rerun preserves capability 80/0/0, typed source 7/7/41, semantic 6 groups/20 responses/128 mutations/9 complete/6 admitted, MCP complete/141, containment and relocation, CLI 66x2, RAM 65%, and Phase 0 1031/1031 in 662 seconds before the exact local-CI marker. Two earlier attempts correctly caught and led to repair of exact governed capability/semantic wording lost from refreshed summary rows; no behavior or rollout state changed."
reverify: "LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE=core bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua && LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE=core bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua && LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE=projection bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua && LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE=projection bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua && ! rg -q 'typed_source_location_contract_test[.]lua' tools/run_lua_local.sh tools/run_ci_local.sh"
---

# Lua typed source-location dormant RED

The final-path consumer is `lua/test/typed_source_location_contract_test.lua`. Lua's ordinary test gate is an
explicit file list, so merely tracking the file does not execute it. The complete gate still syntax-checks every
Lua file, which proves the dormant consumer parses without admitting its future assertions.

Set `LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE` to `core` or `projection` and run through
`tools/run_lua_project_data.sh` with ABI `puc` or `luajit`. The two core combinations pass 133/133 assertions and
the two projection combinations pass 240/240. The unchanged consumer remains dormant only because ordinary and
canonical discovery do not admit it until `.14.2.5.3`.

The value core remains a private direct module. Each runtime execution context now constructs one private adapter
over one copied `input` authority, and the package root exposes only the engine-validated detached projection and
alias catalogs required by the frozen consumer. No typed token becomes an authored runtime value.

Core mode consumes all neutral decoded sources, positions, direct spans, derived texts, and the four value errors.
Projection mode consumes fresh detached 47/30/11/4 family catalogs plus seven aliases and proves existing named-
mark, anonymous-boundary, and cursor-stack results through native, reconstructed, and generated-plan execution.
The dedicated alias consumer retains loaded and independently emitted proof. The implementation does not create a
second interpreter or change existing UTF-8-byte registers, values, or mutation timing.

The parent had named `.14.2.5.1-.3` since the typed-source rollout plan, but history proves their concrete records
were never written. The RED slice materialized those exact core, projection, and admission leaves in the task tree;
the private core and routing are now implemented, while admission remains the separate durable frontier.

## Links

- Owners: [[FUTURE-PARITY-BACKLOG]] `.14.2.5.0.2` (frozen consumer), `.14.2.5.1` (private core), and
  `.14.2.5.2` (typed projections).
- Architecture and rollout: [[typed-source-location-runtime-rollout-plan]].
- Neutral fixtures: [[typed-source-location-neutral-contract-plan]].
- Alias prerequisite: [[lua-typed-source-compatibility-alias-gap]].
- Runtime state and carriers: [[lua-runtime-matching-state]], [[lua-capture-cursor-runtime-audit]],
  [[lua-generated-source-family-plan]], and [[lua-native-spec-pipeline]].
