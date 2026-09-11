---
id: julia-semantic-query-public-api
title: Julia exposes one exact immutable typed and raw-neutral semantic query evaluator
answers:
  - "how do I call the public Julia semantic query API"
  - "what is the difference between semantic_query and semantic_query_neutral in Julia"
  - "does Julia expose semantic capabilities"
  - "does Julia semantic query accept JSON3 Object input"
  - "how many malformed neutral semantic query requests does Julia validate"
  - "why does Julia semantic query reject Bool before Integer"
  - "are Julia semantic query requests and responses clone safe"
  - "can Julia semantic query compile execute trace read paths or invoke callbacks"
  - "is Julia runtime semantic observation implemented"
date: 2026-07-23
status: current exact public typed/raw-neutral query API; static parent and observed runtime derivation complete, admission pending
tags: [julia, semantic-introspection, query, capabilities, validation, immutability, privacy]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.6.5.3-.10.6.5.4; julia/src/semantic/SemanticQuery.jl; julia/src/LinkedSpecJulia.jl; julia/test/semantic_index_query_public_test.jl; julia/test/runtests.jl; capability_conformance/semantic_introspection_contract.json
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test, JSON3; const REPO_ROOT=pwd(); include(\"julia/test/semantic_index_source_foundation_test.jl\"); include(\"julia/test/semantic_index_compilation_foundation_test.jl\"); include(\"julia/test/semantic_index_static_graph_test.jl\"); include(\"julia/test/semantic_index_static_remaining_test.jl\"); include(\"julia/test/semantic_index_call_core_test.jl\"); include(\"julia/test/semantic_index_call_staged_test.jl\"); include(\"julia/test/semantic_index_query_kernel_test.jl\"); include(\"julia/test/semantic_index_query_traversal_test.jl\"); include(\"julia/test/semantic_index_query_public_test.jl\")'; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
---

# Julia Semantic Query Public API

`LinkedSpecJulia` exports the complete immutable query vocabulary and three public entry points:

- `semantic_capabilities(index)` evaluates the canonical v1 capabilities request;
- `semantic_query(index, request::SemanticQuery)` is the idiomatic immutable typed path; and
- `semantic_query_neutral(index, request)` validates a raw JSON-like value and returns the same typed response.

The typed and raw paths do not duplicate semantics. A typed request is converted to the neutral request shape,
then both calls enter `_semantic_query_public_evaluate`. The shared path materializes
`_semantic_static_projection_materialize(index)` exactly once, uses its detached snapshot for validation envelopes,
and enters the existing evaluator for valid requests. It receives only fresh detached snapshot/source-reference/
record/relation data.

Raw input may be an ordinary `Dict` or a direct `JSON3.Object`; Julia exposes the latter's keys as symbols, so the
transport-normalization layer accepts `String` and `Symbol` keys while enforcing the same exact wire names. All 26
portable malformed boundaries return exact rejected responses with empty streams and zero costs. Page and budget
numbers explicitly reject `Bool` before `Integer`, while `include_content_digest` accepts only an actual `Bool`.

All 19 non-runtime static requests match their canonical SHA-256 response digests through both paths. Returned
typed values are recursively immutable, every `to_json` result is fresh, raw cursor evidence is detached, caller
input is not mutated, and repeated or interleaved requests are deterministic. The public suite adds 315 assertions;
all nine semantic suites compose at 1,063, and the complete Julia package reaches 8,605 assertions plus primary
process conformance and corpus 105/105.

Construction and query do not invoke target parsers, actions, lifecycle callbacks, generated execution, trace,
diagnostic sinks, or semantic observers. The evaluator cannot read retained source/map, parser/compiler owners,
staged sidecars, AST/ActionIR, compiled regexes, generated implementation, runtime observations, paths,
environment, clock, randomness, or other host objects. Runtime events remain `.10.6.6`; exact Julia semantic
admission and shared ledger promotion remain `.10.6.7`.

Full primary passes 5 backends x 2 environments x 66 cases and all ten Unicode legs. Governance remains unchanged
at semantic 6/20/81 with rollout 4/9 and admission 3/6 plus Unicode 806/9/8/2, capability 80/0/0, generated
v1/10/80-0-0, and public 59/27/0. Canonical CI passes Rust semantic admission in 79.96 seconds, Dart 1/1, primary
66x2, and Phase 0 1,031/1,031 in 634 seconds. mdBook, Knowledge Map 690/5,307, all four doctrines, and exact
1,613,820-KiB cleanup preserving Julia package/registry caches and all 517 Pgen artifacts pass.

No-change `.10.6.5.4` retrieves this card and the authority/kernel/traversal cards, then recomposes all nine
committed semantic suites at exact focused 1,063. Complete Julia remains 8,605/primary/105; primary 5x2x66, ten
Unicode legs, and every unchanged ledger pass without production code, replacement tests, fixtures, contract/API/
format behavior, runtime observation, rollout, or admission. Parent `.10.6.5` is composition-closed; the twentieth
runtime-events response remains `.10.6.6`, beginning with separate authority plan `.10.6.6.0` after the clean
closeout commit. Canonical Rust 79.55s + Dart 1/1 + primary 66x2 + Phase 0 1,031/635s, book/KM 690/5,307,
doctrines, and exact 1,613,872-KiB cleanup preserving 517 Pgen artifacts pass.

Runtime capture `.10.6.6.1` and derivation `.10.6.6.2` now make the twentieth response available without widening
query authority. `with_execution_observation` builds a new frozen projection from typed events plus static
rule/edge/slot evidence; the same typed/raw-neutral query paths then return the canonical runtime-events response.
Query itself still cannot execute, trace, install a sink, hash input, or inspect runtime/compiler/host state. See
[[julia-semantic-runtime-observation-derivation]].

Related facts: [[julia-semantic-query-authority-map]], [[julia-semantic-query-kernel]],
[[julia-semantic-query-traversal]], [[julia-semantic-introspection-authority-map]],
[[semantic-introspection-neutral-contract]].

## 2026-09-11 — public query budget limitations

Julia .1.27 reads the public/typed/raw-neutral query prefix through1370. Fresh
public and its eight dependent semantic suites pass1063 assertions. Separate
six-case public controls pass26 assertions and equal the neutral evaluator,
while exposing unchecked explain relation/depth costs and a premature list-page
budget warning. Existing immutability/fixture success does not close those
boundaries. Shared startup .82 owns the repair in
[[semantic-query-budget-contract-gaps]]; query remains target-execution-free.

## 2026-09-11 — query helper reading complete

Julia .1.28 completes SemanticQuery1371-1587 through EOF. Rejected requests
return empty streams/zero costs; raw cursor evidence is frozen or discarded if
its host type is unsupported. Typed/raw integer paths reject Bool and translate
unsupported Int conversion; separate tuple-backed object/array wrappers preserve
empty-container identity and thaw to fresh JSON values. Existing query and
observation composition passes1286. Shared budget .82 and all source/projection
repairs remain pending; helper reading does not expand those finite assertions.
Replay: [[julia-semantic-static-correlation-gaps]].
