---
id: rust-semantic-call-staged-projection
title: Rust SemanticIndex retains exact private call staged and generated v1 data
answers:
  - "does Rust semantic introspection project functions helpers calls and bindings"
  - "how are Rust semantic call records ordered"
  - "how does Rust semantic introspection infer function and call shapes"
  - "how does Rust semantic introspection represent function body staging"
  - "where does Rust semantic generated plan provenance come from"
  - "are Rust function sidecar source spans bytes or Unicode scalars"
  - "how does Rust correlate typed ActionIR calls with exact authored source"
  - "why do interleaved Rust function shells not become rule members"
  - "does Rust semantic call projection expose ActionIR or generated source"
  - "what proves the Rust semantic calls fixture has 22 records and 25 relations"
  - "does Rust semantic introspection have public capabilities or query yet"
date: 2026-07-21
status: current private compiled projection exposed through admitted exact public static/runtime query
tags: [rust, semantic-introspection, actionir, calls, bindings, staging, generated-source, unicode]
evidence: rust/linkedspec-runtime/src/semantic_index/call_projection.rs; rust/linkedspec-runtime/src/semantic_index/static_projection.rs; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.4.3
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime semantic_index::static_projection::tests; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; perl tools/check_generated_source_contract.pl"
---

`linkedspec_runtime::semantic_index::SemanticIndex` now retains the corrected calls snapshot's complete private
compiled projection. The Rust projector composes compiled function registry order/signatures, source-preorder typed
ActionIR calls and bindings, normalized function-body staged sidecars, immutable authored-source correlation, and
the existing generated-source-v2 plan. After source keys are materialized, all 22 records and 25 relations
deep-equal `linkedspec-semantic-model-v1`.

Traversal is deterministic authored preorder: definitions merge by exact source position, statements retain order,
and an outer call precedes nested arguments. Registered functions resolve before helper fallback. Conservative
shape inference strengthens only typed literals, current bindings, registered function returns, and the governed
semantic helper vocabulary; anything else remains `unknown`. Staged records keep payload, parse job, and result
separate with exact `consumes`, `produces`, `lowered_from`, and `staged_by` directions.

Typed ActionIR remains semantic authority, while the exact authored brace interior is only the source-correlation
oracle. Function sidecar `source_span` and `body_span` values are decoded-scalar offsets; the immutable source mapper
performs the only conversion to strict UTF-8 byte offsets and one-based Unicode-scalar columns. Function shells are
selected by the exact occurrence containing their staged body span, so interleaved or duplicate-looking definitions
cannot become synthetic rule members.

Generated contract, format, entry, and family come from the existing `SemanticGeneratedPlanInput` also used by
source emission. No generated implementation text is produced or retained. Four focused regressions lock complete
22/25 equality, preorder and resolution, staged directions, multibyte excerpts/columns, interleaved function-shell
isolation, and denial of AST/body/generated-source leakage. The retained projection is clone-safe plain data and
remains crate-private. `.10.4.4` now exposes it only through exact immutable capabilities/query responses; runtime
derivation is exact under `.10.4.5`; composed Rust admission `.10.4.6` subsequently advances only Rust to rollout
3/9 and admission 2/6.

See [[rust-semantic-static-projection]], [[rust-semantic-index-source-foundation]],
[[rust-semantic-introspection-authority-map]], [[perl-semantic-call-staged-projection]],
[[rust-semantic-query-evaluator]], [[rust-semantic-runtime-observation]],
[[semantic-introspection-staged-artifact-schema]], and
[[semantic-introspection-generated-plan-authority]].
