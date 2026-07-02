---
id: terse-string-comparison-bridge-contract
title: "SPEC-FORMAT-TERSE.3.2.3.1 locks the explicit str_* string comparison bridge."
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
evidence: "SPEC-FORMAT-TERSE.3.2.3.1 task-tree contract; perl/LinkedSpec/ActionIR/FlowExpr.pm string comparison dispatch; docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md; docs/linkedspec-book/src/appendix/helper-contract-catalog.md; docs/linkedspec-book/src/appendix/formal-grammar.md"
reverify: "rg -n \"SPEC-FORMAT-TERSE\\.3\\.2\\.3\\.2|str_eq|str_ne|str_gt|str_ge|str_lt|str_le\" docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md docs/linkedspec-book/src docs/knowledge && perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm"
---

# Terse String Comparison Bridge Contract

`SPEC-FORMAT-TERSE.3.2.3.1` is a contract/documentation leaf, not an implementation leaf.

Accepted explicit bridge names:

- `str_eq(lhs,rhs)`
- `str_ne(lhs,rhs)`
- `str_gt(lhs,rhs)`
- `str_ge(lhs,rhs)`
- `str_lt(lhs,rhs)`
- `str_le(lhs,rhs)`

These names preserve today's lexical string comparison semantics of the bare
`eq`/`ne`/`gt`/`ge`/`lt`/`le` helpers. They are not numeric helpers, not receiver-dot methods, and not
comparison symbol callees.

Current shipped behavior is unchanged: use the bare string comparison helpers for runnable lexical comparisons,
and use `num_*` helpers or number receiver terminals for numeric comparisons.

Do not write runnable specs with `str_*` yet. `SPEC-FORMAT-TERSE.3.2.3.2` owns implementation of the explicit
string helper family. Bare comparison words can only flip to numeric aliases after that implementation exists
and repo-owned string examples/tests have moved to `str_*` or kept explicit compatibility coverage.

The next frontier after `.3.2.3.1` is `SPEC-FORMAT-TERSE.3.2.3.2`.
