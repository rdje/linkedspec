# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`


## 2026-09-23 — SESSION-STARTUP-READING.47.1 - accept empty mutation argument whitespace

Rust compiled mutation validation now accepts parentheses whose interior is whitespace-only, matching already admitted parser syntax. Validate the original projected source without rewriting text, spans, schemas or the frozen shared contract. Extend every frozen valid syntax case through compilation.

Runtime proof passes all 179 library and 12 mutation contract tests, including seven whitespace spellings, exact supplied source/scalar spans, seven nonempty controls, eight corrupted argument projections, serde, generated-plan and independently compiled emitted execution. All six rebuilt-native controls pass. The unchanged neutral checker passes 4/14/5 syntax and 167+592 mutations; public no-drift and mdBook rendering pass. Core compatibility passes 201 library tests, 4 diagnostic groups and 5 rule-code rejection groups.

A separate whole-spec CRLF source assertion exposed outer parser normalization. Split the active parent into validator .47.1, immediate source-capture repair .47.2, and canonical closeout .47.3. The failing evidence remains recorded; caller-supplied source-AST tests isolate compiler/carrier fidelity without weakening the original expected source. Rust integration guidance states the current limitation; other backend contracts and dependency pins remain unchanged.

## 2026-09-23 — SESSION-STARTUP-READING.46 - preserve UTF-8 diagnostic boundaries

Fix Rust unexpected-character diagnostics when their bounded context ends inside a multibyte scalar. Keep the existing 40-byte budget and plain-text byte position while moving the excerpt endpoint to a UTF-8 boundary. Syntax rejection, authored text and structured Unicode-scalar spans are unchanged. Add independent two/three/four-byte alignment coverage for both CodeBlock modes and extend existing public route and CLI rejection fixtures.

Core RED: 3 pass/1 split-scalar panic. GREEN: 201 core library tests, 4 diagnostic groups, 5 rule-code rejection groups, the primary CLI rejection test and 4 source/AST/traced/loader/semantic/generated route tests pass. Five rebuilt-native controls pass in 1.16–1.19 seconds; the former Unicode exit 101 becomes ordinary compile:error/exit 1. ASCII, valid Unicode, diagnostic byte offsets and structured scalar spans retain their behavior. Rust formatting and mdBook rendering pass.

Update the Rust integration guide, Knowledge fact, task ownership and live/roadmap pointers. The earlier long-ASCII timeout is not reproduced by current controls; its historical cause remains unknown. No dependency implementation, pin, generated format or cross-backend contract changes. Ordinary focused verification applies; startup .47 is next.


## 2026-09-23 — SEXPR-DOCUMENT-INTEGRATION.2 - admit complete document integration

Add a maintained verifier for the documented public-loader adaptations and publish its commands in every backend integration guide. The verifier uses the independent authored values, changes only the entry-rule literal in temporary copies, and preserves original examples and prepared products. Close the local ARCHOGEN complete-input/token-kind and SEMULITH kind scope through the separate versioned grammar; historical Lispish and downstream report states remain unchanged.

PASS: all 37 unchanged authored cases through each of six public-loader routes (222 outcomes), with 21 process groups per route covering exact values, typed rejection or the Rust text adapter Display, prior-output retention, relative Unicode grammar paths, invalid UTF-8 and missing grammar. Native Rust file replay passes 37 cases/36 groups; historical Lispish passes 26 values/18 groups. The recurring grammar driver adds token round trips and same-engine post-rejection reuse; exact staged canonical proof is mandatory for this admission and enforced by the landing hook.

Synchronize the grammar chapter, Lispish walkthrough, public status, ADR0124, source-qualified report register, task-tree parents, roadmap and continuity. No runtime, grammar, dependency implementation, pin or authored expected-value change. Strict input-file UTF-8 and packaging are covered by the native Rust file verifier; other public-loader replay uses text arguments. The generic Rust text adapter reports exact Display messages, while its file adapter retains typed JSON causes. Next: startup .46, with the earlier whole-spec timeout kept distinct from the proven core UTF-8 panic.

## 2026-09-23 — SEXPR-DOCUMENT-INTEGRATION.1 - deliver native s-expression file consumer

Add the separate Rust sexpr_file example: exact UTF-8 file input, one compiled Document engine, direct tagged values, typed parse causes with input paths and executable-relative grammar assets. The maintained verifier consumes the independent 37-case contract as real files and checks public examples, error order, paths, prior-output retention and relocation. Historical Lispish stays unchanged. Synchronize the Rust/shared integration guides, grammar chapter, public status, roadmap and continuity; other backend guides retain the same canonical document contract.

PASS: 37 unchanged authored cases as real files (21 accepted in one engine and 16 typed rejections), 36 process-check groups including the published example, Unicode/relative paths, strict UTF-8, malformed grammar before input loading, earlier-output retention, default/explicit assets and relocation with all 21 valid cases. Binary/grammar/contract hashes stay exact and owned fixtures are removed. Historical Lispish passes 26 file values/18 groups and all three adapter tests. Native build, Rust formatting and Python syntax pass; the grammar and authored case array remain unchanged. Book/public guards, Knowledge/memory/history/diff and normal doctrines govern the focused landing; .2 owns independent canonical admission and formal parent closeout.

