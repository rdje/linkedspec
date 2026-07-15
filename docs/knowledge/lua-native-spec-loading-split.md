---
id: lua-native-spec-loading-split
title: Lua native spec loading is ordered resolve/load then spec-defined function parsing then composition
answers:
  - "how is Lua native spec loading split"
  - "what is LUA-BACKEND-PARITY 5.2.0"
  - "can Lua execute user_function_definition.spec"
  - "what is next after Lua staged functions"
  - "why is Lua native loading not one implementation leaf"
  - "does Lua need a raw fn scanner for native loading"
date: 2026-07-15
status: current
tags: [lua, resolution, files, utf8, functions, staged-parsing, task-tree, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.2.0 audits and splits the dependency chain; .5.2.1 implements typed deterministic resolve/load and strict UTF-8; .5.2.2 implements cached automatic spec-owned function parsing at 151/151 on both ABIs and activates loaded-source composition .5.2.3."
reverify: "perl tools/check_native_spec_resolution_contract.pl && bash tools/run_lua_local.sh"
---

Lua native file loading has four dependency-ordered implementation mechanisms. First, `.5.2.1` implements typed
name/path requests, deterministic cwd/suffix/direct-root resolution, regular-file selection, byte loading, strict
UTF-8 preservation, neutral pipeline errors through decode, and direct consumption of all 14 validation, 9
resolution, and 4 text cases. It does not parse or compile the loaded source. Both Lua ABIs pass 149/149 with
status `native-spec-resolution-loading-v1`.

Second, `.5.2.2` makes top-level function-shell parsing automatic without adding a raw `fn` scanner. The
production adapter resolves `specs/user_function_definition.spec` through one exact module-relative owner with no
search roots, parses/validates/compiles it once, executes `user_function_definitions` over each caller source, and
reuses the existing Unicode-exact projector plus body-job dispatcher. Both Lua ABIs pass 151/151 with status
`native-spec-defined-functions-v1`.

Third, `.5.2.3` composes loaded source through automatic full-source parse, validation, compilation, and engine
creation while retaining requested identity, resolved path, and exact source text. Fourth, `.5.2.4` performs the
public/API/test/docs/Knowledge-Map no-drift closeout. Outward descriptors and full-pipeline trace remain `.5.3`;
generated source, corpus execution, and the parser CLI retain their later owners.

This order prevents filesystem policy, spec-language parsing, and compiled-runtime identity from becoming one
unreviewable change. It also preserves the architectural rule that `.spec` files own language semantics: the
native loader supplies composition, not an alternative host-language function-definition grammar.

Related facts: [[native-spec-resolution-contract]], [[native-in-memory-backend-contract]],
[[lua-function-definition-shell-projection]], [[lua-staged-function-runtime-closeout]],
[[spec-defined-user-function-definition-parser]], [[lua-native-spec-resolution]],
[[lua-spec-defined-function-parser]].
