# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`


## 2026-09-23 — SESSION-STARTUP-READING.46 - preserve UTF-8 diagnostic boundaries

The panic was in error formatting, not successful parsing: unexpected_character_error selected src[pos..min(pos+40,len)] with an endpoint inside a scalar. The current native CLI independently reproduced exit 101 at endpoint 47 inside bytes 46..48. A maximal complete-scalar prefix within the existing byte budget repairs the error path without changing parser cursor state, diagnostic offset units or ActionIR scalar spans. No production panic-catching is introduced.

Core RED: 3 pass/1 split-scalar panic. GREEN: 201 core library tests, 4 diagnostic groups, 5 rule-code rejection groups, the primary CLI rejection test and 4 source/AST/traced/loader/semantic/generated route tests pass. Five rebuilt-native controls pass in 1.16–1.19 seconds; the former Unicode exit 101 becomes ordinary compile:error/exit 1. ASCII, valid Unicode, diagnostic byte offsets and structured scalar spans retain their behavior. Rust formatting and mdBook rendering pass.

The contemporaneous 80-character ASCII control rejects normally before and after repair. The retrieved historical record does not establish the exact original timeout body or cause; current success must not be represented as a retrospective root cause. Existing malformed-rule-code tests provide the direct-dependent source/AST/traced/file/name/semantic and generated-valid controls. The startup root remains exactly 8,000 lines; two adjacent blank separators were compacted to admit the existing leaf metadata, preserving all .45 evidence and every stable ID.


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

An EOF position does not prove that seek dispatch recognized every character; the independent catch-all mutation accepts interstitial junk at EOF. The production grammar therefore rejects unrecognized characters at both levels. Dart public matching also establishes that the prototype backslash-z anchor becomes literal z; greedy comment contents plus an optional line ending preserve the agreed EOF-comment syntax across all six routes. Token lexemes stay JSON strings, even for numbers; independent authored values and round trips check that boundary.

PASS: all 37 authored cases on six native runtimes (222 case outcomes), 21 token-spelling round trips per route and 16 same-engine post-rejection reuse checks per route. Perl has 44 top-level/168 nested assertions including descriptor readiness and the independent catch-all mutation; Rust one complete contract test, Dart 38 tests, Julia 91 assertions, and both Lua routes pass. Three initial Dart EOF-comment failures become green with a portable grammar branch, without changing authored expectations. Historical Lispish quoted-LF fixtures pass 3/3 on Perl, and the new book command returns its exact documented value. Formatting, Dart analysis, shell syntax, book, Knowledge/memory/history/diff and doctrine checks govern landing. The public grammar/recurring-CI boundary requires the exact staged canonical receipt; native file delivery and final report admission remain separate.

The reviewed new book page advances only the mutation/selector public file counts to70/69. Both gates PASS with unchanged semantic/classification controls (mutation14/11/10/50; selector35/0/5/11).

Canonical preflight rejected the 8,002-line task candidate. Two newly added duplicate evidence fields were removed after confirming their mechanism, proof, ownership and exact census remain in the same task node and linked canonical fact cards. All stable task definitions remain in their original order, with no task or evidence dropped; the task root is 8,000 lines and its original ceiling is unchanged.

A final source-inventory review caught missing catalog rows for the new grammar and the existing function-definition grammar, plus stale fixed counts in current Rust/book/roadmap prose. The public catalog now lists every one of the 22 shipped filenames exactly once; mutable invariant descriptions rely on automatic test discovery, and dated historical counts remain explicit. Canonical CI was stopped before completion to include this documentation correction in the exact candidate.

Complete shipped-inventory proof PASS: Rust auto-discovery parses, validates and compiles all 22 grammars; Perl return_descriptor passes 67 assertions (inventory plus three readiness checks per grammar); the public catalog lists the same 22 filenames exactly once. Current invariant prose no longer embeds a stale fixed count, and the 70/69 public guards retain every semantic mutation check.

All five backend integration guides and the shared integration landing page now describe the document grammar, native values, typed rejection and exact focused check commands. They identify the required Top-to-Document selection in the Perl/Dart/Julia/Lua word adapters and preserve historical Rust lispish_file limits. The document chapter links back to every backend guide; schema and lexical rules keep one canonical owner. The Rust integration guide command builds and returns the exact documented two-form tagged value through the public loader and generic native consumer. Direct consumer boundary checks also pass empty documents, ordered two-form input and interstitial-junk rejection with empty stdout.

## 2026-09-22 — SESSION-STARTUP-READING.45.3 - close Rust rule-code rejection repair

The .45 repair closes propagation of reported rule-code parse errors, not every parser defect. .46 Unicode diagnostic safety, .47 mutation whitespace and .49 regex/newline parsing retain separate owners. Earlier generated artifacts with discarded authored blocks require original-source regeneration. .83 remains the complete-document/kind delivery owner.

