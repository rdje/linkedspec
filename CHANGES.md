# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`


## 2026-09-23 — CONSUMER-REPORT-DELIVERY.3 - admit and publish consumer remedies

Close the local consumer-delivery batch through exact staged canonical acceptance and immediate clean publication. Focused commits01b04138a and12c6ca9ad verify current native remedies and the remaining public RGX report. The book publishes tested source baselinef60a70df3, rebuild/package instructions, explicit Document/sexpr_file migration and the unresolved upstream report.

The canonical receipt and commit body must record successful full local CI before this leaf lands; post-commit promotion and remote read-back complete the publication boundary. Git is the source of truth for remote availability. Seven original requirements have local remedies; ARCHOGEN/LS-004 remains upstream-owned with posting authorization outstanding, LS-006 is withdrawn and LS-007 requires no change. No downstream acceptance or upstream fix is claimed. Resume from MEMORY.md and RGX-CONSUMER-BUILD-REPORTS.1; the separate validator backlog is preserved.

## 2026-09-23 — CONSUMER-REPORT-DELIVERY.2 - reverify the public RGX report

Reproduce ARCHOGEN/LS-004 through the published RGX bootstrap command at the unchanged pin. A fresh empty local Cargo store in offline mode yields exit2, a missing-package error and the misleading seed-success line. Prepared reuse and its repeat exit0 with an explicit already-generated no-op message. Correct the diagnostic probe's unsupported fresh-completion-banner assumption; no dependency implementation is inspected or changed.

Refresh the concrete upstream report with macOS27.0 environment and exact log hashes, preserve RGX repair ownership, and document no-op interpretation in the book. External posting authorization remains pending; no upstream fix is claimed. Focused public-command, book, memory/Knowledge/history/diff and doctrine proof governs landing. Canonical publication of LinkedSpec remedies follows under .3.

## 2026-09-23 — CONSUMER-REPORT-DELIVERY.1 - verify consumer remedies and migration

Reconcile all ten source-qualified SEMULITH/ARCHOGEN reports against their task, Knowledge and ADR authorities. Seven requirements have local remedies; ARCHOGEN/LS-004 remains upstream-owned, LS-006 is withdrawn and LS-007 requires no change. Both supplied report snapshots remain byte-exact. Live remote main87b35665e predates the quote/document repairs, so local completion did not establish delivery. The new three-slice task owns fresh proof, the public RGX report and canonical publication in that order.

Current-source native build passes. Historical Lispish passes26 file values/18 groups; the document consumer passes37 authored cases/36 groups and the Rust public-loader path passes37/21. Nine workspace controls and the rendered book pass. The book gives an exact tested source pin, rebuild/package steps and explicit Document/sexpr_file adoption; updating the historical adapter alone cannot supply the distinct ADR0124 contract. All three adapter tests pass. Focused memory/Knowledge/history/doctrine/diff checks govern landing; no new production change, downstream acceptance, upstream fix or publication is claimed.

## 2026-09-23 — SESSION-STARTUP-READING.86.4.2.4 - distinguish regex operands from runtime types

Audit the documented four binding kinds, helper signatures, syntax nodes and five first-party evaluator representations. Regex pattern operands are supported, but standalone assignment has no portable regex-object contract: Perl emits an implicit match; Rust/Dart produce a pattern string, while Julia/Lua use private helper carriers. Withdraw the earlier precedence question and assignment-only splitter expansion. Correct the book without admitting a new type or changing production.

Thirteen Perl action controls plus an AST probe retain positive helper behavior, scalar assignment effects and typed errors. A documented multiline matches operand independently executes to1 but public validation rejects the next rule: .86.4.3 remains the concrete repair. Direct filter_match and callable matches gaps have explicit .87.1/.87.2 owners. Focused AST/binding/callable45 pass, four native Rust controls pass and the book renders; normal memory/Knowledge/history/doctrine checks apply. The engineering recommendation is no new regex type without an unmet use case. Required bounded-history rollover preserves168 clean-base lines /27426 bytes in segment4971 with exact prior records retained. No full-CI or push claim.

## 2026-09-23 — SESSION-STARTUP-READING.86.4.2.1 - expose slash precedence conflict before repair

Resume the splitter investigation and reject both token-only and lexical-continuation approaches. The latter passes27 action AST groups but regresses seven additional accepted quote/comment controls. Two complete public grammars compile without last_error under both interpretations yet change from7 to empty string. An ordinary comment provides the same counterexample without raw Perl arithmetic. Decision .86.4.2.2 now owns precedence authority; implementation .86.4.2.3 follows it.

Archive the second unaccepted four-file candidate and a standalone diagnostic; verify exact reconstruction and restore accepted production/tests. Restored AST23/23 passes. Update the Knowledge card, public Perl guidance, roadmap/task and bounded continuity. Focused governance/book proof applies; no runtime repair, Phase0/full-CI result or push is claimed. All supplied-policy hashes remain unchanged.

