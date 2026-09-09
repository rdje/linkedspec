# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

## 2026-09-10 — Dart recognition/source reading

.1.24: token misuse restores frame/gap state; source values keep authority identity;
staged seeds create fresh execution state. 58 tests pass. Exact mechanisms and
retained defects: DART-STARTUP-READING.1.24 and its linked Knowledge cards.

## 2026-09-09 — quantifier normalization needs lexical context

Dart reading .1.23 completes matching and reads recognition through 483.
Six exact public Dart/Perl controls prove that replacing {,n} globally changes
escaped literals and character classes, despite 99 passing tests. New .2.16
owns lexical repair and carriers; actual lower-unbounded quantifiers stay
supported. Recognition entry reconciles with its existing private authority.

## 2026-09-09 — matching retains participating-capture identity

Dart reading .1.22 completes interpreter and reads matching through 900.
Compact captures keep original group indexes/options; lazy staged suffix probes
prove boundaries against the original match and decline unprovable patterns.
Typed writes publish copied roots after evaluation. All 132 tests and structural
corpus 31/31 pass; prior authorities and defects remain unchanged.

## 2026-09-09 — typed projection can hide slice-end overflow as absence

Dart reading .1.21 completes context/binding machinery through 9674; 124+6 tests
pass. Nine paired input-slice controls show two overflow nulls, six agreements
and one unsupported zero-argument difference. Source projection catches the
overflowed negative endpoint as absence (.2.14); documented arity needs early
handling (.2.15). Observation binding is guarded by its caller before execution.

## 2026-09-09 — host number and string operations need boundary proof

`DART-STARTUP-READING.1.20` reads supporting value helpers and runtime-context entry
through 8174. The corrected 111-test selection and neutral numeric 55/18 pass.
Eleven paired controls expose six numeric/text corruptions; eight expose five Unicode
ordering differences; six expose two slice-end overflows before clipping. New .2.12-.2.14
own separate repairs and carrier/public proof, coordinated with startup .55/.60 and
MCP .2.5. Exact native/reconstructed and Perl facade/source replay preserves each boundary.

## 2026-09-09 — hash arguments must be spliced before pairing

`DART-STARTUP-READING.1.19` reads guarded helper mutations, constructors, typed capture,
logical dispatch and action-child entry through interpreter 6674. All 122 selected tests
pass. Nine Dart native/reconstructed cases show raw aggregate pairing loses fields and a
late map merge defeats authored duplicates; flat_array is omitted. Nine Perl facade/source
comparisons separate successful flat_array from the already-owned map-helper sentinel.
New .2.11 owns Dart repair/carrier proof with FUTURE-PARITY-BACKLOG.5; prior evidence remains.

## 2026-09-09 — helper names are not callback recursion identities

`DART-STARTUP-READING.1.18` reads observation completion, guarded receiver mutation,
helper/callable dispatch and function store restoration through interpreter 5174.
All 140 selected tests pass. Nine native/reconstructed controls show helper-name tracking
falsely rejects distinct nested with/map_leaves callbacks and loses cb identity through
with. Three successful controls and direct recursion distinguish the failure. New .2.10
owns named/anonymous callback identity and carrier proof; prior repairs remain open.

## 2026-09-09 — marker-selected ranges need value-aware control dispatch

`DART-STARTUP-READING.1.17` reads value controls, copied/restored with and tree callback
bindings, and expression dispatch through interpreter 3674. All 124 selected tests pass.
Ten AST/native/reconstructed controls expose the marker-range fallback into action
execution: attached if/while/switch returns escape the value block, while the one-statement
if adapter loses sibling else. Five direct/marker-only/attached-only controls pass.
New .2.9 owns unified value-aware dispatch and carrier proof; prior defects remain open.

## 2026-09-09 — semantic callback passthrough must cross action blocks

`DART-STARTUP-READING.1.16` reads rule cleanup, blind/regex repetition, gap phases,
slot observations, action dispatch, lifecycle binding ownership and initial control/value
flow through interpreter 2174. All 100 selected tests pass. Six native probes identify
a missing semantic-wrapper passthrough in _executeActionBlock: explicit call(Child) loses
observer error/stack identity before the outer parser can restore it. Direct/blind/final
controls preserve both; the nonthrowing twin returns ok. New .2.8 owns repair and broader
carrier/trace/cleanup proof; exact native events and diagnostics are durably reproduced.

## 2026-09-09 — calculated callback limits need inherited enforcement

`DART-STARTUP-READING.1.15` finishes bounded dispatch and generated families, then reads
interpreter entry/validation/context/observation setup through line 674. All 82 selected tests
and neutral progressive checks pass. Ten direct callback controls prove a composition gap:
request.remainingSteps is computed, but dispatchNested delegates to invocation.dispatch with
fresh supplied grants. A child at zero nests anyway; wider arguments regain extra capability
and 100-step/result-node ceilings. Direct cost/node/diagnostic byte enforcement works.
Existing startup .37.1/.37.2 own inherited authority and the separate diagnostic source-detail
review; no new task ID or cross-backend reproduction is inferred. Exact replay is Knowledge-owned.

## 2026-09-09 — function sidecars and callback-scoped source views

`DART-STARTUP-READING.1.14` completes shell projection: scalar text/span checks, matching
sidecars, normalized parent/job identity and CR/LF-preserving declaration removal. Function
line fields remain separate from the staged scalar coordinates used by semantic projection.
The bounded authority prefix owns copied host configuration and callback-local source rebasing;
every view operation and retained nested request checks lifetime. The actual dispatch algorithm
starts in .1.15. All 24 selected function/progressive tests pass, including emitted Dart
analysis/execution. No new confirmed defect or builder activation; earlier repair evidence remains.

