---
id: lua-spec-defined-function-parser
title: Lua automatically executes the bundled spec-owned function grammar without a raw scanner
answers:
  - how does Lua automatically parse top-level fn definitions
  - does Lua compile user_function_definition.spec once
  - where does Lua resolve the bundled function parser grammar
  - does Lua use search roots for user_function_definition.spec
  - does Lua have a raw fn scanner
  - what API parses Lua function definitions automatically
  - what API composes Lua function bodies automatically
  - how are Lua function parser errors typed
  - what is native-spec-defined-functions-v1
date: 2026-07-15
status: current
tags: [lua, parser, functions, staged-parsing, native-loading, Unicode, public-api]
evidence: "LUA-BACKEND-PARITY.5.2.2 adds user_function_definition_parser.lua and public automatic node/composed APIs; PUC Lua and LuaJIT pass 151/151 with one-build cache proof, exact fixed/variadic/codeblock nodes, Unicode projection, body dispatch, and typed failure ownership."
reverify: "bash tools/run_lua_local.sh"
---

Lua's production automatic function parser is `lua/src/linkedspec/user_function_definition_parser.lua`. It finds
the repository-owned `specs/user_function_definition.spec` from the module file's own directory, issues one exact
path request with that directory as cwd and an empty search-root list, and never recurses or consults caller roots.
The first successful use parses, validates, and compiles the grammar through the ordinary native Lua APIs. That
compiled parser is cached; every caller source is executed in process against top rule
`user_function_definitions` with a fresh runtime engine carrying the bundled spec identity.

`parse_user_function_definition_asts(source)` normalizes only output shapes admitted by the existing
`definition_nodes_from_output(...)` boundary. `parse_spec_with_staged_user_function_definitions(source)` then
delegates those nodes to the existing Unicode-character-index function projector and deterministic
`actionir-body.spec` job dispatcher. Fixed-v1, variadic-v2, and final-codeblock definitions stay source ordered;
their body ASTs are stitched through the established staged registry. No Lua pattern or other host-language raw
`fn` scanner exists in this path, so `user_function_definition.spec` remains the sole syntax owner.

`user_function_definition_parser_metadata()` exposes the bundled name, exact resolved path/origin, top rule, and
successful build count. Parser grammar parse/validation/compile, parser execution, and unsupported output failures
use typed `UserFunctionDefinitionParserError` stages. Function error nodes deliberately remain ordinary
`SpecParseError` values from the projector, and staged failures remain `StagedParserRegistryError`; the composition
layer does not flatten their ownership.

The public status is `native-spec-defined-functions-v1`, with 151/151 focused tests on PUC Lua and LuaJIT.
Loaded caller source is not yet automatically compiled into an identity-bearing engine; that separate adapter is
owned by `LUA-BACKEND-PARITY.5.2.3`. Descriptors/full-pipeline trace, generated source, corpus execution, and the
parser CLI remain later owners.

Related facts: [[lua-function-definition-shell-projection]], [[lua-native-spec-loading-split]],
[[lua-staged-function-body-registry]], [[spec-defined-user-function-definition-parser]],
[[native-in-memory-backend-contract]].
