---
id: terse-array-end-mutation-methods
title: "SPEC-FORMAT-TERSE.1.6 - Array end-mutation methods are statement-level mutations."
answers:
  - "do items.push_back(value) and items.push_front(value) work"
  - "do items.pop_back() and items.pop_front() work"
  - "how do array end-mutation methods lower"
  - "does array(items).push_back(value) work"
  - "is a(items).push_front(value) a legacy compatibility alias"
  - "does items.push_back(value) read value as a scalar working variable"
  - "what ActionIR node do array end mutations report"
  - "are array pop methods value-returning"
  - "where did SPEC-FORMAT-TERSE.1.6 land"
date: 2026-06-29
status: confirmed
tags: [dsl, arrays, mutation, methods, actionir, spec-format-terse, SPEC-FORMAT-TERSE, perl, rust, oracle]
evidence: "SPEC-FORMAT-TERSE.1.6 landed on 2026-06-29. Perl `ActionIR::MethodLowering` recognizes statement-level receiver-dot array methods and lowers `items.push_back(value)` to `push @items, $value`, `items.push_front(value)` to `unshift @items, $value`, `items.pop_back()` to `pop @items`, and `items.pop_front()` to `shift @items`; `array(items)` is the current explicit wrapper receiver. The contract/scanner reports canonical `ARRAY_MUTATE` with zero fallback, and `RuleIR::EmitContext` auto-supplies the receiver array plus scalar reads from push values. Rust `Engine::execute_block` executes the same single-call fluent statements before generic fluent evaluation. Phase0 was green at 990 tests and the Perl-oracle corpus was green at 33 fixtures."
evidence_update_2026_07_07: "SPEC-FORMAT-TERSE.8.4 superseded the original short-alias compatibility note: `a(items)` now emits retired-helper diagnostics on current runtimes. The accepted current receivers are the bare working-array receiver and `array(items)`."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_6 && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Array End-Mutation Methods

Array end-mutation methods are statement forms over named working arrays:

```text
items.push_back(value)
items.push_front(value)
items.pop_back()
items.pop_front()
```

The accepted current receivers are a bare working-array name and the explicit array wrapper:

```text
array(items).push_back("b")
```

The short wrapper alias `a(items)` is retired on current runtimes; use a bare receiver or `array(items)`.

Push methods consume one value argument. A bare value in that argument slot is a scalar working-variable read,
matching the settled mutation-slot rule from `items += value`. Pop methods mutate the array and discard the
removed value.

The contract is statement-only in this slice. Value-returning fluent forms such as
`return(items.pop_back())` are not accepted as part of `SPEC-FORMAT-TERSE.1.6`; they belong to a later
expression-valued/fluent slice.
