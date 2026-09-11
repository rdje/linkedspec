---
id: julia-staged-function-body-registry
title: Julia staged registry dispatches function-body parse jobs and stitches body_ast
answers:
  - where is the Julia staged parser registry
  - does Julia dispatch function body parse jobs
  - how does Julia resolve actionir-body.spec
  - does Julia stitch body_ast
  - what Julia API parses specs with staged function bodies
  - what is JULIA-BACKEND-PARITY.5.1
date: 2026-07-10
status: current
tags: [julia, staged-parsing, parser-registry, parse-jobs, user-functions, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.5.1 adds julia/src/parser/StagedParserRegistry.jl, exports the staged registry APIs, and adds 31 focused assertions in julia/test/runtests.jl. Full Pkg.test() passes with 662 assertions and package/CLI status runtime-staged-registry."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()' && rg -n 'StagedParserRegistry|ACTION_IR_BODY_|execute_staged_parse_jobs|dispatch_function_body_parse_jobs|body_ast' julia/src/parser/StagedParserRegistry.jl julia/test/runtests.jl"
---

Julia's minimal staged parser registry lives in
`julia/src/parser/StagedParserRegistry.jl`.

`execute_staged_parse_jobs(...)` validates and stable-sorts `StagedParseJob`
values by parent AST path, source span, then job id. It resolves
`actionir-body.spec` to `builtin:actionir-body.spec`, records the fixed portable
adapter digest and neutral cache/compiled-parser fields, then parses exact body
text through `parse_action_block(...)` into neutral JSON.

`dispatch_function_body_parse_jobs(...)` validates each function sidecar and
immutably stitches staged `action_block` results into matching `body_ast`
fields. `stitch_function_body_parse_jobs(...)` returns only the stitched spec;
`parse_spec_with_staged_user_function_definition_asts(...)` composes the
existing spec-returned function-shell projection with staged body dispatch.

The function-body implementation remains intentionally narrow. General assignment-form
`parse_job(...)`, caller-frozen resolution, recursive queues and cycle diagnostics
are separately admitted under `.14.7`; they do not widen this legacy adapter.
See [[julia-staged-ast-enrichment-carriers-admission]]. Registered function execution
and descriptor shape retain their `.5.2` / `.5.3` owners.

Related facts: [[function-body-staged-registry-dispatch]],
[[julia-user-function-registry]], [[julia-staged-function-descriptor-shape]],
[[dart-staged-function-body-registry]],
[[staged-parser-registry-dispatch-contract]].

## September 11 exact source reading and focused replay

Julia .1.11 reads all652 lines of `julia/src/parser/StagedParserRegistry.jl`.
Legacy paths are ordered as string lists, then by span and job id. Every job
builds an eight-field cache identity; this adapter stores no reusable plan cache.
Fixed, variadic and final-codeblock metadata are checked before immutable body_ast
stitching. The separate general-v2 scheduler owns typed numeric paths and caches.
Registry39/descriptor28/trace28/function-parser7/stdio170/variadic55 pass (327).
The first ad-hoc replay omitted CORPUS_ROOT and stopped during the trace group;
its two affected groups pass with that existing constant supplied. Earlier passing
groups were retained. Supporting execution grants no future source-reading credit.
Neutral staged governance passes123 mutations/public129 and MCP35/10/10/76.
The original31/662 and99-fixture counts remain historical admission evidence.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP11_PROOF'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const CORPUS_ROOT=joinpath(REPO_ROOT,"rust","linkedspec-runtime","tests","corpus")
const DESCRIPTOR_CONTRACT=JSON3.read(read(joinpath(REPO_ROOT,"capability_conformance/outward_descriptor_contract.json"),String),Dict{String,Any})
const selected=Set(["Staged function-body parser registry","Staged function descriptor shape through runtime","Spec-driven user function definition parser","Frontend compiler and staged trace coverage"])
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
include("julia/test/mcp_server_julia_stdio_test.jl")
include("julia/test/variadic_user_function_contract_test.jl")
JULIA_GROUP11_PROOF
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
```