## 2026-09-23 — SESSION-STARTUP-READING.86.4.5 - preserve paused splitter repair and clean handoff

At director request, suspend PNT and save the unfinished .86.4.2 source/test candidate as a tracked patch. Verify byte-for-byte reconstruction of all four files, then restore those files to accepted diagnosis base 69689bb41. The candidate still regresses division followed by Perl quote operators or a slash literal; it is not a delivered fix. The existing integration-book limitations remain accurate.

The Knowledge card preserves the base, patch checksum, reproduction and recovery commands. Both interrupted Phase0 runs are excluded from acceptance. Focused handoff proof covers archive reconstruction, restored source identity/action AST tests, memory, Knowledge, histories, diff and normal commit doctrines. No public behavior change, full-CI claim or push; the next action is to await director direction.

## 2026-09-23 — SESSION-STARTUP-READING.86.4.1 - isolate Perl multiline regex scanner failures

Separate Perl multiline-regex action segmentation from whole-spec validation under .86.4.2/.3, followed by public recomposition .86.4.4. Public Get/runtime context and lowering reproduce the existing failures. Whole-fragment versus physical-line scanning has opposite outcomes for regex and division controls, so a naive whole-source scanner replacement is excluded. No production behavior changes.

Focused proof: public Get and action lowering; source-preserving StatementSplit/AST and Validation owner probes; memory, Knowledge, histories, book and normal doctrines. Canonical acceptance remains .86.3.

## 2026-09-23 — SESSION-STARTUP-READING.86.2 - preserve division newline and regex interpretations

Accept newline-separated Rust slash division while retaining existing successful regex parses. The parser first tries the established interpretation, then retries an ambiguous slash as division only when that block continuation fails. Statement retries use an explicit stack and memoized failed suffixes. EOF/punctuation rules and the closing-brace exclusion remain intact.

PASS: 254 core tests and 404 selected runtime tests. Seven division core groups cover 24 call/separator combinations in both parser modes, exact retained regex patterns, late-statement retries, Unicode write spans, nested controls/callable candidates, and 1500-statement valid/invalid chains. Runtime coverage includes 12 division/separator combinations, nine mixed/nested cases, exact Unicode writes and the ambiguous regex through source-AST/compiled serde and generated plans. All 15 mutation tests pass, including independently compiled emitted division execution. Native 56 passes: 53 exact integer values and 3 malformed rejections; both book examples pass. Binary SHA-256: bbf40b8165ce72764668b7a02e16c84ddabfcf4b1097d690f5b99956ab38e05d.

Core RED reproduced five failures with one compatibility group passing. The first GREEN build exposed a missed secondary parser initializer; it was corrected before the successful rerun. Captured Perl runtime contexts separate documented handler errors from outer validation failures. Immediate .86.4 owns multiline regex validation/lowering and .86.5 owns bare slash EOF before parent canonical .86.3. The invalid quoted regex is a negative control, not a repair target. Rust integration guidance explains newline division, regex precedence and regeneration; no unmeasured backend parity or downstream acceptance is claimed.

## 2026-09-23 — SESSION-STARTUP-READING.86.1 - preserve non-slash symbol call boundaries

Recognize LF/CRLF/CR after balanced non-slash symbol calls as statement boundaries. Preserve the authored callees for +, -, *, %, = and all six numeric comparisons. This fixes ten measured compile rejects and subtraction's wrong null result: failed lookahead previously consumed '-' and constructed an empty-name call. Slash keeps its existing discriminator until .86.2 reconciles it with accepted multiline regex literals.

The initial test run found an incorrect test assumption about '=' normalization; the public AST corrected it before production changed. Corrected RED has two boundary failures and two compatibility passes. PASS: 247 core tests and 401 selected runtime tests; the new core target covers 110 symbol/separator/parser combinations, 22 following-write source/span cases and retained compatibility. Three new runtime groups cover 33 symbol assignments, a Unicode-source write and five compatibility cases through source-AST/compiled serde and generated plans. All 14 mutation tests pass, including independent emitted execution after subtraction. Native 44 passes: 39 exact numeric values and five unchanged division rejections owned by .86.2. The exact book example returns 7. Binary SHA-256: 80227ab43b9ef73f56c7884d28151f83f2c6562d0c98bdab35a45bd2255129e5.

Split parent .86 before implementation into bounded non-slash .86.1, division/regex .86.2 and canonical closeout .86.3. Preserve all forty public Perl/native/core observations, including independently unexplained Perl EOF/quoted/multiline controls under .86.2. The Rust integration guide includes a subtraction/newline example and regeneration guidance. Other backend integration contracts are unchanged; no cross-backend grammar expansion is claimed. Verification tier is focused; the parent remains open.

