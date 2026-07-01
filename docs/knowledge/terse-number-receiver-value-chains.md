---
id: terse-number-receiver-value-chains
title: SPEC-FORMAT-TERSE.2.3.5.4 number receiver-dot value chains
answers:
  - "how do number receiver-dot value chains work"
  - "does score.abs().ceil().add work"
  - "does 5.mod(2) work"
  - "does 3.5.floor().add(1) work"
  - "are numeric comparison receiver methods terminal"
  - "can number terminal methods continue"
  - "are declare methods terse receiver methods"
  - "is declare a number receiver method"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.4"
date: 2026-07-01
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, number, actionir, rust-parity, oracle, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.5.4 landed number receiver-dot value chains on Perl and Rust. Perl normalizes compatible receiver-dot numeric chains into pure `num_*` helper composition; bare numeric receivers are scalar working-variable reads, and decimal dots are skipped by the receiver splitter. Rust parses fluent chains after numeric literals without swallowing method dots as decimals, evaluates the same receiver family, and now consumes all supplied operands for `num_add` and `num_mul`. Locked examples include `score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12)`, `5.mod(2)`, `3.5.floor().add(1)`, and `3.5.round()`. Comparison links `eq`, `ne`, `gt`, `ge`, `lt`, and `le` are terminal; invalid continuations return `undef`/`null`. Numeric array reducers stay explicit array-consuming helpers, and statement/lifecycle calls such as `declare(...)` are not receiver methods. Phase0 passed with 999 tests and the oracle corpus passed with 50 fixtures."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_5_4 --quiet && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.2.3.5.4` is the number-family implementation leaf for return-type method chaining.

Number receiver-dot chains are pure value composition. The receiver becomes the first numeric helper argument,
and each number-returning helper feeds the next compatible helper:

- `score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12)`
- `5.mod(2)`
- `3.5.floor().add(1)`
- `3.5.round()`

Comparison methods are terminal values. `score.abs().gt(3)` is valid, but `score.abs().gt(3).add(1)` returns
`undef` / JSON `null`.

`declare(...)` and other statement/lifecycle calls are not terse receiver methods. Numeric array reducers such
as `num_sum(array(scores))` also remain explicit array-consuming helpers, not scalar receiver links.

The next task-tree leaf is `.2.3.5.5` for block-valued receiver chaining by yielded runtime type.
