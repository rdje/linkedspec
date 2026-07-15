---
id: lua-action-edge-child-call-reuse
title: Lua action-edge calls cache one selected child result and skip passive-terminal re-search
answers:
  - why did Lua execute HLink EBNF and SimEnv action-edge children twice
  - how does Lua call child reuse the current action edge
  - does Lua call an unrelated named rule normally inside an action edge
  - what is a passive terminal child in the Lua runtime
  - why did Lua EBNF whitespace skip every body token
  - how many Lua advanced corpus fixtures pass after action-edge repair
date: 2026-07-15
status: current
tags: [lua, runtime, action-edge, call, passive-terminal, recursion, corpus, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.6.2.1 routes call(target) through dispatch_edge_child when target matches the current compiled action edge, caches one result, refreshes retv, and leaves unrelated named calls on direct execution. The dispatcher structurally skips rules with no lifecycle/action/blind/plain payload because the parent dependency regex already consumed the passive terminal match. Trace-backed tests lock non-self, self-recursive, passive, and unrelated paths on PUC Lua and LuaJIT at 163/163. Exact offsets 40-98 improve from 50/59 to 56/59 on both ABIs: all three HLink, both EBNF, and SimEnv cases pass unchanged; only three separately owned compare residuals remain."
reverify: "bash tools/run_lua_local.sh"
---

# Lua Action-Edge Child Call Reuse

An action edge already owns a selected child target and a per-edge result slot. When
`call(target)` names that same target, Lua dispatches through the slot instead of
starting an independent rule call. The first request executes at most once, caches the
result, updates `retv`, and marks the edge dispatched so `accept_match(...)` cannot run
the child again as fallback. A call naming any other rule remains an ordinary direct
rule call and does not consume the current edge slot.

Passive terminal rules make the boundary explicit. If a compiled child has no lifecycle
payload, action edge, blind edge, or plain action payload, the parent dependency regex
has already consumed everything that handler can contribute. Lua caches a null child
result without re-entering the rule and emits `passive=1` on the existing child-dispatch
trace. Before this guard, EBNF's body-less `whitespace` child began at cursor 8, used
default seek repetition to find every later whitespace, and jumped to cursor 40; the
grammar consequently retained only its first rule header.

The focused proof covers four non-interchangeable cases:

- a value-returning current child enters once and publishes the same value through the
  assignment and `retv` channels;
- a passive child is not re-searched and leaves the cursor immediately after the parent
  match;
- a self-recursive edge uses the same cached dispatcher without losing cursor/value
  state;
- an unrelated named call executes normally before the current edge's fallback child.

At this leaf boundary, the exact advanced window passed 56/59 on both Lua ABIs.
The independent receiver-copy, flat-array hash-splice, and leading-trivia repairs
subsequently closed their `.6.2.2-.4` owners and brought the window to 59/59.

Related facts: [[rust-action-edge-child-return-dispatch]],
[[julia-action-edge-child-push]], [[lua-advanced-corpus-residual-split]].
