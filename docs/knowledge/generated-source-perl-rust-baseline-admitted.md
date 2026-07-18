---
id: generated-source-perl-rust-baseline-admitted
title: Perl and Rust generated-source capability is admitted and both now emit v2
answers:
  - "is the Perl generated-source baseline admitted"
  - "is the Rust generated-source baseline admitted"
  - "why is Rust generated source still partial"
  - "what is the generated-source capability census after admission"
  - "what does FUTURE-PARITY-BACKLOG.3.2.0 own"
date: 2026-07-18
status: current
tags: [generated-source, admission, perl, rust, parity, census]
evidence: "FUTURE-PARITY-BACKLOG.3.1.3.3 passes the focused 69-assertion Perl contract, focused Rust source_emitter 5/5, canonical Perl gate with Phase 0 1..1030 and 61x2 CLI, and complete Rust 137/105/196/5/5/5/10 plus 61x2 CLI gate. Perl promotes to pass. Rust's contract-v1 baseline is admitted but remains partial solely because isolated generated compile/run proof covers eight of the 105 interpreter-manifest fixtures. The capability census is 57 pass, one partial, and two gaps. Active .3.2.0 owns a scalable all-105 classifier before breadth expansion."
evidence_update_2026_07_11_full_manifest: "FUTURE-PARITY-BACKLOG.3.2.0 completes the scalable classifier 105/105 with zero failures. Rust remains partial pending .3.2.1 zero-failure closeout and .3.2.2 strict recurring admission, not semantic repair."
evidence_update_2026_07_11_zero_failure_closeout: "FUTURE-PARITY-BACKLOG.3.2.1 closes the empty repair inventory without behavior code. Rust remains partial only for strict recurring admission .3.2.2."
evidence_update_2026_07_11_rust_admission: "FUTURE-PARITY-BACKLOG.3.2.2 completes strict recurring all-105 admission and promotes Rust to pass at census 58/0/2."
evidence_update_2026_07_11_dart_admission: "FUTURE-PARITY-BACKLOG.3.3.3 admits Dart's exact contract-sourced eight-case proof and promotes it to pass at census 59/0/1; Julia is the sole remaining gap."
evidence_update_2026_07_18_cursor_v2: "FUTURE-PARITY-BACKLOG.9.1.3.4 and .9.1.4.5 migrate new Perl and Rust artifacts to linkedspec-generated-source-v2 / format 2 with minimal label/family plans and derived rule-local cursor policy. Capability admission and 105-case Rust breadth remain intact."
reverify: "perl tools/check_generated_source_contract.pl && perl tools/check_capability_conformance.pl && PERL5LIB= prove -Iperl t/generated_source_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Perl/Rust Generated-Source Baseline Admission

Admission distinguishes a complete baseline semantic contract from exhaustive
corpus breadth. Perl and Rust both satisfy the source identity, metadata,
validation, result, trace, diagnostic, and structural-family roles. Their current
artifacts are contract v2; the shared capability ledger remains versioned
independently from the cursor migration.

Perl passes the capability row. Rust's explicit staged classifier now proves
all 105 fixtures, zero-failure closeout is complete, and strict recurring
admission passes. Perl and Rust both pass; later `.3.3.3` also admits Dart, so
Julia is the sole remaining gap.

`FUTURE-PARITY-BACKLOG.3.2.0` completes all-105 classification, `.3.2.1`
closes the empty repair inventory, and `.3.2.2` completes recurring admission.

Related facts: [[generated-source-contract-v1]],
[[generated-source-parity-audit]], [[perl-generated-source-contract-v1]],
[[rust-generated-source-contract-v1-gap]], [[backend-capability-census]].
Current cursor reconstruction: [[perl-generated-source-contract-v2]] and
[[rust-generated-source-v2-rule-local-cursor]].
