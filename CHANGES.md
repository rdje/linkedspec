# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-09-11 — DART-STARTUP-READING.1.54 - read binding and function consumers

Complete Unicode routes, binding, function parser/shell and variadic tests; read
write vivification through292. All 1,500 fragments / 44,403 bytes remain identical.
All 43 tests and four neutral checks pass, including existing emitted nested-write
execution. Record detached bindings, shell ownership and fixed/variadic signatures;
separate emitted-payload reconstruction from independent execution. Next .1.55.

## 2026-09-11 — DART-STARTUP-READING.1.53 - read typed source and Unicode consumers

Complete trace, typed-source, casing, classifier, identity and negative-isolation
consumers; read Unicode routes through70. All 1,500 fragments / 44,020 bytes remain
baseline-identical. All 29 tests and three neutral checks pass, including an
independent emitted Unicode caller with fresh offline cache and fatal analysis.
Record precise AST/source/CLI boundaries; prior defects remain open. Next .1.54.

## 2026-09-11 — DART-STARTUP-READING.1.52 - complete staged and lifecycle consumer reading

Complete staged enrichment, v1 registry and lifecycle tests; read trace through260.
All 1,500 fragments / 44,374 bytes remain baseline-identical. All 38 tests and
staged/lifecycle neutral checks pass. Keep four-route staged execution separate
from lifecycle emitted-text-only and malformed exception-type assertions. Record
trace output preservation; prior defects remain open. Next .1.53 after landing.

## 2026-09-11 — DART-STARTUP-READING.1.51 - read staged enrichment authority consumers

Read staged enrichment292-1791: 1,500 fragments / 50,285 baseline-identical bytes.
All19 consumer tests and staged/typed-source neutral checks pass. Preserve private
provenance boundaries, frozen authority, atomic policies, recursion and rebasing
scope; prior .2.17/.2.18/.2.19 defects remain open. Correct the stale parent reading
rollup from36/55 to verified51/55. Next .1.52 after clean focused landing.

## 2026-09-11 — DART-STARTUP-READING.1.50 - complete frontend and emitter consumer reading

Complete emitter/AST/loader/parser/validator consumers and read staged enrichment
through291: 1,500 fragments / 45,895 baseline-identical bytes. All 54 tests and
three neutral checks pass. Preserve parser-only corpus exclusions, directory
non-regular surrogates, legacy-v1/current-staged distinction and all prior defects.
Next .1.51 after clean focused landing.

## 2026-09-11 — DART-STARTUP-READING.1.49 - complete admission and read source-emitter consumers

Complete admission, smoke and source-boundary aliases, then read emitter through529:
1,500 fragments / 48,927 baseline-identical bytes. All 12 tests and three neutral
checks pass, including isolated emitted callers. Retain the admission reused-probe
versus fresh-cache distinction and every prior defect. Next .1.50 after clean landing.

## 2026-09-11 — DART-STARTUP-READING.1.48 - read semantic observation and source consumers

Complete five semantic consumer files and read admission through line 166: 1,500
fragments / 48,937 baseline-identical bytes. All 24 selected tests and semantic
6/20/128 checks pass, including existing emitted execution and twelve-role admission.
No unread suffix credit, new defect or source change. Next .1.49 after clean landing.

## 2026-09-11 — DART-STARTUP-READING.1.47 - read matching and semantic consumer contracts

Complete the seven bounded consumer ranges: 1,500 fragments / 50,626 baseline-identical
bytes. All 30 tests and semantic/Unicode neutral checks pass, including the existing
standalone emitted observation test. Read credit ends at observation routes line 240;
prior defects remain open. Reading 47/55; next .1.48 after clean focused landing.

## 2026-09-10 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.11: approved engineering archive

Admit exactly engineering files 27→28 and manifest lines 26→27 under ADR0113.
Preserve 211 clean-source lines / 24,521 bytes, all prior records and other limits.
Exact source/history and 22 production-validator checks pass; the director’s
September 11 one-time receipt exception authorizes focused landing. Record PGEN/RGX build-on-update direction under startup .80;
no dependency or CI behavior changes. Next Dart .1.47.

## 2026-09-10 — DART-STARTUP-READING.1.46: interpreter consumers

Read 1,500 fragments / 39,292 baseline-identical bytes; interpreter complete,
matching through 86. All 68 tests and three neutral checks pass. Corrected the
stale current nested-write Knowledge answer with history preserved. Exact next
engineering archive proposal .7 is verified; no limits changed. Next .7 before .1.47.

