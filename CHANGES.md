# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

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

## 2026-09-09 — DART-STARTUP-READING.1.8: corpus and loader reading

Read 1,027 fragments / 29,012 unchanged bytes through corpus/loader EOF and MCP line 9.
All 42 selected tests pass, including 105/105 corpus and direct neutral loading cases.
Dated facts, public explanation and exact coverage retain prior evidence; no new defect is confirmed.
Reading reaches 8/55; next .1.9 reads the generated bundle. Existing repairs remain gated.

## 2026-09-09 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.8 - admit approved history member

ADR 0110 implements the director-approved exception: 31 change-history files and a 30-line / 17,039-byte manifest. Governed rollover preserves complete clean-source records; independent source/hash/reconstruction and exact-limit proof accompany canonical validation. Other limits and source-reading gates stay unchanged. Resume Dart .1.8 after clean landing.

## 2026-09-09 — DART-STARTUP-READING.1.7 - read compiler; own recognition effect bypass

Read compiler/corpus ranges; 74 tests pass. Eight probes confirm recognition-effect bypass and leaked writes after rollback; repair .2.4 is owned and book-visible. Exact reading/proof is in the task tree. History capacity intake .4 precedes .1.8.

## 2026-09-09 — DART-STARTUP-READING.1.6 - read CLI and compiler entry; own trace overflow

Read all .1.6 ranges: 1,500 fragments / 43,571 baseline-identical bytes; cumulative 6/55 children, 9,000 fragments / 269,107 bytes. Existing selected AST/compiler/CLI/root tests pass 27/27. Seven adapter probes confirm that adjacent signed-integer overflow throws after trace-file reset while invalid text preserves the file. Own gated .2.3 repair, exact reproducible fact and visible book limitation. Preserve earlier switch/regex findings, parked ideas and source bytes; next .1.7.

## 2026-09-09 — DART-STARTUP-READING.1.5 - read callable and spec state; own regex scanner defects

Read all .1.5 ranges: 1,500 fragments / 42,210 baseline-identical bytes; cumulative 5/55 children, 7,500 fragments / 225,536 bytes. All 55 selected tests pass. Five public AST/programmatic-spec controls confirm grouped-regex action scanning and regex-unaware lifecycle validation defects. Create exact reproducible fact and gated .2.2.1/.2.2.2 repair ownership, route existing startup .54.3 recurrence, and expose the limitation in the book. Preserve switch repair, parked ideas and source bytes; next .1.6.

## 2026-09-09 — DART-STARTUP-READING.1.4 - read assignment, mutation and scanner parsing

Read parser lines 999-2498: 1,500 fragments / 42,924 baseline-identical bytes; cumulative 4/55 children, 6,000 fragments / 183,326 bytes. Existing AST/callable/mutation/punctuation/write/progressive/staged tests pass 79/79. Record assignment, reserved mutation, staged declaration and scanner comprehension in the existing parser fact. Synchronize book and continuity while preserving attached-switch defect .2.1 and its gated repair children. No executable change or new defect; next .1.5.

## 2026-09-09 — DART-STARTUP-READING.1.3 - read resolver and parser; own switch body omission

Read .1.3 contracts 690-1191 and parser 1-998: 1,500 fragments / 43,988 baseline-identical bytes; cumulative 3/55 children, 4,500 fragments / 140,402 bytes. All 45 selected tests pass. Five controlled AST/resolver/native/reconstructed probes confirm attached-switch body omission and duplicate-default replacement. Record exact mechanism/reproduction and gated .2.1.1 validation / .2.1.2 repair owners; synchronize public limitation, Knowledge and continuity. No implementation, emitted or other-backend claim; next .1.4.

## 2026-09-09 — DART-STARTUP-READING.1.2 - read remaining ActionIR nodes and helper tables

