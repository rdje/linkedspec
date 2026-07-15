---
id: lua-runtime-structured-diagnostics
title: Lua runtime failures carry neutral RuntimeDiagnostic payloads with deepest-rule attribution
answers:
  - "does Lua runtime expose structured diagnostics"
  - "what is Lua RuntimeDiagnostic"
  - "where are Lua runtime diagnostic fields"
  - "how does Lua preserve the deepest failing rule"
  - "how do Lua callers attach spec name and path"
  - "how do Lua callers serialize runtime diagnostics"
  - "does Lua structured diagnostics change successful parse output"
date: 2026-07-15
status: current
tags: [lua, runtime, diagnostics, embedding, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.4.1 adds RuntimeDiagnostic, diagnostic-carrying RuntimeInterpreterException tables, optional engine spec_name/spec_path, rule/input/top-stage attribution, and focused dual-ABI proof at 126/126."
reverify: "bash tools/run_lua_local.sh && rg -n 'RuntimeDiagnostic|runtime_diagnostic|runtime-structured-diagnostics' lua/src lua/test/run.lua"
---

`LUA-BACKEND-PARITY.4.4.1` adds the backend-neutral failure payload to Lua's native runtime path.

A typed runtime error remains recognizable through `linkedspec.is_runtime_interpreter_error(error)` and now has
node type `RuntimeInterpreterException`. Its optional `error.diagnostic` is a typed `RuntimeDiagnostic` carrying:

- `type`, `stage`, `owner_stage`, `summary`, and `detail`;
- optional caller-owned `spec_name` and `spec_path`;
- `top_rule`, deepest available `rule_label`, and `handler_source_label`.

`runtime_engine(compiled, { spec_name = ..., spec_path = ... })` stores source identity for failures only. Specific
stages include `top_rule_selection`, `runtime_input`, `rule_lookup`, and `runtime_execution`. Lua handler identity
uses `lua_runtime` without a rule or `lua_runtime:rule:<label>` when a rule is known.

Each rule wrapper attaches a fallback diagnostic before its local context is discarded. If a child or direct
lookup already supplied a richer payload, parent and parse wrappers preserve it. A failure in `Child` therefore
retains `top_rule = "Top"`, `rule_label = "Child"`, and `handler_source_label = "lua_runtime:rule:Child"` after
the entire stack unwinds.

`linkedspec.interpreter.to_json(error.diagnostic)` returns the neutral diagnostic object, while
`linkedspec.interpreter.to_json(error)` returns `message` plus the nested diagnostic. Unavailable optional fields
are omitted. Existing textual `tostring(error)` / `error.message` content and all successful `RuntimeParseResult`
fields remain unchanged.

PUC Lua and LuaJIT pass the same 126/126 suite, including exact missing-rule JSON, nested child attribution,
richer lookup preservation, empty-state selection, strict invalid-input attribution, optional source identity,
runtime-error JSON, and successful-result preservation. Public status is `runtime-structured-diagnostics`.

Related facts: [[lua-runtime-diagnostics-trace-split]], [[dart-runtime-structured-diagnostics]],
[[julia-runtime-structured-diagnostics]], [[rust-runtime-structured-diagnostics]],
[[trace-cross-variant-capability-contract]].