Compiler correction 10893fb71 passed all core/native regressions and the complete Rust component gate; carrier checkpoint 30c1ddeea passed all four source/AST/loader/semantic/generated route tests. This documentation-only parent closeout retains those exact proofs. Canonical acceptance requires tools/run_ci_local.sh to finish successfully on the exact staged candidate and produce the receipt checked by the normal commit hook; the resulting commit and promoted receipt are the durable gate evidence. Other parser defects and document grammar delivery remain separately owned.

## 2026-09-22 — SESSION-STARTUP-READING.45.2 - verify Rust rule-code rejection routes

SpecFile retains authored rule-code strings; CompiledSpec holds parsed blocks. Emitters consume the latter. An old artifact cannot reconstruct source discarded by warning/drop, so regeneration is the recovery path. The new tests reach actual source compilation and independently execute emitted Rust; they do not invent a raw-source decoder or claim arbitrary serialized ActionIR validation.

Four focused route tests PASS: eight malformed sources yield 32 ordinary/traced source/reconstructed-AST rejections, 16 path/name-loader rejections and eight failed semantic snapshots with no compiled authority or plan. Valid path/name loads, reconstructed compiled state and generated-plan execution return 42; a freshly compiled emitted module verifies direct/traced 42 and compatibility [42]. Production code is unchanged from 10893fb71; its complete Rust compatibility proof remains applicable. Rust formatting, book, Knowledge/memory/history/public/diff checks and normal doctrines govern landing.

## 2026-09-22 — SESSION-STARTUP-READING.45.1 - reject malformed Rust rule code

Validation after compilation cannot recover a block discarded during parsing. Returning Result<CodeBlock> makes all five lowering call sites propagate reported errors while optional edge source remains Option<CodeBlock>. No parser syntax or generated schema changes. Separate Unicode/newline/mutation parser causes retain their owners; carrier verification and canonical closeout remain .45.2/.45.3.

PASS: 12 native invalid cases change from warning/compile:ok/invoke:ok to exit 1/compile:error with no input or invocation phase; three valid controls retain 42 and empty stderr. Four persistent core rejection groups are RED before repair; all five groups GREEN afterward (15 malformed contexts and 11 retained valid blocks). Complete Rust component gate PASS: 228 core and 574 runtime tests, including all 197 end-to-end tests, 21 shipped grammars and 105 oracle cases; primary CLI conformance is 66/66 in each default/POSIX environment, and managed-storage checks pass. The committed quoted-LF manifest passes all three cases on the rebuilt primary binary. Callable contract, book, Knowledge/memory/history/public/diff and registered doctrine checks govern focused landing. Separate carrier proof/canonical closeout and parser-cause repairs remain open.

## 2026-09-22 — SESSION-STARTUP-READING.83.1 - define kind-preserving document grammar

Whole-input validation requires recognition of every character, not just a final offset. Removing the prototype rejecting catch-alls accepts interstitial junk while returning both surrounding forms at EOF. Exact token lexemes make kind/spelling reconstruction independent of numeric conversion or escape decoding. Rust rejected the first prototype's nonportable infix expression but warned/dropped LX and returned null/status 0; canonical num_ne(...) fixes the prototype spelling, while .45 remains a separate real compiler defect scheduled for repair before delivery.

Validation: 37 independent cases (21 accept/16 reject), 136 Perl assertions and the exact durable proof, four native Rust prototype controls with complete output/status capture, and precise compiler source attribution. Knowledge/memory/history/book/public/diff and normal doctrine hooks govern this focused design checkpoint; no canonical run or push.

## 2026-09-22 — SESSION-STARTUP-READING.83.2.1 - preserve multiline Lispish quoted strings

Toolbox-generated dependency slots trace quoted-LF corruption to Lispish.spec:69/71: dot without DOTALL fails the complete token, letting seek dispatch treat payload as syntax. Both quote readers matter inside braces. Direct root calls to their initial actions have no parent entry captures, even on one-line input; eight root/child controls exposed invalid initial probes, which were replaced by real parent/brace inputs and replayed RED against exact pre-fix source. No runtime change is needed.

Validation: three final fixtures RED on clean-HEAD source; Phase0 smoke 9 and six-runtime/two-environment 36 legs GREEN; Rust 26 file values/18 groups, descriptor 9/9, corpus identity/value, book/public/syntax/memory/history/Knowledge checks and normal doctrine hooks. Focused correction; no canonical run or push.

## 2026-09-22 — SESSION-STARTUP-READING.85 - recover SEMULITH reports and repair ownership

Report retrieval must use the source-qualified integration register: ARCHOGEN and SEMULITH reuse LS numbers. SEMULITH/LS-001 is an independently reproducible quoted-LF bug; LS-002 asks for kind-preserving design without silently changing historical Lispish; LS-003 guidance remedies are verified. .85 removes a false missing-input blocker. The compatible LF child can proceed before the broader strict/token contract, preserving historical extraction and output shape. Fresh eight-case Rust replay captures complete output and real statuses, avoiding the supplied pipeline that hides stderr and producer status.