Read both .1.2 ranges: 1,500 fragments / 36,093 baseline-identical bytes, completing ActionIR AST and contract tables through line 689. Reconcile exact selectors, deferred codeblocks and current accepted aliases; refresh the resolver fact and its historical verification command. Existing AST/parser, contract, binding and callable tests pass 50/50. Synchronize book, roadmaps and continuity at 2/55 children, 3,000 fragments / 96,414 bytes; next .1.3. No executable change, new confirmed code defect or parked-feature activation.

## 2026-09-09 — DART-STARTUP-READING.1.1 - read Dart entrypoints and initial ActionIR declarations

Read all six .1.1 ranges: 1,500 fragments / 60,321 baseline-identical bytes, including five complete entries and ActionIR declarations through line 659. Record the thin CLI delegates, explicit public export boundary and typed private carrier/data shapes. Existing ActionIR/parser and spec-AST tests pass 9/9. Synchronize Knowledge, book, roadmaps and bounded continuity; next .1.2 resumes the AST and contracts. No executable change, new confirmed defect or parked-feature activation.

## 2026-09-09 — DART-STARTUP-READING.0 - freeze exact bounded Dart reading children

Freeze 55 pending Dart reading children / 169 ranges over all 115 baseline-identical paths, 80,296 physical lines and 2,471,305 bytes. Each child declares exact coordinates, dependency, bounds and digest; independent reconstruction covers every byte once. Preserve startup .3.4 and all earlier repairs, synchronize roadmap/book/Knowledge/continuity, and route .1.1. Focused verification applies under canonically admitted capacity a67a18bf. No source-reading credit, executable change or parked-feature activation.

## 2026-09-09 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.4 - admit bounded Dart reading ownership

Admit docs/tasks/DART-STARTUP-READING.md with pending decomposition, reading, repair-intake and closeout ownership. Preserve startup .3.4 as the existing reading prerequisite/closeout owner and bridge directly to the new tree. All 115 Dart paths and 2,471,305 bytes remain baseline-identical; the exact 55-group/169-range plan re-verifies. Recompute full current/member reserve, retain old nodes/Knowledge/immutable stores, and synchronize every current frontier and the book. No source-reading credit, executable change, additional capacity increase or parked-feature activation. Exact staged canonical milestone proof precedes the clean handoff to DART-STARTUP-READING.0.

## 2026-09-09 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.3 - independently verify Dart capacity and evidence retention

Independent verification of canonical implementation 4489f5e9 confirms exactly four approved registry scalars, actual validator boundaries, retained task/Knowledge paths and questions, 59 history-store files (56 immutable segments and three manifests), and all 11 FUTURE files. Stable lookup returns exact owner bytes from root and docs/. Recompute current pressure and the complete reserve including member limits; all fit. All doctrines, both histories, Knowledge synchronization, rendered book and staged scope govern this focused documentation slice. No capacity, executable or parser change; admission .7.4 remains next.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.2 - implement the approved Dart capacity controls

Implement the director-approved ADR 0108 exception through exact execution ADR 0109. Change only task aggregate lines/bytes to 88,000/9,437,184 and Knowledge file/line totals to 1,152/72,000; preserve all member and other limits. The task main census and boundary self-tests share actual member/aggregate validators. Old guards fail five new classes; approved guards pass 31/31. The unchanged routing validator passes 16 registry-bound cases/24 executions. Existing IDs, records and parser behavior remain intact; canonical receipt-bound proof precedes landing, then independent .7.3 and admission .7.4.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.1 - design bounded Dart capacity and record the approval boundary

Record proposed ADR 0108 with exact task/Knowledge aggregate limits, measured growth and explicit reserve arithmetic, a separate bounded Dart task-tree, preservation/retrieval obligations and pending .7.2-.7.4 implementation/proof/admission. The task guard independently enforces current aggregate caps, so implementation requires a director exception while full-codebase reading is incomplete. No limit, registry, guard, parser or runtime changes are made. The book and continuity expose the pending decision; focused verification governs this design-only slice.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.0 - measure Dart reading demand and documentation capacity