## 2026-09-09 — Unicode identity and body-fluent token completeness

`DART-STARTUP-READING.1.13` completes staged v1 helpers, the 806-range Unicode classifier and
function-parser bridge, then reads shell projection through line 252. Scalar membership and
supplementary-safe prefix slicing remain exact; 25 selected tests and neutral 806/9/8/2 checks pass.
The Lua suffix-loss fact prompts seven direct Dart controls: the standalone fluent adapter
drops its parser helper's remainder, accepting truncated .Töp() and .Top-Rule() plus an invalid
same-line tail. Existing .2.6 owns adapter and downstream body-loop retention together.
The function bridge caches its default compiled parser, while shell projection consumes the
spec-returned nodes. No Unicode table, parser behavior or parked builder capability changes.

## 2026-09-09 — compact argument extraction and outer block collection

`DART-STARTUP-READING.1.12` completes spec-parser reading and staged v1 registry through line 677.
Compact completeness skips literals, but extraction counts their parentheses. A quoted opening
parenthesis makes extraction fail, then fallback clears the argument and remainder: return()
compiles and produces null/matched=false. The closing-parenthesis twin truncates and rejects.
Outer brace collection independently lacks regex state and truncates /}/ and /(})/ lifecycle
payloads. Ten source/native controls retain six successful values; .2.7 and existing .2.2.2
own repairs. The v1 registry constructs adapter/cache-key metadata; general v2 frozen cached
authority remains a separate canonical owner. Existing parser/registry tests pass 17/17.

## 2026-09-09 — Dart body suffix loss precedes validation

`DART-STARTUP-READING.1.11` completes MCP server/wire reading and spec parser through line 744.
Both parser body loops drop unsupported suffixes after regex or E elements; validation cannot
reject text absent from the AST. Fourteen controls distinguish four accepted malformed tails,
four valid controls and six retained/rejected invalid cases. Gated .2.6 owns repair, coordinated
with Rust startup .53 and the existing lifecycle-I diagnostic-precedence boundary.
Wire source explicitly rechecks final-EOF payload size; no new EOF runtime outcome is claimed.
Existing strict-stdio/spec-parser tests pass 16/16, without closing uncovered defects.

## 2026-09-09 — Dart MCP serializer order and enforcement boundaries

`DART-STARTUP-READING.1.10` completes generated data and contract-runtime reading, then server
registration/dispatch/policy helpers through line 1019. Default SplayTreeMap sorting uses UTF-16
ordering and reverses U+E000/U+10000 against the neutral canonical byte owner. ASCII/BMP controls
pass; nested and injected schema-valid decoded-dispatch responses reproduce the difference.
The injection proves a production dispatch path, not native payload construction or wire behavior.
Gated .2.5 owns affected-route proof and repair. Existing 11-test success is retained without
claiming complete canonical Unicode coverage.

## 2026-09-09 — generated MCP policy and response boundaries

`DART-STARTUP-READING.1.9` reads the canonical frames, transport policy, complete corpus and
schema prefix through the page field. Native semantic rejection remains a successful tool transport
payload; handle/policy errors and JSON-RPC errors retain distinct envelopes. Explicit policy
components alone intercept native dispatch. Generator freshness and decoded identity verify the
complete data owner without granting physical credit beyond byte 65,855 or runtime enforcement.

## 2026-09-09 — Dart corpus selection and file-loading boundaries

`DART-STARTUP-READING.1.8` confirms whole-corpus validation before selection, structural
`[expectedJson]` output comparison and per-fixture execution failure collection. Named loading
uses ordered direct roots and first-regular-file selection; strict UTF-8 text/BOM is preserved
before the composed parser's stage-specific rejection. Existing corpus/loader/MCP facts retain
their older evidence with current qualifications. The complete 42-test selection passes;
physical reading stops at the generated MCP prefix, independently of binding-test coverage.

## 2026-09-09 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.8 - admit approved history member

The director's “Greenlighted !” approves DART-STARTUP-READING.4's exact additional history exception. ADR0110 changes only three registry scalars: collection files 30 to 31 and manifest lines/bytes 29/16463 to 30/17039. Remeasure from clean f8b626f0: lines 221-393 are the same 173-line / 26767-byte suffix measured in the earlier proposal, now with current source blob 8e1f556504159c8042676a9c49efbeb448de2bfe. Independent full-byte reconstruction preserves every older record; 22 actual validator executions exercise equality, independent and combined overflow, plus rejection by prior limits and acceptance by approved controls. Exact staged canonical proof is required; subsequent Dart reading retains all other startup gates.

## 2026-09-09 — DART-STARTUP-READING.1.7 - read compiler; own recognition effect bypass

RecognitionTransactionAuthority.classifyEffects rejects binding_write when directly called by neutral tests, but dart/lib has no production caller. Compiler observation effect closure follows explicit rule/functions and scans payloads without structural action/blind transitions. Runtime recognize_once executes the child before recording its attempt; rollback restores cursor/boundary/marks, not forbidden binding changes. Eight native/authority controls confirm seen changes from 0 to 1 through a recognized child and stays 1 after rollback, while pure rollback stays 0. Structural observation routes enter Observer I instead of rejecting. .2.4 owns complete graph integration and carrier/public proof; this intake does not broaden snapshot semantics or claim untested carriers.

The same leaf’s draft history rollover passed exact source copying but exceeded the three approved collection/manifest controls. Its generated candidate is retained in managed scratch; source c2682cf9 and the manifest record reproduce it. Restore only that uncommitted rollover, preserve every earlier history byte, and shorten only the new changelog record to 339 bytes. CHANGES is then 58,814 bytes; .4 records the exact additional exception and blocks further committed reading pending the director. No capacity limit changes here.

