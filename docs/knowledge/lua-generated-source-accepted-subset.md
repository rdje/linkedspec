---
id: lua-generated-source-accepted-subset
title: Generated Lua passes the exact contract-ordered interpreter-first 8/105 subset in fresh dual-ABI hosts
answers:
  - does generated Lua pass the accepted 8/105 subset
  - where do the generated Lua accepted subset names come from
  - does Lua compare interpreter values before emitting source
  - how are accepted subset generated Lua modules loaded independently
  - what does the generated source checker enforce for Lua
  - does the generated Lua subset preserve user functions
  - which Lua runtimes run the generated source subset
  - what remains before Lua generated source enters the capability census
date: 2026-07-16
status: current
tags: [lua, generated-source, corpus, accepted-subset, interpreter-oracle, PUC-Lua, LuaJIT, contract]
evidence: "LUA-BACKEND-PARITY.8.3 adds corpus_proof.lua_accepted_subset_test to capability_conformance/generated_source_contract.json and checker enforcement for exact count, contract list/order, full-manifest validation, interpreter-before-emission proof, independent load/run, metadata/plans/trace identity, caller-owned cleanup, and unconditional registration. lua/test/run.lua validates all 105 fixtures, consumes the eight contract names directly, proves expected interpreter values, emits eight source-identified modules, and launches the exact selected PUC Lua or LuaJIT ABI host with explicit package/native paths. The host loads each module, validates plans, returns exact ordered value/metadata/plan observations, executes the fixed user-function fixture, observes portable first-case trace identity, emits empty stderr, and cleans its root. Both ABIs pass 177/177; primary is 61x2, corpus 105/105, capability 64/0/0, and canonical Phase 0 1031/1031 in 620 seconds."
reverify: "bash tools/run_lua_local.sh; perl tools/check_generated_source_contract.pl; rg -n 'LUA_GENERATED_SOURCE_ACCEPTED_SUBSET_COUNT|contract.corpus_proof.accepted_subset|generated Lua source matches the contract accepted manifest subset|lua_accepted_subset_test' lua/test/run.lua tools/check_generated_source_contract.pl capability_conformance/generated_source_contract.json"
---

Lua reads the accepted names directly from
`capability_conformance/generated_source_contract.json`; no duplicate Lua list
owns selection or order. `load_corpus_fixtures(...)` validates the complete
105-fixture manifest and directory/file/UTF-8/JSON boundary before the test
looks up those eight rows.

For every contract row, the native interpreter runs first and its direct value
must equal the fixture's expected JSON. Only then does the test emit one
source-identified Lua module and record its expected metadata and typed plan.
This preserves the contract's proof order instead of using generated output as
its own oracle.

One caller-owned temporary root contains the eight modules, observation JSON,
and a host runner. The focused gate passes its exact current PUC Lua or LuaJIT
executable plus explicit `LUA_PATH`/`LUA_CPATH`; the fresh process loads every
module with `loadfile`, validates each plan, executes each input, and returns
exact ordered value/metadata/plan observations. The subset includes
`terse_4_3_2_user_function_runtime`, so fixed function definitions and calls
are reconstructed and executed rather than merely serialized.

The first module also runs traced execution and requires
`generated_rule_enter`, `generated_family_decision`, and
`generated_rule_exit` with its exact source identity. Stdout is exact JSON,
stderr is empty, and the caller-owned root must be absent afterward.

The executable contract checker owns the Lua test path and statically enforces
the count, contract consumption/order, full validation, proof order, fresh
load, metadata/plan projection, trace identity, cleanup, and unconditional test
registration. This closes `.8.3`; only capability-census admission and backend
handoff `.8.4` remain.

Related facts: [[generated-source-contract-v1]],
[[lua-generated-source-family-plan]], [[lua-generated-source-emitter-core]],
[[lua-generated-source-fresh-process-isolation]],
[[lua-backend-full-parity-plan]].
