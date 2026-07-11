---
id: rust-generated-source-full-manifest-classification
title: Rust generated source passes an explicit staged classifier over all 105 fixtures
answers:
  - "does Rust generated source pass all 105 fixtures"
  - "what did FUTURE-PARITY-BACKLOG.3.2.0 find"
  - "are Rust generated-source repairs required after full-manifest classification"
  - "how does the scalable Rust generated-source classifier work"
  - "why is Rust generated source still partial after 105 cases pass"
date: 2026-07-11
status: current
tags: [rust, generated-source, classifier, corpus, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.3.2.0 adds rust/linkedspec-runtime/tests/generated_source_full_manifest_classifier.rs. It checks exact 105-case manifest accounting, prepares every case through strict-UTF-8 read, parse, validate, compile, legacy/direct interpreter oracle, and emit_rust_source_v1, writes separate generated modules/tests into one isolated temporary Cargo crate, then performs one host compile and one serial host run. An initial per-case Cargo prototype was stopped after eight green cases at about ten seconds/case. The scalable run completes in 184.46 seconds with CLASSIFY SUMMARY total=105 pass=105 fail=0. No source-emitter, plan, executor, build, or fixture-contract repair mechanism exists. Rust remains partial until .3.2.1 zero-failure closeout and .3.2.2 strict recurring-gate admission."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test generated_source_full_manifest_classifier -- --ignored --nocapture && rg -n 'FULL_MANIFEST_CASE_COUNT|CLASSIFY SUMMARY|host_compile|host_run' rust/linkedspec-runtime/tests/generated_source_full_manifest_classifier.rs"
---

# Rust Generated-Source Full-Manifest Classification

The breadth gap was a proof gap, not a discovered semantic gap. All 105 current
interpreter fixtures also pass independently compiled generated Rust source.

The classifier retains exact per-case preparation and diagnostics while
avoiding 105 dependency builds. It emits one module and named test per case
inside one caller-owned temporary crate, compiles once, then runs all tests
serially. A case is marked pass only after its direct value, embedded neutral
plan, and compatibility accumulator projection all match the oracle.

The test remains explicitly invoked during classification. Rust's capability
state therefore stays partial until the zero-failure classification is closed
and the proof becomes a strict recurring admission gate.

Related facts: [[rust-generated-source-corpus-subset]],
[[generated-source-parity-audit]], [[generated-source-perl-rust-baseline-admitted]],
[[rust-generated-source-contract-v1-gap]].