## 2026-09-23 — SESSION-STARTUP-READING.49 - preserve regex statement boundaries

Remove whitespace consumption before Rust action-regex suffix scanning. Only adjacent compatibility letters are consumed; LF/CRLF and following identifiers remain available to the statement parser. Preserve the existing pattern-only RegexLiteral representation. A separated suffix such as /x/ i rejects without a statement separator. Subsequent typed writes and mutations retain their exact source and Unicode scalar spans.

Core RED has four regex failures and one independently faulty arithmetic control; scoped RED has four failures and one compatibility pass. All 243 core tests pass after the repair, including five new groups and 144 assignment combinations across both parser modes. PASS: 243 core tests; 397 selected runtime tests (179 library, 197 integration, 2 source-fidelity, 3 regex, 13 mutation, 3 corpus groups covering 105 fixtures). The regex target checks 32 assignments, exact nested-write source, 3 valid and 3 invalid controls across source/compiled serde and generated plans. The new mutation case also passes independently compiled emitted execution. Native: 22 checks pass (16 return 7, 3 malformed inputs reject, 3 symbol-call rejections remain owned by .86); the exact book example returns 7. Binary SHA-256: 2675f2ffb467b123ef6e866b3765c68232a519aac42f6771ed620eef8e0e4e24.

The Rust integration guide includes an executable newline example and the remaining arithmetic slash-call limitation. Newly owned .86 follows immediately and retains the original failing source and public Perl/Rust comparisons. The known no-edge Perl E-result issue remains .27; explicit action edges provide the value oracle. Other backend integration guides retain their verified contracts. Ordinary focused verification applies; canonical .47 closeout at 04534674 remains historical proof, not proof of this changed tree.

## 2026-09-23 — SESSION-STARTUP-READING.47.3 - close Rust mutation argument and source repairs

Validator repair a6ff64e56 and source repair 01c40fd3f are committed and verified. The latter passes the complete Rust component gate, core238, all runtime targets, storage and CLI66x2; final native25 uses SHA256 2025d1ce7556aaae4b5ef516344ed7054e7620bc51d7f454c778938279464be4. Whole-spec/programmatic, serialized, generated and independently compiled emitted carriers preserve the tested source and values. Neutral authority retains167+592 mutation proof. This documentation-only closeout requires successful canonical tools/run_ci_local.sh on the exact staged candidate and its receipt before landing; the commit body and promoted receipt record the result. Separate .49/.52-.54/.58-.59 defects remain open.

Reconcile the task parent, Knowledge and live roadmap pointers. The Rust integration guide already describes exact internal source, compact-header values, closing-line statements and rebuilding old artifacts; the other backend guides retain their independently verified contracts. Resume .49 after a clean committed handoff.

## 2026-09-23 — SESSION-STARTUP-READING.47.2 - retain Rust action source through outer parsing

Preserve internal CRLF/LF, blank lines, indentation and trailing line whitespace while collecting Rust action blocks; retain only the established trim around the complete block interior. Keep same-line remainders intact. Restore the original rule-header tail instead of reconstructing its first token and remainder with a single space. This also repairs accepted compact-header string values: two spaces and tabs no longer become one space.

Core RED compiles with four exact-source failures and one compatibility pass. Native before-repair controls establish eight retained valid/invalid behaviors and a three-case header/body literal contrast. Add 88 outer source-AST combinations, compact/remainder/compiled-scalar controls, 15 runtime literal cases, and extend the mutation carrier/emitted tests to whole-spec input alongside programmatic source ASTs. First component attempt passes core201 and four source groups, then fails the remainder group: a collector uses the next-line cursor for a closing-line suffix and skips the next authored line. A native assignment control returns3 instead of4. Track suffix origin separately from the consumed-line cursor and align multiline fluent collection with that cursor contract. Six core groups and 16 runtime source/value cases cover the repair. PASS: complete Rust component gate (238 core tests, runtime library179, all integration targets, storage oracle and CLI66/66 twice); six core source groups cover 88 block combinations plus header/remainder/scalar controls. Two runtime groups cover 15 exact literal values and the skipped-assignment regression. All12 mutation tests pass through whole-spec and programmatic source ASTs, serde, generated plans and independently compiled emitted consumers. Final native25 passes with binary SHA256 2025d1ce7556aaae4b5ef516344ed7054e7620bc51d7f454c778938279464be4. Neutral167+592 mutations retain byte-identical authority; book, formatting and public no-drift pass.

Rust integration guidance and the source-fidelity Knowledge record describe the exact boundary. Shared contract/schema and dependency pins remain unchanged. Compact fluent parsing, invalid header suffixes, regex-brace/multiline-quote recognition and receiver guard defects retain their separate owners. Canonical parent closeout follows under .47.3.

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
