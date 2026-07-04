---
id: rust-generated-bcode-direct
title: Rust generated source directly executes AND and OR bcode families
answers:
  - "does generated Rust source execute bcode directly"
  - "which leaf added direct bcode generated execution"
  - "how does Rust generated OR bcode dispatch work"
  - "how does Rust generated AND bcode dispatch work"
  - "what remains after direct bcode generated execution"
date: 2026-07-04
status: accepted
tags: [rust, codegen, source-emitter, bcode, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.3.4 extends GeneratedPlanExecutor direct execution to GeneratedRuleFamily::AndBcode and GeneratedRuleFamily::OrBcode. Direct bcode execution preserves the interpreter's recursion guard, caller return save/restore, entry/local match save/restore, lifecycle preamble, child-return-to-retv contract, attached blind-edge code/fluent tail execution, parent E behavior, and OR no-match LX behavior. The interpreted bcode path now uses the same blind-edge tail helper: non-OR bcode visits every blind child in order, while explicit OR bcode stops after the first truthy child return and fires LX when no child matches. The focused source_emitter matrix proves ordered AND child-return collection, OR first-match behavior on input that would otherwise continue to a later child, and OR no-match LX. RUST-PARITY.8.4 later added direct repeated bcode families RepBcode and RepAndBcode."
reverify: "rg -n 'AndBcode|OrBcode|execute_direct_bcode_rule|execute_bcode_entry_tail|RUST-PARITY\\.8\\.3\\.4' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated Bcode Direct Execution

`RUST-PARITY.8.3.4` makes the generated-plan executor run these additional
families directly:

- `GeneratedRuleFamily::AndBcode`
- `GeneratedRuleFamily::OrBcode`

Direct bcode execution keeps the same child-return contract as the interpreter:
each blind child return is assigned to parent `retv`, then any attached
blind-edge code and fluent calls run before the parent `E` block reads the
result.

Non-OR bcode dispatch visits every blind child in order. Explicit OR bcode
dispatch stops after the first truthy child return, so later blind children do
not overwrite the selected result. If no OR child returns a truthy value, the
rule runs `LX` before the parent `E` block.

`RUST-PARITY.8.3.5` closed the non-repetition generated-family matrix.
`RUST-PARITY.8.4` later added direct repeated bcode families:
`GeneratedRuleFamily::RepBcode` and `GeneratedRuleFamily::RepAndBcode`.
