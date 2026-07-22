---
id: dart-semantic-query-public-api
title: Dart exposes one exact immutable typed and raw-neutral semantic query evaluator
answers:
  - "how do I call the public Dart semantic query API"
  - "what is the difference between Dart SemanticIndex query and queryNeutral"
  - "does Dart SemanticIndex expose semantic capabilities"
  - "does Dart semantic query validate malformed neutral requests"
  - "are Dart semantic query responses clone safe"
  - "can Dart semantic query compile execute trace or read paths"
  - "is Dart runtime semantic observation implemented"
date: 2026-07-22
status: current exact public static-query API; runtime observation and admission remain pending
tags: [dart, semantic-introspection, query, capabilities, validation, immutability, privacy]
evidence: dart/lib/src/semantic/semantic_index.dart; dart/lib/src/semantic/semantic_query.dart; dart/lib/linkedspec_dart.dart; dart/test/semantic_index_query_kernel_test.dart; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.4.3
reverify: "cd dart && dart test test/semantic_index_query_kernel_test.dart test/semantic_index_source_foundation_test.dart test/semantic_index_compilation_foundation_test.dart test/semantic_index_static_graph_test.dart test/semantic_index_call_projection_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

# Dart Semantic Query Public API

`SemanticIndex` publicly exposes three semantic-query entrypoints:

- `index.capabilities` returns a fresh exact `SemanticQueryResponse` for the v1 capability operation;
- `index.query(SemanticQuery(...))` is the idiomatic immutable typed Dart path; and
- `index.queryNeutral(value)` validates a raw JSON-like value and returns the same typed response envelope.

Every request/response protocol type is exported through `package:linkedspec_dart/linkedspec_dart.dart`. The typed
and raw paths do not duplicate semantics: both enter `_evaluateSemanticQueryNeutral` after receiving a new
`_staticProjection.detachedJson()` clone. Raw input exists to represent invalid keys, containers, duplicate values,
numeric/boolean confusion, and non-string cursors that the typed model intentionally cannot construct.

All 19 non-runtime static requests match their complete canonical SHA-256 response digests through both paths. All
26 portable malformed-request boundaries return exact diagnostics and empty primary streams. Rejected responses
preserve invalid cursor evidence as detached plain data without retaining or mutating the caller's request.
Capabilities, lists, records, relations, diagnostics, pages, costs, and every `toJson()` result are owned or fresh
clone-safe values; repeated and interleaved calls have deterministic JSON identity.

The evaluator receives only the normalized snapshot, source-reference table, records, and relations. It cannot
read accepted source wholesale, parser/compiler objects, staged sidecars, AST/ActionIR, compiled regexes, generated
implementation source, executors, trace state, paths, environment, or host objects. Query evaluation never compiles
or executes a target and cannot enable trace. Runtime `execution` and `event` records remain absent until
`.10.5.5`; Dart rollout/native admission remain unchanged until `.10.5.6`.

Related facts: [[dart-semantic-query-authority-map]], [[dart-semantic-query-record-kernel]],
[[dart-semantic-query-traversal-kernel]], [[dart-semantic-introspection-authority-map]],
[[semantic-introspection-neutral-contract]].
