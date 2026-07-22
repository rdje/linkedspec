---
id: dart-semantic-query-record-kernel
title: Dart has an exact immutable package-private semantic record and source query kernel
answers:
  - "does Dart have typed semantic query values"
  - "which Dart semantic query operations are implemented internally"
  - "how many semantic query response digests does Dart match now"
  - "is the Dart semantic query public yet"
  - "how does Dart semantic query enforce source privacy"
  - "can a caller mutate a Dart semantic query response"
  - "does the Dart semantic query kernel access compiler state"
date: 2026-07-22
status: current exact package-private record/source kernel; traversal and public query remain pending
tags: [dart, semantic-introspection, query, capabilities, privacy, redaction, immutability]
evidence: dart/lib/src/semantic/semantic_query.dart; dart/lib/src/semantic/semantic_index.dart; dart/test/semantic_index_query_kernel_test.dart; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.4.1
reverify: "cd dart && dart test test/semantic_index_query_kernel_test.dart test/semantic_index_source_foundation_test.dart test/semantic_index_compilation_foundation_test.dart test/semantic_index_static_graph_test.dart test/semantic_index_call_projection_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

# Dart Semantic Query Record Kernel

`semantic_query.dart` defines immutable typed operations, direction, page, budget, source policy, request, source
reference, record, relation, diagnostic, page state, cost, and response values. Lists, maps, facts, diagnostics, and
responses are owned and unmodifiable; every `toJson()` call returns a fresh detached plain-data value.

The package-internal `SemanticIndexQueryKernelTestAccess` extension is the only current entry. It passes
`_staticProjection.detachedJson()` to the evaluator, so the kernel cannot receive accepted source text/bytes,
source mapper, parser/compiler objects, staged sidecars, AST/ActionIR, compiled regexes, generated implementation,
executor, trace, path, or host state.

The kernel implements capabilities, list, get, and explain. It projects source at `none`, `identity`, `span`, and
`text`, exposes a digest only when requested with text, nulls source-sensitive regex/diagnostic/explanation facts
below text with exact redaction paths, and rejects detail above the immutable construction ceiling. Nine full
canonical response digests match: capabilities, graph rules, duplicate regex text, entry explanation, call symbols
and shapes, failed diagnostic, privacy none, privacy text plus digest, and source-ceiling rejection.

Relation traversal, paging, and logical budgets are deliberately fenced to `.10.5.4.2`. Raw-neutral structural
validation and all public `SemanticIndex` query methods/exports remain absent until `.10.5.4.3`. Runtime records
remain absent until `.10.5.5`, and Dart admission remains `.10.5.6`.

Related facts: [[dart-semantic-query-authority-map]], [[dart-semantic-introspection-authority-map]],
[[semantic-introspection-neutral-contract]], [[rust-semantic-query-evaluator]].
