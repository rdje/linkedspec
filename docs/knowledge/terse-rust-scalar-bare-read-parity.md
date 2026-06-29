---
id: terse-rust-scalar-bare-read-parity
title: "SPEC-FORMAT-TERSE.1.2.3.4 — Rust scalar bare-read parity is parser acceptance over the existing Expr::Variable scalar read."
answers:
  - "does Rust match Perl scalar bare reads after SPEC-FORMAT-TERSE.1.2.3.4"
  - "does Rust accept items += value as a scalar RHS read"
  - "does Rust accept meta[key] = value with bare key and RHS reads"
  - "does Rust accept foo[\"a\"][z] direct access"
  - "what changed for Rust scalar bare-read parity"
  - "why did Rust scalar bare-read parity not need runtime changes"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.4"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, rust, parser]
evidence: "SPEC-FORMAT-TERSE.1.2.3.4 landed on 2026-06-29. Rust runtime evaluation already mapped `Expr::Variable` to `ctx.get_scalar(name)`, so scalar bare-read parity required removing parser reservations, not adding a new runtime value path. `rust/linkedspec-core/src/expr.rs` now accepts bare variables in array append RHS, hash-index key/RHS, and multi-segment direct-access path indexes. The focused parser locks `parse_scalar_bare_reads_in_mutation_slots` and `parse_direct_nested_access_accepts_bare_segments` pass. Runtime locks `terse_1_2_3_4_scalar_source_slot_bare_reads_run` and `terse_1_2_3_4_mutation_and_direct_access_bare_reads_run` pass. `tools/gen_oracle_corpus.pl` now emits three `.1.2.3.4` fixtures and the Rust corpus oracle passes over 28 fixtures. The next Channel 2 leaf is SPEC-FORMAT-TERSE.1.2.3.5 for RHS-shape/type-inference split before code."
reverify: "cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_scalar_bare_reads_in_mutation_slots && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_direct_nested_access_accepts_bare_segments && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_2_3_4 && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle"
---

# Rust Scalar Bare-Read Parity

Rust now matches the accepted Perl scalar bare-read contract from `SPEC-FORMAT-TERSE.1.2.3.3`.

Accepted scalar read slots include:

- source slots: `return(value)`, `set(out, value)`, `name = value`;
- mutation key/RHS slots: `items += value`, `set_key(meta, key, value)`, `meta[key] = value`;
- direct-access path atoms: `foo["a"][idx]`, equivalent to `foo["a"][scalar(idx)]`.

The runtime already had the scalar read semantics because `Expr::Variable` evaluates through
`RuntimeContext::get_scalar`. This leaf removed the parser guards that kept the accepted Channel 2 scalar read
slots reserved.

This does not implement RHS-shape `[]`/`{}` inference, expression-valued blocks, or a broader helper-argument
fallback. The next leaf is `SPEC-FORMAT-TERSE.1.2.3.5`, which owns the RHS-shape/type-inference split before
code.
