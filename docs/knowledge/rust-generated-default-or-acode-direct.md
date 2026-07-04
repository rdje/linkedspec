---
id: rust-generated-default-or-acode-direct
title: Rust generated source directly executes default and OR acode families
answers:
  - "which Rust generated families execute directly"
  - "does generated Rust source execute directly yet"
  - "what did RUST-PARITY.8.3.2 add"
  - "what remains after direct default OR acode generation"
  - "which leaf owns direct AND acode generated execution"
date: 2026-07-04
status: accepted
tags: [rust, codegen, source-emitter, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.3.2 adds Engine::execute_generated_with_plan and the runtime-internal GeneratedPlanExecutor. execute_generated_parser now validates GENERATED_RULES and calls the plan-aware executor instead of Engine::execute. The executor directly handles GeneratedRuleFamily::Default and GeneratedRuleFamily::OrAcode with the interpreter's recursion guard, entry/local match save/restore, lifecycle block execution, action-edge child retv/call(child) scoping, default repetition loop, and zero-progress guard. AND acode, bcode, and REP families still fall back inside the executor. The focused source_emitter test proves repeated default matching and OR acode child-return dispatch in generated modules built in an isolated temp crate. RUST-PARITY.8.3.3 owns direct AND acode next."
reverify: "rg -n 'execute_generated_with_plan|GeneratedPlanExecutor|execute_generated_parser|GeneratedRuleFamily::Default|GeneratedRuleFamily::OrAcode|RUST-PARITY\\.8\\.3\\.2|RUST-PARITY\\.8\\.3\\.3' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
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

Remaining generated families still fall back inside the executor until their
owned leaves land: `.8.3.3` for AND acode, `.8.3.4` for bcode, and `.8.4` for
REP families.
