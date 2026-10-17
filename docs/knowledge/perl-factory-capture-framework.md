---
id: perl-factory-capture-framework
title: Actual callback registration and native dependency contexts have separate private boundaries
answers:
  - "how do actual factory callbacks register private emission authority"
  - "how are injected scalar list void dependencies isolated"
  - "can a known parent inherit an opaque dependency publication"
  - "why do two Perl factory calls return the same callback reference"
  - "does private factory capture preserve callback aliases and error objects"
  - "which required FlowExpr callbacks have separate private captures"
  - "do FlowExpr normalizers retain parser argument array mutations"
  - "does required FlowExpr capture preserve native validation line locations"
  - "how does FlowExpr preserve optional kind second selection and authority"
  - "how are actual FlowExpr default callbacks selected"
  - "does FlowExpr default construction preserve scalar list void factory contexts"
  - "which ControlFlow foundation callbacks run in list context"
  - "does ControlFlow retain selected lowerers after dependency map replacement"
  - "which attached parser callbacks have separate private frames"
  - "does attached parsing preserve its native substring lvalue"
  - "does single-statement trim preserve aliases and branch candidate state"
date: 2026-10-17
status: framework, Contracts, MethodLowering and FlowExpr bounded owners verified; ControlFlow foundation/expansion/attached parser/single statement verified; later ControlFlow and pipeline open
tags: [perl, actionir, callbacks, contexts, identity, source-emission]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.1 verifies224 assertions,30 native differential modes,11 effective semantic source faults and17 supplied suites in136 files. The initial four failed identity checks and actual native closure-reference probe are retained; only the fixture factory changed after that diagnosis. Complete book and reason-sensitive evidence controls are retained beside the owner."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.18-final-claim.py. Complete prior507/full117862 remain at e2ec1e96b; dated captures stay retired."
---

`SourceEmissions::_register_emission_producer` retains the actual CODE reference
only in the current source-token/producer scope and returns that same reference.
Public names and copied metadata cannot register a different callback. Retaining
an already registered actual reference still selects that callback. Nested source
and producer invocations cannot borrow or leak registrations, including fatal
exits. Strong references last until producer-scope exit; there is no global cache.

`_invoke_emission_dependency` shifts the actual callback and forwards the original
argument aliases. Scalar calls use a separate `_capture_emission` and return its
ordinary actual value. List and void calls keep their native contexts with the
enclosing publication slot locally disabled. An opaque dependency can call a
producer and return an equal literal without lending its nested publication to
the parent. Successful callback error effects and fatal exception objects retain
their native behavior. Public dependency/context maps and callback fields stay
unchanged.

A known child's explicit actual capture can retain its own packet; the parent's
equal result does not inherit it. Later output builders must explicitly compose
retained child captures. The ordinary-value helper does not expose that child
capture as a new public return field.

The initial fixture used an anonymous sub with no captured lexical state and
assumed that separate factory calls returned distinct references. The actual
retained native probe shows that this Perl returns one shared CODE reference for
that factory; a factory with lexical state returns distinct closures. Four draft
identity checks therefore tested the wrong premise. The corrected fixture adds
lexical state; production bytes are identical before and after that correction.
This is a measured local observation, not a universal cross-version closure rule.

Contracts registration/call sites are verified in the linked children.
MethodLowering's seventeen original ingress sites and FlowExpr's defaults/calls have bounded repairs. ControlFlow and RewritePipeline remain later owners in
`docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md`. Output construction, mapping, complete
private Phase0 and canonical admission remain with the original self-containment
owners. The quoted-first replacement defect is unchanged.

EmitContext now owns its definition-bound facade selection and resolved-call
prerequisite; see docs/knowledge/perl-emitcontext-callback-capture.md. Actual
Contracts callback construction is verified separately; pipeline activation remains open.

The same no-lexical-state lifetime premise recurred in the Contracts draft. Its
exact original/current probe is retained under PERL-PRIVATE-FACTORY-CAPTURE.2.1.0;
only the fixture changes, and lexical-state callbacks release on both boundaries.
Current dependency integration and bounded original235 preservation are reviewed by
that owner; see docs/knowledge/perl-contract-dependency-capture.md. The .2.0
reviewer now requires its exact2d8784780 historical input boundary.

Current own-constructor registration is verified by .2.1.1; see
docs/knowledge/perl-contract-constructor-capture.md. Earlier .2.1.0 reviewers now
require exactbe7d70719 historical inputs.

MethodLowering family evidence lives in the individual callback cards and
docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. Original owner reviews retain their
recorded accepted Git input boundaries. MEMORY.md and that tree's frontier own
current selection; this framework card does not duplicate a changing next leaf.

Correction dated2026-10-10 under .3.1.4: the previous paragraphs incorrectly
called local-return/value .3.1.2.2 next after those children and later guarded
AST children had already landed. Their historical evidence is unchanged; only
the stale current projection is removed.


