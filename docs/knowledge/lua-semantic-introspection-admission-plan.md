---
id: lua-semantic-introspection-admission-plan
title: Lua semantic admission must use one identical ordered consumer on both ABIs
answers:
  - "how will Lua semantic introspection be admitted"
  - "which test will admit Lua semantic introspection"
  - "does PUC Lua use a different semantic admission consumer from LuaJIT"
  - "how many Lua semantic admission roles are required"
  - "which Lua semantic routes must the admission consumer compose"
  - "how will both Lua semantic admission rows be locked"
  - "how many mutations will Lua semantic admission add"
  - "what semantic governance changes are allowed during Lua admission"
  - "what is the current Lua semantic admission baseline"
date: 2026-07-28
status: active behavior-free plan; implementation follows the clean activation commit
tags: [lua, luajit, semantic-introspection, admission, conformance, mutations, rollout, parity]
evidence: "FUTURE-PARITY-BACKLOG.10.7.7 is activated from clean 17348041 after retrieval of the four admitted consumers and the committed Lua semantic/runtime owner chain. Its frozen target is lua/test/semantic_introspection_lua_admission_test.lua, one Lua-5.1-compatible twelve-role source run unchanged by PUC Lua and LuaJIT. Both admission rows must reference its identical path/driver/roles topology; nine independent mutations lock both statuses plus path, role order, driver, rollout, and canonical registration. Baseline remains 6 groups / 20 responses / 89 mutations at rollout 5/9 and admission 4/6 until implementation."
last_verified: 2026-07-28
reverify:
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "rg -n 'FUTURE-PARITY-BACKLOG\\.10\\.7\\.7|semantic_introspection_lua_admission_test|LUA COMPOSED ADMISSION PLAN' docs/tasks/FUTURE-PARITY-BACKLOG.md TOOLBOX.md docs/linkedspec-book/src/public-api/semantic-introspection.md"
---

# Lua semantic-introspection admission plan

Lua admission is composition, not another implementation layer. The planned consumer calls only the committed
strict source/outcome owner, static and calls/staged/generated projection, immutable typed/raw-neutral evaluator,
invocation-local observation sink, detached observed-index derivation, generated helpers, emitted modules, and
isolated host routes.

One additive `lua/test/semantic_introspection_lua_admission_test.lua` file owns the established ordered roles:

1. `source_normalization`
2. `compiled_snapshots`
3. `failed_snapshot`
4. `runtime_direct`
5. `runtime_loaded`
6. `runtime_generated`
7. `runtime_traced`
8. `native_and_neutral_json`
9. `exact_twenty_queries`
10. `privacy_page_budget_error_explain`
11. `query_non_interference`
12. `stale_host_leak_denial`

The source must remain compatible with Lua 5.1 syntax and execute unchanged on PUC Lua and LuaJIT. The two
contract admission rows therefore carry the same consumer path, `tools/run_ci_local.sh` driver, and role list;
`tools/run_lua_local.sh` invokes that same path once per ABI. Runtime coverage includes direct, loaded,
normalized-JSON reconstructed, public generated-plan, fresh-emitted direct/traced, isolated emitted, native traced,
and generated-helper traced routes. All twenty response digests, source/privacy/page/budget/error/explain policy,
request/response isolation, query non-execution, and denial of path, host table/metatable, implementation/type,
AST/ActionIR, observation-object, generated-source, trace, and pointer leakage must pass.

The governance change is deliberately narrow. Both Lua admission statuses and only the `lua_dual_abi` rollout row
may advance. Nine mutations independently roll back each ABI status, omit or alter the shared path, omit or reorder
roles, alter the driver, roll back Lua rollout, and omit canonical registration. Recurring six-runtime proof, MCP,
and public no-drift remain pending. Before implementation the exact neutral state is six fixture groups, twenty
response hashes, 89 rejected mutations, rollout 5/9, and native admission 4/6.

Related facts: [[semantic-introspection-neutral-contract]], [[lua-semantic-introspection-authority-map]],
[[lua-semantic-query-public-api]], [[lua-semantic-runtime-observation-authority-map]],
[[lua-semantic-runtime-observation-generated-routes]], [[perl-semantic-introspection-admission]],
[[rust-semantic-introspection-admission]], [[dart-semantic-introspection-admission]], and
[[julia-semantic-introspection-admission]].
