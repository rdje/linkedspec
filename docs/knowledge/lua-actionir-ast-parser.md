---
id: lua-actionir-ast-parser
title: Lua parses helper/action source into typed ActionIR AST nodes
answers:
  - does Lua parse ActionIR
  - where is the Lua action AST parser
  - what does parse_action_expression do in Lua
  - how does Lua parse semicolon action statements
  - does Lua support single quoted ActionIR strings
  - does Lua support generic trailing codeblocks
  - does Lua support punctuation-light zero-argument markers
  - may a Lua receiver method omit empty parentheses
  - is bare next a statement or value in Lua ActionIR
  - are Lua ActionIR spans Unicode characters or bytes
date: 2026-07-13
status: current
tags: [lua, actionir, parser, AST, Unicode, semicolon, codeblock]
evidence: "LUA-BACKEND-PARITY.3.1 adds lua/src/linkedspec/action_ast.lua and action_parser.lua; .3.2 adds contracts and restores the equals symbol alias; FUTURE-PARITY-BACKLOG.16.6 adds the exact punctuation-light statement/terminal-receiver boundary and passes 109/109 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh"
---

Public `parse_action_block(source)`, `parse_action_statement(source)`, and
`parse_action_expression(source)` produce metatable-typed structural records.
`lua/src/linkedspec/action_ast.lua` owns blocks, value-drop statements,
expressions, arguments, access segments, hash entries, fluent calls, and source
spans; `lua/src/linkedspec/action_parser.lua` owns recursive parsing.

The parser covers primitive and regex literals, scalar/array/harray/codeblock
values, calls and nested/assignment-valued arguments, variables and
indexed/nested access, scalar/append/hash/nested assignments, attached
if/while/switch controls, receiver chains, and explicit `raw_perl` fallback.
Physical LF, CRLF, and CR newlines separate statements. A semicolon separates multiple
statements on one physical line; no trailing semicolon is required after its
last statement. Single and double quotes are universal DSL delimiters, so
`substr(value, '"|\s', "", go)` is parsed without Lua-literal leakage.

Trailing codeblocks are parsed independently of callable name. Helper,
user-function-shaped, and receiver-method forms append a final positional
`block_value`, giving `call(args) { ... }` the same argument semantics as
`call(args, { ... })`. Contract resolution later decides whether a resolved
callable accepts that argument; the parser does not fall through to Lua globals.

The punctuation-light boundary is deliberately contextual. Exact standalone
`else`, `endif`, `default`, `endcase`, `endswitch`, and `next` statements produce
the same zero-argument typed calls as their parenthesized twins. A generic receiver
identifier may omit `()` only in the final chain segment. Expression-position
`next` remains a variable, while general calls, condition-bearing `if`/`while`
headers, intermediate bare receiver segments, and receiver calls with trailing
blocks keep their existing parenthesized syntax.

Lua source is admitted only as strict UTF-8, but stored spans are zero-based
Unicode character offsets rather than byte offsets. `action_ast.to_json(node)`
projects nodes through explicit JSON array/harray identities.

Related facts: [[lua-core-spec-parser]], [[lua-frontend-ast-json-contract]], [[lua-actionir-contract-resolver]],
[[lua-frontend-validation]], [[dart-actionir-ast-parser]],
[[julia-action-ast-parser]], [[text-to-ast-backend-doctrine]].
