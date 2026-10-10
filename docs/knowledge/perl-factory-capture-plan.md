---
id: perl-factory-capture-plan
title: Bounded owners for actual factory and injected dependency emission capture
answers:
  - "where is actual factory dependency emission capture implemented next"
  - "which task owns invocation-local built-in callback registration"
  - "where is the private dependency scalar list void boundary planned"
date: 2026-10-10
status: framework, EmitContext and Contracts dependencies/construction accepted; MethodLowering defaults accepted; required trim/inference/inline/block-component accepted; remaining dependencies and pipeline planned
tags: [perl, actionir, source-emission, planning, callbacks]
evidence: "The original factory planning leaf routes the existing selected protocol to docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. Existing stable IDs and task consumers remain in place; no partition, capacity or runtime change."
reverify: "Read docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md and its referenced original planning leaf/plan; implementation status and verification live beside each stable owner."
---

The next private factory/dependency implementation is owned by the linked
`docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md` tree. Its first leaf now implements invocation-local
actual callback registration and separate dependency invocation boundaries in
SourceEmissions; later owners cover Contracts, MethodLowering, FlowExpr,
ControlFlow and final RewritePipeline activation. The detailed proposed protocol
is retained under
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0-plan.json`.

The plan reuses the actual opaque-dependency diagnosis in
`docs/knowledge/perl-private-input-authority-selection.md` and the independently
accepted current input joins in `docs/knowledge/perl-input-composition-acceptance.md`.
The planning record adds no runtime observation. Current framework evidence is
owned by `docs/knowledge/perl-factory-capture-framework.md`. Actual built-in callback references may
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

Projection correction `RUST-DEPENDENCY-WARNING-ZERO.8` now aligns the current Rust warning
roadmaps with the adopted public RGX/upstream boundary. The standalone framework
and the EmitContext/Contracts children are accepted; MethodLowering defaults `.3.0` are accepted; required trim `.3.1.0` is accepted; inference `.3.1.1` is accepted; inline `.3.1.2.0` is accepted; block `.3.1.2.1` is accepted; local-return/value `.3.1.2.2` and remaining required/optional calls are next. No dependency build or implementation access was needed.

The bounded EmitContext prerequisite .2.0 is accepted; actual Contracts/default
callback construction is .2.1. Its current identity and native bridge rules live in
docs/knowledge/perl-emitcontext-callback-capture.md.

Contracts dependency/default selection .2.1.0 and actual local/delegated
lower construction .2.1.1 are accepted; MethodLowering defaults .3.0 are accepted; required trim .3.1.0 is accepted; inference .3.1.1 is accepted; inline .3.1.2.0 is accepted; block .3.1.2.1 is accepted; local-return/value .3.1.2.2 and remaining required/optional calls are next. Current binding and target rules
live in docs/knowledge/perl-contract-dependency-capture.md.

Actual local/delegated lower construction .2.1.1 is accepted. MethodLowering defaults .3.0 are accepted; required trim .3.1.0 is accepted; inference .3.1.1 is accepted; inline .3.1.2.0 is accepted; block .3.1.2.1 is accepted; local-return/value .3.1.2.2 and remaining required/optional calls
are next; current constructor authority/ref/lifetime rules live in
docs/knowledge/perl-contract-constructor-capture.md.

Actual MethodLowering default selection .3.0 is accepted; target/ref/map rules and
bounded proof live in docs/knowledge/perl-method-default-capture.md. Required trim .3.1.0 is accepted;
inference .3.1.1 is accepted; inline .3.1.2.0 is accepted; block .3.1.2.1 is accepted; local-return/value .3.1.2.2 and remaining required/optional calls remain next; no separate parent admission is inferred.

Required trim .3.1.0 is accepted; bounded native/caller/isolation evidence lives in
docs/knowledge/perl-method-trim-capture.md. Required inference .3.1.1 is accepted; current evidence lives in
docs/knowledge/perl-method-inference-capture.md. Inline .3.1.2.0 is accepted; current evidence lives in
docs/knowledge/perl-method-inline-capture.md. Block .3.1.2.1 is accepted; current evidence lives in
docs/knowledge/perl-method-block-component-capture.md. Local-return/value .3.1.2.2 is next.
