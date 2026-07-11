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
evidence: "DART-BACKEND-PARITY.7.2 compares the Dart lane to the Rust source-emitter precedent and defers codegen after the then-current 99/99 interpreter milestone. ADR 0023 later classifies Rust's exported source_emitter as a public capability. FUTURE-PARITY-BACKLOG.3.0 reverified no emitter in dart/lib or dart/test after the corpus reached 105 and split Dart implementation into .3.3.1 scaffold/harness, .3.3.2 family plan/direct execution, and .3.3.3 manifest admission."
reverify: "rg -n 'DART-BACKEND-PARITY\\.7\\.2|FUTURE-PARITY-BACKLOG\\.3|99/99|generated.*source|complete.*parity' docs/tasks/DART-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/decisions/0023-user-observable-backend-and-cli-parity.md docs/linkedspec-book/src/appendix/backend-handoff.md ROADMAP.md ROADMAP_V2.md"
---

Generated Dart source does not exist as a current implementation surface. It was
not required for the scoped interpreter-corpus claim, now green at 105/105. ADR `0023` makes it
required for complete public capability parity because Rust exports source emission.

`DART-BACKEND-PARITY.7.2` deliberately deferred generated Dart source. The active
implementation is now split under `FUTURE-PARITY-BACKLOG.3.3` into:

- a minimal Dart emitter scaffold plus compile/run harness;
- generated family-plan metadata equivalent to the Rust source-emitter proof;
- direct execution coverage for the current structural families;
- a curated manifest-backed corpus subset proof that first passes the interpreter oracle.

`DART-BACKEND-PARITY.7.5` closed the scoped interpreter-first Dart milestone
without changing this deferral. There is no active Dart frontier in the closed
task tree; generated-source proof remains future work under `FUTURE-PARITY-BACKLOG.3`
and blocks a complete Dart-parity claim.

Related facts: [[user-observable-backend-cli-parity-contract]], [[dart-backend-interpreter-first-plan]], [[rust-source-emitter-lane-split]],
[[rust-generated-source-corpus-subset]], [[dart-mdbook-usage-status]].
