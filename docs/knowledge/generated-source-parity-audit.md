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
reverify: "rg -n 'emit_rust_source|GENERATED_SOURCE_FORMAT|GeneratedRuleFamily|GENERATED_SOURCE_CORPUS_SUBSET|generated_rust_source_matches_manifest_backed_corpus_subset' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs && rg -n -i 'emit_.*source|source_emitter|generated.*source' dart/lib dart/test julia/src julia/test || true && perl tools/check_capability_conformance.pl"
---

# Generated-Source Parity Audit

The active capability census has one residual mechanism, not three unrelated
features: generated host-language parser source. Its backend states differ:

- Perl's normal compiler generates and executes handlers, but independently
  recompiled captured source loses dependency-regex indexes and is partial.
- Rust has a public versioned emitter, a validated typed family plan, direct
  execution for all current structural families, and an isolated compile/run
  harness.
- Rust's manifest proof still names only eight fixtures, while the interpreter
  corpus now contains 105.
- Dart and Julia have no source-emitter implementation.

The implementation order is deliberately contract-first:

1. define one executable backend-neutral capability contract and repair/admit
   Perl's independently compiled source;
2. classify and expand Rust to full-manifest generated proof;
3. add Dart's scaffold, direct family execution, and corpus proof;
4. add Julia's equivalent capability and proof;
5. admit all four implemented backends together.

The generated source is necessarily host-language source, so Rust, Dart,
Julia, and Perl bytes are not expected to be identical. ADR `0023` instead
requires equivalent public operations, accepted inputs, generated execution,
results, diagnostics, tracing, and source identity through idiomatic host APIs.
The 105-case interpreter corpus remains the primary correctness oracle.

Related facts: [[rust-generated-source-corpus-subset]], [[rust-source-emitter-lane-split]],
[[dart-generated-source-deferred]], [[julia-generated-source-deferred]],
[[user-observable-backend-cli-parity-contract]], [[perl-generated-source-capture-not-standalone]].
