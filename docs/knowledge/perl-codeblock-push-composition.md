---
id: perl-codeblock-push-composition
title: Perl deferred push uses live caller identity and independent parameter slots
answers:
  - "does push work inside a Perl deferred codeblock"
  - "how does deferred push preserve static rule precedence"
  - "are Perl codeblock parameters independent scalar references"
  - "can deferred push mutate an active map leaves receiver through an alias"
  - "does a failed Perl codeblock restore caller parameter reference identity"
  - "which repair remains after the Perl composed push fix"
  - "why do copied callbacks in the deferred push fixture close cb to cb"
date: 2026-11-02
status: current bounded implementation; full normalization and runtime admission pending
tags: [perl, codeblock, mutation, caller-identity, language-readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.1 owns CodeblockRuntime/MethodLowering, seventeen native/fresh emitted cases,147 top-level tests with23 nested actual-reference assertions, recurring CI and owner-bound historical audit evolution. Exact canonical result belongs to its commit/receipt."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/codeblock_push_composition_perl.t t/callable_codeblock_literal_contract.t t/uniform_binding_contract.t t/map_leaves_mutation_perl_contract.t"
  - "bash tools/run_python_project_data.sh tests/language-readiness/verify_objectives.py"
  - "bash tools/run_python_project_data.sh tools/check_composed_objective_contract.py"
---

`CodeblockRuntime::_eval_call` handles existing bare-target push before generic
value-call dispatch. Exact arity rejects before argument work. Operands evaluate
once, then the current destination scalar value feeds `BindingRuntime::push_value`;
its copy-on-write array is published through the actual caller reference after
`assert_receiver_writable`. An argument can rebind the target before this snapshot.
Wrong-kind diagnostics remain the existing BindingRuntime channel.

Generated bound-codeblock and with invocation sites pass explicit descriptor,
input and match-info references in an optional sixth invocation argument. Nested
codeblocks forward it. For two bare identifiers, a current rule handler has priority
and its result appends to the second binding, matching existing static push.
This invocation context is outside the unchanged plain eight-field codeblock record;
no codeblock record stores a host closure or captured environment.

`invoke` copies arguments before parameter installation, saves caller reference
mappings and gives each parameter a fresh temporary scalar reference. Those mappings
restore after success or failure; nonparameters retain actual caller references.
Consequently an active receiver alias rejects push by identity, but a same-named
temporary parameter is independent and writable. Failure restoration rethrows the
actual caller exception object rather than replacing it.

The regression executes17 sources on native Get and in a fresh child that loads
emitted artifacts without calling the authoring compiler. It preserves the emitted
failure carrier's stage/code/source identity beside original typed detail.147 top-level
tests have23 nested actual-object assertions: detached copied arguments/prior
push results, caller slot restoration, once-only rule failure, opaque exception
identity, no arity argument effects and alias-sensitive atomic receiver rejection.
Existing callable/binding/map suites pass30 top-level tests. Historical objective
audit keeps24 checkpoints/257 references/149 inputs/134 logs, nine CI controls and
six Perl-storage controls. Exact tracked-test/prove insertions normalize before earlier
insertions; four exact inventory replacements recover the historical27-owner script.
The managed Perl storage census is28, with this regression as the sole new allocator.

The seven original controls now give six successes and one callback-function failure.
The unchanged normalization source reaches unknown_helper/decorate with ready1 and
zero raw/fallback/unresolved counts, no result and no diagnostic events. Registered
function child `.1.3.3.0.2` remains next. Startup19 assignment guards,32 caller-function
shadowing,35 boolean literals and87.2/.3 matches/numeric dispatch retain their owners.
No complete neutral execution, other backend parity, new primitive or admission follows.

## Current recursion-label calibration

Canonical restoration20.1.15 reaches four older bridge expectations that predate
TYPE31.6.4.2's origin-matched label repair. Passing `cb` as `callback`, copying it
to `fresh`, transporting it through an Array, or copying it through a compiled
function retains the active callable origin. All four actual native and emitted
errors therefore close `cb` to `cb`, preserving the complete typed diagnostic.
The old expectations closed with the incoming alias spelling. Correct those four
expectations; do not change runtime identity or weaken the error comparison.
The independent callback-identity fixture checks direct/mutual order, copied
origin equality and successful execution of an equal independent literal while
the original is active. The current push605 and identity8 checks pass together.
Original October counts and behavior above remain dated milestone observations.