## 2026-09-09 — DART-STARTUP-READING.1.6 - read CLI and compiler entry; own trace overflow

Primary CLI trace validation recognizes decimal syntax with a regular expression, while later conversion uses bounded int.tryParse. _CanonicalTrace.create resets the file before conversion, and its filesystem catch does not cover the resulting StateError; invalid text returns usage 2 before the reset. Seven adapter probes isolate both signed endpoints, adjacent overflows, 0/100 and invalid text. This proves the validation/order defect, not a process-exit or other-backend result; .2.3 owns resolution and repair. Compiler prefix reading preserves ordered last-definition state, entry selection and structural regex-slot identities; validation bodies continue in .1.7.

## 2026-09-09 — DART-STARTUP-READING.1.5 - read callable and spec state; own regex scanner defects

Callable normalization recursively checks retained bodies structurally, while ordinary helper-dependency resolution remains deferred; no body execution follows from normalization. The registry preserves ordered unique names, immutable containers, fixed/variadic matching and descriptor versions. Spec AST decoding retains distinct line/offset and selector-omission fields. The scanner probe isolates two regex-brace failures: slash followed by opening parenthesis is not recognized as regex by the inner delimiter walker, and lifecycle balance counts regex braces even in a programmatic SpecFile. The latter blocks normal execution of both regex-brace controls; only ordinary-group and quoted-pattern controls execute true. Validator lines 322-398 are diagnostic reading, not whole-file credit.

## 2026-09-09 — DART-STARTUP-READING.1.4 - read assignment, mutation and scanner parsing

The parser recognizes staged dispatch only in exact scalar-assignment shapes; normalized literal options and flattened text provenance remain logical data. Receiver mutation separately enforces bare addressable roots, one adjacent bang, empty arguments, immediate callbacks and parenthesized ordinary continuations, retaining explicit character spans. Contextual candidates retain outer body bounds while reparsing body-local AST. Scanner state preserves quote/regex and nesting context, but this range ends inside quoted/regex consumption; .1.5 owns the remaining tail. Existing canonical records own runtime guarantees; 79 passing selected tests do not repair the switch omission.

## 2026-09-09 — DART-STARTUP-READING.1.3 - read resolver and parser; own switch body omission

The resolver prefers extracted switch cases/default over the complete body; the parser can stop extraction early and overwrite the default. Native and SpecFile-reconstructed execution consume those extracted branches. Controlled unknown-helper placement distinguishes lost diagnostics from lazy branch execution and shows that compile acceptance alone does not imply no contract diagnostics. The finding card preserves all five outcomes and precise sources. Ordinary offsets, explicit character spans, static recognition operands and deferred callable bodies retain their contracts; no whole runtime file is credited by diagnostic excerpts.

## 2026-09-09 — DART-STARTUP-READING.1.2 - read remaining ActionIR nodes and helper tables

ActionIR keeps mutation receiver identity, callback body and post-mutation continuations in typed fields. Exact aggregate-selector detection excludes inert callable literal bodies, matching the existing deferred-state contract; that exclusion is not an eager traversal defect. Contract names include canonical helpers, numeric/current aliases and accepted source-boundary aliases. The old resolver fact now makes that distinction and replaces its scaffold-era whole-Dart text negation with focused existing tests. The read ends inside _familyForCanonical; no remaining resolver code is credited until .1.3.

## 2026-09-09 — DART-STARTUP-READING.1.1 - read Dart entrypoints and initial ActionIR declarations

The 22 explicit export directives preserve the public boundary while progressive/staged/recognition ActionIR declarations remain internal to the package facade. The first AST range records logical data and structural JSON, with copied unmodifiable staged provenance/capability lists; runtime behavior is not inferred from declarations. It ends at the literal-codeblock constructor, so .1.2 owns the remaining fields and serializer. Existing nine tests cover AST parsing and spec reconstruction, not exhaustive runtime admission. Source-reading credit is recorded separately from decomposition and repair completion.

## 2026-09-09 — DART-STARTUP-READING.0 - freeze exact bounded Dart reading children

The reproducible Dart plan becomes actual ownership under .1.1-.1.55. One-based inclusive line coordinates and two UTF-8-safe file-byte windows account for one oversized physical line; 80,297 window fragments therefore cover 80,296 physical lines. Per-child and global digests verify the declared plan independently of its generation. Pending children omit verification-tier declarations until activation, preserving exactly one owning tier per commit. Comprehension and repair completion remain separate from decomposition.

## 2026-09-09 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.4 - admit bounded Dart reading ownership

The separate Dart tree keeps the startup member bounded while retaining every earlier reading range and repair owner. Its .0 must decompose .1 before reading; .2 captures newly confirmed repairs under existing startup gates; .3 can close startup .3.4 reading while pending repairs keep the separate tree open. Admission adds only five pending definitions and does not claim comprehension. The full original reserve is applied again on top of the actual new member and current stores, a conservative admission check. Root metadata and index frontiers now agree; .7.1 status explicitly labels its former pending exception as historical.

## 2026-09-09 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.3 - independently verify Dart capacity and evidence retention

The independent census preserves 2,137 ID-prefixed blocks across 100 task Markdown files; 2,073 use the exact complete-line syntax counted by the current-ID checker. The remaining headers have trailing text and remain byte-identical; the broader preservation count is not a current-ID total. Knowledge Map has a single-file limit schema, while task and Knowledge collections have aggregate/member schemas; the audit handles each actual registry contract. Applying all original growth/template/setup allowances again to the current population conservatively retains the complete Dart reserve. Canonical 4489f5e9 passes all nine doctrines, CLI 66x2 and Phase 0 1,032/1,032 in 1,152 seconds; 25 optional gates remain skipped.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.2 - implement the approved Dart capacity controls

