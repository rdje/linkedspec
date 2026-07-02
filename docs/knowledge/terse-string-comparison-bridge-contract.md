---
id: terse-string-comparison-bridge-contract
title: "SPEC-FORMAT-TERSE.3.2.3.2 ships the explicit str_* string comparison bridge."
answers:
  - "what is str_eq"
  - "are str_eq and str_gt implemented"
  - "what is the string comparison bridge contract"
  - "when can bare gt become numeric"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.1"
  - "should docs use str_eq now"
date: 2026-07-02
status: current
tags: [spec-format-terse, comparisons, string-helpers, helper-aliases, task-tree, mdbook]
evidence: "SPEC-FORMAT-TERSE.3.2.3.1 task-tree contract; SPEC-FORMAT-TERSE.3.2.3.2 implementation; perl/LinkedSpec/ActionIR/FlowExpr.pm string comparison dispatch; perl/LinkedSpec/ActionIR/MethodLowering.pm value-call lowering; rust/linkedspec-runtime/src/engine.rs helper dispatch; t/phase0_regression.t; rust/linkedspec-runtime/tests/integration_test.rs; docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md; docs/linkedspec-book/src/appendix/helper-contract-catalog.md; docs/linkedspec-book/src/appendix/formal-grammar.md"
reverify: "rg -n \"SPEC-FORMAT-TERSE\\.3\\.2\\.3\\.2|str_eq|str_ne|str_gt|str_ge|str_lt|str_le\" docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md docs/linkedspec-book/src docs/knowledge t/phase0_regression.t rust/linkedspec-runtime/tests/integration_test.rs && perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm && prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_3_2_3_2_string_comparison_helpers_run"
---

# Terse String Comparison Bridge Contract

`SPEC-FORMAT-TERSE.3.2.3.1` locked the contract, and
`SPEC-FORMAT-TERSE.3.2.3.2` implements it on Perl and Rust.

Accepted explicit bridge names:

- `str_eq(lhs,rhs)`
- `str_ne(lhs,rhs)`
- `str_gt(lhs,rhs)`
- `str_ge(lhs,rhs)`
- `str_lt(lhs,rhs)`
- `str_le(lhs,rhs)`

These names preserve the prior lexical string comparison semantics of the bare
`eq`/`ne`/`gt`/`ge`/`lt`/`le` helpers before `.3.2.3.3`. They are shipped two-argument string predicates, not numeric helpers,
not receiver-dot methods, and not comparison symbol callees.

Current shipped behavior after `.3.2.3.3`: use `str_*` for lexical comparisons, and use `num_*` helpers,
bare comparison word aliases, comparison symbol aliases, or number receiver terminals for numeric comparisons.

Bare comparison words are no longer string-comparison compatibility aliases. Repo-owned lexical string examples
should use `str_*`; `eq`/`ne`/`gt`/`ge`/`lt`/`le` are numeric aliases.

`SPEC-FORMAT-TERSE.3.2.3.4` later added comparison symbol aliases. The next frontier is
`SPEC-FORMAT-TERSE.3.3` for expression-valued assignment and `=(target,value)` equivalence.