Required FlowExpr callbacks, .4.0 (2026-10-12), use actual CODE identity in
separate private captures through five required-validator returns. Validation,
selection order and original diagnostic lines stay intact; public dependency maps
retain their references. All622 native rows match before/after, with387 warm/235
cold rows and exact fresh-process recurrences. Native callback sites are scalar
under scalar/list/void owners. Local trim mutations leave the caller scalar intact;
normalizer mutations reach the shared parser argument array. Successful errors,
fatal objects, fallback values and require-only lazy loading remain native.
Children cannot donate equal-text parent packets; a registered child retains its
own matching packet. Identical1795 assertions retain490 original authority REDs,
1305 controls and all current GREEN. Thirteen effective source faults include the
exact original490-failure inverse. Complete input/channel capsules are retained.
Optional bare_symbol_kind and actual default registration have separate accepted .4.2/.4.1
owners; this does not admit the complete helper/private/parent pipeline.

Historical header archive: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/knowledge-headers.md` (perl-factory-capture-framework). The complete original fact body and runtime observations are retained; the first uncommitted FlowExpr proof replays from its complete supplied bytes through the sibling replay.py.

Optional FlowExpr kind .4.2 preserves the original first CODE check and second
selection, both guarded invocation branches, native match aliases, scalar calls,
coercion/error/fatal effects and lazy loading. Only an actual unblessed CODE
selection carries its registration; native symbolic/blessed/amp-callable dispatch
stays opaque. Native delegation occupies the original opening condition line.
The first continuation-line candidate changes48 diagnostic comparisons; the next
if-condition lexical candidate fails266 checks and actual strict-vars compilation.
Both full sources/channels stay frozen. A completed lexical declaration before
the condition fixes scope without changing the native diagnostic line. The final
762 assertions retain154 original REDs/608 controls/all GREEN; all300 native rows
and exact fresh-process recurrences stay unchanged. Fourteen full-source faults
are effective, including the exact154-failure inverse. Defaults and independent
admissions remain open; the task tree and current readonly proof own signoff.

FlowExpr defaults select a separate nine-reference definition-owned catalogue in
EmitContext, through the built-in target and current actual source/producer scope.
The public map and callbacks keep their original references. Equal names, copied
names, custom target aliases and unrelated method/contract defaults cannot select
new authority. Retained native references remain selectable after replacement.
Nested scopes cannot borrow outer selection; normal/fatal exits restore the actual
outer registry, and completed invocation registries release. Native facade CODE
references remain module-owned; no universal native-reference release is claimed.

The default factory forwards native scalar/list/void build context, errors and
fatal objects. Scalar/list returned maps select their actual native callbacks;
a void call performs the native build and returns no map to select. Cold calls
load neither SourceEmissions nor Trace. Registration iterates a Perl hash and
stores an identity set: its event order is unspecified, while every actual native
callback is registered once. Original/current ordinary observations and contexts
remain exact; two retained warm registration orders differ without a raw-byte
ordered recurrence claim. Registration does not itself produce or compose output.

ControlFlow foundation .5.0 isolates required calls in control value, switch case
value and bare zero-argument marker normalization (three validators/seven roles).
Native-first observation locates the tag normalizer's list context in the switch
hash constructor; SourceEmissions explicitly clears its list publication frame.
Trim, method value and composite calls are scalar. Eager validation/reference
selection precedes undefined guards; trim sees a local scalar alias and downstream
map replacement cannot replace an already selected callback. All ordinary rows,
errors/fatal objects and cold loading remain exact. Control value falls back from
empty brace-method output to its original local expression; switch regex bypasses
composite, bare tags normalize after successful composite, and marker aliases stay
native. Source-bound proof retains308 original/current rows,848 paired assertions
with198 original REDs/650 controls/all GREEN, and13 effective source faults. The
original449-input/106177-byte default publication remains historical at aa8823343.
ControlFlow defaults have a mixed provider: seven target callbacks and the fixed
ValueExpr extract_array_symbol_name reference; later .5.7 owns exact selection.

Branch expansion .5.1.0 isolates trim/split through one original required-validator
return. Both actual callbacks stay scalar; validation/reference selection is eager.
Plain text becomes one element, braces return the actual splitter array (including
empty), and non-ARRAY/blessed results decline. The named body is a native match
argument: its clear readonly flag still accompanies write rejection. Copying
arguments loses that constraint; see perl-match-alias-writability. Original/current
134 rows match;368 paired assertions retain82 original REDs/286 controls/all GREEN,
and10 complete source faults reject. Full foundation428-input/100775-byte claim
remains historical at9f9b47973. No later ControlFlow/pipeline admission is inferred.

Attached parser .5.1.1 binds one required validator/two roles. Nested marker trims
already have private frames; both direct parser calls and head trim gain their own.
The retained v5.34.1 probe identifies the head substring argument as LVALUE, with
clear readonly flag and writable shared storage. Its mutation changes the scalar
held by the first parser call; copying arguments loses that alias and reference
type. Actual call/argument-array references and typed source_method reconstruction
stay native. Truthy injected parser results forward unchanged; false results
continue the original attached-block scan. Registration still requires actual
callback identity; reconstructed source fields alone grant no emission authority.

Single-statement .5.1.2 binds its required trim through one validator. The actual
callback stays scalar with a writable local slot; mutation leaves the caller intact.
Validation, tied-map selection, closure prefixes, direct AST/control traversal and
rule candidate state remain native. Candidates copy stack-entry hashes/counters,
share nested references, and commit only defined nonempty changed outputs (`0`
included). This preserves existing shallow-copy semantics, without admitting later
direct/rule invocation owners or rollback of external effects.