## 2026-09-10 — DART-STARTUP-READING.1.45: cursor consumers

Read 1,500 fragments / 41,762 baseline-identical bytes; cursor consumers complete,
interpreter tests through 407. All 75 tests and the neutral cursor check pass;
no new defect. Reading 45/55; next .1.46.

## 2026-09-10 — DART-STARTUP-READING.1.44: root selection consumers

Read 1,500 fragments / 45,785 baseline-identical bytes; repeated-action/root
consumers complete, cursor admission through 298. All 13 tests and three
neutral checks pass; no new defect. Reading 44/55; next .1.45.

## 2026-09-10 — DART-STARTUP-READING.1.43: recognition and observation

Read 1,500 fragments / 45,121 baseline-identical bytes; recognition/observation
complete, repeated-action through 333. All 22 tests and three neutral checks
pass; no new defect. Reading 43/55; effect integration stays open; next .1.44.

## 2026-09-10 — DART-STARTUP-READING.1.42: trace CLI and carriers

Read 1,500 fragments / 48,485 baseline-identical bytes; trace/CLI/progressive/
zero-argument complete, recognition through 216. All 39 tests and three
neutral checks pass; no new defect. Reading 42/55; next .1.43.

## 2026-09-10 — DART-STARTUP-READING.1.41: MCP consumers

Read 1,500 fragments / 48,287 baseline-identical bytes; all MCP consumers
complete, native trace imports through 3. All 17 MCP tests, neutral checks
and binding freshness pass; no new defect. Reading 41/55; next .1.42.

## 2026-09-10 — DART-STARTUP-READING.1.40: mutation and MCP tests

Read 1,500 fragments / 49,088 baseline-identical bytes; mutation/binding tests
complete, MCP admission through 705. All 16 tests, neutral mutation/MCP checks
and binding freshness pass. No new defect; reading 40/55; earlier repairs
retain their gates; next .1.41.

## 2026-09-10 — DART-STARTUP-READING.1.39: gap and logical tests

Read 1,500 fragments / 46,756 baseline-identical bytes; gap/logical tests
complete, receiver-mutation through 176. All 40 tests and three neutral checks
pass, including independent emitted consumers. No new defect; reading39/55;
earlier repairs retain their gates; next .1.40.

## 2026-09-10 — DART-STARTUP-READING.1.38: identity and trace tests

Read 1,500 fragments / 45,409 baseline-identical bytes; duplicate-slot and
frontend/function/registry tests complete, gap tests through 718. All 15 selected
tests and both neutral contracts pass, including independent emitted gap proof.
No new defect; reading 38/55; earlier repairs remain owned; next .1.39.

## 2026-09-10 — DART-STARTUP-READING.1.37: corpus and diagnostic tests

Read 1,500 fragments / 44,134 baseline-identical bytes; compiled, named-mark,
corpus and diagnostic tests complete, duplicate-slot through 123. All 38 tests
(including 105 corpus fixtures) and three neutral checks pass. Preserve prior
findings and CI owners; no new defect. Reading37/55; next .1.38.

## 2026-09-10 — SESSION-STARTUP-READING.80.0: own CI performance findings

Record the source-backed missing PGEN watches and eleven visible test-build stages
(78m02s), with correct Cargo reuse owned by .80.1-.4. Newer macOS pre-main
observations and conditional remediation have separate .81 ownership. Knowledge,
book and continuity preserve the exact evidence and completed capacity receipt.
No implementation or reading credit; Dart .1.37 resumes after focused closeout.

## 2026-09-10 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.10: approved history member

ADR0112 records the director approval of exactly files 31→32, manifest lines
30→31 and bytes 17039→17615. Governed rollover preserves the complete clean
source suffix and every prior history record. Independent reconstruction,
three-scalar scope and actual validator boundaries govern the exact canonical
commit. Dart .6 closes; .1.37 resumes after clean admission. All other gates remain.

## 2026-09-10 — DART-STARTUP-READING.1.36: callable consumer reading
Read 1,500 fragments / 48,187 baseline-identical bytes; all 38 selected tests and callable contract checks pass, including fresh offline emitted execution. Earlier findings remain owned; no new defect. Reading reaches 36/55. Capacity intake .6 owns the next history-member decision before .1.37; no allowance changes.

## 2026-09-10 — DART-STARTUP-READING.1.35: null named-selector validation

