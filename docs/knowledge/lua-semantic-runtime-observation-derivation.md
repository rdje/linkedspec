---
id: lua-semantic-runtime-observation-derivation
title: Lua derives immutable observed semantic snapshots only from protected events and detached static topology
answers:
  - "how do I derive a Lua observed semantic index"
  - "what does Lua index with_execution_observation do"
  - "how does Lua validate runtime semantic observation events"
  - "does Lua with_execution_observation execute or compile"
  - "does Lua with_execution_observation hash the input"
  - "how does Lua validate selecting rule and regex slot topology"
  - "where do Lua observed event source and value shape come from"
  - "does Lua observed-index derivation mutate the base index"
  - "what records and relations does Lua observed-index derivation add"
  - "what is the Lua runtime_events response digest"
  - "can Lua query an observed runtime snapshot"
  - "does Lua observed-index derivation work on PUC Lua and LuaJIT"
date: 2026-07-28
status: current immutable native observed-index derivation; generated and emitted propagation remain pending
tags: [lua, luajit, semantic-introspection, runtime, observation, query, immutability, topology]
evidence: lua/src/linkedspec/semantic_index.lua; lua/src/linkedspec/semantic_runtime_projection.lua; lua/src/linkedspec/semantic_static_projection.lua; lua/test/semantic_index_runtime_projection_test.lua; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.7.6.2
last_verified: 2026-07-28
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_projection_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_projection_test.lua"
  - "rg -n 'with_execution_observation|observed_as|semantic_index_invalid_observation' lua/src/linkedspec/semantic_index.lua lua/src/linkedspec/semantic_runtime_projection.lua lua/test/semantic_index_runtime_projection_test.lua"
---

# Lua immutable observed runtime projection

`index:with_execution_observation(events)` accepts a compiled static opaque Lua semantic index and a dense
sequence of exact protected `RuntimeSemanticObservationEvent` handles. It returns a new protected index and never
mutates the base. The same implementation and projection bytes run on PUC Lua and LuaJIT.

The boundary rejects ambiguous/host-metatable/sparse sequences and non-event values. It validates observation
contract v1, exact slot/result kinds and nullable fields, nonempty valid-UTF-8 labels, finite nonnegative integral
positions and slot indices, exactly one successful final result last, the selected entry rule, and an exact
lowercase `input:sha256:` identity with 64 hex digits. Each slot must map from its executing static rule through
one owned edge and `selects_regex` relation to the named target rule and authored zero-based slot. Failed or
already-observed bases plus foreign, reordered, duplicate-final, wrong-entry, missing-slot, and unrelated-edge
sequences reject as protected `semantic_index_invalid_observation` errors at stage `execution_observation`.

Authority is exactly one fresh detached materialization of the immutable static projection plus detached JSON
from each protected event. Slot source comes from the selected regex-slot record and slot value shape comes from
the selecting edge. Final source and result shape come from the selected static entry rule. The derivation module
does not parse, validate, or compile source; execute a target; enable trace or diagnostics; install a sink; hash
input; read a path or environment; inspect a host result; or receive retained source/compiler/staged/generated/
runtime authorities.

The derived projection sets `snapshot.has_execution=true`, adds canonical `execution:0`, ordered
`event:execution:0:N` records, and one `observed_as` relation per event. Relation evidence points to the selected
regex slot for slot events and to the entry rule for the final event. The shared static-projection owner performs
canonical ordering and recursive freezing. Event-sequence, detached-event JSON, response, and private-materialized
projection mutations cannot alter either the base or derived index; repeated and interleaved derivations remain
identical.

Canonical `runtime.spec` over `ab\n` produces two slot events at scalar positions one and two plus final `Top`
success at position two. Typed `query` and raw-neutral `query_neutral` both retain exact `runtime_events` digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`. Focused derivation proof passes 269
assertions per ABI; all nine Lua semantic suites compose at 1,884 assertions per ABI. Generated-plan and emitted
observation propagation remain exclusively owned by `.10.7.6.3`; generated-source v2/format 2, rollout 5/9,
native admission 4/6, and all governance ledgers remain unchanged.

Complete proof passes Lua package `1..177` on both ABIs, PUC primary 66x2, corpus 105/105, storage 14, primary
5x2x66, Unicode 10/10, all six ledgers, canonical CI through Phase 0 1,031/1,031 in 654 seconds, mdBook, and
Knowledge Map 732 facts / 5,863 question keys.

Related facts: [[lua-semantic-runtime-observation-authority-map]],
[[lua-semantic-runtime-observation-direct-capture]], [[lua-semantic-query-public-api]],
[[semantic-introspection-neutral-contract]], [[julia-semantic-runtime-observation-derivation]], and
[[rust-semantic-runtime-observation]].
