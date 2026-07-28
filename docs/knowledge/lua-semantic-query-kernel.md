---
id: lua-semantic-query-kernel
title: Lua privately implements exact immutable capabilities list get and explain queries
answers:
  - "does Lua implement semantic query capabilities list get and explain"
  - "which Lua semantic query operations are implemented privately"
  - "which nine Lua semantic query response hashes are exact"
  - "is the Lua semantic query API public"
  - "how are Lua semantic query values immutable"
  - "does Lua semantic query retain caller tables"
  - "how does Lua semantic query obtain the static projection"
  - "does Lua semantic query access source compiler runtime trace or paths"
  - "which Lua semantic query features remain after the non-traversal kernel"
  - "where is the Lua private semantic query kernel tested"
  - "does the Lua semantic query kernel behave identically on PUC Lua and LuaJIT"
date: 2026-07-28
status: current private non-traversal foundation; traversal limits and public entrypoints pending
tags: [lua, luajit, semantic-introspection, query, capabilities, privacy, immutability, no-execution]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.7.5.1; lua/src/linkedspec/semantic_query.lua; lua/src/linkedspec/semantic_index.lua; lua/test/semantic_index_query_kernel_test.lua; tools/run_lua_local.sh; capability_conformance/semantic_introspection_contract.json
reverify: "bash tools/run_lua_local.sh; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; rg -n '_semantic_query_kernel|materialize_static_projection|SemanticQuery(Request|Response)|semantic_index_query_kernel_test' lua/src/linkedspec lua/test tools/run_lua_local.sh"
---

# Lua Private Semantic Query Kernel

Leaf `.10.7.5.1` implements Lua's immutable semantic-query vocabulary and its first projection-only evaluator in
`lua/src/linkedspec/semantic_query.lua`. The module is package-private. Root `linkedspec` exports no query
constructor, guard, serializer, `capabilities`, `query`, or `query_neutral`; semantic-index instances expose none
of those methods yet. This prevents the non-traversal subset from becoming a partial compatibility surface.

The kernel matches nine complete neutral response digests on both PUC Lua and LuaJIT: `capabilities`,
`graph_list_rules`, `graph_duplicate_regex_text`, `graph_explain_entry`, `calls_symbols_and_shapes`,
`failed_diagnostic`, `privacy_none`, `privacy_text_and_digest`, and `source_ceiling_forbidden`. It preserves
canonical record order, default page and logical cost envelopes, decision-before-explanation-step order, only the
relevant `explained_by` relations, structural redaction below text detail, text-only requested digest disclosure,
and exact source-ceiling rejection.

Requests, responses, snapshots, records, relations, source references, diagnostics, pages, budgets, source
policies, page states, and costs are protected empty handles backed by weak-key private state. Stored JSON objects,
arrays, and nulls are recursively copied into unexposed frozen nodes. Ordinary typed option/list tables are copied
by known role. Collection properties return fresh JSON-kind containers, retaining only immutable child protocol
handles; `to_json` recursively returns an entirely fresh `json.harray` / `json.array` / `json.null` tree. Caller
input mutation, property-result mutation, nested JSON mutation, repeated queries, and interleaved queries cannot
alter retained requests, responses, or indexes.

`semantic_index` owns the only authority seam. `_semantic_query_kernel(index, request)` calls
`materialize_static_projection(index_state(index))` once, then passes that one detached
`snapshot`/`source_refs`/`records`/`relations` tree to `semantic_query.evaluate`. The evaluator imports only
`linkedspec.json`. It cannot reach retained source text/maps/outcomes, parser/compiler/staged sidecars,
AST/ActionIR, compiled regexes, generated implementation, emitter/loader/executor, runtime observation, trace or
diagnostic sinks, paths, environment, time, randomness, callbacks, or host identity; it cannot parse, compile,
execute, observe, or enable trace.

At this boundary, typed requests may represent all five operations and complete page/budget/source vocabulary,
but the kernel explicitly defers relations, cursors, non-default page sizes, non-default budgets, portable typed
errors, deterministic prefixes, and the other ten static hashes to `.10.7.5.2`. Ambiguous/raw JSON-like validation,
all 26 malformed boundaries, and the complete public typed/raw-neutral API remain `.10.7.5.3`. Runtime events
remain `.10.7.6`.

The focused suite passes 159 assertions unchanged on both ABIs. The seven semantic suites compose at 1,080 per
ABI: source 380, outcome 122, graph 64, remaining static 122, call core 136, staged/generated 97, and query 159.
The complete Lua gate passes package `1..177` per ABI, PUC primary 66x2, corpus 105/105, and repository-volume
storage proof.

Related facts: [[lua-semantic-query-authority-map]], [[lua-semantic-introspection-authority-map]],
[[lua-semantic-staged-generated-projection]], [[semantic-introspection-neutral-contract]],
[[semantic-source-ceiling-boundary]], and [[julia-semantic-query-kernel]].