Read 1,500 fragments / 44,700 baseline-identical bytes: complete validator,
package inputs and action-parser tests; contracts reach 203. All 35 tests and
gap/duplicate checks pass. Ten reconstructed controls own .2.23 with two repair
children: null named selectors wrongly select anonymous regexes at either index.
Six valid/rejecting controls and two provenance census inputs bound the finding.
Prior owners remain; no source repair. Reading reaches 35/55; .1.36 is next.

## 2026-09-10 — DART-STARTUP-READING.1.34: emitter and trace completion

Read 1,500 fragments / 45,347 baseline-identical bytes: complete emitter/trace
and read validation through 355. All 27 selected tests, isolated emitted callers,
ten-family/eight-case proof and neutral generated-source checks pass. Preserve
the shared semantic-v1/current-artifact-v2 distinction and all earlier findings.
No new defect or source repair. Reading reaches 34/55; .1.35 is next.

## 2026-09-10 — DART-STARTUP-READING.1.33: indexed source correlation

Read 1,500 fragments / 42,984 baseline-identical bytes: complete static
projection/SHA-256 and read emitter through 55. All 28 tests and neutral
6/20/128 checks pass. Eight public native controls extend startup .70 grouped
selectors and own regex-arrow correlation .2.22 with two children: four index
failures, four valid controls and all runtime values correct. No source repair;
reading reaches 33/55 and .1.34 is next.

## 2026-09-10 — DART-STARTUP-READING.1.32: query and runtime projection

Read 1,500 fragments / 45,289 baseline-identical bytes: complete query/runtime
projection and read static projection through 381. All 21 selected tests and
neutral 6/20/128 checks pass. Qualify older query immutability wording with the
existing .2.21 native rejection finding; retain every prior owner and gate.
No new defect or source repair. Reading reaches 32/55; .1.33 is next.

## 2026-09-10 — DART-STARTUP-READING.1.31: native rejection detachment

Read 1,500 fragments / 43,744 baseline-identical bytes: complete semantic index
and read query through 668. All 18 tests and neutral 6/20/128 checks pass.
Eight native controls own rejection response detachment/encoding under .2.21
and two children: four defective non-JSON cases and four detached JSON controls.
No MCP defect or source repair is claimed. Reading reaches 31/55; .1.32 is next.

## 2026-09-10 — DART-STARTUP-READING.1.30: semantic call counterexamples

Read 1,500 fragments / 43,400 baseline-identical bytes: complete call projection
and read semantic index through 399. All 28 tests and neutral 6/20/128 checks
pass. Nine public-query/typed-runtime controls extend startup .67 with Dart
array-call omission and own regex source correlation under .2.20 and two
children; seven valid/arity-rejection controls preserve scope. No source repair;
reading reaches 30/55 and .1.31 is next.

## 2026-09-10 — DART-STARTUP-READING.1.29: Unicode completion and call projection

Read 1,500 fragments / 37,172 baseline-identical bytes: complete Unicode
mapping/scaffold and begin semantic call projection through 347. Eleven Dart
tests and semantic 6/20/128 checks pass, including all twelve Unicode runtime
fixtures. The existing empty-function guard remains startup .22-owned.
No new defect or source change; reading reaches 29/55 and .1.30 is next.

## 2026-09-10 — DART-STARTUP-READING.1.28: Unicode mapping continuation

Read Unicode mapping 1190–2689: 1,500 fragments / 38,936 baseline-identical
bytes. Lower mappings are complete and upper mappings reach U+A76F. Fresh
regeneration matches neutral data and all five backend modules; twelve
independent fixtures pass. Retain .1.27 runtime evidence by exact source
identity and preserve all earlier findings. No new defect or source change;
reading reaches 28/55 and .1.29 is next.

## 2026-09-10 — DART-STARTUP-READING.1.27: declarations and provenance types

Complete both staged runtime modules and read Unicode lower mappings through
1189: 1,500 fragments / 39,481 baseline-identical bytes. Seventeen private/
neutral validator controls establish six malformed provenance acceptances and
eleven agreeing cases. Own .2.19 and two gated repair children, preserve exact
reproduction, and qualify the staged chapter and project status. All 33 selected
tests and Unicode generation/12 neutral fixtures pass; prior resource defects
remain owned. Reading reaches 27/55; .1.28 is next.

## 2026-09-10 — DART-STARTUP-READING.1.26: staged resource boundaries

