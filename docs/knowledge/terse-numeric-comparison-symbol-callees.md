---
id: terse-numeric-comparison-symbol-callees
title: "SPEC-FORMAT-TERSE.3.2.3.4 makes comparison symbols numeric aliases."
answers:
  - "are == and != implemented as calls"
  - "are >(a,b) and >=(a,b) implemented now"
  - "are comparison symbol callees numeric or string comparisons"
  - "does =(target,value) work as a comparison symbol"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.4"
date: 2026-07-02
status: current
tags: [spec-format-terse, comparisons, helper-aliases, parser, rust-parity]
evidence: "SPEC-FORMAT-TERSE.3.2.3.4 implementation; perl/LinkedSpec/ActionIR/MethodExpr.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; perl/LinkedSpec/ActionIR/FlowExpr.pm; rust/linkedspec-core/src/expr.rs; rust/linkedspec-runtime/src/engine.rs; t/phase0_regression.t spec_format_terse_3_2_3_4_numeric_comparison_symbol_callees; rust/linkedspec-runtime/tests/integration_test.rs terse_3_2_3_4_numeric_comparison_symbol_callees_run; rust/linkedspec-runtime/tests/corpus/terse_3_2_3_4_numeric_comparison_symbol_callees"
reverify: "perl -Iperl -c perl/LinkedSpec/ActionIR/MethodExpr.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm && prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core symbol_callees && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_2_3_4_numeric_comparison_symbol_callees_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# Terse Numeric Comparison Symbol Callees

`SPEC-FORMAT-TERSE.3.2.3.4` implements comparison symbol callees as ordinary `callee(args)` calls.

- `==(lhs,rhs)` maps to `num_eq(lhs,rhs)`.
- `!=(lhs,rhs)` maps to `num_ne(lhs,rhs)`.
- `>(lhs,rhs)` maps to `num_gt(lhs,rhs)`.
- `>=(lhs,rhs)` maps to `num_ge(lhs,rhs)`.
- `<(lhs,rhs)` maps to `num_lt(lhs,rhs)`.
- `<=(lhs,rhs)` maps to `num_le(lhs,rhs)`.

These are numeric comparisons, matching the `.3.2.3.3` comparison word aliases. Lexical string comparisons
remain the explicit `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` family.

The single-equals spelling `=(target,value)` is not part of comparison symbols and remains owned by
`SPEC-FORMAT-TERSE.3.3`. The blind-call edge operator `=>` is unchanged.

Rust parser note: `==(...)` exposed that argument parsing must not treat an empty token before `=` as a
keyword-argument name. The parser now requires a non-empty identifier before recognizing `name=expr`.

The next task-tree frontier after this leaf was `SPEC-FORMAT-TERSE.3.3`; that leaf is now split/done,
`SPEC-FORMAT-TERSE.3.3.1` has landed scalar assignment expression values, `SPEC-FORMAT-TERSE.3.3.2` has landed
aggregate assignment expression values, and `SPEC-FORMAT-TERSE.3.3.3` has landed array append/hash-index mutation
expression values. The current implementation frontier is `SPEC-FORMAT-TERSE.3.3.4`.
