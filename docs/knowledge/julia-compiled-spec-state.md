---
id: julia-compiled-spec-state
title: Julia compile_spec builds compiled rule, dependency-regex, and descriptor state
answers:
  - where is the Julia compiled spec state
  - does Julia have compile_spec
  - how does Julia project descriptor JSON
  - where does Julia build dependency regex data
  - does Julia compiled state carry action payload ASTs
date: 2026-07-10
status: current
tags: [julia, compiler, compiled-state, descriptor, dependency-regex, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.3.4 adds julia/src/compiler/CompiledSpec.jl and exports compile_spec plus CompiledSpec, CompiledRule, CompiledRuleModeMetadata, CompiledDependencyRegexState, CompiledDependencyRegexEntry, CompiledDescriptorState, compiled_rule(...), action_payloads(...), and to_descriptor_json(...). julia/test/runtests.jl verifies ordered rule state, redefinition metadata when validation is deliberately skipped, dependency-ref and dependency-regex derivation, lifecycle/action ActionBlock payloads, registry-aware contracts, source validation reuse, compiled-state diagnostics, function registry projection, and descriptor-shaped JSON. Runtime matching remains deferred to JULIA-BACKEND-PARITY.4.1."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

## Fact

Julia compiled-state construction lives in `julia/src/compiler/CompiledSpec.jl`.

`compile_spec(...)` validates a parsed `SpecFile` by default, builds an ordered `UserFunctionRegistry`, and returns
`CompiledSpec` with deterministic `definition_order`, `compiled_rule_order`, `rules_by_label`,
`redefined_rule_labels`, and `dependency_regex_state`. Each `CompiledRule` records regex patterns, dependency refs,
rule mode metadata, action/blind edges, lifecycle/plain `ActionBlock` payloads, original body elements, and
registry-aware ActionIR contract results.

`CompiledDependencyRegexState` derives structured dependency-regex rows from child rule regex slots. Julia stores
dependency refs plus pattern strings until runtime matching owns executable regex dispatch.

`CompiledDescriptorState` projects the public descriptor shape: `spec`, `functions`, `dependency_regex_map`, and
`meta`, with rule handlers marked as `julia_interpreter_rule` / `compiled_state_only`.

Related facts: [[julia-user-function-registry]], [[julia-actionir-contract-resolver]],
[[dart-compiled-spec-state]], [[julia-backend-interpreter-first-plan]], [[compilerstate-internal-model]].
