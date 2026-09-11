---
id: julia-runtime-structured-diagnostics
title: Julia runtime failures carry RuntimeDiagnostic payloads on RuntimeInterpreterException
answers:
  - does Julia runtime expose structured diagnostics
  - what is Julia RuntimeDiagnostic
  - where are Julia runtime diagnostic fields
  - does Julia runtime change successful parse output for diagnostics
  - how does Julia preserve runtime child rule attribution
  - which state is fresh for each Julia runtime execution
  - how do Julia runtime compatibility projections handle invalid typed source boundaries
date: 2026-07-10
status: current
tags: [julia, runtime, diagnostics, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.5.1 adds exported RuntimeDiagnostic, RuntimeInterpreterException.diagnostic, optional LinkedSpecRuntimeEngine spec_name/spec_path fields, context top-rule identity, direct rule-lookup diagnostics, and fallback-preserving rule/parse wrapping. Seven focused assertions and the full 588-assertion Julia suite prove neutral JSON fields, successful-output preservation, child-rule attribution, and unchanged textual errors."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia runtime structured diagnostics live in
`julia/src/runtime/Interpreter.jl`.

`RuntimeInterpreterException` carries an optional exported `RuntimeDiagnostic`
on its `diagnostic` field. The payload uses the backend-neutral fields `type`,
`stage`, `owner_stage`, `summary`, `detail`, `top_rule`, `rule_label`,
`handler_source_label`, plus optional `spec_name` and `spec_path` supplied by
`LinkedSpecRuntimeEngine`.

Successful `RuntimeParseResult` values and JSON are unchanged. Existing textual
exception display still prints only the message. Diagnostics appear on runtime
failures and have deterministic JSON projection through `to_json(...)`.

Missing compiled-rule lookup emits a specific `rule_lookup` payload. Ordinary
rule failures receive `runtime_execution` attribution before the rule context
unwinds, so nested failures retain the child rule and
`julia_runtime:rule:<label>` handler identity. Parent and parse wrappers preserve
an existing richer payload instead of replacing it. `.7.3.2.4` now renders the
CLI-visible subset of these fields in stable order before raw error text.

Related facts: [[julia-runtime-diagnostics-trace-split]],
[[julia-trace-controls-sinks]], [[julia-runtime-rule-interpreter]],
[[dart-runtime-structured-diagnostics]],
[[trace-cross-variant-capability-contract]],
[[julia-primary-cli-failure-trace-routing]].

## September 11 runtime-state and projection reading

Julia .1.13 reads `julia/src/runtime/Interpreter.jl`116-1615, following the
constructor prefix in .1.12. Diagnostic normalization copies paths and source spans;
engine construction checks removed options, private seed types, regex identities
and serialized mutation state. Fresh contexts own independent stores, source and
recognition authority, frames, caches and observation/diagnostic sinks. The gap and
observation adapters preserve exact slot/invocation identity and use SourceLocation
for detached scalar coordinates. Compatibility projections return absence on typed
source failures. Recognition restores cursor/boundary/marks, not arbitrary bindings;
[[julia-recognition-effect-integration-gap]] remains open under Julia .2.3.

Focused existing assertions pass diagnostics7, typed127, recognition207,
observation30, gap319 and options53 (743 total). The selected-set assertion also
passes. Supporting full-suite parsing or emitted execution grants no later physical
reading credit. Neutral typed14/0/231 and recognition138/250/58 pass.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP13_PROOF'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const selected=Set(["Runtime structured diagnostics"])
const seen=Set{String}()
for expression in Meta.parseall(read("julia/test/runtests.jl",String)).args
 expression isa Expr || continue
 if expression.head==:function
  Core.eval(Main,expression)
 elseif expression.head==:macrocall && expression.args[1]==Symbol("@testset") && expression.args[3] in selected
  Core.eval(Main,expression);push!(seen,expression.args[3])
 end
end
@test seen==selected
include("julia/test/typed_source_location_contract_test.jl")
include("julia/test/recognition_transaction_contract_test.jl")
include("julia/test/recursive_observation_contract_test.jl")
include("julia/test/inter_match_gap_capture_contract_test.jl")
include("julia/test/rule_local_cursor_option_removal_test.jl")
JULIA_GROUP13_PROOF
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
```

## September 11 complete diagnostic consumer reading (.1.43)

Testset3530–3603 passes7 assertions. Source identity does not alter successful
output. An absent selected entry reports select_entry_rule/entry_rule_not_found;
a failed child retains runtime_execution, Child and its handler label while
showerror preserves the message. The synthetic /specs paths are diagnostic text,
not filesystem inputs. Earlier CLI-field rendering is historical: current primary
errors are phase-only; rich native diagnostics remain separate. This fixture does
not close observer/diagnostic sink or byte-retention repairs. Replay is in
[[julia-runtime-array-helpers]], .1.43 below.
