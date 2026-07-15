---
id: lua-staged-function-body-registry
title: Lua staged registry dispatches function-body parse jobs and stitches body_ast
answers:
  - "where is the Lua staged parser registry"
  - "does Lua dispatch function body parse jobs"
  - "how does Lua resolve actionir-body.spec"
  - "does Lua stitch body_ast"
  - "what Lua API parses specs with staged function bodies"
  - "what is LUA-BACKEND-PARITY.5.1.1"
date: 2026-07-15
status: current
tags: [lua, staged-parsing, parser-registry, parse-jobs, user-functions, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.1.1 adds lua/src/linkedspec/staged_parser_registry.lua, exports the staged registry APIs through lua/src/linkedspec/init.lua, and adds a focused dual-ABI test in lua/test/run.lua. PUC Lua and LuaJIT pass 130/130 with public status runtime-staged-registry; canonical local CI passes CLI 61x2 and Phase 0 1..1031."
evidence_update_2026_07_15_fixed_runtime: "LUA-BACKEND-PARITY.5.1.2 consumes stitched body_ast as an integrity-checked runtime authority for fixed-v1 calls; PUC Lua and LuaJIT pass 133/133 with status runtime-user-functions-fixed-v1."
reverify: "bash tools/run_lua_local.sh && rg -n 'ACTION_IR_BODY_|execute_staged_parse_jobs|dispatch_function_body_parse_jobs|body_ast' lua/src/linkedspec/staged_parser_registry.lua lua/src/linkedspec/init.lua lua/test/run.lua"
---

Lua's minimal staged parser registry lives in
`lua/src/linkedspec/staged_parser_registry.lua`.

`execute_staged_parse_jobs(...)` validates and defensively copies exact
`StagedParseJob` values, then stable-sorts them by parent AST path, source span,
job id, and original position for equal keys. It resolves only
`actionir-body.spec` to `builtin:actionir-body.spec`, records the governed
adapter digest
`sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c`
and neutral cache/compiled-parser identity, then parses exact body text through
`parse_action_block(...)` into neutral JSON.

`dispatch_function_body_parse_jobs(...)` validates each fixed-v1 function
sidecar, rejects duplicate job ids, and immutably stitches staged
`action_block` results into matching `body_ast` fields under the
`replace_field` policy. `stitch_function_body_parse_jobs(...)` returns only the
stitched spec. `parse_spec_with_staged_user_function_definition_asts(...)`
composes the existing spec-returned function-definition shell with staged body
dispatch.

The provider is intentionally narrow. Registered fixed-v1 execution has landed
under `.5.1.2`; variadic-v2 state is active at `.5.1.3.1`; native loading remains `.5.2`; outward descriptors and
full-pipeline trace remain `.5.3`; public `parse_job(...)` authoring, multiple
parser families, and recursive staged queues remain later staged-authoring
work.

Related facts: [[function-body-staged-registry-dispatch]],
[[lua-function-definition-shell-projection]],
[[lua-user-function-registry]], [[lua-staged-function-execution-split]],
[[staged-parser-registry-dispatch-contract]], [[lua-fixed-v1-user-function-runtime]].
