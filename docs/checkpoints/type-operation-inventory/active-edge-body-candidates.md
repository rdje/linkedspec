# Outgoing-edge body candidates

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.36.0; bounded backend repairs36.1-.4.
Status: target frozen; All bounded Default/OR backend children36.1-.4 and trace-test followup are targeted-checked; formal23.4 admission remains.

This target implements existing semantics, rather than introducing a new grammar
or generated-source contract. Read ADR0044 for rule-local cursor ownership,
ADR0047 and its neutral duplicate-slot artifact for structural identity/choice
priority, and the book's action-and-lifecycle-placement entry/edge explanation.
The retained constant BODY source distinguishes dispatch from Number helper work.

## Catalog and candidate roles

Keep every compiled rule's complete regex catalog. Incoming numeric selectors,
entry captures, descriptors, and capture_until_boundary still require declared
patterns even when no outgoing edge uses them. Never truncate that catalog or
infer an edge from a nearby regex declaration.

For Default/OR-family action-edge body choice, only the compiled outgoing edges
are eligible. Iterate in authored edge order using each edge's regex_idx to
address the existing compiled matcher. child_regex_idx describes the written
target's slot; it is not interchangeable with the enclosing compiled index.
Preserve the selected original compiled index, target identity, capture groups,
named captures, source spans, diagnostics, trace and descriptor identity.

Seek chooses the earliest match start among eligible edges. Equal starts retain
the first authored edge, even when its target selector is numerically larger or
two slots have identical patterns. Do not sort by declared slot number, recover
identity from regex text, or return the first later-starting edge without checking
whether another eligible edge starts earlier. Keep current zero-progress handling.

The scope excludes changing AND sequence/required-slot selection, indexed-first
entry compatibility, blind dispatch, no-edge handlers and lifecycle reconciliation
SESSION-STARTUP-READING.27. Existing repetition, cursor, frame restoration and
inter-match gap hooks keep their owners. Rust's preceding-input regex-context
defect remains independently owned by SESSION-STARTUP-READING.63.2; this repair
does not claim to fix sliced-input anchor/lookbehind semantics.

## Distinguishing evidence and implementation seam

active-edge-regex-dispatch-intake.json retains the original wildcard/literal
constant-payload sources, full compiled descriptors and exact native trace. Perl
Get returns ["BODY"] for the valid wildcard source. Rust selects untargeted0 on
:c and at, dispatches no child, and returns [null], although only edge2 is written.
The Number-method fixture's nonoverlap literal is a separate isolation carrier;
it neither invalidates the wildcard source nor waives this defect.

The additional public Perl probe retains native/fresh [2] when edges Value[2],
Value[1] reverse declaration order over duplicate /a/ patterns, and ["A"] when
edge /b/ is authored before /a/ but the input has a earlier. These distinguish
authored edge priority from catalog order and earliest start from edge order.
Exact sources, channels and generated boundary diagnostic are retained with the
authority packet. Finite authored examples do not establish population coverage.

Rust's two body matcher construction sites belong to the native Engine and
GeneratedPlanExecutor. Both call Engine::select_native_match; the existing
consume_slot_match/seek_slot_match APIs reuse individually compiled regexes and
return the original index/captures. Repair choice eligibility in that shared
selection owner, without rebuilding/truncating catalogs, adding serialized fields
or independently duplicating native/generated algorithms. The earlier intake's
"native and recognition" wording was imprecise: there is no separately diagnosed
recognition matcher in this finding. Recognition traversals using these execution
owners share the repaired selection; transaction semantics remain unchanged.

## Focused completion per backend

Establish native, supported restoration and generated-plan/fresh execution before
editing production. Lock wildcard/literal payloads, reverse duplicate priority,
earliest start, cross-target identity, local OR policy and untargeted no-match.
Inspect selected source/capture/slot trace, and prove complete catalogs remain
usable for incoming selectors and boundary lookahead. Run the relevant existing
duplicate-slot, rule-local cursor and inter-match gap checks; select focused tests
where existing suites include unrelated package/build admission.

Rust36.1 enables the previously ignored wildcard regression and records actual
RED/GREEN across native/restored CompiledSpec/generated plans. Other backend
children independently establish their own baseline; no peer failure or repair is
inferred. Preserve normal test registration, public book accuracy and per-leaf
commits. Full23.4/source-context admission and clean push gates remain separate.

## Independently discovered Perl generated boundary gap

The complete-catalog control Top:: I returning capture_until_boundary("Landmark")
with Landmark /END/ on bodyEND returns "body" natively but null from independently
loaded emitted Perl. The emitted helper requires descr.spec.Landmark.re, while
the emitted descriptor stores Landmark as a CODE handler with no regex catalog.
This is a separate generated descriptor reconstruction defect, not evidence for
changing the helper's boundary semantics or for truncating Rust catalogs. Own it
under37 after the bounded Number/named/block feature work and before full23.4
admission or push; its runtime/generated regression and repair are required.

## Bounded Rust36.1

The shared selection owner now considers only outgoing compiled edge slots for
non-AND action-edge choice, in authored edge order. Existing individual regex
programs are reused; full catalogs and serialization remain intact. Earliest
cursor-start candidates may return immediately because no later candidate can
start sooner and ties retain the first authored edge. Other candidates compare
starts strictly, without replacing a tied earlier edge.