Validation: exact snapshot hash and report/owner reconciliation, native eight-case reproduction, Knowledge/memory/history checks, book rendering, direct public-document checks and normal doctrine hooks. No canonical run or push for this continuity correction.

## 2026-09-22 — SESSION-STARTUP-READING.84 - adopt targeted startup and fast ramp-up

Exhaustive startup reading displaced bug implementation. The director explicitly approved targeted reading and fast ramp-up. Startup recovery and task investigation now have distinct scopes:2–5 minute recovery is a target, while correctness determines investigation depth. Full reading stays separately tracked at conformance89/143; historical prerequisite language is superseded only as a blanket gate. Missing report IDs/titles are preserved as .85's blocker; do not guess the intended three from recent audit findings.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.89 - read trace dispatch and typed source consumers

Trace CLI checks exact routed JSON, stderr, compile/invoke events and ambient-trace isolation on operational failure. EmitContext checks removed-selector rejection, canonical lowering, dependency injection and actual cold-process before/after Trace absence. Generated branch helpers test disabled lazy details, enabled context and caught detail errors; startup .24 still owns incoming exception preservation. Non-repetition and repetition consumers execute selected branch outcomes, while four repetition emitter templates are source-checked separately. RuleIR compares planning metadata, lifecycle routing, mixed-action rejection and descriptor compile events. Typed projections compare all 92 catalog rows plus seven aliases, detached catalog copies, live and same-process generated named-mark/absent-match results, and a present zero-width control. Values through226 cover exact scalar positions, coordinates, direct/derived materialization, detached position records and part of the diagnostic subtest; no partial value test is executed. Seven complete consumers pass 27 top-level/402 nested TAP results: CLI3/17, EmitContext4/29, branch3/16, nonrep4/35, rep4/54, RuleIR5/39 and typed projections4/212. Typed neutral governance passes14 complete/0 pending/231 mutations. Twelve EmitContext process controls reproduce both known defects and reap both timeout children. Four source-observation controls prove original6/6 assertions miss Top-only instrumentation removal; the bounded twin passes pristine and fails only assertion4 after removal. Existing .2.16 repairs now own eleven process helpers. New .2.19 owns the cross-handler source assertion; production instrumentation passes the stronger control. Corrected stale EmitContext fallback wording to current rejection. Startup .24 and all prior repair/source/book/policy prerequisites remain. No production change, full immutable-value execution, fresh-process generated proof, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.88 - read staged lifecycle and trace consumers

The staged suffix executes decreasing derived lineage, exact cycle/depth/call/step rejection, cancellation/deadline safe points, cumulative result and diagnostic limits, direct/ordered rebasing, transaction denial and expired contexts. Four carriers compare complete results with retained distinct snapshots, callbacks, tokens and clocks; one first-to-second result mutation checks isolation. The normalized route directly calls a newly compiled descriptor handler; the plan route validates a minimal plan then executes its loaded source. Generated packages share the process. Lifecycle tests compare exact bootstrap/provenance/ActionIR twins, four duplicate orders, earlier brace owners and structured malformed diagnostics; one generated mixed fixture executes. Self-hosting checks explicit/bare I and seven reserved lifecycle markers. Trace consumers compare exact lowering and selected events, with real cold-process before/after lazy-loading checks; they do not execute the lowered fragments as user programs. Six complete consumers pass 188 top-level/688 nested TAP results: staged 143/322, lifecycle 7/274, self-hosted 25/0, compact trace 4/24, method trace 4/39 and pipeline trace 5/29. Staged governance passes 9 rollout legs/123 base and public 6/17/10/129 mutations. Lifecycle governance passes 9 placements/4 duplicates/6 owners/3 malformed twins/6 runtime rows/14 mutations. Forty-eight source-pinned trace-process controls reproduce status/pipe defects and reap all eight timed-out owned children. Existing .2.16.1/.2.16.2 now own ten process helpers, retaining their callers and prerequisites. Startup .44/.73 and all prior repairs remain open. No unread CLI test execution, historical false-green run, fresh-process generated proof, production repair, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.87 - read staged enrichment declaration and scheduling consumers

