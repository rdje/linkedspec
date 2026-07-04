---
id: terse-rust-rhs-shape-target-kind-parity
title: "SPEC-FORMAT-TERSE.1.2.3.5.4 - Rust direct RHS shape literals infer aggregate assignment targets."
answers:
  - "does Rust name = [value] infer an array working variable"
  - "does Rust name = {} infer a hash working variable"
  - "does Rust set(items, [value]) assign an array working variable"
  - "does Rust meta = { key => value } assign a hash working variable"
  - "how does Rust keep scalar-held shape payload assignment"
  - "where did Rust RHS shape target-kind parity land"
  - "is the SPEC-FORMAT-TERSE.1.2.3.5 RHS-shape split closed on Rust"
date: 2026-07-04
status: confirmed
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, rust, oracle]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5.4 landed on 2026-06-29. Rust `Engine::execute_scalar_assignment_operator_statement` now checks whether the raw RHS AST is a direct `Expr::ArrayLiteral` or `Expr::HashLiteral`; only direct shape literals redirect assignment. `Engine::call_helper` applies the same direct-shape check to `set(...)`. Bare targets and matching explicit `array(...)` / `hash(...)` targets are resolved from the raw target AST and assigned with `RuntimeContext::set_array` / `set_hash`, replacing the working aggregate slot after normal expression evaluation of the RHS shape. Explicit `:name` scalar-slot targets deliberately do not match the aggregate target resolver and fall through to the scalar assignment path, preserving scalar-held payload assignment. Focused runtime locks cover bare operator targets, `set` bare targets, explicit typed aggregate targets, and the scalar boundary. The Perl-oracle corpus includes `terse_1_2_3_5_4_shape_rhs_infers_bare_targets` and `terse_1_2_3_5_4_shape_rhs_scalar_boundary`; SPEC-FORMAT-TERSE.6.2.3.2 later retired authored spec-file assign(...)/scalar(...)."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_2_3_5_4 && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Rust RHS Shape Target-Kind Parity

Rust now mirrors the accepted Perl direct RHS shape target-kind rule from
[[terse-rhs-shape-target-kind-inference]].

Direct array RHS shapes assign array working variables:

```text
items = [value]
set(items, [value])
set(array(items), [value])
```

Direct hash RHS shapes assign hash working variables:

```text
meta = { key => value }
set(meta, { key => value })
set(hash(meta), { key => value })
```

The scalar-slot shorthand remains the scalar payload boundary:

```text
set(:payload, [value])
```

That assigns the whole array payload to scalar `payload`; it does not initialize array working variable
`payload`. Non-shape RHS assignment keeps the existing scalar assignment contract.
