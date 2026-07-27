---
id: lua-rule-slot-marker-execution
title: Lua executes split-boundary and named-mark rule members as typed post-action slot events
answers:
  - does Lua execute @capture_slice rule members
  - does Lua execute @capture_from_here and @move_pos
  - does Lua execute @mark name rule members
  - when are Lua split marker effects visible
  - how does Lua compile split markers
  - does the shipped EBNF @move_pos have a Lua owner
  - are malformed Lua marker names typed
date: 2026-07-15
status: current
tags: [lua, capture, marks, compiler, runtime, timing, unicode, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.7.4 adds CompiledRuleSlotEvent records in lua/src/linkedspec/compiled_spec.lua and post-action/pre-LE execution in lua/src/linkedspec/interpreter.lua. lua/test/run.lua locks all three anonymous spellings, two named marks, same-slot versus later-slot timing, Unicode positions, native and serialized-source execution, typed malformed authored/manual AST markers, and the exact checked-in EBNF logging_annotation @move_pos line. tools/run_lua_local.sh passes 121/121 on PUC Lua and LuaJIT; canonical CI passes capability 64/0/0, coverage 246/105+1/122, selector admission 57/27/0, CLI 61x2, and Phase 0 1..1031 in 633 seconds."
reverify: "bash tools/run_lua_local.sh && bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
---

# Lua Rule-Slot Marker Execution

`LUA-BACKEND-PARITY.4.3.7.4` turns each valid `SplitMarkerBodyElementKind` into a typed
`CompiledRuleSlotEvent` attached to the preceding regex index. Preferred `@capture_slice` and compatibility
`@capture_from_here` / `@move_pos` canonicalize to `capture_boundary`; `@mark(name)` canonicalizes to
`named_mark` while preserving its identifier, source, and line. The events survive dependency resolution and
appear in both compiled-state and outward descriptor serialization.

After one regex slot matches, Lua first dispatches its action edges and child calls, then executes that slot's
events, then runs `LE`. A same-slot action therefore observes the old boundary/mark state; an action at a later
slot observes the update. Capture events call the existing anonymous-boundary setter, and named events write the
existing parse-scoped `rule label -> mark name -> UTF-8 byte offset` store. There is no marker-only shadow state.

The focused input `é(α🙂,βγ)` makes UTF-8 byte offsets diverge from public character positions and proves the
timing through native execution plus reconstruction from public source AST JSON. The test also embeds the exact
checked-in `rgx/subs/pgen/specs/ebnf.spec::logging_annotation` rule line and proves its `@move_pos` compiles to
one executable event at the expected slot. Empty, digit-leading, hyphenated, trailing-fragment, and prefix-typo
authored markers fail typed validation; a malformed validation-bypassed AST fails with stable compiled error
fields.

## Links

- Owner: [[LUA-BACKEND-PARITY]] `.4.3.7.4`.
- Timing contract: [[split-boundary-marker-action-timing]].
- State taxonomy: [[spec-capture-mark-family-taxonomy]].
- Runtime-family audit: [[lua-capture-cursor-runtime-audit]].