The missing consumer is confirmed against clean 77d7b3db1; the historical adapter fails the new file verifier as expected. The new executable passes 36 process groups, including all 21 accepted files again after relocation. This ordinary delivery changes only contract delivery-status metadata, not authored values or grammar source. Independent canonical admission and formal startup-parent/report closeout remain SEXPR-DOCUMENT-INTEGRATION.2.

The startup task root stays at 8,000 lines with every stable ID retained. A bounded semantic execution tree owns the remaining work without raising a ceiling or changing partition infrastructure. The due metadata-only artifact census observes 3,389 .log/.bin files (9203965937 bytes), retains reusable/current/ambiguous data, and removes only this session's exact obsolete 68-byte wrapper-usage log; an exact-path residue check passes.

## 2026-09-22 — SESSION-STARTUP-READING.83.2.2 - implement complete s-expression documents

Add specs/SExprDocumentV1.spec: complete parenthesized documents, every top-level form, tagged list/symbol/number/string nodes and exact lexical spelling. Register independent contract consumers in all six native runtime routes and the canonical gate; add the public grammar chapter. Lispish, runtime implementations, dependency pins and expected case values are unchanged.

PASS: all 37 authored cases on six native runtimes (222 case outcomes), 21 token-spelling round trips per route and 16 same-engine post-rejection reuse checks per route. Perl has 44 top-level/168 nested assertions including descriptor readiness and the independent catch-all mutation; Rust one complete contract test, Dart 38 tests, Julia 91 assertions, and both Lua routes pass. Three initial Dart EOF-comment failures become green with a portable grammar branch, without changing authored expectations. Historical Lispish quoted-LF fixtures pass 3/3 on Perl, and the new book command returns its exact documented value. Formatting, Dart analysis, shell syntax, book, Knowledge/memory/history/diff and doctrine checks govern landing. The public grammar/recurring-CI boundary requires the exact staged canonical receipt; native file delivery and final report admission remain separate.

The reviewed new book page advances only the mutation/selector public file counts to70/69. Both gates PASS with unchanged semantic/classification controls (mutation14/11/10/50; selector35/0/5/11).

Canonical preflight rejected the 8,002-line task candidate. Two newly added duplicate evidence fields were removed after confirming their mechanism, proof, ownership and exact census remain in the same task node and linked canonical fact cards. All stable task definitions remain in their original order, with no task or evidence dropped; the task root is 8,000 lines and its original ceiling is unchanged.

A final source-inventory review caught missing catalog rows for the new grammar and the existing function-definition grammar, plus stale fixed counts in current Rust/book/roadmap prose. The public catalog now lists every one of the 22 shipped filenames exactly once; mutable invariant descriptions rely on automatic test discovery, and dated historical counts remain explicit. Canonical CI was stopped before completion to include this documentation correction in the exact candidate.

Complete shipped-inventory proof PASS: Rust auto-discovery parses, validates and compiles all 22 grammars; Perl return_descriptor passes 67 assertions (inventory plus three readiness checks per grammar); the public catalog lists the same 22 filenames exactly once. Current invariant prose no longer embeds a stale fixed count, and the 70/69 public guards retain every semantic mutation check.

All five backend integration guides and the shared integration landing page now describe the document grammar, native values, typed rejection and exact focused check commands. They identify the required Top-to-Document selection in the Perl/Dart/Julia/Lua word adapters and preserve historical Rust lispish_file limits. The document chapter links back to every backend guide; schema and lexical rules keep one canonical owner. The Rust integration guide command builds and returns the exact documented two-form tagged value through the public loader and generic native consumer. Direct consumer boundary checks also pass empty documents, ordered two-form input and interstitial-junk rejection with empty stdout.

## 2026-09-22 — SESSION-STARTUP-READING.45.3 - close Rust rule-code rejection repair

Close the bounded Rust rule-code error-propagation repair after compiler and carrier verification. Align roadmap, public status, Knowledge and task pointers; select the versioned document grammar as the next leaf. No production source, generated schema, dependency pin or historical Lispish behavior changes.

Compiler correction 10893fb71 passed all core/native regressions and the complete Rust component gate; carrier checkpoint 30c1ddeea passed all four source/AST/loader/semantic/generated route tests. This documentation-only parent closeout retains those exact proofs. Canonical acceptance requires tools/run_ci_local.sh to finish successfully on the exact staged candidate and produce the receipt checked by the normal commit hook; the resulting commit and promoted receipt are the durable gate evidence. Other parser defects and document grammar delivery remain separately owned.

## 2026-09-22 — SESSION-STARTUP-READING.45.2 - verify Rust rule-code rejection routes

Add bounded public-route regressions for the compiler correction: reconstructed source AST, traced compilation, path/name loading, semantic failure and actual generated-module execution. Document why artifacts produced by an older compiler must be regenerated from authored source.

