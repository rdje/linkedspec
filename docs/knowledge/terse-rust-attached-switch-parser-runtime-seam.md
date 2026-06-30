---
id: terse-rust-attached-switch-parser-runtime-seam
title: Rust attached-block switch parity landed as parser normalization plus statement switch runtime gating
answers:
  - "what does SPEC-FORMAT-TERSE.2.2.5.2 own"
  - "where should Rust attached switch be implemented"
  - "does Rust CodeBlock parse attached switch branch blocks"
  - "does Rust runtime gate statement switch case default"
  - "how does Rust preserve lazy value-form switch while adding attached switch"
date: 2026-06-30
status: current
tags: [spec-format-terse, rust-parity, control-flow, switch, parser, runtime]
evidence: "SPEC-FORMAT-TERSE.2.2.5.2 implementation. `rust/linkedspec-core/src/expr.rs` now parses one-argument attached `switch(...) { ... }` blocks before ordinary statement-expression parsing, accepts attached `case(value) { ... }` and `default { ... }` / `default() { ... }` branch bodies inside the outer block, and normalizes them to `switch` / `case` / `default` / `endswitch` statements. `rust/linkedspec-runtime/src/engine.rs` adds `StatementSwitchFrame` and gates statement switch controls beside the existing statement-if stack in `execute_block()` and `eval_block_value()`. Multi-argument lazy value-form `switch(expr, case(...), default(...))` stays in the lazy helper path. Locked by focused parser `attached_switch`, focused runtime `terse_2_2_5_2`, existing lazy `cond_switch`, and oracle fixture `terse_2_2_5_2_attached_switch_blocks`."
reverify: "cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core attached_switch && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_5_2 && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime cond_switch && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

Rust attached-block switch support has two seams:

1. `CodeBlock::parse` claims attached switch blocks only when `switch(...)` has one subject argument and is
   followed by an outer `{ ... }` block.
2. The runtime handles the normalized statement controls with a switch stack:

```text
switch(expr)
case(value)
...
default
...
endswitch
```

The switch expression is evaluated once when the parent controls are active. Cases compare stringified branch
values in order, only the first matching branch executes, and `default` executes only if no prior case matched.
Inactive branches skip side effects, including nested attached `if` or nested switch bodies.

This does not replace lazy value-form switch:

```text
switch(expr, case(value, result), default(result))
```

That multi-argument form remains a value expression in the lazy helper path.
