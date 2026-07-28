---
id: lua-semantic-runtime-observation-authority-map
title: Lua runtime semantics must be captured at accepted match-end and normally returned result seams
answers:
  - "does Lua already have a semantic runtime observation sink"
  - "where must Lua capture regex slot semantic events"
  - "where must Lua capture final semantic result events"
  - "which Lua match position owns semantic observation positions"
  - "should Lua semantic observations reuse trace output"
  - "should Lua semantic observations reuse diagnostic output"
  - "what happens when no Lua semantic observation sink is installed"
  - "how must Lua semantic observer callback failures propagate"
  - "why do generated Lua wrappers need semantic observer failure passthrough"
  - "which Lua execution routes reuse the runtime observation seams"
  - "how must Lua derive an observed semantic index"
  - "can Lua semantic query execute the parser"
  - "what is the Lua semantic runtime observation implementation split"
  - "which SHA 256 implementation must Lua runtime observation use"
  - "why are Lua semantic observation imports function local"
  - "how many top level locals can the Lua interpreter chunk use"
  - "how do generated Lua parsers authorize semantic observation sinks"
  - "does Lua generated semantic observation change emitted source bytes"
date: 2026-07-28
status: native capture, immutable derivation, and generated/emitted propagation implemented; composition remains planned
tags: [lua, luajit, semantic-introspection, runtime, observation, trace, diagnostics, generated-source]
evidence: lua/src/linkedspec/interpreter.lua; lua/src/linkedspec/semantic_observation.lua; lua/src/linkedspec/semantic_runtime_projection.lua; lua/src/linkedspec/sha256.lua; lua/src/linkedspec/init.lua; lua/src/linkedspec/matching.lua; lua/src/linkedspec/compiled_spec.lua; lua/src/linkedspec/spec_loader.lua; lua/src/linkedspec/source_emitter.lua; lua/src/linkedspec/semantic_index.lua; lua/test/semantic_index_runtime_observation_native_test.lua; lua/test/semantic_index_runtime_projection_test.lua; lua/test/semantic_index_runtime_observation_generated_routes_test.lua; capability_conformance/semantic_introspection_model.json; capability_conformance/semantic_introspection_contract.json; docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.7.6.0-.3
last_verified: 2026-07-28
reverify:
  - "rg -n 'trace_regex_slot_selected|accept_match|RuntimeParseResult|diagnostic_output_sink_failure|runtime_parse' lua/src/linkedspec/interpreter.lua"
  - "rg -n 'GENERATED_DIAGNOSTIC_SINK_FAILURE_MT|GENERATED_SEMANTIC_SINK_FAILURE_MT|_generated_semantic_observation_sink|execute_generated|function M.execute' lua/src/linkedspec/source_emitter.lua lua/src/linkedspec/interpreter.lua"
  - "rg -n 'byte_offset_to_char_offset|function MatchMethods:char_end' lua/src/linkedspec/matching.lua"
  - "rg -n 'semantic_observation|RuntimeSemanticObservation|with_execution_observation' lua/src lua/test"
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_observation_native_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_observation_native_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_projection_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_projection_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_observation_generated_routes_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_observation_generated_routes_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "bash tools/run_lua_local.sh"
---

# Lua semantic runtime observation authority map

## Current boundary

Lua now has one typed semantic runtime-observation channel on both ABIs. Native direct, loaded, normalized-AST
reconstructed, execute-alias, and traced convenience routes are implemented by `.10.7.6.1`; detached immutable
observed-index derivation is implemented by `.10.7.6.2`; public generated-plan direct/traced and freshly emitted
direct/traced routes, including isolated hosts, are implemented by `.10.7.6.3`. The high trace topic
`lua_runtime:regex_slot_selected` remains string observability and diagnostic events remain a separate optional
product. Neither is normalized semantic evidence.

The exact selected-slot call sites are after a regex match exists and any ordered target/index invariant succeeds,
but before `accept_match(...)` changes cursor, registers, actions, rule-slot events, or lifecycle state. At that
seam `ctx.cursor_byte` is still the pre-match position. The post-match portable position must come from
`one:char_end()`, which converts `one.byte_end` to a Unicode-scalar offset. The executing rule is `rule.label`;
each authored target rule and zero-based regex index comes from
`compiled_spec.compiled_regex_slot_identities_for(rule, one.alternative_index)`. A direct dual-ABI Unicode probe
locks `xé` at byte end 3 and scalar end 2.

The single final-result seam is immediately after successful `RuntimeParseResult` construction and before its
trace-scope exit/return. It owns the resolved entry label, copied exact input, and final
`cursor_char_offset`. Every normally returned invocation, including a normal `matched=false` result, is a
succeeded invocation and emits the final event. Entry-selection or execution throws and `RuntimeExitNow` emit no
final event. A callback failure stops synchronously before any later event; if the final callback itself fails,
that final event has already been delivered to the callback but the parse does not return.