Reverify all 115 Dart baseline paths / 80,296 lines / 2,471,305 bytes. Explicit UTF-8-safe packing proves 55 groups and 169 coordinate-verified ranges; a distinct 56-group control preserves the earlier planning allowance without inventing its historical grouping. A minimal 605-line scoped-leaf projection exceeds both aggregate task and startup-file headroom. The existing Knowledge card contains the executable inventory/projection/pressure audit; the book, roadmap and continuity pointers route capacity design .7.1. No Dart reading or ownership, limit change or migration is admitted.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.67 - close Rust reading with exact coverage and durable repair ownership

Close the Rust reading parent after independent proof of all 412 baseline paths / 3,533,382 bytes, two empty inputs and 66 uniquely committed bounded children. Current Git modes, blobs and working bytes match baseline; all 141 Knowledge paths touched by reading commits remain present. Preserve all post-Perl repair ownership: 34 top-level owners, 90 pending nodes and 73 pending leaves, plus unchanged earlier/cross-cutting repairs. The existing inventory card stores executable scope/continuity audits and exact digests. Route the clean next action to containment .7 before Dart decomposition; full-codebase reading remains No. This designated parent boundary requires exact staged canonical CI, whose outcome is retained in the commit.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.66 - complete final Rust contract consumer reading

Reconcile four baseline-identical scopes: 1,468 lines / 48,324 bytes. Complete all sixty-six Rust reading groups while keeping .3.3.67 parent closeout pending. Four existing Knowledge cards distinguish Unicode strict-loader compilation and native/generated selectors, uniform-binding generated helpers, variadic emitted-text inspection and the one independently compiled write-vivification fixture with a relative manifest and checked child status. Fresh Unicode806/9/8/2, binding11/7/6/8, signature3/9/7 and write105-mutation neutral checks pass. Historical runtime evidence and all pending repairs retain their scope; no new native target is claimed.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.65 - complete lifecycle trace and typed-source consumer reading

Reconcile five baseline-identical scopes: 1,500 lines / 51,021 bytes. Preserve lifecycle native/reconstructed/generated-helper execution while qualifying emitted text inspection; date the older eleven-test trace result against twelve current source tests. Typed-source Knowledge separates exact 92+7 catalog equality from executed helper fixtures, and Unicode casing retains managed generation versus dated runtime proof. Existing lexical repairs .52–.54 remain pending; label suffix is .66-owned. Fresh typed 14/0/231, Unicode twelve-fixture/five-module byte comparison and lifecycle fourteen-mutation proof pass with focused continuity checks.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.64 - complete staged recursive and carrier consumer reading

Reconcile 1,491 lines / 55,771 baseline-identical bytes: complete recursive staged-AST tests and four fresh-authority carriers, then begin standalone-lifecycle helper/placement tests. Both independently compiled staged programs check child success; .78 still owns their absolute Cargo dependency, and .73–.75 runtime gaps remain open. Knowledge qualifies historical RED/rollout records, retains the completed .61 native result and uses managed locked/offline reverify commands. Fresh neutral staged proof passes 9 legs / 123 base / 129 public mutations; exact CI registrations and focused continuity checks govern landing.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.63 - complete emitter, loader and staged consumer reading

Reconcile emitter suffix, all native-loader tests and the staged-AST consumer prefix: 1,492 lines / 58,940 baseline-identical bytes. Correct the older eight-case subset card's unqualified all-105 classifier claim against existing .77, retain checked subset/all-family child execution, and keep .71/.78 literal/manifest repairs distinct. Qualify directory non-file fixtures and the staged test's replaced panic hook; .73–.75 remain open. Fresh neutral resolution 14/9/4 and staged 9 legs / 123 base / 129 public mutations pass; source reading does not claim a new full native target run. Knowledge, memory, doctrines, bounded histories and diff govern focused landing.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.62 - complete semantic admission and emitter boundary reading

