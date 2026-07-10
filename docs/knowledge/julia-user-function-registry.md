---
id: julia-user-function-registry
title: Julia user-function registry preserves staged sidecars and resolves exact-arity calls before helper fallback
answers:
  - where is the Julia user function registry
  - how does Julia preserve function body parse jobs
  - how does Julia resolve user function calls before helper fallback
  - does Julia stitch function body AST into registry records
  - does Julia classify exact arity user function calls
date: 2026-07-10
status: current
tags: [julia, actionir, functions, staged-parsing, registry, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.3.3 adds julia/src/action/FunctionRegistry.jl, exports UserFunctionRegistry/UserFunctionEntry/UserFunctionCallResolution, and threads optional registry input through the ActionIR contract resolver. julia/test/runtests.jl verifies ordered entries, staged body_parse_job exposure, body_payload/body_ast preservation, exact match, wrong arity, missing name, duplicate-name rejection, immutable body_ast stitching through stitch_function_body_ast(...), and registry-aware ActionIR contract diagnostics. Runtime execution remains deferred to later Julia leaves."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

## Fact

Julia's user-function registry lives in `julia/src/action/FunctionRegistry.jl`.

`user_function_registry_from_spec(...)` and `user_function_registry_from_functions(...)` build ordered
`UserFunctionEntry` records from `FunctionDefinition` values. Each entry preserves params, arity, source/body spans,
`body_payload`, `body_parse_job`, and optional stitched `body_ast`. The registry exposes `body_parse_jobs(...)` for
the staged function-body parse queue, and `stitch_function_body_ast(...)` returns a new `SpecFile` with a parsed
function body stored under the job's `replace_field` / `body_ast` policy.

`resolve_user_function_call(...)` reports exact matches, missing names, and registered-name arity mismatches without
running function bodies. The ActionIR contract resolver accepts optional `function_registry` input; with that registry,
exact-arity calls classify as `family = "user_function"` before helper fallback, while wrong-arity registered calls
emit `user_function_arity_mismatch`.

This is a registry and contract-classification seam only. Compiled-spec state, staged parser execution, runtime
interpretation, diagnostics/trace breadth, and corpus execution remain later Julia leaves.

Related facts: [[julia-actionir-contract-resolver]], [[julia-user-function-definition-projection]],
[[dart-function-registry]], [[function-body-parse-job-sidecar]], [[text-to-ast-backend-doctrine]].
