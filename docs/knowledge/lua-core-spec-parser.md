---
id: lua-core-spec-parser
title: Lua parses universal rule paragraphs into typed source AST nodes
answers:
  - does Lua parse spec files yet
  - where is the Lua spec parser
  - what does Lua parse_spec support
  - can Lua parse shipped specs
  - how many corpus specs does Lua parse
  - does Lua parse top-level function definitions yet
  - how does Lua parse semicolon statement separators
  - does Lua preserve single and double quoted strings
date: 2026-07-11
status: current
tags: [lua, parser, AST, source, semicolon, quotes, PUC-Lua, LuaJIT]
evidence: "LUA-BACKEND-PARITY.2.2 adds lua/src/linkedspec/spec_parser.lua; .2.3 adds validation; .2.4 adds spec-owned function projection; .3.1-.3.4 add typed action parsing/contracts/registry/compiled state. The current local gate passes 55/55 on both runtimes, all 21 shipped specs, and 102 rule-only corpus specs."
reverify: "bash tools/run_lua_local.sh"
---

Public `linkedspec.parse_spec(source)` parses permissive rule-level `.spec` source into the typed nodes in
`linkedspec.spec_ast`. It recognizes rule headers and simple/bounded modes; inline and body regex slots;
grouped/indexed action and blind edges; lifecycle/plain blocks; split, conditional, and lifecycle markers; fluent
continuations; receiver `when`/`otherwise`; comments; and raw fallback. Nested parentheses and braces are scanned
without treating braces inside either single- or double-quoted strings as structure. Failures are typed values with
`line` and `message`, detectable with `is_spec_parse_error`. Lua strings can contain arbitrary bytes, so the public
source seam first requires strict UTF-8 as its representation of logical Unicode text.

The parser passes all 21 checked-in `specs/*.spec` files and 102 of the 105 corpus source files on both PUC Lua and
LuaJIT. The other three start with `fn` shells; direct parsing rejects them intentionally. `.2.4` now projects
explicitly supplied AST nodes returned by `specs/user_function_definition.spec`, without a raw scanner.

Physical newlines separate statements. Semicolons are only separators between multiple statements on one physical
line, and the last statement on that line needs no trailing semicolon. The parser preserves newline-delimited block
text. When compact lifecycle fluent calls are normalized into same-line statement code, it inserts `; ` only
between calls and never after the final call.

Parsing remains separate from validation. `.2.3` adds public validation/strict syntax, and `.3.1` adds the separate
typed ActionIR parser seam; later leaves own contract resolution, compilation, runtime, corpus execution, and the
exact primary CLI.

Related facts: [[lua-frontend-ast-json-contract]], [[lua-actionir-ast-parser]], [[canonical-statement-separator-syntax]],
[[dart-core-spec-parser]], [[julia-core-spec-parser]], [[text-to-ast-backend-doctrine]].
