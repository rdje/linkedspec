---
id: lua-callable-codeblock-literal-state
title: Lua preserves callable codeblock literals as inert typed state
answers:
  - "does Lua parse callable codeblock literals"
  - "can Lua construct a {|params| body } codeblock"
  - "what fields are in a Lua callable codeblock value"
  - "does constructing a Lua codeblock execute its body"
  - "does a Lua callable codeblock capture a closure or environment"
  - "are Lua callable codeblock spans byte or Unicode character offsets"
  - "does generated Lua preserve callable codeblocks"
  - "does Lua semantic introspection report codeblock signatures"
  - "how does Lua copy a codeblock without losing its source span"
  - "can Lua invoke a codeblock variable with cb parentheses"
date: 2026-08-01
status: current
tags: [lua, luajit, actionir, codeblock, callable, generated-source, semantic-introspection, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.8.1 adds exact {| recognition, the neutral eight-field literal/fixed-rest signature record, containing Unicode-character-coordinate literal/body spans, nine malformed codes, inert runtime and user-function copies, compiled/generated/emitted-effective-state preservation, and semantic codeblock shapes. One focused consumer passes 168 assertions on PUC Lua and LuaJIT; complete Lua, neutral+20, KM 777/6,301, mdBook, all seven doctrines, canonical Phase 0 1,031/1,031, and the four-backend callable matrix pass."
evidence_update_2026_08_01_invocation: "FUTURE-PARITY-BACKLOG.11.8.2 now invokes this retained state through one post-static dynamic caller-frame executor on PUC Lua and LuaJIT; construction remains inert and unchanged."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_lua_project_data.sh puc lua/test/callable_codeblock_literal_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/callable_codeblock_literal_contract_test.lua && bash tools/run_lua_local.sh"
---

# Lua Callable Codeblock Literal State

Lua recognizes exact `{|params| body }` and `{|| body }` before its existing harray and eager-block brace
classifiers. A valid literal projects as one serializable `codeblock_literal` record with exactly eight fields:
`kind`, `version`, `signature`, `body_source`, `body_ast`, `source_text`, `source_span`, and `body_span`. The
`ActionCallableSignature` represents fixed signatures with `rest_param = null` and final-rest signatures with an
unbounded `max_arity`; this does not weaken the separate non-null rest invariant for variadic user functions.

Literal and body spans are half-open Unicode-character offsets in the containing ActionIR source. Nested literals
retain the same root coordinate space. Runtime and user-function copies remain fresh typed nodes, but reparse at
the original character offset so they do not silently reset spans to zero. That offset-preserving boundary is
parser-owned rather than a second AST codec.

The retained `body_ast` is typed ActionIR and is deferred. Construction never executes body mutations, calls, or
`retv` reads. Action-contract resolution and removed-selector scanning stop at the literal. All nine malformed
literal shapes produce `codeblock_literal_error` plus the exact neutral diagnostic code instead of raw fallback.

Ordinary assignment, `copy`, user-function arguments/results, compiled ActionIR JSON, generated-plan execution,
and the emitted effective-`SpecFile` payload preserve the same record. In-memory reconstruction of that emitted
payload goes back through `spec_ast.from_json`, the ordinary compiler, and the same interpreter. Semantic binding
projection reports `kind = codeblock` plus exact fixed/rest signature data. No Lua closure, captured environment,
route-specific codec, or second executor exists.

Construction and general bound invocation such as `cb(args)` are current on both PUC Lua and LuaJIT. Call-result
access, portable call failures, and ordered recursion use the same interpreter and are documented in
[[lua-callable-codeblock-dynamic-invocation]]. Independently loaded emitted execution is current under `.11.8.3`;
recurring/public admission is current under `.11.8.4`.

Related facts: [[callable-codeblock-literal-contract]], [[lua-callable-codeblock-typed-audit]],
[[lua-explicit-callable-codeblock-gap]], [[lua-callable-codeblock-dynamic-invocation]],
[[lua-contextual-user-function-codeblock-runtime]],
[[julia-callable-codeblock-literal-state]], [[dart-callable-codeblock-literal-state]],
[[rust-callable-codeblock-literal-state]].