The director explicitly greenlit the capacity exception before remaining full-codebase reading. Only one executable owner changes: the task partition checker extracts its existing member/aggregate predicates into pure functions used by the main census and its real boundary tests, then changes two aggregate caps. The registry changes exactly four scalars in two surfaces; route contracts and storage/topology authorities remain identical. Markdown-only task census and index-inclusive routing census retain their distinct scopes. A recorded audit invokes exact validator definitions with actual approved records; accepted design, book and continuity reflect the approval without activating Dart reading or pending repairs.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.1 - design bounded Dart capacity and record the approval boundary

The 611d7b5c-to-95915ffb interval is observed net documentation growth, including Rust reading and intervening consolidation, not an isolated experiment or a bound on future findings. Twice that sample plus template/setup reserves fits proposed 88,000 task lines/9 MiB and 1,152 Knowledge files/72,000 lines; member, Knowledge-byte and generated-map ceilings stay unchanged. Guard constants make this a real reading-gate decision before implementation. Existing task identities and evidence remain in place; the future Dart tree bridges startup .3.4. Correct the .7.0 commit-body label: its 1,018 Knowledge members are 1,017 facts plus README, not INDEX; counts were correct.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.0 - measure Dart reading demand and documentation capacity

The old 56-group estimate fixed source totals and ceilings but did not preserve executable packing or group membership. The new recipe independently proves all source coordinates, byte identity and 55-group bounds; splitting at an existing file boundary proves a separate valid 56-group control with the same 169 ranges. Activation 3132596c has only 60 aggregate task lines, 562 startup-file lines and six Knowledge file slots available. The projection excludes closeout and future evidence growth, so it cannot be treated as a sufficient reserve. Design .7.1 must resolve both retrieval and growth before migration or Dart admission; this ordinary measurement uses focused proof.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.67 - close Rust reading with exact coverage and durable repair ownership

The Rust closeout separates four claims: physically read bytes, reconciled understanding, durable pending defects, and the selected runtime gate. Exact interval coverage and unique commit subjects support the first two continuity claims; they do not turn historical tests or emitted-source inspections into fresh executions. Repair node bodies remain unchanged, including the generated classifier child-status, manifest portability and routing signal-status defects. Expected PGEN → RGX → LinkedSpec Rust generated dependency state is not a blocker. Capacity admission remains a distinct clean-tree task before Dart ownership and reading.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.66 - complete final Rust contract consumer reading

Completion of consumer reading does not turn source assertions into fresh runtime results. The Rust label target compiles its loaded fixture without executing it; labels and variadic functions inspect emitted text while executing generated helpers. The write target independently compiles one computed-string-path child and checks normal success; its full frozen case set is separately exercised natively. These boundaries now live in the existing canonical Knowledge owners. The next leaf independently proves every baseline byte and current delta before canonical Rust reading closeout; containment .7 must precede any Dart decomposition or source reading.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.65 - complete lifecycle trace and typed-source consumer reading

Generated/emitted terminology needs route-level evidence: the lifecycle and trace targets inspect emitted text while executing native/reconstructed or generated helpers; the staged target from .64 independently compiles children. Typed-source catalog completeness proves 92+7 identities, while three fixture programs exercise the runtime routes and four private errors constrain values. Keep these scopes and historical/native counts explicit in existing bounded cards; the nearly-full global rollout card is not expanded. Unicode casing's 91-line test uses direct, helper, receiver and array forms; current regeneration adds no new native execution claim.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.64 - complete staged recursive and carrier consumer reading

The recursive consumer tests complete breadth-first depths, exact chain identity/decrease, shared resources, expiring callbacks and original-source rebasing. Carrier proof separately compiles an inert marker program and a host-seeded program; each child must succeed before JSON comparison, and four routes compare two runs with fresh cache/counters and detached results. This evidence remains fixture-bound and does not close .73–.75/.78. Standalone helpers include native Engine execution; its .65 suffix must distinguish native/reconstructed/generated-helper execution from emitted-text inspection.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.63 - complete emitter, loader and staged consumer reading

The source-emitter consumer checks direct and compatibility shapes before and inside generated modules, spans fourteen fixtures/ten families and retains an eight-case manifest subset. The separate all-105 classifier's admission record cannot substitute for child-status validation; .77 already owns that gap. Loader non-regular cases use directories as portable surrogates. Staged current-depth tests cover four result/three failure policies and caching/atomicity fixtures, but the panic control replaces the process hook; default-hook behavior is not exercised. Recursive/carrier suffixes remain .64-owned, and existing repair boundaries stay explicit.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.62 - complete semantic admission and emitter boundary reading

Admission's twelve roles freeze fixture identity, query digests and host-leak denials; emitted-labelled routes directly invoke generated-plan helpers and traced wrappers disable text tracing. Alias tests independently compile four modules and check child success; emitter suffix remains .63-owned. The routing verifier and Git helper discard signal bits, confirmed by twelve source-extracted original/guard controls; nine history-helper controls retain correct failure handling. Pending .79 owns production repair. Preserve the .61 canonical/native results separately from optional-gate history and locate September 8 loader samples without inferring an OS cause or a sampling workaround.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.61 - complete semantic consumer reading and roll engineering notes

Independent emitted observation asserts value, three events, positions 1/2/2 and first/last kinds; full typed-event equality and query digest belong to separate tests. Semantic reading remains distinct from fresh native execution. This checkpoint also owns the mandatory engineering-notes history rollover and its exact finite routing-capacity admission.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.60 - complete Rust cursor and diagnostic consumer reading

