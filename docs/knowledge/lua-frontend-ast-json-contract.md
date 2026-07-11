---
id: lua-frontend-ast-json-contract
title: Lua source AST nodes round-trip the neutral provenance and body-variant contract
answers:
  - what Lua types represent parsed spec files
  - how do Lua AST nodes serialize to JSON
  - what fields does the Lua staged parse job use
  - where are Lua rule modes and body element types
  - does Lua parse spec source yet
  - how does Lua distinguish source AST codeblocks from tables
  - are Lua AST constructor lists sparse or dense
date: 2026-07-11
status: current
tags: [lua, AST, parser, JSON, staged-parsing, provenance, codeblock]
evidence: "LUA-BACKEND-PARITY.2.1 adds lua/src/linkedspec/spec_ast.lua; .2.2 adds its first source producer; .2.3 adds validation; .2.4 adds function projection; .3.1-.3.2 add typed ActionIR/contracts. The current full local gate passes 46/46 on PUC Lua and 46/46 on LuaJIT."
reverify: "bash tools/run_lua_local.sh"
---

`lua/src/linkedspec/spec_ast.lua` defines validated, metatable-typed data nodes for `SpecFile`,
`FunctionDefinition`, `SourceSpan`, `StagedSourceSpan`, `StagedParseJob`, `Rule`, `RuleHeader`, `RuleMode`, ten body
element variants, `EdgeTarget`, and `FluentCall`. It exposes top-rule/rule lookup and Rust-equivalent mode queries.
`LUA-BACKEND-PARITY.2.2` now produces these nodes through public rule-level `parse_spec(source)`.

`to_json(node)` projects recursively into the repository's typed JSON values; `from_json(type, value)` validates
and reconstructs the node. Field names match the Rust/Dart/Julia contract: `functions`, `rules`, `source_span`,
`body_span`, `body_parse_job`, `parent_ast_path`, `result_policy`, `result_field`, and `failure_policy`. Optional
function payload and body AST values are defensively cloned, and staged provenance remains exact.

Arrays and harrays retain the JSON module's explicit identities. A source codeblock is a distinct
`CodeBlockBodyElementKind` node whose projection carries `kind: "code_block"`, lifecycle, and exact code text;
plain tables cannot masquerade as it. Constructor list inputs must have contiguous one-based integer indexes.
Unknown modes/body kinds, wrong node collections, ambiguous payload tables, and sparse lists fail explicitly.

Related facts: [[lua-corpus-manifest-io]], [[lua-actionir-ast-parser]], [[dart-frontend-ast-json-contract]],
[[julia-frontend-ast-json-contract]], [[staged-parse-job-annotation-contract]],
[[text-to-ast-backend-doctrine]].
