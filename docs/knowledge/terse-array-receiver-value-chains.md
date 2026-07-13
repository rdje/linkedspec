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
evidence: "SPEC-FORMAT-TERSE.2.3.5.1 landed pure array receiver-dot value chains on Perl and Rust. The original slice preserved the then-current statement-only end-mutation boundary. FUTURE-PARITY-BACKLOG.12.1.1-.6 later supersede that result boundary across all five backends: named end mutations return independent updated arrays and may feed compatible continuations."
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

This leaf did not originally make mutating array end methods value-returning. Uniform binding later superseded
that boundary: `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()`
mutate and return updated arrays; pop discards the removed element. See
[[uniform-binding-array-end-result-supersession]].

The next return-family leaf is `SPEC-FORMAT-TERSE.2.3.5.2` for hash receiver-dot value chains.
