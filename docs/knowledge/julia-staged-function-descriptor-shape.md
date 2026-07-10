---
id: julia-staged-function-descriptor-shape
title: Julia preserves neutral staged function descriptor shape through runtime
answers:
  - does Julia preserve staged function descriptor shape
  - does Julia descriptor include body_payload provenance
  - does Julia descriptor include normalized body_parse_job
  - does Julia descriptor include stitched body_ast
  - does Julia compiled descriptor preserve function_order and function_count
  - what is JULIA-BACKEND-PARITY.5.3
date: 2026-07-10
status: current
tags: [julia, descriptor, staged-parsing, user-functions, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.5.3 adds a 20-assertion testset in julia/test/runtests.jl. It builds two functions from neutral spec-returned function_definition nodes, dispatches and stitches their body jobs, compiles the spec, asserts parsed/registry/descriptor shape, and executes the same compiled state. Full Pkg.test() passes with 691 assertions."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia's staged function descriptor proof lives in `julia/test/runtests.jl` under
`Staged function descriptor shape through runtime`.

The fixture starts from the neutral `function_definition` node shape returned by the spec-defined function shell,
not from hand-built internal records. `parse_spec_with_staged_user_function_definition_asts(...)` normalizes and
dispatches both jobs before `compile_spec(...)` builds the registry and descriptor state.

The proof asserts:

- parsed function source order and compiled registry job order
- zero-based `functions.<index>.body_source` parent paths and deterministic job ids
- neutral `body_payload` identity, params/text/span, and source-slice provenance
- neutral `body_parse_job` identity, parser/top rule, result/failure policies, and diagnostic owner
- immutable stitched ActionIR `body_ast`
- descriptor function indices plus `meta.function_order` / `meta.function_count`
- stable registered-function runtime output from the same compiled state

No production projection change was required. This is a shape/no-drift proof, not general public
`parse_job(...)` authoring or corpus parity.

Related facts: [[julia-compiled-spec-state]], [[julia-user-function-registry]],
[[julia-staged-function-body-registry]], [[julia-user-function-runtime-execution]],
[[dart-staged-function-descriptor-shape]], [[function-body-staged-prototype-proof]].
