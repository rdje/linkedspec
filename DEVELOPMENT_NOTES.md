# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

## 2026-09-11 — Mutating a copy does not test returned-result isolation

Staged consumer859–861 passes deliberately aliased results because it mutates a
new deepcopy. Direct mutations of each actual returned AST preserve its siblings;
this is a permanent-test gap, not a proven runtime alias defect. Julia .2.26 owns
correction and counterpart audit; source-gated repair and exact evidence remain.

## 2026-09-11 — Emitter and staged-prefix tests preserve separate boundaries

Emitted hosts prove eight accepted fixtures, ten families and format-before-payload
rejection. Loader tests preserve14/9/4 neutral cases. Staged1–734 executes three
complete testsets while production-route reading remains partial through799.
Focused208 assertions pass; no full staged-suite or repair closure follows.

## 2026-09-11 — Static fixtures and admission preserve bounded guarantees

Private projection retains source correlation while public query applies ceilings.
Twelve admission roles execute once and match all twenty fixture hashes; known
projection/budget gaps remain. Alias metadata tests cover arities0/1 separately
from normal/reversed runtime fixtures. Focused726 assertions pass.

## 2026-09-11 — Observed snapshots and emitted execution retain distinct proof

Runtime observation tests execute fresh modules and a separate Julia process.
Derived snapshots match the twentieth query digest without mutating the base.
Direct callback identity and warmed helper allocations are finite controls;
child-inside-action repair .2.6 remains open. Focused509 assertions pass.

## 2026-09-11 — Semantic consumer proof stays bounded to its fixtures

Compilation, staged provenance and query consumers pass759 assertions together.
Nineteen static hashes exclude runtime events; source-token guards do not prove
all dynamic non-execution. The malformed-operation callback remains uncalled.
Shared budget .82 and every prior repair remain open despite positive fixtures.

## 2026-09-11 — Main and semantic consumers retain their separate authorities

Main parser loops skip function shells; separate spec-defined parsing and full
corpus execution cover those routes. AST JSON roundtrip proves shape, not full
validity. Semantic core retains18/16 exact identity but its assigned-regex fixture
does not close source-correlation repair .2.15. Focused475 assertions pass.

## 2026-09-11 — Helper and trace consumers preserve independent state boundaries

Tests distinguish copied harray updates from index mutation, zero-width presence
from absent matches, and block-local returns from rule returns. Frontend trace
executes the function-source parser separately from dictionary-based descriptor
fixtures. Focused 138 assertions pass; all existing repair owners remain open.

## 2026-09-11 — Staged descriptor fixtures retain precise producer coverage

The main descriptor fixture constructs neutral function dictionaries before
projection, compilation and runtime; it does not execute the source producer.
Ten complete testsets pass 419 assertions. Partial string/numeric tests remain
outside this replay, and all existing repair owners retain their prerequisites.

## 2026-09-11 — Cursor and CLI consumers preserve their test boundaries

Cursor normalization/execution/options pass510 assertions; complete main-prefix
checks pass145, including exact help, loading, canonical JSON and routed trace.
The failure/trace testset continues into .1.42. Governed notes rollover preserves
clean source bytes, manifest order and archived queries under unchanged limits.

## 2026-09-11 — Cursor admission preserves independent emitted evidence

Cursor admission checks emitted text, while source-emitter and root-route tests
execute fresh emitted modules/processes. Loaded descriptor equality adjusts only
logical slot/gap source IDs; normalized byte equality remains exact. Focused1463
pass. Notes reach455 lines; the next seven-line record requires governed rollover.

## 2026-09-11 — Recognition and observation tests retain their exact coverage

Recognition graph/progress fixtures call private validators directly; production
effect closure remains separately repair-owned. Observation validates detached
multibyte records and typed diagnostics; repeated results use an offline emitted
process. Root entry returns isolate selection before matching. Focused663 pass.

## 2026-09-11 — Consumer source preserves distinct authority and emitted proofs

Progressive creates an independent emitted host with caller-supplied authority;
punctuation reconstructs the emitted payload and recompiles it. Private recognition
fixtures preserve falsey payloads and detached marks, while effect integration and
late attempt preflight remain separate repairs. All494 focused assertions pass.

## 2026-09-11 — Approved finite evidence capacity preserves retrieval

ADR0116 records the director’s Granted answer to both line controls and .13-only
focused validation. Production functions test inclusive limits and unauthorized
changes on detached inputs; full candidate-plus-reserve checks retain readable
facts, prior source/history and all other controls. Future canonical gates remain.

## 2026-09-11 — Finite Knowledge reserve follows measured Julia growth