Four focused route tests PASS: eight malformed sources yield 32 ordinary/traced source/reconstructed-AST rejections, 16 path/name-loader rejections and eight failed semantic snapshots with no compiled authority or plan. Valid path/name loads, reconstructed compiled state and generated-plan execution return 42; a freshly compiled emitted module verifies direct/traced 42 and compatibility [42]. Production code is unchanged from 10893fb71; its complete Rust compatibility proof remains applicable. Rust formatting, book, Knowledge/memory/history/public/diff checks and normal doctrines govern landing.

## 2026-09-22 — SESSION-STARTUP-READING.45.1 - reject malformed Rust rule code

Make every reported Rust rule-code parse error a compilation failure with its rule/block context. Remove the warning-and-drop fallback and retain optional absent edge code. Add persistent lifecycle/edge/guard/write/mutation and primary phase-boundary regressions; normalize one pre-existing trace-test formatting issue and align diagnostic guidance.

PASS: 12 native invalid cases change from warning/compile:ok/invoke:ok to exit 1/compile:error with no input or invocation phase; three valid controls retain 42 and empty stderr. Four persistent core rejection groups are RED before repair; all five groups GREEN afterward (15 malformed contexts and 11 retained valid blocks). Complete Rust component gate PASS: 228 core and 574 runtime tests, including all 197 end-to-end tests, 21 shipped grammars and 105 oracle cases; primary CLI conformance is 66/66 in each default/POSIX environment, and managed-storage checks pass. The committed quoted-LF manifest passes all three cases on the rebuilt primary binary. Callable contract, book, Knowledge/memory/history/public/diff and registered doctrine checks govern focused landing. Separate carrier proof/canonical closeout and parser-cause repairs remain open.

## 2026-09-22 — SESSION-STARTUP-READING.83.1 - define kind-preserving document grammar

Accept ADR0124: a separate versioned s-expression document with all forms, tagged exact lexemes and rejection of unrecognized input. Author 37 acceptance cases, retain historical Lispish, and decompose grammar/native-consumer delivery. A native prototype re-exposes existing Rust warning/drop defect .45; its three bounded repair children now precede delivery. No production grammar, runtime, dependency or admission changes.

Validation: 37 independent cases (21 accept/16 reject), 136 Perl assertions and the exact durable proof, four native Rust prototype controls with complete output/status capture, and precise compiler source attribution. Knowledge/memory/history/book/public/diff and normal doctrine hooks govern this focused design checkpoint; no canonical run or push.

## 2026-09-22 — SESSION-STARTUP-READING.83.2.1 - preserve multiline Lispish quoted strings

Enable DOTALL in both Lispish quote patterns so actual LF remains data and cannot corrupt following forms. Add shared CLI/Phase0 regressions, retain all eight SEMULITH/LS-001 inputs/expectations in the Rust file verifier, synchronize the shipped corpus copy and update exact book examples/status. Historical extraction, escapes, adjacency and atom-kind behavior remain. LS-002 contract work is next.

Validation: three final fixtures RED on clean-HEAD source; Phase0 smoke 9 and six-runtime/two-environment 36 legs GREEN; Rust 26 file values/18 groups, descriptor 9/9, corpus identity/value, book/public/syntax/memory/history/Knowledge checks and normal doctrine hooks. Focused correction; no canonical run or push.

## 2026-09-22 — SESSION-STARTUP-READING.85 - recover SEMULITH reports and repair ownership

Recover the three SEMULITH reports from integration .8.1 and correct the false missing-identities blocker across task, roadmap, memory, Knowledge and book pointers. LS-001 has four fresh native LF failures and four matching controls, with full stdout/stderr/status captured; the 29-file snapshot hash matches intake. Add bounded .83.2.1 ownership for the compatible LF repair; retain .83.1 kind/strict design and verified LS-003 integration remedies. Source and dependency pins are unchanged.

Validation: exact snapshot hash and report/owner reconciliation, native eight-case reproduction, Knowledge/memory/history checks, book rendering, direct public-document checks and normal doctrine hooks. No canonical run or push for this continuity correction.

## 2026-09-22 — SESSION-STARTUP-READING.84 - adopt targeted startup and fast ramp-up

The director replaces the blanket full-codebase prerequisite with targeted startup: recover context/Git/frontier in2–5 minutes, then read affected requirements/code/contracts/tests/book before a fix. ADR0123 and SESSION_BOOTSTRAP own the direction. Prior audit ranges and defects remain unchanged; .85 awaits the three requested report identities. No runtime, gate or capacity changes.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.89 - read trace dispatch and typed source consumers

