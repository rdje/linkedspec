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

The implementation is intentionally narrow. Public `parse_job(...)`
authoring, filesystem/provider search roots, multiple parser families,
recursive staged queues, and cycle diagnostics remain future work. Registered
function runtime execution has since landed in `.5.2`, and `.5.3` locks the
neutral descriptor shape through runtime.

Related facts: [[function-body-staged-registry-dispatch]],
[[julia-user-function-registry]], [[julia-staged-function-descriptor-shape]],
[[dart-staged-function-body-registry]],
[[staged-parser-registry-dispatch-contract]].
