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
evidence_update_2026_07_13_builtin_blocks: "LUA-BACKEND-PARITY.4.3.6.4 executes metadata-governed helper/receiver with in attached and parenthesized form through copied/restored scope at 112/112; tree callback behavior remains .5."
evidence_update_2026_07_13_harray_callbacks: "LUA-BACKEND-PARITY.4.3.6.5.1.2 executes sorted harray walk/map/reduce through one copied/restored value/key/path/depth/acc frame at 113/113 on both Lua ABIs; array-root traversal was then owned by .5.2."
evidence_update_2026_07_13_array_callbacks: "LUA-BACKEND-PARITY.4.3.6.5.2 generalizes the dispatcher by receiver root kind and executes zero-based array walk/map/reduce at 114/114 on both Lua ABIs; cross-kind aggregates remain leaves."
evidence_update_2026_07_13_closeout: "LUA-BACKEND-PARITY.4.3.6.6 closes the parent after tools/run_lua_local.sh passes 114/114 on PUC Lua and LuaJIT, the callable-codeblock and punctuation-light checkers pass, capability census remains 64/0/0, and every public surface agrees. Destination acceptance now explicitly makes LUA-BACKEND-PARITY.5.1 own final callback: codeblock user-function metadata plus attached/parenthesized contextual execution; FUTURE-PARITY-BACKLOG.11.7 retains explicit literals and dynamic calls."
evidence_update_2026_07_15_user_function_callbacks: "LUA-BACKEND-PARITY.5.1.4.1/.2 preserve final callback metadata, normalize both contextual spellings, and execute current-frame zero-positional blocks at 146/146 on both Lua ABIs; explicit literals and general dynamic calls remain .11.7."
evidence_update_2026_07_15_staged_function_closeout: "LUA-BACKEND-PARITY.5.1.5 closes staged-function no-drift at the same 146/146 boundary and activates native loading .5.2."
evidence_update_2026_08_01_callable_routing: "FUTURE-PARITY-BACKLOG.11.7.0 retains current eager/control/contextual behavior and routes explicit literal/general bound-call construction, execution, generation, and admission to .11.8."
reverify: "bash tools/run_lua_local.sh && bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_python_project_data.sh tools/check_punctuation_light_zero_arg_contract.py && perl tools/check_capability_conformance.pl && rg -n 'LUA-BACKEND-PARITY.4.3.6.6|callback: codeblock|FUTURE-PARITY-BACKLOG.11.8' docs/tasks/LUA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

## Fact

Lua's ActionIR parser is ahead of its runtime. It already emits `block_value`
and structured control nodes, and it appends both attached `call(args) { ... }`
and parenthesized `call(args, { ... })` blocks as final positional block values.
The contract resolver traverses those nodes without deciding their behavior.

The interpreter now executes eager `block_value`, inline controls, attached/marker if and switch, attached while,
signature-governed helper/receiver `with`, and root-kind hash/array walk/map/reduce callbacks through
`.4.3.6.1-.5.2`. General staged fixed/variadic user functions and their contextual final blocks now execute
through `LUA-BACKEND-PARITY.5.1.1-.5.1.4.2`; scoped no-drift `.5.1.5` closes the parent.

`LUA-BACKEND-PARITY.4.3.6` therefore has dependency-ordered children:

1. `.1`: eager expression blocks and block-local return;
2. `.2`: lazy inline value controls;
3. `.3.1-.3.3`: attached/marker if, switch, and while statements;
4. `.4`: signature-governed current built-in block arguments and scoped `with`;
5. `.5.1`: deterministic harray callbacks; `.5.2`: root-kind array callbacks (both done);
6. `.6`: no-drift and explicit dependency handoff (done; parent closed).

This split preserves, rather than weakens, the generic final-codeblock model.
Current built-in `with` consumes contextual codeblocks through `.4.3.6.4`.
General user functions consume their final `callback: codeblock` parameter through `.5.1.4.1/.2`, which preserve
the declaration and connect attached/parenthesized contextual execution to current function-frame dispatch.
Explicit `{|params| ...}` literals and
dynamic codeblock-variable calls remain the later Lua obligation routed by
`FUTURE-PARITY-BACKLOG.11.8`.

Related facts: [[lua-actionir-ast-parser]], [[lua-runtime-helper-family-split]],
[[generic-trailing-codeblock-argument-correction]],
[[callable-codeblock-literal-contract]], [[terse-expression-valued-block-early-return]],
[[lua-runtime-eager-block-values]], [[lua-runtime-builtin-final-codeblocks-with]],
[[lua-runtime-harray-tree-callbacks]], [[lua-runtime-array-tree-callbacks]].
