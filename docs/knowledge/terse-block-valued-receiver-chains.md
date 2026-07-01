---
id: terse-block-valued-receiver-chains
title: SPEC-FORMAT-TERSE.2.3.5.5 block-valued receiver-dot chains
answers:
  - "do expression-valued blocks work as receiver-dot receivers"
  - "does { [3, 1, 2] }.sorted().join_values work"
  - "does a block yielding a string continue through trim split count"
  - "does a block yielding a hash continue through sorted_keys join_values"
  - "does a block yielding a number continue through floor add"
  - "how are block-local returns handled in receiver chains"
  - "which task closed block-valued receiver chaining"
date: 2026-07-01
status: current
tags: [spec-format-terse, expression-valued-blocks, receiver-dot, method-chaining, actionir, rust-parity, oracle, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.5.5 landed block-valued receiver-dot chains on Perl and Rust. Perl already supported string/hash/number block receivers through existing receiver-family normalization, but array-yielding block receivers were rejected by the array-value recognizer before `sorted(...)` and similar helpers could lower. `MethodLowering.pm` now treats expression-valued blocks as array-like only when the block's visible exits are array-yielding expressions, preserving hash/string/number blocks while letting the existing array helper runtime guards operate. Rust now parses fluent chains after block/hash/array primaries, so `{ [3, 1, 2] }.sorted().join_values(\",\")` is an `Expr::FluentChain` with a `BlockValue` receiver; the existing runtime evaluator already feeds non-variable receivers through `eval_expr`. Locked examples cover array, block-local early return yielding an array, string-to-array bridge, hash-to-array bridge, and number receiver families. Phase0 passed with 1001 tests, the oracle corpus regenerated to 52 fixtures, and Rust `corpus_oracle` passed all 52."
reverify: "perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm && perl -Iperl -c t/phase0_regression.t && prove -q -Iperl t/phase0_regression.t && RUSTFLAGS=-Awarnings cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_block_valued_receiver_chain --quiet && RUSTFLAGS=-Awarnings cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_5_5 --quiet && perl -Iperl tools/gen_oracle_corpus.pl && RUSTFLAGS=-Awarnings cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

Expression-valued blocks are ordinary value expressions when used as receiver-dot receivers. The block runs
first; its yielded value then enters the already-owned receiver family selected by the first method.

Locked examples:

```text
{ [3, 1, 2] }.sorted().join_values(",")              # "1,2,3"
{ return(["x", "y"]); ["bad"] }.join_values("|")     # "x|y"
{ set(raw, " a-b "); raw }.trim().split("-").count() # 2
{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",") # "a,b"
{ 3.5 }.floor().add(2)                               # 5
```

The block does not add a special block-only dispatch rule. `return(expr)` inside the block remains
block-local and yields the receiver value before later block statements are skipped.
