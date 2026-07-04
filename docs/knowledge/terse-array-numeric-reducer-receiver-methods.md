---
id: terse-array-numeric-reducer-receiver-methods
title: SPEC-FORMAT-TERSE.7.3 array numeric reducer receiver methods
answers:
  - "does scores.sum() work"
  - "does scores.avg() work"
  - "does scores.median() work"
  - "does scores.range() work"
  - "does scores.min() work on arrays"
  - "does scores.max() work on arrays"
  - "are array numeric reducers terminal receiver methods"
  - "are sum and avg number receiver methods"
  - "what did SPEC-FORMAT-TERSE.7.3 backfill"
  - "which task follows SPEC-FORMAT-TERSE.7.3"
date: 2026-07-04
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, array, number, reducers, actionir, rust-parity, oracle, mdbook]
evidence: "SPEC-FORMAT-TERSE.7.3 backfilled numeric aggregate reducers as pure terminal methods on array/list receivers: `scores.sum()`, `scores.avg()`, `scores.median()`, `scores.range()`, `scores.min()`, and `scores.max()`. Perl lowers them through the existing numeric aggregate helper family, including sorted/take/uniq array-chain inputs. Rust accepts the same receiver methods and also supports the documented single-array `num_min(array_expr)` / `num_max(array_expr)` and word-alias `min(array_expr)` / `max(array_expr)` forms. Reducer receiver methods are terminal; invalid continuations such as `scores.sum().drop_front(1)` return `undef` / JSON `null`. Scalar number receiver methods remain the `.2.3.5.4` `num_*` first-argument family, so reducers are not scalar number receiver links. Hash receiver methods from `.7.1` already covered the useful pure hash surface; mutating/ambiguous helpers remain explicit statement/function forms. Locked by Perl phase0, Rust integration tests, oracle fixture `terse_7_3_array_numeric_reducer_receiver_methods`, mdBook examples, and KM regeneration."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_7_3 --quiet && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.7.3` is the array/list backfill for numeric aggregate receiver methods.

Accepted terminal array receiver reducers:

- `scores.sum()` -> `num_sum(scores)`
- `scores.avg()` -> `num_avg(scores)`
- `scores.median()` -> `num_median(scores)`
- `scores.range()` -> `num_range(scores)`
- `scores.min()` -> array-form `num_min(scores)`
- `scores.max()` -> array-form `num_max(scores)`

They compose after array-returning receiver links:

```text
scores.sorted().take(3).avg()
scores.uniq().sum()
```

They are terminal receiver values. `scores.sum().drop_front(1)` and `scores.min().sorted()` return
`undef` / JSON `null` rather than generating host-language receiver residue.

This does not add scalar number receiver reducer links. Number receivers still use the first-argument numeric
helper family (`score.abs().ceil().add(2)`, `score.min(3)`, etc.). Hash receiver methods from the `.7.1`
inventory did not need additional backfill in this slice; mutating or ambiguous helpers stay explicit.

The follow-up `SPEC-FORMAT-TERSE.7.4` no-drift sweep is now done. No `SPEC-FORMAT-TERSE` leaf is currently
pending. `TRACE-OBSERVABILITY.1` has since closed its read-only audit, and PNT returns to
`TRACE-OBSERVABILITY.2` unless a new terse leaf is split or another active tree is reprioritized.
