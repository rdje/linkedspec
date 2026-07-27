---
id: julia-semantic-query-authority-map
title: Julia semantic query must consume only one fresh detached static projection
answers:
  - "what authority may the Julia semantic query evaluator consume"
  - "how many static semantic query digests must Julia match"
  - "how many malformed neutral semantic query boundaries must Julia validate"
  - "how is the Julia semantic query implementation split"
  - "what Julia semantic query types and functions are planned"
  - "why must Julia semantic query reject Bool before Integer"
  - "may Julia semantic query access source text compiler objects paths execution or trace"
  - "when may Julia expose its public semantic query API"
  - "does Julia semantic query include runtime events"
date: 2026-07-23
status: current authority; immutable static query composition closed, runtime observation pending
tags: [julia, semantic-introspection, query, capabilities, privacy, pagination, budgets, immutability]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.6.5.0-.10.6.5.4; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; capability_conformance/semantic_introspection_contract.json; capability_conformance/semantic_introspection_model.json; julia/src/semantic/SemanticIndex.jl; julia/src/semantic/SemanticStaticProjection.jl; julia/src/semantic/SemanticCallProjection.jl; julia/src/semantic/SemanticQuery.jl; julia/test/semantic_index_query_kernel_test.jl; julia/test/semantic_index_query_traversal_test.jl; julia/test/semantic_index_query_public_test.jl; perl/LinkedSpec/SemanticQuery.pm; rust/linkedspec-runtime/src/semantic_index/query.rs; dart/lib/src/semantic/semantic_query.dart
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py && PERL5LIB= prove -Iperl t/semantic_index_perl_query.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_query && (cd dart && dart test test/semantic_index_query_kernel_test.dart) && rg -n 'semantic_query|SemanticQuery|semantic_capabilities' julia/src"
---

# Julia Semantic Query Authority Map

Julia's closed `_SemanticStaticProjection` is the complete and only permitted input to static query evaluation. It
retains a typed `SemanticSnapshot` and recursively tuple-backed source references, records, and relations. Each
query receives one fresh detached plain-data materialization. It must not receive retained decoded source or source
map, source detail above the construction ceiling, parsed or compiled owners, staged sidecars, AST/ActionIR,
compiled regexes, generated implementation, loader/emitter/executor, runtime observation, trace or diagnostic sink,
path, environment, clock, randomness, or any other host object.

The neutral oracle freezes 20 response hashes, of which `runtime_events` alone needs post-execution authority.
Leaves `.10.6.5.1-.3` must therefore match the other 19 static hashes exactly and validate the same 26 malformed
raw-neutral boundaries as Perl, Rust, and Dart. Runtime `execution`/`event` records and the twentieth hash belong to
`.10.6.6`; rollout and native admission remain later `.10.6.7` work.

The implemented immutable vocabulary is `SemanticQueryOperation`, `SemanticQueryDirection`, `SemanticQueryPage`,
`SemanticQueryBudget`, `SemanticQuerySource`, `SemanticQuery`, `SemanticQuerySourceReference`,
`SemanticQueryRecord`, `SemanticQueryRelation`, `SemanticQueryDiagnostic`, `SemanticQueryPageState`,
`SemanticQueryCost`, and `SemanticQueryResponse`, reusing `SemanticSourceDetail`, `SemanticSourceSpan`, and
`SemanticSnapshot`. Collections are copied tuples. Variable-shape record facts and diagnostic fields are
recursively immutable tuple-backed values; `to_json` produces a fresh `Dict`/`Vector` tree on every call.
Operation values are `SemanticQueryCapabilitiesOperation`, `SemanticQueryListOperation`,
`SemanticQueryGetOperation`, `SemanticQueryRelationsOperation`, and `SemanticQueryExplainOperation`; direction
values are `SemanticQueryOutgoingDirection`, `SemanticQueryIncomingDirection`, and `SemanticQueryBothDirection`.

The complete public surface now appears after the private evaluator was completed:

- `semantic_capabilities(index)` evaluates the canonical capabilities request;
- `semantic_query(index, request::SemanticQuery)` is the typed native path; and
- `semantic_query_neutral(index, request)` accepts raw JSON-like values so malformed shapes have portable response
  envelopes.

