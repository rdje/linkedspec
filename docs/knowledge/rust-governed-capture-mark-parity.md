---
id: rust-governed-capture-mark-parity
title: Rust executes the governed anonymous/named capture fixtures and preserves symbolic mark arguments
answers:
  - "does Rust pass the exhaustive anonymous capture fixture"
  - "does Rust pass the exhaustive named mark fixture"
  - "how are bare mark names resolved in the Rust runtime"
  - "why did every Rust named mark collapse to the input end"
  - "does Rust AND blind-call return its ordered child values implicitly"
  - "which leaf closed Rust capture mark executable parity"
date: 2026-07-10
status: current
tags: [rust, capture, marks, blind-call, generated-plan, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.1; governed fixtures capability_capture_anonymous_surface.spec and capability_capture_named_surface.spec; Rust integration exact-value locks; generated source implicit AndBcode result lock; tools/run_rust_local.sh passes 137 library, 196 integration, 99 oracle, 3 source-emitter, 10 trace, and 61x2 CLI."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test future_parity_backlog_1_6_1_2_2_4_1 -- --nocapture && bash tools/run_rust_local.sh"
---

# Rust Governed Capture / Mark Parity

`FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.1` closes Rust execution of both governed capture sources. The anonymous
fixture covers stable and advancing slice/cursor/rest reads, line/column/position metadata, and resetting the
anonymous capture start from a named mark. The named fixture covers current/input-boundary/copied marks, stable
and advancing from/rest/cursor reads, two-mark reads, and two-mark advancing text/length reads.

Bare mark arguments are symbolic slots. For example, `mark_here(origin)` names the mark `origin`; it does not read
a scalar variable named `origin`. Rust resolves those bare identifiers from the raw typed argument AST and falls
back to the evaluated value for quoted or dynamic forms. Before this repair, undefined bare variables all became
the empty string, so every mark shared one key and the final `mark_here(cursor_end)` overwrote the earlier origin.

The fixtures also lock their real wrapper shape: `Top::AND` blind-calls `Value`. A non-repeated `AND` blind-call
rule with no explicit parent return surfaces the ordered array of child return values. Rust now preserves that
contract in both interpreted execution and generated-plan execution; an explicit parent return still wins.
