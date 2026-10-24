---
id: write-vivification-perl-reference
title: "Perl reference nested writes vivify typed string/integer paths atomically"
answers:
  - "why does a tracked lifecycle assignment return one"
  - "why is __ls_binding_presence undeclared in a Perl fragment"
  - "does Perl currently autovivify nested assignment paths"
  - "how does Perl distinguish an absent nested write root from bound null"
  - "does a dynamic string nested write segment select a Perl harray"
  - "does a dynamic integer nested write segment select a Perl array"
  - "what Perl runtime owns nested write vivification"
  - "are Perl one segment and multi segment writes one ActionIR node"
  - "does Perl nested write vivification work inside user functions"
  - "what typed errors does Perl nested write vivification throw"
  - "what VM state must a lowered nested write fragment fixture declare"
  - "do Perl deferred codeblocks support indexed writes"
  - "how does a deferred Perl assignment preserve caller null presence"
  - "why does a deferred with call raise unknown_helper"
  - "do ordinary and deferred Perl negative array reads currently agree"
  - "which Perl readers govern negative array indexes"
  - "why do whole floats assigned inside Perl callbacks become integer indexes"
  - "why do deferred boolean literals become integer zero and one"
date: "2026-10-24"
status: current on the Perl reference under FUTURE-PARITY-BACKLOG.19.2.1; portable capability admitted under .19.7
tags: [dsl, actionir, assignment, autovivification, diagnostics, perl, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.2.1 and frozen v1 fixture; deferred extension TYPE-REFERENCE-BOOK.1.2.12. Prior card: git show 24e9c72a31b7eb31ce94b09beab9655ae85378cb:docs/knowledge/write-vivification-perl-reference.md."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/signed-array-perl/publish.py; current: prove -Iperl t/signed_array_selector_perl_contract.t; literal-kind intake: bash tools/run_python_project_data.sh docs/checkpoints/perl-literal-number-intake/read.py. Perl scope only."
---

# Perl reference write vivification

Perl now implements the frozen `linkedspec-write-vivification-v1` contract for assignments rooted at a bare
working binding:

```text
document[section_name][0]["title"] = title
```

Each bracket evaluates once left-to-right, then the RHS. Strings select harrays;
nonnegative integers select arrays. The runtime snapshots post-expression state,
builds on an isolated copy, and infers absent roots/intermediates only for
eligible string/nonnegative selectors. Bound null/wrong kinds and gaps fail; arrays replace or append at length.

The rule/function lowering owns an invocation-local presence map because Perl `undef` alone cannot distinguish an
unassigned lexical from an explicitly assigned null. User-function parameters begin present, including an `undef`
argument, while a fresh local target begins absent on every call.

Standalone indexed/receiver-mutation fragments declare
`my %__ls_binding_presence` alongside value lexicals and mark bound roots
present. Plain assignment/read fragments add no presence-map requirement.
Compiled frames supply scalar flags. Three October19 fixture failures/fixes
remain in TYPE-REFERENCE-BOOK.1.2.3;12 preserves this fragment ABI.

Invalid selectors, kind conflicts, and gaps throw
`LinkedSpec::BindingRuntime::NestedWriteError` objects with the frozen codes, binding, failing segment, detached
valid prefix, authored Unicode-scalar span, and kind/gap fields. Expression failures propagate unchanged. A
structural failure commits no partial path, although a segment/RHS side effect already completed before the
snapshot remains ordinary program state. Success detaches the committed binding, expression result, initial tree,
and aggregate RHS.

Read lowering was unchanged at this milestone. September24 public verification found that
raw Perl dereferences violated the required read purity in five controls. Startup `.89` repairs
both AST and compact lowering and adds actual Perl recurrence for all three frozen read exclusions.
[[perl-direct-read-autovivification-gap]] retains the before/after scope and native/fresh-source proof.
The September6 intermediate snapshot is historical: Rust/Dart and Julia writes
had landed while Lua was pending. Later portable admission, six-runtime recurrence
and public closeout belong to FUTURE-PARITY-BACKLOG.19.7-.9.

## Deferred execution (October23)

CodeblockRuntime dispatches the typed write node to BindingRuntime. Compiled
call sites pass invocation-local presence flags by reference; forwarded calls
retain them by weak slot identity; newly allocated slots reuse supplied flags.
All compiled caller scalar slots carry presence independently of body source. Fixed/rest parameters use
separate flags and restore caller slots/flags on every exit. Keys then RHS run
once before the root snapshot. Guards precede operands; structural failures
publish nothing. Returned roots stay detached. Invalid write headers reject before effects. Native/fresh and frozen write cases run in
t/callable_codeblock_literal_contract.t. Deferred with still raises
unknown_helper:with; TYPE-REFERENCE-BOOK.1.2.16 owns repair after last14.
Only this bounded Perl extension is admitted.
Tracked statements yield scalar(value), retaining assignment results and quiet void/value/list use; a presence flag must not replace the result.
Incomplete raw-regex fragments retain their compatibility source boundary; [[perl-multiline-helper-pattern-validation]] owns the precise limitations.

Historical .19.2.1: AST5/syntax7/success11/structural16;
ActionIR/trace/uniform50; Phase0 1032/963s after12 stale expectations.
Other backends awaited .19.3-.6; the prior Git card above retains full scope.

Related: [[write-vivification-neutral-contract]], [[terse-nested-value-path-assignment]],
[[uniform-binding-neutral-contract]], [[write-map-leaves-neutral-composition]], and ADR `0036`.

## Signed array selectors on Perl (October24)

TYPE-REFERENCE-BOOK.1.2.17.2 extends ordinary/deferred native and emitted Perl
execution with existing-array L+index reads/writes. BindingRuntime admits
negative integers globally, rejects missing required arrays, normalizes
against each post-expression array and reports exact underflow fields.
Raw authored prefixes, old diagnostics, effects, guard identity and detached
copies remain governed by the frozen signed/v1 authorities.

CodeblockRuntime::_read_array_entry serves indexed_var, nested_access and
read_path. Literal number spelling distinguishes -1 from serialized -1.0;
dynamic NV/string controls and ordinary bare-binding read coercions stay
separate. The callable-result form pick()[-1].count() now selects the tail
but retains compatibility marker1; no pure-source classification is added.
The permanent consumer executes all33 frozen writes through real deferred
callbacks, plus authored native/emitted programs and detachment controls;
tools/run_ci_local.sh enrolls this Perl-only regression consumer.
Historical before/after packets and two qualified infix-oracle mistakes
remain under docs/checkpoints/signed-array-perl/. Other backend/portable
admission and complete spelling inventory remain separately owned.

Owned22: accepted/current native and emitted byte-shadow probes show
CodeblockRuntime::_eval_expr erases whole-float and boolean literal kinds
before return/assignment: 0+serialized number yields IV; native1/0 loses
boolean identity. Compiled argument twins retain NV/boolean kinds. This
pre-existing producer defect precedes integer selection. Repair22 is P1
after clean17.2, before Rust17.3. Preliminary source/flags/INC review:
docs/checkpoints/perl-literal-number-intake/read.py under the project
Python wrapper. No repair/admission or historical environment replay.
