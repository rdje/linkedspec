---
id: lua-semantic-query-authority-map
title: Lua semantic query must consume one fresh detached dual-ABI projection
answers:
  - "what authority may the Lua semantic query evaluator consume"
  - "how many static semantic query hashes must Lua match"
  - "how many malformed raw neutral query boundaries must Lua validate"
  - "what is the Lua semantic query public vocabulary"
  - "how is the Lua semantic query implementation split"
  - "how must Lua distinguish semantic JSON objects arrays and null"
  - "how must Lua validate semantic query integers on PUC Lua and LuaJIT"
  - "may Lua semantic query use math.type"
  - "may Lua semantic query access source compiler paths execution or trace"
  - "when may Lua expose capabilities query and query_neutral"
  - "does Lua semantic query include runtime events"
date: 2026-07-28
status: current authority plan; complete public static evaluator implemented
tags: [lua, luajit, semantic-introspection, query, capabilities, privacy, pagination, budgets, immutability]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.7.5.0; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; capability_conformance/semantic_introspection_contract.json; capability_conformance/semantic_introspection_model.json; lua/src/linkedspec/semantic_index.lua; lua/src/linkedspec/semantic_static_projection.lua; lua/src/linkedspec/json.lua; docs/knowledge/perl-semantic-query-evaluator.md; docs/knowledge/rust-semantic-query-evaluator.md; docs/knowledge/dart-semantic-query-authority-map.md; docs/knowledge/julia-semantic-query-authority-map.md
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; bash tools/run_lua_local.sh; rg -n 'semantic_(query|capabilities)|query_neutral|materialize' lua/src/linkedspec lua/test"
---

# Lua Semantic Query Authority Map

Lua's closed frozen private projection is the complete and only permitted authority for static query evaluation.
Every request receives exactly one fresh detached JSON-kind materialization containing only `snapshot`,
`source_refs`, `records`, and `relations`. The evaluator may not receive retained source or source map above that
authorized clone, parsed/compiled state, function/staged sidecars, AST/ActionIR, compiled regexes, generated
implementation, plan builder, emitter, loader, executor, runtime observation, trace or diagnostic sink, path,
environment, clock, randomness, callback, or another host object. Querying never parses, compiles, executes,
observes, enables trace, or mutates the index or request.

Direct PUC Lua and LuaJIT probes confirm the exact private inputs:

| Snapshot | Records | Relations | Source refs | Digest available |
| --- | ---: | ---: | ---: | --- |
| graph / text | 12 | 14 | 7 | yes |
| calls / text | 22 | 25 | 10 | yes |
| failed / span | 6 | 4 | 2 | no |
| privacy / text | 4 | 3 | 2 | yes |
| privacy / identity | 4 | 3 | 2 | no |

All source refs retain exact private span, excerpt, and digest authority even at the identity construction ceiling;
the immutable snapshot records what may leave. Query-time source projection applies `none`/`identity`/`span`/`text`,
redacts source-sensitive facts structurally, exposes a digest only with text, and rejects elevation without silent
downgrade. Mutating a returned nested materialization cannot affect the next one.

The neutral contract owns 20 response hashes. `runtime_events` alone requires later caller-owned execution
authority in `.10.7.6`; Lua query leaves `.10.7.5.1-.3` must match these 19 complete static hashes through the typed
and raw-neutral paths:

| Case | SHA-256 |
| --- | --- |
| `capabilities` | `a5f759dc8a5d060a36f86d35d5a86ff8b6745ef87cbe03d2c8b5a3200ddfd141` |
| `graph_list_rules` | `b8872b7340d2d6f4aaa409745fe0083bc744a594e09a05ed5b9786446594df0b` |
| `graph_duplicate_regex_text` | `b64f16400c700eaa455f9304b1a0084d283fad9e65efc3f1c41c09b8dbca7a4a` |
| `graph_reverse_dispatch` | `efc996d0a5f790375d96faac8018e8cfdf7a543948950047fb54c8c8635f7975` |
| `graph_explain_entry` | `86d93288b05ab0d17e297e1e84973820b377f14ba0346ec59cf58439940ff8ad` |
| `calls_symbols_and_shapes` | `b3e3e0d047313ef9e42340914014f72c184f0fc4c68e3b37d51960a858208c17` |
| `staged_chain` | `862d6f30fbfa54bb914ea44dd3d76f7bcb63037ba67aff77c80313e9b6bfd9b0` |
| `generated_provenance` | `aaba2d3db87e239e45aa28ac6af241107ec483df8aa34b64bbafce1e138d2622` |
| `failed_diagnostic` | `b2afd23b60f37170e1b945dceed7851870f8217e06b02911d52b26c7c92abd9c` |
| `privacy_none` | `906711bc69d32917d0564c3298c5e42399b69a27e4676cd44e4e7f7ddfc7e779` |
| `privacy_text_and_digest` | `651908fac11a8140e90cc2fe59a096a1c0445288cf6bb627678f7710f4cdb0fd` |
| `pagination_after_id` | `f705e7fac4671fc2f3cc0710095c0daa778e4b200e249d366c93070ea3e27a31` |
| `page_boundary` | `cf350f73d0ec10b634ee8b7018ad073f07a65fd47c211b6f0c760958770d6bac` |
| `budget_prefix` | `d41ec0a15fef465ba0dd62981f48d687f5538ba62b0aa7b921f94e1acc574961` |
| `relation_budget_prefix` | `32d109f9c4549c72b451f3b2ee60cbc962f58c1c060d546174d0d88c8f2677f5` |
| `relation_depth_zero` | `cacc627cefcfc9a84cc22f7ed951776b448516072df7a83dfe25827bacac46d7` |
| `source_ceiling_forbidden` | `12eddbc76f4377a706e807cb344cbec49f3bb0f51792e9861821a61a8e5f8f50` |
| `unsupported_contract` | `e6d797f339bc66a4cbef83d8b82e6deb95bf57f5569150405189a5a3b9aafc6a` |
| `invalid_operation_combination` | `3010ac5f9a7a2679d4c6e17b2408cda2c3a6d9c0e6a83f9b47ce1973d7ad7aee` |

