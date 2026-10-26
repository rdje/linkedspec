---
id: terse-array-receiver-value-chains
title: Array pure receiver chains and named statement transforms
answers:
  - "can first or last continue through selected string methods"
  - "can copy preserve selected array or harray values"
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
status: Perl/Rust selected-value methods implemented; Dart/Julia/Lua confirmations next
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

Rust/Dart/Julia5.3.1-.3 implement named standalone transforms using validated snapshots, ordered operands and existing pure helpers; focused native/restored/generated-plan checks pass. Broad5.3.4 stays deferred.


At23.2.1, Perl extraction chains failed beside working nested controls. Repairs23.3.1.1.1-.2 preserve selected-result flow through existing scalar/container helpers in every outer-family loop. Pipeline sources and generic copy read actual values once, checking runtime container kind instead of guessing extracted content from spelling. copy keeps selected array/harray kind; min/max distinguish scalar operands from zero-extra-operand array reducers. Native/fresh focused scalar/container and pipeline checks pass with snapshots and once-only effects. Rust23.3.1.2 reuses dynamic receiver dispatch after extraction, with native/restored/generated-plan checks and a trim-null blocker fix. selected-values.md retains the contract; other backends/full admission remain open.