13 complete windows cover 1,500 fragments / 53,547 baseline bytes; ordered window SHA-256 53b9f5f72e1d3121a1e20402b1d5850520a916bc37f5d832fd5de6182bf09465. Cumulative reading is 89/143 groups, 109,904 fragments / 4,784,266 baseline bytes and 133 complete files. Seven trace/typed-projection consumers are complete; typed immutable values are read through 226, inside reversed-span diagnostic verification. The remaining value tests stay .1.90-owned. Seven complete consumers pass 27 top-level/402 nested TAP results: CLI3/17, EmitContext4/29, branch3/16, nonrep4/35, rep4/54, RuleIR5/39 and typed projections4/212. Typed neutral governance passes14 complete/0 pending/231 mutations. Twelve EmitContext process controls reproduce both known defects and reap both timeout children. Four source-observation controls prove original6/6 assertions miss Top-only instrumentation removal; the bounded twin passes pristine and fails only assertion4 after removal. Existing .2.16 repairs now own eleven process helpers. New .2.19 owns the cross-handler source assertion; production instrumentation passes the stronger control. Corrected stale EmitContext fallback wording to current rejection. Startup .24 and all prior repair/source/book/policy prerequisites remain. No production change, full immutable-value execution, fresh-process generated proof, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.88 - read staged lifecycle and trace consumers

13 complete windows cover 1,500 fragments / 57,180 baseline bytes; ordered window SHA-256 ea8f3aa4f0e21715211a51c8b780c954485ebf408a59ae1363542c1964dfd79d. Cumulative reading is 88/143 groups, 108,404 fragments / 4,730,719 baseline bytes and 126 complete files. Staged enrichment, both standalone lifecycle consumers and three ActionIR trace consumers are complete; trace CLI is partial through line 47, including its complete process helper. Six complete consumers pass 188 top-level/688 nested TAP results: staged 143/322, lifecycle 7/274, self-hosted 25/0, compact trace 4/24, method trace 4/39 and pipeline trace 5/29. Staged governance passes 9 rollout legs/123 base and public 6/17/10/129 mutations. Lifecycle governance passes 9 placements/4 duplicates/6 owners/3 malformed twins/6 runtime rows/14 mutations. Forty-eight source-pinned trace-process controls reproduce status/pipe defects and reap all eight timed-out owned children. Existing .2.16.1/.2.16.2 now own ten process helpers, retaining their callers and prerequisites. Startup .44/.73 and all prior repairs remain open. No unread CLI test execution, historical false-green run, fresh-process generated proof, production repair, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.87 - read staged enrichment declaration and scheduling consumers

Nine complete windows cover 1,500 fragments / 54,923 baseline bytes; ordered window SHA-256 23a24a42efdacf352b641c0c3001b01cd77ef6a99d7c91b37546e8afd9fbfced. Cumulative reading is 87/143 groups, 106,904 fragments / 4,673,539 baseline bytes and 120 complete files. Staged enrichment is read through line 1504, inside payload identity; complete executable prefix ends at 1461. The suffix and carrier/admission reading remain .1.88-owned. The exact complete prefix through 1461 passes 135 top-level/227 nested TAP results. Staged governance passes 9 rollout legs/123 base mutations and public 6/17/10/129; typed source passes 14/0/231; recognition passes 138 ActionIR rows/250 calls/58 mutations and 9/9 rollout. Existing startup .44 identity-lifetime and .73 competing-target repairs remain open, along with all prior defects and required source/book/policy prerequisites. No suffix execution, new runtime defect, repair closure, production change, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.86 - read semantic index and sparse slot consumers

13 complete windows cover 1,500 fragments / 61,968 baseline bytes; ordered window SHA-256 4809bc148e5052220956c468ea5fdfdf17cf5a8cfce23351b708e8bcfc36009c. Cumulative reading is 86/143 groups, 105,404 fragments / 4,618,616 baseline bytes and 120 complete files. Semantic foundation, query, runtime/static projection, composed admission and sparse action slots are complete; staged enrichment is read only through its four-line header. Six complete consumers pass 146 top-level/634 nested TAP results; the direct-dependent duplicate-slot suite adds 12/62, totaling 158/696. Semantic governance passes 6 fixture groups/20 exact queries/128 mutations with rollout 9/0 and admission 6/0. Duplicate-slot governance passes 5 fixtures/2 diagnostics/6 runtime rows/59 mutations with rollout 7/0. Known runtime and observation repairs remain open with required source/book/policy prerequisites. No new defect or repair closure, fresh-process generated proof, production change, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.85 - read cursor scalar and semantic call consumers

13 complete windows cover 1,500 fragments / 52,593 baseline bytes; ordered window SHA-256 c34998ba12ac92b0810836ed81caf87c6dfe93027fe5e9bd33799563de736449. Cumulative reading is 85/143 groups, 103,904 fragments / 4,556,648 baseline bytes and 114 complete files. Root selection routes, all three rule-local cursor consumers, scalar numeric/text and semantic call projection are complete; semantic foundation is partial through line 65. Fresh focused proof passes 431 top-level and 213 nested TAP results across seven complete files. Cursor governance passes 36 family spellings / 18 edge cases / 8 parent-child cases / 14 Perl roles / 60 mutations; numeric passes 55 cases / 18 helpers; semantic passes 6 fixture groups / 20 queries / 128 mutations with rollout 9/0 and admission 6/0. Twelve controls reproduce the byte-identical sixth subprocess helper defects and reap both timeout children. Twenty-four source-capture controls reproduce both negative-only cursor observations. Four semantic copy controls pass original 6-assertion tests with shared nested shape, while the 7-assertion guard rejects exactly that mutation. Existing .2.13 owns both cursor-source observations; .2.16 owns the sixth subprocess helper; new .2.18 owns semantic nested-copy test sensitivity. Production copies pass the stronger scratch control. All repair and source/book/policy prerequisites remain; no production change, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.84 - read recognition observation repetition and root selection consumers

