---
id: spec-arithmetic-call-surface-ground-truth
title: SPEC-FORMAT-TERSE.3.2 arithmetic/comparison call surface ground truth after comparison symbol aliases
answers:
  - "does add(2,3) work as numeric addition"
  - "does +(2,3) work as numeric addition"
  - "does sum(array(...)) work without num_sum"
  - "are gt and lt numeric comparisons"
  - "are eq gt lt string or numeric comparisons"
  - "can Rust parse symbol callees"
  - "how are slash symbol calls distinguished from regex literals"
  - "why was SPEC-FORMAT-TERSE.3.2 split"
  - "what is the next task after SPEC-FORMAT-TERSE.3.2.1"
  - "what is the next task after SPEC-FORMAT-TERSE.3.2.2"
  - "what is the next task after SPEC-FORMAT-TERSE.3.2.3"
  - "what is the next task after SPEC-FORMAT-TERSE.3.2.3.2"
  - "what is the next task after SPEC-FORMAT-TERSE.3.2.3.3"
  - "what is the next task after SPEC-FORMAT-TERSE.3.2.3.4"
date: 2026-07-02
status: current
tags: [spec-format-terse, arithmetic, comparison, helper-aliases, parser, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.3.2 split + SPEC-FORMAT-TERSE.3.2.1/.3.2.2/.3.2.3.3/.3.2.3.4 implementations; TOOLBOX call_spec_handler_subst/runtime/flow probes; perl/LinkedSpec/ActionIR/MethodExpr.pm; perl/LinkedSpec/ActionIR/FlowExpr.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/Validation.pm; perl/LinkedSpec/BootstrapSpec/Core.pm; rust/linkedspec-core/src/expr.rs; rust/linkedspec-core/src/validation.rs; rust/linkedspec-runtime/src/engine.rs; rust/linkedspec-runtime/tests/corpus/terse_3_2_2_arithmetic_symbol_callees; rust/linkedspec-runtime/tests/corpus/terse_3_2_3_3_numeric_comparison_word_aliases; rust/linkedspec-runtime/tests/corpus/terse_3_2_3_4_numeric_comparison_symbol_callees; docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md"
reverify: "perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm && prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_2_3_4_numeric_comparison_symbol_callees_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# SPEC-FORMAT-TERSE.3.2 Arithmetic/Comparison Call Surface Ground Truth

`SPEC-FORMAT-TERSE.3.2` split the requested Round 3 arithmetic/comparison surface by mechanism.
`SPEC-FORMAT-TERSE.3.2.1` landed the non-conflicting numeric word aliases, and
`SPEC-FORMAT-TERSE.3.2.2` landed arithmetic symbol callees,
`SPEC-FORMAT-TERSE.3.2.3.3` landed numeric comparison word aliases, and
`SPEC-FORMAT-TERSE.3.2.3.4` landed numeric comparison symbol callees.

- Existing numeric helper implementation is still the `num_*` family (`num_add`, `num_gt`, `num_sum`, and
  peers).
- Bare non-comparison word aliases such as `add(2,3)` and `sum(array(...))` now lower/dispatch as numeric
  helpers on Perl and Rust. The landed alias set is `add`, `sub`, `mul`, `div`, `mod`, `abs`, `floor`,
  `ceil`, `round`, `min`, `max`, `clamp`, `sum`, `avg`, `median`, and `range`.
- Arithmetic symbol callees `+(2,3)`, `-(10,3)`, `*(2,3)`, `/(9,2)`, and `%(17,5)` now lower/dispatch as
  `num_add`, `num_sub`, `num_mul`, `num_div`, and `num_mod` on Perl and Rust.
- Slash symbol-call parsing is deliberately narrow: `/(` becomes division only when followed by a balanced
  parenthesized argument list and a call boundary. The lookahead skips quoted strings and escaped characters and
  does not treat `}` as a valid call boundary, preserving regex literals such as `/(\))/` and `/(?<!\\)}/`.
- `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` are shipped lexical string comparisons.
- Bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` now lower/dispatch as numeric aliases over
  `num_eq`/`num_ne`/`num_gt`/`num_ge`/`num_lt`/`num_le` on Perl and Rust. Numeric comparisons can also use
  receiver terminals such as `score.gt(3)`.
- Comparison symbol callees `==(2,2)`, `!=(2,3)`, `>(10,2)`, `>=(2,2)`, `<(2,10)`, and `<=(2,2)` now
  lower/dispatch as numeric aliases over the same `num_*` comparison family on Perl and Rust.
- Perl aliasing is deliberately not done in the shared method-expression parser normalization seam. It happens
  in value lowering after receiver-dot normalization, so receiver chains such as `3.5.floor().add(1)` keep their
  existing number-chain behavior.

The accepted call-shape decision is one uniform `callee(args)` grammar with word and symbol callees. The
Lisp-prefix `(op a, b)` / `(ge a, b)` surface is not added.

The `.3.2` split frontier is:

- `.3.2.1`: done; non-conflicting numeric word aliases for arithmetic, single/multi-value helpers, and reducers.
- `.3.2.2`: done; arithmetic symbol callees such as `+(a,b)`.
- `.3.2.3`: split/owned; comparison spelling policy and implementation sequencing are now recorded before code.
- `.3.2.3.1`: done; explicit string-comparison bridge contract locked before numeric comparison word aliases
  and symbol callees.
- `.3.2.3.2`: done; explicit `str_*` string comparison helpers ship on Perl/Rust.
- `.3.2.3.3`: done; ordinary comparison word calls now map to numeric `num_*` aliases.
- `.3.2.3.4`: done; numeric comparison symbol callees.
- `.3.3`: current next task; expression-valued assignment and `=(target,value)` equivalence.
