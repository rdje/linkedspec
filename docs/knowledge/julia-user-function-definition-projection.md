---
id: julia-user-function-definition-projection
title: Julia consumes spec-shaped user-function definition nodes without a raw fn scanner
answers:
  - does Julia parse top-level user functions
  - how does Julia consume user_function_definition.spec output
  - does Julia raw scan fn definitions
  - where is Julia function definition projection
  - what does parse_spec_with_user_function_definition_asts do
date: 2026-07-10
status: current
tags: [julia, parser, user-functions, staged-parsing, backend]
evidence: "JULIA-BACKEND-PARITY.2.4 adds neutral projection, .6.2.5 adds source-driven execution, and .6.3 includes it in 99/99. JULIA-BACKEND-PARITY.7.3.2.1 adds shared-emitter tracing and re-proves the path in the current 868-assertion/99-fixture gate."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.2.4` adds `julia/src/spec/UserFunctionDefinitionShell.jl`.
It exposes `project_user_function_definition_asts(source, nodes)`,
`parse_spec_with_user_function_definition_asts(source, nodes)`, and
`definition_nodes_from_user_function_definition_output(output)`.

Julia does not raw-scan top-level `fn name(params) { ... }` definitions. Instead, it consumes the neutral
`function_definition` / `function_definition_error` node shape owned by `specs/user_function_definition.spec`.
Projection validates name/params/arity, source/body spans, `body_payload`, `body_parse_job`, parser/top-rule
identity, result/failure policies, and diagnostic owner. It then normalizes `parent_ast_path` and job IDs to
`functions.<index>.body_source`, strips function-definition spans while preserving newlines, and parses the
remaining rule source through `parse_spec(...)`.

Direct `parse_spec(...)` remains rule-only. `JULIA-BACKEND-PARITY.6.2.5` now executes
`specs/user_function_definition.spec` inside Julia through `UserFunctionDefinitionAstParser`, then feeds its output
through this projection and the existing staged body registry. The corpus default invokes that path only after
rule-only parsing reports a source parse error. No raw function scanner is present.

Related facts: [[julia-full-corpus-gate]], [[julia-spec-driven-function-shell-parser]], [[spec-defined-user-function-definition-parser]], [[julia-core-spec-parser]],
[[julia-frontend-ast-json-contract]], [[julia-frontend-validation]], [[julia-user-function-registry]],
[[dart-core-spec-parser]], [[rust-user-function-registry-parity]], [[text-to-ast-backend-doctrine]].
