---
id: terse-assignment-expression-closure
title: "SPEC-FORMAT-TERSE.3.3.4 closes assignment expressions and keeps assign as a legacy alias."
answers:
  - "is SPEC-FORMAT-TERSE.3.3 fully closed"
  - "what happened in SPEC-FORMAT-TERSE.3.3.4"
  - "should new docs use assign or set after assignment expression closure"
  - "is assign still supported after terse assignment closure"
  - "what oracle fixture covers all assignment expression value forms"
  - "does assignment expression closure cover user function bodies"
  - "is there a next SPEC-FORMAT-TERSE PNT leaf after 3.3.4"
date: 2026-07-02
status: current
tags: [spec-format-terse, assignment, expressions, docs, mdbook, oracle, rust-parity, task-tree]
evidence: "SPEC-FORMAT-TERSE.3.3.4 updates docs/tasks/SPEC-FORMAT-TERSE.md, docs/TASK_TREE.md, ROADMAP_V2.md, MEMORY.md, CHANGES.md, DEVELOPMENT_NOTES.md, and LIVE_ACHIEVEMENT_STATUS.md. It adds phase0 subtest spec_format_terse_3_3_4_assignment_expression_closure, Rust runtime test terse_3_3_4_assignment_expression_closure_run, and oracle fixture rust/linkedspec-runtime/tests/corpus/terse_3_3_4_assignment_expression_closure. Public mdBook examples were migrated to prefer set(...) or operator assignment; the appendix helper catalog keeps assign(...) as a legacy alias with current value semantics."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_4_assignment_expression_closure_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle && rg -n \"assign\\(\" docs/linkedspec-book/src"
---

# Terse Assignment Expression Closure

`SPEC-FORMAT-TERSE.3.3.4` closes the parent `.3.3` assignment-expression contract after the scalar, aggregate,
array-append, and hash-index implementation leaves landed.

The closure fixture proves the forms compose together on Perl and Rust:

- scalar assignment values: `name = value`
- operator-call assignment: `=(target, value)`
- canonical helper assignment: `set(target, value)`
- legacy helper compatibility: `assign(target, value)`
- user-function body assignment
- direct RHS shape assignments for arrays and hashes
- mutation assignment values: `items += value` and `meta[key] = value`
- aggregate snapshot reads after assignment/mutation
- receiver-chain terminals such as `.count()` and `.count_keys()`

The documentation policy after closure is:

- New public examples should prefer `set(...)`, `name = value`, `items += value`, and `meta[key] = value`.
- `assign(...)` remains supported for compatibility and is documented as a legacy alias.
- The helper catalog records the current value semantics for legacy `assign(...)`: statement position ignores the
  value, and value position yields the stored scalar or direct-shape aggregate value.

The active `SPEC-FORMAT-TERSE` roadmap has no concrete PNT-eligible leaf after `.3.3.4`. Future backend leaves
`.5.1` and `.5.2` are deferred to roadmap selection, and `.5.3` is blocked on a Lua backend decision.
