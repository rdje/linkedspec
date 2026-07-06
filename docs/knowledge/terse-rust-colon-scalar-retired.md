---
id: terse-rust-colon-scalar-retired
title: "SPEC-FORMAT-TERSE.15.4 - Rust Expr::ScalarSlot is retired and colon scalar slots emit the bare-read migration diagnostic"
answers:
  - "what happens to :name in Rust after SPEC-FORMAT-TERSE.15.4"
  - "is Expr::ScalarSlot still in the Rust AST"
  - "is :name still supported on the Rust backend"
  - "which leaf removed Rust Expr::ScalarSlot"
  - "what diagnostic does Rust emit for a retired colon scalar slot"
  - "why did ebnf.spec need rule_header after Rust colon slot removal"
date: 2026-07-06
status: current
tags: [spec-format-terse, scalar-slot, colon-slot, bare-read, rust, actionir, oracle]
evidence: "SPEC-FORMAT-TERSE.15.4 removed `Expr::ScalarSlot` from the Rust core AST and runtime/source-emitter paths. `parse_primary` now routes `:name` to a retired-colon diagnostic with `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read`, and active Rust fixtures use bare reads. The EBNF shipped spec now separates scalar `rule_header` from aggregate `rule` to avoid relying on the old same-name scalar/array collision, generated EBNF oracle inputs were refreshed, and the former scalar-slot oracle fixture is now `terse_15_4_bare_scalar_payload_readback`. Focused Rust core/runtime/source-emitter/trace tests, oracle generation, and the 93-fixture Rust corpus oracle pass."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_retired_colon_scalar_slot_reports_bare_read_migration && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_15_4_bare_reads_replace_scalar_slot_shorthand"
---

# Rust Colon Scalar Slots Are Retired

Current Rust authoring follows the same surface as the Perl reference backend: working variables are read by bare
name in value positions, and aggregate mutation boundaries stay explicit with `array(...)` / `hash(...)` targets.

`Expr::ScalarSlot` is gone. A remaining `return(:name)`, `set(:name, value)`, or similar form fails with the
retired-colon diagnostic sentinel:

```text
LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read
```

The EBNF oracle is the regression guard for the same-name collision that `:name` used to mask: scalar headers use
`rule_header`, while aggregate body accumulation still uses `rule`.

Related: [[terse-perl-colon-scalar-retired]], [[terse-bare-read-value-position-gap]],
[[terse-colon-scalar-slot-removal-audit]].
