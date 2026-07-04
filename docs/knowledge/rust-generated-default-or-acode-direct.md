---
id: rust-generated-default-or-acode-direct
title: Rust generated source directly executes default and OR acode families
answers:
  - "which Rust generated families execute directly"
  - "does generated Rust source execute directly yet"
  - "what did RUST-PARITY.8.3.2 add"
  - "what remains after direct default OR acode generation"
  - "which leaf owned direct AND acode generated execution"
date: 2026-07-04
status: accepted
tags: [rust, codegen, source-emitter, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.3.2 added Engine::execute_generated_with_plan and the runtime-internal GeneratedPlanExecutor. execute_generated_parser validates GENERATED_RULES and calls the plan-aware executor instead of Engine::execute. The executor directly handles GeneratedRuleFamily::Default and GeneratedRuleFamily::OrAcode with the interpreter's recursion guard, entry/local match save/restore, lifecycle block execution, action-edge child retv/call(child) scoping, default repetition loop, and zero-progress guard. RUST-PARITY.8.3.3 later added direct AND acode, RUST-PARITY.8.3.4 later added direct AND/OR bcode, RUST-PARITY.8.3.5 closed the non-REP matrix, and RUST-PARITY.8.4 closed direct REP families. The focused source_emitter test proves every non-REP and REP generated family in generated modules built in an isolated temp crate."
reverify: "rg -n 'execute_generated_with_plan|GeneratedPlanExecutor|execute_generated_parser|GeneratedRuleFamily::Default|GeneratedRuleFamily::OrAcode|GeneratedRuleFamily::AndSingleAcode|GeneratedRuleFamily::AndAcodeSeq|RUST-PARITY\\.8\\.3\\.2|RUST-PARITY\\.8\\.3\\.3' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated Default/OR Acode Direct Execution

`RUST-PARITY.8.3.2` is the first direct generated-execution slice.

Generated modules still embed `COMPILED_SPEC_JSON` and `GENERATED_RULES`.
After validation, `execute_generated_parser(...)` now calls
`Engine::execute_generated_with_plan(...)` instead of whole-parser
`Engine::execute(...)`.

The plan-aware executor directly handles:

- `GeneratedRuleFamily::Default`
- `GeneratedRuleFamily::OrAcode`

It preserves the interpreter's important runtime contracts: recursion cutoff,
entry/local match scoping, lifecycle block order, action-edge child return
scoping, default-mode repetition, and zero-progress termination.

`RUST-PARITY.8.3.3` later added direct `AndSingleAcode` and `AndAcodeSeq`.
`RUST-PARITY.8.3.4` later added direct `AndBcode` and `OrBcode`, `.8.3.5`
closed the non-REP matrix, and `.8.4` closed the explicit REP matrix.
