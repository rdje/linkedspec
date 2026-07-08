---
id: terse-assignment-expression-closure
title: "SPEC-FORMAT-TERSE.3.3.4 closed assignment expressions and temporarily kept assign as a legacy alias; SPEC-FORMAT-TERSE.6.2.3.2 later retired authored spec-file assign(...)."
answers:
  - "is SPEC-FORMAT-TERSE.3.3 fully closed"
  - "what happened in SPEC-FORMAT-TERSE.3.3.4"
  - "should new docs use assign or set after assignment expression closure"
  - "is assign still supported after terse assignment closure"
  - "what oracle fixture covers all assignment expression value forms"
  - "does assignment expression closure cover user function bodies"
  - "is there a next SPEC-FORMAT-TERSE PNT leaf after 3.3.4"
date: 2026-07-04
status: confirmed
tags: [spec-format-terse, assignment, expressions, docs, mdbook, oracle, rust-parity, task-tree]
evidence: "SPEC-FORMAT-TERSE.3.3.4 updated docs/tasks/SPEC-FORMAT-TERSE.md, docs/TASK_TREE.md, ROADMAP_V2.md, MEMORY.md, CHANGES.md, DEVELOPMENT_NOTES.md, and LIVE_ACHIEVEMENT_STATUS.md. It added phase0 subtest spec_format_terse_3_3_4_assignment_expression_closure, Rust runtime test terse_3_3_4_assignment_expression_closure_run, and oracle fixture rust/linkedspec-runtime/tests/corpus/terse_3_3_4_assignment_expression_closure. At that closure, public mdBook examples preferred set(...) or operator assignment while assign(...) was still a documented legacy alias. SPEC-FORMAT-TERSE.6.2.3.2 later retired authored spec-file assign(...); current docs/specs use LHS = RHS or set(...)."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_4_assignment_expression_closure_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle && rg -n '\\bassign\\s*\\(' docs/linkedspec-book/src"
---

# Terse Assignment Expression Closure

`SPEC-FORMAT-TERSE.3.3.4` closes the parent `.3.3` assignment-expression contract after the scalar, aggregate,
array-append, and hash-index implementation leaves landed.

The closure fixture proves the forms compose together on Perl and Rust:

- scalar assignment values: `name = value`
- operator-call assignment: `=(target, value)`
- canonical helper assignment: `set(target, value)`
- historical legacy helper compatibility at `.3.3.4`: `assign(target, value)`; retired from authored specs by `.6.2.3.2`
- user-function body assignment
- direct RHS shape assignments for arrays and hashes
- mutation assignment values: `items += value` and `meta[key] = value`
- aggregate snapshot reads after assignment/mutation
- receiver-chain terminals such as `.count()` and `.count_keys()`

The documentation policy after closure is:

- New public examples should prefer `set(...)`, `name = value`, `items += value`, and `meta[key] = value`.
- At `.3.3.4`, `assign(...)` remained supported for compatibility and was documented as a legacy alias.
- After `.6.2.3.2`, current authored specs use `target = value` or `set(target, value)` instead.

At `.3.3.4`, the active `SPEC-FORMAT-TERSE` roadmap had no concrete PNT-eligible leaf until later user
reactivations. `SPEC-FORMAT-TERSE.13.5` later closed the parent terse-format task tree; future terse-format work
requires a newly activated/split leaf.
