---
id: rust-scalaref-legacy-path-parity
title: Rust supports legacy scalaref paths only in scalaref's second argument; bare path atoms are literal keys and Lispish lispish_x_y is active
answers:
  - "does Rust support scalaref(retv, {content})"
  - "how does Rust parse legacy scalaref paths"
  - "are bare scalaref path atoms literal keys or scalar reads"
  - "why did Lispish output xy instead of the nested y tail"
  - "how is assign(array(word), array()) handled in Rust"
  - "does child return leak into the parent accumulator in Rust"
  - "which fixture proves Lispish Rust parity"
date: 2026-07-02
status: confirmed
tags: [rust, scalaref, Lispish, oracle, RUST-PARITY, runtime]
evidence: "RUST-PARITY.7.5.2 (2026-07-02): rust/linkedspec-core/src/expr.rs adds scoped Expr::ScalarRefPath parsing for scalaref's second positional argument; rust/linkedspec-runtime/src/engine.rs evaluates legacy paths, contains child-return accumulator pushes, skips duplicate action-edge pre-dispatch when the block explicitly calls the child, and replaces explicit aggregate-wrapper assignments. rust/linkedspec-runtime/tests/integration_test.rs has rust_parity_7_5_2 locks; tools/gen_oracle_corpus.pl enables lispish_x_y; corpus_oracle passes over 63 fixtures."
reverify: "cargo test -q --manifest-path rust/linkedspec-core/Cargo.toml parse_scalaref && cargo test -q --manifest-path rust/linkedspec-runtime/Cargo.toml rust_parity_7_5_2 && cargo test -q --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# Rust `scalaref` Legacy Path Parity

`RUST-PARITY.7.5.2` made the Rust backend run the minimal shipped Lispish fixture
`lispish_x_y` (`(x y)` -> Perl reference `["x",["y"]]`).

The parser hook is intentionally narrow. `Expr::ScalarRefPath` is produced only for the
second positional argument of `scalaref(...)` when that argument starts with `{` or `[`.
General brace expressions and normal hash literals keep their existing parsers.

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

`scalaref(...)` and the existing Perl-shaped hash literal spelling are legacy
compatibility surfaces. They are restored here only to match shipped Lispish behavior; the
2026-07-02 user directive is to retire/remove `scalaref(...)`, which needs a separate
task-tree-owned parser/lowering/spec/docs migration.
