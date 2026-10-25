---
id: terse-array-receiver-value-chains
title: Array pure receiver chains and named statement transforms
answers:
  - "why do Rust standalone split_each filter_match and uniq update arrays"
  - "how do array receiver-dot value chains work"
  - "does items.sorted().drop_front().first() work"
  - "does items.uniq().join_values work"
  - "does items.filter_match().count work"
  - "does split_each flatten in receiver-dot array chains"
  - "does items.join_values keep delimiter first"
  - "are push_back and pop_back value-returning after SPEC-FORMAT-TERSE.2.3.5.1"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.1"
date: 2026-10-25
status: pure chains current; Rust statement transforms5.3.1 targeted-checked; Dart/Julia pending
tags: [spec-format-terse, method-chaining, receiver-dot, array, actionir, rust-parity, oracle, mdbook]
evidence: "Historical pure chains: SPEC-FORMAT-TERSE.2.3.5.1; end-result supersession: FUTURE-PARITY-BACKLOG.12.1.1-.6. Rust statement repair:5.3.1."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test array_transform_writeback"
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

Historical hash sibling: `SPEC-FORMAT-TERSE.2.3.5.2`.

Rust5.3.1 enrolls standalone split_each/filter_match/uniq in execute_array_string_transform_statement. Validate the array target, snapshot it, evaluate remaining operands once and reuse call_helper before rebinding. Existing wrong kinds fail; absent targets initialize. Pure value/receiver calls stay unchanged. Native/restored/generated-plan focused checks pass; Dart5.3.2, Julia5.3.3 and broad5.3.4 remain open.