The consumer pins neutral inventories separately from execution. Function-body v1 retains its adapter, phases, errors and body_ast target. Dedicated assignment markers carry direct/ordered Unicode-scalar provenance and detached sidecars; malformed/dynamic declarations and recognition reachability reject statically. Resolution, narrowed authority, normalized job/cache identity, frozen callbacks, four stitch policies, three failure policies and detached results execute through private host APIs. Typed index 2 precedes 10; plan-cache hits still execute fresh results and retry failed children. Individual invalid targets reject before callbacks; a displaced later marker rejects after one callback, matching open startup .73. One-depth enrichment leaves new markers inert. Live recursive proof covers breadth-first order, detached lineage, four fresh contexts and shared steps; later payload/decrease/resource/carrier assertions remain unread. The exact complete prefix through 1461 passes 135 top-level/227 nested TAP results. Staged governance passes 9 rollout legs/123 base mutations and public 6/17/10/129; typed source passes 14/0/231; recognition passes 138 ActionIR rows/250 calls/58 mutations and 9/9 rollout. Existing startup .44 identity-lifetime and .73 competing-target repairs remain open, along with all prior defects and required source/book/policy prerequisites. No suffix execution, new runtime defect, repair closure, production change, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.86 - read semantic index and sparse slot consumers

Foundation tests distinguish strict UTF-8 bytes from scalar columns, reject split characters and retain cloned failed-compilation data. Query tests compare all 19 static digests, 26 error boundaries, privacy, detached responses and silence with compilation disabled. Runtime observations preserve exact input, cursor, typed slot/final events, derived copies, sink exception identity and trace/diagnostic neutrality across eight rows. Generated packages share the process; reconstructed_plan validates the minimal plan then calls the same generated executor, without rebuilding it from that plan. Static projections deep-compare neutral snapshots and both mutated copy fields. Admission composes 12 roles and all 20 digests. Sparse AND preserves structural slots 0/1/2 while dispatching only authored actions, live and generated. Six complete consumers pass 146 top-level/634 nested TAP results; the direct-dependent duplicate-slot suite adds 12/62, totaling 158/696. Semantic governance passes 6 fixture groups/20 exact queries/128 mutations with rollout 9/0 and admission 6/0. Duplicate-slot governance passes 5 fixtures/2 diagnostics/6 runtime rows/59 mutations with rollout 7/0. Known runtime and observation repairs remain open with required source/book/policy prerequisites. No new defect or repair closure, fresh-process generated proof, production change, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.85 - read cursor scalar and semantic call consumers

Root trace completion checks effective entry identity and absence of handler entry on failed selection. Cursor tests distinguish family-derived seek/consume, typed edge normalization and provenance, mixed-parent recursion, loaded descriptors, exact admission roles, generated-v2 metadata and option retirement. Generated packages share the process. Scalar fixtures execute exact admitted values; numeric emitted-source proof checks its dependency declaration only. Semantic calls deep-compare 22 records/25 relations, source preorder, shared family authority, privacy, multibyte columns and interleaved function masking. The nested return-shape mutation is not asserted by the original copy test. Foundation reading ends inside its first expected snapshot, without executing that partial subtest. Fresh focused proof passes 431 top-level and 213 nested TAP results across seven complete files. Cursor governance passes 36 family spellings / 18 edge cases / 8 parent-child cases / 14 Perl roles / 60 mutations; numeric passes 55 cases / 18 helpers; semantic passes 6 fixture groups / 20 queries / 128 mutations with rollout 9/0 and admission 6/0. Twelve controls reproduce the byte-identical sixth subprocess helper defects and reap both timeout children. Twenty-four source-capture controls reproduce both negative-only cursor observations. Four semantic copy controls pass original 6-assertion tests with shared nested shape, while the 7-assertion guard rejects exactly that mutation. Existing .2.13 owns both cursor-source observations; .2.16 owns the sixth subprocess helper; new .2.18 owns semantic nested-copy test sensitivity. Production copies pass the stronger scratch control. All repair and source/book/policy prerequisites remain; no production change, canonical run, dependency build or push is claimed.

## 2026-09-22 — CONFORMANCE-SOURCE-READING.1.84 - read recognition observation repetition and root selection consumers

Recognition completion checks typed direct/mutual zero-progress errors and generated falsey commit results. Recursive observation locks dedicated lowering, static/effect barriers, exact detached nine-field records, falsey/failure outcomes, cursor ownership and recursion identities. Repetition executes eight mode and ten special cases, loaded/descriptor/generated/trace/CLI/corpus roles. Root selection preserves explicit/first-marker/first-rule precedence, authored identity, strict graph independence and generated-role attribution. Generated packages share the host process. Root trace reading ends inside an invocation at 359; only complete constructs through line 324 execute. Strict Get remains intentionally unwired and the neutral strict loop is model arithmetic, with separate real-validator cases. Fresh focused proof passes 79 top-level and 475 nested TAP results: recognition 51/99, recursive observation 7/78, repeated action results 10/122, root selection core 7/78 and the complete root routes prefix through line 324 at 4/98. Neutral recognition 138/250/58, typed 14/0/231, repetition 8/0/54 and root 7/0/54 pass. Twelve source-extracted repeated-action process controls confirm signal-status loss and sequential-pipe blocking; both timed-out owned children are reaped. Existing .2.16.1/.2.16.2 now also own the repeated-action CLI helper; all previous repairs and required source/book/policy prerequisites remain. No production repair, fresh-process generated proof, dependency build, canonical run or push is claimed. Director reconfirms reading-only documentation checkpoints before full reading completion; implementation stays gated.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.83 - read progressive punctuation and recognition observation boundaries

