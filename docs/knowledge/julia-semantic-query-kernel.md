---
id: julia-semantic-query-kernel
title: Julia privately implements exact immutable capabilities list get and explain queries
answers:
  - "does Julia implement semantic query capabilities list get and explain"
  - "which Julia semantic query operations are implemented privately"
  - "which nine Julia semantic query response hashes are exact"
  - "is the Julia semantic query API public"
  - "how are Julia semantic query values immutable"
  - "does Julia semantic query retain mutable dictionaries or arrays"
  - "how does Julia semantic query obtain the static projection"
  - "does Julia semantic query access source compiler runtime trace or paths"
  - "which Julia semantic query features remained after the non-traversal kernel"
  - "where is the Julia private semantic query kernel tested"
date: 2026-07-23
status: historical private non-traversal foundation beneath the complete public static evaluator
tags: [julia, semantic-introspection, query, capabilities, privacy, immutability, no-execution]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.5.1; julia/src/semantic/SemanticQuery.jl; julia/src/semantic/SemanticStaticProjection.jl; julia/src/LinkedSpecJulia.jl; julia/test/semantic_index_query_kernel_test.jl; julia/test/runtests.jl; capability_conformance/semantic_introspection_contract.json
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test, JSON3; const REPO_ROOT=pwd(); include(\"julia/test/semantic_index_source_foundation_test.jl\"); include(\"julia/test/semantic_index_compilation_foundation_test.jl\"); include(\"julia/test/semantic_index_static_graph_test.jl\"); include(\"julia/test/semantic_index_static_remaining_test.jl\"); include(\"julia/test/semantic_index_call_core_test.jl\"); include(\"julia/test/semantic_index_call_staged_test.jl\"); include(\"julia/test/semantic_index_query_kernel_test.jl\")'; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; rg -n '_semantic_query_kernel|_semantic_static_projection_materialize|semantic_query_kernel_case' julia/src/semantic/SemanticQuery.jl julia/src/semantic/SemanticStaticProjection.jl julia/test/semantic_index_query_kernel_test.jl"
---

# Julia Private Semantic Query Kernel

Leaf `.10.6.5.1` implements Julia's immutable semantic-query vocabulary and the non-traversal private evaluator.
The implementation lives in `julia/src/semantic/SemanticQuery.jl`, is included by the package, and deliberately
exported none of `SemanticQuery`, `SemanticQueryResponse`, `semantic_capabilities`, `semantic_query`,
`semantic_query_neutral`, or the private kernel at that boundary. Public `.10.6.5.3` now exports the types and
three calls together while the kernel stays private. Traversal and limits are complete under `.10.6.5.2`; see
[[julia-semantic-query-traversal]] and [[julia-semantic-query-public-api]].

The kernel matches nine complete portable response hashes: `capabilities`, `graph_list_rules`,
`graph_duplicate_regex_text`, `graph_explain_entry`, `calls_symbols_and_shapes`, `failed_diagnostic`,
`privacy_none`, `privacy_text_and_digest`, and `source_ceiling_forbidden`. It preserves canonical record order,
exact default page and logical cost envelopes, decision-before-explanation-step order, only the relevant
`explained_by` relations, source-ceiling rejection, structural redaction below text detail, and content digests
only when text detail explicitly requests them.

All retained request and response values are immutable Julia structs. Collections are copied tuples, while
variable-shape objects and arrays use separate private tuple-backed wrappers so an empty object cannot collapse
into an empty array. Recursive `to_json` conversion returns a fresh mutable `Dict`/`Vector` tree each time; mutating
one serialized result cannot affect the retained response or a later query. Page and budget validation rejects
`Bool` before accepting `Integer`, preserving the portable Boolean/numeric boundary despite `Bool <: Integer`.

`_semantic_static_projection_materialize(index)` is the one production-private authority seam. Each query calls it
exactly once and evaluates only the resulting detached snapshot, source-reference, record, and relation data. The
query file does not reach retained source text/maps/outcomes, parser/compiler/staged owners, AST/IR, compiled regex,
generated implementation, loader/emitter/executor, runtime observation, trace/sinks, paths, environment, time, or
randomness. The previous underscore-only test materializer delegates to the same seam.

At the `.10.6.5.1` boundary, cursor and non-default paging, record/relation/depth budgets, directional relation
traversal, deterministic incomplete prefixes, and the remaining ten static query hashes stayed in `.10.6.5.2`.
That completion is now implemented and exact; `.10.6.5.3` subsequently added raw malformed-request validation,
public typed/raw-neutral entry points, and complete clone/non-interference proof. Runtime events remain `.10.6.6`.

Focused proof is 100 assertions and the seven-suite Julia semantic composition is 630. Complete Julia reaches
8,172 package assertions plus primary process conformance and corpus 105/105; the full primary 5x2x66 matrix and
all ten Unicode-manifest legs pass. Governance remains 6/20/81 at rollout 4/9 and native admission 3/6, with
Unicode 806/9/8/2, capability 80/0/0, generated v1/10/80-0-0, and public 59/27/0 unchanged. Canonical local CI
passes Rust admission 1/1 in 80.95 seconds, Dart 1/1, primary 66x2, Phase 0 1,031/662s, book/KM 688/5,287, all
four doctrines, and exact 1,613,088-KiB cleanup preserving 517 Pgen artifacts plus Julia package/registry caches.

Related facts: [[julia-semantic-query-traversal]], [[julia-semantic-query-public-api]],
[[julia-semantic-query-authority-map]], [[julia-semantic-static-projection-plan]],
[[julia-semantic-call-staged-projection-plan]], [[semantic-introspection-neutral-contract]].