The raw-neutral validator locks exactly 26 labels: `request_not_object`, `unsupported_contract`, `request_fields`,
`page_fields`, `budget_fields`, `source_fields`, `operation`, `subjects_type`, `subjects_duplicate`, `record_kind`,
`relation_kind`, `record_kind_order`, `relation_kind_order`, `direction`, `after_id`, `page_limit`, `max_records`,
`max_relations`, `max_depth`, `source_policy`, `numeric_boolean`, `digest_requires_text`,
`operation_combination`, `unknown_subject`, `after_id_not_in_primary_stream`, and `not_explainable`.

Lua JSON identity is explicit. `json.harray`, `json.array`, and `json.null` distinguish objects, arrays, and null,
including empty containers; canonical decoding and encoding agree on both ABIs. A plain table is ambiguous and is
not raw-neutral input. The raw entry accepts explicit JSON-kind values, including direct `json.decode` output, and
must reject host metatables, cycles, functions, threads, and userdata without invoking them. Typed construction may
accept copied ordinary option/list tables because the constructor supplies their role.

PUC Lua distinguishes integer and float with `math.type`; LuaJIT does not. Query integers must therefore be
validated portably as type `number`, finite, equal to `math.floor(value)`, and within the exact neutral range.
Booleans have type `boolean` on both ABIs and are rejected before numeric checks. `math.type`, integer width, host
resource counters, and floating display cannot become semantic authority. Canonical JSON emits bounded integral
values identically on both runtimes.

The exact public surface is now implemented and remains idiomatic and small:

- `linkedspec.semantic_query_request(operation[, options])` creates one protected typed request;
- `linkedspec.is_semantic_query_request`, `linkedspec.is_semantic_query_response`, and
  `linkedspec.semantic_query_to_json` inspect or project protected values;
- `index:capabilities()` evaluates the canonical capabilities request;
- `index:query(request)` accepts only the typed request; and
- `index:query_neutral(value)` validates explicit raw JSON-like input.

Both query paths enter one evaluator over one materialization and return a protected `SemanticQueryResponse`.
Stored object/array/null values are recursively frozen behind weak-key state. Collection properties and every
`to_json` call return fresh detached JSON-kind trees. Lowercase contract operations, directions, source levels,
record/relation kinds, field names, envelopes, diagnostic codes, and ordering remain the neutral vocabulary; Lua
adds no backend field or enum. Typed requests can represent unsupported contracts and invalid operation
combinations so those portable responses match, while malformed container/rank boundaries remain raw-only.

The evaluator applies canonical primary-stream pages, filtered outgoing/incoming/both breadth-first relation
traversal, relation-id then frontier-record-id deduplication, canonical result order, logical record/relation/depth
budgets and costs, deterministic incomplete prefixes, and decision-first explanations containing only
`explained_by`. Its four portable diagnostics remain `semantic_query_budget_exceeded`, `semantic_query_invalid`,
`semantic_query_source_detail_forbidden`, and `semantic_query_contract_unsupported`.

Implementation order remains omission-safe:

1. `.10.7.5.1` adds private protected protocol values plus capabilities/list/get/explain and exact source policy
   for nine static hashes. No root or index query name exists yet.
2. `.10.7.5.2` adds relations, pages, budgets, costs, prefixes, and the remaining ten static hashes while private;
   it is complete at all 19 static hashes on both ABIs.
3. `.10.7.5.3` now exposes the complete constructor/guards/projection and three index methods together, matching
   all 19 typed/raw hashes and 26 raw boundaries with clone/privacy/non-execution/host denial.
4. `.10.7.5.4` recomposes committed proof without a replacement owner and closes the immutable query parent.

Related facts: [[semantic-introspection-neutral-contract]], [[semantic-source-ceiling-boundary]],
[[lua-semantic-introspection-authority-map]], [[lua-semantic-call-staged-projection-plan]],
[[lua-semantic-query-kernel]], [[lua-semantic-query-traversal]], [[lua-semantic-query-public-api]],
[[perl-semantic-query-evaluator]], [[rust-semantic-query-evaluator]],
[[dart-semantic-query-authority-map]], and [[julia-semantic-query-authority-map]].