Both request paths enter the same projection-only evaluator and return the same typed response. The raw seam does
not add authority. Julia validators must test `Bool` before `Integer` for page and budget numbers because
`true isa Integer`, while `include_content_digest` must require an actual `Bool`. This is necessary to reproduce
the portable numeric/Boolean rejection boundaries rather than inheriting Julia subtype behavior.

Exact policy stays owned by the neutral contract: five operations, three directions, four source levels, canonical
record/relation order, source ceiling without silent downgrade, digest only at text, after-id paging, filter-
constrained directional breadth-first traversal, relation/frontier deduplication, logical record/relation/depth
budgets, deterministic incomplete prefixes, portable costs, four diagnostic codes, and decision-first explain
responses. Querying never compiles or executes and never enables trace.

The dependency split is omission-safe:

1. `.10.6.5.1` adds private immutable protocol values and capabilities/list/get/explain plus source redaction.
2. `.10.6.5.2` adds directional traversal, paging, budgets, costs, and all 19 static response hashes.
3. `.10.6.5.3` exports typed capabilities/query/raw-neutral query together and locks all 26 malformed boundaries,
   recursive clone isolation, non-interference, privacy, and forbidden-authority denial.
4. `.10.6.5.4` recomposes committed proof without a replacement implementation and closes the query parent.

Behavior-free audit `.10.6.5.0` changes no production code, tests, fixture, contract, public API, format, runtime
observation, rollout, or admission. Direct probing confirms the closed calls projection is 22 records / 25
relations / 10 source references, a mutation of one returned nested record cannot affect the next materialization,
and no public query symbol exists before implementation.

The completed audit passes neutral 6/20/81 at rollout 4/9 and native admission 3/6, focused admitted Perl 9 + Rust
5/5 + Dart 6/6, Julia focused 530, Julia 8,072/primary/105, primary 5x2x66, ten Unicode legs, and every unchanged
ledger. Canonical local CI passes doctrines/contracts, Rust and Dart semantic admission, primary 66x2, and Phase 0
1,031/1,031 in 655 seconds. mdBook, Knowledge Map 687/5,277, and exact 1,812,240-KiB artifact cleanup preserving
517 Pgen issue artifacts pass. Private kernel `.10.6.5.1` then lands immutable tuple-backed values plus exact
capabilities/list/get/explain/source behavior for nine static hashes. Traversal completion `.10.6.5.2` adds exact
filtered directional BFS, canonical pages, logical budgets/costs, deterministic prefixes, and the other ten static
hashes. The complete private evaluator therefore matches all 19 static responses, consumes one fresh detached
materialization per request. Public `.10.6.5.3` now exports every query type and the three calls together, routes
typed and raw input through one exact validator/evaluator, matches all 19 hashes through both paths, and locks all
26 malformed boundaries plus clone/privacy/non-execution/host denial. See [[julia-semantic-query-kernel]],
[[julia-semantic-query-traversal]], and [[julia-semantic-query-public-api]] for the implemented boundary and proof.
No-change `.10.6.5.4` retrieves those committed authorities and recomposes the nine owner suites at exact focused
1,063 with complete Julia 8,605/primary/105, primary 5x2x66, all ten Unicode legs, and unchanged ledgers. It adds no
production/replacement-test/API/format/runtime/promotion behavior and composition-closes parent `.10.6.5` before
runtime-observation planning `.10.6.6.0`. Canonical Rust 79.55s + Dart 1/1 + primary 66x2 + Phase 0 1,031/635s,
book/KM 690/5,307, doctrines, and exact 1,613,872-KiB cleanup preserving 517 Pgen artifacts pass.

Related facts: [[semantic-introspection-neutral-contract]], [[julia-semantic-introspection-authority-map]],
[[julia-semantic-call-staged-projection-plan]], [[perl-semantic-query-evaluator]],
[[rust-semantic-query-evaluator]], [[dart-semantic-query-authority-map]], [[julia-semantic-query-kernel]],
[[julia-semantic-query-traversal]], and [[julia-semantic-query-public-api]].
