---
id: rust-scalaref-legacy-path-parity
title: Rust temporarily supported legacy scalaref paths in RUST-PARITY.7.5.2; SCALAREF-RETIREMENT.4 later removed that support
answers:
  - "did Rust support scalaref(retv, {content}) before retirement"
  - "how did Rust parse legacy scalaref paths before retirement"
  - "were bare scalaref path atoms literal keys or scalar reads"
  - "why did Lispish output xy instead of the nested y tail"
  - "how is assign(array(word), array()) handled in Rust"
  - "does child return leak into the parent accumulator in Rust"
  - "which fixture proves Lispish Rust parity"
date: 2026-07-02
status: historical
tags: [rust, scalaref, Lispish, oracle, RUST-PARITY, runtime]
evidence: "RUST-PARITY.7.5.2 (2026-07-02) temporarily added scoped Expr::ScalarRefPath parsing for scalaref's second positional argument and runtime evaluation for legacy paths so Rust matched the then-current shipped Lispish surface. The same leaf also contained child-return accumulator pushes, skipped duplicate action-edge pre-dispatch when the block explicitly calls the child, and replaced explicit aggregate-wrapper assignments. SCALAREF-RETIREMENT.3 migrated Lispish to direct access, and SCALAREF-RETIREMENT.4 removed ScalarRefPath and runtime scalaref support."
reverify: "rg -n 'RUST-PARITY.7.5.2|SCALAREF-RETIREMENT.4|ScalarRefPath' docs/TASK_TREE.md docs/tasks/SCALAREF-RETIREMENT.md docs/knowledge/scalaref-implementation-removed.md"
---

# Historical Rust `scalaref` Legacy Path Parity

`RUST-PARITY.7.5.2` made the Rust backend run the minimal shipped Lispish fixture
`lispish_x_y` (`(x y)` -> Perl reference `["x",["y"]]`) when that fixture still used
legacy `scalaref(...)` path reads.

That parser hook was intentionally narrow while it existed. `Expr::ScalarRefPath` was
produced only for the second positional argument of `scalaref(...)` when that argument
started with `{` or `[`. General brace expressions and normal hash literals kept their
existing parsers.

Legacy path semantics differ from direct nested access:

- `scalaref(retv, {content})` treats `content` as a literal hash key.
- `scalaref(retv, {"content"})` also reads the literal key.
- `scalaref(retv, {scalar(k)})` evaluates `scalar(k)` and uses the result as the key.
- `scalaref(retv, [0])` reads array index `0`.
- `scalaref(retv, [scalar(i)])` evaluates `scalar(i)` and uses the result as the index.

Do not generalize this to direct access: direct nested access bare atoms keep their later
Channel-2 rule, where `foo[z]` is a scalar index read equivalent to `foo[scalar(z)]`.

Two runtime boundaries were needed for Lispish:

- Child dispatch/call now contains child accumulator pushes after the child returns, while
  preserving the child return value for `retv` and `call(child)`.
- Explicit aggregate-wrapper assignments such as `assign(array(word), array())` replace
  the array working store. Without that replacement, Lispish cleared `word` as a scalar and
  left stale array contents, producing the wrong tail.

`SCALAREF-RETIREMENT.3` migrated the fixture to direct nested access, and
`SCALAREF-RETIREMENT.4` removed `ScalarRefPath` plus runtime helper support. For current
behavior, read [[scalaref-implementation-removed]].