The36 unconstrained reading slices peak at316 Knowledge lines/17674 bytes/one card.
Twenty units reserve6320 lines versus4472 under the recent-mean model;79000 retains
680 lines of margin. Decision reserve486 fits13000; all other controls stay unchanged.
The proposed .13-only exception is explicit and does not inherit ADR0115 authority.

## 2026-09-11 — MCP admission composes with executable focused seams

Admission checks source markers for pre-emission cancellation and native failure;
this slice executes the actual stdio/dispatch consumers as well. All20 native/MCP
identity cases remain finite equality proof, preserving shared budget .82 ownership.
MCP625 passes; Knowledge overflow72065/72000 resolves by exact task routing; .5 owns capacity.

## 2026-09-11 — Julia consumer proof retains exact exercised roles

Logical arity rows have complete in-process coverage and one emitted negative.
Mutation guards include18 loop rows plus set_key; typed carrier/identity/atomicity
checks remain intact. MCP admission executes257 assertions while its read prefix
stops at304; finite binding patterns do not close terminal-LF repair .2.4.

## 2026-09-11 — Complete Julia gap evidence and logical truth representation

Gap source distinguishes detached metadata, native lifecycle/rollback, normalized
carriers, fresh emitted host and exact nine-role admission. Logical truth uses
an explicit ActionBlock fixture; callable literals remain a separate representation.
The full two-consumer proof passes551 assertions; no defect is closed by reading.

## 2026-09-11 — Julia consumer labels require concrete exercised values

The diagnostic codeblock row actually constructs an eager block; actual literal
native/generated controls remain inert and render the correct empty event.
Fixture correction .2.25 keeps that proof permanent. Contract roles stay distinct;
change-history rollover preserves213 exact clean lines within existing limits.

## 2026-09-11 — Julia identity guards require present names and full strings

Nullable selector equality treats anonymous absence as a name; reordered slots
move the erroneous selection. A terminal LF passes the host dollar anchor and
bypasses exact reserved-name checks. Reconstructed native controls isolate both;
trace config parsing precedes file preparation and preserves invalid-input files.

## 2026-09-11 — Julia projection checks must bind metadata to source

Matching scalar text does not verify its claimed lines; equal sidecars can all
carry the same false location. Bool enters an Integer projection helper, while
payload version is unchecked. Compact regex braces independently fail a
quote-only validator after parsing preserves full code. Repairs remain owned.

## 2026-09-11 — Julia lexical stages require distinct repair ownership

A body adapter drops helper remainders; compact extraction counts quoted
parentheses despite its separate literal-aware completeness scan; outer brace
collection lacks regex state. EOF retains enough source for balance rejection.
All806 Unicode ranges are read, with classifier functions still next.

## 2026-09-11 — Julia source retention precedes strict validation

Unsupported suffixes disappear after recognized members unless a narrow raw
retention condition holds. Strict validation cannot reject bytes already lost;
self-target controls avoid unrelated unused-rule rejection. Typed AST preserves
selectors and JSON boundaries; explicit rule return correctly precedes E.

## 2026-09-11 — Julia authored selectors and generated state

Whole-member substring matching overrides typed unindexed selector identity,
creating incorrect source forms, target shapes and selects_regex relations.
Static/emitter reading completes; generated state retains canonical JSON,
ASCII-hex Unicode identity and contract-first validation. Repair .2.18 stays open.

## 2026-09-11 — Julia static slot and entry evidence gates

Filtering authored parent matchers before comparing the unfiltered compiled
pattern prefix rejects a valid mixed-order source. Entry explanations depend
on absent functions and multiple rules. Separate failure controls preserve
missing-rule versus out-of-range-slot evidence; all repairs remain task-owned.

## 2026-09-11 — Shared semantic budget and paging inconsistencies

Explain limits records but omits relation/depth bounds; page selection flags
the whole remaining stream before taking a smaller page. Six complete Julia
and neutral responses match, demonstrating why parity alone cannot sign off
the declared budget contract. Shared .82 owns independent repair expectations.

## 2026-09-11 — Julia matcher decoys and semantic source ownership

The whole-member call scanner refuses regex starts followed by group syntax
or whitespace, then selects a call-shaped matcher substring for a typed action.
Plain regex, nested calls, arity and repeated-binding controls isolate the gap.
Outcome/source reading preserves strict UTF-8, detached state and exact ceilings.

## 2026-09-11 — Julia contextual casing and typed semantic provenance

Final Sigma reads original code points against pinned cased/ignorable ranges.
Semantic projection validates staged payload/job/signature and retained plan
identity before typed call/binding evidence. The known function-empty guard
still precedes rule traversal; fixture success grants no closure or suffix credit.

## 2026-09-11 — Julia upper-case completion and contextual properties

Upper data reaches U+1E943, preserving ligature and combining expansions.
Cased-property intervals include more than changed mapping entries; all158 are
read. Ignorable-property prefix ends at U+0605; contextual evaluator is still
unread. Fresh pinned regeneration passes without new runtime assertion credit.

