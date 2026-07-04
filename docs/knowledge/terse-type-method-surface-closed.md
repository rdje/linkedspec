---
id: terse-type-method-surface-closed
title: SPEC-FORMAT-TERSE.7 type-method surface is closed and no-drift reconciled
answers:
  - "is the type method surface closed"
  - "what did SPEC-FORMAT-TERSE.7.4 close"
  - "which receiver method families are current"
  - "which helpers remain function-only after type method audit"
  - "which task follows SPEC-FORMAT-TERSE.7.4"
date: 2026-07-04
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, mdbook, task-tree, knowledge-map]
evidence: "SPEC-FORMAT-TERSE.7.4 closed the type-method no-drift sweep. The current supported receiver families are string/scalar, array/list, hash, and number. String/scalar receiver methods include the pure string links verified in .7.2, including substr(); array/list receivers include pure array links plus terminal reducers sum, avg, median, range, min, and max from .7.3; hash receivers keep the useful pure hash surface from .7.1/.2.3.5.2; number receivers keep scalar numeric num_* first-argument links from .2.3.5.4. Array numeric reducers are array/list receiver methods, not scalar number receiver links. Mutation, lifecycle/control, child-dispatch, parser-state/capture/input/mark readers, declaration helpers, and compatibility aliases remain explicit function/statement/lifecycle surfaces unless a future leaf defines type-correct receiver semantics. No Perl/Rust behavior change was needed in .7.4; the sweep reconciled ROADMAP_V2.md, docs/TASK_TREE.md, docs/tasks/SPEC-FORMAT-TERSE.md, mdBook helper/reference summaries, and Knowledge Map fact cards. No SPEC-FORMAT-TERSE leaf is currently pending; after RUST-PARITY.8.3.1 landed the generated family plan, PNT returns to RUST-PARITY.8.3.2 unless a new terse leaf is split."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.7\\.4|type-method|Receiver-Dot Method Families|scores\\.sum|current frontier|frontier empty|RUST-PARITY\\.7\\.3\\.5' ROADMAP_V2.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md docs/linkedspec-book/src/appendix/helper-contract-catalog.md docs/knowledge && mdbook build docs/linkedspec-book && bash knowledge-map/scripts/check_knowledge_map.sh"
---

`SPEC-FORMAT-TERSE.7.4` is the no-drift closure leaf for the supported-type method audit.

Current receiver families:

- String/scalar: pure string links such as `trim`, `uppercase`, `substr`, and string terminals.
- Array/list: pure array links plus terminal reducers `sum`, `avg`, `median`, `range`, `min`, and `max`.
- Hash: pure hash links plus array bridges and terminal key/count predicates.
- Number: scalar numeric `num_*` first-argument links and terminal comparisons.

Array numeric reducers are array/list receiver methods. They are not scalar number receiver links.

Mutation, lifecycle/control, child-dispatch, parser-state/capture/input/mark readers, declaration helpers, and
compatibility aliases remain explicit function/statement/lifecycle surfaces unless a future task defines safe
receiver semantics and updates Perl/Rust/tests/docs/KM together.

No `SPEC-FORMAT-TERSE` leaf is currently pending. PNT returns to `RUST-PARITY.8.3.2` unless a new terse leaf is
split.
