# Ordinary immediate with-result bracket reads

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.9; implementation family23.3.32.
Status: bounded Perl32.1 implemented/targeted-checked; other backend children independently follow; full23.4 remains open.

The existing with helper returns its immediate contextual body's actual value.
On current Perl, a receiver-with result already supports direct Array/Hash reads;
helper spelling needs a working binding or method endpoint instead. This feature
adds the missing helper-result source to existing typed postfix reads. It is
separate from31's repaired method continuations and does not reinterpret deferred
or arbitrary callable reads as ordinary data-helper sources.

## Bounded target

- Existing canonical helper with with zero/one ordinary value argument and a final
  immediate contextual block may feed direct bracket reads. Attached and existing
  parenthesized contextual spellings use current CallableContract normalization.
  Preserve no-value scoped undef and all valid receiver-with read forms.
- Reuse value_access and current segments, including valid zero-based/signed Array
  positions and quoted Hash keys. Selected Bool/Number/String/null/Array/Hash kinds
  and compatible method/selection/default bridges stay intact. Wrong-kind/missing/
  out-of-range paths yield null without creating storage, as ordinary reads do.
- Evaluate source/value then immediate body once, restore scoped value before
  selectors run, and evaluate all selectors left-to-right even on a missing path.
  Preserve prior effects and stop normally on errors. Capture the result before
  selector rebinding; no stronger copy depth or nested-alias promise follows.
- Existing actual-result guards reject incompatible consumer operands before their
  effects. Preserve current named/literal/context first-consumer policies outside
  this source, malformed-helper arity and explicit mutation/copy/list-splice rules.
- This source grant is for metadata-approved immediate contextual helper with.
  Explicit delayed literals, bound/opaque final callables, registered contextual
  callbacks and their bodies retain existing read/vocabulary/diagnostic/raw-status
  boundaries. Do not broaden static source admission from a runtime value kind or
  make all control/context helpers data sources. Existing receiver forms remain.
- Keep unknown-source/body errors and specific pure-function parser-state fences
  under the existing owners, including when selection follows a returned Array.
  Computed writes, new selector coercions/dynamic Hash keys and grouping remain
  outside this slice. Preserve public AST fields, body/source spans and formats.

Shared prospective fixture: tests/fixtures/with_result_selection_values.spec/json,
input x. Fourteen coordinates cover helper/receiver and parenthesized/no-value
forms, signed/nested reads, strict scalar kinds, Array/Hash/String/Number bridges,
missing/default behavior, skipped bad consumer operands, selector order, source
rebinding snapshot, outer value restoration and exact ABCDEFGHIJKLM effects. It
is the frozen expectation. Recorded bounded Perl execution is below; other backend execution and full admission are not inferred.

## Independent Perl intake

At cleanad752f204e, eight authored sources distinguish four unsupported helper
forms from four healthy receiver/named/method controls. Native/fresh helper Array,
Hash, no-value and parenthesized-contextual brackets fail compilation with raw1/
unready/unresolved[]. Receiver Array/Hash reads and named/method twins retain
exact values, scalar kinds, W once and outer restoration with raw0/ready1.

Public AST has raw_perl at a helper-with selected receiver, versus value_access
around receiver-with's completed fluent chain. Parser::_parse_value_access_expr
already preserves its deferred-literal fence and asks the static MethodLowering
computed-data-call owner for direct calls. That owner excludes with's control/
context role, while completed fluent receivers already join the same reader.
Reuse those typed owners with a precise immediate-with contract check; do not
reconstruct host code from bracket text or weaken source/body validation.

A merged stdout/stderr refinement log embeds a host warning inside a buffered
JSON row. Its exact boundary is inspected and retained as instrument evidence;
it is not runtime semantic RED. The producer now flushes stdout and the three
refined sources are replayed with separate streams, yielding parseable rows and
the actual supported/unsupported distinctions. Exact original/refined sources,
raw channels, oracle and limits: with-result-selection-intake.json.gz. Independent
backend32.1-.5 children run focused checks; full source/context/portable/generated
admission remains23.4 after feature coverage.

A separate pre-freeze named no-value producer returns Number1 on public Perl
native/fresh with raw0/ready1. The unsupported initial source probe's true payload
expectation was unverified and is withdrawn. The final shared fixture branches on
that existing predicate truth to String empty, preserving each backend's current
predicate result kind rather than adding a body-policy change. The eight source-
role distinctions/four admission gaps remain unchanged; this producer-kind control
is separate and receives no new product RED credit.

## Bounded Perl implementation32.1

A separate exact immediate-with contract check joins computed-call sources without
adding with to the shared known-value-name table. First candidate passes direct
reads and10/11 groups, but selected fluent consumers still mark with unsupported.
Public direct-read/.add traces isolate the first-unknown helper precheck; reuse the
same source role there, scan value operands and let the typed with owner validate
the contextual body. Three specific consumer-bearing fence controls independently
RED before that refinement and GREEN afterward. No parser/body/reader/schema rewrite.

Final11 groups/shared14 strict values and one valid helper source native/fresh/
raw0/ready1 pass, retaining nested/pure scopes, source/body/selector/consumer order,
missing paths and explicit/bound/registered/malformed boundaries. Final metadata
loader uses OwnerDispatch; cold post-chdir/incoming-error,15 parser assertions and
final public chain traces pass afterward. Packet with-result-selection-perl-
intake.json.gz retains sources/channels and explicit initial-input recovery/setup
provenance. No full suite/matrix/source/context admission; Rust32.2 is next.
