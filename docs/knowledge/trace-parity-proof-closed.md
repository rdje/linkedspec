---
id: trace-parity-proof-closed
title: TRACE-OBSERVABILITY.4.5 closes cross-variant trace parity proof
answers:
  - "can Rust claim trace parity"
  - "what did TRACE-OBSERVABILITY.4.5 prove"
  - "what trace capabilities must future variants implement"
  - "is trace parity variant agnostic"
  - "where is the future variant trace checklist"
date: 2026-07-04
status: current
tags: [trace, parity, rust, perl, variants, mdbook, task-tree]
evidence: "docs/tasks/TRACE-OBSERVABILITY.md .4.5; docs/linkedspec-book/src/public-api/trace-api.md future variant checklist; rust/linkedspec-core/src/trace.rs; rust/linkedspec-runtime/tests/trace_controls.rs; Perl trace regression suite"
reverify: "perl bin/linkedspec --help && prove -v -Iperl t/trace_cli.t t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t t/trace_ruleir_planning.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t && RUSTFLAGS=-Awarnings cargo test --manifest-path rust/Cargo.toml -p linkedspec-core trace && RUSTFLAGS=-Awarnings cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls"
---

`TRACE-OBSERVABILITY.4.5` closes the cross-variant trace parity proof.

Rust can claim trace parity for the mdBook-documented external capability contract. The claim is behavioral, not a
promise to reuse Perl package names or every Perl-internal event namespace.

The parity contract requires ordered levels, normal-entrypoint controls, stdout/routed-file/mirror sinks,
routed-file reset/truncate behavior, default quiet output, structured compile/parser/runtime scope events,
decision/branch events including runtime dispatch branches, mark/capture/source-boundary events where implemented,
and dump/log diagnostics.

Future variants must satisfy the checklist in `docs/linkedspec-book/src/public-api/trace-api.md` and record
task-tree plus Knowledge Map proof before claiming trace parity.