Complete progressive carrier, punctuation and recognition authority reading; stop recognition carrier inside direct-recursive fixture at549 and execute only complete constructs through535. Focused proof195 top-level/424 nested TAP results (nested subtest results included). Four added recognition compatibility scope controls pass alongside285 original nested authority assertions: its fixture never enters execution. .2.17 owns actual supported-carrier observations, distinct from startup .38 completed-token restoration. Extend .2.15 with the absence of actual parent-register comparisons in the full progressive carrier while preserving exact payload/diagnostic proof. Same-process package loads are not fresh-process evidence; no runtime corruption, source repair, canonical run or grammar use claimed.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.82 - complete Phase0 and own subprocess and parent observation gaps

Read the final Phase0 helpers and two complete test files plus the admitted progressive contract prefix. Exact fresh proof is fuzz 5 top/307 nested, authority 9/264 and contract prefix80; no unread carrier suffix is executed or credited. Parent observation uses a fixture clone only: eight scope controls pass with the original authority assertions, without proving runtime corruption. Four source-extracted subprocess helpers each lose SIGTERM status and block on stderr-first/interleaved large output; 48 original/guard outcomes pass and all eight timeout children are reaped. .2.15 owns actual parent observations; .2.16 splits status and concurrent capture. Correct .1.81 terminology to the previously established 1031 subtests within 1032 top-level assertions; retained runtime results and source bytes are unchanged.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.81 - finish Phase0 subtests and bound remaining observation repairs

Complete the aggregate assignment through final admitted staged-AST subtests: retained ordinals 1019–1032, 236 direct assertions. Exact block/traversal/restoration and inline-control payload checks remain bounded; the final child wrapper proves its retained exit/143-plan/top-level-failure conditions. All Phase0 subtests are physically read, but discovery and subprocess helpers remain. Split .2.14 into declaration sensitivity, genuine comparisons and description/guidance children before repair; preserve existing scope and acceptance. Four public live-empty/independently-loaded controls reproduce the absent-hash counterpart (0/1 versus explicitly bound 0/0), now owned by startup .17.2. No implementation or canonical rerun.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.80 - read shape and receiver checks and own absent host-slot leakage

Colon/shape tests preserve evaluated key and scalar-held binding semantics; current receiver returns and terminal boundaries match the dated Knowledge updates. A fresh twelve-assertion array-receiver replay passes. Its exact public source contains no missing scalar declaration but reads undeclared @missing, correcting the initial diagnostic hypothesis before any claim. Four live-empty/independently-loaded controls reproduce host-array sensitivity only for the absent receiver (1/0), with explicit empty binding stable (1/1). Extend startup .17.1 with this concrete case and loaded-source regression obligation, preserving implicit rule accumulators. .2.14 separately owns old explicit-selector descriptions. No dropped-declaration mutation controls were run or claimed for this fixture.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.79 - read binding and newline checks and extend observation repair

Read current scalar-held declaration/mutation/copy paths, genuine operator/helper contrasts and repeated-call results. Extend existing .2.14 with exact identical-input comparisons (direct path, set nodes, current-helper twins, one spacing pair) and stale keyword/deferred descriptions. These source-qualified gaps do not negate separate exact lowering or runtime assertions. A three-assertion public lowering recipe passes. Retained canonical ordinals 983–1001 cover 246 assertions without a fresh full run. Newline controls distinguish balanced payloads, marker chains and switch do-block termination; the colon-hash test remains partial.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.78 - read function staging and own working variable observation drift

Function-body-v1 tests preserve exact shell AST/body spans, normalized payload/job provenance, deterministic built-in dispatch, source-qualified failures and concrete execution values. They do not re-admit general-v2 staging. Recursion tests separate no-progress termination from LX sequence return and match_group/entry_text ownership. The document-path helper selects eleven named root documents plus book Markdown, yielding 65 current assertions. Public capture of the exact fluent push fixture emits one scalar-held items declaration and zero array declarations. Its six assertions pass after removing the actual declaration; a positive scratch assertion distinguishes the removal. .2.14 owns this observation gap and adjacent stale wrapper descriptions after remaining reading. The initial scratch preparation typo failed before target creation and was discarded; all reported controls use the corrected isolated target.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.77 - read trace and cursor tests and own missing source observation

Tkgui/simenv exact AST and quiet-output checks, historical Lispish AST, limited VHDL tags/EBNF names, three corpus datasets and trace source/decision/mark/route observations remain distinct. Five uppercase-slot comparisons extend existing .2.10 inventory without new generated-code claims. Public dump_parser_source returns 11,417 bytes, but the exact cursor-contract twelve-assertion test also passes after emptying its subprocess output. Scratch positive source observation passes pristine and rejects empty/unrelated output while the original denial still passes. New .2.13 owns the correction and independent controls after prerequisites; production and the separate actual seek/consume controls remain unchanged.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.76 - read shipped grammar runtime smokes and adapter boundaries

