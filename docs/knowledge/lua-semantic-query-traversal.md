---
id: lua-semantic-query-traversal
title: Lua privately implements all static semantic query traversal pages budgets and costs
answers:
  - "does Lua implement semantic relation traversal"
  - "how does Lua semantic query traverse outgoing incoming and both directions"
  - "how does Lua semantic query deduplicate breadth first traversal"
  - "how does Lua semantic query page records relations and explanation steps"
  - "what does a Lua semantic query after_id cursor address"
  - "how do Lua semantic query record relation and depth budgets interact"
  - "how are Lua semantic query deterministic incomplete prefixes selected"
  - "how does Lua semantic query calculate logical costs"
  - "which nineteen Lua semantic query response hashes are exact"
  - "is Lua semantic query traversal public"
  - "where is Lua semantic query traversal tested"
  - "does Lua semantic query traversal behave identically on PUC Lua and LuaJIT"
date: 2026-07-28
status: current complete private static evaluator; raw-neutral validation and public entrypoints pending
tags: [lua, luajit, semantic-introspection, query, traversal, pagination, budgets, costs, no-execution]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.7.5.2; lua/src/linkedspec/semantic_query.lua; lua/src/linkedspec/semantic_index.lua; lua/test/semantic_index_query_kernel_test.lua; tools/run_lua_local.sh; capability_conformance/semantic_introspection_contract.json
reverify: "bash tools/run_lua_local.sh; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; rg -n 'page_stream|traverse_relations|relation_layer|semantic_query_budget_exceeded|owned static query count' lua/src/linkedspec/semantic_query.lua lua/test/semantic_index_query_kernel_test.lua"
---

# Lua Private Semantic Query Traversal

Leaf `.10.7.5.2` completes Lua's package-private static semantic-query evaluator without exporting a partial API.
The same evaluator now matches all 19 non-runtime canonical response hashes on PUC Lua and LuaJIT. The ten
completion cases cover reverse graph dispatch, staged and generated provenance, after-id and boundary pages,
record/relation/depth limits, unsupported contracts, and invalid operation combinations. Raw JSON-like validation,
all 26 malformed neutral boundaries, and root/index public entry points remain together in `.10.7.5.3`; the
twentieth runtime response remains `.10.7.6`.

`page_stream` operates only on an operation's already-filtered primary stream. An `after_id` must identify an item
in that stream and resumes immediately after it. Selection uses the minimum of the remaining stream, requested page
limit, and applicable logical budget. Page-only boundaries return a cursor without a diagnostic; budget boundaries
return the same deterministic prefix, force `complete=false`, and emit `semantic_query_budget_exceeded`. Explain
reserves one record unit for its decision and pages only its owned explanation steps; only relations to returned
steps are projected.

`traverse_relations` performs relation-kind-filtered breadth-first traversal over the canonical detached relation
stream in outgoing, incoming, or both directions. Each layer deduplicates already-selected relation ids, removes
visited record ids from the next frontier, records the first logical depth of every selected relation, and restores
canonical projection order for the result. A remaining matching layer beyond `max_depth` yields a depth-limited
prefix. A simultaneous relation ceiling takes diagnostic precedence over the depth ceiling.

Costs are logical response-model counts, never wall time, allocation, compiler work, I/O, or another host counter.
Capabilities/list/get report returned records; relations report returned relations plus the deepest returned BFS
layer; explain reports its decision, returned steps and `explained_by` relations, with depth one only when a step is
present. Rejected requests report zero cost. Evaluation still consumes exactly one fresh detached static projection
and cannot reach retained source/compiler/staged/AST/IR/generated/runtime/trace/path/host authority.

The expanded focused suite passes 283 assertions on each ABI. The seven semantic suites compose at 1,204 per ABI:
source 380, outcome 122, graph 64, remaining static 122, call core 136, staged/generated 97, and query 283. It locks
all 19 full hashes plus two-layer traversal, all five paging users, budget precedence, typed portable errors,
decision reservation, recursive detachment, public omission, one materialization, and forbidden authority. The
complete Lua gate remains package `1..177` per ABI with PUC primary 66x2, corpus 105/105, and repository-volume
storage proof.

Full signoff passes primary 5x2x66, Unicode 10/10, all six unchanged governance ledgers, and canonical CI through
Rust admission 1/1 in 78.18 seconds, Dart 1/1, Julia 416/416 in 27.3 seconds, elevated six-family containment,
moved-root execution, reference primary 66x2, and Phase 0 1,031/1,031 in 622 seconds. The mdBook and Knowledge Map
728/5,814 pass. Exact slice-owned adapters, rendered book, and the empty managed-run directory are removed while
active Rust incremental caches remain available.

Related facts: [[lua-semantic-query-authority-map]], [[lua-semantic-query-kernel]],
[[lua-semantic-introspection-authority-map]], [[semantic-introspection-neutral-contract]],
[[julia-semantic-query-traversal]], and [[semantic-source-ceiling-boundary]].
