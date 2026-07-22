---
id: dart-semantic-query-authority-map
title: Dart semantic query must consume only a fresh detached normalized projection
answers:
  - "what authority may the Dart semantic query evaluator consume"
  - "how many static semantic query digests must Dart match"
  - "how many raw neutral semantic query boundaries must Dart validate"
  - "how is the Dart semantic query implementation split"
  - "may Dart semantic query access source text or compiler objects"
  - "may Dart semantic query execute or enable trace"
  - "when may Dart expose its public semantic query API"
  - "does Dart semantic query include runtime events"
date: 2026-07-22
status: current authority and dependency split; typed record/source plus traversal/limit kernels implemented
tags: [dart, semantic-introspection, query, capabilities, privacy, pagination, budgets, immutability]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.4.0; capability_conformance/semantic_introspection_contract.json; dart/lib/src/semantic/semantic_index.dart; dart/lib/src/semantic/semantic_static_projection.dart; dart/lib/src/semantic/semantic_call_projection.dart; perl/LinkedSpec/SemanticQuery.pm; rust/linkedspec-runtime/src/semantic_index/query.rs; rust/linkedspec-runtime/tests/semantic_index_query.rs
reverify: "python3 tools/check_semantic_introspection_contract.py && cd dart && dart test test/semantic_index_source_foundation_test.dart test/semantic_index_compilation_foundation_test.dart test/semantic_index_static_graph_test.dart test/semantic_index_call_projection_test.dart"
---

# Dart Semantic Query Authority Map

The existing Dart `_SemanticStaticProjection` is the complete and only allowed authority for query evaluation. It
contains an immutable snapshot, source-reference table, canonically ordered records, and canonically ordered
relations. A query must receive a fresh detached plain-data clone of that projection. It must not receive the
retained decoded source/bytes/source mapper, parsed `SpecFile`, `CompiledSpec`, function registry, staged sidecars,
AST/ActionIR, compiled regexes, generated implementation source, executor, trace state, path, or host object.

The neutral contract freezes 19 non-runtime response digests and 26 malformed-request boundaries. Dart's typed
request path and raw-neutral path must enter one evaluator and return the same immutable typed response envelope.
The raw-neutral seam exists because malformed JSON shapes cannot all be represented by the typed request class;
it does not broaden evaluator authority. Responses and capabilities must be fresh clone-safe values, and
canonical JSON identity must be deterministic under repeated and interleaved queries.

The dependency split is omission-safe:

1. `.10.5.4.1` adds immutable typed protocol values plus a package-private capabilities/list/get/explain and
   source/redaction kernel. The incomplete seam remains outside the public umbrella.
2. `.10.5.4.2` adds directional breadth-first relations, canonical paging, budgets, costs, deterministic prefixes,
   and every successful static digest.
3. `.10.5.4.3` exposes public capabilities/typed query/raw-neutral query only after the evaluator is complete; it
   locks all 19 digests, all 26 structural boundaries, privacy, clone isolation, and forbidden-authority denial.
4. `.10.5.4.4` composes complete signoff and closes the query parent.

Runtime `execution` and `event` records remain absent. Caller-captured runtime observation and the twentieth digest
belong exclusively to `.10.5.5`; rollout/admission promotion belongs to `.10.5.6`.

Leaves `.10.5.4.1-.2` now implement immutable record/source and exact traversal/page/budget behavior; see
[[dart-semantic-query-record-kernel]] and [[dart-semantic-query-traversal-kernel]].

Related facts: [[semantic-introspection-neutral-contract]], [[dart-semantic-introspection-authority-map]],
[[perl-semantic-query-evaluator]], [[rust-semantic-query-evaluator]].