VHDL declaration/payload source checks and shipped grammar readiness metadata retain bounded claims. Six runtime-bearing subtests separately observe ifelse quiet undef output, hlink exact delimiter ASTs, lib_reader grouped attributes and context, EBNF logging annotations, seven portmap classifications and pplugin body-text parsing followed by legacy Perl callback execution. Quiet undef alone does not prove branch execution; pplugin readiness does not make callbacks portable. Existing diagnostic/null-output, hlink migration, EBNF migration and pplugin boundary cards agree with these observations. No new defect or dependency snapshot validation is claimed.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.75 - read quote boundaries and shipped grammar migration checks

Quoted/commented/nested semicolons preserve statement boundaries; backtick payloads remain authored source. EBNF, ds_vhistory, regdef, tablegrep and VHDL helper migrations are observed through metadata, canonical nodes and source patterns. Regdef adds a four-assertion parser smoke including the exact CTRL/ENABLE/MODE AST. Zero raw fallback or blocked-rule counts do not independently establish arbitrary EBNF input acceptance or cross-backend runtime parity. The approved dependency grammar snapshot remains unused; canonical fallback and EBNF migration facts retain their own evidence.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.74 - read source boundary projections and legacy classification checks

Cursor, entry, local-match, anonymous, named-mark and whole-input anchors remain distinct. Capture_slice_len has an exact anonymous span expression; take/rest/through-cursor/two-mark checks inspect typed read/write calls and trace labels. These substring checks are bounded lowering observations. Legacy printing, declarations, position tracking, substitution and assignments preserve authored text while avoiding raw fallback; print_each instead uses the parse-scoped diagnostic seam. Canonical source taxonomy and typed-runtime admission remain separate from these metadata checks.

Managed preparation repeated the known child setpgid warning for PID 77478 and exited 0; the final PGID was not captured. Independent document/preservation checks validate the output, not process-group establishment. Existing startup .7 ownership and the recovery/purge restriction remain unchanged.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.73 - read switch safety and compatibility migration observations

Switch fixtures cover first/later/default branches; attached while covers skip, condition mutation and a captured 10,000-iteration failed-match diagnostic. Remaining-tag semicolonless tests check metadata/hits only despite unused code-key variables; six separate uppercase-slot assertions retain .2.10 limits. Canonical event payloads, raw/unresolved blockers and compatibility summaries preserve distinct readiness and migration axes. Bare return/exit and supported call wrappers remain legacy observations, while exit_now uses typed termination. Readiness does not prove cross-backend execution.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.72 - read reducers and meaningful lifecycle source and result locks

Median validates and numerically sorts terms; range tracks extrema; unary array min/max inspect validated terms. Flat and typed-transform cases distinguish list construction from one-binding mutation. Conditional/lifecycle plans include scalar source capture and real parser-result checks. Seven positive marker checks use AND versus collection fixtures deliberately; three runtime cases distinguish final statement, surrounding-rule return and block-local return. Preserve these bounded observations without closing the broader lifecycle drift or nonexistent uppercase descriptor-slot repair. Canonical Knowledge is reconciled in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.71 - read array ordering and own assignment description drift

Sorted_values follows key order; sorted compares lexical terms and reversed changes element order. Numeric reducer expressions validate each term, with sum identity zero and empty average undef. The public assignment outputs use scalar-held arrays despite four stale list-context-flattening labels; inner list construction is distinct. Exact source extraction and four compiled lowering controls confirm the wording mismatch. phase0-array-assignment-description-drift owns durable reproduction; .2.12 owns correction after reading. Descriptor comparisons retain .2.10 limits.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.70 - read hash transformations and snapshot lowering checks

Seven four-assertion direct plans inspect hash lookup, merging, copying and key transforms through expressions and anchored patterns. Bare copy observes one runtime-typed binding; the composed known-hash case checks a shallow snapshot. Rename moves existing keys, drop deletes from a local copy and pick projects existing requested keys. Fourteen descriptor comparisons retain .2.10 limits; lifecycle pick_keys ends before readiness. Exact comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.69 - read scalar membership and reducer lowering checks

Ten direct-lowering plans include nine of four assertions and a six-assertion boundary-transform plan. Exact text retains undefined-needle membership, literal replacement trailing fields, empty/nonmatching boundary identity, concatenation boolean/negative-zero handling, first-match indexes and aggregate reducers. Nine descriptor comparisons retain .2.10 limits. Lifecycle count_keys is partial after both builds. Exact comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.68 - read fallback lowering and normalization metadata

