---
id: lua-explicit-callable-codeblock-gap
title: Lua has contextual codeblock slots but no explicit literal or general bound-call path
answers:
  - "why does Lua not support explicit callable codeblock literals yet"
  - "how does Lua currently parse a brace-pipe callable literal"
  - "what Lua seams are missing for dynamic codeblock calls"
  - "can the Lua source emitter preserve callable codeblocks without a new codec"
  - "which Lua owner implements explicit callable codeblocks"
  - "which Lua scoped-binding seam should callable codeblocks reuse"
date: 2026-08-01
status: current-gap
tags: [lua, callable, codeblock, actionir, dynamic-scope, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.7.0 probes exact Lua ActionIR/runtime owners after four-backend completion. Brace-pipe syntax falls through eager block parsing to unsupported raw body syntax; the AST/copy/registry has contextual codeblock_argument only; the interpreter has only zero-argument declared-slot execution and no post-static bound-value dispatch. Existing runtime_scoped_binding and effective-SpecFile emission are reusable, so FUTURE-PARITY-BACKLOG.11.8 owns construction, invocation, generated identity, and admission without a new closure, executor, or codec."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && rg -n 'block_value|codeblock_argument|execute_contextual_codeblock|runtime_scoped_binding|spec_ast\\.to_json|spec_ast\\.from_json' lua/src/linkedspec/action_ast.lua lua/src/linkedspec/action_parser.lua lua/src/linkedspec/interpreter.lua lua/src/linkedspec/runtime_scoped_binding.lua lua/src/linkedspec/source_emitter.lua && bash tools/run_lua_local.sh"
---

Lua's completed contextual surface is deliberately narrower than explicit callable values. A final declared
`callback: codeblock` accepts attached or parenthesized zero-positional block syntax, stores a
`codeblock_argument`, and invokes that declared slot inside the current isolated user-function frame. That path
does not parse or represent the neutral eight-field `{|params| body }` value and is not a general variable-call
fallback.

Exact ActionIR probes on 2026-08-01 establish four missing mechanisms:

1. `{|left, ...rest| return(left) }` enters the ordinary brace branch, becomes `block_value`, and retains an
   unsupported raw body rather than a deferred typed literal.
2. `cb(value: "x")` has no typed keyword-argument node, while access such as `collector(...)["items"]` has no
   typed evaluated-call receiver before fluent continuation.
3. The interpreter resolves controls, helpers, and registered functions, then only recognizes a declared
   contextual codeblock parameter. It has no general bound-codeblock fallback, non-callable distinction, or
   active explicit-codeblock recursion stack.
4. Copy/registry validation reparses only `block_value` and `codeblock_argument`; no explicit literal record can
   survive those paths yet.

The smallest coherent implementation reuses rather than replaces current authorities. `runtime_scoped_binding`
already provides protected temporary bindings, recursive value copy already owns isolation, and the source emitter
already serializes one effective `SpecFile` to generated Lua and reconstructs it through `spec_ast.from_json`.
Once parser/AST/schema support exists, generated preservation belongs on that one transport; a second codec or
executor would create drift.

Four-backend governance and status correction remain `FUTURE-PARITY-BACKLOG.11.7`. The dependency-complete Lua
implementation is `FUTURE-PARITY-BACKLOG.11.8`: `.1` inert construction/state, `.2` dynamic invocation, `.3`
serialized/generated/emitted dual-ABI identity, and `.4` five-backend admission/public closeout after `.0` freezes
the detailed RED plan. Lexical capture remains outside the accepted contract and requires a new decision/task.

Related facts: [[callable-codeblock-literal-contract]], [[lua-contextual-user-function-codeblock-runtime]],
[[lua-runtime-eager-block-values]], [[lua-staged-function-execution-split]],
[[lua-five-backend-capability-admission]].
