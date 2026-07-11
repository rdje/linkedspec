---
id: julia-generated-source-deferred
title: Generated Julia source is deferred to the future split source-emitter lane
answers:
  - does Julia generated source exist now
  - what did JULIA-BACKEND-PARITY.7.2 decide
  - why was generated Julia source deferred
  - what must a future Julia source emitter prove
  - is generated Julia source required for Julia parity
  - what task owns future generated Julia source
date: 2026-07-10
status: current
tags: [julia, codegen, source-emitter, corpus, embedding, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.2 compares Julia's then-green native 99/99 interpreter path with the Rust source-emitter precedent and defers generated Julia source to FUTURE-PARITY-BACKLOG.3. ADR 0023 later makes equivalent capability mandatory. FUTURE-PARITY-BACKLOG.3.0 reverified no emitter in julia/src or julia/test after the corpus reached 105 and split Julia implementation into .3.4.1 scaffold/harness, .3.4.2 family plan/direct execution, and .3.4.3 manifest admission."
reverify: "rg -n 'JULIA-BACKEND-PARITY\.7\.2|FUTURE-PARITY-BACKLOG\.3|generated Julia source|emitter scaffold|family-plan|curated.*corpus|runtime-corpus-primary-cli' docs/tasks/JULIA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/overview/project-status.md ROADMAP.md ROADMAP_V2.md"
---

Generated Julia source does not exist as a current implementation surface and was not required for the accepted
interpreter-corpus milestone. The native in-memory interpreter path satisfies ADR `0022` and now passes the complete
checked-in corpus at 105/105 exact outputs.

`JULIA-BACKEND-PARITY.7.2` deliberately defers generation rather than adding an unverified string emitter during
closeout. Rust's generated-source work demonstrates the minimum credible proof architecture:

- a minimal emitter scaffold and compile/run harness;
- typed generated-family plan metadata;
- direct execution coverage for current structural families;
- a curated manifest-backed corpus subset that first passes the interpreter oracle.

`FUTURE-PARITY-BACKLOG.3.4` now owns Julia's scaffold, direct family execution, and manifest proof. The later
`runtime-corpus-primary-cli` status adds a local CLI gate but still does not include generated
source. ADR `0023` classifies Rust's exported `source_emitter` as a user-observable
capability, so this deferral blocks complete Julia feature parity even though it does not weaken interpreter proof.

Related facts: [[user-observable-backend-cli-parity-contract]], [[julia-backend-interpreter-first-plan]], [[julia-mdbook-usage-status]],
[[julia-full-corpus-gate]], [[native-in-memory-backend-contract]], [[rust-source-emitter-lane-split]],
[[rust-generated-source-family-plan]], [[rust-generated-source-corpus-subset]],
[[dart-generated-source-deferred]], [[julia-scoped-parity-no-drift]].
