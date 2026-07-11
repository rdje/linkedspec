---
id: lua-function-definition-shell-projection
title: Lua projects spec-owned function-definition nodes without raw-scanning fn source
answers:
  - does Lua project top-level user functions
  - does Lua raw scan fn definitions
  - how does Lua consume user_function_definition.spec output
  - where is Lua function definition projection
  - does Lua preserve function body parse jobs
  - how does Lua handle Unicode function source spans
  - does Lua dispatch function body AST jobs yet
date: 2026-07-11
status: current
tags: [lua, parser, functions, staged-parsing, provenance, Unicode]
evidence: "LUA-BACKEND-PARITY.2.4 adds user_function_definition_shell.lua. The local gate passes 35/35 on PUC Lua and LuaJIT, including Unicode spans, staged sidecars, composition, errors/drift/wrappers/overlap, and no raw scanner."
reverify: "bash tools/run_lua_local.sh"
---

Lua function-shell semantics remain owned by `specs/user_function_definition.spec`. The native frontend accepts
only its explicitly typed `function_definition` / `function_definition_error` result nodes through
`project_user_function_definition_asts(source, nodes)` and
`parse_spec_with_user_function_definition_asts(source, nodes)`. Empty node input over leading `fn` source produces
a typed ordinary rule-parse error; there is no competing raw `fn` scanner.

Projection validates node kind/version, identifiers, params/arity, source/body containment and exact slices,
staged payload/job identity, parent path, parser/top rule, result field/policy, failure policy, and diagnostic owner.
Spans are zero-based Unicode character indexes, not UTF-8 byte offsets. Lua first validates strict UTF-8 as its host
representation, then maps character indexes to byte boundaries without confusing the encoding with Unicode itself.

Sidecars are defensively copied. Parent paths normalize to `functions.<index>.body_source`; body job IDs become
deterministic from the normalized path, parser/top identity, and body span. Function spans are replaced with spaces
per character while CR/LF and all outside Unicode text remain intact, so subsequent rule line numbers do not move.
The composed API attaches ordered `FunctionDefinition` nodes to ordinary parsed rules and can pass validation.

`definition_nodes_from_user_function_definition_output(output)` normalizes direct, singleton-wrapped, and nested
array result shapes. `body_parse_job` is preserved, but `body_ast` remains absent because staged registry dispatch
belongs to `.5.1`.

Related facts: [[spec-defined-user-function-definition-parser]], [[function-body-parse-job-sidecar]],
[[lua-core-spec-parser]], [[lua-frontend-validation]], [[dart-function-definition-shell-projection]],
[[julia-user-function-definition-projection]].