Direct lowering plans 2,3,4,5,3 check coalesce, coalesce_nonempty, definedness, aggregate emptiness and scalar normalization. Their exact strings/anchored patterns observe emitted expressions; they do not execute target behavior. Seventeen descriptor pairs contribute 204 further assertions with .2.10 observation limits. Source-span extraction and Unicode casing remain explicit in the expectations. Exact comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.67 - read payload branches and captured-call descriptor comparisons

Modulo/clamp and array-drop pairs precede join-values and flat-list branches, direct call capture and action if/elseif call capture. Node requirements distinguish IF/ELIF, SWITCH/CASE/DEFAULT and ASSIGN/CALL/RETURN, but do not execute helper outputs or Leaf return propagation. The action switch call-value predicate remains partial after CALL. Exact comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.66 - read scalar and numeric descriptor comparisons

Twenty completed fluent/structured comparisons have twelve assertions each. Scalar boundary, substring, concatenation, regex and numeric fixtures compare descriptor nodes without checking evaluated helper results or hit-map equality; replace_substr additionally requires IF/ELSE nodes. The lifecycle min/max fixture ends after its first build assertion. Exact comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.65 - read fluent container helper comparisons and observation limits

Fluent/structured helper pairs use twelve assertions covering builds, slots, fallback, raw dependencies, unresolved helpers, node-list equality, readiness and selected nodes. They do not execute helper outputs or prove copy isolation or hit-map equality. Repeated ASSIGN terms still assert presence only. Seventeen complete helper comparisons plus the carried marker comparisons retain nineteen completed subtests; exact comprehension is in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.64 - read mutual marker nesting and bounded helper coverage

Deep mutual marker fixtures require at least three IF/SWITCH/CASE/DEFAULT helper hits and expected control nodes. Standalone lifecycle plans use six assertions; marker outer attached-branch lifecycle plans add explicit undef slot shape. Same-family branch pairs retain node/hit equality but their code-output-labelled slot checks remain .2.10-owned. Six seven-tag loops retain 329 inner assertions; comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.63 - read outer-family selected-node checks and comparison limits

The carried eight-assertion lifecycle loop compares node lists; subsequent seven-assertion loops and eleven-assertion action tests only require selected control nodes in the marker descriptor. Neither this presence check nor slot equality establishes complete metadata or execution parity. Five seven-tag loops retain 252 inner assertions. Exact comprehension and .2.10 limits remain in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.62 - read switch outer-family comparisons and exact metadata limits

Same-family switch branch pairs compare canonical node/hit maps with thirteen action or nine lifecycle assertions; cross-family inline/marker outer switches omit hit-map equality and use twelve/eight. Five seven-tag loops retain 308 inner assertions. Code-output labels still observe uppercase slots under .2.10; the next lifecycle declaration is partial after I and LS. Comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.61 - read structured switch branch comparisons and preserve observation limits

Structured/list/attached switch branches compose nested multi-case switches and deep alternating if/switch markers. Ten completed test declarations and one partial action declaration compare uppercase slots with code-output labels; existing .2.10 owns meaningful observation repair. Six seven-tag loops retain 364 inner assertions without emitted-code or branch-execution claims. Canonical comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.60 - read multi-case switch composition and metadata coverage

Multi-case inline/marker switches compose beneath if/elseif and directly beneath outer switch branches. Exact helper-hit expectations remain descriptor metadata rather than executed branch counts. Six seven-tag loops use nine or seven assertions per tag; the next marker/marker lifecycle fixture remains partial. Canonical comprehension and the existing .2.10/.2.11 limitations remain in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.59 - read deep switch nesting and descriptor slot shape

Structured and attached if/elseif bodies compose under inline/marker outer switches and single/multiple-case inner switches. Independent selectors and undef-only branch values remain descriptor inputs. Four seven-tag loops each use nine inner assertions; explicit slot-shape checks remain narrower than generated-code proof. Canonical comprehension and the existing .2.10/.2.11 limitations remain in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.58 - read mixed switch and nested marker metadata

Marker outer plus nested marker switch expects two SWITCH/two ENDSWITCH hits; marker outer plus two inline switches expects three SWITCH/one ENDSWITCH. Nine seven-tag loops verify 476 inner assertions at three distinct plan lengths. Slot-shape labels make a narrower claim than code equivalence; .2.10 remains the latter repair owner. Canonical comprehension remains in conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.57 - read snapshot and bare-marker descriptor coverage

Bare-switch fixtures include ENDCASE twice; optional-semicolon fixtures omit it, so expected hit maps remain fixture-specific. Two paired seven-tag loops, one paired five-tag loop and three seven-tag loops separately verify 472 inner assertions. Snapshot descriptors do not prove copy isolation, and absent-slot comparisons do not prove generated-code equality. Canonical comprehension remains in conformance-perl-consumer-reading and the .2.10 observation-gap card.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.56 - read switch coverage and own vacuous code comparisons

