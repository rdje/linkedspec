---
id: perl-emitcontext-callback-capture
title: EmitContext selects definition-owned references and separates native dependency calls
answers:
  - "how are EmitContext contract default callbacks selected for emission"
  - "can replacing an EmitContext public callback name borrow producer authority"
  - "does EmitContext private callback selection load SourceEmissions or Trace"
  - "does EmitContext copy scalar arguments or forward caller aliases"
  - "can a resolved EmitContext owner or default factory donate nested publication"
date: 2026-10-10
status: bounded EmitContext and Contracts integration verified; other owners/pipeline open
tags: [perl, actionir, emitcontext, callbacks, identity, dependencies]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.2.0 retains345 main/five cold assertions,30 exact native/current observation ledgers,28 actual definition-owned callback selections,six opaque owner/factory publication modes,13 effective semantic source faults and19 direct suites in138 supplied files. Original233 framework bindings remain exact historically. The first duplicate-Trace preflight failure is retained separately from runtime observations."
reverify: "Original framework/EmitContext/dependency reviewers require accepted b21b3bb9/2d8784780/be7d70719 input boundaries respectively. Current block-component integration and original242 inline preservation are reviewed by docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1-review.py under tools/run_python_project_data.sh. One-shot writers are not resume commands."
---

EmitContext retains actual native facade CODE references in a private lexical
catalog when the module loads. Its private contract selector compares the actual
callback with those retained references and returns the same callback. Replacing
a public symbol under an equal name or copying metadata does not select the
replacement. Retaining the original actual callback remains selectable after
symbol replacement. The catalog retains native definitions only, not source
origins, events or invocation-local user callbacks.

Selection is lazy when the private channel is absent. It neither requires
SourceEmissions nor loads Trace. The actual resolved default factory and each
actual resolved owner call have separate private dependency boundaries once the
channel is loaded. An opaque call cannot donate its nested publication to an
eligible native facade, including list/void call paths.

The existing bridge first copies scalar arguments into its local argument array;
shared referenced objects remain actual shared objects. Native/current ledgers
preserve that existing behavior, scalar/list/void contexts, once-only effects,
ordinary scalar/reference/undefined/list returns, fatal object identity and the
exact actual factory map. OwnerDispatch still restores the caller's successful
error state. Shared OwnerDispatch mechanics and public maps remain unchanged.

The framework's direct alias/error rules and this facade's copied arguments/error
restoration describe different existing call boundaries. Do not replace either
with the other's semantics. Contracts construction is verified separately. Other dependency
owners, RewritePipeline scope activation and explicit output composition remain
subsequent owners in docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. Complete private
Phase0, mapped replacement and independent canonical admission remain open.

Contracts private dependency/default integration is now verified; see
docs/knowledge/perl-contract-dependency-capture.md. Actual lower construction and
pipeline activation remain subsequent owners.

Current own-constructor registration is verified by .2.1.1; see
docs/knowledge/perl-contract-constructor-capture.md. Earlier .2.1.0 reviewers now
require exactbe7d70719 historical inputs.

MethodLowering defaults .3.0, required trim .3.1.0 and required inference
.3.1.1 are accepted; inline .3.1.2.0 and block component .3.1.2.1 are accepted; local-return/value .3.1.2.2 and remaining required/optional families are next. Current rules/evidence live in
docs/knowledge/perl-method-default-capture.md. Original owner reviews retain
their recorded accepted input boundaries.

Required inference .3.1.1 is accepted; current native/caller/isolation rules
live in docs/knowledge/perl-method-inference-capture.md. Inline .3.1.2.0 and block component .3.1.2.1 are accepted; local-return/value .3.1.2.2
is next; remaining required/optional and pipeline owners stay open.
