---
id: lua-semantic-runtime-observation-generated-routes
title: Lua generated and emitted parsers forward typed semantic observations without changing emitted bytes
answers:
  - "do generated Lua parser helpers accept semantic_observation_sink"
  - "how do I capture semantic observations from an emitted Lua parser"
  - "which Lua generated semantic observation routes work on PUC Lua and LuaJIT"
  - "how does Lua preserve generated semantic callback failure identity"
  - "can generated Lua metadata forge semantic observation authorization"
  - "does Lua generated observation change emitted source format"
  - "does Lua generated observation change result trace or diagnostics"
  - "does Lua emitted exit produce a final semantic result event"
  - "does Lua serialize semantic observation state into generated source"
date: 2026-07-28
status: current generated-plan and fresh-emitted direct/traced propagation; composition closeout remains pending
tags: [lua, luajit, semantic-introspection, runtime, observation, generated-source, trace, diagnostics]
evidence: lua/src/linkedspec/source_emitter.lua; lua/src/linkedspec/interpreter.lua; lua/test/semantic_index_runtime_observation_generated_routes_test.lua; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.7.6.3
last_verified: 2026-07-28
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_observation_generated_routes_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_observation_generated_routes_test.lua"
  - "rg -n 'GENERATED_SEMANTIC_SINK_FAILURE_MT|_generated_semantic_observation_sink|semantic_observation_sink' lua/src/linkedspec/source_emitter.lua lua/src/linkedspec/interpreter.lua lua/test/semantic_index_runtime_observation_generated_routes_test.lua"
---

# Lua generated and emitted runtime observation routes

The public validated `execute_generated_parser_v2` and `execute_generated_parser_with_trace_v2` helpers accept the
same optional invocation-local `semantic_observation_sink` as native execution. Fresh modules produced by
`emit_lua_source_v2` expose matching `execute(input, options)` and `execute_with_trace(input, config, options)`
wrappers. Both PUC Lua and LuaJIT deliver the same protected `regex_slot_selected` and `rule_result` handles from
the committed native runtime seams; generated execution creates no second event vocabulary or derivation path.

`execute_generated` wraps only a supplied semantic sink with a protected callback carrier. It passes that wrapped
function as both `semantic_observation_sink` and the package-private `_generated_semantic_observation_sink` marker.
The native runtime accepts generated observation only when the two function identities are exact. Native cleanup
may unwrap its own semantic carrier, after which the generated wrapper recognizes its carrier before broad
`GeneratedSourceError` translation and rethrows the original string, table, `nil`, or runtime-error object. The
existing diagnostic callback carrier remains separate; arbitrary generated metadata cannot authorize the sink.

The emitted wrappers already forwarded their options table, so this propagation changes no emitted source text.
Repeated bytes remain deterministic `linkedspec-generated-source-v2` / format 2 and plan rows remain exactly
`{label, family}`. No observation option, contract vocabulary, callback, event, or invocation state is serialized.
No-sink execution still avoids event construction, scalar conversion, and input hashing.

Canonical public direct/traced, fresh emitted direct/traced, and repository-local isolated-host routes each emit
two accepted slots plus one successful final result and retain twentieth typed/raw-neutral digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`. Installing the sink does not change result,
cursor, trace bytes/events, or diagnostic events. Normal unmatched execution emits its final success; entry,
runtime, and immediate-exit failures omit it. Callback failure stops later delivery, and reentrant calls retain
separate event sequences.

The focused route owner passes 80 assertions on each ABI, including rejection of generated sinks without the exact
marker and markers without generated metadata. All ten Lua semantic owners compose at 1,964 assertions per ABI;
complete Lua passes package `1..177` per ABI, PUC primary 66x2, corpus 105/105, and 15-owner same-volume storage.
Semantic rollout remains 5/9 and native admission remains 4/6 pending their separate owners.

Complete signoff passes primary 5x2x66, Unicode 10/10, all six unchanged ledgers, and canonical CI with Rust
admission 1/1 in 82.65 seconds, Dart 1/1, Julia 416/416 in 29.5 seconds, containment/moved-root proof, reference
primary 66x2, and Phase 0 1,031/1,031 in 667 seconds. mdBook and Knowledge Map 733/5,874 pass; exact cleanup removes
only the 13,040-KiB rendered book and one proven-empty managed-run directory while retaining reusable repository-
local caches and governed artifact evidence.

Related facts: [[lua-semantic-runtime-observation-authority-map]],
[[lua-semantic-runtime-observation-direct-capture]], [[lua-semantic-runtime-observation-derivation]],
[[lua-generated-source-emitter-core]], [[lua-generated-source-fresh-process-isolation]],
[[julia-semantic-runtime-observation-generated-routes]].
