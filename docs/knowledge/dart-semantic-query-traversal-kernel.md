---
id: dart-semantic-query-traversal-kernel
title: Dart semantic query has exact directional traversal pages and logical budgets
answers:
  - "does Dart semantic query traverse relations now"
  - "how does Dart semantic query order breadth-first relations"
  - "how does Dart semantic query page records and relations"
  - "how does Dart semantic query apply record relation and depth budgets"
  - "how many successful static semantic query digests does Dart match"
  - "does Dart semantic query support both traversal directions"
  - "is Dart semantic relation query public yet"
date: 2026-07-22
status: current exact traversal/page/budget kernel exposed through the public typed/raw-neutral evaluator
tags: [dart, semantic-introspection, query, traversal, pagination, budgets, costs]
evidence: dart/lib/src/semantic/semantic_query.dart; dart/test/semantic_index_query_kernel_test.dart; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.4.2
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/semantic_index_query_kernel_test[.]dart test/semantic_index_source_foundation_test[.]dart test/semantic_index_compilation_foundation_test[.]dart test/semantic_index_static_graph_test[.]dart test/semantic_index_call_projection_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

# Dart Semantic Query Traversal Kernel

The package-private Dart evaluator now implements relation-kind-filtered outgoing, incoming, and both-direction
breadth-first traversal. Each layer scans the immutable projection's canonical relation order, deduplicates by
relation id, advances only to unvisited record ids, and returns the selected relations in canonical projection
order. One independent depth-one `both` proof locks simultaneous incoming/outgoing selection, exact cost, and the
deterministic depth-limit warning.

One shared primary-stream page function serves capabilities, list, get, relations, and explanation steps. A valid
`after_id` advances after that exact record/relation id; page limits set `next_after_id` without a budget warning.
Record and relation budgets return a deterministic prefix plus `semantic_query_budget_exceeded`; a remaining
frontier beyond `max_depth` reports the same portable warning with `max_depth`. Costs count only returned primary
records/relations, and depth is the maximum returned traversal layer.

All 16 successful non-runtime neutral responses match their full canonical SHA-256 digests through immutable typed
requests and responses. This includes reverse dispatch, staged payload/result edges, generated provenance,
after-id/page boundaries, record/relation budget prefixes, depth zero, privacy, and explanations. Public completion
`.10.5.4.3` now exposes this kernel through typed and raw-neutral paths while adding the remaining static errors and
all 26 structural validation boundaries; see [[dart-semantic-query-public-api]].

Related facts: [[dart-semantic-query-record-kernel]], [[dart-semantic-query-authority-map]],
[[semantic-introspection-neutral-contract]], [[rust-semantic-query-evaluator]].
