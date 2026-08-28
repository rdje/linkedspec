---
id: typed-source-location-cursor-algebra-direction
title: Typed immutable positions and spans unify cursor, capture, recursion, segmentation, and parser composition
answers:
  - "what is the approved typed source location algebra"
  - "how should LinkedSpec make cursor and capture more expressive"
  - "are positions and spans first class in LinkedSpec"
  - "what coordinate system do portable LinkedSpec spans use"
  - "how do cursor transactions work"
  - "does transactional cursor control add systemic backtracking"
  - "what can cursor rollback restore"
  - "can cursor rollback undo AST or user variable mutations"
  - "how do recursive rules expose entry match and exit positions"
  - "how should a captured span be passed to another spec parser"
  - "how does span native progressive parsing preserve provenance"
  - "how does typed source location relate to capture gaps"
  - "which task owns lossless segmentation syntax"
  - "which diagnostics protect cursor and span safety"
  - "what owns the typed cursor span implementation program"
date: 2026-08-12
status: accepted architecture; internal values, transaction composition, recursive observation, lossless-gap composition, and progressive dispatch recurrence complete
tags: [architecture, cursor, source-location, spans, capture, recursion, parser-composition, diagnostics, portability]
evidence: "Director approval on 2026-07-29 plus ADR 0056. FUTURE-PARITY-BACKLOG.14.1 completed the executable base model and structural teaching; .14.2 completed the internal immutable value/projection layer on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; .14.3 closed exact six-runtime recognition transactions at rollout 9/9; .14.4 closed recursive-observation recurrence and public projection; .14.5.1 composed the complete separate lossless-gap authority; .14.6.0.1 corrected the typed transaction projection to 11 complete / 3 pending / 152 mutations; and .14.6.7 binds exact progressive recurrence, promoting only progressive_span_dispatch for current 12 / 2 / 170 truth."
reverify: "rg -n 'source-location algebra|Cursor transactions|Progressive and staged parsing consume spans|Lossless segmentation|FUTURE-PARITY-BACKLOG[.]14[.]0[.]1' docs/decisions/0056-typed-source-location-and-cursor-algebra.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

LinkedSpec's approved target is one small immutable algebra rather than another flat expansion of helper names:

- source identity is caller-authorized decoded input, never a path or backend object;
- a position is a zero-based Unicode-scalar offset within one source;
- a span is a same-source half-open `[start, end)` pair with provenance;
- line/column and UTF-8 byte coordinates are derived evidence; and
- derived text retains an ordered list of contributing spans instead of pretending it is one contiguous interval.

The live cursor, anonymous capture boundary, and named marks remain mutable state local to one rule invocation.
Existing capture/mark/cursor/input/entry/match helpers project immutable positions, spans, text, or measurements from
that state. Recursive children receive the current position, derive their own intrinsic seek/consume policy, and may
expose read-only entry/match/accepted-exit boundaries plus bounded parent/child provenance.

A cursor transaction is explicit and performs one bounded recognition attempt. It can restore only the owning
invocation's cursor, anonymous boundary, and named-mark snapshot. It does not discover alternatives, unwind callers,
or roll back user variables, AST mutation, output/diagnostic events, registry work, external calls, or host state.
An uncommitted path must therefore be recognition-only. Repetition, recursion, and staged queues must prove cursor
advance or another well-founded decreasing measure.

Progressive/staged dispatch should receive a span plus source authority rather than an anonymous copied string, so
child diagnostics map exactly to the original source. This grants no implicit file, registry, compilation,
execution, or policy authority. Lossless `@capture_gaps` prefix/gap/tail segmentation uses the same span model but
keeps its existing syntax/lifecycle/migration owner in `docs/tasks/INTER-MATCH-GAP-CAPTURE.md` and ADR `0045`.

ADR `0056` ratified `recognition_checkpoint()` / `recognize_once(token, call(Rule))` /
`recognition_commit(token)` / `recognition_rollback(token)` surface. Match presence is a strict boolean and the
child payload remains staged until commit, so falsey successful values are not collapsed into failure. Neutral,
six-runtime transaction admission, recurrence, and public no-drift are complete. Recursive observation is also
privately admitted, recurrent, and publicly projected without public API admission on all six runtimes. Lossless
gap syntax and runtime admission remain exclusively owned by `INTER-MATCH-GAP-CAPTURE.1-.7`; gap and transaction
composition and progressive span-dispatch recurrence are current, while progressive public no-drift, staged
dispatch, and final typed-source no-drift continue under `FUTURE-PARITY-BACKLOG.14.6.8-.14.8`.

Typed transaction, progressive span-dispatch, and staged-AST composition are current at six runtimes and the typed rollout is 13 complete / 1 pending.

Related records: [[cursor-transaction-safety-audit-plan]], [[recursive-source-observation-audit]],
[[lossless-gap-cross-tree-handoff]].
