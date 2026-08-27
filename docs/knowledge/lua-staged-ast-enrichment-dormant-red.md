---
id: lua-staged-ast-enrichment-dormant-red
title: Lua general staged-AST enrichment has one shared dual-ABI dormant marker/provenance RED
answers:
  - "what is the Lua staged AST enrichment dormant RED"
  - "where is the Lua staged AST enrichment contract test"
  - "how do I run the Lua staged AST enrichment dormant consumer"
  - "does ordinary Lua discovery run staged AST enrichment"
  - "does canonical CI run the Lua staged AST enrichment consumer"
  - "how does Lua compile parse_job before its dedicated marker"
  - "what error does Lua parse_job produce"
  - "which Lua carriers preserve the staged AST enrichment RED"
  - "does Lua function body staged parsing still work"
  - "does the same staged AST test run on PUC Lua and LuaJIT"
  - "what does FUTURE-PARITY-BACKLOG 14.7.7.0 own"
date: 2026-08-27
status: current shared dual-ABI dormant RED; marker/provenance owner .14.7.7.1 is next
tags: [lua, PUC-Lua, LuaJIT, staged-parsing, parse-job, red-test, generated-source, governance]
evidence: "FUTURE-PARITY-BACKLOG.14.7.7.0 adds one Lua-5.1-compatible consumer at lua/test/staged_ast_enrichment_contract_test.lua and executes the unchanged bytes independently on PUC Lua and LuaJIT. Each run passes 153 assertions over the complete 98-mutation neutral inventory, unchanged function-body-v1 resolve/load/compile/execute/cache/stitch behavior and wrong-top context, generic assign_scalar/call parse_job structure, narrow expr-v1 registry denial, and native/SpecFile-JSON reconstructed/validated generated-plan/independently loaded emitted-module unsupported-helper observations. The only failure is the labeled missing STAGED_PARSE_JOB_MARKER/staged_parse_job_v2 assertion. tools/run_lua_local.sh, lua/test/run.lua, and canonical CI omit the consumer; both Lua rollout legs remain pending; no Lua production source, generated format, or public/outward surface moves."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua"
  - "rg -n 'LINKEDSPEC_STAGED_AST_ENRICHMENT_LUA_RED|STAGED_PARSE_JOB_MARKER|staged_parse_job_v2|unsupported runtime helper' lua/test/staged_ast_enrichment_contract_test.lua"
  - "rg -n 'staged_ast_enrichment_contract_test.lua' tools/run_lua_local.sh lua/test/run.lua tools/run_ci_local.sh"
---

# Shared Lua staged-AST enrichment dormant boundary

The stable consumer path is `lua/test/staged_ast_enrichment_contract_test.lua`. It is ordinary Lua source with no
ABI-specific branch: the repository-local wrapper runs the same file independently on PUC Lua and LuaJIT. The
file deliberately stays absent from `tools/run_lua_local.sh`, `lua/test/run.lua`, and canonical CI until admission
owner `.14.7.7.4` moves the unchanged final path.

Assignment-form `parse_job(...)` currently compiles as one `assign_scalar` whose value is the generic `call` named
`parse_job`. Its two operands remain the generic `entry_group` and `hash` calls, helper-contract analysis records
one `unknown_helper`, and no dedicated `staged_parse_job_marker` or typed `staged_parse_job_v2` sidecar exists.
The narrow function-body-v1 registry still accepts only `actionir-body.spec` / `action_block` and rejects general
`expr-v1` during resolve.

Native and normalized `SpecFile`-JSON reconstructed execution return the same typed
`RuntimeInterpreterException` for unsupported helper `parse_job`. Validated generated-plan execution wraps that
same detail as `generated_execution_failed`; an independently loaded emitted Lua module reaches the identical
generated boundary and preserves its source identity. Emitted source contains none of the neutral marker,
sidecar, or staged-contract identities.

Each ABI reports 153 GREEN assertions and one intentional RED. Leaf `.14.7.7.1` owns only the dedicated inert
annotation/provenance carrier. `.2` owns caller-frozen resolution/cache and all policies; `.3` owns breadth-first
recurrence, bounds, rebasing, and fresh dormant carriers; `.4` alone owns ordinary/canonical dual-ABI admission and
rollout; `.5` independently recomposes the two admitted ABI routes and closes the shared parent.

Related: [[general-staged-ast-enrichment-neutral-contract]], [[general-staged-ast-current-boundary]],
[[lua-staged-function-body-registry]], [[lua-progressive-span-dispatch-dormant-red]], and
[[function-body-staged-registry-dispatch]].