Read staged enrichment lines 1807–3306: 1,500 fragments / 43,782 baseline-identical
bytes. Eleven private recursive controls own diagnostic-byte overruns (.2.17)
and signed-maximum call-count wrap (.2.18), with seven valid controls. Decompose
seven gated repair nodes and publish measured limitations in the staged chapter,
project status and a reproducible Knowledge card. All 44 selected tests and
neutral 123/129 mutations pass; no source repair or fresh production-carrier
defect proof is claimed. Reading reaches 26/55; .1.27 is next.

## 2026-09-10 — DART-STARTUP-READING.1.25: frozen registry and recursive dispatch

Read staged enrichment lines 307–1806: 1,500 fragments / 47,254 baseline-identical
bytes. Frozen resolution, effective authority, plan caching and recursive
preflight/dispatch reconcile with their existing scope. All 44 selected tests
pass; no new defect is established. Preserve prior findings, exact coverage and
book/live alignment; .1.26 follows the focused clean commit. The approved
engineering-history prerequisite is committed canonically at 9c644ecb.

## 2026-09-10 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.9: approved engineering-history slot

Admit the two approved engineering_notes controls: files 26→27 and manifest lines
25→26, with indexed ADR0111 and governed complete-record rollover. Exact source,
history reconstruction, old-record retention and actual validator boundaries
verify the candidate. All byte limits remain unchanged; exact staged canonical
proof governs landing. Dart intake .5 closes; reading .1.25 resumes after clean
commit. Parser behavior, earlier defects and parked ideas remain unchanged.

## 2026-09-10 — DART-STARTUP-READING.1.24: recognition and source authority

Read 1,500 fragments / 48,312 unchanged bytes: recognition, semantic observation
and source location through EOF, staged entry through 306. All 58 selected tests
pass. Existing authorities reconcile; a stale Knowledge link is corrected.
Reading is 24/55; prior defects remain owned and gated. Exact draft engineering-history
rollover preserves every prior byte but needs files 26→27 and manifest lines 25→26.
Intake .5 owns the unapproved proposal. Restoring only that verified draft and shortening
the new engineering summary lets .1.24 land; 50 bytes remain below required rollover.

## 2026-09-09 — DART-STARTUP-READING.1.23: regex literal normalization

Read 1,500 fragments / 41,162 unchanged bytes: matching through EOF and
recognition through 483. All 99 selected tests pass. Six public Dart/Perl
controls prove three escaped-literal/class corruptions with three agreements;
.2.16 owns lexical normalization and carriers. Reading is 23/55; next .1.24.

## 2026-09-09 — DART-STARTUP-READING.1.22: interpreter completion and matching

Read 1,500 fragments / 42,836 unchanged bytes: interpreter through EOF and
matching through 900. All 132 selected tests and structural corpus 31/31 pass.
Existing write, callable, staged and structural authorities reconcile without
a new defect. Reading is 22/55; next .1.23; prior repairs remain owned.

## 2026-09-09 — DART-STARTUP-READING.1.21: input-slice boundaries

Read 1,500 fragments / 39,933 unchanged bytes through interpreter line 9674.
All 124 runtime and six contract tests pass. Nine native/reconstructed and Perl
facade/source controls extend .2.14 typed slice overflow and own .2.15 arity.
Book/KM retain exact limitations and replay. Reading is 21/55; next .1.22.

## 2026-09-09 — DART-STARTUP-READING.1.20: value-helper boundaries

Read 1,500 fragments / 41,244 unchanged bytes through interpreter line 8174.
The corrected 111-test selection and neutral numeric 55/18 pass. Eleven number,
eight Unicode-order and six slice comparisons own .2.12-.2.14 with exact
native/reconstructed and Perl facade/source evidence. Book limitations and prior
owners remain durable. Reading reaches 20/55; next .1.21. No executable change.

## 2026-09-09 — DART-STARTUP-READING.1.19: hash splice pairing

Read 1,500 fragments / 43,446 unchanged bytes through interpreter line 6674.
All 122 selected tests pass. Nine native/reconstructed hash cases and nine Perl
facade/source comparisons own Dart splice pairing/order repair under .2.11;
FUTURE-PARITY-BACKLOG.5 retains existing helper caveats. Exact replay and book
limitation are durable. Reading reaches 19/55; next .1.20. No executable change.

## 2026-09-09 — DART-STARTUP-READING.1.18: callback recursion identity

