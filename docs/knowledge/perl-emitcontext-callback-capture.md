---
id: perl-emitcontext-callback-capture
title: EmitContext selects definition-owned references and separates native dependency calls
answers:
  - "how are EmitContext contract default callbacks selected for emission"
  - "can replacing an EmitContext public callback name borrow producer authority"
  - "does EmitContext private callback selection load SourceEmissions or Trace"
  - "does EmitContext copy scalar arguments or forward caller aliases"
  - "can a resolved EmitContext owner or default factory donate nested publication"
date: 2026-10-12
status: EmitContext/Contracts and exact FlowExpr default selection verified; pipeline open
tags: [perl, actionir, emitcontext, callbacks, identity, dependencies]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.2.0 retains345 main/five cold assertions,30 exact native/current observation ledgers,28 actual definition-owned callback selections,six opaque owner/factory publication modes,13 effective semantic source faults and19 direct suites in138 supplied files. Original233 framework bindings remain exact historically. The first duplicate-Trace preflight failure is retained separately from runtime observations."
reverify: "Readonly current review: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/publish.py. Complete accepted .5.1.2 and all earlier headers/inputs remain at736c6a43ef. Capture writers stay retired."
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


The exact FlowExpr default selector owns nine native facade references separately
from the Contracts and MethodLowering catalogues. Shared references can belong to
more than one catalogue; union membership and a public name are not FlowExpr
selection criteria. The actual returned map, built-in target and actual reference
are all required. Its own default-factory/native-context rules live in
`docs/knowledge/perl-factory-capture-framework.md`. Historical integration records
retain their accepted Git boundaries; current work belongs to MEMORY.md.
