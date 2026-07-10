---
id: julia-spec-driven-function-shell-parser
title: Julia parses top-level function shells by executing the checked-in definition spec
answers:
  - how does Julia parse top-level user functions from source
  - why did Julia corpus fn fixtures fail at line 1
  - does Julia raw scan fn definitions
  - what is UserFunctionDefinitionAstParser
  - how does Julia corpus select staged function parsing
  - what is parse_user_function_definition_asts
  - what is parse_spec_with_staged_user_function_definitions
  - what is JULIA-BACKEND-PARITY.6.2.5
date: 2026-07-10
status: current
tags: [julia, parser, corpus, user-functions, staged-parsing, in-memory, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.5 adds julia/src/parser/UserFunctionDefinitionParser.jl, seven focused source-driven parser assertions, and a permanent three-fixture corpus regression. Direct CLI execution is 3 passed / 0 failed; full Julia tests pass with 827 assertions and status runtime-corpus-function-shells."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

The routed Julia corpus fixtures originally failed on line 1 because the default corpus path sent complete source
containing top-level `fn` definitions to the deliberately rule-only `parse_spec(...)` entrypoint. The function
grammar and runtime were already present: direct Julia execution of `specs/user_function_definition.spec` consumed
the source and returned the expected neutral function-definition nodes. The missing seam was source composition.

`UserFunctionDefinitionAstParser` compiles that checked-in parser spec once, caches the default instance behind a
lock, and executes it over caller-provided source in memory. `parse_user_function_definition_asts(...)` normalizes
the returned nodes through the existing portable projection. `parse_spec_with_staged_user_function_definitions(...)`
then strips the definition spans, parses the remaining rules, executes existing staged ActionIR body jobs, and
returns a complete `SpecFile` whose function bodies are ready for registry compilation.

The default corpus path still tries direct rule-only parsing first. It uses the staged function-shell path only
after `parse_spec(...)` raises `SpecParseException`; validation, compile, runtime, and expected-output comparison
remain shared. Julia does not raw-scan `fn` syntax and has no fixture-name semantic branch.

All three routed fixtures pass exact checked-in output:

- `terse_3_3_1_scalar_assignment_expressions`
- `terse_3_3_4_assignment_expression_closure`
- `terse_4_3_2_user_function_runtime`

This closes the function-shell batch, not the aggregate parity claim. `JULIA-BACKEND-PARITY.6.3` independently owns
the complete 99-fixture manifest drift and execution gate.

Related facts: [[julia-user-function-definition-projection]], [[julia-controlled-corpus-execution]],
[[julia-staged-function-body-registry]], [[julia-user-function-runtime-execution]],
[[spec-defined-user-function-definition-parser]], [[native-in-memory-backend-contract]].
