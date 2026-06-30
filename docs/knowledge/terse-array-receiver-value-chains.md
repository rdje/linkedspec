---
id: terse-array-receiver-value-chains
title: SPEC-FORMAT-TERSE.2.3.5.1 array receiver-dot value chains
answers:
  - "how do array receiver-dot value chains work"
  - "does items.sorted().drop_front().first() work"
  - "does items.uniq().join_values work"
  - "does items.filter_match().count work"
  - "does split_each flatten in receiver-dot array chains"
  - "does items.join_values keep delimiter first"
  - "are push_back and pop_back value-returning after SPEC-FORMAT-TERSE.2.3.5.1"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.1"
date: 2026-07-01
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, array, actionir, rust-parity, oracle, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.5.1 landed array receiver-dot value chains on Perl and Rust. Perl normalizes compatible receiver-dot array chains into pure value helper composition while preserving legacy public function-style array-pipeline lowering. Rust evaluates `Expr::FluentChain` array receivers by carrying the current value through helper calls. Locked examples include `items.sorted().drop_front(2).first()`, `items.uniq().join_values(\",\")`, `items.filter_match(/^a$/).count()`, and `phrases.split_each(\"-\").filter_match(/^aa$/).count()`. Receiver-dot `join_values` maps to the delimiter-first function contract (`join_values(delim, items)`). Rust `split_each` now returns the documented flat array with the supplied delimiter. `.1.6` array end mutations (`push_back`, `push_front`, `pop_back`, `pop_front`) remain statement-only; value slots return `undef` and do not mutate. Phase0 passed with 996 tests and the oracle corpus passed with 47 fixtures."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_5_1 --quiet && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

Array receiver-dot value chains are pure helper composition over compatible array helpers.

Examples:

```text
items.sorted().drop_front(2).first()
items.uniq().join_values(",")
items.filter_match(/^a$/).count()
phrases.split_each("-").filter_match(/^aa$/).count()
```

The receiver becomes the array argument for the next helper. `join_values` is the special delimiter-first
terminal: `items.join_values("|")` is the receiver-dot spelling for `join_values("|", items)`.

This leaf did not make mutating array end methods value-returning. `items.push_back(value)`,
`items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` remain statement-only mutation forms.
When they appear in a value slot, they return `undef` and do not mutate the array.

The next return-family leaf is `SPEC-FORMAT-TERSE.2.3.5.2` for hash receiver-dot value chains.
