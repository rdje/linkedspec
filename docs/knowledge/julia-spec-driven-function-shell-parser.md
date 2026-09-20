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
  - where does a Julia application find the supporting user function grammar
  - does Julia prefer the package source or working directory for its function parser spec
date: 2026-09-20
status: current
tags: [julia, parser, corpus, user-functions, staged-parsing, in-memory, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.5 adds source-driven parser execution and a permanent regression; .6.3 includes it in 99/99. .7.3.2.1 traces it and .7.3.2.2 re-proves it in the current 920-assertion/99-fixture gate."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
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

This closes the function-shell batch. `JULIA-BACKEND-PARITY.6.3` has since independently closed the complete
99-fixture manifest drift and execution gate.

Related facts: [[julia-full-corpus-gate]], [[julia-user-function-definition-projection]], [[julia-controlled-corpus-execution]],
[[julia-staged-function-body-registry]], [[julia-user-function-runtime-execution]],
[[spec-defined-user-function-definition-parser]], [[native-in-memory-backend-contract]].

## September 11 source-reading reconciliation

Julia .1.11 reads `julia/src/parser/UserFunctionDefinitionParser.jl` through231.
The checked-in spec executes in memory, then its returned nodes enter projection
and staged body stitching. Default parser construction is cached behind a lock;
explicit parser source constructs a separate parser. Function-shell7 and frontend/
staged-trace28 assertions pass. The final helper suffix remains unread for .1.12;
99/920 counts above are historical, while current corpus ownership records105.
Focused replay: `docs/knowledge/julia-staged-function-body-registry.md`.

Julia .1.12 subsequently reads the final18 lines: ancestor search terminates at the
filesystem root; a failed match is accepted only when the remaining character
suffix is whitespace or the reported character cursor has reached the source end.
This completes physical reading of the249-line parser, without changing behavior.

## September 20 native integration lookup proof

`BACKEND-INTEGRATION-GUIDES.4.1` verifies the default supporting asset independently
of the application's requested grammar. `_user_function_definition_spec_path`
searches ancestors of the package parser source first, then ancestors of `pwd()`.
A complete checkout therefore supplies `specs/user_function_definition.spec`
beside the package's `julia/` directory. The native staged file loader requires
this asset even for the word example without user functions. Retaining only the
Julia subtree loses that arrangement; a nearby unrelated checkout is not a
packaging contract. Explicit parser source remains a lower-level API choice.

The integration verifier changes cwd inside Julia to an owned temporary directory
containing a deliberately invalid competing asset. It checks the exact selected
package-owned path and the successful direct word result. This is an explicit
Julia `cd`, because the managed Julia wrapper itself selects the checkout root
before invoking Julia. Application-relative grammar resolution is separately
anchored to the example's bin/ parent by `SpecLoadOptions`. Replay:

```sh
bash tools/run_python_project_data.sh examples/integration/julia/verify_words.py
```

See [[backend-integration-inventory]] for application preparation and the two
consumer environments. These checks neither change parser behavior nor advance
the paused conformance source-reading ledger.
