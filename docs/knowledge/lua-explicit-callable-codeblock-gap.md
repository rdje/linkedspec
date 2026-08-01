---
id: lua-explicit-callable-codeblock-gap
title: Lua has explicit callable literals but no general bound-call path
answers:
  - "does Lua support explicit callable codeblock literals yet"
  - "how does Lua currently parse a brace-pipe callable literal"
  - "what Lua seams are missing for dynamic codeblock calls"
  - "can the Lua source emitter preserve callable codeblocks without a new codec"
  - "which Lua owner implements explicit callable codeblocks"
  - "which Lua scoped-binding seam should callable codeblocks reuse"
date: 2026-08-01
status: current-partial-gap
tags: [lua, callable, codeblock, actionir, dynamic-scope, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.8.1 closes exact inert literal construction/state after the .11.7.0 gap audit: brace-pipe syntax, eight-field AST/copy/registry state, nine malformed codes, and semantic/generated/emitted-effective transport are current on both Lua ABIs. The interpreter still has only declared-slot contextual execution and no post-static ordinary bound-value dispatch, so .11.8.2-.4 retain invocation, emitted execution, and admission without a new closure, executor, or codec."
evidence_update_2026_08_01_typed_audit: "FUTURE-PARITY-BACKLOG.11.8.0 confirms identical PUC Lua/LuaJIT gaps, distinguishes colon keyword data from positional name-equals assignment, freezes one focused Lua consumer, and records exact .11.8.1-.4 construction/invocation/route/admission owners in lua-callable-codeblock-typed-audit."
evidence_update_2026_08_01_construction: "FUTURE-PARITY-BACKLOG.11.8.1 closes exact literal construction/state on PUC Lua and LuaJIT. The remaining gap is general bound invocation, call-result access, portable callable failures/recursion, byte-fresh emitted execution, and final admission under .11.8.2-.4."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && rg -n 'block_value|codeblock_argument|execute_contextual_codeblock|runtime_scoped_binding|spec_ast\\.to_json|spec_ast\\.from_json' lua/src/linkedspec/action_ast.lua lua/src/linkedspec/action_parser.lua lua/src/linkedspec/interpreter.lua lua/src/linkedspec/runtime_scoped_binding.lua lua/src/linkedspec/source_emitter.lua && bash tools/run_lua_local.sh"
---

Lua's completed contextual surface is deliberately separate from explicit callable values. A final declared
`callback: codeblock` accepts attached or parenthesized zero-positional block syntax, stores a
`codeblock_argument`, and invokes that declared slot inside the current isolated user-function frame. That path
is not a general variable-call fallback.

The behavior-free probes originally established four missing mechanisms. `.11.8.1` has now closed construction
and copy/state preservation: exact brace-pipe forms are neutral eight-field values, malformed forms retain all
nine codes, and runtime/user-function/compiled/generated/emitted-effective/semantic paths preserve inert state.
The remaining mechanisms are:

1. `cb(value: "x")` has no typed keyword-argument node, while access such as `collector(...)["items"]` has no
   typed evaluated-call receiver before fluent continuation.
2. The interpreter resolves controls, helpers, and registered functions, then only recognizes a declared
   contextual codeblock parameter. It has no general bound-codeblock fallback, non-callable distinction, or
   active explicit-codeblock recursion stack.

The smallest coherent implementation reuses rather than replaces current authorities. `runtime_scoped_binding`
already provides protected temporary bindings, recursive value copy already owns isolation, and the source emitter
already serializes one effective `SpecFile` to generated Lua and reconstructs it through `spec_ast.from_json`.
Parser/AST/schema support now exists and uses that transport. Independently loaded emitted execution remains the
later route proof; a second codec or executor would create drift.

Four-backend governance and status correction remain `FUTURE-PARITY-BACKLOG.11.7`. The dependency-complete Lua
implementation is `FUTURE-PARITY-BACKLOG.11.8`: `.1` inert construction/state is complete, `.2` dynamic invocation, `.3`
serialized/generated/emitted dual-ABI identity, and `.4` five-backend admission/public closeout after `.0` freezes
the detailed RED plan. Lexical capture remains outside the accepted contract and requires a new decision/task.

Related facts: [[lua-callable-codeblock-literal-state]], [[lua-callable-codeblock-typed-audit]],
[[callable-codeblock-literal-contract]], [[lua-contextual-user-function-codeblock-runtime]],
[[lua-runtime-eager-block-values]], [[lua-staged-function-execution-split]],
[[lua-five-backend-capability-admission]].