Read and reconcile the exact admission suffix, source-boundary compatibility tests and emitter prefix: 1,483 lines / 48,632 baseline-identical bytes. Qualify generated-plan versus independent emitted execution, preserve historical admission/full-gate counts, and retain the completed .61 canonical result and bounded September 8 loader observations. Create actual pending routing signal-status repair .79 with a source-pinned executable fact card; public .41.3/.41.7 and runtime repairs remain gated on .3/.4/.5. Focused proof covers exact identities, semantic governance, original/guard routing children, safe history siblings, Knowledge, memory, doctrines, histories and diff.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.61 - complete semantic consumer reading and roll engineering notes

Completed Rust checkpoint `.3.3.61`: 1,461 lines / 52,200 baseline-identical bytes and semantic governance 6/20/128, rollout 9/0, admission 6/0. Corrected the independent emitted-module digest overclaim. The scheduled engineering-notes rollover preserves exact source history with a separately indexed finite count admission; canonical staged verification is required before landing.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.60 - complete Rust cursor and diagnostic consumer reading

Completed Rust checkpoint `.3.3.60`: 1,472 lines / 49,181 baseline-identical bytes. Reconciled cursor/diagnostic consumers, scalar numeric coverage and semantic-foundation prefix. Fresh cursor governance passes 8 complete / 0 pending with 60 mutations. Qualified historical normalization handoffs and retained selector repair `.57`; next `.61` owns semantic reading and scheduled notes rollover.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.59 - complete Rust root-selection consumer reading

Completed Rust checkpoint `.3.3.59`: 1,487 lines / 48,937 baseline-identical bytes. Reconciled repeated-result roles, moved-root test construction and root-selection adapters. Fresh neutral governance passes 7 complete / 0 pending with 54 mutations. Qualified historical Rust-only/65-case Knowledge claims and routed three Cargo commands through managed storage; no runtime source changed.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.58 - complete recognition and observation consumer reading

Completed Rust checkpoint `.3.3.58`: 1,471 lines / 49,296 baseline-identical bytes. Preserved recognition/observation and repeated-result proof boundaries. Two source-bound construction probes reproduce absolute emitted Cargo inputs; repair `.78` owns nine writers, relative-path normalization and actual relocated/emitted proof. Knowledge/live/task routing updated; no parser or manifest implementation changed.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.57 - complete progressive and punctuation consumer reading

Reconcile four scopes: 1,476 lines / 52,176 baseline-identical bytes. Complete progressive and punctuation consumers and read recognition-prefix state/identity checks. Preserve the existing contains-arity exception and distinguish generated-plan/source assertions from emitted execution. Route the Rust arity recheck through managed Cargo. Focused checks pass.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.56 - complete MCP tests and reconcile progressive authority reading

Reconcile four exact scopes: 1,474 lines / 50,699 bytes. Complete MCP tests and record the private progressive-authority prefix. Preserve existing transport defect limits. Correct an older admission card that still called completed recurrence/public work pending, using canonical completion records. Focused checks pass; behavior is unchanged.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.55 - complete mutation consumer and checkpoint MCP admission reading

Reconcile mutation-consumer completion and MCP admission prefix: 1,500 lines / 53,737 bytes. Preserve guard-control limits, emitted process-status proof structure and host-owned native index registration. Existing defects and parked authoring ideas retain their owners. Project the required engineering-notes rollover to .61 and own its exact history/capacity review there. Focused continuity checks pass; implementation is unchanged.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.54 - complete gap and logical consumer reading

Reconcile three scopes: 1,449 lines / 54,955 baseline-identical bytes. Finish gap and logical consumers, verify their explicit emitted-process status checks and record the logical codeblock-row limit. Begin mutation syntax reading. Focused continuity checks pass; test and runtime behavior stay unchanged.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.53 - complete integration reading and checkpoint gap-capture consumer

