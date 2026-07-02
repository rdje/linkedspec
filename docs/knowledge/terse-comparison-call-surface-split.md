---
id: terse-comparison-call-surface-split
title: "SPEC-FORMAT-TERSE.3.2.3 splits comparison operator calls behind an explicit string bridge."
answers:
  - "what is the comparison call surface split"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3"
  - "are gt and lt numeric aliases now"
  - "are >(a,b) and >=(a,b) implemented now"
  - "what are the explicit string comparison helper names"
  - "why does comparison migration need str_eq"
  - "does =(target,value) belong to comparison symbols"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.1"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.2"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.3"
date: 2026-07-02
status: current
tags: [spec-format-terse, comparisons, helper-aliases, task-tree, mdbook, rust-parity]
evidence: "SPEC-FORMAT-TERSE.3.2.3 split/ownership and SPEC-FORMAT-TERSE.3.2.3.3 implementation; TOOLBOX call_spec_handler_subst/runtime/flow probes for gt/num_gt/receiver gt/comparison symbols; perl/LinkedSpec/ActionIR/FlowExpr.pm; perl/LinkedSpec/ActionIR/MethodExpr.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; rust/linkedspec-core/src/expr.rs; rust/linkedspec-core/src/validation.rs; rust/linkedspec-runtime/src/engine.rs; docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md"
reverify: "rg -n \"SPEC-FORMAT-TERSE\\.3\\.2\\.3\\.3|numeric comparison word|comparison call surface\" docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md docs/linkedspec-book/src docs/knowledge && perl -Iperl -MLinkedSpec::RuleIR::EmitContext -e 'print LinkedSpec::RuleIR::EmitContext::_lower_flow_composite_expr(q{gt(10, 2)})'"
---

# Terse Comparison Call Surface Split

`SPEC-FORMAT-TERSE.3.2.3` is a split/ownership slice, not a parser/runtime behavior change.

Current shipped behavior remains:

- `num_eq`/`num_ne`/`num_gt`/`num_ge`/`num_lt`/`num_le` are numeric comparison helpers.
- Number receiver terminals such as `score.gt(3)` are numeric comparisons.
- `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` are shipped lexical string comparisons.
- Bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` are numeric aliases over the matching `num_*` helpers in flow/helper
  contexts.
- Comparison symbol callees such as `>(a,b)`, `>=(a,b)`, `==(a,b)`, and `!=(a,b)` are not implemented yet.

The accepted future numeric comparison operator-call surface is ordinary `callee(args)` calls with both word
and symbol spellings:

- `eq(a,b)` / `==(a,b)` -> `num_eq(a,b)`
- `ne(a,b)` / `!=(a,b)` -> `num_ne(a,b)`
- `gt(a,b)` / `>(a,b)` -> `num_gt(a,b)`
- `ge(a,b)` / `>=(a,b)` -> `num_ge(a,b)`
- `lt(a,b)` / `<(a,b)` -> `num_lt(a,b)`
- `le(a,b)` / `<=(a,b)` -> `num_le(a,b)`

Because the migration started with bare comparison words serving as string comparisons, implementation was split
behind an explicit string-comparison bridge:

- `.3.2.3.1`: done; explicit string bridge contract locked.
- `.3.2.3.2`: done; `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le` now ship as lexical
  string comparisons.
- `.3.2.3.3`: done; ordinary comparison word calls now map to numeric `num_*` aliases.
- `.3.2.3.4`: current next task; add numeric comparison symbol callees.

`=(target,value)` is not part of the comparison-symbol slice. It remains assignment operator-call syntax owned
by `SPEC-FORMAT-TERSE.3.3`; `=>` remains the blind-call edge operator.
