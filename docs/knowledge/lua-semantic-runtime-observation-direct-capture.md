---
id: lua-semantic-runtime-observation-direct-capture
title: Lua native execution delivers protected typed semantic observations through one invocation-local sink
answers:
  - "how do I capture Lua runtime semantic observations"
  - "which Lua runtime routes support semantic observation"
  - "what fields are on a Lua semantic observation event"
  - "are Lua semantic observation events immutable"
  - "how do I serialize a Lua semantic observation event"
  - "what happens when a Lua semantic observation callback fails"
  - "does a normally unmatched Lua parse emit a final semantic event"
  - "do Lua execution failures emit semantic result events"
  - "does Lua semantic observation change trace diagnostics or results"
  - "does Lua semantic observation work through generated parsers"
  - "does Lua semantic observation hash input when no sink exists"
date: 2026-07-28
status: current native direct capture reused by current observed-index derivation and generated propagation
tags: [lua, luajit, semantic-introspection, runtime, observation, immutability, callback, trace, diagnostics]
evidence: lua/src/linkedspec/semantic_observation.lua; lua/src/linkedspec/sha256.lua; lua/src/linkedspec/interpreter.lua; lua/src/linkedspec/init.lua; lua/test/semantic_index_runtime_observation_native_test.lua; FUTURE-PARITY-BACKLOG.10.7.6.1
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_observation_native_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_observation_native_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_observation_generated_routes_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_observation_generated_routes_test.lua"
  - "bash tools/run_lua_local.sh"
---

# Lua native typed runtime observation capture

Lua native parse/execute calls accept one optional per-invocation `semantic_observation_sink` function. Direct
engines, loaded engines, normalized-AST reconstructed engines, `runtime_execute`, and both traced convenience
aliases reuse the same interpreter seam on PUC Lua and LuaJIT. Engines reject the sink as retained configuration.
Generated-plan and freshly emitted direct/traced routes now reuse this seam through `.10.7.6.3`. The native
runtime accepts a generated sink only when it is exactly the wrapped callback installed as the private generated
authorization marker, preserving the earlier fence against accidental or forged partial propagation.

Every event is a protected immutable handle under
`linkedspec-semantic-execution-observation-v1`. The root package exposes the contract id,
`is_runtime_semantic_observation_event`, and `runtime_semantic_observation_event_to_json`; constructors stay
package-internal. The detached JSON projection always has exactly eight fields: contract id, event kind, executing
rule label, nullable target rule, nullable zero-based regex index, Unicode-scalar position, nullable input identity,
and nullable status. A deep-equivalent JSON object is not a typed event, and mutating a projection cannot mutate
the handle.

Accepted slots deliver synchronously before `accept_match`, using `one:char_end()` plus every compiled ordered slot
identity. Normally constructed results then deliver one `rule_result` with status `succeeded` and
`input:sha256:<lowercase-hex>` over the exact input bytes. That includes normal `matched=false` results. Entry
selection, execution, and `RuntimeExitNow` failures omit the final event. Callback failure stops later delivery;
a private protected carrier lets all active trace scopes close and then rethrows the exact caller string, table,
`nil`, or existing runtime-error object. Trace bytes/events, diagnostic events, results, cursors, and reentrant
invocation sequences remain independent.

No-sink match paths create no semantic closure or event and do not call the match scalar-end converter. No-sink
final paths create no event and do not hash input. Source content digests and final input identities share the one
package-internal arithmetic `linkedspec.sha256` owner, which uses the Lua-5.1-compatible language surface and no
external executable, optional native digest module, path, or cache.

The canonical `runtime.spec` over `ab\n` returns `['A','B']`, finishes at byte/scalar cursor 2, selects `Top[0]`
at scalar 1 and `Top[1]` at scalar 2, then completes `Top` at scalar 2 with input identity
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`. Focused proof passes 121 assertions per
ABI; the seven static/query suites total 1,493 per ABI, and complete Lua passes package `1..177`, PUC primary
66x2, corpus 105/105, and the 14-owner repository-storage proof.

Complete signoff passes primary 5x2x66, Unicode 10/10, every unchanged no-drift ledger, and canonical six-doctrine
CI with Rust admission 1/1 in 77.88 seconds, Dart 1/1, Julia 416/416 in 27.3 seconds, containment/moved-root proof,
reference primary 66x2, and Phase 0 1,031/1,031 in 621 seconds. Knowledge Map is 731 facts / 5,851 keys. Exact
cleanup removes only the 208-KiB leaf-owned adapter scratch, 13,000-KiB rendered book, and one empty run directory;
no Lua adapter remains and 246 reusable Rust artifacts are retained.

Related facts: [[lua-semantic-runtime-observation-authority-map]],
[[lua-semantic-runtime-observation-generated-routes]], [[lua-semantic-runtime-observation-derivation]],
[[lua-semantic-query-public-api]],
[[lua-runtime-trace-events]], [[lua-diagnostic-output-events]], [[lua-project-data-ssd-storage]],
[[julia-semantic-runtime-observation-direct-capture]], and [[rust-semantic-runtime-observation]].
