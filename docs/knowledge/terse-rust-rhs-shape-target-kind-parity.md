---
id: terse-rust-rhs-shape-target-kind-parity
title: "SPEC-FORMAT-TERSE.1.2.3.5.4 - Historical Rust direct RHS shape target-kind inference."
answers:
  - "did Rust name = [value] historically infer an array working variable"
  - "what superseded Rust RHS shape target-kind parity"
  - "where is current Rust duck typed assignment parity recorded"
  - "where did historical Rust RHS shape target-kind parity land"
date: 2026-07-05
status: superseded
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, rust, oracle]
evidence: "Historical fact: SPEC-FORMAT-TERSE.1.2.3.5.4 landed on 2026-06-29 and made Rust direct RHS shape literals retag bare assignment targets into aggregate storage. SPEC-FORMAT-TERSE.11.3 superseded that behavior on 2026-07-05: Rust bare assignment and set/=/helper forms now bind evaluated RuntimeValue instances through scalar storage, including direct array/hash RHS values. Explicit array(name) / hash(name) targets remain aggregate storage. Current Rust behavior is recorded in [[terse-rust-duck-typed-assignment-parity]]."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_11_3 && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Historical Rust RHS Shape Target-Kind Parity

This card records the historical Rust behavior from `SPEC-FORMAT-TERSE.1.2.3.5.4`. It is superseded by
[[terse-rust-duck-typed-assignment-parity]].

Direct array RHS shapes used to assign array working variables:

```text
items = [value]
set(items, [value])
set(array(items), [value])
```

Direct hash RHS shapes used to assign hash working variables:

```text
meta = { key : value }
set(meta, { key : value })
set(hash(meta), { key : value })
```

Current Rust duck-typed assignment stores a whole shape payload through a bare target:

```text
payload = [value]
set(payload, [value])
```

Current Rust behavior no longer retags bare targets from RHS shape. Bare `items = [value]`, `set(items, [value])`,
and `=(items, [value])` bind array values as scalar-held typed values; explicit `array(items)` / `hash(meta)`
targets remain aggregate storage.
