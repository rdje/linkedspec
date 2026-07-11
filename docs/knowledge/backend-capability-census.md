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
evidence_update_2026_07_11_descriptor_admission: "FUTURE-PARITY-BACKLOG.1.6.2.3 adds one exact descriptor contract consumed by all four variants, normalizes outer function records, and promotes compiled-descriptor projection to pass. The census is now 52 pass, one partial, and seven gap."
evidence_update_2026_07_11_rust_diagnostic_audit: "FUTURE-PARITY-BACKLOG.1.6.3.0 corrects the prior boundary description: Rust Engine public methods and internal runtime frames return Result<_, String>; core LinkedSpecError::Runtime is unused by linkedspec-runtime. Typed implementation .1 and admission .2 now own the gap. Census remains 52 pass, one partial, seven gap."
evidence_update_2026_07_11_rust_diagnostic_implementation: "FUTURE-PARITY-BACKLOG.1.6.3.1 adds typed/JSON RuntimeDiagnostic and RuntimeExecutionError, optional Engine source identity, diagnostic-aware accumulator/direct methods, deepest-child attribution, and string compatibility. Five focused and the complete runtime package pass; .1.6.3.2 owns final recurring-gate admission, so census remains 52/1/7 until closeout."
evidence_update_2026_07_11_rust_diagnostic_admission: "FUTURE-PARITY-BACKLOG.1.6.3.2 passes the complete Rust gate including five diagnostics and 61x2 CLI, promotes structured runtime diagnostics to pass, and closes .1.6.3. The census is now 53 pass, one partial, six gap."
evidence_update_2026_07_11_native_resolution_audit: "FUTURE-PARITY-BACKLOG.1.6.4.0 finds that non-Perl named resolution remains process-adapter-only and fallback semantics drift: Rust/Dart stop after three local candidates, Julia adds sorted recursive repository discovery, and Perl PathSearch fallback selects through hash-key order. Neutral contract .1 now owns explicit ordered roots before backend implementation. Census remains 53/1/6."
evidence_update_2026_07_11_native_resolution_contract: "FUTURE-PARITY-BACKLOG.1.6.4.1 adds ADR 0026, a 13/9/4 executable contract, standalone checker, and canonical-gate wiring for portable names/exact paths, ordered roots, first regular file, strict UTF-8, identity, and typed stages/codes. No backend row promotes; census remains 53/1/6 until implementations and admission."
evidence_update_2026_07_11_rust_native_resolution: "FUTURE-PARITY-BACKLOG.1.6.4.2 adds public Rust name/path resolution, strict loading, staged parse/validate/compile composition, source identity, structured errors, direct 14/9/4 fixture proof, and CLI delegation. Full Rust gate including five loader and 61x2 CLI passes; Rust promotes to pass and census is 54/1/5."
evidence_update_2026_07_11_dart_native_resolution: "FUTURE-PARITY-BACKLOG.1.6.4.3 adds public Dart name/path resolution, strict loading, staged parse/validate/compile composition, source identity, structured exceptions, direct 14/9/4 fixture proof, and CLI delegation. Full Dart gate passes 165 tests, 61x2 CLI, and 105 corpus fixtures; Dart promotes to pass and census is 55/1/4."
evidence_update_2026_07_11_julia_native_resolution: "FUTURE-PARITY-BACKLOG.1.6.4.4 adds public Julia name/path resolution, strict loading, staged parse/validate/compile composition, source identity, typed structured exceptions, direct 14/9/4 fixture proof, CLI delegation, and recursive-fallback removal. Full Julia proof passes 1,110 assertions, 61x2 CLI, and 105 corpus fixtures; Julia promotes to pass and census is 56/1/3."
evidence_update_2026_07_11_native_resolution_admission: "FUTURE-PARITY-BACKLOG.1.6.4.5 adds a separate public Perl portable facade and direct 14/9/4 fixture/pipeline test to canonical CI without changing legacy PathSearch. Core CI passes 61x2 CLI and Phase 0 1..1030; combined adjacent backend proof admits all four and closes .1.6.4. Census remains 56/1/3."
evidence_update_2026_07_11_dart_full_pipeline_trace: "FUTURE-PARITY-BACKLOG.1.6.5.1-.3 propagate one caller-owned Dart emitter through frontend/compiler, function shell/staged dispatch, public native loading, and runtime. Direct routed/quiet/failure identity plus 175 tests, 61x2 CLI, 105 corpus, and core CI pass; Dart promotes and census is 57/1/2."
evidence_update_2026_07_11_non_codegen_closeout: "FUTURE-PARITY-BACKLOG.1.6.6 directly enumerates the only non-pass states: generated parser source is Rust partial and Dart/Julia gap, all owned by .3. Every non-codegen state passes; .1.6 closes without changing the 57/1/2 census."
evidence_update_2026_07_11_generated_baseline_admission: "FUTURE-PARITY-BACKLOG.3.1.3.3 admits the contract-v1 Perl and Rust generated-source baseline after focused proof and complete recurring Perl/Rust gates. Perl promotes to pass; Rust remains the sole partial solely because isolated generated compile/run proof covers eight of 105 manifest fixtures. The census remains 57 pass, one partial, and two gaps; .3.2.0 owns scalable Rust full-manifest classification."
evidence_update_2026_07_11_rust_full_manifest_classification: "FUTURE-PARITY-BACKLOG.3.2.0 adds a scalable staged classifier and passes all 105 generated Rust fixtures through interpreter-first emission, one isolated host compile, and 105 named tests in 184.46 seconds with zero failures. Census remains 57/1/2 until .3.2.1 zero-failure closeout and .3.2.2 recurring admission."
reverify: "perl tools/check_capability_conformance.pl && rg -n 'FUTURE-PARITY-BACKLOG.1.6.[0-6]' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`capability_conformance/manifest.json` is the current user-observable capability census. The checker validates the
schema, exact backend set, evidence paths, status vocabulary, unique ids, gap ownership, and explicit legacy/future
exclusions. After Dart full-pipeline trace admission, its 15 rows and 60 backend states classify 57 pass, one
partial, and two gaps.

