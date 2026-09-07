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
date: 2026-09-07
status: current admitted native static/runtime query evaluator
tags: [rust, semantic-introspection, query, privacy, pagination, budgets, immutability, json]
evidence: rust/linkedspec-runtime/src/semantic_index/query.rs; rust/linkedspec-runtime/src/semantic_index.rs; rust/linkedspec-runtime/tests/semantic_index_query.rs; FUTURE-PARITY-BACKLOG.10.4.4
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_query; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
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
changing this projection-only evaluator. Composed Rust admission `.10.4.6` subsequently advances only Rust to
neutral rollout 3/9 and backend admission 2/6.

See [[rust-semantic-runtime-observation]], [[rust-semantic-static-projection]], [[rust-semantic-call-staged-projection]],
[[rust-semantic-index-source-foundation]], [[perl-semantic-query-evaluator]], and
[[semantic-introspection-neutral-contract]].

## September 7 evaluator and validation prefix reading

`SESSION-STARTUP-READING.3.3.31` reads query.rs 1–589. Typed options retain exact field shapes/defaults;
all public routes enter one raw-value validator. It checks object/contract/field shape, vocabulary, duplicate
and rank-ordered filters, integer bounds and source ceiling before operation dispatch. The remaining operation
constraints and page/traversal/projection helpers are completed by the following checkpoint. The evaluator lists cloned records,
uses subject membership for Get, and projects source only at return; explanations reserve the decision record
before paging its steps. Costs are canonical selected model units, not CPU/host scan limits (ADR 0049).
Existing .66/.67 input-projection defects remain visible through this evaluator; this source reading does not
claim to repair or freshly exercise get/page/relations. Neutral semantic proof passes current 6/20/128,9/0,6/0.

## September 7 complete query helper reading

`SESSION-STARTUP-READING.3.3.32` completes query.rs 590–1003. Operation/filter combinations are
checked after shared validation. Paging resolves after-id in the filtered primary stream, selects a deterministic
prefix bounded by page and record/relation budget, and returns the last selected id when more remain.
Relation traversal records each relation's first breadth-first depth, tracks visited record ids, follows the
requested direction/kinds and returns canonical projection order. A nonempty next layer marks depth exhaustion.
These are logical model budgets; the helper may inspect/materialize larger vectors before returning that prefix.

Record projection nulls regex pattern, diagnostic message and explanation summary below text and records the
exact fact path. Source identity/span/excerpt/digest are assembled structurally from retained source references.
Malformed responses retain the request's after-id value, empty records/relations, complete page and zero cost.
Fresh neutral proof remains 6/20/128 at 9/0 and 6/0. This is complete source reading plus the neutral checker;
the earlier native test counts remain dated, and .66/.67 projection repairs remain pending.
