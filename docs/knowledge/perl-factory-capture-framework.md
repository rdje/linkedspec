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
  - "how does ControlFlow select mixed-provider default callback references"
  - "how do default factories preserve package object overload effects"
date: 2026-10-18
status: framework and bounded Contracts/MethodLowering/FlowExpr/ControlFlow required families verified; optional/direct/rule and mixed-provider defaults verified; pipeline owners open
tags: [perl, actionir, callbacks, contexts, identity, source-emission]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.1 verifies224 assertions,30 native differential modes,11 effective semantic source faults and17 supplied suites in136 files. The initial four failed identity checks and actual native closure-reference probe are retained; only the fixture factory changed after that diagnosis. Complete book and reason-sensitive evidence controls are retained beside the owner."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/publish.py. Prior inputs:54bb5eb65."
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

The initial no-lexical-state factory calls shared a native CODE reference;
lexical-state closures supply distinct test identities. Original four failed
checks and the corrected fixture remain with .1; this is not a cross-version rule.

Contracts, MethodLowering, FlowExpr and bounded ControlFlow repairs have their
individual owners below. Pipeline activation, output construction/mapping,
complete private Phase0 and canonical admission remain with the original owners;
the quoted-first replacement defect is unchanged. EmitContext facade selection
and resolved calls are owned by perl-emitcontext-callback-capture. Contracts
construction is verified independently.

Contracts construction and MethodLowering family proofs have their individual
knowledge cards and task owners. Their initial closure-identity premise failures
and scope corrections remain in accepted Git. MEMORY.md owns current selection;
older named boundaries and complete original prose remain recoverable.

Required FlowExpr .4.0 binds five validators, preserving eager selection,
scalar context, public maps and diagnostic lines. Trim writes remain local;
normalizer writes reach the shared parser array. Opaque children cannot donate
parent packets; registered matching children keep their own. Exact proof and
separate optional/default admissions remain in their task owners.

Historical header archive: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/knowledge-headers.md` (perl-factory-capture-framework). The complete original fact body and runtime observations are retained; the first uncommitted FlowExpr proof replays from its complete supplied bytes through the sibling replay.py.

Optional FlowExpr .4.2 keeps guarded two-read selection, scalar calls, match
aliases and opaque native non-CODE dispatch. Its completed lexical declaration
occupies the original condition line; failed scope/location candidates remain
retained beside native/source-control proof.

FlowExpr defaults .4.1 selects its exact nine-reference EmitContext catalogue
through built-in target, returned map and actual reference. Equal names, custom
target aliases and other catalogues grant no authority. Retained definitions
survive replacement. Nested scopes cannot borrow selection; normal/fatal exits
restore and completed registries release. Module-owned native references remain
retained. Native factory contexts, errors, fatal objects and actual maps stay
unchanged; list selects returned maps, void selects none. Cold calls load neither
private channel nor Trace. Registration is an unordered identity set, with raw
orders retained separately; it does not produce or compose output.

ControlFlow foundation .5.0 binds three validators/seven roles. Switch-tag
normalization stays in native list context with parent publication disabled;
trim/method/composite calls stay scalar. Eager selected references survive map
replacement. Empty brace-method output falls back to the original expression;
switch regex bypasses composite, and bare tags normalize after successful
composite. Marker aliases remain. Exact proof stays with .5.0.

Branch expansion .5.1.0 binds eager scalar trim/split; text becomes one element,
braces retain the splitter array and non-ARRAY/blessed results decline. The match
body rejects writes despite a clear readonly flag; see perl-match-alias-writability.
Attached parsing .5.1.1 binds both parser calls and head trim. Its native LVALUE
substring is writable shared storage; mutation changes the first call scalar.
Truthy parser results forward unchanged; false results continue the block scan.
Single statements .5.1.2 bind scalar trim to a writable local slot, leaving the
caller intact. Candidates copy stack-entry hashes/counters, share nested refs
and commit nonempty changed results, including0. Source_method reconstruction
and ordinary reference values alone grant no authority. Exact proofs remain in
their owners; earlier full prose is retained in Git and the initial draft archive.

If/while .5.2 binds six validators/seven roles. Scalar calls, parser references
and shared normalizer arrays stay native; hash/array returns cannot retain scalar
packets. Inline-if normalizes the original array and reparses its aliased element;
inline-action bypass shallow-copies it. Else failure keeps else_seen; empty-split
while advances its guard. Original overwritten-case observations and corrected
complete inventory remain retained. These probes do not establish facade execution.

Switch .5.3 binds six required normalizers. Scalar context, actual array references, aliases and native state remain exact. Inline branch detection bypasses the outer normalizer; branches still normalize. Failed default actions leave default_seen set. Endcase closes the active case; endswitch pops one state. Native333/297 rows recur exactly; identical1641 assertions retain273 original authority REDs/1368 controls/all GREEN. Later owners remain open.

Output .5.4 binds parser roles in all four helpers, plus print_each trim/extraction. Trim aliases the parsed argument cell. Matching registered scalar helpers retain their own packet; parser hashes cannot. Legacy labels stay native.

Optional print_each kind .5.5 retains both reads, guarded scalar dispatch,
match-alias write rejection, original errors/effects and lazy loading. Actual
CODE uses its own capture; opaque native-call thunks isolate other selections.
Earlier framework prose is condensed on2026-10-18; original bodies and the first
tied-map snapshot failure remain in Git/checkpoints.

Direct/rule .5.6 isolates selected CODE in native tail contexts; list/void
disable publication. Rules fetch apply once after candidate construction and
invoke scalar. Other callables use opaque native thunks at the original line.
Rejected scalar mutation reaches the next rule; nested candidate refs stay shared.
No name installs registration; exact original bodies remain in accepted Git.

Mixed defaults .5.7 has two definition-owned providers: seven target EmitContext
facades and ValueExpr's fixed native extractor. The built-in target selects its
actual facade references; custom targets add no facade registration. The fixed extractor
keeps its native provider for custom targets too. Same-name replacements remain
opaque; retained definitions survive replacement. Each provider rejects its other
definitions; there is no FlowExpr catalogue union. Factory contexts and actual
returned maps remain native. List selects each map, scalar selects its actual
result, and void selects none. Selection stays source/producer-local and lazy,
restores after fatal exits and does not compose output. Original401/44 proof is
frozen; extended445/53 adds fresh-void and disjoint multi-map controls. Complete
three-owner source inverses and native ledgers remain with .5.7.

Package-object repair .5.7 preserves native OwnerDispatch lookup and overload
effects in ControlFlow, FlowExpr and MethodLowering. Test !ref($pkg) before
comparing a built-in package name: object equality/string conversion must not
run merely to choose private authority. Inherited native references or a forged
equality result grant no new facade registration. Fixed ValueExpr extraction
remains independent. Existing actual registrations survive custom-target reuse;
no-new-grant does not mean revoking a reference already authorized in that scope.
The published-builder oracle retains each owner's original construction context;
MethodLowering builds scalar, while the other two forward. Original uncommitted
546-input evidence is byte/mode preserved before repair and replayed from saved inputs.
