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
evidence_update_2026_07_11_closeout: "FUTURE-PARITY-BACKLOG.3.2.1 explicitly records the source-emitter, generated-plan, generated-executor, dependency/build, and fixture-contract failure inventories as empty and closes without behavior code. Only strict recurring admission .3.2.2 remains before promotion."
evidence_update_2026_07_11_admission: "FUTURE-PARITY-BACKLOG.3.2.2 removes the ignore and conditional strictness bypass, adds contract path/count/no-ignore/unconditional-failure checks, passes independently 105/105 in 186.42 seconds and inside the complete Rust gate in 189.42 seconds, and promotes Rust generated source to pass at census 58/0/2."
evidence_update_2026_07_18_v2: "FUTURE-PARITY-BACKLOG.9.1.4.5 migrates the same unconditional exact-105 classifier to emit_rust_source_v2. It continues to require direct value, minimal neutral plan validation, compatibility accumulator result, one host compile, and serial host execution for every fixture."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test generated_source_full_manifest_classifier -- --nocapture && rg -n 'FULL_MANIFEST_CASE_COUNT|CLASSIFY SUMMARY|host_compile|host_run|emit_rust_source_v2' rust/linkedspec-runtime/tests/generated_source_full_manifest_classifier.rs"
---

# Rust Generated-Source Full-Manifest Classification

The breadth gap was a proof gap, not a discovered semantic gap. All 105 current
interpreter fixtures also pass independently compiled generated Rust source.
The current run emits contract-v2 modules; the breadth architecture is otherwise
unchanged.

The classifier retains exact per-case preparation and diagnostics while
avoiding 105 dependency builds. It emits one module and named test per case
inside one caller-owned temporary crate, compiles once, then runs all tests
serially. A case is marked pass only after its direct value, embedded neutral
plan, and compatibility accumulator projection all match the oracle.

The test is now an unconditional ordinary runtime-package test. Contract
checking prevents it from becoming ignored or conditionally strict. Independent
and complete admission gates pass, so Rust generated source is a current pass.

Related facts: [[rust-generated-source-corpus-subset]],
[[generated-source-parity-audit]], [[generated-source-perl-rust-baseline-admitted]],
[[rust-generated-source-contract-v1-gap]], and
[[rust-generated-source-v2-rule-local-cursor]].
