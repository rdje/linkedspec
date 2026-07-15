---
id: lua-diagnostic-output-events
title: Lua diagnostic helpers emit typed caller-owned events without changing parse values
answers:
  - does Lua execute print say and print_each
  - how do I capture Lua diagnostic helper output
  - what is RuntimeDiagnosticOutputEvent
  - does Lua diagnostic output enter RuntimeParseResult
  - is Lua quiet without a diagnostic sink
  - does Lua exit_now still terminate immediately
date: 2026-07-15
status: current
tags: [lua, runtime, helpers, diagnostic-output, events, Unicode, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.8 adds per-runtime_parse diagnostic_sink injection and typed RuntimeDiagnosticOutputEvent helper_name/rule_label/message records. print, say, and print_each evaluate arguments once left-to-right; messages preserve Unicode and order; no sink stays quiet; parse value/output remain structural; exit_now remains immediate typed control. tools/run_lua_local.sh passes 122/122 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh && rg -n 'RuntimeDiagnosticOutputEvent|diagnostic_sink|evaluate_runtime_diagnostic_output' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua callers opt into diagnostic helper output per parse:

```lua
local events = {}
local result = linkedspec.runtime_parse(engine, input, {
  diagnostic_sink = function(event)
    events[#events + 1] = event
  end,
})
```

Each callback argument is a typed `RuntimeDiagnosticOutputEvent` with `helper_name`, `rule_label`, and `message`.
`linkedspec.interpreter.to_json(event)` projects those exact fields. Delivery is synchronous and ordered.

- `print(value, ...)` concatenates one or more eagerly evaluated scalar-text values.
- `say(value, ...)` concatenates identically and appends one newline.
- `print_each(array, prefix[, suffix])` evaluates all arguments first, then emits one event per array item in
  source order. The optional suffix defaults to empty text, matching the Perl reference lowering.

Null and aggregate values contribute empty text; booleans use `1`/`0`; numbers use the stable portable scalar
spelling; UTF-8 strings pass through unchanged. A missing sink suppresses delivery but never skips argument side
effects. The helpers return null/void and never append messages to the rule accumulator, `RuntimeParseResult.value`,
or its one-value `output` wrapper.

`exit_now(status)` is unchanged: it raises the typed runtime failure immediately. Events emitted before it have
already reached the caller; later helper expressions do not run.

Cross-backend output transport and a few formatting details are not yet normalized; that separate fact and owner
are [[cross-backend-diagnostic-output-drift]].

Related facts: [[lua-runtime-helper-family-split]], [[lua-runtime-rule-interpreter]],
[[julia-diagnostic-output-helpers]].
