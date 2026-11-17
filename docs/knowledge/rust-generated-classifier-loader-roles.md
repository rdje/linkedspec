---
id: rust-generated-classifier-loader-roles
title: Generated Rust classifier inputs, child templates and trace roles are separate
answers:
  - "which input files does the generated Rust full manifest classifier select"
  - "are generated Rust child test templates parent tests"
  - "does the Count trace test launch Cargo"
  - "how many Count fixture rows feed the generated classifier source"
  - "where is generated Rust loader qualification retained"
date: 2026-11-17
status: focused source qualification; runtime/native/semantic closure remains separately owned
tags: [rust, loaders, corpus, generated-source, custody, classifier]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.2; docs/checkpoints/rust-generated-loader-qualification-2026-11-17/ retains original capture exit1,442 original bodies/modes, separately scoped reader,320 input bindings/319 targets,321 older identity matches and twelve controls. No Cargo/SDK execution."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/rust-generated-loader-qualification-2026-11-17/review_qualified.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/rust-generated-loader-qualification-2026-11-17/review_qualified.py --current"
---

The manifest selects105 potential case directories, with three runtime UTF-8 inputs
per case. Three direct `include_str!` sites reference two Count JSON fixtures;
the compiler parser also embeds the function grammar. This is320 bindings to319
distinct targets. Manifest `generated_by` metadata supplies no extra file edge.
Potential inputs do not prove successful reads, preparation or generated writes.

The source contains three parent tests and two emitted child-test templates.
Full-manifest preparation writes only its successful subset into an isolated crate.
The focused Count parent combines16+1 fixture rows, writes generated modules and
requires its child exit to succeed. The native trace parent selects two named rows,
writes Engine trace output and reads it back; it launches no Cargo child, although
the shared temporary-project constructor still writes a Cargo manifest.

The shared Cargo helper requests offline/quiet execution, generated-project cwd and
its own target directory. Three call templates belong to two parent tests. Actual
Cargo/dependency/cache identity, temporary-root routing, historical manifest anchor
and embedded binary bytes are unobserved here. Full-manifest run markers still do
not require child success: [[rust-generated-classifier-child-status-gap]] owns the
known defect under SESSION-STARTUP-READING.77. Historical admission remains dated.

All321 distinct consumer/parser/target identities match the older qualified-direct
root metadata. Nine victim-bearing ledger controls and three independent dated
grammar inverses pass. The broader independent semantic/transitive graph remains
remaining qualification3, with native/per-read/source-origin/physical closure4.2.

The first reader rejects duplicate unqualified `new` methods. Its complete failure
and inputs remain unchanged. Five exact substitutions qualify method lookup by
implementation scope, preserving `CaseFailure::new` at45 and `TempProject::new`
at65. Default recovery is historical; `--current` also checks original input bytes
and modes against this dated epoch. Neither command starts Cargo or a writer.
