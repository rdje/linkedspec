---
id: julia-variadic-user-functions
title: Julia preserves v1 fixed functions and executes v2 variadic functions natively and from generated state
answers:
  - "does Julia support variadic user functions"
  - "where does Julia bind a rest parameter"
  - "does Julia evaluate variadic arguments left to right"
  - "are Julia rest arrays fresh per invocation"
  - "does Julia preserve variadic signatures in staged records"
  - "does Julia generated source preserve callable signatures"
  - "does Julia allow keyword arguments for user functions"
date: 2026-07-12
status: current
tags: [julia, functions, variadic, rest-parameter, descriptor, staged-parsing, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.4.3.2 updates Julia AST/staged projection, validation, registry/action resolution, runtime, descriptors, and normalized emitted state. The 55 assertions in variadic_user_function_contract_test.jl consume the unchanged neutral fixture; tools/run_julia_local.sh passes all package tests, 61x2 CLI, and 105 corpus fixtures."
evidence_update_2026_07_18_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.6.4 migrates the unchanged variadic generated-plan and independently emitted roles to contract-v2 source."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/variadic_user_function_contract_test.jl\")'"
---

Julia accepts `fn name(fixed, ...rest) { ... }` through the shared spec-defined shell. A typed
`CallableSignature` survives `FunctionDefinition`, `StagedParseJob`, registry entries, exact descriptor projection,
normalized source-emitter JSON, generated-plan execution, and generated-state reconstruction. Internally derived
prefix params and minimum arity reuse the established execution model; v2 staged/public records omit those legacy
keys and expose only the authoritative signature. Fixed v1 records remain unchanged.

The registry accepts an argument count when it equals fixed v1 arity or meets v2 `min_arity`. ActionIR and runtime
resolution reject keyword arguments for registered functions, so Julia keyword-call or dispatch behavior does not
enter the `.spec` contract. Accepted arguments evaluate once left-to-right in caller scope. The runtime swaps in
fresh scalar, array, and hash stores, binds fixed params, and stores a newly allocated, recursively copied
`Vector{Any}` of all extras under the rest name in both scalar and typed-array views. Empty, nested, hash, boolean,
and null values preserve their shapes.

`emit_julia_source_v2` needs no host splat logic: normalized `SpecFile` JSON emits the exact v1/v2 callable union as strict
UTF-8 bytes represented by ASCII hex. The generated module reconstructs `SpecFile` and compiles and executes the
same runtime. The neutral fixture passes both direct generated-plan execution and serialization round-trip.

Related facts: [[variadic-user-function-contract]], [[julia-user-function-definition-projection]],
[[julia-user-function-registry]], [[julia-user-function-runtime-execution]], [[julia-generated-source-scaffold]],
[[dart-variadic-user-functions]], [[rust-variadic-user-functions]].

## September 11 — consumer reading and emitted-carrier qualification .1.51

All181 lines are read and55 assertions pass. Fixed/v2 signature unions and exact
staged/descriptor fields survive generated plans and emitted payload reconstruction.
The latter extracts _COMPILED_SPEC_JSON_HEX, decodes SpecFile, recompiles and runs
the native engine; this consumer never independently loads the emitted module.
The historical independently-emitted wording in the generated-v2 update above
is therefore too broad for this permanent target. General emitted-host evidence
lives in the separate source-emitter suite; no new variadic host proof is claimed.
Arguments execute once left-to-right; independent calls receive fresh rest arrays.
Malformed definitions, fixed/minimum arity and keyword-resolution errors retain
their covered boundaries. Neutral3 definitions/9 calls/7 invalid definitions pass.
Previously owned callable/identifier repairs stay open. Replay: [[write-vivification-julia-runtime]].
