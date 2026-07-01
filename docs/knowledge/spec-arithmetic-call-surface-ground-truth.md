---
id: spec-arithmetic-call-surface-ground-truth
title: SPEC-FORMAT-TERSE.3.2 arithmetic/comparison call surface ground truth after numeric word aliases
answers:
  - "does add(2,3) work as numeric addition"
  - "does +(2,3) work as numeric addition"
  - "does sum(array(...)) work without num_sum"
  - "are gt and lt numeric comparisons"
  - "are eq gt lt string or numeric comparisons"
  - "can Rust parse symbol callees"
  - "why was SPEC-FORMAT-TERSE.3.2 split"
  - "what is the next task after SPEC-FORMAT-TERSE.3.2.1"
date: 2026-07-01
status: current
tags: [spec-format-terse, arithmetic, comparison, helper-aliases, parser, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.3.2 split + SPEC-FORMAT-TERSE.3.2.1 implementation; TOOLBOX call_spec_handler_subst/runtime/flow probes; perl/LinkedSpec/ActionIR/MethodLowering.pm; perl/LinkedSpec/ActionIR/FlowExpr.pm; perl/LinkedSpec/BootstrapSpec/Core.pm; rust/linkedspec-runtime/src/engine.rs; rust/linkedspec-runtime/tests/corpus/terse_3_2_1_numeric_word_aliases; docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md"
reverify: "perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm && prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

# SPEC-FORMAT-TERSE.3.2 Arithmetic/Comparison Call Surface Ground Truth

`SPEC-FORMAT-TERSE.3.2` split the requested Round 3 arithmetic/comparison surface by mechanism, and
`SPEC-FORMAT-TERSE.3.2.1` has now landed the non-conflicting numeric word aliases.

- Existing numeric helper implementation is still the `num_*` family (`num_add`, `num_gt`, `num_sum`, and
  peers).
- Bare non-comparison word aliases such as `add(2,3)` and `sum(array(...))` now lower/dispatch as numeric
  helpers on Perl and Rust. The landed alias set is `add`, `sub`, `mul`, `div`, `mod`, `abs`, `floor`,
  `ceil`, `round`, `min`, `max`, `clamp`, `sum`, `avg`, `median`, and `range`.
- Symbol callees such as `+(2,3)` are not a portable call syntax today. Perl must intercept them before raw
  host fallback can reinterpret them, and Rust's expression parser currently accepts word-like call names only.
- Bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` are already string comparisons in flow/helper contexts. Numeric
  comparisons are `num_eq`/`num_gt`/etc. or receiver terminals such as `score.gt(3)`.
- Perl aliasing is deliberately not done in the shared method-expression parser normalization seam. It happens
  in value lowering after receiver-dot normalization, so receiver chains such as `3.5.floor().add(1)` keep their
  existing number-chain behavior.

The accepted call-shape decision is one uniform `callee(args)` grammar with word and symbol callees. The
Lisp-prefix `(op a, b)` / `(ge a, b)` surface is not added.

The split frontier is:

- `.3.2.1`: done; non-conflicting numeric word aliases for arithmetic, single/multi-value helpers, and reducers.
- `.3.2.2`: current next task; arithmetic symbol callees such as `+(a,b)`.
- `.3.2.3`: comparison spelling policy before implementation.