Refined unchanged-production12 tests have5pass/7RED; first candidate12pass across
native/restored CompiledSpec/generated plans. Source/capture/spans/gap, full
boundary catalog, reversed Default/OR duplicate priority, cross-target identity,
five existing duplicate fixtures, seek/consume and selected slot traces pass.
Number6pass includes the original now-enabled wildcard regression. Initial LS
instrument refinement retains historical unflagged pre-selection hook ordering;
the distinguishing hook control uses capture_gaps's accepted selected-first
contract. Packet active-edge-body-rust-intake.json.gz retains all epochs. No
independent emitted-package, full regex-context, peer or admission claim.

## Bounded Dart36.2

Private _matchChoice now owns both gap-preselected and ordinary choice sites,
using existing indexed alternatives from outgoing edges in authored order.
Complete catalogs and indexed-first/AND/blind/no-edge/format owners stay intact.
Final13 tests pass native/restored SpecFile/generated plans, including exact
native/generated slot2 traces held in memory. Existing duplicate15-role,
rule-local5 and capture collection4 selected groups pass; changed-file analysis
is fatal-clean. No independent emitted package/full admission is claimed.

Initial13 groups have5pass/8mismatches; seven directly expose selection. The
LS-return gap carrier also exposes a distinct Dart live-cursor bug: selected
registers see cat while live/caller cursor remains1, versus reference4 on Hcat.
Own38 before admission; preserve all epochs and correct desired values, never
bless null suffixes. The final dispatch gap control reads its gap inside the
accepted edge, isolating eligibility without changing runtime cursor code.
Packet active-edge-body-dart-intake.json.gz retains exact probes/channels.
Immediate36.1.1 removes the prior Rust test's unregistered temporary trace owner
through public in-memory emitters; no storage manifest/gate change is needed.

## Rust trace-test storage followup36.1.1

The new file-backed trace test initially introduced an unregistered temporary
owner. The unchanged official storage-owner census detects it. The final test
uses TraceEmitter::with_stdout and a caller-owned in-memory Write buffer, with
public native/generated compatibility emitter methods; exact slot2 traces pass
and the same census returns0. Runtime/manifest/gate/format stay unchanged.

These compatibility emitter methods retain their documented accumulator envelope;
the unchanged value controls exercise direct native/restored/v2 projection. An
initial in-memory candidate incorrectly mixed those projections and is retained
as an instrument mismatch, with no product RED credit. Exact trace test1pass,
compile/rustfmt and actual owner-census GREEN receipt are retained in
active-edge-body-rust-trace-owner.json.gz. Other runtime tests were not repeated
for this test-only correction; prior12/6 proof keeps its recorded boundary.

## Bounded Julia36.3

Private _match_runtime_choice now serves ordinary and gap-preselected choice,
reusing compiled outgoing edge.regex_index alternatives in authored order.
Full catalogs and entry/AND/blind/no-edge/cursor/frame/format owners remain.
Refined58pass/34RED becomes92pass on native/reconstructed SpecFile/generated-plan
and independently loaded emitted Module. Exact source/capture/Unicode/gap/slot
and priority controls plus duplicate121/rule-local104/capture collection12 pass.
Traces stay in memory; normal runtests registers the module-scoped new test.
No independent isolated package/full matrix/backend admission is claimed.

Initial merged output interleaves one stderr error inside a JSON row; separated
streams resolve that instrument ambiguity before production. Final normal test
removes only the unasserted Hcat diagnostic, with exact assertion equality and
syntax checked. A standalone retained probe confirms Julia live/caller cursor1
on four routes versus reference4, independently owned38.2 before admission. No
healthy credit for that diagnostic, cursor repair or null rebasing in this slice.
Packet active-edge-body-julia-intake.json.gz retains exact epochs and commands.

## Bounded safe Lua36.4 and next feature

Both installed hosts PUC5.5.1/LuaJIT2.1.1788460057 have92 checks/34RED before
production and92pass after the first candidate. Shared existing-table helper
M._match_body_choice owns ordinary and gap choice, reusing cached indexed edge
programs in authored order. Full catalogs/indices, entry/AND/blind/no-edge/cursor/
frame/gap/formats remain. Exact source/capture/Unicode/gap/catalog/priority/mode
and in-memory slot2 traces pass; duplicate112/rule-local108/capture checks pass
per host. No persistent interpreter chunk-local or new temp owner is introduced;
module/runner loadfile and normal registration pass. Declared5.4 proof staysLUA2.2;
no unsafe pattern, full suite/matrix or isolated package admission is claimed.

Independent Hcat early-LS probes confirm cursor1 versus reference4 on both hosts,
owned38.3 before admission. A separate AND source also exposes an unaddressed
sequence role: catalogH/cat and only edge1, reference[BODY] versus Lua[null], with
trace requiring0 at cursor1. Own39 after bounded33/35/34 and before38/37/full23.4;
peer intake is independent. Choice filtering cannot substitute for an AND
sequence/counter repair; include non-returning actions and repetition before
claiming that fix. Initial AND descriptor serialization requires explicit JSON
array/object tags; setup failure/source are retained without product RED credit.
Packet active-edge-body-lua-intake.json.gz retains all epochs/oracles/commands.

The bounded Default/OR functional prerequisite permits Number33.3 next. Formal
source/context/backend closure remains canonical23.4; no focused parent-admission
claim or waiver of sparseAND39, earlyLS38, generated boundary37 follows.
