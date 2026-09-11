---
id: julia-compiled-spec-state
title: Julia compile_spec builds compiled rule, dependency-regex, and descriptor state
answers:
  - where is the Julia compiled spec state
  - does Julia have compile_spec
  - how does Julia project descriptor JSON
  - where does Julia build dependency regex data
  - does Julia compiled state carry action payload ASTs
  - does Julia descriptor preserve staged function payload jobs and body AST
date: 2026-07-10
status: current
tags: [julia, compiler, compiled-state, descriptor, dependency-regex, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.3.4 adds julia/src/compiler/CompiledSpec.jl and exports compile_spec plus CompiledSpec, CompiledRule, CompiledRuleModeMetadata, CompiledDependencyRegexState, CompiledDependencyRegexEntry, CompiledDescriptorState, compiled_rule(...), action_payloads(...), and to_descriptor_json(...). JULIA-BACKEND-PARITY.5.3 adds an executable 20-assertion proof that spec-returned function order, normalized staged payload/jobs, stitched body_ast, descriptor function metadata, and runtime output survive through the compiled state. Existing tests cover ordered rule state, dependency-regex derivation, lifecycle/action payloads, registry-aware contracts, validation reuse, and diagnostics."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

## Fact

Julia compiled-state construction lives in `julia/src/compiler/CompiledSpec.jl`.

`compile_spec(...)` validates a parsed `SpecFile` by default, builds an ordered `UserFunctionRegistry`, and returns
`CompiledSpec` with deterministic `definition_order`, `compiled_rule_order`, `rules_by_label`,
`redefined_rule_labels`, and `dependency_regex_state`. Each `CompiledRule` records regex patterns, dependency refs,
rule mode metadata, action/blind edges, lifecycle/plain `ActionBlock` payloads, original body elements, and
registry-aware ActionIR contract results.

`CompiledDependencyRegexState` derives structured dependency-regex rows from child rule regex slots. Julia stores
dependency refs plus pattern strings; runtime matching now compiles those pattern lists in
`julia/src/runtime/Matching.jl`.

`CompiledDescriptorState` projects the public descriptor shape: `spec`, `functions`, `dependency_regex_map`, and
`meta`, with rule handlers marked as `julia_interpreter_rule` / `compiled_state_only`.

`.5.3` proves the `functions` projection against executable staged state: `body_payload` source provenance,
normalized `body_parse_job`, stitched `body_ast`, and `meta.function_order` / `meta.function_count` survive from
spec-returned definition nodes through compile and runtime without Julia-specific fields.

Related facts: [[julia-staged-function-descriptor-shape]], [[julia-runtime-matching-state]], [[julia-user-function-registry]], [[julia-actionir-contract-resolver]],
[[dart-compiled-spec-state]], [[julia-backend-interpreter-first-plan]], [[compilerstate-internal-model]].

## September 11 bounded reading and focused replay

`JULIA-STARTUP-READING.1.6` reads `CompiledSpec.jl` through line 521, after completing the function
registry and primary CLI. This prefix defines the typed compiled records, shallow collection copies,
ordered entry selection, removed-selector traversal and nested-write carrier validation. The receiver-mutation
validator starts here and continues in the next child. Existing callable-body selector repair `.2.1` stays open;
the prefix's validation docstring does not establish complete recursive coverage.

At activation `a858b781d8befc5cf5ba3af2932e4e9877d6fcf3`, the unchanged registry, compiled-state,
root-selection and variadic suites pass 23/41/79/55 assertions. The selected-set assertion separately
ensures both requested embedded testsets actually execute. This replay evaluates existing helper definitions
and only the named testsets from `runtests.jl`; parsing the rest gives no source-reading credit.
The unchanged primary-process checker passes all ten families. These are focused results, not a complete
Julia gate or fresh cross-backend admission.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP6_PROOF'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const DESCRIPTOR_CONTRACT=JSON3.read(read(joinpath(REPO_ROOT,"capability_conformance/outward_descriptor_contract.json"),String),Dict{String,Any})
const selected=Set(["User function registry","Compiled spec state"])
const seen=Set{String}()
const parsed=Meta.parseall(read("julia/test/runtests.jl",String))
for expression in parsed.args
    expression isa Expr || continue
    if expression.head == :function
        Core.eval(Main,expression)
    elseif expression.head == :macrocall && expression.args[1] == Symbol("@testset")
        label=expression.args[3]
        if label in selected
            Core.eval(Main,expression)
            push!(seen,label)
        end
    end
end
@test seen == selected
include("julia/test/root_rule_selection_core_test.jl")
include("julia/test/variadic_user_function_contract_test.jl")
JULIA_GROUP6_PROOF
bash tools/check_julia_primary_cli.sh
```

Exact baseline/current byte and range proof remains [[julia-startup-reading-coverage]]. The suite expectations
are checked-in independent controls for the reading conclusions; no new behavioral oracle or production change
is introduced by this checkpoint.