Reconcile two scopes: 1,500 lines / 55,337 baseline-identical bytes. Complete all 3,910 integration lines and read the gap-consumer prefix through 380. Preserve assertion and emitted-fixture preparation limits against existing Knowledge. Focused continuity checks pass; implementation is unchanged.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.52 - reconcile integration control and traversal reading

Reconcile integration lines 1383–2790: 1,408 lines / 65,108 baseline-identical bytes. Preserve control, value-block, scope, callback and child-result distinctions; qualify historical comments. Route expression-block Cargo rechecks through managed storage. Focused continuity checks pass; implementation is unchanged.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.51 - reconcile classifier reading and own failed-child verification repair

Reconcile the classifier suffix and integration prefix: 1,487 lines / 51,804 baseline-identical bytes. Replay six source-extracted controls: a failed child with all pass markers is falsely accepted; an in-memory guard rejects it. Own repair .77, preserve an executable Knowledge probe, qualify historical classifier claims and correct stale return-scope documentation. Focused checks pass; implementation remains unchanged.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.50 - reconcile corpus and diagnostic test-consumer reading

Reconcile six exact scopes: 1,494 lines / 55,681 bytes. Finish VHDL grammar; read corpus, diagnostic-output and duplicate-slot consumers plus the classifier prefix. Clarify current test-route evidence and route the oracle Cargo reverify through managed storage. Focused checks pass; no runtime change or fresh execution is claimed.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.49 - reconcile Terse and legacy corpus reading

Reconcile 202 scopes: 1,500 lines / 46,200 bytes, including one explicit empty input. Decode 67 JSON files and verify all 68 case directories against the manifest. Complete the last self-hosted mirror and read Terse, legacy, root-recursion and VHDL-prefix fixtures; retain historical smoke limits. Focused checks pass; production behavior is unchanged.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.48 - reconcile user-function edge grammar reading

Reconcile the user-function grammar edge range: 32 lines / 60,575 baseline-identical bytes. Exact mirror identity retains .44 Unicode proof. Record distinct edge fields and balanced blocks; the suffix remains .49-owned. Focused continuity checks pass; behavior is unchanged.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.47 - reconcile minimal-rule and user-function grammar reading

Reconcile four owned scopes: 249 lines / 53,907 baseline-identical bytes. Finish the minimal-rule grammar and review its input, the user-function stored oracle and grammar prefix. JSON decoding and unchanged canonical mirror checks pass; .44 Unicode evidence remains applicable. No grammar, runtime or public behavior changes.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.46 - reconcile comment-skip and minimal-rule grammar reading

Reconcile four owned scopes: 231 lines / 59,566 baseline-identical bytes. Finish the comment-skip grammar and review its input plus the minimal-rule stored oracle and grammar prefix. Exact mirror identity retains the .44 Unicode freshness proof; JSON and focused continuity checks pass. No runtime, grammar or public behavior changes.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.45 - reconcile self-hosted labels and edge grammar reading

Reconcile the comment-skip grammar middle: 44 lines / 60,931 baseline-identical bytes. Record header, regex-slot and action/blind/bare node-field comprehension. The complete mirror still matches the exact canonical identity validated by .44; its Unicode proof remains applicable. Focused continuity checks govern this documentation-only checkpoint.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.44 - reconcile self-hosted grammar reading and mirror freshness

Reconcile four owned scopes: 225 lines / 65,141 bytes remain baseline-identical. Complete the action-edge grammar copy and preserve the comment-skip prefix boundary. All four corpus grammar mirrors equal canonical source; the Unicode rule-label contract and JSON decoding pass. The reading checkpoint changes no grammar, runtime or public behavior; remaining Rust checkpoints and formal alignment stay pending.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.6 - consolidate verified task chronology and correct historical references

Consolidate 264 chronology rows into 260 existing task nodes across four closed trees, preserving every prior node reference and verbatim completion note. Six captions remain in their original tables. Exact source/node/Git and inverse reconstruction checks preserve all other node fields and outside text. Net saving: 251 lines and 8,210 bytes. Correct the proven wrong-node expression-block commit reference with its previous value retained. This ordinary documentation leaf uses focused proof; the parent remains open for Dart capacity .7 after Rust closeout.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.43 - reconcile corpus reading and own SimEnv dispatch repair