Cursor fixtures prove family-derived policies within their declared cases; nonnumeric AND selectors remain outside those exclusions. Diagnostic tests preserve effective/source/deep-child identities, while the semantic prefix checks source ownership and UTF-8 boundaries. These are source-reading conclusions plus neutral governance, without fresh native execution.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.59 - complete Rust root-selection consumer reading

Root selection preserves immutable authored identity while execution chooses explicit selector, first marker or first rule. The reviewed emitted-labelled roles inspect source or exercise generated-plan adapters; independent compilation remains a separate consumer. Historical intermediate rollout results stay dated; current neutral proof is 7/0 with 54 mutations.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.58 - complete recognition and observation consumer reading

The emitted manifest probes validate construction, same-target relative controls and exact cleanup without child Cargo builds. Nine runtime-test writers persist absolute dependencies; five sites already use relative inputs. ADR 0052 distinguishes these authored inputs from tool-cache metadata. Runnable evidence and future repair live in `rust-emitted-cargo-manifest-path-portability-gap`.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.57 - complete progressive and punctuation consumer reading

Punctuation aliases preserve their parenthesized counterparts, including the known missing-needle contains result. Recognition keeps matched state separate from falsey payloads. Source assertion coverage and freshly executed proof remain distinct.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.56 - complete MCP tests and reconcile progressive authority reading

MCP positive transport tests do not discharge the existing mixed-error, panic-output or final-EOF defects. The private progressive authority target and admitted four-carrier consumer have distinct cfg/routing boundaries. Their dated rollout snapshots need explicit temporal labels.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.55 - complete mutation consumer and checkpoint MCP admission reading

Mutation guard statements in these tests precede return(value), leaving known final-expression exceptions outside their scope. MCP admission builds native indexes before registration; that host setup does not expose parser construction through MCP. At four lines per ordinary record, .61 reaches the engineering-notes rollover threshold; that leaf owns exact archive preservation and any required canonical capacity admission.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.54 - complete gap and logical consumer reading

The gap and logical emitted harnesses require successful child termination, unlike the reproduced classifier defect. Logical fixture adaptation still skips the codeblock row; later callable proof does not turn that older consumer into exhaustive row coverage.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.53 - complete integration reading and checkpoint gap-capture consumer

The integration suffix exercises bounded shipped-spec results and rich capability fixtures. The gap prefix introduces role accounting, adapters and emitted fixture sources; preparing those sources does not establish an executed emitted result.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.52 - reconcile integration control and traversal reading

Expression-block returns are local to value evaluation; rule return and accumulator effects have separate boundaries. Callback scopes restore temporary bindings, while mutation assertions distinguish copy from rebinding. This checkpoint reads those controls without rerunning them.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.51 - reconcile classifier reading and own failed-child verification repair

Pass-marker completeness cannot establish successful child termination. The classifier loses that distinction despite recording status in diagnostic text. Repair .77 owns exact process/marker accounting. Return-channel documentation now distinguishes historical shared stores from current selective rule-variable snapshots.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.50 - reconcile corpus and diagnostic test-consumer reading

The corpus compares compatibility output with a wrapped reference. Diagnostic consumers distinguish typed-v2/direct results, compatibility arrays, output sinks and trace. Reading assertions and a classifier prefix does not establish a new native or emitted run.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.49 - reconcile Terse and legacy corpus reading

Stored legacy smokes exercise narrow paths: TkGui is empty, tablegrep is one TERM and VHDL is library/use text. Direct-root and LX-root recursion preserve different outer array shapes. Existing Knowledge retains the richer-case limits.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.48 - reconcile user-function edge grammar reading

Block, fluent and bare edge forms retain different fields; grouped bare edges add source_form. Recursive blocks preserve nested quoted content. Existing grammar Knowledge applies; this is source reading evidence.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.47 - reconcile minimal-rule and user-function grammar reading

The function-definition corpus oracle stores norm(value) and its body text before Top in the first paragraph, followed by a separate Done paragraph. The captured action code contains the call to norm. This proves what the stored syntax representation contains; it does not by itself prove function execution or backend parity. Existing self-hosted grammar Knowledge remains the authority for grammar ownership and bridge policy.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.46 - reconcile comment-skip and minimal-rule grammar reading

The comment-skip input starts with a comment before Top; spec_file dispatch skips that token, and the minimal-rule stored oracle contains one paragraph with rule and regex nodes. The completed grammar suffix preserves complete-line lifecycle precedence, standalone-I normalization, variadic signatures and capture marker/directive nodes. This checkpoint records source comprehension and stored evidence without claiming a new parser execution.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.45 - reconcile self-hosted labels and edge grammar reading

Unicode label membership and physical token boundaries are separate constraints: line anchoring and trailing boundaries prevent valid prefixes or suffixes from silently replacing invalid labels. Headers keep top and mode distinct; named regex slots preserve slot_name, while edge forms select target(s), code or fluent/raw fields. Existing self-hosted-rule-label-physical-boundaries Knowledge remains the causal owner. No runtime or public behavior changes.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.44 - reconcile self-hosted grammar reading and mirror freshness

The self-hosted grammar preserves separate fields for fluent, indexed, blind and bare edges. Complete-line lifecycle dispatch precedes generic bare edges; standalone blocks normalize to lifecycle I. Variadic functions emit a versioned signature, while paragraph accumulation copies completed rules. Mirror identity and Unicode fixtures establish freshness; the inspected comment-skip oracle is stored evidence, not a newly executed parser result.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.6 - consolidate verified task chronology and correct historical references

Historical task records use both full subjects and abbreviated pointers; some table captions differ from exact Git subjects. Consolidation preserves those distinctions, matches only explicit subject/typographic variants backed by Git, and retains unmatched captions. Git b4217c37 changed the expression-block task's placeholder to an unrelated string-comparison commit; its real c5f2204b reference is restored with the old value labeled. No parsing behavior, acceptance field, verification evidence or doctrine changes. The retained Dart decomposition estimate needs a later capacity admission, so .6 is an ordinary focused leaf and .7 keeps the capacity parent open.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.43 - reconcile corpus reading and own SimEnv dispatch repair

