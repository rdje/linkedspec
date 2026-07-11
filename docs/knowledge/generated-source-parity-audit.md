---
id: generated-source-parity-audit
title: Generated-source parity is split across a neutral contract, Rust breadth, Dart, Julia, and final admission
answers:
  - "what is the current generated-source parity boundary"
  - "how many Rust corpus fixtures compile and run as generated source"
  - "what does FUTURE-PARITY-BACKLOG.3 implement next"
  - "does Rust generated source cover all 105 fixtures"
  - "do Dart and Julia have source emitters"
  - "must generated source bytes be identical across backends"
date: 2026-07-11
status: current
tags: [codegen, generated-source, rust, dart, julia, parity, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.3.0 audited capability_conformance/manifest.json, Perl/Rust emitter source and Rust compile/run tests. It initially inherited the census's Perl pass classification. FUTURE-PARITY-BACKLOG.3.1.0 then added the missing independent Perl source execution probe and proved captured source loses LinkedRE dependency alternative indexes, correcting Perl to partial. Rust publicly exports emit_rust_source, emits source format v1 with a serialized CompiledSpec and typed GeneratedRuleFamily plan, validates that plan, directly executes all current structural families, and compiles/runs emitted modules in isolated temporary crates. Its manifest-backed generated-source proof names exactly eight fixtures while the interpreter manifest contains 105. Dart and Julia have no source emitter. ADR 0023 permits idiomatic host APIs, so the neutral contract requires capability/result/diagnostic/source-identity equivalence rather than byte-identical host-language source. FUTURE-PARITY-BACKLOG.3 is split into .3.1 contract/Perl correction, .3.2 Rust full-manifest breadth, .3.3 Dart, .3.4 Julia, and .3.5 final admission."
evidence_update_2026_07_11_perl_repair: "FUTURE-PARITY-BACKLOG.3.1.2 adds public and legacy-identical contract-v1 emission, canonical LinkedRE::oredRE reconstruction, independent exact execution, metadata/identity/trace/errors, and plan validation. Perl remains partial only until .3.1.3 admission; the dependency-index defect is fixed."
evidence_update_2026_07_11_rust_contract_audit: "FUTURE-PARITY-BACKLOG.3.1.3.0 preserves Rust's green all-family/eight-case baseline but finds its pre-v1 API lacks identity/contract markers, structured generated-source errors, unknown-family rejection, and neutral generated trace roles. Bounded .3.1.3.1-.3 alignment/admission leaves now precede .3.2 breadth."
evidence_update_2026_07_11_rust_metadata_errors: "FUTURE-PARITY-BACKLOG.3.1.3.1 adds Rust v1 identity/metadata/typed errors plus compatibility adapters; focused 4/4 and the complete Rust gate pass. Exact neutral plan/trace .3.1.3.2 and admission .3 remain before breadth."
evidence_update_2026_07_11_rust_plan_trace: "FUTURE-PARITY-BACKLOG.3.1.3.2 adds exact neutral plan/four rejection roles, direct v1 result, and three portable trace roles while preserving legacy envelope/trace. Focused 5/5 + 10/10 and the clean complete Rust gate pass; explicit admission .3 remains before breadth."
evidence_update_2026_07_11_baseline_admission: "FUTURE-PARITY-BACKLOG.3.1.3.3 admits the Perl/Rust contract-v1 baseline after focused and complete recurring gates. Perl promotes from partial to pass. Rust stays partial solely because generated compile/run proof names eight of 105 interpreter-manifest fixtures. The census stays 57/1/2 and active .3.2.0 owns a scalable full-manifest classifier before expansion."
evidence_update_2026_07_11_full_manifest_classification: "FUTURE-PARITY-BACKLOG.3.2.0 replaces a measured slow per-case prototype with one isolated 105-module crate and exact staged accounting. The explicit run passes all 105 fixtures in 184.46 seconds with zero failures. No repair mechanism exists; .3.2.1-.2 own zero-failure closeout and recurring admission."
evidence_update_2026_07_11_zero_failure_closeout: "FUTURE-PARITY-BACKLOG.3.2.1 records every requested failure category as empty and closes without speculative repairs. Strict recurring admission .3.2.2 is the only remaining Rust breadth step."
evidence_update_2026_07_11_rust_admission: "FUTURE-PARITY-BACKLOG.3.2.2 removes ignore/conditional bypasses, extends contract checking to enforce the exact all-105 test, passes independent and complete Rust/61x2 CLI gates, promotes Rust to pass, and closes .3.2 at census 58/0/2."
evidence_update_2026_07_11_dart_admission: "FUTURE-PARITY-BACKLOG.3.3.1-.3 add deterministic Dart v1 emission, exact ten-family direct execution/four rejections/trace roles, and contract-sourced interpreter-first 8/105 isolated host proof. Complete 181/61x2/105 gates pass; Dart promotes and .3.3 closes at census 59/0/1."
evidence_update_2026_07_11_julia_admission: "FUTURE-PARITY-BACKLOG.3.4.1-.3 add deterministic Unicode-safe Julia v1 emission, exact ten-family family-authoritative execution/four rejections/trace roles, and contract-sourced interpreter-first 8/105 namespaced host proof. Complete 1,168/61x2/105 gates pass; Julia promotes and .3.4 closes at census 60/0/0."
evidence_update_2026_07_11_final_closeout: "FUTURE-PARITY-BACKLOG.3.5 rechecks contract/capability 60/0/0, focused Perl 69 assertions, Rust 5/5, Dart 6/6, and Julia 58/58 against adjacent complete backend gates, aligns every durable/public surface, removes over 1.23 GB of reproducible caches, closes generated-source .3, and activates Lua plan .1.3 without behavior changes."
reverify: "rg -n 'emit_rust_source|GENERATED_SOURCE_FORMAT|GeneratedRuleFamily|GENERATED_SOURCE_CORPUS_SUBSET|generated_rust_source_matches_manifest_backed_corpus_subset' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs && rg -n -i 'emit_.*source|source_emitter|generated.*source' dart/lib dart/test julia/src julia/test || true && perl tools/check_capability_conformance.pl"
---

# Generated-Source Parity Audit

The active capability census has one residual mechanism, not three unrelated
features: generated host-language parser source. Its backend states differ:

- Perl's contract-v1 source reconstruction/API proof is admitted and passes.
- Rust has a public versioned emitter, a validated typed family plan, direct
  execution for all current structural families, and an isolated compile/run
  harness.
- Rust v1 source identity, metadata, errors, exact neutral plan/rejections,
  direct result, portable trace roles, and compatibility adapters are admitted.
- Rust's focused subset still names eight fixtures, while its strict recurring
  full-manifest classifier passes 105/105 and is admitted.
- Dart and Julia have admitted emitters/direct executors and exact accepted-subset proof.

The implementation order is deliberately contract-first:

1. define and admit one executable backend-neutral contract with repaired Perl
   and aligned Rust baselines (complete);
2. classify Rust over the full manifest, close the empty repair inventory, and
   admit a strict recurring 105/105 gate (complete);
3. add and admit Dart's scaffold, direct family execution, and corpus proof (complete);
4. add Julia's equivalent capability and proof (complete);
5. admit all four implemented backends together (complete `.3.5`).

The generated source is necessarily host-language source, so Rust, Dart,
Julia, and Perl bytes are not expected to be identical. ADR `0023` instead
requires equivalent public operations, accepted inputs, generated execution,
results, diagnostics, tracing, and source identity through idiomatic host APIs.
The 105-case interpreter corpus remains the primary correctness oracle.

Related facts: [[rust-generated-source-corpus-subset]], [[rust-source-emitter-lane-split]],
[[dart-generated-source-deferred]], [[julia-generated-source-scaffold]],
[[user-observable-backend-cli-parity-contract]], [[perl-generated-source-capture-not-standalone]].
