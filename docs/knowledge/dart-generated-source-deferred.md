---
id: dart-generated-source-deferred
title: Generated Dart source is deferred to a future split source-emitter lane
answers:
  - "does Dart generated source exist now"
  - "what did DART-BACKEND-PARITY.7.2 decide"
  - "why was generated Dart source deferred"
  - "what must a future Dart source emitter prove"
  - "is generated Dart source required for Dart parity"
date: 2026-07-09
status: current
tags: [dart, codegen, source-emitter, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.2 compares the Dart lane to the Rust source-emitter precedent. Rust generated-source proof required a split lane: emitter scaffold/compile-run harness, generated family-plan metadata, direct structural-family execution, and curated manifest-backed corpus subset. Dart already has the interpreter-first 99/99 corpus conformance gate, so generated Dart source is deferred instead of implemented as a one-slice add-on."
reverify: "rg -n 'DART-BACKEND-PARITY\\.7\\.2|source-emitter lane|generated family-plan|99/99 corpus|Dart-specific CLI productization' docs/tasks/DART-BACKEND-PARITY.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/overview/project-status.md ROADMAP.md ROADMAP_V2.md"
---

Generated Dart source does not exist as a current implementation surface. It is
not required for the current Dart parity claim because the Dart interpreter path
passes the full checked-in 99-fixture corpus.

`DART-BACKEND-PARITY.7.2` deliberately defers generated Dart source to a future
split source-emitter lane. A credible future lane must at least own:

- a minimal Dart emitter scaffold plus compile/run harness;
- generated family-plan metadata equivalent to the Rust source-emitter proof;
- direct execution coverage for the current structural families;
- a curated manifest-backed corpus subset proof that first passes the interpreter oracle.

The immediate PNT frontier after this decision is `DART-BACKEND-PARITY.7.4` for
Dart-specific CLI productization.

Related facts: [[dart-backend-interpreter-first-plan]], [[rust-source-emitter-lane-split]],
[[rust-generated-source-corpus-subset]], [[dart-mdbook-usage-status]].
