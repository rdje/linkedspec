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
evidence: "JULIA-BACKEND-PARITY.7.2 compares Julia's green native 99/99 interpreter path with the Rust source-emitter precedent and defers generated Julia source to FUTURE-PARITY-BACKLOG.3. ADR 0023 later clarifies that Rust's exported source_emitter makes equivalent capability mandatory for complete user-visible parity, while the 99/99 interpreter gate remains valid."
reverify: "rg -n 'JULIA-BACKEND-PARITY\.7\.2|FUTURE-PARITY-BACKLOG\.3|generated Julia source|emitter scaffold|family-plan|curated.*corpus|runtime-corpus-full' docs/tasks/JULIA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/overview/project-status.md ROADMAP.md ROADMAP_V2.md"
---

Generated Julia source does not exist as a current implementation surface and is not required for the accepted
99/99 interpreter-corpus claim. The native in-memory interpreter path satisfies ADR `0022` and passes the complete
checked-in corpus at 99/99 exact outputs.

`JULIA-BACKEND-PARITY.7.2` deliberately defers generation rather than adding an unverified string emitter during
closeout. Rust's generated-source work demonstrates the minimum credible proof architecture:

- a minimal emitter scaffold and compile/run harness;
- typed generated-family plan metadata;
- direct execution coverage for current structural families;
- a curated manifest-backed corpus subset that first passes the interpreter oracle.

`FUTURE-PARITY-BACKLOG.3` now owns generated-source breadth across Rust plus separate future Dart and Julia emitter
splits. Until a Julia-specific split independently satisfies those proof classes, `runtime-corpus-full` refers to
the native interpreter gate only. ADR `0023` classifies Rust's exported `source_emitter` as a user-observable
capability, so this deferral blocks complete Julia feature parity even though it does not weaken interpreter proof.

Related facts: [[user-observable-backend-cli-parity-contract]], [[julia-backend-interpreter-first-plan]], [[julia-mdbook-usage-status]],
[[julia-full-corpus-gate]], [[native-in-memory-backend-contract]], [[rust-source-emitter-lane-split]],
[[rust-generated-source-family-plan]], [[rust-generated-source-corpus-subset]],
[[dart-generated-source-deferred]].