The SimEnv edge matches variable_substitution but explicitly calls bvariable_substitution in three quoting contexts. Generated action inspection follows that authored callee; changing only those targets in memory restores bare variables while braced controls retain their node shapes. This is distinct from historical single-line verbatim loss. Corpus inventory, stored oracles, empty-input reachability and executed runtime evidence remain separate. Required reading and full cross-backend repair are still pending; the director's RGX/PGEN build-chain clarification is preserved without treating generated dependency state as a blocker.

## 2026-09-08 — STRUCTURED-TEXT-FORMAT-PROGRAM.0.1 - record approved parked language coverage and evidence matrix

Coverage count, conformance, mechanisms exercised, authoring friction, performance and confidence answer different questions. The parked extension records them separately with reproducible evidence and unassessed states. Language membership/version/dialect and bounded parser ownership are selected at activation; every confirmed gap gains a minimal reproduction and a repair owner. The existing neutral-language/all-backend sequence continues, and finite inventory coverage does not prove universal parsing completeness.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5 - compact duplicate startup chronology without losing evidence

Line pressure came partly from recording the same commit subjects in both task nodes and a global table, plus a manually enumerated Git batch. Removing these duplicates preserves one richer node-local owner and reproducible Git history. Independent pre/post comparisons retain all notes and all non-Commit fields; the provenance card supplies the clean source identity and exact batch reconstruction. Read-only donor checks still match all three September 6 policy hashes; local adoption review remains startup .5-owned.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.42 - complete callable and named-mark reading with corpus prefix

The completed consumers assert different carrier boundaries: contextual callable coverage compiles an emitted fixture, while the named-mark consumer inspects emission and executes a validated generated plan. Reading preserves those distinctions without claiming a fresh native run. The measured task collection requires proven duplicate removal under its existing containment owner; unique reading and repair evidence stays addressable.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.41 — The final batch boundary preserves exact coverage and verification scope

Unicode casing uses binary-searched property intervals and original input scalars for Final Sigma, then emits full mapping sequences without normalization. The callable prefix uses different strengths of diagnostic assertion across routes; source reading must preserve that distinction. The first 99 batch commits are independently matched to their recorded leaves and hashes. The final exact staged candidate runs canonical CI; its completed result is added to the ignored commit-message brief so durable commit evidence can include the result without changing the verified candidate.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.40 — Full upper mappings preserve sequences without promising an inverse

The generated upper table contains ordered two- and three-scalar expansions and maps multiple inputs to one uppercase scalar. These data agree with the existing Unicode contract. Completing the physical table reading adds no algorithm or runtime execution claim; property ranges and contextual evaluation remain the next owned range. Unchanged generation inputs preserve the preceding focused proof.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.39 — Separate completed canonical proof from sampled waits and preserved probes

The accepted .3.3.38 receipt binds its exact staged candidate and committed eba1a0ed. The two macOS samples locate pre-main waits that later cleared; build and test durations are separate, with no new OS-cause claim. Their exact log/report identities are in the existing launch-latency Knowledge card. A static probe rerun exercises its linked runtime, so repair verification must rebuild against newly verified libraries. Unicode map expansions and identity entries retain the pinned contract; public behavior is unchanged.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.38 — Declaration authority and legacy registry metadata have distinct guarantees

Marker construction materializes exact text through live source authority; detached host-returned markers require their own validation under .74. The legacy v1 registry executes a fixed built-in ActionIR adapter, constructs cache-key metadata without caching plans and delegates stitch-policy enforcement to function integration. Its integer helper joins existing .55.1 audit scope. Generated Unicode data remains pinned and regenerated, with subsequent table/evaluator reading still pending. Mandatory rollover preserves exact clean-source segment 4983 (247 lines/18,635 bytes; SHA-256 90ac78b4747014cf1c23511da66b37cd4c1e2e3d100d0b62ef7719e4cbc5bc3a); prior manifest records remain byte-identical. ADR0106 admits only 30 collection files, 29 manifest lines and 16,463 manifest bytes. The final staged canonical receipt is required before landing.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.37 — Complete-depth preparation needs destination reservation and checked marker authority

Each target can be valid against the starting AST while competing with another prepared job. Paired probes show why whole-depth reservation must precede the first callback, with shared append retained. Atomic marker node accounting also must retain deep record validation: Rust accepts forbidden marker fields and reaches an unchecked extent sum for invalid derived provenance. Separately, saturating a call counter before comparing its maximum admits a callback at MAX/MAX. Task owners .73–.75 preserve focused controls, typed-error requirements and later carrier/book verification.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.36 — Prepared registry data and fresh invocation state have separate lifetimes

Rust freezes caller-completed candidates and binds opaque compiled callbacks before dispatch. Seed state may be shared, while each execution receives a fresh registry/cache and recursive counters; callback-local records omit live authority. The queue coordinator prepares and validates a complete depth before callbacks and retains cumulative resources across depths. Lower execution, identity, stitching and rebasing helpers remain in the next reading window, so this prefix does not establish new native results for those mechanisms.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.35 — Function stripping preserves scalar coordinates while source authority keeps typed provenance