## 2026-09-11 — Julia Unicode lower completion and upper prefix

Lower data reaches U+1E921; upper prefix includes sharp-s, modifier-apostrophe
and combining-sequence expansions. Directional casing maps are not inverses or
normalization. Pinned regeneration passes; remaining upper/property/evaluator
source is unread, and previous casing39 remains bounded unchanged-source proof.

## 2026-09-11 — Julia staged diagnostic bytes and call admission

Diagnostic fallback can exceed its allowance and recur after exhaustion; measured
187/188/375-byte controls now own .2.14 repair. Julia checks call exhaustion before
increment, including the maximum integer boundary. Declaration uses exact typed
source materialization; Unicode17 prefix and regeneration retain pinned data.

## 2026-09-11 — Julia staged registry pattern boundaries

Dollar-anchored staged occursin admits final LF; parser components reject valid
neutral digit starts, and nondefault allowed tops lack pattern validation.
Six malformed snapshots still dispatch, while neutral checks reject them.
Private authority proof and exact replay own .2.13; existing491 remains finite.

## 2026-09-11 — Julia source values and staged authority seeds

Decoded source tables own exact scalar/codeunit conversions; event construction
leaves topology validation to derivation. Staged seeds validate logical data with
placeholders before factory invocation and create fresh execution state. Focused
observation routes require both ordinary query-digest and direct-capture helpers.

## 2026-09-11 — selected-slot validation and recognition prefix

Selected-slot matching returns on regex miss before normalizing mode; ordinary
matching validates first. Exact hit/miss controls own .2.12 repair. Recognition
restoration first excludes invalidated tokens, preserving the existing separate
Perl stale-snapshot repair and all-runtime census under startup .38.

## 2026-09-11 — Julia typed slicing and count conversion boundaries

Typed input slicing clips integer widths before addition, unlike array/string
slices. Missing/extra input_slice operands bypass arity enforcement, and large
float counts throw during Int conversion. Perl scientific-count fallback has
separate host substr/drop semantics; startup .60.2 owns normative review/repair.

## 2026-09-11 — Julia numeric and range boundary mechanisms

Integer literal parsing can throw; result normalization loses large finite
floats, while integer addition and abs wrap before normalization. Range helpers
add counts before clipping, causing wrong slices or BoundsError. Paired Julia
and Perl controls isolate these from portable text spelling under startup .55.2.

## 2026-09-11 — Julia helper callback recursion identity

The callable executor tracks the supplied name; with/tree dispatch supplies the
helper name, colliding across distinct nested callbacks and losing bound names.
Native/reconstructed controls distinguish four false cycles and one wrong cycle
identity from valid single/sequential/mixed calls. Exact repair owner is .2.8.

## 2026-09-11 — Julia recognition attempt preflight

RecognizeOnce executes its child before token lookup and authority validation.
One-character Child controls prove execution before missing-token rejection and
a second match before repeated/post-commit rejection through four public routes.
Repair .2.7 owns preflight and static-sequence/carrier proof; replay is durable.

## 2026-09-11 — Julia action callback identity boundary

The sink marks the original callback error, but an enclosing action catch wraps
it before outer identity-based passthrough. Native execution returns a runtime
error; generated plans translate it again. Direct/blind/final controls preserve
identity. Exact 24-route replay and gated repair live under Julia .2.6.

## 2026-09-11 — Julia execution state and typed adapters

Runtime construction validates compiled identities and creates fresh stores,
recognition authority and source projections. Gap and observation adapters retain
entry-slot identity and Unicode-scalar records; compatibility failures return
absence. Existing classifier integration repair .2.3 remains open.

## 2026-09-11 — Julia progressive authority gaps

Nested requests check view expiry but re-use caller-supplied grants and invocation
steps; the active child can regain wider ceilings despite zero local budget.
Direct caps work in controls. Identity/top/fingerprint dollar anchors admit final
LF; neutral fullmatch rejects it. Startup .37 and Julia .2.5 own bounded repairs.

## 2026-09-11 — Julia wire and narrow staged parsing

Wire scanning precedes JSON3 decoding and restores exact numeric token kinds.
The function-body registry builds cache identity per job without storing plans;
its built-in adapter stays separate from admitted general-v2 frozen authority.
Function shells execute the checked-in definition spec; default parsing is cached.

## 2026-09-11 — Julia MCP validation boundaries

Dollar-anchored occursin admits a final LF in handle/digest schema strings; host
handle length rejects it, but public lookup reports unavailable. Neutral fullmatch
rejects the malformed input. Decoded/stdio probes agree; separate metadata-order
controls reuse startup .36. Julia .2.4 owns repair after startup prerequisites.