## Implemented typed native boundary

Leaf `.10.7.6.1` exposes contract `linkedspec-semantic-execution-observation-v1` through protected immutable
Lua event handles and one optional invocation-local `semantic_observation_sink` function. The root API exposes
the contract id, an exact-event guard, and a detached JSON projector; runtime-owned constructors stay private.
The closed `regex_slot_selected` / `rule_result` vocabulary carries `contract_id`, `event_kind`, `rule_label`,
nullable `target_rule`/`regex_index`, Unicode-scalar `position`, and nullable `input_identity`/`status`. Slot events
populate only target/index; result events populate exact `input:sha256:<lowercase-hex>` and `succeeded`. Host
result values never enter an event.

The semantic callback remains separate from `LinkedSpecTraceEmitter` and `diagnostic_sink`. Every semantic
emission path must return before event allocation and scalar conversion when the sink is absent; final emission
must also return before hashing input. The final identity uses one package-internal extraction of the existing
Lua-5.1-compatible pure-Lua SHA-256 implementation formerly embedded in `semantic_index.lua`. It may not invoke an
external executable/module or duplicate a second algorithm.

A semantic callback may throw any Lua value, including an existing runtime/generated error object. Native
execution needs a private semantic-only carrier at the callback boundary and must restore the exact caller value
after closing active trace scopes. Generated execution needs its own semantic-only wrapper/carrier because
`execute_generated(...)` otherwise converts arbitrary thrown values to `GeneratedSourceError`. That carrier must
be parallel to, not shared with, the diagnostic-output carrier so neither callback channel can misclassify the
other or an unrelated runtime failure.

`runtime_parse` is the common native seam. `runtime_execute` aliases it; both traced conveniences clone options
and delegate to it. `LoadedCompiledSpec:create_engine()` constructs the same runtime engine, and normalized AST
JSON reconstruction recompiles into that engine. Public generated-plan helpers and fresh emitted modules now carry
the same sink through the generated-only authorization and callback carrier described below.

PUC Lua's chunk-wide local-variable limit is a concrete implementation constraint here: `interpreter.lua` was
already at the 200-local ceiling before this leaf. Adding a module-level observation import or helper made
`loadfile` fail. The observation import and conditional slot-emission closure therefore live inside
`runtime_parse` and `regex_once`. The closure is created only for an installed sink, preserving the no-sink event/
slot-scalar work fence without merging semantic ownership into trace or diagnostics.

## Implemented immutable derivation boundary

Leaf `.10.7.6.2` adds `index:with_execution_observation(events)`. It accepts a dense caller-retained sequence
of exact protected event handles, validates contract/kind/nullability, nonnegative portable positions and indices,
a compiled base with `has_execution=false`, stable lowercase input identity, and exactly one succeeded final event
last whose rule is the selected entry. Each slot must map from its executing static rule through one owned edge
and `selects_regex` relation to the named target rule/authored slot.

Derivation receives only one fresh detached static projection. Slot source comes from the selected regex-slot
record and value shape from the selecting edge; final source and result shape come from the selected static rule.
It must not parse, validate, compile, execute, install a sink, enable trace, hash a new input, inspect host result
values, read paths/environment, or consume retained source/compiler/staged/generated/runtime objects. It returns a
new protected index whose projection sets `has_execution=true`, adds canonical `execution:0`, ordered event
records, and one `observed_as` relation per event. The base remains static and immutable; later sequence/JSON
mutation cannot change either snapshot. Invalid observation rejects as `semantic_index_invalid_observation` at
stage `execution_observation`. Query stays projection-only.

## Implemented generated and emitted boundary

Leaf `.10.7.6.3` wraps only a supplied generated semantic sink with `pcall`, raises one protected generated-
semantic carrier on callback failure, and passes the wrapped function as both the runtime sink and the private
`_generated_semantic_observation_sink` authorization marker. `runtime_parse` accepts generated observation only
when those exact function identities match. This replaces the earlier blanket generated fence without letting an
ordinary caller-provided flag authorize the path. After native cleanup, the generated wrapper unwraps its carrier
before broad `GeneratedSourceError` translation and restores the exact caller string, table, `nil`, or existing
runtime error. The diagnostic callback carrier is parallel and cannot be confused with semantic failures.

`execute_generated_parser_v2`, `execute_generated_parser_with_trace_v2`, fresh emitted `execute`, and fresh emitted
`execute_with_trace` all reuse the native accepted-slot/final-result seams and the same detached derivation. The
emitted wrappers already forwarded `options`, so their source bytes, generated-source v2/format 2 metadata, and
minimal `{label, family}` plan remain unchanged. No observation vocabulary, callback, or state is serialized.
No-sink event/scalar/hash fences and result/cursor/trace/diagnostic behavior remain unchanged.

## Dependency order

