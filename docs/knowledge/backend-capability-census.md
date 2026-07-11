---
id: backend-capability-census
title: A validated 15-capability census owns every remaining four-backend parity residual
answers:
  - where is the LinkedSpec backend capability matrix
  - how many backend capabilities are in the parity census
  - which current capabilities are not yet equal across Perl Rust Dart and Julia
  - does the 105 fixture corpus prove every current LinkedSpec language feature
  - does Rust expose the backend neutral compiled descriptor
  - does Rust expose structured runtime diagnostics
  - do Rust Dart and Julia have native named spec resolution
  - does Dart trace frontend compiler and staged phases
  - what did FUTURE-PARITY-BACKLOG 1.6.0 audit
date: 2026-07-10
status: current
tags: [parity, capability, matrix, public-api, rust, dart, julia, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.0 adds capability_conformance/manifest.json and tools/check_capability_conformance.pl: 15 capabilities x four backends classify 47 pass, five partial-proof, and eight gap states, each non-pass state with an explicit owner."
evidence_update_2026_07_10: "FUTURE-PARITY-BACKLOG.1.6.1 closes exhaustive current-language proof at 239 bidirectionally checked ActionIR names and 105 exact fixtures on Perl, Rust, Dart, and Julia. The 60-state census is now 51 pass, one partial, and eight gap."
evidence_update_2026_07_11: "FUTURE-PARITY-BACKLOG.1.6.2.0 uses return_descriptor to prove Perl's projection has the stale descriptor_model value compiled_spec_state_v1 while its composing owner, mdBook, Dart, and Julia use compiled_descriptor_state. The census is now 50 pass, two partial, and eight gap until .1.6.2.1 reconciles the public tag."
evidence_update_2026_07_11_identity: "FUTURE-PARITY-BACKLOG.1.6.2.1 changes Perl descriptor_model to compiled_descriptor_state and adds explicit compiled_spec_model / compiled_dependency_regex_model identities, matching Dart/Julia and the mdBook. Phase 0 1..1030 passes; the census returns to 51 pass, one partial, and eight gap while Rust projection remains active."
evidence_update_2026_07_11_rust_descriptor: "FUTURE-PARITY-BACKLOG.1.6.2.2 adds typed Rust descriptor_state/to_descriptor_json projection with ordered dependency refs, staged function metadata, deterministic order, and compiled-state round-trip proof. The census is 51 pass, two partial, and seven gap until .1.6.2.3 normalizes outer function records and admits the row."
reverify: "perl tools/check_capability_conformance.pl && rg -n 'FUTURE-PARITY-BACKLOG.1.6.[0-6]' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`capability_conformance/manifest.json` is the current user-observable capability census. The checker validates the
schema, exact backend set, evidence paths, status vocabulary, unique ids, gap ownership, and explicit legacy/future
exclusions. After Rust descriptor projection, its 15 rows and 60 backend states classify 51 pass, two partial, and
seven gap.

The audit distinguishes implementation gaps from proof gaps:

- the 105-fixture interpreter corpus passes all four backends and is indexed against the 239-name current
  non-legacy ActionIR surface; `.1.6.1` closed that neutral proof;
- all four expose outward descriptors and aligned model identities; `.1.6.2.3` owns exact outer function-record
  normalization and final admission;
- Perl/Dart/Julia expose structured runtime diagnostic attribution, while Rust uses a string payload in
  `LinkedSpecError::Runtime`; `.1.6.3` owns the structured record;
- the native file-oriented named-spec role exists only as Perl `get_parser(...)`; Rust/Dart/Julia process adapters
  resolve names but their public libraries do not; `.1.6.4` owns idiomatic native equivalents;
- Perl/Rust/Julia propagate a native emitter through frontend/compiler/function-shell/staged/runtime phases, while
  Dart native trace begins at the interpreter; `.1.6.5` owns the missing pipeline coverage;
- generated source remains top-level `.3`: Perl passes, Rust has all structural families but only a curated corpus
  proof, and Dart/Julia have no emitter.

`.1.6.6` closes non-codegen capability parity only after the matrix has no unowned partial/gap state. Deprecated
Perl plugins and not-yet-current general parse jobs, semantic introspection/MCP, generic final-codeblock behavior,
and Lua are explicit exclusions/future owners, not omitted rows.

Related facts: [[user-observable-backend-cli-parity-contract]], [[native-in-memory-backend-contract]],
[[trace-cross-variant-capability-contract]], [[dart-generated-source-deferred]],
[[julia-generated-source-deferred]], [[rust-parity-followon-closed]], [[primary-cli-four-backend-matrix]].
