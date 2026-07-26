---
id: julia-frontend-validation
title: Julia validates parsed .spec source ASTs before ActionIR or runtime work
answers:
  - does Julia validate spec files yet
  - where is the Julia spec validator
  - what does Julia validate_spec check
  - does Julia have strict syntax validation
  - how does Julia reject bad edge targets
date: 2026-07-10
status: current
tags: [julia, validation, parser, backend]
evidence: "julia/src/spec/Validator.jl; julia/test/runtests.jl; docs/tasks/JULIA-BACKEND-PARITY.md"
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.2.3` adds `validate_spec(spec; strict_syntax=false)` in
`julia/src/spec/Validator.jl`, plus `SpecValidationException`.

The validator runs on the parsed source AST from `parse_spec(...)`. It checks top-rule presence, duplicate rule
labels, duplicate user function names, user-function registry collisions with rule labels / runtime symbols /
lifecycle markers / ActionIR helper-control names, invalid function names and params, parameter duplicates, arity
mismatches, raw fallback lines, mixed action/blind-call edge families, grouped action-edge targets without a shared
block, undefined edge targets, target regex-slot bounds, structural regex errors, and strict unused-rule behavior.

The focused Julia tests mirror the Dart frontend validator cases and validate all 21 checked-in `specs/*.spec`
files plus rule-only corpus `input.spec` files. `JULIA-BACKEND-PARITY.2.4` has since added projection of
`function_definition` / `function_definition_error` nodes shaped by `specs/user_function_definition.spec`, so
`validate_spec(...)` can validate `SpecFile.functions` produced by that frontend path.

Related facts: [[julia-core-spec-parser]], [[julia-frontend-ast-json-contract]],
[[julia-user-function-definition-projection]], [[dart-frontend-validation]], [[text-to-ast-backend-doctrine]].