- `.10.7.6.1`: shared package-internal digest extraction, immutable typed event/sink API, and direct/loaded/
  reconstructed/traced-convenience capture at the native engine seam.
- `.10.7.6.2`: strict detached derivation, malformed/topology rejection, immutable base/derived isolation, and the
  twentieth exact response digest.
- `.10.7.6.3`: public generated helpers plus fresh emitted direct/traced and isolated PUC Lua/LuaJIT propagation,
  callback-value passthrough, failure omission, and result/cursor/trace/diagnostic non-interference with unchanged
  generated-source v2/format 2.
- `.10.7.6.4`: no-change composition/signoff and parent closure without Lua rollout or native-admission promotion.

## Exact neutral anchor and measured topology

The governed source is 73 bytes with SHA-256
`e224b813a4a3c79bef65b33c8ac5c1eaeb75e231da5ec3844233b4a8d796351a`. The three input bytes are `61 62 0a`
(`ab\n`) with identity
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`. Expected events select `Top[0]`
at scalar position 1, select `Top[1]` at position 2, and complete `Top` at position 2. Query case `runtime_events`
must retain response digest `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.

Read-only PUC Lua and LuaJIT probes confirm direct, loaded, normalized-AST reconstructed, generated-plan,
generated-plan traced, fresh emitted, and emitted-traced routes all return `['A','B']`. Result-bearing native
routes end at byte/scalar offset 2, and direct/traced, generated-traced, and emitted-traced execution each emits
exactly two existing slot marks. This is route/topology evidence only; it does not make trace text a semantic
authority. The unchanged gate passes seven semantic suites at 1,492 assertions per ABI, diagnostic callback proof
at 119 per ABI, package 177/177 per ABI, primary 66x2, corpus 105/105, and repository-volume storage. The neutral
oracle remains 6 groups / 20 responses / 89 rejected mutations at rollout 5/9 and native admission 4/6.
Complete behavior-free signoff also passes primary 5x2x66, Unicode 10/10, all six governance ledgers, canonical
six-doctrine CI with Rust admission 1/1 in 77.93 seconds, Dart 1/1, Julia 416/416 in 27.3 seconds, containment,
moved-root proof, reference primary 66x2, and Phase 0 1,031/1,031 in 624 seconds. The mdBook and Knowledge Map
730/5,838 pass; exact cleanup removes the 12,972-KiB rendered book and one proven-empty managed-run directory,
leaves no Lua adapter, and retains 246 reusable Rust cache artifacts.

The implemented `.10.7.6.1` boundary passes new native observation 121 plus existing semantic 1,493 = focused
1,614 assertions per ABI, complete Lua 177x2/PUC primary 66x2/corpus 105/storage 14, primary 5x2x66, Unicode
10/10, and all six unchanged ledgers. Canonical passes Rust admission 1/1 in 77.88 seconds, Dart 1/1, Julia
416/416 in 27.3 seconds, containment/moved-root proof, reference primary 66x2, and Phase 0 1,031/1,031 in 621
seconds. The mdBook and Knowledge Map 731/5,851 pass. Exact cleanup removes the 208-KiB leaf-owned adapter scratch,
13,000-KiB rendered book, and one proven-empty run directory; no Lua adapter remains and 246 reusable Rust cache
artifacts are retained.

The implemented `.10.7.6.2` boundary adds 269 derivation assertions and composes nine semantic owners at 1,884 per
ABI. The implemented `.10.7.6.3` boundary adds 80 generated-route assertions and composes ten semantic owners at
1,964 per ABI. Complete Lua passes package `1..177` per ABI, PUC primary 66x2, corpus 105/105, and the 15-owner
same-volume storage proof. Cross-backend closeout is recorded by the active task leaf rather than inferred here.

Full `.10.7.6.3` signoff passes primary 5x2x66, Unicode 10/10, all six ledgers, canonical Rust 1/1 in 82.65
seconds, Dart 1/1, Julia 416/416 in 29.5 seconds, containment/moved-root proof, reference primary 66x2, and Phase 0
1,031/1,031 in 667 seconds. mdBook and Knowledge Map 733/5,874 pass.

Related facts: [[lua-semantic-introspection-authority-map]], [[lua-semantic-query-authority-map]],
[[lua-semantic-query-public-api]], [[lua-runtime-matching-state]], [[lua-runtime-rule-interpreter]],
[[lua-runtime-trace-events]], [[lua-diagnostic-output-events]],
[[lua-semantic-runtime-observation-generated-routes]], [[lua-generated-source-emitter-core]],
[[lua-generated-source-fresh-process-isolation]], [[julia-semantic-runtime-observation-authority-map]],
[[dart-semantic-runtime-observation-authority-map]], [[perl-semantic-runtime-observation]],
[[rust-semantic-runtime-observation]], and [[semantic-introspection-neutral-contract]].
