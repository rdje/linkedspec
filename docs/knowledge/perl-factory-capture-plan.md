---
id: perl-factory-capture-plan
title: Bounded owners for actual factory and injected dependency emission capture
answers:
  - "where is actual factory dependency emission capture implemented next"
  - "which task owns invocation-local built-in callback registration"
  - "where is the private dependency scalar list void boundary planned"
date: 2026-10-10
status: planned; no implementation or new measurement claimed
tags: [perl, actionir, source-emission, planning, callbacks]
evidence: "The original factory planning leaf routes the existing selected protocol to docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. Existing stable IDs and task consumers remain in place; no partition, capacity or runtime change."
reverify: "Read docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md and its referenced original planning leaf/plan; implementation status and verification live beside each stable owner."
---

The next private factory/dependency implementation is owned by the linked
`docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md` tree. Its first leaf adds invocation-local
actual callback registration and separate dependency invocation boundaries in
SourceEmissions; later owners cover Contracts, MethodLowering, FlowExpr,
ControlFlow and final RewritePipeline activation. The detailed proposed protocol
is retained under
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0-plan.json`.

The plan reuses the actual opaque-dependency diagnosis in
`docs/knowledge/perl-private-input-authority-selection.md` and the independently
accepted current input joins in `docs/knowledge/perl-input-composition-acceptance.md`.
It adds no new runtime observation. Actual built-in callback references may
register within the current source/producer scope; public names, copied metadata
and equal values cannot register an unknown callback. Every injected dependency
call needs its own capture boundary. Native list/void contexts require isolated
nonpublishing calls because the current packet protocol accepts scalar strings.

Public dependency/context maps and returned callback fields keep their actual
references. A private lexical thunk may retain and invoke the actual callback
without rebinding those maps; each owner must prove original aliases, context,
effects and error behavior. Later trusted output builders explicitly retain and
compose actual child captures rather than inheriting a nested publication.

This is a linked work owner, not a migration: existing self-containment IDs and
consumers remain in their canonical file. After the implementation owners,
independent composition returns to the existing self-containment acceptance leaf;
full private Phase0, typed/raw output, mapping and independent canonical admission
remain open. Current public book behavior and the quoted-first replacement defect
are unchanged by planning.

Before framework implementation, P1 `RUST-DEPENDENCY-WARNING-ZERO.8` corrects contrary current
Rust warning roadmap projections. It requires no dependency build or implementation
access; afterward PNT returns to the first factory framework owner.