10 complete windows cover 1,500 fragments / 54,362 baseline bytes; ordered window SHA-256 3ca32d29209411869425074b019fa6a21ae019e62e79dc5e15e603573aca37c1. Cumulative reading is 84/143 groups, 102,404 fragments / 4,504,055 baseline bytes and 107 complete files. Recognition, recursive observation, repeated action results and root selection core are complete; root selection routes are partial through line 359. Fresh focused proof passes 79 top-level and 475 nested TAP results: recognition 51/99, recursive observation 7/78, repeated action results 10/122, root selection core 7/78 and the complete root routes prefix through line 324 at 4/98. Neutral recognition 138/250/58, typed 14/0/231, repetition 8/0/54 and root 7/0/54 pass. Twelve source-extracted repeated-action process controls confirm signal-status loss and sequential-pipe blocking; both timed-out owned children are reaped. Existing .2.16.1/.2.16.2 now also own the repeated-action CLI helper; all previous repairs and required source/book/policy prerequisites remain. No production repair, fresh-process generated proof, dependency build, canonical run or push is claimed.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.83 - read progressive punctuation and recognition observation boundaries

Read the .1.83 four-file scope: 83/143 groups, 100,904 fragments / 4,449,693 baseline bytes and 103 complete files. Focused proof: Fresh focused proof passes 195 top-level and 424 nested TAP results: progressive contract129/0, punctuation7/73, recognition authority8/285 and the complete read recognition prefix through535 at51/76; four source-extracted compatibility scope controls also pass. Three files finish. .2.15 retains the full progressive carrier observation limit; new .2.17 owns disconnected recognition compatibility observations. New .2.17 ownership and the .2.15 carrier audit are recorded; all repairs retain prerequisites; .1.84 continues.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.82 - complete Phase0 and own subprocess and parent observation gaps

Read the .1.82 four-file scope: 82/143 groups, 99,404 fragments / 4,399,178 baseline bytes and 100 complete files. Focused proof: Fresh focused proof passes 94 top-level assertions and 571 nested assertions across validation fuzz, private progressive authority and the exact read contract prefix; source-extracted parent controls add eight scope checks, and 48 process controls confirm status/pipe behavior with eight timeout children reaped. Three files finish. New .2.15 owns disconnected parent observations; .2.16 owns signal-status loss and sequential-pipe blocking. Prior .1.81 count wording is corrected. New .2.15/.2.16 owners and the .1.81 count correction are recorded; all repairs retain prerequisites; .1.83 continues.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.81 - finish Phase0 subtests and bound remaining observation repairs

Read Phase0 47308–48409: 81/143 groups, 97,904 fragments / 4,347,276 baseline bytes and 97 complete files. Retained proof covers 14 completed subtests, ordinals 1019–1032 with 236 direct assertions and no nested plans. All Phase0 subtests are read; helpers remain. .2.14 has three bounded repair children, and startup .17.2 owns reproduced absent-hash host-slot leakage. The bounded .2.14 inventory is extended; all repairs retain prerequisites; .1.82 continues.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.80 - read shape and receiver checks and own absent host-slot leakage

Read Phase0 46192–47307: 80/143 groups, 96,802 fragments / 4,281,755 baseline bytes and 97 complete files. Retained proof covers 17 completed subtests, ordinals 1002–1018 with 244 direct assertions and no nested plans. Shape/receiver and numeric comparison checks retain exact results; startup .17.1 now owns reproduced absent-receiver host-slot leakage and .2.14 owns remaining obsolete target descriptions. The bounded .2.14 inventory is extended; all repairs retain prerequisites; .1.81 continues.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.79 - read binding and newline checks and extend observation repair

Read Phase0 45064–46191: 79/143 groups, 95,686 fragments / 4,216,269 baseline bytes and 97 complete files. Retained proof covers 19 completed subtests, ordinals 983–1001 with 246 direct assertions and no nested plans. Binding and newline tests preserve concrete runtime and lowering claims; .2.14 now owns the adjacent collapsed comparisons and stale descriptions. The bounded .2.14 inventory is extended; all repairs retain prerequisites; .1.80 continues.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.78 - read function staging and own working variable observation drift

