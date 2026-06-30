---
id: terse-lifecycle-value-drop-return-channel
title: SPEC-FORMAT-TERSE.2.3.2 lifecycle blocks discard ordinary statement values; top-level return uses the rule/action channel
answers:
  - "are lifecycle blocks expression-valued in LinkedSpec"
  - "does the last statement in I LS LE E EX IT LX return implicitly"
  - "what does return(expr) inside a lifecycle block do"
  - "is return(expr) inside an expression-valued block the same as lifecycle return"
  - "does Rust stop after a top-level lifecycle return"
  - "how is lifecycle value drop locked"
date: 2026-06-30
status: current
tags: [spec-format-terse, lifecycle, return-channel, expression-valued-blocks, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.2 landed focused locks on 2026-06-30. Perl phase0 subtest `spec_format_terse_2_3_2_locks_lifecycle_value_drop_and_return_channel` source-locks structured blocks for all seven lifecycle markers (`I`, `LS`, `LE`, `LX`, `E`, `EX`, `IT`) and runtime-locks three distinctions: (1) a final ordinary lifecycle statement such as `set(ignored, \"i-final\")` mutates state but is not an implicit rule return; (2) a top-level Perl lifecycle `return(\"i\")` writes the surrounding rule channel through host return semantics; (3) `return(\"block\")` inside an expression-valued block remains block-local, so later outer statements still run. Rust integration tests `terse_2_3_2_*` lock the same value/drop distinction and the Rust backend's existing return-event shape: top-level lifecycle `return(\"from_i\")` records a surrounding return event, then later statements/lifecycle returns can still record additional top-level return events. This Rust shape is consistent with existing Rust lifecycle tests that intentionally use multiple `return(...)` statements in one lifecycle block for capture helpers. The mdBook now states lifecycle blocks are statement blocks, not expression-valued blocks, and contrasts top-level lifecycle/action return with expression-valued block-local return."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_2 && mdbook build docs/linkedspec-book"
---

Lifecycle blocks are statement blocks.

Ground truth:

- Ordinary statement values in lifecycle blocks are discarded. A final `set(...)`, helper call, or value
  expression is not an implicit rule return.
- Top-level lifecycle/action `return(expr)` writes the surrounding rule/action return channel.
- `return(expr)` inside an expression-valued block is block-local: it yields that block's value and skips later
  statements only inside that value block.
- Rust's top-level `execute(...)` result is an accumulator of return events. Current Rust lifecycle execution
  can therefore expose multiple top-level return events from one lifecycle path; this is existing runtime
  behavior and is separately locked from Perl's host-level early return behavior.
