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
  - "does Rust descriptor v1 use rule local cursor policy"
  - "what fields are in Rust resolved edge descriptors"
  - "does Rust descriptor retain bare versus explicit edge provenance"
date: 2026-07-18
status: current through rule-local cursor descriptor v1
tags: [rust, descriptor, compiler-state, public-api, staged-parsing, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.2.2 adds rust/linkedspec-core/src/descriptor.rs, CompiledSpec::descriptor_state(), CompiledSpec::to_descriptor_json(), and ordered CompiledRule.dependency_refs. Three focused tests prove the four-key shape, model/order/rule/dependency/staged-function values, compiled-state JSON round-trip identity, and deterministic last-definition projection. The full core package and full Rust gate pass: formatting, 137 runtime tests, 105 oracle fixtures, 196 integration tests, three generated-source tests, ten trace tests, and 61/61 CLI cases in both environments."
evidence_update_2026_07_11: "FUTURE-PARITY-BACKLOG.1.6.2.3 makes the focused Rust shape test consume capability_conformance/outward_descriptor_contract.json alongside Perl, Dart, and Julia. Exact four-backend descriptor admission is closed."
evidence_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.4.4 migrates Rust to linkedspec-rule-local-cursor-v1: root/rule global mode fields are absent; every rule publishes normalized family, derived cursor_policy, edge_ownership, and ordered ownership/target/regex_index/block/fluent rows. All 36 families, every valid neutral edge case, direct/CompiledSpec-JSON identity, loaded projection, and live agreement pass; generated-source v1 remains separately staged."
evidence_update_2026_07_18_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.4.5 removes the last generated-v1 consumer of legacy_artifact_parse_mode. Descriptor and generated-source now independently derive from normalized family state; generated v2 carries no serialized cursor field."
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

Cursor metadata now consumes the shared `rule_local_cursor_v1` descriptor variant. Root metadata identifies
`linkedspec-rule-local-cursor-v1`; it has no global cursor field. Rule metadata publishes `family` (`and` or
`or_default`), derived `cursor_policy`, aggregate `edge_ownership`, and ordered `resolved_edges`. Each semantic row
has exactly `ownership`, `target`, `regex_index`, `block`, and `fluent`. Action indexes select the child regex slot;
blind rows use null. Bare/explicit `source_form` is omitted because the neutral contract declares it optional and
non-semantic and normalized `CompiledRule` state deliberately does not retain it.

The projection is pure derived state: direct, loaded, and ordinary compiled-JSON-reconstructed values agree, and
descriptor policy is the same `CompiledRule::cursor_policy()` normal execution spends. Generated-source v2 now
derives policy independently from its validated neutral family rows; no legacy artifact adapter remains.
