---
id: terse-comparison-call-surface-split
title: "SPEC-FORMAT-TERSE.3.2.3 completes comparison operator calls behind an explicit string bridge."
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
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.4"
date: 2026-07-02
status: current
tags: [spec-format-terse, comparisons, helper-aliases, task-tree, mdbook, rust-parity]
evidence: "SPEC-FORMAT-TERSE.3.2.3 split/ownership and SPEC-FORMAT-TERSE.3.2.3.3/.3.2.3.4 implementations; TOOLBOX call_spec_handler_subst/runtime/flow probes for gt/num_gt/receiver gt/comparison symbols; perl/LinkedSpec/ActionIR/FlowExpr.pm; perl/LinkedSpec/ActionIR/MethodExpr.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; rust/linkedspec-core/src/expr.rs; rust/linkedspec-core/src/validation.rs; rust/linkedspec-runtime/src/engine.rs; docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md"
reverify: "rg -n \"SPEC-FORMAT-TERSE\\.3\\.2\\.3\\.4|numeric comparison symbol|comparison call surface\" docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md docs/linkedspec-book/src docs/knowledge && perl -Iperl -MLinkedSpec::RuleIR::EmitContext -e 'print LinkedSpec::RuleIR::EmitContext::_lower_flow_composite_expr(q{>(10, 2)})'"
---

# Terse Comparison Call Surface Split

`SPEC-FORMAT-TERSE.3.2.3` started as a split/ownership slice and is now implemented through its comparison
symbol child.

Current shipped behavior remains:

- `num_eq`/`num_ne`/`num_gt`/`num_ge`/`num_lt`/`num_le` are numeric comparison helpers.
- Number receiver terminals such as `score.gt(3)` are numeric comparisons.
- `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` are shipped lexical string comparisons.
- Bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` are numeric aliases over the matching `num_*` helpers in flow/helper
  contexts.
- Comparison symbol callees such as `>(a,b)`, `>=(a,b)`, `==(a,b)`, and `!=(a,b)` are numeric aliases over the
  same `num_*` family.

The accepted numeric comparison operator-call surface is ordinary `callee(args)` calls with both word and symbol
spellings:

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
- `.3.2.3.4`: done; comparison symbol callees now map to numeric `num_*` aliases.
- `.3.3`: done/split; expression-valued assignment and `=(target,value)` equivalence are now split before code.
- `.3.3.1`: done; scalar assignment expression values and scalar `=(target,value)` equivalence now ship.
- `.3.3.2`: done; direct-shape assignment expression values now ship, with current storage behavior superseded by
  the later `.11` duck-typed assignment facts.
- `.3.3.3`: done; array append and hash-index mutation expression values now ship.
- `.3.3.4`: current next task; legacy function spelling cleanup and full assignment-expression closure.

`=(target,value)` is not part of the comparison-symbol slice. It remains assignment operator-call syntax owned
by `SPEC-FORMAT-TERSE.3.3`, with scalar and aggregate direct-shape subsets implemented first under `.3.3.1` and
`.3.3.2`, and mutation assignment values implemented under `.3.3.3`; `=>` remains the blind-call edge operator.
