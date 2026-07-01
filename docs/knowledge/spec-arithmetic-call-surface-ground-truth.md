---
id: spec-arithmetic-call-surface-ground-truth
title: SPEC-FORMAT-TERSE.3.2 arithmetic/comparison call surface ground truth
answers:
  - "does add(2,3) work as numeric addition"
  - "does +(2,3) work as numeric addition"
  - "does sum(array(...)) work without num_sum"
  - "are gt and lt numeric comparisons"
  - "are eq gt lt string or numeric comparisons"
  - "can Rust parse symbol callees"
  - "why was SPEC-FORMAT-TERSE.3.2 split"
  - "what is the next task after SPEC-FORMAT-TERSE.3.2"
date: 2026-07-01
status: current
tags: [spec-format-terse, arithmetic, comparison, helper-aliases, parser, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.3.2 split; TOOLBOX call_spec_handler_subst/runtime/flow probes; perl/LinkedSpec/ActionIR/MethodExpr.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; rust/linkedspec-core/src/expr.rs; rust/linkedspec-runtime/src/engine.rs; docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md"
reverify: "perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm && cargo test --manifest-path rust/linkedspec-core/Cargo.toml --quiet && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --quiet"
---

# SPEC-FORMAT-TERSE.3.2 Arithmetic/Comparison Call Surface Ground Truth

`SPEC-FORMAT-TERSE.3.2` was split before code because the requested Round 3 arithmetic/comparison surface
crosses separate mechanisms:

- Existing numeric helper implementation is the `num_*` family (`num_add`, `num_gt`, `num_sum`, and peers).
- Bare word aliases such as `add(2,3)` and `sum(array(...))` do not currently lower as numeric helpers.
- Symbol callees such as `+(2,3)` are not a portable call syntax today. Perl must intercept them before raw
  host fallback can reinterpret them, and Rust's expression parser currently accepts word-like call names only.
- Bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` are already string comparisons in flow/helper contexts. Numeric
  comparisons are `num_eq`/`num_gt`/etc. or receiver terminals such as `score.gt(3)`.

The accepted call-shape decision is one uniform `callee(args)` grammar with word and symbol callees. The
Lisp-prefix `(op a, b)` / `(ge a, b)` surface is not added.

The split frontier is:

- `.3.2.1`: non-conflicting numeric word aliases for arithmetic, single/multi-value helpers, and reducers.
- `.3.2.2`: arithmetic symbol callees such as `+(a,b)`.
- `.3.2.3`: comparison spelling policy before implementation.