Rust validates function source/body text against decoded-scalar spans, normalizes staged job identity and executes the fixed body parser before attaching its result. Stripping substitutes one space per non-newline scalar, so line/scalar positions remain stable while UTF-8 byte length can shrink. The semantic source mapper handles its own byte conversion. Separately, sealed source-value materialization revalidates authority and each provenance span; the native loader preserves explicit discovery and structured pipeline stages. The existing Knowledge-card cap caught the large rollout card at 66,112 bytes; the new Rust authority sections are routed intact to their own fact card with a retained pointer and unchanged budgets.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.34 — Native emitted modules expose gaps outside the neutral fixture corpus

JSON string encoding does not cover Rust literal syntax for every accepted identity. Separately, recognition emission rewrites only plain parse to direct-value execution; default-options, disabled-trace and no-sink siblings still use the accumulator. Actual emitted-module compilation/execution establishes both limits independently of neutral gate success. .71/.72 own corrected literal boundaries, coherent accepted projections and public recurrence; uncalled private probe roles explain 34 dead-code warnings, while one unused emitted import belongs to the recognition rewrite.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.33 — Correct grouped execution can coexist with incomplete semantic provenance

Rust's semantic selector scan finds Child inside ChildLong and loses its explicit index; Perl joins expanded edges to physical source members and loses the second grouped edge's source/index. Separate-member controls remain correct, and grouped execution still returns b. A different initial selector spelling also exposes Rust's partial group parsing and discarded action remainder. Task .70 separates those mechanisms and requires an authoritative grammar reconciliation before any syntax change; existing fixture equality is insufficient source-correlation proof.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.32 — Private rejection tests do not prove authored token-use enforcement

Rust's token authority rejects escapes when called directly, but the real assignment handlers put Undef in the ordinary scalar table and ordinary reads never invoke that rejection. Two clean authored controls therefore return null where Perl rejects; a legal return agrees. The newline-only copy is a different parser failure and is preserved separately from the semicolon control. Native slot controls also rule out the initially suspected false missing-rule mapping because ordinary validation catches the invalid selector earlier. Repairs .68/.69 and the existing .45 own the distinct causes.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.31 — Cross-backend agreement still needs independent semantic evidence

Rust and Perl return matching signature-acceptance explanations even when their own declared one-argument signature contradicts the zero/two supplied argument count. Both also skip calls under an array node; the independent Get control executes trim and returns ["x"]. The Rust binding source additionally disappears because its registration depends on an emitted RHS call. Task .67 separates truthful compatibility evidence from complete typed traversal/source correlation and requires independently justified recurrence beyond frozen fixture equality.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.30 — A latest-binding lookup cannot also count binding occurrences

Rust call projection stores one latest binding ID per owner/name but counts those keys when allocating occurrence order. That count stays at one, so the third and later writes reuse an ID and overwrite its source-reference entry. Six paired public queries isolate this from the empty-function gate and from ordinary one/two/distinct-name controls; the final excerpt appears on every reused Rust record. Perl's separate counter provides independent occurrence evidence. Repair .66 requires distinct allocation plus query/source recurrence; frozen one-write fixture equality alone did not expose the defect.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.29 — Binding identity and public aggregate results have distinct ownership

RuntimeContext resolves guards through current binding identity and preserves the existing private aggregate store when updating a bare value. Absent Undef permits aggregate initialization; explicitly bound Undef fails the kind check. Bare pop yields a detached updated array, while private pop yields its removed element. Observation completions are consumed within their local scope, typed source adapters convert byte registers through immutable authority, and diagnostic/output/semantic/trace channels retain separate ownership. The next window owns full variable snapshot restoration.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.28 — Recognition rollback includes private gap state alongside public snapshots

The live frame adapter captures committed gap cursor, edge ordinal and detached candidate alongside cursor/boundary/marks. RuntimeContext delegates to one parse authority, restores prior same-label marks on exit and projects gap spans through immutable source authority. The exact 92-name/seven-alias catalog was decoded independently; current neutral proof is distinct from the dated native alias repair. Source reading adds the incoming JSON bridge to .55.1's round-trip audit without asserting a new failing input.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.27 — Current source guards and dated runtime evidence have separate scopes

Rust's token validation checks source/invocation before reuse, like Perl, but its restoration helper first returns on Invalidated. The exact stale-snapshot mechanism measured in Perl is therefore absent from this Rust helper; .38 still owns the full behavioral/runtime census. CLI source and 66 default cases confirm source/input/top-rule trace metadata with no retired parse-mode field. Historical 61-case and 3-of-9 Knowledge claims are now explicitly dated, while fresh neutral recognition is complete 9/9. No native recognition consumer or Rust compiler runs in this slice.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.26 — Separate valid size controls expose a missing EOF combination

Both Rust and Perl retain one byte beyond the payload ceiling for CRLF framing. Rust rechecks size only in its newline branch; Perl also checks in decode_payload. A valid padded discovery frame at maximum+1 therefore succeeds only on Rust EOF, while maximum+2 and both newline delimiters reject correctly. Existing malformed overlong input cannot isolate a size check from JSON rejection; ordinary EOF and maximum CRLF tests miss the combination. Twelve independent pairs and exact Rust canonical bytes bound the finding to one byte. .65 owns the correction and recurrence; the initial Perl probe option typo ran no accepted case.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.25 — A sanitized returned response does not establish silent process output

The MCP prepare_response builder is wrapped in catch_unwind and returns fixed -32603 on panic. Its existing fixture asserts only returned JSON. With --exact --nocapture, the test still passes while stderr records the synthetic panic and source location. Response construction and process-level panic reporting need separate evidence; .64 owns the bounded correction without silently replacing a host-global hook. Native timing separates 6m10s build from 2.43 test seconds and 524.920 total. Source reading also confirms Rust's method/version-before-full-schema order under existing .36. No production or public-document repair precedes startup prerequisites.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.24 — Generated identity and physical comprehension have different boundaries

