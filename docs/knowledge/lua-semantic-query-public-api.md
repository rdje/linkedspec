---
id: lua-semantic-query-public-api
title: Lua exposes one immutable typed and raw-neutral static semantic query API
answers:
  - "how do I call the Lua semantic query API"
  - "what is the difference between Lua query and query_neutral"
  - "does Lua expose semantic query capabilities"
  - "how does Lua validate malformed semantic query requests"
  - "must Lua raw semantic queries use json harray array and null"
  - "why is a plain Lua table not a raw semantic query object"
  - "how does Lua validate semantic query integers on PUC Lua and LuaJIT"
  - "does Lua semantic query clone requests responses and projections"
  - "can Lua semantic query compile execute trace access paths or invoke callbacks"
  - "does Lua semantic query include runtime observations"
date: 2026-07-28
status: current complete public static/runtime API; generated observation and dual-ABI admission complete
tags: [lua, luajit, semantic-introspection, query, capabilities, public-api, validation, immutability]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.7.5.3; lua/src/linkedspec/init.lua; lua/src/linkedspec/semantic_index.lua; lua/src/linkedspec/semantic_query.lua; lua/test/semantic_index_query_kernel_test.lua; capability_conformance/semantic_introspection_contract.json
reverify: "bash tools/run_lua_local.sh; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; rg -n 'semantic_query_request|is_semantic_query_(request|response)|semantic_query_to_json|INDEX_METHODS.(capabilities|query|query_neutral)' lua/src/linkedspec lua/test"
---

# Lua Public Static Semantic Query API

Lua now exposes the complete non-runtime `linkedspec-semantic-query-v1` surface on both PUC Lua and LuaJIT. Root
`linkedspec` exports `semantic_query_request`, `is_semantic_query_request`, `is_semantic_query_response`, and
`semantic_query_to_json`. Each semantic index exposes `capabilities()`, typed `query(request)`, and raw-neutral
`query_neutral(value)`. There is deliberately no root `semantic_query`, `query_neutral`, or `capabilities` alias;
the index remains the snapshot authority.

`semantic_query_request(operation, options)` accepts ordinary Lua option and sequence tables because each table's
role is known, copies them immediately, and returns a protected request handle. `index:query(request)` accepts only
that typed handle. `index:query_neutral(value)` instead accepts an explicit neutral JSON-kind tree, validates it,
constructs the same protected typed request only after validation, and shares the same evaluator. Direct
`linkedspec.json.decode` output is admissible.

Raw-neutral identity is exact: request and nested objects are `json.harray`, sequences are `json.array`, and null
is `json.null`. A plain `{}` is ambiguous between object and array and is rejected as `request_not_object` rather
than guessed. The validator requires every exact field and container, canonical kind ordering, no duplicates,
valid operation/direction/source policy, portable pages and budgets, and valid operation-specific subjects. It
locks the contract's 26 malformed-request envelopes, including zero-cost invalid cursors and unknown or
non-explainable subjects, without invoking hostile metatables or callbacks.

Portable integral fields require Lua type `number`, finiteness, equality with `math.floor`, and the governed bound;
Booleans are rejected first and PUC-only `math.type` is never semantic authority. Numeric-looking cursor text uses
an explicit dual-ABI decimal/exponent plus non-finite-word grammar rather than host `tonumber`: decimal text is
rejected as a scalar-ambiguity boundary while `0x10` remains an ordinary textual cursor.

Both entry points materialize the retained private static projection exactly once and pass only detached
`snapshot`, `source_refs`, `records`, and `relations` data to one evaluator. Stored protocol state is recursively
immutable; collection properties and `semantic_query_to_json` return fresh detached JSON-kind trees. Caller input,
serialized output, repeated/interleaved requests, and nested projections cannot mutate an index or another
response.

The query module imports only `linkedspec.json`. It cannot access retained source/maps/outcomes, compiler or staged
sidecars, AST/ActionIR, compiled regexes, generated implementation, emitter, loader, executor, runtime observation,
trace/diagnostic sinks, paths, environment, time, randomness, callbacks, or host identity. Hostile callback and
metatable probes remain uninvoked. Event capture and observed-index derivation remain separate `.10.7.6` owners;
query sees only the resulting immutable projection.

The focused suite proves all 19 complete static response hashes through both typed and raw-neutral public paths,
all 26 governed malformed boundaries, portable numeric edge cases, exact public topology, recursive detachment,
one materialization, and authority denial at 571 assertions per ABI. The seven semantic suites compose at 1,492
assertions per ABI: source 380, outcome 122, graph 64, remaining static 122, call core 136, staged/generated 97,
and query 571. Complete Lua also passes package `1..177` per ABI, PUC primary 66x2, corpus 105/105, and the
repository-volume storage proof.

Leaf `.10.7.6.2` now derives a separate `has_execution=true` index from protected native events and one detached
static projection. The existing typed and raw-neutral query paths consume that projection without new execution
authority and match the exact twentieth `runtime_events` digest. The nine semantic suites now total 1,884
assertions per ABI; generated/emitted observation remains pending in `.10.7.6.3`.

No-change leaf `.10.7.5.4` reruns those seven committed suites from clean public commit `65cb13da` and closes the
immutable query parent without a replacement production/test/API owner. Complete dual-ABI Lua, primary 5x2x66,
Unicode 10/10, all six unchanged ledgers, canonical Rust 77.93s + Dart 1/1 + Julia 416/27.4s + containment/
moved-root + reference 66x2 + Phase 0 1,031/622s, mdBook, Knowledge Map, and exact cleanup pass. Runtime observation
remains solely `.10.7.6` work.

Related facts: [[lua-semantic-query-authority-map]], [[lua-semantic-query-kernel]],
[[lua-semantic-query-traversal]], [[lua-semantic-introspection-authority-map]],
[[lua-semantic-runtime-observation-derivation]],
[[semantic-introspection-neutral-contract]], [[perl-semantic-query-evaluator]],
[[rust-semantic-query-evaluator]], [[dart-semantic-query-public-api]], and
[[julia-semantic-query-public-api]].
