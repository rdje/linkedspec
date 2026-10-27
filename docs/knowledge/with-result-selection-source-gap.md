---
id: with-result-selection-source-gap
title: Immediate helper-with reads use scoped metadata source and consumer admission
answers:
  - "can a helper with result be indexed directly"
  - "why does receiver with Hash indexing work but helper with indexing fail"
  - "which task owns direct with result bracket reads"
  - "does immediate with selection admit deferred callback reads"
  - "why does Rust run Array operands after selecting a scalar from with"
  - "why does Dart run Array operands after selecting a scalar from with"
  - "does Rust unknown with source warn or reject before callback activity"
date: 2026-10-28
status: bounded Perl32.1/Rust32.2/Dart32.3 repaired; remaining backends/full admission next
tags: [perl, rust, dart, with, selection, fluent, scope, computed]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.9; activationad752f204ea99e928c757184d8e58a130111cba2; with-result-selection-intake.json.gz retains eight public source pairs and exact raw channels."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/with_result_selection.t; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test with_result_selection; cd dart && bash ../tools/run_dart_project_data.sh test test/with_result_selection_test.dart"
---

At the recorded clean base, direct helper-with Array/Hash/no-value/parenthesized
contextual brackets fail native/fresh host compilation with raw1/unready. Receiver
Array/Hash direct reads and named/method controls work with exact values/kinds,
W once and outer restoration, raw0/ready1. The prospective-value oracle is RED on
four helper forms and healthy on four controls. This is an additive source gap,
not false-ready metadata or evidence that the immediate body fails.

AST keeps helper-with bracket receivers raw_perl while a completed receiver-with
fluent chain uses existing value_access. Parser::_parse_value_access_expr retains
its deferred-body fence and asks MethodLowering::_actionir_ast_computed_data_call_method
for direct-call source authority. That owner excludes with's control/context role;
completed fluent sources already use the same typed reader. TYPE32 must admit only
metadata-approved immediate contextual helper-with forms through current owners,
with no new AST/segment/schema and no runtime-kind-derived source authority.

The frozen target covers existing attached/parenthesized contextual forms and
zero/one value argument. Actual kinds, signed/nested reads, once/order/snapshots,
missing paths and incompatible operand guards retain their current contracts.
Preserve existing receiver forms and delayed/bound/opaque/registered callback
read/vocabulary/raw-status boundaries. Explicit mutation, selector-coercion,
unknown-body and pure-function parser-state fences remain separately governed.

The fourteen-coordinate shared fixture is normative. Recorded Perl/Rust/Dart bounded
execution is below; remaining backend children start with their own baseline.
No other backend failure or full context/portable/generated admission is inferred.
Full23.4, excluded deferred readiness31.6.4.4, canonical fixture
registration23.4.1, pressure and declared-host proof remain open owners.

The first refinement's merged stderr warning interrupts a buffered JSON row at
JSON::PP in emitted source. The exact boundary/raw stream is retained; the producer
now flushes stdout and the three-source replay separates stdout/stderr, giving
parseable rows. This is instrument evidence, not additional runtime semantic RED.

A separate pre-freeze named no-value producer returns Number1 on public Perl
native/fresh with raw0/ready1. The unsupported initial source probe's true payload
expectation was unverified and is withdrawn. The final shared fixture branches on
that existing predicate truth to String empty, preserving each backend's current
predicate result kind rather than adding a body-policy change. The eight source-
role distinctions/four admission gaps remain unchanged; this producer-kind control
is separate and receives no new product RED credit.

## Current bounded Perl32.1

The immediate-with metadata/count/kind source role is separate from the global
known-value-name table, which omits with and remains unchanged. Retain explicit/
bound/opaque finals and registered/deferred body boundaries. An initial candidate
passes direct reads but consumer preflight still reports with unsupported. Public
normalization/lowering/unknown-precheck traces distinguish plain reads from .add
for attached/parenthesized forms. The same scoped role now guides that precheck,
checking ordinary value operands while the existing typed with owner validates
its body. Consumer-bearing entry_len/missing/missing_source controls retain exact
specific diagnoses; no body-vocabulary promotion follows.

Final11 groups/shared14 strict native/fresh values and one helper source raw0/
ready1 pass. They cover scopes, once/order, source rebind snapshots, missing-path
selectors, kind bridges and skipped incompatible operands. Explicit/registered
callbacks retain typed unsupported_codeblock_actionir/raw_perl/raw1/unready;
bound/malformed sources keep old compile/raw channels. Canonical OwnerDispatch
loads metadata; final cold post-chdir/incoming-error,15 parser assertions and
public chain trace pass. No AST/segment/schema/global name/selector/copy/write
policy changes. Rust32.2 independently follows; full23.4 remains separate.

Exact packet: with-result-selection-perl-intake.json.gz. Initial module/test inputs
are restored by exact inverse of retained authored refinements, checked against
clean Git source, trace caller lines and a test roundtrip; no premutation hash is
claimed. A guard initially mistook a multiline caller argument line4477 for the
callee line4476 and is corrected after inspection. A premature diagnostic consumer
produces empty output and gets no semantic credit; the completed two-row consumer
is guarded. These are instrument/input-provenance records, not product RED counts.

## Current bounded Rust32.2

Unlike Perl's source/precheck gap, Rust already parses/evaluates immediate with
brackets and ordinary/registered callback-body reads. is_ordinary_computed_read
excluded all helper with sources, omitting actual-kind guards after selection.
The private classifier now accepts only normalized CodeblockArgument and existing
builtin helper metadata arity, after registered-function precedence. Explicit/bound
final callbacks keep their legacy selected count0/.take operand policies. Current
reader, parser, normalization, callback vocabulary and schemas remain unchanged.

Refined unchanged-production5pass/1RED precedes candidate6pass over native/restored
CompiledSpec/generated-plan. Shared14 values/order/scopes pass, and one exact legacy
bound-call computed-read compatibility passes. Initial unknown-source rejection
expectation was wrong: rust-callable-codeblock-dynamic-invocation and the engine
ordinary-unknown unit already document warning/undef outside active callbacks.
The ordinary with value operand runs before callback activity; all routes retain
String1, while missing() inside the active body diagnoses. No unknown-call repair
or extra semantic RED is claimed. Packet with-result-selection-rust-intake.json.gz
retains actual source inputs/refinements/channels. Dart32.3 next; full23.4 separate.

## Current bounded Dart32.3

Dart already supports immediate helper-with brackets and ordinary/registered
callback-body reads. _isOrdinaryComputedRead omits this source, so scalar-selected
Array consumers run their operands and yield[]. Only canonical with with normalized
ActionCodeblockArgumentExpr and builtin helper metadata arity now joins the existing
guard after registered-function precedence. Explicit/bound finals keep their current
count0/.take policies. Refined baseline5pass/1RED precedes candidate6pass across
native/restored SpecFile-to-recompile/generated-plan; exact bound-call compatibility
and selected fatal analysis pass. Dart's unknown source/body calls already diagnose
and remain strict; no Rust warning/undef policy is imported. Entry_len/malformed
arity and scopes/order/snapshots/missing bridges are preserved. No parser/reader/
schema/vocabulary expansion. Packet with-result-selection-dart-intake.json.gz keeps
sources/channels and discloses the failed wrong-cwd setup separately from RED.
Julia32.4 next; full23.4 separate.
