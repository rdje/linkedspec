---
id: lua-explicit-callable-codeblock-gap
title: Lua explicit callable gap audit now retains only final admission
answers:
  - "does Lua support explicit callable codeblock literals yet"
  - "how does Lua currently parse a brace-pipe callable literal"
  - "what Lua seams are missing for dynamic codeblock calls"
  - "can the Lua source emitter preserve callable codeblocks without a new codec"
  - "which Lua owner implements explicit callable codeblocks"
  - "which Lua scoped-binding seam should callable codeblocks reuse"
date: 2026-08-01
status: historical-gap-current-admission-residual
tags: [lua, callable, codeblock, actionir, dynamic-scope, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.8.1 closes exact inert literal construction/state after the .11.7.0 gap audit, and .11.8.2 closes the post-static ordinary bound-value path, call-result access, portable failures, and ordered recursion on both ABIs. Only independently emitted execution and final admission remain .11.8.3-.4."
evidence_update_2026_08_01_typed_audit: "FUTURE-PARITY-BACKLOG.11.8.0 confirms identical PUC Lua/LuaJIT gaps, distinguishes colon keyword data from positional name-equals assignment, freezes one focused Lua consumer, and records exact .11.8.1-.4 construction/invocation/route/admission owners in lua-callable-codeblock-typed-audit."
evidence_update_2026_08_01_construction: "FUTURE-PARITY-BACKLOG.11.8.1 closes exact literal construction/state on PUC Lua and LuaJIT. The remaining gap is general bound invocation, call-result access, portable callable failures/recursion, byte-fresh emitted execution, and final admission under .11.8.2-.4."
evidence_update_2026_08_01_invocation: "FUTURE-PARITY-BACKLOG.11.8.2 closes general bound invocation through one shared explicit/contextual executor. Focused 232x2 and complete dual-ABI Lua proof pass; .11.8.3-.4 retain only byte-fresh route identity and five-backend admission."
evidence_update_2026_08_01_emitted_identity: "FUTURE-PARITY-BACKLOG.11.8.3 closes native/reconstructed/generated/fresh-emitted identity through the existing effective-SpecFile transport and one interpreter at 449 assertions per ABI. Only five-backend admission .11.8.4 remains."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && rg -n 'block_value|codeblock_argument|active_codeblocks|callable_codeblock\\.execute|runtime_scoped_binding|spec_ast\\.to_json|spec_ast\\.from_json' lua/src/linkedspec/action_ast.lua lua/src/linkedspec/action_parser.lua lua/src/linkedspec/interpreter.lua lua/src/linkedspec/runtime_scoped_binding.lua lua/src/linkedspec/source_emitter.lua && bash tools/run_lua_local.sh"
---

Lua's contextual and explicit authoring surfaces remain syntactically distinct. A final declared
`callback: codeblock` accepts attached or parenthesized zero-positional block syntax, stores a
`codeblock_argument`; explicit `{|params| ...}` owns its signature. Both now invoke through the same post-static
bound-value executor inside the current caller frame.

The behavior-free probes originally established four missing mechanisms. `.11.8.1` closed construction and copy/
state preservation. `.11.8.2` then closed the two invocation mechanisms:

1. `cb(value: "x")` is typed for governed rejection while `cb(value = "x")` stays positional; evaluated call
   results have a typed `value_access` receiver before fluent continuation.
2. After static callables, one executor distinguishes bound codeblocks/non-codeblocks, installs copied fixed/rest
   parameters through the existing scoped binder, keeps nonparameters live, and owns portable failures plus one
   ordered recursion stack.

The implementation reuses rather than replaces current authorities. `runtime_scoped_binding` provides protected
temporary bindings, recursive value copy owns isolation, and the source emitter
already serializes one effective `SpecFile` to generated Lua and reconstructs it through `spec_ast.from_json`.
Parser/AST/schema support now exists and uses that transport. `.11.8.3` proves independently loaded emitted
execution through it; a second codec or executor would create drift.

Four-backend governance and status correction remain `FUTURE-PARITY-BACKLOG.11.7`. The dependency-complete Lua
implementation is `FUTURE-PARITY-BACKLOG.11.8`: `.1` inert construction/state and `.2` dynamic invocation are complete, `.3`
serialized/generated/emitted dual-ABI identity is complete, and `.4` retains five-backend admission/public closeout after `.0` freezes
the detailed RED plan. Lexical capture remains outside the accepted contract and requires a new decision/task.

Related facts: [[lua-callable-codeblock-literal-state]], [[lua-callable-codeblock-typed-audit]],
[[lua-callable-codeblock-dynamic-invocation]], [[callable-codeblock-literal-contract]],
[[lua-contextual-user-function-codeblock-runtime]], [[lua-callable-codeblock-emitted-route-identity]],
[[lua-runtime-eager-block-values]], [[lua-staged-function-execution-split]],
[[lua-five-backend-capability-admission]].