Read Phase0 43917–45063: 78/143 groups, 94,558 fragments / 4,150,753 baseline bytes and 97 complete files. Retained proof covers 22 completed subtests, ordinals 961–982 with 392 direct assertions and no nested plans. Function staging, runtime values and recursion checks retain bounded claims; new .2.14 owns working-variable observation and description drift. Fresh diagnosis is owned by .2.14; all repairs retain prerequisites; .1.79 continues.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.77 - read trace and cursor tests and own missing source observation

Read Phase0 42888–43916: 77/143 groups, 93,411 fragments / 4,085,281 baseline bytes and 97 complete files. Retained proof covers 35 completed subtests, ordinals 926–960 with 479 direct assertions and no nested plans. Trace and runtime cursor observations remain distinct from descriptor equality; new .2.13 owns the reproduced negative-only source check. Fresh diagnosis is owned by .2.13; all repairs retain prerequisites; .1.78 continues.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.76 - read shipped grammar runtime smokes and adapter boundaries

Read Phase0 42088–42887: 76/143 groups, 92,382 fragments / 4,019,804 baseline bytes and 97 complete files. Retained proof covers 33 completed subtests, ordinals 893–925 with 650 direct assertions and no nested plans. Grammar metadata and source checks remain distinct from bounded parser results and legacy Perl adapter execution. Existing repairs remain; no new defect or fresh execution; .1.77 continues.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.75 - read quote boundaries and shipped grammar migration checks

Read Phase0 41196–42087: 75/143 groups, 91,582 fragments / 3,954,348 baseline bytes. Retained thirty-six-subtest proof has 470 assertions for quote-aware statement boundaries and shipped grammar migration checks. Descriptor/source observations remain distinct from the exact regdef parser result. Existing repairs remain; no new defect or fresh execution; .1.76 completes the VHDL concurrent-assignment source test.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.74 - read source boundary projections and legacy classification checks

Read Phase0 40443–41195: 74/143 groups, 90,690 fragments / 3,888,884 baseline bytes. Retained twenty-nine-subtest proof has 323 assertions for typed source-boundary projections and legacy classification. Runtime-call substrings and metadata do not independently execute endpoint arithmetic or boundary advancement. Existing repairs remain; no new defect or fresh execution; .1.75 continues split/trim/filter metadata.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.73 - read switch safety and compatibility migration observations

Read Phase0 39355–40442: 73/143 groups, 89,937 fragments / 3,823,480 baseline bytes. Retained twenty-eight-subtest proof has 291 direct plan entries including 5 nested results, with 40 inner assertions. Switch/while runtime controls, semicolonless metadata, raw/unresolved blockers and compatibility migration summaries remain distinct observations. Existing .2.10 and other repairs remain; no new defect or fresh execution; .1.74 continues prefix-newline metadata.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.72 - read reducers and meaningful lifecycle source and result locks

Read Phase0 38504–39354: 72/143 groups, 88,849 fragments / 3,758,044 baseline bytes. Retained seventeen-subtest proof has 235 direct assertions across reducers, flat lists, typed transforms and conditionals/lifecycle. Nine runtime results and seven positive marker source checks are meaningful bounded observations; existing .2.10 and startup .27 gaps remain. No new defect, fresh execution or repair closure; .1.73 continues the switch test.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.71 - read array ordering and own assignment description drift

Read Phase0 37745–38503:71/143 groups,87,998 fragments /3,692,510 baseline bytes. Retained twenty-one-subtest proof has 196 assertions; four fresh exact subtests pass 16 assertions and four public assignment executions return expected arrays. Own the four stale list-context-flattening descriptions under .2.12 with durable reproduction; no test/runtime repair closes. .1.72 continues lifecycle num_avg.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.70 - read hash transformations and snapshot lowering checks

Read Phase0 36948–37744: 70/143 groups, 87,239 fragments / 3,627,006 baseline bytes. Retained twenty-one-subtest proof has 196 assertions: 168 descriptor and 28 direct-lowering checks. Hash lookup, merge, snapshot and key-transform expressions remain distinct from executed isolation/mutation behavior and .2.10-owned code-slot comparisons. No repair closes; .1.71 continues lifecycle pick_keys.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.69 - read scalar membership and reducer lowering checks

Read Phase0 36291–36947: 69/143 groups, 86,442 fragments / 3,561,482 baseline bytes. Retained nineteen-subtest proof has 150 assertions: 108 descriptor and 42 direct-lowering checks. Scalar membership, replacement, boundary, concatenation, index and reducer expectations remain distinct from target execution and .2.10-owned code-slot comparisons. No repair closes; .1.70 continues lifecycle count_keys.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.68 - read fallback lowering and normalization metadata

Read Phase0 35430–36290: 68/143 groups, 85,785 fragments / 3,496,045 baseline bytes. Retained twenty-two-subtest proof has 221 assertions: 204 descriptor and seventeen direct-lowering checks. Fallback, definedness, emptiness and normalization textual observations remain distinct from .2.10-owned code-slot comparisons and target execution. No repair closes; .1.69 continues the partial scalar-normalization test.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.67 - read payload branches and captured-call descriptor comparisons

