---
id: rust-trace-runtime-branch-events
title: Rust interpreted and generated-plan runtime traces include gap-aware child dispatch
answers:
  - "does Rust emit runtime trace events"
  - "what did TRACE-OBSERVABILITY.4.4 add"
  - "which Rust runtime trace namespaces exist"
  - "does Rust trace generated-plan runtime branches"
  - "does Rust trace mark and capture helper operations"
  - "can Rust claim trace parity after TRACE-OBSERVABILITY.4.4"
  - "does Rust trace gap-aware action-edge child dispatch"
  - "why was child_dispatch missing from Rust gap capture traces"
  - "what did TRACE-OBSERVABILITY.5.2 repair"
date: 2026-09-08
status: current
tags: [trace, observability, rust, parity, runtime, task-tree, mdbook]
evidence: "rust/linkedspec-runtime/src/{engine.rs,runtime.rs}; rust/linkedspec-runtime/tests/trace_controls.rs; docs/linkedspec-book/src/public-api/trace-api.md; docs/tasks/TRACE-OBSERVABILITY.md .4.4"
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test trace_controls"
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

At `.4.4` closeout Rust still did not claim trace parity. `TRACE-OBSERVABILITY.4.5` later closed the original
cross-variant proof and reusable future-variant checklist.

Corrective `.5.2` found a later regression introduced by Rust inter-match-gap support: interpreted and generated
action edges carrying a typed gap entry slot used parallel `execute_child_rule_with_entry_slot` seams created
after the original trace instrumentation. Those seams preserved accumulator and child-result semantics but omitted
the existing `child_dispatch` / `child_dispatch_result` pair. `.5.2` makes the normal child wrapper delegate to the
entry-slot seam in each executor and moves the unchanged event lifecycle into that single local owner. Both no-slot
and gap-aware entry therefore emit exactly one pair under their existing `rust_runtime:engine:*` or
`rust_runtime:generated_plan:*` namespace. At the .5.2 closeout, the then-current trace controls passed 11/11 with unchanged
traced/untraced results and restored the documented external trace capability claim.

## September 8 trace-consumer reading

`SESSION-STARTUP-READING.3.3.65` reconciles all 477 lines of
`rust/linkedspec-runtime/tests/trace_controls.rs`. The current source contains twelve
tests, including the later zero-regex-root target-selection control. It compares
quiet parse/validation/compilation/engine/generated-helper outputs, validates sink
setup, and checks enabled core/runtime/generated-plan and staged-dispatch events.
The emitted-source test checks exported trace entry-point text; it does not compile
an independent emitted module. Eleven-test results above remain historical; this
reading checkpoint does not claim a fresh execution of the twelve-test target.
