---
id: dart-semantic-query-record-kernel
title: Dart has an exact immutable semantic record and source query kernel
answers:
  - "does Dart have typed semantic query values"
  - "which Dart semantic query operations are implemented internally"
  - "how many semantic query response digests does Dart match now"
  - "is the Dart semantic query public yet"
  - "how does Dart semantic query enforce source privacy"
  - "can a caller mutate a Dart semantic query response"
  - "does the Dart semantic query kernel access compiler state"
date: 2026-07-22
status: current exact record/source kernel exposed through the public typed/raw-neutral evaluator
tags: [dart, semantic-introspection, query, capabilities, privacy, redaction, immutability]
evidence: dart/lib/src/semantic/semantic_query.dart; dart/lib/src/semantic/semantic_index.dart; dart/test/semantic_index_query_kernel_test.dart; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.4.1
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/semantic_index_query_kernel_test[.]dart test/semantic_index_source_foundation_test[.]dart test/semantic_index_compilation_foundation_test[.]dart test/semantic_index_static_graph_test[.]dart test/semantic_index_call_projection_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

# Dart Semantic Query Record Kernel

`semantic_query.dart` defines immutable typed operations, direction, page, budget, source policy, request, source
reference, record, relation, diagnostic, page state, cost, and response values. Lists, maps, facts, diagnostics, and
responses are owned and unmodifiable; every `toJson()` call returns a fresh detached plain-data value.

Public `SemanticIndex.query` and `queryNeutral` now pass `_staticProjection.detachedJson()` to one evaluator, so the
kernel cannot receive accepted source text/bytes, source mapper, parser/compiler objects, staged sidecars,
AST/ActionIR, compiled regexes, generated implementation, executor, trace, path, or host state.

The kernel implements capabilities, list, get, and explain. It projects source at `none`, `identity`, `span`, and
`text`, exposes a digest only when requested with text, nulls source-sensitive regex/diagnostic/explanation facts
below text with exact redaction paths, and rejects detail above the immutable construction ceiling. Nine full
canonical response digests match: capabilities, graph rules, duplicate regex text, entry explanation, call symbols
and shapes, failed diagnostic, privacy none, privacy text plus digest, and source-ceiling rejection.

Relation traversal, paging, and logical budgets were added by `.10.5.4.2`; raw-neutral structural validation and
the public `SemanticIndex` query methods/exports were completed by `.10.5.4.3`. Runtime records remain absent until
`.10.5.5`, and Dart admission remains `.10.5.6`.

Related facts: [[dart-semantic-query-authority-map]], [[dart-semantic-query-public-api]],
[[dart-semantic-introspection-authority-map]], [[semantic-introspection-neutral-contract]],
[[rust-semantic-query-evaluator]].