Reconcile all 53 owned scopes (52 nonempty): 1,106 lines / 59,355 baseline-identical bytes; 18 JSON files decode and the manifest contains 105 unique cases. Twelve paired Perl probes and exact handler lowering confirm a distinct SimEnv bare/braced dispatch defect, now repair-owned by .76. Preserve three DBINP authoring investigations in PARSER-AUTHORING-APIS without activation, clarify historical corpus evidence, and own the next task-capacity boundary under containment .6. No production or public contract changes.

## 2026-09-08 — STRUCTURED-TEXT-FORMAT-PROGRAM.0.1 - record approved parked language coverage and evidence matrix

Record the director-approved programming-language coverage track and mechanism/authoring-difficulty matrix in the existing format program, ADR 0034 addendum, both roadmaps, task index, Knowledge and visible mdBook status. Future work is owned by .2.8 and .12; readiness .1 stays inactive and the original 91 catalog rows remain exact. Planning documentation adds no supported language or implementation. Focused inventory/state/route, rendered-book and continuity checks govern this slice.

## 2026-09-08 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5 - compact duplicate startup chronology without losing evidence

Verified all 100 recorded batch identities against Git and all 102 duplicate commit subjects against canonical nodes, then retained each completion note verbatim beside its owning node. Removed the duplicate enumeration/table: 186 task-file lines and 16,380 bytes. Every other node field and all 316 stable IDs remain exact. No registry limit, immutable history, runtime or public surface changes. Exact staged canonical proof governs this containment closeout.

## 2026-09-08 — SESSION-STARTUP-READING.3.3.42 - complete callable and named-mark reading with corpus prefix

Read all 56 owned scopes: 1,500 lines / 45,529 baseline-identical bytes. Callable and named-mark neutral checks pass. Existing Knowledge distinguishes source inspection, generated-plan assertions and standalone emitted execution. The task collection approaches its unchanged line ceiling; containment .5 owns duplicate-chronology compaction before reading resumes.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.41 — complete Unicode reading and checkpoint callable contracts at the batch boundary

Read the Unicode suffix and callable consumer prefix completely: 1,494 lines / 43,943 baseline-identical bytes. The complete Unicode module is now read; four existing Knowledge cards record the evaluator and precise callable assertion scope. Unicode regeneration/twelve fixtures and callable neutral checks pass. An independent Git census verifies the preceding 99 batch commits. This final reading slice requires an exact staged canonical receipt before landing, with the completed gate summary in its commit body and a clean receipt-verified push.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.40 — complete Unicode upper-map reading

Read Unicode lines 1707–3156 completely: 1,450 lines / 37,746 bytes, identical to the baseline. The upper mapping table is complete through U+1E943. Existing Knowledge records full combining sequences, ligature expansion and many-to-one casing without adding normalization or inverse guarantees. Generation inputs remain unchanged; the preceding checkpoint's five-module regeneration and twelve neutral fixtures remain retained proof. Required continuity checks cover this documentation-only slice.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.39 — finish Unicode lower-map reading and preserve canonical evidence

Read Unicode lines207–1706 completely (1,500 lines/38,103 baseline-identical bytes), finishing the lower table and opening upper full mappings. Unicode regeneration and twelve neutral fixtures pass. Five existing Knowledge cards preserve this comprehension, .3.3.38 canonical PASS at eba1a0ed (CLI66 twice; Phase0 1032/1032 in1100s; 25 optional skips), two fully consumed launch samples, and the requirement to rebuild preserved static probes before claiming later runtime repair.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.38 — complete staged source reading and preserve bounded change history

