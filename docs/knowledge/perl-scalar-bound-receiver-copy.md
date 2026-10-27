---
id: perl-scalar-bound-receiver-copy
title: Perl single-step receiver copy preserves a scalar binding's runtime container type
answers:
  - "does Perl meta copy preserve a hash stored in a scalar"
  - "why did single step receiver copy return an empty array for a hash"
  - "does empty hash receiver copy stay a hash on Perl"
  - "does Perl receiver copy share nested references"
  - "does scalar receiver copy consume typed AST fields"
  - "where is the scalar bound receiver copy repair verified"
  - "does ordinary Perl function copy preserve primitive values and selector kinds"
  - "does deferred Perl copy support primitive values or receiver methods"
  - "does ordinary Perl shallow copy describe interpreted copy depth"
date: 2026-10-10
status: accepted public repair at770cffcc; original proof requires its accepted Git input state
tags: [perl, actionir, ast, copy, containers, receivers]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0 retains identical50 assertions: original9 semantic REDs/41 controls/all50 current GREEN. Live Get and retained standalone source each execute14 cases; typed AST poisoning is independent. Three syntax-valid faults fail9/4/8 named assertions. Supplied61 suites/184 files, evidence5/original307 restoration and complete book89/three controls pass. Native probe/regression/channels remain unchanged; canonical admission is separate."
reverify: "Use accepted770cffcc Git inputs including the original live claim: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-book-repair/review.py; separately book-repair/publish-claim.py under that wrapper. Defaults readonly. Original final review/publications replay from retained failed03 inputs via book-repair/replay.py; original runtime/CI source and observations stay exact. Capture/freezer/faults/evidence/publication writers are one-shot. Earlier regex proof requires accepted2b4e484a9 Git inputs including original live claim."
---

Ordinary bare assignment remembers a scalar value slot, which can contain either
an array or a hash. The AST hash-copy discriminator recognized an aggregate hash
binding or a later hash method. A scalar-bound variable with a single `.copy()`
therefore fell through to array wrapping and returned `[]` for hash values.

The bounded repair routes a variable known to be scalar-bound, with one copy call
and no arguments, through the existing aggregate function-form copy lowerer.
That lowerer dispatches from the runtime array/hash value. Empty hashes remain
hashes. Arrays and empty arrays retain their values; other scalar values keep
the existing empty-array result.

Both spellings create a distinct outer container and retain shared nested
references on Perl. The probe checks live and actual standalone execution before
serialization, so identity is observed rather than inferred from equal JSON.
Full generated source is retained in each actual observation channel. Typed AST
chain/receiver/call source fields are poisoned; their semantic fields still
produce the correct hash result.

Multi-step chains, legacy rule aggregate storage and wrong-arity diagnostics
retain their controls. The separate legacy hash kind callback repair has bounded
proof in `docs/knowledge/perl-legacy-hash-kind-callback.md`; required receiver capture and independent factory/private/
mapped admissions remain open. This proof covers the scalar-bound single-step
population and does not establish other receiver populations.

October27 ADR0138 supersedes only the old scalar fallback in current ordinary
function copying (TYPE1.2.1.4.2.2.1.1). Typed non-variable operands lower directly
from their AST; variables retain the existing legacy storage/kind-provider path.
The shared ordinary emitter shallow-copies Array/Hash, preserves non-reference
scalars/null and JSON Boolean values, and retains the opaque-reference fallback.
It does not inspect scalar text, so Number0 and String0 remain distinguishable
by BindingRuntime typed writes before JSON. Function-copy continuations use
actual-kind default-result dispatch, including repeated copy and skipped wrong
container operands. t/value_copy_function.t covers native/fresh values, kinds,
once-only snapshots/errors, function locals and outer-distinct/nested-shared
containers; t/actionir_receiver_scalar_copy.t retains the legacy callback and
exact rule-storage controls with only text/zero expectations advanced. Historical
accepted captures above remain exact; generic receiver and interpreted-context
rollout are separate children1.2/1.3, and complete admission remains23.4.

Ordinary receiver extension1.2 folds each zero-operand copy link (alongside the
existing logical fold) into the typed function-call AST. Prefixes remain typed,
so logical/arithmetic/String/selected/with/function-local results preserve their
actual values instead of acquiring Array inference or scalar-result rejection.
Variable sources still use the producer's legacy kind/storage path; the existing
private callback tests and exact return[@Top] control are unchanged. Extra copy
operands reject in the root shape preflight before source/operand effects, keeping
the existing unsupported-copy sentinel. The new t/value_copy_receiver.t exercises
native/fresh primitive kinds, repeated/default recovery, scoped and with results,
SR guard effects,0!/7/2 snapshots, Number selector writes and original and() errors.
A public generated-source failure also exposed selected-chain set_key block keys
being emitted as authored DSL inside a Perl hash index. That typed block key is
now lowered before the compatibility key helper; wrong-Hash operands stay skipped
and a compatible Hash block key runs once. No change to free-key vocabulary,
operand execution order, container depth, callable origins or deferred grammar.
Existing interpreted paths1.3 require independent assessment; canonical admission23.4
and explicit new Perl fixture registration remain open.

Existing interpreted-context1.3 is independently preserved by
 t/value_copy_interpreted.t public native/fresh checks without runtime edits.
CodeblockRuntime::_eval_call already sends valid free copy to _copy_value:
no-ref scalars retain flags; Bool cloning retains its kind; Array/Hash recursion
and callable origins retain their existing implementation. Public values,
Number/String typed writes, snapshots0!/7/2, wrong-Array count suppression/S,
source/helper errors and copied-callable recursion rejection pass. Deferred
receiver copy remains unknown_helper/copy; invalid free arity keeps that existing
error. Its take wrong-kind policy returns[], distinct from ordinary guarded null.
No new vocabulary/depth/origin policy is admitted; equal returned JSON is not
used to infer producer depth because invocation/container boundaries also copy.
The separate computed deferred raw/readiness boundary remains covered. Perl's
bounded producer/receiver/context children are complete; independent backends
and full source/context/portable/canonical admission remain open.
