---
id: rust-outward-compiled-descriptor-projection
title: Rust projects typed and JSON outward descriptors directly from CompiledSpec
answers:
  - "how does Rust expose the backend neutral compiled descriptor"
  - "what does Rust descriptor_state return"
  - "how does Rust convert a compiled descriptor to JSON"
  - "does Rust descriptor introspection require the runtime engine"
  - "does Rust preserve dependency refs in source order"
  - "does Rust descriptor projection survive CompiledSpec JSON round trips"
date: 2026-07-11
status: current
tags: [rust, descriptor, compiler-state, public-api, staged-parsing, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.2.2 adds rust/linkedspec-core/src/descriptor.rs, CompiledSpec::descriptor_state(), CompiledSpec::to_descriptor_json(), and ordered CompiledRule.dependency_refs. Three focused tests prove the four-key shape, model/order/rule/dependency/staged-function values, compiled-state JSON round-trip identity, and deterministic last-definition projection. The full core package and full Rust gate pass: formatting, 137 runtime tests, 105 oracle fixtures, 196 integration tests, three generated-source tests, ten trace tests, and 61/61 CLI cases in both environments."
evidence_update_2026_07_11: "FUTURE-PARITY-BACKLOG.1.6.2.3 makes the focused Rust shape test consume capability_conformance/outward_descriptor_contract.json alongside Perl, Dart, and Julia. Exact four-backend descriptor admission is closed."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --test descriptor_test && bash tools/run_rust_local.sh"
---

# Rust Outward Compiled Descriptor Projection

`CompiledSpec::descriptor_state()` returns typed serializable records from `linkedspec_core::descriptor`.
`CompiledSpec::to_descriptor_json()` returns the equivalent JSON object. Both expose `spec`, `functions`,
`dependency_regex_map`, and `meta` without importing or launching the runtime engine.

Compilation preserves dependency references explicitly in source order. The projection also carries staged
function payload/job/AST values, deterministic source and last-definition compile order, redefinition labels,
function order/count, rule modes, combined dependency patterns, and the canonical composing/nested model
identities. The legacy fallback derives dependency refs from dispatch entries when older serialized compiled state
does not contain the new field.

The focused Rust test consumes the same exact outer descriptor and function-record schema as Perl, Dart, and Julia;
four-backend admission closed under `FUTURE-PARITY-BACKLOG.1.6.2.3`.
