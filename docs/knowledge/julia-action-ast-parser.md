---
id: julia-action-ast-parser
title: Julia parses helper/action source into typed ActionIR AST nodes
answers:
  - does Julia parse ActionIR
  - where is the Julia action AST parser
  - what does parse_action_expression do
  - what does parse_action_block return in Julia
  - does Julia rewrite helper text directly
date: 2026-07-10
status: current
tags: [julia, actionir, parser, backend]
evidence: "julia/src/action/ActionAst.jl; julia/src/action/ActionParser.jl; julia/test/runtests.jl; docs/tasks/JULIA-BACKEND-PARITY.md"
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.3.1` adds Julia's typed helper/action parser. The public API is
`parse_action_block(source)`, `parse_action_statement(source)`, and `parse_action_expression(source)`.

The AST/data model lives in `julia/src/action/ActionAst.jl`, and the parser lives in
`julia/src/action/ActionParser.jl`. It produces structural nodes for action blocks, value-drop statements, calls,
positional/keyword arguments, literals, variables, indexed/nested access, array/hash literals, block values,
scalar/array/hash/nested assignments, receiver fluent chains, helper/receiver trailing block arguments, attached
control forms, switch/case/default branches, and unsupported `raw_perl` fallback expressions.

This was a structural parsing boundary only at `.3.1`. Julia helper-contract resolution has since landed in
`JULIA-BACKEND-PARITY.3.2`; the user-function registry over these nodes, parsed-spec compilation, helper runtime
semantics, and corpus fixture execution remain later `JULIA-BACKEND-PARITY.3.x` / `.4.x` leaves.

Related facts: [[julia-user-function-definition-projection]], [[julia-frontend-validation]],
[[julia-core-spec-parser]], [[julia-actionir-contract-resolver]], [[dart-actionir-ast-parser]],
[[text-to-ast-backend-doctrine]].