Read Phase0 34546–35429: 67/143 groups, 84,924 fragments / 3,430,534 baseline bytes. Retained twenty-subtest proof has 240 direct assertions and no nested plans. Payload branches and captured calls inspect descriptor metadata; uppercase-slot observations remain .2.10-owned. No new runtime execution or repair; .1.68 continues the action switch call-value comparison.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.66 - read scalar and numeric descriptor comparisons

Read Phase0 33716–34545: 66/143 groups, 84,040 fragments / 3,365,034 baseline bytes. Retained twenty-subtest proof has 240 direct assertions and no nested plans. Scalar and numeric helper pairs inspect descriptor metadata; uppercase-slot observations remain .2.10-owned. No new runtime execution or repair; .1.67 continues the lifecycle min/max comparison.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.65 - read fluent container helper comparisons and observation limits

Read Phase0 32759–33715: 65/143 groups, 83,210 fragments / 3,299,611 baseline bytes. Retained nineteen-subtest proof has 222 direct assertions, including seven nested results / 63 inner assertions. Fluent snapshot branches and container helper pairs inspect descriptor metadata; uppercase-slot observations remain .2.10-owned. No new runtime execution or repair; .1.66 continues the lifecycle slice-array comparison.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.64 - read mutual marker nesting and bounded helper coverage

Read Phase0 31259–32758: 64/143 groups, 82,253 fragments / 3,234,113 baseline bytes. Retained eleven-subtest proof has 95 direct assertions, including 42 nested results / 329 inner assertions. Same-family node/hit comparisons and deep mutual marker helper thresholds retain exact metadata limits; code-output-labelled slot comparisons remain .2.10-owned. No new runtime execution or repair; .1.65 continues the partial action fixture.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.63 - read outer-family selected-node checks and comparison limits

Read Phase0 29759–31258: 63/143 groups, 80,753 fragments / 3,179,902 baseline bytes. Retained ten-subtest proof has 90 direct assertions, including 35 nested results / 252 inner assertions. Selected marker-node checks are distinct from complete node-list or hit-map equality; code-output-labelled slot comparisons remain .2.10-owned. No new runtime execution or repair; .1.64 continues the partial lifecycle fixture.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.62 - read switch outer-family comparisons and exact metadata limits

Read Phase0 28259–29758: 62/143 groups, 79,253 fragments / 3,127,736 baseline bytes. Retained eleven-subtest proof has 111 direct assertions, including 35 nested results / 308 inner assertions. Same-family node/hit comparisons and cross-family node-only comparisons retain exact metadata limits; code-output-labelled slot comparisons remain .2.10-owned. No new runtime execution or repair; .1.63 continues the partial lifecycle case list.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.61 - read structured switch branch comparisons and preserve observation limits

Read Phase0 26759–28258: 61/143 groups, 77,753 fragments / 3,067,280 baseline bytes. Retained eleven-subtest proof has 107 direct assertions, including 42 nested results / 364 inner assertions. Structured switch branch comparisons retain metadata proof; code-output-labelled slot comparisons remain .2.10-owned. No independently reproduced new defect or target execution; all repairs remain. .1.62 continues the partial action pair.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.60 - read multi-case switch composition and metadata coverage

Read Phase0 25259–26758: 60/143 groups, 76,253 fragments / 3,006,852 baseline bytes. Retained twelve-subtest proof has 108 direct assertions, including 42 nested results / 336 inner assertions. Multi-case switch compositions inspect metadata and current slot shape, without code or execution equivalence claims. No new defect or target execution; all repairs remain. .1.61 continues the partial lifecycle fixture.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.59 - read deep switch nesting and descriptor slot shape

Read Phase0 23759–25258: 59/143 groups, 74,753 fragments / 2,951,000 baseline bytes. Retained nine-subtest proof has 93 direct assertions, including 28 nested results / 252 inner assertions. Deep inline/marker and multi-case switch fixtures compare metadata and current slot shape, without code or execution equivalence claims. No new defect or target execution; all repairs remain. .1.60 continues the partial lifecycle fixture.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.58 - read mixed switch and nested marker metadata

Read Phase0 22259–23758: 58/143 groups, 73,253 fragments / 2,895,669 baseline bytes. Retained 18-subtest proof has 160 direct assertions, including 63 nested results / 476 inner assertions. Mixed attached/plain switches and nested marker flow preserve the distinction between explicit slot shape and unsupported code-equivalence claims. No new defect or target execution; all repairs remain. .1.59 continues the next partial fixture.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.57 - read snapshot and bare-marker descriptor coverage

Read Phase0 21058–22258: 57/143 groups, 71,753 fragments / 2,833,045 baseline bytes. Retained 18-subtest proof has 195 direct assertions, including 59 nested results / 472 inner assertions. Snapshot helpers, optional semicolons, bare markers and attached switch metadata retain the .2.10 code-slot observation limit. No new defect or target execution; all repairs remain. .1.58 owns the final fluent outer-switch assertion.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.56 - read switch coverage and own vacuous code comparisons

