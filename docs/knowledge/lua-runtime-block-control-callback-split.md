---
id: lua-runtime-block-control-callback-split
title: Lua block and callback execution is split from general user-function and callable-codeblock invocation
answers:
  - how is Lua codeblock control and callback runtime work split
  - does Lua already parse trailing codeblocks and controls
  - does Lua already execute block values
  - which Lua task owns expression valued blocks
  - which Lua task owns inline and structured controls
  - which Lua task owns with and tree callbacks
  - which Lua task owns user function final codeblocks
  - which task owns Lua callable codeblock variables
date: 2026-07-13
status: current
tags: [lua, runtime, codeblock, controls, callbacks, user-functions, planning, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.6.0 audits lua/src/linkedspec/action_parser.lua, action_contracts.lua, interpreter.lua, and user_function_registry.lua. Parser/resolver support is structural; runtime block/control/callback execution is absent, and general user-function dispatch remains LUA-BACKEND-PARITY.5.1."
evidence_update_2026_07_13_eager_blocks: "LUA-BACKEND-PARITY.4.3.6.1 executes ordinary no-pair brace values, consumes block-local return, preserves harray classification, and corrects the earlier Lua-only inert assignment expectation at 104/104 on both ABIs."
evidence_update_2026_07_13_inline_controls: "LUA-BACKEND-PARITY.4.3.6.2 executes lazy inline if/switch values, selected expression blocks, one-time switch subjects, literal bare case labels, and fluent returns at 105/105 on both ABIs; statement/attached aliases remain structural."
evidence_update_2026_07_13_statement_controls: "LUA-BACKEND-PARITY.4.3.6.3.1-.3 execute attached/marker if, attached/marker switch, and attached while at 108/108. Current built-in final blocks/with remain .4; callbacks remain .5."
reverify: "rg -n 'block_value|control_if|control_switch|control_while|prepare_invocation' lua/src/linkedspec/action_parser.lua lua/src/linkedspec/action_contracts.lua lua/src/linkedspec/interpreter.lua lua/src/linkedspec/user_function_registry.lua && bash scripts/check_task_tree_metadata.sh"
---

## Fact

Lua's ActionIR parser is ahead of its runtime. It already emits `block_value`
and structured control nodes, and it appends both attached `call(args) { ... }`
and parenthesized `call(args, { ... })` blocks as final positional block values.
The contract resolver traverses those nodes without deciding their behavior.

The interpreter now executes eager `block_value`, inline controls, attached/marker if and switch, and attached
while through `.4.3.6.1-.3.3`. It still has no scoped `with` or walk/map/reduce callback frame. The user-function registry can prepare an
invocation, but the interpreter does not yet call it; general staged-function
runtime dispatch is explicitly owned by `LUA-BACKEND-PARITY.5.1`.

`LUA-BACKEND-PARITY.4.3.6` therefore has dependency-ordered children:

1. `.1`: eager expression blocks and block-local return;
2. `.2`: lazy inline value controls;
3. `.3.1-.3.3`: attached/marker if, switch, and while statements;
4. `.4`: signature-governed current built-in block arguments and scoped `with`;
5. `.5.1-.5.2`: deterministic harray/array leaf callbacks;
6. `.6`: no-drift and explicit dependency handoff.

This split preserves, rather than weakens, the generic final-codeblock model.
Current built-ins may consume contextual codeblocks once `.4.3.6.4` lands.
General user functions consume their final `codeblock` parameter only after
`.5.1` connects function dispatch. Explicit `{|params| ...}` literals and
dynamic codeblock-variable calls remain the later Lua obligation routed by
`FUTURE-PARITY-BACKLOG.11.7`.

Related facts: [[lua-actionir-ast-parser]], [[lua-runtime-helper-family-split]],
[[generic-trailing-codeblock-argument-correction]],
[[callable-codeblock-literal-contract]], [[terse-expression-valued-block-early-return]],
[[lua-runtime-eager-block-values]].
