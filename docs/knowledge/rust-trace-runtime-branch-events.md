---
id: rust-trace-runtime-branch-events
title: TRACE-OBSERVABILITY.4.4 adds Rust interpreted and generated-plan runtime trace events
answers:
  - "does Rust emit runtime trace events"
  - "what did TRACE-OBSERVABILITY.4.4 add"
  - "which Rust runtime trace namespaces exist"
  - "does Rust trace generated-plan runtime branches"
  - "does Rust trace mark and capture helper operations"
  - "can Rust claim trace parity after TRACE-OBSERVABILITY.4.4"
date: 2026-07-04
status: current
tags: [trace, observability, rust, parity, runtime, task-tree, mdbook]
evidence: "rust/linkedspec-runtime/src/{engine.rs,runtime.rs}; rust/linkedspec-runtime/tests/trace_controls.rs; docs/linkedspec-book/src/public-api/trace-api.md; docs/tasks/TRACE-OBSERVABILITY.md .4.4"
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls"
---

`TRACE-OBSERVABILITY.4.4` adds Rust runtime trace events while preserving default-quiet entrypoints and traced/
untraced output equality.

Interpreted `Engine::execute_with_trace(...)` now emits `rust_runtime:engine:*` events for top-rule selection,
rule entry/exit, recursion cutoffs, child and passive-terminal dispatch, regex match/no-match, acode/bcode dispatch,
AND-sequence slots, lifecycle block execution/result, statement-form `if`/`switch`, lazy helper dispatch,
helper `call(child)`, and mark/capture helper operations.

Generated-plan traced execution now emits `rust_runtime:generated_plan:*` events for top-rule selection,
generated family dispatch, direct acode/bcode rule scopes, child dispatch/results, recursion cutoffs, regex
match/no-match, acode/bcode dispatch, and AND-sequence slots. Lifecycle and mark/capture helper events still use
the shared `rust_runtime:engine:*` namespaces because generated-plan execution reuses the same runtime block/helper
owners.

Rust still does not claim trace parity after `.4.4`. `TRACE-OBSERVABILITY.4.5` remains the cross-variant parity
proof and reusable future-variant checklist.
