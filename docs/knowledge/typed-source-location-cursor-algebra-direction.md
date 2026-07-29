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
date: 2026-07-29
status: accepted direction; executable contract and implementation pending
tags: [architecture, cursor, source-location, spans, capture, recursion, parser-composition, diagnostics, portability]
evidence: "Director approval on 2026-07-29 plus ADR 0056. The direction reconciles ADR 0012 staged composition, ADRs 0014/0015 parse jobs and dispatch, ADR 0044 rule-local cursor ownership, ADR 0045 inter-match gaps, the Phase 4 capture/mark taxonomy, and Phase 3's forward-moving non-backtracking model. FUTURE-PARITY-BACKLOG.14.0.1 owns the behavior-free capture and splits executable work into .14.1-.8."
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

ADR `0056` selects no final DSL spelling and changes no current behavior. Neutral schema/fixtures/mutations precede
backend code; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT are admitted independently before recurring and public
no-drift closeout under `FUTURE-PARITY-BACKLOG.14.1-.8`.
