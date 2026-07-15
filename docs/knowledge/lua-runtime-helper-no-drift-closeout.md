---
id: lua-runtime-helper-no-drift-closeout
title: Lua native helper value and control execution closes with exact 233 plus 13 ownership
answers:
  - are all 246 Lua call names runtime owned
  - which Lua call names are intentionally not functions
  - what is the Lua backend parity status after helper closeout
  - does Lua directly execute call rule
  - how is Lua all helper runtime drift detected
  - why was no duplicate or inventory row removed
date: 2026-07-15
status: current
tags: [lua, runtime, helpers, controls, call, no-drift, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.9.2 exposes a sorted defensive current_names view and drives all 246 generated name() actions through parse, compile, and runtime. Exactly 233 reach function-form owners and thirteen documented structural/receiver-only names report unsupported; a focused call(Child) assertion locks child result, retv, and cursor. backend_status parity is runtime-helper-value-control. tools/run_lua_local.sh passes 125/125 on PUC Lua and LuaJIT; coverage is 246/105+1/122 and capability is 64/0/0. Canonical local CI passes CLI 61x2 and Phase 0 1..1031 in 608 seconds."
reverify: "bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl --report && perl tools/check_capability_conformance.pl"
---

Lua's admitted call inventory is now an executable boundary rather than a membership-only claim. The permanent
test receives a fresh sorted list from `action_call_names.current_names()`, builds one minimal action per name, and
requires every source to parse and compile before runtime classification.

The exact partition is:

| Result | Count | Names |
| --- | ---: | --- |
| Function form reaches a runtime owner | 233 | Every admitted name except the thirteen below. |
| Intentional non-function form | 13 | Structural `case`, `elif`, `elseif`, `i`, `when`, `while`; receiver-only `walk_leaves`, `map_leaves`, `reduce_leaves`; named-receiver-only `push_back`, `push_front`, `pop_back`, `pop_front`. |

A separate focused rule proves `call(Child)` returns the child's value, refreshes `retv` to the same copied value,
and leaves the shared Unicode-character cursor after the child match. The public status
`runtime-helper-value-control` names only the completed native interpreter boundary. It does not claim the later
diagnostic/trace, general-function, corpus-execution, primary-CLI, or generated-source milestones.

The earlier `.4.3.9.0` audit note also claimed a duplicate `or` source row. Exact inspection of current and
historical `lua/src/linkedspec/action_call_names.lua` revisions finds one row each. Because the claim cannot be
reproduced from committed source, `.4.3.9.2` corrects the durable note and intentionally makes no fake inventory
edit.

Related facts: [[lua-exhaustive-runtime-call-audit]], [[lua-logical-helper-execution]],
[[lua-runtime-helper-family-split]], [[public-call-inventory-independent-coverage]].