The exact six-tag inline-switch test passes 48 assertions after a branch payload changes: both compared uppercase descriptor fields are absent. Captured generated handlers show different return expressions. ARRAY source chunks require a join or explicit parser_source_ref, not scalar dereference. Exact public probes and discarded bootstrap-wrapper setup error are documented in phase0-code-slot-equivalence-observation-gap; .2.10/.2.11 own bounded repairs after prerequisites.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.55 - read mixed branches and nested switch equivalence

Mixed branch carriers compare metadata; nested marker/inline switch pairs also compare code fields. Descriptor fixtures with unbound selectors and undef-only branches do not prove runtime branch selection. Eight seven-tag loops have448 inner assertions, separate from151 direct assertions including56 nested results. Canonical comprehension: conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.54 - read structured branch and lifecycle equivalence coverage

Branch fixtures establish code/metadata equality, not target execution. Inline-if comparisons remove marker-only ENDIF; LX switch hit counts include the separate action return. Two six-tag loops have96 inner assertions, counted separately from227 direct assertions including12 nested results. Canonical comprehension: conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.53 - read collection and branch lowering contracts

Collection/branch equivalence tests compare metadata and selected ICODE/ACODE/LXCODE fields, separately from executed push controls. Two bare-target push inputs retain inaccurate wrapped-target labels; .2.9 owns wording correction, with exact lowering in conformance-perl-consumer-reading. Static child-call precedence remains intact.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.52 - read entry and match helpers and diagnose invalid numeric fixture

Equal generated strings can both be invalid: the positive num_min fixture contains an extra input/expected parenthesis. Toolbox output plus independent compilation isolates it; a one-character-balanced input returns2. Reproduction and repair ownership: phase0-num-min-lowering-fixture / .2.8. Reading does not close repairs.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.51 - read capture boundaries and diagnose mark-copy clearing test gap

An absent target cannot prove deletion. Original mark_copy4/4 passes a deletion-no-op; observing a seeded-zero target makes that same mutation fail the intended assertion while pristine behavior passes. .2.7 owns tracked repair after prerequisites; recipe: conformance-perl-consumer-reading. Retained canonical ec10be6b proof and fresh diagnosis remain separate.

## 2026-09-21 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15 - admit approved conformance evidence capacity

Granted authorizes the exact fourteen controls and bounded before-reading implementation, with normal canonical CI. Admission consumes one of the conservative 99 allowance units; its required rollover consumes one of eight archive slots per collection. Model the actual remaining suffix and preserve all prior history, source, questions and repair scopes. Reproduction: docs/knowledge/conformance-evidence-capacity-admission.md. The director separately granted exact .15.1 checker-mirror correction after canonical failure;37 self-tests/50 registry cases and actual partition validation pass. Fresh canonical proof remains required.

## 2026-09-21

CONFORMANCE-SOURCE-READING.4.1: capacity proposal.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.50 - read ActionIR lazy-loading and capture lowering tests

Six EmitContext labels overstate lazy loading; .2.6 owns correction. Exact probes and partial lowering evidence: conformance-perl-consumer-reading.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.49 - read compiler owner paths and diagnose lazy-load test blind spot

Compiler projection ordering observes validation entry, not completion; lowering-string checks are not execution proof. Fresh cold probes confirm a MethodExpr test blind spot: its Deps marker precedes parsing. All seven assertions still pass after an inert fixture is required post-parse, while explicit before/after observations distinguish 0/0 from 0/1. Normal production loading is correct. CONFORMANCE-SOURCE-READING.2.5 owns repair after prerequisites; docs/knowledge/conformance-perl-consumer-reading.md#methodexpr-post-parse-deps-observation-gap preserves the exact reproduction.

## 2026-09-21 — CONFORMANCE-SOURCE-READING.1.48 - read public diagnostic propagation and handler lifecycle contracts

Public get_parser controls preserve scalar-slot identity and caller fields while refreshing requested spec/top identity, clearing stale source chunks in place and dropping the stale emitter before failed resolution. Real load, validation and injected setup/compile failures preserve specific summaries, source identity, owner stage and requested-top labels through the facades. Invoked generated handlers trap forced LinkedRE failures as runtime_handler errors with inner eval text; a subsequent successful inline invocation clears the error. Injected raw handlers instead throw through the runtime_parser boundary, which records top-rule/variant identity and rethrows; invalid ARRAY input records validate_input_ref with the targeted message. A BEGIN counter proves one source compilation during one handler construction and reuse across two calls. Invalid generated syntax yields a wrapper, suppresses construction warnings and publishes compile detail only when invoked. These direct invocation controls do not establish independently emitted-module behavior. The final compiler success-cleanup control has only its parser-construction assertion read; invocation and seven assertions remain. Retained proof checks complete sequential assertion sets against the pinned canonical log. Handler construction, trapped invocation failure and rethrown parser failure are separate evidence; one constructed wrapper is not an independently emitted module.

