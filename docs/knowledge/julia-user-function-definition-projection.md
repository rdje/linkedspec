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
evidence: "JULIA-BACKEND-PARITY.2.4 adds neutral projection, .6.2.5 adds source-driven execution, and .6.3 includes it in 99/99. .7.3.2.1 adds tracing and .7.3.2.2 re-proves the path in the current 920-assertion/99-fixture gate."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.2.4` adds `julia/src/spec/UserFunctionDefinitionShell.jl`.
It exposes `project_user_function_definition_asts(source, nodes)`,
`parse_spec_with_user_function_definition_asts(source, nodes)`, and
`definition_nodes_from_user_function_definition_output(output)`.

Julia does not raw-scan top-level `fn name(params) { ... }` definitions. Instead, it consumes the neutral
`function_definition` / `function_definition_error` node shape owned by `specs/user_function_definition.spec`.
Projection validates the exact fixed-v1 `params`/`arity` or variadic-v2 `callable_signature` union, source/body
spans, identical staged `body_payload`/`body_parse_job` signature copies, parser/top-rule
identity, result/failure policies, and diagnostic owner. It then normalizes `parent_ast_path` and job IDs to
`functions.<index>.body_source`, strips function-definition spans while preserving newlines, and parses the
remaining rule source through `parse_spec(...)`.

Direct `parse_spec(...)` remains rule-only. `JULIA-BACKEND-PARITY.6.2.5` now executes
`specs/user_function_definition.spec` inside Julia through `UserFunctionDefinitionAstParser`, then feeds its output
through this projection and the existing staged body registry. The corpus default invokes that path only after
rule-only parsing reports a source parse error. No raw function scanner is present.

Related facts: [[julia-full-corpus-gate]], [[julia-spec-driven-function-shell-parser]], [[spec-defined-user-function-definition-parser]], [[julia-core-spec-parser]],
[[julia-frontend-ast-json-contract]], [[julia-frontend-validation]], [[julia-user-function-registry]],
[[julia-variadic-user-functions]],
[[dart-core-spec-parser]], [[rust-user-function-registry-parity]], [[text-to-ast-backend-doctrine]].

## September 11 source-reading reconciliation

Julia .1.11 reads `julia/src/parser/UserFunctionDefinitionParser.jl` through231.
The checked-in spec executes in memory, then its returned nodes enter projection
and staged body stitching. Default parser construction is cached behind a lock;
explicit parser source constructs a separate parser. Function-shell7 and frontend/
staged-trace28 assertions pass. The final helper suffix remains unread for .1.12;
99/920 counts above are historical, while current corpus ownership records105.
Focused replay: `docs/knowledge/julia-staged-function-body-registry.md`.

## September 11 — projection reading and malformed metadata boundaries

Julia .1.32 reads all810 lines of UserFunctionDefinitionShell.jl. Scalar text,
containment and sidecar agreement are validated, but source-derived line bounds,
exact Boolean exclusion and payload versions have gaps. Five malformed metadata
controls still stage/compile/execute; seven invalid comparisons reject and the
clean node succeeds. Repair .2.22.1-.3 and complete118-assertion diagnostic replay
are in [[julia-function-projection-metadata-gaps]]. Existing projection27 plus
source-parser7, registry39 and broader frontend/callable checks remain positive
finite evidence, not universal projection validation.
