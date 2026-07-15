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
evidence: "LUA-BACKEND-PARITY.2.4 adds user_function_definition_shell.lua; .3.1-.4.1 add typed ActionIR/contracts/registry/compiled/matching state. The local gate passes 60/60 on PUC Lua and LuaJIT, including Unicode spans, staged sidecars, composition, no raw scanner, action parsing, contracts, registry, descriptor, and matching preservation."
evidence_update_2026_07_15_staged_dispatch: "LUA-BACKEND-PARITY.5.1.1 composes this projector with deterministic staged body dispatch; PUC Lua and LuaJIT pass 130/130."
evidence_update_2026_07_15_fixed_runtime: "LUA-BACKEND-PARITY.5.1.2 executes the projected exact-v1 records through verified staged bodies and fresh stores at 133/133; .5.1.3.1 now owns variadic-v2 projection evolution."
evidence_update_2026_07_15_native_loading_split: "LUA-BACKEND-PARITY.5.2.0 directly proves the current Lua runtime can execute specs/user_function_definition.spec and return an exact function_definition node; automatic parser composition is owned by .5.2.2 after portable resolve/load .5.2.1."
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
array result shapes. The original projection APIs preserve `body_parse_job` with `body_ast` absent. The later
`parse_spec_with_staged_user_function_definition_asts(...)` API composes that exact projection with `.5.1.1`
dispatch and returns a new spec carrying neutral `body_ast` JSON.

The completed projector now validates fixed-v1, variadic-v2, and final-codeblock parameter state through the
closed `.5.1` runtime parent. Planning `.5.2.0` proves the owning grammar itself executes on the current Lua
runtime; `.5.2.2` will make that execution an automatic composed parser after `.5.2.1` supplies portable loading.

Related facts: [[spec-defined-user-function-definition-parser]], [[function-body-parse-job-sidecar]],
[[lua-staged-function-body-registry]],
[[lua-core-spec-parser]], [[lua-frontend-validation]], [[dart-function-definition-shell-projection]],
[[julia-user-function-definition-projection]].
See also [[lua-variadic-user-function-routing]], [[lua-fixed-v1-user-function-runtime]].
