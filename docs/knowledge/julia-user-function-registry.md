---
id: julia-user-function-registry
title: Julia user-function registry preserves staged sidecars and callable metadata
answers:
  - where is the Julia user function registry
  - how does Julia preserve function body parse jobs
  - how does Julia resolve user function calls before helper fallback
  - does Julia stitch function body AST into registry records
  - does Julia classify exact arity user function calls
date: 2026-07-10
status: current
tags: [julia, actionir, functions, staged-parsing, registry, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.3.3 adds julia/src/action/FunctionRegistry.jl and registry-aware ActionIR contracts. JULIA-BACKEND-PARITY.5.1 adds deterministic staged function-body dispatch and immutable body_ast stitching through julia/src/parser/StagedParserRegistry.jl. JULIA-BACKEND-PARITY.5.2 executes exact-arity registry matches before helper fallback."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

## Historical implementation boundary

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

Compiled-spec state landed in `.3.4`, `.5.1` consumes the exposed job queue through the built-in staged provider
and returns a new spec with neutral JSON `body_ast` values, and `.5.2` executes exact-arity registry matches before
ordinary helper fallback.

Related facts: [[julia-actionir-contract-resolver]], [[julia-user-function-definition-projection]],
[[julia-compiled-spec-state]], [[dart-function-registry]], [[function-body-parse-job-sidecar]],
[[julia-staged-function-body-registry]], [[julia-staged-function-descriptor-shape]],
[[julia-user-function-runtime-execution]],
[[text-to-ast-backend-doctrine]].

## September 11 reading reconciliation

The first 94 lines preserve source order and zero-based entry indices, reject duplicate names, and expose
existing body jobs without executing them. Complete callable normalization was also read: it preserves the
definition and sidecars while rebuilding normalized body_ast through the complete registry.
The original exact-arity description above predates fixed/variadic signatures. Current arity and keyword
behavior is [[julia-variadic-user-functions]]; this reading runs its 55 assertions plus 23 registry assertions.
Registry resolution/stitching suffix reading remains the next child; these tests grant no unread-source credit.

The subsequent `.1.6` completes lines 95–235. `resolve_exact_user_function` accepts either a fixed exact
arity or a variadic signature's minimum; the name does not imply fixed-only resolution. Stitching requires
`replace_field`/`body_ast`, rejects a missing job, and returns a new SpecFile while retaining source, signature
and parameter-kind metadata. Descriptor versions distinguish fixed v1, variadic v2 and parameter-kind v3.
The unchanged registry 23 and variadic 55 assertions pass again alongside compiled-state/root controls;
replay and exact scope are [[julia-compiled-spec-state]]. This completes reading, not deferred repair work.

## September 11 registry consumer reading (.1.42)

The complete testset1333–1410 passes 23 assertions. It preserves source order,
zero-based indices, parse-job identity and fixed-arity resolution, then checks
immutable body stitching, duplicate rejection and registered arity diagnostics
before unknown-helper fallback. These fixed examples do not replace the separate
variadic or parameter-kind consumers. Exact combined replay is in
[[julia-runtime-rule-interpreter]], .1.42 below.
