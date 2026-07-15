---
id: lua-user-function-registry
title: Lua preserves staged user-function records and prepares isolated exact-arity invocation frames
answers:
  - where is the Lua user function registry
  - how does Lua preserve function body parse jobs
  - how does Lua stitch function body ASTs
  - how does Lua resolve user functions before helpers
  - how does Lua prepare user function invocation frames
  - do Lua user functions capture caller stores or closures
  - how does Lua diagnose user function recursion
date: 2026-07-11
status: current
tags: [lua, actionir, functions, staged-parsing, registry, runtime-boundary]
evidence: "LUA-BACKEND-PARITY.3.3 adds lua/src/linkedspec/user_function_registry.lua and 4 focused tests; .3.4 carries it into compiled state/descriptors; .4.1 adds matching. The full Lua gate passes 60/60 on PUC Lua and LuaJIT; exact 239-name and 105-fixture coverage remains green."
evidence_update_2026_07_15_staged_dispatch: "LUA-BACKEND-PARITY.5.1.1 adds the separate staged parser registry over these preserved jobs and stitch seam; PUC Lua and LuaJIT pass 130/130 with status runtime-staged-registry."
reverify: "bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl"
---

## Fact

`lua/src/linkedspec/user_function_registry.lua` owns typed
`UserFunctionRegistry`, `UserFunctionEntry`, `UserFunctionCallResolution`,
`UserFunctionInvocationFrame`, and registry-error records.

`user_function_registry_from_spec(...)` and
`user_function_registry_from_functions(...)` snapshot ordered typed function
definitions. Each entry preserves params, arity, source/body spans,
`body_source`, `body_payload`, `body_parse_job`, and optional `body_ast`.
Duplicate names are rejected. `body_parse_jobs()` exposes the ordered staged
queue, while neutral JSON and descriptor projections preserve the same fields
as the other variants.

`stitch_function_body_ast(spec, job_id, body_ast)` validates the staged job's
`replace_field` / `body_ast` policy and returns a new `SpecFile`; neither the
source spec nor the caller's AST table is mutated. The registry's
`resolve_call(name, arity)` is the concrete `.3.2` registry-first interface:
exact registered calls classify before helper fallback and registered-name
arity drift stays explicit.

`prepare_user_function_invocation(...)` is a pre-execution data boundary. Its
argument list contains already-evaluated values, so the later runtime owns
evaluation order. It accepts only scalar, typed array, typed harray, and typed
codeblock values; recursively copies mutable aggregates, reparses codeblock
source into an independent AST, and creates fresh variable/array/harray stores.
It accepts no caller-store object and rejects Lua functions, ambiguous plain
tables, and cycles, so there is no implicit caller mutation or host closure
capture. Active-name recursion is rejected with typed stage, rule, helper,
handler-source, and cycle identity.

This `.3.3` leaf did not dispatch staged jobs or execute function bodies. The separate
`.5.1.1` registry now dispatches and stitches them without changing this registry's ownership;
fixed-v1 execution remains active `.5.1.2`. `FUTURE-PARITY-BACKLOG.4.4` routes the adopted variadic-v2 signature to
dependency-complete `LUA-BACKEND-PARITY.5.1`; this completed exact-v1 registry leaf is not retroactively an
execution claim. Descriptor admission follows in `.5.3`, with generated preservation/execution under `.8`.

Related facts: [[lua-function-definition-shell-projection]],
[[lua-staged-function-body-registry]],
[[lua-actionir-contract-resolver]], [[julia-user-function-registry]],
[[dart-function-registry]], [[function-body-parse-job-sidecar]],
[[text-to-ast-backend-doctrine]].
See also [[lua-variadic-user-function-routing]].
