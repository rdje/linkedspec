---
id: terse-array-receiver-value-chains
title: Array pure receiver chains and named statement transforms
answers:
  - "can first or last continue through selected string methods"
  - "why do Rust standalone split_each filter_match and uniq update arrays"
  - "how do array receiver-dot value chains work"
  - "does items.sorted().drop_front().first() work"
  - "does items.uniq().join_values work"
  - "does items.filter_match().count work"
  - "does split_each flatten in receiver-dot array chains"
  - "does items.join_values keep delimiter first"
  - "are push_back and pop_back value-returning after SPEC-FORMAT-TERSE.2.3.5.1"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.1"
date: 2026-10-26
status: Perl selected scalars implemented; containers/other backend transitions open
tags: [spec-format-terse, method-chaining, receiver-dot, array, actionir, rust-parity, oracle, mdbook]
evidence: "Historical pure chains: SPEC-FORMAT-TERSE.2.3.5.1; end-result supersession: FUTURE-PARITY-BACKLOG.12.1.1-.6. Rust/Dart/Julia statement repairs:5.3.1-.3."
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

Array end mutation/result supersession is governed by [[uniform-binding-array-end-result-supersession]]; this historical chain leaf does not redefine it.

Rust5.3.1 enrolls standalone split_each/filter_match/uniq in execute_array_string_transform_statement. Validate the array target, snapshot it, evaluate remaining operands once and reuse call_helper before rebinding. Existing wrong kinds fail; absent targets initialize. Pure value/receiver calls stay unchanged. Rust/Dart/Julia5.3.1-.3 are implemented with focused native/restored/generated-plan checks. Broad5.3.4 remains deferred until feature coverage. The earlier pending Dart/Julia wording was stale, not an unimplemented feature.

At23.2.1, public Perl first/last string chains returned null beside working nested controls. Scalar repair23.3.1.1.1 removes the first-terminal preflight and carries selected results through existing string/numeric helpers in every outer-family loop. Native/fresh scalar regression and pipeline controls pass with once-only effects. selected-values.md retains the contract; selected containers1.1.2 and other backends remain open. No new runtime type or complete fluent family admission.
