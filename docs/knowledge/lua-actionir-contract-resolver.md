---
id: lua-actionir-contract-resolver
title: Lua resolves typed ActionIR against the exact current helper contract
answers:
  - does Lua resolve ActionIR helper contracts
  - where is the Lua ActionIR contract resolver
  - how does Lua canonicalize helper aliases
  - how does Lua diagnose unknown helper calls
  - does Lua fall through to global functions
  - how do Lua user functions resolve before helpers
  - does Lua parse the equals helper alias
date: 2026-07-11
status: current
tags: [lua, actionir, contracts, diagnostics, helpers, functions]
evidence: "LUA-BACKEND-PARITY.3.2 adds lua/src/linkedspec/action_contracts.lua, restores the governed equals symbol callee, and exposes recursive resolvers. LUA-BACKEND-PARITY.3.3 supplies the concrete registry. The local gate passes 50/50 on PUC Lua and LuaJIT; the cross-language checker proves the shared 239-name set and 105-fixture coverage."
reverify: "bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl"
---

Public `resolve_action_block_contracts`,
`resolve_action_statement_contracts`, and
`resolve_action_expression_contracts` walk the typed `.3.1` AST. Resolved
records carry source/canonical name, family, surface, source/span, and
positional/keyword counts. Structural assignments and controls are recorded
without pretending they are Lua calls. `action_contracts.to_json(value)` uses
the same neutral fields as Dart and Julia.

`canonical_action_helper_name(name)` maps current numeric words/symbols and
control aliases to their canonical names. The governed `=(target, value)`
symbol form is parsed and resolves to `set`. `is_known_action_ir_call_name`
delegates to the same exact 239-name `action_call_names` table already used by
source function validation; there is no competing resolver inventory.

Unknown/non-current calls produce `unknown_helper`, and parser fallback nodes
produce `raw_perl`. Both are typed generic diagnostics; neither invokes an
arbitrary Lua global. Nested arguments, shapes, codeblocks, access indexes,
controls, assignments, and receiver methods are recursively visited.

The optional `{ function_registry = registry }` seam calls
`registry:resolve_call(name, arity)` before helper fallback on ordinary
function-call surfaces. Exact matches use `family = "user_function"`; a known
name with wrong arity produces `user_function_arity_mismatch`. The concrete
`.3.3` ordered registry implements this interface without changing traversal.

Related facts: [[lua-actionir-ast-parser]], [[lua-frontend-validation]],
[[dart-actionir-contract-resolver]], [[julia-actionir-contract-resolver]],
[[lua-user-function-registry]], [[text-to-ast-backend-doctrine]].
