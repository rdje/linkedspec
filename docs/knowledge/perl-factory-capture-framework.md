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
  - "which switch callbacks have private emission frames"
  - "which output helper callbacks have private emission frames"
  - "does print_each preserve optional kind two-read selection and match aliases"
  - "how do direct ControlFlow and rule apply calls preserve context and lookup order"
date: 2026-10-18
status: framework and bounded Contracts/MethodLowering/FlowExpr/ControlFlow required families verified; optional kind and direct/rule boundaries verified; default/pipeline owners open
tags: [perl, actionir, callbacks, contexts, identity, source-emission]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.1 verifies224 assertions,30 native differential modes,11 effective semantic source faults and17 supplied suites in136 files. The initial four failed identity checks and actual native closure-reference probe are retained; only the fixture factory changed after that diagnosis. Complete book and reason-sensitive evidence controls are retained beside the owner."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/publish.py. Prior inputs:2b35b77ea."
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

The initial framework fixture assumed separate no-lexical-state factory calls
returned distinct references. Native probes instead observed a shared CODE
reference; lexical-state closures supply distinct identities for those tests.
The original four failed checks, first instrument and exact corrected fixture
remain with .1. Production source was unchanged by this fixture correction;
this is a local observation, not a universal cross-version closure rule.

Contracts, MethodLowering, FlowExpr and bounded ControlFlow repairs have their
individual owners below. Pipeline activation, output construction/mapping,
complete private Phase0 and canonical admission remain with the original owners;
the quoted-first replacement defect is unchanged. EmitContext facade selection
and resolved calls are owned by perl-emitcontext-callback-capture. Contracts
construction is verified independently.

The Contracts draft repeated that lifetime premise. Its original and corrected
native probes remain with .2.1.0; only the fixture changed. See
perl-contract-dependency-capture for the current integration boundary.

Current own-constructor registration is verified by .2.1.1; see
docs/knowledge/perl-contract-constructor-capture.md. Earlier .2.1.0 reviewers now
require exactbe7d70719 historical inputs.

MethodLowering family evidence lives in the individual callback cards and
docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. Original owner reviews retain their
recorded accepted Git input boundaries. MEMORY.md and that tree's frontier own
current selection; this framework card does not duplicate a changing next leaf.

Correction2026-10-10 (.3.1.4): remove the stale local-return/value next-leaf
projection. Historical evidence stays in its original owner.

Required FlowExpr .4.0 binds five required validators. Validation, eager
reference selection, original diagnostic lines and public maps remain native.
Callbacks stay scalar under scalar/list/void owners. Local trim mutation leaves
the caller intact; normalizer writes reach the shared parser argument array.
Opaque children cannot donate parent packets; a registered matching child keeps
its own. Exact native, source-fault and supplied-consumer evidence stays with
.4.0. Optional kind .4.2 and defaults .4.1 have separate accepted owners;
complete helper/private/parent admissions remain open.

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

ControlFlow foundation .5.0 binds three validators/seven roles in control value,
switch case value and bare marker normalization. Switch tag normalization keeps
its native list context in the hash constructor with parent publication disabled;
trim, method value and composite stay scalar. Validation/selection precede guards;
local trim and already selected references survive map replacement. Control value
falls back from empty brace-method output to the original expression; switch
regex bypasses composite, and bare tags normalize after successful composite.
Native marker aliases remain. Exact proof stays with .5.0. The mixed default map
has seven EmitContext references and fixed ValueExpr extraction; .5.7 owns selection.

Branch expansion .5.1.0 binds trim/split through one validator. Both stay scalar;
validation and selection are eager. Plain text becomes one element, braces return
the actual splitter array (including empty), and non-ARRAY/blessed results decline.
The match-body argument rejects writes despite a clear readonly flag; copying
loses that constraint. See perl-match-alias-writability. Exact native/source-fault/
supplied proof remains with .5.1.0 and its accepted Git boundary.

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

If/while .5.2 binds six required validators/seven roles: local parser plus scope
normalizer in if, and normalizer in elseif/else/endif/inline-if/while. Selection,
validation and scalar contexts stay native. Parser hashes and normalizer arrays
retain their references; neither ordinary return can retain a scalar emission
packet, even when its actual callback is eligible. Inline-if normalizes the
original parser array and its second parser call aliases its element; inline-action
bypass shallow-copies the array. Else attached-action failure leaves else_seen set.
Controlled empty-split while advances guard7 to8; nested while uses8 then9.
The complete native probe has356 warm/314 cold rows. Identical1750 assertions
retain294 original REDs/1456 controls/all GREEN;16 full-source faults reject.
First350/308 observations remain frozen; only two overwritten case labels and a
duplicate guard change in the complete instrument. These injected dependency
observations do not claim facade execution or full pipeline admission.

Switch .5.3 binds six required normalizers. Scalar context, actual array references, aliases and native state remain exact. Inline branch detection bypasses the outer normalizer; branches still normalize. Failed default actions leave default_seen set. Endcase closes the active case; endswitch pops one state. Native333/297 rows recur exactly; identical1641 assertions retain273 original authority REDs/1368 controls/all GREEN. Later owners remain open.

Output .5.4 binds parser roles in all four helpers, plus print_each trim/extraction. Trim aliases the parsed argument cell. Matching registered scalar helpers retain their own packet; parser hashes cannot. Legacy labels stay native.

Optional print_each kind .5.5 retains both reads, guarded scalar dispatch,
match-alias write rejection, original errors/effects and lazy loading. Actual
CODE uses its own capture; opaque native-call thunks isolate other selections.
Earlier framework prose is condensed on2026-10-18; original bodies and the first
tied-map snapshot failure remain in Git/checkpoints.

Direct/rule .5.6 gives selected direct CODE its own native tail-call context.
Scalar calls use separate captures; list/void calls disable publication. Rule
apply stays scalar and selects its field once after candidate construction.
Actual CODE uses its own identity; other selections use an opaque native thunk
at the original error line. Rejected rule mutation reaches the same trimmed slot
seen by the next rule; candidate counters stay private while nested references
remain shared. Tied-fetch side effects distinguish selection order. No function
name installs registration. Earlier statistical prose is condensed on2026-10-18;
its complete original bodies and measurements remain in accepted Git/task owners.