The audit distinguishes implementation gaps from proof gaps:

- the 105-fixture interpreter corpus passes all four backends and is indexed against the 239-name current
  non-legacy ActionIR surface; `.1.6.1` closed that neutral proof;
- all four expose exact outward descriptors, aligned model identities, and one canonical function-record schema;
- all four expose structured runtime diagnostic attribution; Rust's full recurring/CLI gate and final admission
  are closed;
- Perl, Rust, Dart, and Julia expose the native file-oriented named-spec role and consume the exact 14/9/4 ordered-
  root contract directly; exact admission is closed under `.1.6.4`;
- Perl, Rust, Dart, and Julia propagate a native emitter through frontend/compiler/function-shell/staged/runtime
  phases; Dart's direct routed/quiet/failure proof closes `.1.6.5`;
- generated source remains top-level `.3`: Perl's baseline is admitted and passes; Rust's explicit full-manifest
  classification is 105/105 green but not yet a strict recurring admission gate; Dart/Julia have no emitter.

`.1.6.6` closes non-codegen capability parity after proving the matrix has no unowned partial/gap state. Active
`.3` owns every remaining generated-source state. Deprecated Perl plugins and not-yet-current general parse jobs,
semantic introspection/MCP, generic final-codeblock behavior, and Lua are explicit exclusions/future owners, not
omitted rows.

Related facts: [[user-observable-backend-cli-parity-contract]], [[native-in-memory-backend-contract]],
[[perl-native-spec-resolution]], [[dart-native-spec-resolution]], [[julia-native-spec-resolution]],
[[trace-cross-variant-capability-contract]], [[dart-generated-source-deferred]],
[[julia-generated-source-deferred]], [[rust-parity-followon-closed]], [[primary-cli-four-backend-matrix]].
