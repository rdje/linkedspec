---
id: rust-runtime-embedded-help-input
title: Rust runtime builds require the embedded primary-command help template
answers:
  - "why does a private Rust Engine build need cli_conformance help stdout"
  - "which own non-Rust artifact does primary_cli include at compile time"
  - "why did Hash-helper private inverse exit101 without test frames"
  - "is Cargo exit101 sufficient evidence of a semantic failing test"
  - "must Rust runtime input captures include the primary help template"
  - "which task owns historical Rust compile-time help input custody"
date: 2026-11-07
status: qualified77.2 epochs capture help before build; historical custody4.2 separate
tags: [rust, custody, inputs, compile, help, verification]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.77.2; original private-inverse/private-restored raw compiler failures have zero normal frames and identify primary_cli.rs:21 include_str of cli_conformance/cases/help/stdout.txt; control-failure-event.json distinguishes actual inner channels from outer tool-result transcription."
reverify:
  - "rg -n 'const HELP_TEMPLATE|include_str!' rust/linkedspec-runtime/src/primary_cli.rs"
  - "bash tools/run_python_project_data.sh docs/checkpoints/hash-value-result-guard-rust-2026-11-07/review_qualified.py"
---

The ordinary linkedspec-runtime library compiles primary_cli even when a consumer
uses only Engine. primary_cli.rs embeds the repository-owned
cli_conformance/cases/help/stdout.txt through include_str!. A private copy of own
Rust plus grammar/fixtures is therefore insufficient: retain/copy this actual
help artifact, with bytes and mode before Cargo compilation. No dependency
implementation inspection is needed to establish this own source edge.

The first77.2 private source images both stop at that missing file before any
normal executes. Their exit101 is compiler failure, not the thirteen semantic
failures established by the actual public baseline. The original producer's
exit-only acceptance incorrectly printed inverse completion; the restored path
rejects the same status. Keep both raw failures and original instruments. The
qualified producer requires89 distinct observation frames and actual76/13 or
89/0 test counts, in addition to command status and preserved inputs.

Original public four-route/ordinary runs have actual semantic observations, but
their first root archives omit this help input. A later Git lookup does not make
those first-use archives complete. Qualified old/current private images capture
the actual help file before build and use one stable own-Rust path; canonical
qualified direct/format acquisitions include it too. Earlier missing edges and
complete native/cache/transitive/toolchain custody remain23.4.2/SESSION5-owned.
Qualified ordinary old/current images now have actual76PASS/13FAIL and89PASS
counts with89 frames. No full custody or semantic claim follows from compilation
status alone.

Related: [[rust-hash-value-result-guards]].
