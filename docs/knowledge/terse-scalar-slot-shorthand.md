---
id: terse-scalar-slot-shorthand
title: "SPEC-FORMAT-TERSE.6.2.3.1 - :name is the terse scalar-slot shorthand; SPEC-FORMAT-TERSE.6.2.3.2 later retired authored spec-file scalar(name), and set(:name, shape) preserves the scalar payload boundary."
answers:
  - "what is :name in LinkedSpec"
  - "how do I write scalar(name) tersely"
  - "does :payload keep scalar payload boundary for direct shape assignment"
  - "is scalar(name) retired or still accepted"
  - "where did SPEC-FORMAT-TERSE.6.2.3.1 land"
  - "how do Perl and Rust parse :name scalar slot shorthand"
date: 2026-07-03
status: confirmed
tags: [dsl, scalar, shorthand, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.6.2.3.1 landed `:name` on 2026-07-03. Perl recognizes the spelling in `ActionIR::ValueExpr::_extract_scalar_symbol_name`, `ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr`, direct-shape/constructor value lowering, and `RuleIR::EmitContext::_collect_auto_working_var_decls`. Rust adds `Expr::ScalarSlot { name }` in `linkedspec-core/src/expr.rs`, parses leading `:name` as a value primary, evaluates it with `RuntimeContext::get_scalar`, and treats it as a scalar assignment/mutation target in `linkedspec-runtime/src/engine.rs`. At `.6.2.3.1`, `:name` was introduced as the replacement for one-argument `scalar(name)` and `set(:payload, [value])` stores the whole array payload in scalar `payload`, while bare `set(payload, [value])` still infers an array assignment. SPEC-FORMAT-TERSE.6.2.3.2 later hard-retired authored spec-file `scalar(name)` and `assign(...)`; use `:name` plus `LHS = RHS`/`set(...)` on the current surface."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return(:name)}, q{set(:payload, [value]); return(:payload)}, q{return([:value, :other])}, q{return(array(:value, :other))}) { print LinkedSpec::call_spec_handler_subst(\"Top\", $stmt), \"\\n\" }' && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_scalar_slot_shorthand_expr && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_6_2_3_1_scalar_slot_shorthand_runs -- --nocapture"
---

# Scalar-slot shorthand

`SPEC-FORMAT-TERSE.6.2.3.1` adds `:name` as the terse scalar-slot spelling.
It is a scalar read in value positions:

```text
return(:name)                  # reads scalar working variable name
return([:value, :other])       # both items read scalar working variables
```

It is also an explicit scalar target in assignment-like target positions:

```text
set(:payload, [value])        # scalar payload boundary: $payload = [$value]
```

This does not change direct-shape target inference for bare targets:

```text
set(payload, [value])         # assigns array working variable payload
set(:payload, [value])        # assigns scalar working variable payload
```

`SPEC-FORMAT-TERSE.6.2.3.2` later retired authored spec-file `scalar(name)`.
Current specs use `:name` for scalar slots.