Read Phase0 19558–21057: 56/143 groups, 70,552 fragments / 2,767,515 baseline bytes. Retained 18-subtest proof has 148 direct assertions, including 74 nested results / 557 inner assertions. Fresh controls expose absent-code-slot comparisons and invalid scalar capture recipes; .2.10/.2.11 own repairs. Current generated-code equivalence wording is corrected; historical reads and passes remain. .1.57 completes the LX flat-list test.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.55 - read mixed branches and nested switch equivalence

Read Phase0 18058–19557:55/143 groups,69,052 fragments/2,703,226 baseline bytes. Retained proof covers16 completed subtests/151 direct assertions, including56 nested results whose inner plans separately pass448 assertions. No new defect or target runtime execution; all repairs remain. Exact windows and comprehension are task/card-owned; .1.56 continues the next lifecycle cases list.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.54 - read structured branch and lifecycle equivalence coverage

Read Phase0 16880–18057:54/143 groups,67,552 fragments/2,639,708 baseline bytes. Retained proof covers20 completed subtests/227 direct assertions, including12 nested results whose inner plans separately pass96 assertions. No new defect or runtime execution; all repairs remain. Exact windows and comprehension are task/card-owned; .1.55 continues the seven-tag lifecycle test.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.53 - read collection and branch lowering contracts

Read Phase0 16062–16879:53/143 groups,66,374 fragments/2,574,186 baseline bytes. Retained proof covers13 completed subtests/224 assertions. Fresh lowering confirms two push descriptions still claim wrapped targets despite bare inputs; .2.9 owns correction. Exact windows, comprehension and recipe are task/card-owned. .1.54 continues the partial lifecycle switch/case test; all prior repairs remain.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.52 - read entry and match helpers and diagnose invalid numeric fixture

Read Phase0 14985–16061:52/143 groups,65,556 fragments/2,508,708 baseline bytes. Retained proof covers27 completed subtests/129 assertions. Exact num_min lowering matches a malformed positive expectation but fails compilation; the balanced twin returns2. .2.8 owns fixture correction and executable proof. Comprehension, exact windows and diagnosis are task/card-owned; .1.53 continues the partial method-contract test. Earlier repairs remain.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.51 - read capture boundaries and diagnose mark-copy clearing test gap

Read Phase0 13632–14984:51/143 groups,64,479 fragments/2,443,528 baseline bytes. Retained ec10be6b proof covers40 completed subtests/266 assertions. Four fresh controls confirm the mark_copy clearing observation gap; .2.7 owns repair. Production clears a seeded-zero target. Exact windows, comprehension and reproduction are task/card-owned; .1.52 continues the partial capture-column test. All earlier repairs and prerequisites remain.

## 2026-09-21 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15 - admit approved conformance evidence capacity

Admit exactly fourteen approved remaining-conformance evidence controls under ADR0122 and containment .15. Preserve both governed history rollovers and prior evidence; forecast the remaining 98 allowance units after actual admission overhead. Reading remains 50/143; MethodExpr .2.5 and EmitContext .2.6 remain open. Exact production/preservation proof and ordinary staged canonical CI govern landing; .1.51 resumes after clean commit. The director separately granted exact .15.1 checker-mirror correction after canonical failure;37 self-tests/50 registry cases and actual partition validation pass. Fresh canonical proof remains required.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.4.1

Propose fourteen finite evidence-capacity controls for remaining reading; exact objects/models in task .4.1. No limits change. Explicit .4.2 approval and canonical admission precede .1.51.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.50 - read ActionIR lazy-loading and capture lowering tests

Read Phase0 12850–13631: 50/143 groups, 63,126 fragments / 2,378,009 baseline bytes. Retained proof covers 13 complete subtests / 118 assertions. Fresh six-test / 42-assertion probes confirm six misleading EmitContext load descriptions, owned by .2.6. The 90-assertion lowering test remains partial after assertion73; .1.51 continues. Exact windows, reproduction and comprehension are in the task-tree and conformance-perl-consumer-reading; all repair prerequisites remain.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.49 - read compiler owner paths and diagnose lazy-load test blind spot

Eleven complete windows cover 994 fragments / 65,520 baseline bytes; ordered window SHA-256 d73aae559d4b4280080e5d3df87d2300a07cc2f30f85439045cde24f95689a60. Cumulative reading is 49/143: 62,344 fragments / 2,312,539 baseline bytes and 97 complete files. Phase0 is partial through line 12849. Unchanged canonical commit 87b35665e retains PASS for 29 completed subtests, ordinals 365–393 with 202 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh TOOLBOX6.2 extraction passes the MethodExpr test with all7 assertions both unchanged and with an inert post-parse Deps fixture load; independent cold probes observe 0/0 versus 0/1. Repair .2.5 owns the wrong-time observation. The Diagnostics lazy-load heredoc remains partial before its assertions; .1.50 owns the suffix. Targeted helper inspection at48608–48631 grants no reading credit outside this scope. Historical whole-gate proof remains 1032 top-level tests; no new full gate, runtime repair, dependency build or push is claimed.

