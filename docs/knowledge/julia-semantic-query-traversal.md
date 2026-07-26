---
id: julia-semantic-query-traversal
title: Julia privately implements exact semantic relation traversal pages budgets and costs
answers:
  - "does Julia implement semantic relation traversal"
  - "how does Julia semantic query traverse outgoing incoming and both directions"
  - "how does Julia semantic query deduplicate breadth first traversal"
  - "how does Julia semantic query page records relations and explanation steps"
  - "what does a Julia semantic query after_id cursor address"
  - "how do Julia semantic query record relation and depth budgets interact"
  - "how are Julia semantic query deterministic incomplete prefixes selected"
  - "how does Julia semantic query calculate logical costs"
  - "which nineteen Julia semantic query response hashes are exact"
  - "is Julia semantic query traversal public"
  - "where is Julia semantic query traversal tested"
date: 2026-07-23
status: current traversal kernel beneath the complete public static evaluator
tags: [julia, semantic-introspection, query, traversal, pagination, budgets, costs, no-execution]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.5.2; julia/src/semantic/SemanticQuery.jl; julia/src/semantic/SemanticStaticProjection.jl; julia/src/LinkedSpecJulia.jl; julia/test/semantic_index_query_kernel_test.jl; julia/test/semantic_index_query_traversal_test.jl; julia/test/runtests.jl; perl/LinkedSpec/SemanticQuery.pm; capability_conformance/semantic_introspection_contract.json
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test, JSON3; const REPO_ROOT=pwd(); include(\"julia/test/semantic_index_source_foundation_test.jl\"); include(\"julia/test/semantic_index_compilation_foundation_test.jl\"); include(\"julia/test/semantic_index_static_graph_test.jl\"); include(\"julia/test/semantic_index_static_remaining_test.jl\"); include(\"julia/test/semantic_index_call_core_test.jl\"); include(\"julia/test/semantic_index_call_staged_test.jl\"); include(\"julia/test/semantic_index_query_kernel_test.jl\"); include(\"julia/test/semantic_index_query_traversal_test.jl\")'; python3 tools/check_semantic_introspection_contract.py; rg -n '_semantic_query_page_stream|_semantic_query_traverse_relations|_semantic_query_relation_layer|_semantic_query_kernel' julia/src/semantic/SemanticQuery.jl julia/test/semantic_index_query_traversal_test.jl"
---

# Julia Private Semantic Query Traversal

Leaf `.10.6.5.2` completes Julia's private static semantic-query evaluator without exporting a partial API. The
same `_semantic_query_kernel` now matches all 19 non-runtime canonical response hashes. The ten completion cases
cover reverse graph dispatch, staged and generated provenance, after-id and boundary pages, record/relation/depth
limits, unsupported contracts, and invalid operation combinations. Raw malformed-request validation and public
typed/raw-neutral entry points remain together in `.10.6.5.3`; the twentieth runtime response remains
`.10.6.6`.

`_semantic_query_page_stream` operates on the already-filtered primary stream. An `after_id` must name an item in
that stream and resumes immediately after it. The selected length is the smaller of the requested page limit and
the operation's applicable logical budget. A page-only boundary returns a cursor without a diagnostic; a budget
boundary returns the same deterministic prefix, forces `complete=false`, and emits
`semantic_query_budget_exceeded`. Explain reserves one record unit for its decision and pages only the owned
explanation steps; only relations to returned steps are projected.

`_semantic_query_traverse_relations` performs filter-constrained breadth-first traversal over the canonical
detached relation stream. It supports outgoing, incoming, and both directions, deduplicates relation ids across
layers, removes already-visited record ids from each next frontier, records the first logical depth of each selected
relation, and finally restores canonical source order. A remaining matching layer beyond `max_depth` produces the
depth-limited prefix. `max_relations` takes diagnostic precedence when both a relation ceiling and depth ceiling
constrain a request.

Costs are logical model costs, never wall time, allocations, database reads, compiler work, or another host
counter. List/get/capabilities report returned records; relations report returned relations plus the deepest
returned BFS layer; explain reports its decision, returned steps, derived `explained_by` relations, and depth one
only when a step is present. Rejected requests report zero cost. Evaluation still consumes exactly one fresh
detached static-projection materialization and cannot reach retained source/compiler/staged/AST/IR/generated/
runtime/trace/path/host authority.

The completion suite adds 118 assertions, while the earlier 100-assertion kernel suite remains unchanged in size.
All eight semantic suites compose at 748 assertions and the complete Julia package reaches 8,290 assertions plus
primary process conformance and corpus 105/105. The traversal responses remain recursively immutable, every JSON
conversion is fresh, and `SemanticQuery`, `semantic_capabilities`, `semantic_query`, and
`semantic_query_neutral` were exported together by `.10.6.5.3` after this private traversal boundary was complete.

The full primary matrix passes all five backends in both environments across 66 cases, and all ten Unicode
manifest legs pass. Governance remains exact at Unicode 806/9/8/2, semantic 6 groups / 20 queries / 81 mutations
with rollout 4/9 and admission 3/6, capability 80/0/0, generated v1/10/80-0-0, and public 59/27/0. The canonical
local gate passes all four doctrines, Rust semantic admission 1/1 in 82.53 seconds, Dart 1/1, reference-primary
66 cases in both environments, and Phase 0 at 1,031/1,031 in 647 seconds. The mdBook builds, the Knowledge Map
composes 689 facts and 5,298 question keys, and the final safe-artifact audit removed 1,613,224 KiB while preserving
all Julia package/registry caches and the 517 Pgen evidence artifacts.

Related facts: [[julia-semantic-query-kernel]], [[julia-semantic-query-authority-map]],
[[julia-semantic-query-public-api]], [[julia-semantic-static-projection-plan]],
[[semantic-introspection-neutral-contract]].
