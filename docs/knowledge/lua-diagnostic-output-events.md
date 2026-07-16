---
id: lua-diagnostic-output-events
title: Lua diagnostic helpers emit typed caller-owned events without changing parse values
answers:
  - does Lua execute print say and print_each
  - how do I capture Lua diagnostic helper output
  - what is RuntimeDiagnosticOutputEvent
  - does Lua diagnostic output enter RuntimeParseResult
  - is Lua quiet without a diagnostic sink
  - does Lua preserve diagnostic sink failure identity
  - does Lua exit_now still terminate immediately
  - what is Lua RuntimeExitNow
  - how do generated Lua parsers expose diagnostic output
date: 2026-07-16
status: current
tags: [lua, runtime, helpers, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "LUA-BACKEND-PARITY.4.3.8 adds the typed per-parse event seam. FUTURE-PARITY-BACKLOG.5.1.6 consumes linkedspec-diagnostic-output-v1 natively on PUC Lua and LuaJIT with exact arbitrary sink-failure preservation and distinct typed RuntimeExitNow control. FUTURE-PARITY-BACKLOG.5.1.7 proves the emitted option-bearing direct/traced API and preserves the same outcomes across generated-source framing."
reverify: "bash tools/run_lua_local.sh && rg -n 'RuntimeDiagnosticOutputEvent|RuntimeExitNow|diagnostic_sink|evaluate_runtime_diagnostic_output' lua/src/linkedspec/interpreter.lua lua/test/diagnostic_output_contract_test.lua"
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

If the sink throws, Lua carries the exact caller value opaquely through internal action/rule failure handling and
restores it at the public parse boundary. That includes a caller-thrown `RuntimeInterpreterException`; it is not
cloned or attributed as an engine failure.

`exit_now(status)` raises a distinct `RuntimeExitNow` object immediately. `linkedspec.is_runtime_exit_now(error)`
identifies it, `.status` carries the requested status, and `interpreter.to_json(error)` projects that status.
Events emitted before it have already reached the caller; later helper expressions do not run.

Generated modules expose `execute(input, { diagnostic_sink = sink })` and
`execute_with_trace(input, trace_config, { diagnostic_sink = sink })`. The emitter wraps callable sinks in a
private carrier so an arbitrary caller value and `RuntimeExitNow` survive generated-source framing; invalid sink
types still reach the native validator and ordinary failures remain source-attributed. All five native and
generated engines now share the neutral behavior; see [[cross-backend-diagnostic-output-drift]].

Related facts: [[lua-runtime-helper-family-split]], [[lua-runtime-rule-interpreter]],
[[julia-diagnostic-output-helpers]].
