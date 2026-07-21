---
id: rust-semantic-static-projection
title: Rust SemanticIndex retains an exact clone-safe private static v1 projection
answers:
  - "does Rust semantic introspection have static v1 records"
  - "which Rust authorities build semantic rule regex edge and lifecycle records"
  - "how does Rust normalize failed semantic compilation"
  - "does the Rust semantic static projection expose a query API"
  - "how are Rust semantic source references correlated"
  - "does Rust semantic static projection leak CompiledSpec or paths"
  - "what proves Rust graph privacy failed and runtime-static semantics"
date: 2026-07-21
status: current private static foundation consumed through public static/runtime query; composed admission remains separate
tags: [rust, semantic-introspection, records, relations, source-map, diagnostics, privacy, immutability]
evidence: rust/linkedspec-runtime/src/semantic_index.rs; rust/linkedspec-runtime/src/semantic_index/static_projection.rs; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.4.2
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime semantic_index::static_projection::tests; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_foundation; python3 tools/check_semantic_introspection_contract.py"
---

`linkedspec_runtime::semantic_index::SemanticIndex` now builds and retains a private static projection after its
source/outcome snapshot is fixed. Parsed authored source supplies line-aware rule, slot, edge, and lifecycle
correlation; typed `CompiledSpec` plus effective-entry and generated-plan authority supplies canonical root,
family, cursor, repetition, slot ownership, resolved topology, lifecycle presence, value shapes, and order. The
projector combines those owners into plain serializable v1 spec/source/rule/regex-slot/edge/lifecycle records and
static relations. It does not serialize parsed nodes, compiled regexes, `CompiledSpec`, object identity, or paths.

Source correlation reuses the foundation's immutable accepted text, canonical UTF-8 bytes, and exact source map.
Projection retains complete private references so the `.10.4.4` query evaluator can apply the caller's immutable
`none`/`identity`/`span`/`text` ceiling structurally. No public projection accessor exists: capabilities and query
consume only a fresh private clone and cannot bypass the construction ceiling. Returned response values are owned,
and mutation does not alter the index.

Failure normalization is explicit rather than accidental. Rust validation can report
`bare_edge_target_undefined` at `normalize_edges`, while direct compiled validation can report
`regex_slot_identity_invalid`. When either seam represents the accepted failed fixture's unknown authored target,
the projector emits neutral `unknown_rule_reference` at phase `compile`, retains exact rule/missing-rule fields and
source evidence, and adds the canonical dependency-resolution decision and ordered explanation relations.

Five internal exact-oracle tests materialize private source keys and deep-compare the entire graph fixture,
Unicode privacy fixture at text and identity construction ceilings, failed compilation, and the runtime fixture's
static half with `linkedspec-semantic-model-v1`. A fifth boundary test proves clone isolation and rejects host
objects and paths. Calls/staged/generated detail beyond static plan identity is composed by `.10.4.3`; public
static query is exact under `.10.4.4`, runtime derivation is exact under `.10.4.5`, and composed Rust admission
remains `.10.4.6`. Rollout/admission therefore stay 2/9 and 1/6. See [[rust-semantic-query-evaluator]],
[[rust-semantic-runtime-observation]], [[rust-semantic-call-staged-projection]],
[[rust-semantic-index-source-foundation]],
[[rust-semantic-introspection-authority-map]], [[semantic-introspection-neutral-contract]], and
[[perl-semantic-static-projection]].
