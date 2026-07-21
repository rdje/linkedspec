---
id: rust-semantic-query-evaluator
title: Rust exposes one typed and neutral immutable static semantic query evaluator
answers:
  - "does Rust semantic introspection expose capabilities and query"
  - "what is the Rust SemanticQuery API"
  - "how does Rust accept malformed neutral semantic query JSON"
  - "how many semantic query response digests does Rust match"
  - "does Rust semantic query compile or execute"
  - "does Rust semantic query read paths or enable trace"
  - "how does Rust semantic query enforce source privacy"
  - "how does Rust semantic query traverse relations"
  - "how does Rust semantic query count pages budgets and costs"
  - "what proves Rust native and neutral semantic query identity"
  - "does Rust semantic query expose ActionIR CompiledSpec or generated source"
  - "does Rust semantic query include runtime events"
  - "is Rust semantic introspection admitted after static query"
date: 2026-07-21
status: current native static/runtime query evaluator; composed Rust admission remains separate
tags: [rust, semantic-introspection, query, privacy, pagination, budgets, immutability, json]
evidence: rust/linkedspec-runtime/src/semantic_index/query.rs; rust/linkedspec-runtime/src/semantic_index.rs; rust/linkedspec-runtime/tests/semantic_index_query.rs; FUTURE-PARITY-BACKLOG.10.4.4
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_query; python3 tools/check_semantic_introspection_contract.py"
---

`linkedspec_runtime::semantic_index::SemanticIndex` exposes `capabilities()`,
`query(&SemanticQuery)`, and `query_neutral(&serde_json::Value)`. `SemanticQuery` gives native callers typed
operations, direction, page, budget, and source policy. The raw-neutral seam preserves exact portable diagnostics
for structurally invalid JSON that cannot deserialize into the typed request. Both paths enter the same evaluator
over a fresh clone of the retained normalized projection and return owned typed `SemanticQueryResponse` values.

The evaluator implements the v1 `capabilities`, `list`, `get`, `relations`, and `explain` operations. It applies
canonical primary-stream after-id pages, filtered directional breadth-first relation traversal, logical record/
relation/depth budgets and costs, and exact explanation evidence. Source projection is structural: detail below
`text` nulls source-sensitive facts and lists exact redaction paths; `identity`, `span`, and `text` add only their
allowed fields; digest requires `text`; and no query can exceed the immutable construction ceiling.

The evaluator receives no accepted source text, parsed AST, `CompiledSpec`, compiled regex, ActionIR, executor,
trace sink, generated implementation source, or filesystem path. Querying cannot compile, execute, capture runtime
events, enable trace, or mutate the request/index. Every response is an owned clone, and repeated or interleaved
queries are deterministic.

`semantic_index_query.rs` matches all 19 non-runtime canonical response SHA-256 digests through both typed and
raw-neutral entrypoints, covers the exact 26 request/error boundaries, and separately locks privacy, response
mutation isolation, input isolation, deterministic interleaving, absent execution state, and host/path/IR denial.
The twentieth runtime response is supplied by the separate typed observation/derivation owner in `.10.4.5` without
changing this projection-only evaluator. Composed Rust admission remains `.10.4.6`; neutral rollout and backend
admission therefore stay 2/9 and 1/6.

See [[rust-semantic-runtime-observation]], [[rust-semantic-static-projection]], [[rust-semantic-call-staged-projection]],
[[rust-semantic-index-source-foundation]], [[perl-semantic-query-evaluator]], and
[[semantic-introspection-neutral-contract]].