Completed the three staged source files and read the Unicode mapping prefix (1,500 lines/50,788 baseline-identical bytes). Six existing Knowledge cards distinguish source-authorized marker construction, returned JSON validation, final registry helpers and the legacy function-body adapter. Existing .55.1 includes another source integer-conversion boundary, without a new measured failure. Unicode regeneration/12 fixtures, staged and typed-source neutral checks pass. Mandatory rollover preserves exact clean-source segment 4983 (247 lines/18,635 bytes; SHA-256 90ac78b4747014cf1c23511da66b37cd4c1e2e3d100d0b62ef7719e4cbc5bc3a); prior manifest records remain byte-identical. ADR0106 admits only 30 collection files, 29 manifest lines and 16,463 manifest bytes. The final staged canonical receipt is required before landing.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.37 — trace staged execution and own target validation and counter repairs

Read 1,499 lines/53,102 baseline-identical bytes of staged execution and validation helpers. Independently asserted 28 paired Rust/Perl target records, twelve Rust returned-marker/control records and six call-budget records. Repair .73 owns competing destinations; .74 owns deep marker validation and the backtrace-confirmed provenance overflow; .75 owns exhausted maximum-counter admission. Three new and three existing Knowledge cards preserve exact scope and artifact hashes. Fresh staged/typed neutral checks pass; no runtime/public change is made before required reading completes.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.36 — complete spec parser reading and trace staged registry and invocation authority

Completed spec-parser reading and read the staged-enrichment authority prefix (1,453 lines/51,063 baseline-identical bytes). Five Knowledge cards document exact signature helpers, caller-prepared registry resolution, authority narrowing, fresh seeds and complete-depth preparation. Existing .55.1 now includes the private function-AST integer conversion in its source audit, without a new measured failure claim. Staged, typed-source and scalar-numeric neutral checks pass.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.35 — complete source authority and loader reading and reconcile function projection

Completed source-location and native-loader reading and read the function-parser projection prefix (1,497 lines/51,223 baseline-identical bytes). One new/four existing Knowledge cards now explain sealed materialization, deterministic load stages, exact function/body metadata and scalar-preserving stripping; the earlier Julia fallback description is explicitly historical. Rust authority sections move intact to a focused card after the rollout card reached its byte cap. Resolution, typed-source, diagnostic and staged neutral checks pass. Runtime and public-book implementation remain unchanged during prerequisite reading.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.34 — complete emitter reading and own literal and recognition adapter repairs

Completed emitter reading and the source-authority prefix (1,493 lines/53,383 baseline-identical bytes). Seven freshly emitted identity modules expose four Rust literal compilation failures. Two executable generated modules show recognition plain parse and inert-option siblings disagree on result shape; .71/.72 own both mechanisms and recurrence. Generated, cursor and typed-source checks pass. Two new/three existing Knowledge cards preserve evidence and limits; no runtime or public-book repair is made during prerequisite reading.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.33 — complete static semantic reading and own grouped edge correlation repairs

Completed the static semantic projector and observation event types, and read the emitter prefix (1,482 lines/50,376 baseline-identical bytes). Five paired public queries expose grouped selector/source loss and Rust partial parsing of per-target selectors. Three paired execution controls still return the correct "b" value. New .70 separates semantic correlation, complete grammar/remainder handling and backend/carrier recurrence. Semantic, cursor and generated metadata checks pass; one new/four existing Knowledge cards and continuity preserve exact evidence.

## 2026-09-07 — SESSION-STARTUP-READING.3.3.32 — complete semantic query reading and own token use and newline repairs

Completed semantic query/runtime projection and read the static prefix (1,495 lines/50,145 baseline-identical bytes). Native failure controls preserve correct missing-rule and out-of-range-slot diagnostics. Follow-up paired Get/CLI controls expose Rust accepting forbidden token return/copy as undefined values; a newline-copy twin separately exposes variable lookahead consuming the delimiter and the known warning/drop fallback. New .68/.69 own repairs and recurrence. Semantic, diagnostic and recognition neutral proof pass; two new/five existing Knowledge cards and continuity retain exact limits.
