---
id: julia-frontend-ast-json-contract
title: Julia frontend AST types mirror the Rust/Dart parsed-source JSON contract
answers:
  - what Julia types represent parsed spec files
  - how do Julia AST types serialize to JSON
  - what fields does the Julia staged parse job use
  - where are Julia rule mode and body element data types
  - what Julia AST types will the parser produce
date: 2026-07-10
status: current
tags: [julia, ast, parser, json, staged-parsing]
evidence: "julia/src/spec/Ast.jl; julia/src/spec/Parser.jl; julia/test/runtests.jl; docs/tasks/JULIA-BACKEND-PARITY.md"
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.2.1` adds data-only Julia source AST types in `julia/src/spec/Ast.jl`. They cover
`SpecFile`, `FunctionDefinition`, `SourceSpan`, `StagedSourceSpan`, `StagedParseJob`, `Rule`, `RuleHeader`,
`RuleMode`, body element variants, `EdgeTarget`, and `FluentCall`.

The JSON projection intentionally follows the Rust/Dart/mdBook contract, including `functions`, `rules`,
`source_span`, `body_span`, `body_parse_job`, `line_start`, `line_end`, `parent_ast_path`, `result_policy`, and
`failure_policy`.

`julia/test/runtests.jl` round-trips a representative `SpecFile` through JSON, including a function definition,
staged function-body parse job, bounded AND rule mode, regex/action/code body elements, edge targets, and fluent
calls. `JULIA-BACKEND-PARITY.2.2` has since added `parse_spec(source)` as the first producer of these rule AST
types from `.spec` text, and `JULIA-BACKEND-PARITY.2.3` has since added `validate_spec(...)` as the first
consumer and validator of those parsed source ASTs. `JULIA-BACKEND-PARITY.2.4` now also projects
spec-shaped user-function shell nodes into `FunctionDefinition` records with normalized staged body parse jobs.

Related facts: [[julia-core-spec-parser]], [[julia-frontend-validation]],
[[julia-user-function-definition-projection]], [[julia-corpus-manifest-io]],
[[dart-frontend-ast-json-contract]], [[dart-core-spec-parser]], [[text-to-ast-backend-doctrine]].

## 2026-09-11 — full AST physical reading and focused JSON recurrence

Julia .1.30 completes Ast102-909 after .1.29's1-101 prefix. Source/staged spans,
callable signatures, function sidecars, rule/body variants and selector identity
are fully read. EdgeTarget keeps authored kind/value independently of resolved
index; JSON projection retains both. Integer readers explicitly exclude Bool;
optional arrays/maps/strings and omitted source identity follow their typed
null/default handling. Data construction is separate from compiler validation.

The unchanged Spec AST JSON contract passes16 assertions through exact top-level
selection, alongside parser185/validator23. The independent selection assertion
checks five original helpers and all three original testsets. Additional lifecycle
proof passes103; no full package gate ran. Replay and the separate parser source-
loss limitation are preserved in [[julia-parser-member-suffix-loss]].