Read 1,500 fragments / 45,330 unchanged bytes through interpreter line 5174.
All 140 selected tests pass. Nine native/reconstructed controls expose false nested-helper
callback cycles and lost bound callback identity. New .2.10 owns repair/carrier proof;
exact replay and book limitation are durable. Reading reaches 18/55, next .1.19.
No executable change.

## 2026-09-09 — DART-STARTUP-READING.1.17: mixed value-control execution

Read 1,500 fragments / 40,984 unchanged bytes through interpreter line 3674.
All 124 selected tests pass. Ten native/reconstructed controls show attached controls
inside marker value ranges can escape local returns or skip else. New .2.9 owns repair
and carrier proof; exact replay and the book limitation are durable. Reading reaches
17/55, next .1.18. No executable change.

## 2026-09-09 — DART-STARTUP-READING.1.16: rule execution and observer error identity

Read 1,500 fragments / 43,183 unchanged bytes through interpreter line 2174.
All 100 selected tests pass. Six public native controls show action-mediated child
observation replaces the original callback error/stack; direct/blind/final controls preserve
them. New .2.8 owns repair and carrier/cleanup proof. Exact replay and book limitation are
durable; reading reaches 16/55, next .1.17. No executable change.

## 2026-09-09 — DART-STARTUP-READING.1.15: dispatch, runtime and nested authority

Read 1,500 fragments / 45,477 unchanged bytes through bounded authority/generated-plan EOF
and interpreter line 674. All 82 selected tests and neutral progressive checks pass.
Ten private-authority controls confirm missing nested budget/grant inheritance; existing startup
.37.1/.37.2 own repair/diagnostic review. Exact replay and book limitation are durable.
Reading reaches 15/55; next .1.16. No executable or policy change.

## 2026-09-09 — DART-STARTUP-READING.1.14: function projection and bounded source authority

Read 1,500 fragments / 44,607 unchanged bytes through function-shell EOF and bounded authority
line 746. All 24 selected function/progressive tests pass, including emitted analysis/execution.
No new confirmed defect; Knowledge, book, roadmap and live pointers agree at 14/55.
Existing repairs stay gated; next .1.15 completes authority and begins runtime reading.

## 2026-09-09 — DART-STARTUP-READING.1.13: Unicode, function bridge and fluent suffixes

Read 1,500 fragments / 48,522 unchanged bytes through staged registry/Unicode/function parser EOF
and shell line 252. All 25 selected tests and neutral Unicode checks pass. Seven source/AST/
validation/compiler controls confirm body-fluent suffix loss, extending existing .2.6.
Exact replay, public limitation and prior evidence are durable; reading reaches 13/55, next .1.14.

## 2026-09-09 — DART-STARTUP-READING.1.12: spec lexical boundaries and staged v1

Read 1,500 fragments / 41,630 unchanged bytes through spec-parser EOF and staged registry line 677.
All 17 selected tests pass. Ten source/native controls establish compact argument corruption (.2.7)
and outer regex-brace truncation (existing .2.2.2). Exact replay, public limitations and v1/v2
registry distinction are durable; repairs remain gated. Reading reaches 12/55; next .1.13.

## 2026-09-09 — DART-STARTUP-READING.1.11: MCP wire and body suffix retention

Read 1,500 fragments / 39,800 unchanged bytes through MCP server/wire EOF and spec parser line 744.
All 16 selected tests pass. Fourteen source/validation/compiler controls confirm discarded regex/E
suffixes, with valid and retained/rejected controls. Repair .2.6 is owned and gated; exact replay,
public limitation and earlier evidence remain durable. Reading reaches 11/55; next .1.12.

## 2026-09-09 — DART-STARTUP-READING.1.10: MCP runtime and Unicode key order

Read 1,500 fragments / 61,935 unchanged bytes through generated bundle/runtime EOF and server line 1019.
All 11 selected tests pass. Four helper controls and one injected public-dispatch probe confirm
canonical U+E000/U+10000 ordering divergence with equal JSON values. Repair .2.5 is owned and gated;
exact replay, public limitation and prior evidence are durable. Reading reaches 10/55; next .1.11.

## 2026-09-09 — DART-STARTUP-READING.1.9: generated MCP contract reading

Read all 65,536 owned bytes of the first generated bundle window, retaining exact baseline identity.
Four binding tests, neutral 35/10/10/76 validation, generator freshness and embedded-value equality pass.
Dated facts and public outcome distinctions retain prior evidence. Reading reaches 9/55; no new
defect is confirmed. Next .1.10 finishes the bundle and reads its runtime/server.
