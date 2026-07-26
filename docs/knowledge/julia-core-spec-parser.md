---
id: julia-core-spec-parser
title: Julia parses core .spec rule paragraphs into source AST types
answers:
  - does Julia parse spec files yet
  - where is the Julia spec parser
  - what does Julia parse_spec produce
  - can Julia parse shipped specs
  - does Julia parse corpus input specs
date: 2026-07-10
status: current
tags: [julia, parser, ast, backend]
evidence: "julia/src/spec/Parser.jl; julia/test/runtests.jl; docs/tasks/JULIA-BACKEND-PARITY.md"
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.2.2` adds `parse_spec(source)` in `julia/src/spec/Parser.jl`. It parses core `.spec` rule
paragraphs into the source AST types from `julia/src/spec/Ast.jl`, covering rule headers/modes, regex slots,
lifecycle blocks, action/blind-call edges, fluent continuations, split/conditional markers, plain blocks, raw
fallback lines, comments, and nested block boundaries.

The focused Julia parser tests cover representative headers, bounded modes, inline body elements, grouped/indexed
edges, attached `when`/`otherwise` blocks, compact lifecycle fluent chains, multiline fluent arguments, quoted
braces inside code blocks, raw fallback lines, all 21 checked-in `specs/*.spec` files, and rule-only corpus
`input.spec` files.

This is source parsing only. Frontend validation and strict syntax have since landed in
`JULIA-BACKEND-PARITY.2.3`; top-level function-shell projection through the
`specs/user_function_definition.spec` node shape has since landed in `JULIA-BACKEND-PARITY.2.4`. Direct
`parse_spec(...)` remains rule-only.

Related facts: [[julia-frontend-ast-json-contract]], [[julia-frontend-validation]],
[[julia-user-function-definition-projection]], [[dart-core-spec-parser]], [[julia-corpus-manifest-io]],
[[text-to-ast-backend-doctrine]].
