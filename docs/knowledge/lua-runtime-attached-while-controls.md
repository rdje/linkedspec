---
id: lua-runtime-attached-while-controls
title: "Lua attached while re-evaluates state and enforces a typed post-limit guard"
answers:
  - "does Lua execute attached while statements"
  - "does Lua while re-evaluate its condition"
  - "can a Lua while body update its next condition"
  - "what happens to return inside Lua attached while"
  - "what is the Lua while iteration limit diagnostic"
  - "what does LUA-BACKEND-PARITY.4.3.6.3.3 implement"
date: 2026-07-13
status: current
tags: [lua, runtime, actionir, control-flow, while, safety, diagnostics, parity]
evidence: "LUA-BACKEND-PARITY.4.3.6.3.3 adds execute_attached_while, an inner next-flow boundary, and while_iteration_limit_failure to lua/src/linkedspec/interpreter.lua. lua/test/run.lua locks false-initial execution, condition/body order, state visibility, action and expression-block return, Perl-reference next, exact-limit success, next-truthful failure, typed code/keyword/kind/limit/rule fields, and bodyless rejection before condition evaluation. PUC Lua and LuaJIT pass 108/108."
reverify: "bash tools/run_lua_local.sh && bash knowledge-map/scripts/check_knowledge_map.sh"
---

# Lua Runtime Attached While Controls

Lua dispatches typed `control_while` through the indexed statement executor. It requires an attached body before
evaluating the condition, then repeatedly:

1. evaluates the condition against current bindings;
2. stops when it is false;
3. fails before another body when the configured completed-body limit is already reached;
4. otherwise executes the body and repeats.

This permits exactly `max_iterations` bodies and gives a loop one final condition recheck. A remaining true
condition raises `while_iteration_limit_exceeded` with `control_keyword`, `action_kind`, `max_iterations`, and
`rule_label`.

Return flow is not consumed by the loop: it exits the surrounding action, while an enclosing expression-valued
block catches it as that block's local result. Lua catches statement `next()` at the loop boundary as inner-loop
continue, matching generated Perl. See [[cross-backend-attached-while-boundary-drift]] for nonportable edges.

## Links

- Owner: [[LUA-BACKEND-PARITY]] `.4.3.6.3.3`.
- Original contract: [[terse-attached-while-split-ground-truth]].
- Next Lua leaf: [[LUA-BACKEND-PARITY]] `.4.3.6.4`.