The generator can prove byte equality for the entire 83,225-byte module while this reading leaf owns only its first 65,536 bytes. Keep those facts distinct. Its shared builder verifies source digests and canonical frame encoding; the Rust renderer embeds canonical JSON with a noncolliding raw delimiter. Four semantic text/structured pairs retain exact identity, including semantic failure in a successful transport envelope. Fresh neutral admission validates governance rather than rerunning native servers. The next leaf continues inside the schema and then reads production dispatch support.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.23 — Restoring offsets does not restore discarded regex context

Rust adds the cursor offset back to match coordinates after passing only input[pos..] to the provider. This cannot restore input-start or preceding-character context for anchors, lookbehind and word boundaries. An explicit collector exposes five disagreements after consuming x; the first uncollected chain returned null and could not answer the question. Whole-input matching must keep slot identity and all capture projections aligned across seek, consume and required-slot routes. .63 tracks that repair and independent carrier/public closure. Engine suffix tests meanwhile demonstrate exact rollback/effect assertions on their covered write routes.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.22 — Returned values alone do not prove skipped operand effects

The coalesce_short_circuits test returns the expected first string even when Rust eagerly evaluates every argument. Assignment probes expose the missing effect boundary in both coalesce variants; a separate predicate also skips defined empty text. Perl's nested ternaries preserve selection order. The initial diagnostic collector then introduced an unrelated false-to-string artifact; inspecting the original lowered Boolean and rerunning with JSON::PP::is_bool preservation separates observer behavior from runtime behavior. .62 tracks actual repairs and permanent recurrence; existing capture cards now distinguish historical free helpers from current typed authority.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.21 — Range clipping and undefined-value semantics need explicit boundaries

Clipping an array slice's end does not constrain its start, and start+n can overflow before clipping. Rust's primary reproduces four small range panics and one arithmetic panic; bounded Perl controls return empty arrays. Separately, to_str turns undef into empty text before seven transformations and four predicates, while empty-old str::replace inserts separators. Literal undef and an unbound null-name twin both reproduce the differences; empty-string controls agree. .60/.61 retain exact fixes and carrier/public obligations. Reading smoke tests that check only wrappers or membership does not establish the stronger behavior suggested by their names/comments.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.20 — Substitution needs statement routing and receiver protection

Ordinary bare-g substr/regex_subst controls agree, but quoted flags select different Perl paths. Inside callbacks, Perl emits unsupported-helper markers even for unrelated scalar targets; descriptors show unresolved=1/ready=0 while execution continues. Rust performs substitution but its receiver_write_attempt omits both names before unguarded scalar publication. Ten paired values/errors and actual generated text establish separate .59 repairs; the prior final-assignment gap stays in .58. Neutral success is bounded to its fixtures and does not close either omission.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.19 — Final assignments must share the receiver guard

eval_block_value sends its last active statement to eval_block_final_expr, whose direct scalar/nested assignment branches bypass eval_expr's pre-evaluation receiver guard. Native CLI and structured diagnostics reproduce the resulting success, while Perl rejects; moving the write before return(value) restores Rust rejection. The coordinator's success-only rebuild publication cannot compensate for an unchecked callback write. Repair .58 requires shared guard authority and exact state/effect/carrier regressions. The separate compiler wait sampled procedural-macro dlopen/fcntl, then cleared; it establishes no OS cause or trust-workflow change.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.18 — Function stores and temporary callable parameters

Named user functions take the caller's variable stores and install fresh fixed/rest bindings; callable values temporarily replace only their parameter bindings while using the caller's other stores. Both restore state after body evaluation returns a Result. Expression guards ask RuntimeContext about resolved identity before evaluation; source scanning supplies diagnostic spans. Recursive writes operate on the coordinator's detached snapshot and cannot publish a partial path. These are bounded source observations supported by four neutral contract checks, not fresh native execution.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.17 — Action collection and mutation snapshot boundaries

Explicit repeated action values and lifecycle return control remain separate. Native gap timing agrees with the generated loop while preserving unflagged selection order. Nested-write structural work starts after all path/RHS evaluation and classification; its coordinator commits only after recursive construction returns successfully. Four native diagnostic controls confirm dense append/gap behavior and a saturated write index: exact 2^64 is reported as usize::MAX, while the next representable larger value is an invalid selector. Existing .55.1 owns repair; hashes, retained harness and precise limits are in the numeric Knowledge card. Three prior CLI controls expose only generic invocation failure.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.16 — Invocation success and downstream completion

Execution channels have distinct boundaries: the parent rule result is observed before staged enrichment, and retained sink/exit outcomes survive later generated trace-write failure. Generated engine contexts rely on validation at the source-emitter carrier boundary, while native direct entry checks typed writes itself. Claim wording now names those exact seams and keeps dated native evidence separate from fresh neutral proof.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.15 — Generated family execution and literal versus regex splitting

Generated execution derives cursor behavior from the family plan while retaining separate action/blind loops, recognition frames, entry-slot identity and capture-specific lifecycle ordering. Normal/explicit return restoration does not imply every error-recovery route is proved. The split comparison separates literal host splitting from the regex loop's initial zero-width slice and Perl's emitted split boundary; matching Unicode scalars do not imply matching empty fields. Existing .33 owns authoritative review and repair. The diagnostic runner reads plain JSON without optional stdout trace.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.14 — Positive authority construction and current invocation/diagnostic types

Validate apparent boundary issues against the actual construction API: private positive-only ceilings make the one-byte diagnostic fallback representable without admitting zero-byte ceilings. Callback return/unwind invalidates views and pops the active chain before outcome handling. Current options include observation and two opaque seeds, while diagnostics carry later helper/slot/callable fields. Definition reading and neutral fixtures do not establish every engine callsite or replace native carrier proof; the next window owns continuation.
