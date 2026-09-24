# SESSION-STARTUP-READING: immutable pre-partition snapshot

Historical evidence only; do not edit or append. Current state is in docs/tasks/SESSION-STARTUP-READING.md.
Current AGENTS.md and ADR0123 supersede contrary historical reading or dependency instructions.

# SESSION-STARTUP-READING: Targeted Startup and Separate Reading Audit

## Metadata

- Tree ID: `SESSION-STARTUP-READING`
- Status: `active`
- Roadmap lane: `Targeted session continuity / separately tracked full-reading audit`
- Created: `2026-09-06`
- Last updated: `2026-09-24`
- Owner: repo-local workflow
- Reading baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`

## Goal

Use targeted startup to proceed to the director's bug reports under ADR0123. Preserve
the incomplete full-reading audit separately without making it a blanket prerequisite.
The September22 approval supersedes that condition wherever older task nodes mention
required source/book/policy reading; relevant policies and real technical dependencies
remain. Reading completion and runtime signoff remain distinct.

## Non-Goals

- Infer bug-report identities or silently close defects through a reading/policy checkpoint.
- Count file enumeration, truncated output, historical test results, or unread material as completed reading.
- Include the `rgx` submodule or its nested dependencies in this startup reading pass.

## Acceptance Criteria

- All three required-reading answers become Yes only after their remaining material has actually been read.
- The exact baseline, exclusions, completed ranges, remaining work, and next action survive in committed state.
- Any discovered defect or policy gap receives an owning leaf and evidence before remediation.
- Roadmaps, live continuity, and task index agree; public book changes accompany material public understanding.
- Each completed leaf follows `COMMIT.md`; ordinary repairs require task-specific reading under ADR0123.
  Director exception (2026-09-08): containment `.7.2-.7.4` may implement and verify ADR 0108/0109 capacity infrastructure before remaining reading; all parser/repair gates remain in force.

## Task Tree
- ID: `SESSION-STARTUP-READING`
  Status: `active`
  Goal: Recover the repair frontier with targeted reading and preserve the separate full-reading audit.
  Children: `SESSION-STARTUP-READING.1`, `SESSION-STARTUP-READING.2`, `SESSION-STARTUP-READING.3`, `SESSION-STARTUP-READING.4`, `SESSION-STARTUP-READING.5`, `SESSION-STARTUP-READING.6`, `SESSION-STARTUP-READING.7`, `SESSION-STARTUP-READING.8`, `SESSION-STARTUP-READING.9`, `SESSION-STARTUP-READING.10`, `SESSION-STARTUP-READING.11`, `SESSION-STARTUP-READING.12`, `SESSION-STARTUP-READING.13`, `SESSION-STARTUP-READING.14`, `SESSION-STARTUP-READING.15`, `SESSION-STARTUP-READING.16`, `SESSION-STARTUP-READING.17`, `SESSION-STARTUP-READING.18`, `SESSION-STARTUP-READING.19`, `SESSION-STARTUP-READING.20`, `SESSION-STARTUP-READING.21`, `SESSION-STARTUP-READING.22`, `SESSION-STARTUP-READING.23`, `SESSION-STARTUP-READING.24`, `SESSION-STARTUP-READING.25`, `SESSION-STARTUP-READING.26`, `SESSION-STARTUP-READING.27`, `SESSION-STARTUP-READING.28`, `SESSION-STARTUP-READING.29`, `SESSION-STARTUP-READING.30`, `SESSION-STARTUP-READING.31`, `SESSION-STARTUP-READING.32`, `SESSION-STARTUP-READING.33`, `SESSION-STARTUP-READING.34`, `SESSION-STARTUP-READING.35`, `SESSION-STARTUP-READING.36`, `SESSION-STARTUP-READING.37`, `SESSION-STARTUP-READING.38`, `SESSION-STARTUP-READING.39`, `SESSION-STARTUP-READING.40`, `SESSION-STARTUP-READING.41`, `SESSION-STARTUP-READING.42`, `SESSION-STARTUP-READING.43`, `SESSION-STARTUP-READING.44`, `SESSION-STARTUP-READING.45`, `SESSION-STARTUP-READING.46`, `SESSION-STARTUP-READING.47`, `SESSION-STARTUP-READING.49`, `SESSION-STARTUP-READING.50`, `SESSION-STARTUP-READING.51`, `SESSION-STARTUP-READING.52`, `SESSION-STARTUP-READING.53`, `SESSION-STARTUP-READING.54`, `SESSION-STARTUP-READING.55`, `SESSION-STARTUP-READING.56`, `SESSION-STARTUP-READING.57`, `SESSION-STARTUP-READING.58`, `SESSION-STARTUP-READING.59`, `SESSION-STARTUP-READING.60`, `SESSION-STARTUP-READING.61`, `SESSION-STARTUP-READING.62`, `SESSION-STARTUP-READING.63`, `SESSION-STARTUP-READING.64`, `SESSION-STARTUP-READING.65`, `SESSION-STARTUP-READING.66`, `SESSION-STARTUP-READING.67`, `SESSION-STARTUP-READING.68`, `SESSION-STARTUP-READING.69`, `SESSION-STARTUP-READING.70`, `SESSION-STARTUP-READING.71`, `SESSION-STARTUP-READING.72`, `SESSION-STARTUP-READING.73`, `SESSION-STARTUP-READING.74`, `SESSION-STARTUP-READING.75`, `SESSION-STARTUP-READING.76`, `SESSION-STARTUP-READING.77`, `SESSION-STARTUP-READING.78`, `SESSION-STARTUP-READING.79`, `SESSION-STARTUP-READING.80`, `SESSION-STARTUP-READING.81`, `SESSION-STARTUP-READING.82`, `SESSION-STARTUP-READING.83`, `SESSION-STARTUP-READING.84`, `SESSION-STARTUP-READING.85`, `SESSION-STARTUP-READING.86`, `SESSION-STARTUP-READING.87`, `SESSION-STARTUP-READING.88`, `SESSION-STARTUP-READING.89`
## Current Frontier

ADR0123 replaces the blanket full-reading prerequisite with targeted startup. Prior
reading and repairs remain recorded below; conformance .1.90 is the next separate
audit range, not the default repair frontier.

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SESSION-STARTUP-READING.89` | `pending` | Indexed-read .88 is verified; finish containment .16, then repair confirmed Perl read mutation before .51. |

The audit withdraws the unsupported precedence question. Helper validation `.86.4.3` and
statement splitting `.86.4.6` plus quoted-subject validation `.86.4.7` are verified. Public recomposition verifies grouped repair `.86.4.8.2` and fresh generated Trace bootstrap `.86.4.4.2.1`; `.86.4.4.2.2` closes the measured helper scope. Line-ending `.86.5.1`, same-line `.86.5.2` and regex-slot metadata `.86.5.3` are verified; canonical `.86.3` closes the bounded parent; compact hash-key `.50` is verified; indexed-read `.88` is verified; containment `.16` precedes confirmed Perl read-purity repair `.89`, then `.51`.
Independent helper gaps are owned by `.87.1/.87.2`; no regex-type feature is admitted.

## Reading LedgerAll line ranges below refer to the **reading baseline**, not later shifted working-file line numbers. Files
modified by this checkpoint must also be reviewed in the final diff. Unlisted source files and unlisted ranges
remain unread; running a command that prints a file does not establish comprehension if its output was truncated.
| Required surface | Fully read and understood? | Completed at checkpoint | Remaining |
| --- | --- | --- | --- |
| Roadmap | **Yes** | `ROADMAP.md` 1–2564; `ROADMAP_V2.md` 1–1585. `.2` read 1341–1380, 1381–1420, 1421–1470, 1471–1530, and 1531–1585 without truncation and reviewed both current roadmap diffs. | Review later changes as they land; codebase/book alignment remains gated on their reading. |
| Codebase | **No** | All 89 baseline Perl entries physically read; `.31` preserves forward coverage. Perl reading is complete; Rust reading is complete: all 412 baseline paths / 3,533,382 bytes; `.3.3.67` closes exact coverage, current deltas and durable repair/Knowledge reconciliation. Dart closes under ADR0114; Julia closes 95 entries/75984 lines/2693170 bytes under ADR0117 with 52 committed reading groups and independent audit. | All other first-party inputs not explicitly listed as read; final cross-lane delta reconciliation. |
| mdBook | **Yes — physical source reading** | All 50 tracked book files / 1,956,582 bytes, including configuration and SUMMARY, are fully read at baseline; .3.2.42 preserves coverage, and c8759242 reviews/renders the approved parked-coverage delta. | Formal roadmap/codebase alignment, current deltas, and rendered review remain .4-owned; .41 owns additional verified repairs. |
The exact tracked file population and object identities are recoverable without an independently maintained
manifest or an absolute checkout path:
```bash
git ls-tree -r --full-tree baeb984e36a94a15951cd23d4c52def5064cdaca
git ls-tree -r --name-only baeb984e36a94a15951cd23d4c52def5064cdaca -- docs/linkedspec-book/src
git show baeb984e36a94a15951cd23d4c52def5064cdaca:ROADMAP_V2.md | sed -n '1341,1400p'
```
The recursive tree command does not descend into the `rgx` gitlink. During `.3`, classify the whole first-party
inventory, including files outside the obvious language directories; a language-directory census alone is not
complete codebase coverage. Generated source and fixtures are not silently excluded by a file-extension filter.
After a later commit, use `git diff --name-only` against this baseline to identify changed reading inputs; review
the changed portions as well as remaining baseline text. Immutable historical task parts use their indexed
retrieval contract rather than an indiscriminate chronology scan.
## Decisions
- 2026-09-22: Director approves targeted reading and fast ramp-up. ADR0123 supersedes the blanket full-reading prerequisite; .85 identifies the three reports before repair selection. No audit range or defect is closed.
- `2026-09-13` .3.7.0: Freeze 21 complete supporting groups under existing capacity; exact prior startup Scope records grant no supporting-file reading credit. Continue authorized read-only work while reusing compatible dependencies.
- `2026-09-11`: .3.5.0 uses a separate bounded Julia member because the 572-line minimum plan exceeds startup member headroom. All 52 scopes are fixed before reading; no limit increase or source-reading credit. Future history capacity belongs to JULIA-STARTUP-READING.4.
- `2026-09-06`: The director explicitly excluded `rgx` from this reading pass; the exclusion includes its nested
  dependencies and does not remove first-party Rust code or tests from scope.
- `2026-09-06`: After being asked to choose between a reading checkpoint and keeping every file unchanged, the
  director authorized proceeding and delegated the choice. This permits the narrow startup-tracking commit
  before full reading, resolving the session's no-document-edits prerequisite for startup tracking only.
  Implementation and unrelated documentation changes remain gated.
- `2026-09-06`: Keep detailed progress here and a short pointer in layer A; preserve the existing implementation
  destination. The checkpoint does not alter repository doctrine or make reading a substitute for production work.
- `2026-09-08`: DBINP authoring discussion is proposed under `PARSER-AUTHORING-APIS`; approved format coverage remains parked under its existing tree. Preserve the required LinkedSpec/RGX/PGEN dependency build chain; generated dependency state alone is not a blocker.
## Open Questions
- None requiring director input. `.6` resolved the liveness discrepancy as a real false-dead defect; `.7` owns
  repair after required reading. Do not use `--recover` or `--purge-failed` while that boundary remains unfixed.
## Blockers
- None. At activation, Git was clean and no background job was pending. Required reading is unfinished work,
  not a test failure or an external blocker.
- `.7` blocks managed recovery/purge and later mutation-workspace setup until denied/unknown liveness is safe.
  Read-only reading can continue; no source repair is authorized by the narrow startup-tracking exception.
- `.8` owns confirmed stale bootstrap diagnostic state after `.7`; no primary parser corruption was demonstrated.
- `.9` owns confirmed attached-tail regex truncation and public handler-compile failure; repair follows `.8`.
- `.10` owns confirmed unbound AND_BCODE package-variable inputs; repair follows `.9` without inventing self-match semantics.
- `.11.1`–`.11.3` own diagnostic context/occurrence/rule-attribution repairs after `.10`; invalid inputs still reject.
- `.12` owns confirmed native bare/explicit edge-order drift after `.11`; metadata and execution currently disagree.
- `.16.1`/`.16.2` own confirmed emptiness expression drift and literal/host-slot leakage after `.15`.
- `.17`–`.30` own the additional confirmed runtime/tool/public/evidence gaps preserved in intake `.31`;
  existing lifecycle debt remains under its original card and gains `.27` implementation ownership.
- `.80.1-.4` own correct dependency build reuse; `.81.1/.81.2` own newer-OS startup diagnosis and conditional repair.
  Both retain startup .3/.4/.5 prerequisites; intake .80.0 authorizes no source repair or OS mitigation.
## Verification Log

- 2026-09-24 .50: Core258, selected runtime226, keyword1, final compact/emitted2, Perl book26 and exact public13 pass. Final CLI a2058123 agrees with initial e8690ef3; checkpoints .50-hash-separator.json/.50-verification.json retain both and complete focused proof. No canonical run is claimed for this ordinary leaf.
- 2026-09-24 .86.3: Fresh public Rust replay passes56 cases:53 exact integer results and3 malformed rejections, including both published symbol/division examples. Rust production and carrier tests are byte-identical to19ba2e0d5, retaining254 core/404 selected runtime/15 emitted-mutation proof. Perl/spec/Dart sources match verified52408086a, retaining focused240/book103/Phase0 1033,120 exact checkpoint records, composed grammar72 and Dart20/package502/storage25owners47packages/CLI66x2/corpus105. All Perl/Rust book fences remain exact; only reciprocal guide links change and the book renders. All .86 implementation children are done or explicitly superseded. Independent .27/.34/.54.1/.63/.87 and Dart .2.24/.2.25 remain owned; no full optional Dart gate or global defect-free claim. Landing requires successful tools/run_ci_local.sh on the exact staged candidate; its receipt and commit body record the final canonical result. Logs: .linkedspec-data/scratch/scanner-parent86-3/.
- 2026-09-24 .86.5.3: Focused checks pass 240 tests across 11 files; six exact book sources pass 103 assertions. Clean4ca4f745e finishes 111 metadata groups and fails only new group4. Fourteen LF/CRLF layouts preserve names/order, selectors, source, live/generated values and permanent grammar nodes; bare payloads remain exact. Typed/Unicode/comment/code/unsupported-tail controls and gap/slot/bare neutral checks pass; four grammar mirrors remain exact. Six slot-focused CLI grammar cases pass on Perl, Rust, Dart, Julia, PUC Lua and LuaJIT in both environments (72 case legs). The unchanged final-E projection defect has a permanent .63 regression and public qualification. Dart exact shipped-pattern recognition now preserves cursor/physical-line semantics, captures, suffixes and three carriers. Focused Dart20 and independent remaining stages pass502 tests/storage25owners47packages/CLI66x2/corpus105. Complete Dart gate attempts remain failed at existing .2.24/.2.25 formatter/SDK blockers; six unrelated formatter edits are restored exactly, without suppression. The72 grammar legs compose retained Perl/Rust passes and fresh Dart/Julia/PUC/LuaJIT passes; neither stopped full-driver attempt is reported green. All 120 final checkpoint records match the preceding candidate after the last bare-block shield; the first five book sources are unchanged. Full Phase0 passes 1033/1033 at frozen diff a80c914626100ac1fbe7c7448a42547574d7adfbc7ec0de8da4aadef88394a32. Book rendering and syntax pass. .86.5 closes its bounded implementation; .86.3 canonical remains pending. Files=1, Tests=1033, 2099 wallclock secs ( 0.41 usr  0.08 sys + 1043.99 cusr 137.50 csys = 1181.98 CPU) Logs: .linkedspec-data/scratch/regex-slots86-5-3/.
- 2026-09-24 .86.5.2.2: Recognize the balanced slash-call end before an outer brace and following members, retaining full-source regex-first trial selection. Focused9 files/207, exact book84 and rendering pass. Clean fb955602e finishes14 groups and fails only new group14. Exactly8 bare-slash rows in the30-case intake now match named controls; other22 are exact. Original12/helper13+syntax/grouped22/numeric12/multiline5 stay exact. Context15 changes only intended next_member/quoted-slash public outcomes; private fragment scans do not select the full-source interpretation. Slot5 stays exact and required .86.5.3-owned. Full Phase0 passes1033/1033 at frozen diff86881406bf815024ee8c7cf00482ce547ebae315a6165fd350cfe9d258b05a92. No canonical or push claim. Files=1, Tests=1033, 1394 wallclock secs ( 0.42 usr  0.09 sys + 1081.47 cusr 110.13 csys = 1192.11 CPU) Logs: .linkedspec-data/scratch/slash-members86-5-2/.
- 2026-09-24 .86.5.2.1: Public/Get and emitted-source diagnosis proves omitted E: old I/regex/E returns7 for x and y despite E{return(42)}; generated source contains only I. Corrected explicit edge returns8 for x and undef/no-error for y. Focused5 files/31 pass; five exact book sources/84 pass. Isolated old-fixture mutation finishes7 groups and fails only book group7. First four sources are unchanged; production matches917b4a42a. Book render and permanent checkpoint pass. .27 retains lifecycle repair; .86.5.2.2 is next; no new Phase0/canonical claim. Logs: .linkedspec-data/scratch/slash-members86-5-2/.
- 2026-09-24 .86.5.1: Outer structural depth recognizes only a complete bare slash call followed by line-ending braces; shared MethodExpr precedence and source bytes stay unchanged. Accepted full-source regex interpretations win; only a failed source with a final-call candidate retries. Only the selected attempt publishes diagnostics. Focused9 files/206 and five exact book sources/82 assertions pass. Clean fe516141b baseline completes13 groups and fails only new groups12/13. Fixed15 contexts and original12 change only their bare/spaced EOF outcomes to7; helper13+syntax/grouped22/numeric12 remain exact. Full Phase0 passes1033/1033; frozen source/test diff SHA25691821cd09b9991ce975862b4c83a62b0c899badb8c02fd62a8ed9dd8f89188d5. Syntax and final book render pass. Same-line members stay .86.5.2; numeric callable/grouping are .87.3/.87.4-owned. Phase0: Files=1, Tests=1033, 1528 wallclock secs ( 0.51 usr  0.11 sys + 1129.24 cusr 129.84 csys = 1259.70 CPU). Logs: .linkedspec-data/scratch/slash-eof86-5/.
- 2026-09-24 .86.4.4.2.2: All59 fixed public outcomes/readiness/error stages and the complete syntax record reconcile. Exact code/test/four-source identities reuse9f81d3162 focused173/book66 and mutation proof; checkpoint syntax/rendering and normal memory/history/Knowledge/doctrine checks govern landing. Logs: .linkedspec-data/scratch/helper-pattern86-4-4-2-2/. Engineering notes roll exact114 lines/28181 bytes to segment4969; all prior segment rows/bytes remain unchanged. Trim only the resulting mutable-root trailing blank separator.
- 2026-09-24 .86.4.4.2.1: Fresh generated baseline fails four book cases; explicit Trace import passes book66 and focused173 across9 files in163 seconds. Two isolated book mutations reject only intended assertions; syntax/contract, book/memory/Knowledge/history and normal doctrines govern landing. Logs: .linkedspec-data/scratch/helper-pattern86-4-4-2/.
- 2026-09-24 .86.4.8.2: Focused187, exact book21, baseline RED only group10 and final Phase0 1033/1033 (Files=1, Tests=1033, 1423 wallclock secs ( 0.44 usr  0.10 sys + 1086.49 cusr 125.81 csys = 1212.84 CPU)) pass; frozen diff unchanged. Book/memory/Knowledge/history/doctrines govern landing; scratch .linkedspec-data/scratch/helper-pattern86-4-8-2/.
- 2026-09-24 .86.4.8.1: Exact12-case baseline/candidate source pairs reject lookahead despite prior22-case improvement. Archived patch reconstructs; production/tests and all three complete book sources remain exact to f3f9fc74. Restored consumer9 passes; tracked replay/book render/memory/history and normal doctrine hooks govern intake only. No full Phase0 or canonical claim.
- 2026-09-23 — .86.4.2.1: exact accepted/candidate public and lowering comparison proves two successful-value changes; rejected patch reconstructs four files exactly; restored source/test identity and AST23/23 pass; focused governance/book proof before commit.
- 2026-09-23 — .86.4.1: public Get/lowering and whole-versus-line scanner probes reproduce distinct owners; supplied policy hashes unchanged; focused memory/history/Knowledge/book/doctrine checks before commit.
- 2026-09-22 .83.2.2: PASS: all 37 authored cases on six native runtimes (222 case outcomes), 21 token-spelling round trips per route and 16 same-engine post-rejection reuse checks per route. Perl has 44 top-level/168 nested assertions including descriptor readiness and the independent catch-all mutation; Rust one complete contract test, Dart 38 tests, Julia 91 assertions, and both Lua routes pass. Three initial Dart EOF-comment failures become green with a portable grammar branch, without changing authored expectations. Historical Lispish quoted-LF fixtures pass 3/3 on Perl, and the new book command returns its exact documented value. Formatting, Dart analysis, shell syntax, book, Knowledge/memory/history/diff and doctrine checks govern landing. The public grammar/recurring-CI boundary requires the exact staged canonical receipt; native file delivery and final report admission remain separate. Logs: .linkedspec-data/scratch/sexpr-document-v1/.
- 2026-09-22 .45.3: Compiler correction 10893fb71 passed all core/native regressions and the complete Rust component gate; carrier checkpoint 30c1ddeea passed all four source/AST/loader/semantic/generated route tests. This documentation-only parent closeout retains those exact proofs. Canonical acceptance requires tools/run_ci_local.sh to finish successfully on the exact staged candidate and produce the receipt checked by the normal commit hook; the resulting commit and promoted receipt are the durable gate evidence. Other parser defects and document grammar delivery remain separately owned.
- 2026-09-22 .45.2: Four focused route tests PASS: eight malformed sources yield 32 ordinary/traced source/reconstructed-AST rejections, 16 path/name-loader rejections and eight failed semantic snapshots with no compiled authority or plan. Valid path/name loads, reconstructed compiled state and generated-plan execution return 42; a freshly compiled emitted module verifies direct/traced 42 and compatibility [42]. Production code is unchanged from 10893fb71; its complete Rust compatibility proof remains applicable. Rust formatting, book, Knowledge/memory/history/public/diff checks and normal doctrines govern landing. Raw log: .linkedspec-data/scratch/compiler-rejection45/routes-green.log.
- 2026-09-22 .45.1: PASS: 12 native invalid cases change from warning/compile:ok/invoke:ok to exit 1/compile:error with no input or invocation phase; three valid controls retain 42 and empty stderr. Four persistent core rejection groups are RED before repair; all five groups GREEN afterward (15 malformed contexts and 11 retained valid blocks). Complete Rust component gate PASS: 228 core and 574 runtime tests, including all 197 end-to-end tests, 21 shipped grammars and 105 oracle cases; primary CLI conformance is 66/66 in each default/POSIX environment, and managed-storage checks pass. The committed quoted-LF manifest passes all three cases on the rebuilt primary binary. Callable contract, book, Knowledge/memory/history/public/diff and registered doctrine checks govern focused landing. Separate carrier proof/canonical closeout and parser-cause repairs remain open.
- 2026-09-22 .83.1: ADR0124/37 independent cases and 136 Perl assertions establish the planned contract; four Rust prototype boundaries pass after canonical comparison spelling. Existing .45 warning/drop reproduces with exit 0/null and receives three bounded repair children before delivery. No production grammar or cross-backend admission claimed.
- 2026-09-22 .83.2.1: PASS: exact clean-HEAD grammar fails all three final shared fixtures; fixed Phase0 smoke passes 9 assertions, and Perl/Rust/Dart/Julia/PUC Lua/LuaJIT pass 3 fixtures in both default and POSIX environments (36 command legs; 19 aggregate forms plus two isolated quote contexts). Rust passes 26 file values through one engine and all 18 existing verification groups, including all eight byte-exact report inputs/expectations. Descriptor readiness remains 9/9 with 0 blockers; corpus copy is exact and retains its x/y value. Eight root/child quote controls explain and correct the initial invalid root-capture probes without a runtime change. Book, direct public checks, syntax, memory/history/Knowledge/diff and normal nine-doctrine hooks govern focused landing; no canonical run or push.
- 2026-09-22 .85: Exact report register/snapshot recovered; fresh Rust replay confirms four controls and four LF failures, all real exits0/stderr empty. No missing-user-input blocker remains.
- 2026-09-22 .84: Targeted-startup adoption preserves prior reading evidence and source; selected continuity checks govern landing.
- `2026-09-13` .3.7.0: Supporting-source inventory .3.7.0 reconciles all 158 baseline-identical files under conf, tablescript, noncore, specs and ebnf: 25,612 LF delimiters, 25,613 fragments and 964,256 bytes. SUPPORTING-SOURCE-READING owns 21 pending groups/174 disjoint ranges; independent Git, current-delta and published-task reconstruction pass with every group within 1,500 fragments /65,536 bytes. No exact earlier startup Scope coverage is credited; physical reading is 0/21. The resulting decomposition uses existing controls, preserves all repairs and changes no source. Lua reading remains closed under ADR0119; next supporting .1.1 reads configuration. No dependency compilation or canonical gate is run; full codebase/book/policy prerequisites and later verification remain.
- `2026-09-12` .3.6.0: Lua decomposition freezes 51 pending reading children across 99 baseline-identical files: 71,268 physical lines, 71,269 fragments and 2,732,450 bytes. The independent 149-range audit includes two UTF-8-safe byte windows for an oversized generated MCP line. No source comprehension is claimed. The current plan fits unchanged limits; comparable Julia reading growth exceeds remaining Knowledge capacity. LUA-STARTUP-READING.4.1 prepares a coherent capacity disposition before reading. All previous reading, repairs and verification requirements remain intact.
- `2026-09-11` .3.5.0: Startup .3.5.0 freezes Julia reading into 52 owned children / 146 ranges across all 95 baseline-identical files: 75,984 lines / 2,693,170 bytes. Independent reconstruction verifies every byte and range digest; physical Julia reading remains 0/52. A separate bounded JULIA-STARTUP-READING member fits existing controls; .4 owns future history/capacity pressure. Dart reading is closed under ADR0114, with all 69 repairs and its failed gate retained. Next Julia .1.1 reads the manifests and first README range.
- `2026-09-08` `.3.3.67`: Exact scope and independent committed-child/mode/delta/repair/Knowledge continuity audits PASS. All 66 reading children and 141 touched fact paths are durable; 34 post-Perl repair owners retain 90 pending nodes / 73 pending leaves. Final receipt-bound canonical CI governs parent landing; outcome and exact log identity are retained in the commit. Next containment .7 precedes Dart ownership/reading.

- `2026-09-08` `.3.3.66`: Four exact scope/baseline identities PASS. Managed neutral Unicode806/9/8/2, binding11/7/6/8, callable-signature3/9/7 and write5/7/11/16/3/3/8/105 PASS. Existing cards distinguish native/generated-helper execution, strict-loader compilation, emitted-text inspection and the one independently compiled write fixture; no new native run is inferred. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.65`: Five exact scope/baseline identities PASS. Typed neutral 3/7/6/3, 92+7 and14/0/231; Unicode17 five-module byte comparison with12 fixtures; lifecycle9/4/6/3 and14 mutations PASS. Four existing Knowledge cards distinguish runtime/generated-helper execution, emitted-text inspection, catalogs and historical test counts; no new runtime/carrier run is inferred. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.64`: Both scope/baseline identities PASS; staged neutral governance PASS at 9 rollout legs / 123 base / 129 public mutations. Recursive/carrier Knowledge distinguishes historical admission from the completed .61 native run and retains .73–.75/.78. Standalone prefix includes native execution helpers; no emitted compilation is inferred from that prefix. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.63`: Exact three-scope identities PASS; native-resolution neutral 14/9/4 and staged neutral 9 legs / 123 base / 129 public mutations PASS. Three Knowledge cards reconcile child status, loader fixture types and current-depth policy/panic proof while preserving .71/.73–.78 repair ownership. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.62`: Exact three-scope identities reconcile admission, source-boundary aliases and emitter prefix; neutral semantic proof and pinned routing/history child-status controls pass. The preceding .61 canonical result is retained with exact log/receipt identity; no optional-gate rerun is inferred. Actual pending .79 owns the reproduced routing signal-status defect. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.61`: Four exact scopes PASS (1,461 lines / 52,200 bytes); semantic governance PASS 6/20/128 with rollout 9/0 and admission 6/0. Independent emitted assertions are precisely qualified. Mandatory engineering-notes rollover and exact finite capacity admission require staged canonical proof; commit body/receipt retain the completed run. Knowledge, memory, histories, diff and doctrine hooks govern canonical landing.
- `2026-09-08` `.3.3.60`: Seven exact scopes PASS (1,472 lines / 49,181 bytes). Managed cursor contract PASS at 8 complete / 0 pending, 6 runtime legs and 60 mutations. Reading facts preserve named-selector repair .57 and historical/current cursor boundaries. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.59`: Five exact scopes PASS (1,487 lines / 48,937 bytes). Managed root contract check PASS at 7 complete / 0 pending and 54 mutations. Historical/current Knowledge reconciliation preserves source-inspection versus independently compiled emitted proof. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.58`: Three scope/baseline identities PASS (1,471 lines / 49,296 bytes). Both exact-source manifest construction probes exit 0; relative controls resolve the same runtime crate, original Drop removes both workspaces and managed scratch is removed. Nine absolute writers and five relative source controls are inventoried; actual repair .78 follows required reading. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.57`: Four exact scopes and progressive/punctuation/recognition proof-boundary reconciliation pass; the known contains arity exception is explicit. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.56`: Four exact scopes and MCP/progressive test-boundary reconciliation pass; canonical completion records resolve dated admission wording. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.55`: Two exact scopes and mutation/MCP assertion-boundary reconciliation pass; known .58/.59 and .77 repair limits remain explicit. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.54`: Three exact scopes, both explicit emitted status guards and the bounded codeblock-row skip are verified from unchanged source. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.53`: Two exact scopes, integration EOF and test-route/Knowledge reconciliation pass. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.52`: Exact range/source identity and retained test-boundary comprehension pass. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.51`: Exact scopes/source pins and six source-extracted classifier controls pass their expected outcomes; managed scratch is removed. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.50`: Six exact baseline scopes and canonical Knowledge/test-boundary reconciliation pass. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.49`: 202 exact scopes, one explicit empty, 67 decoded JSON files, 68 manifest-owned cases and unchanged grammar mirror pass. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.48`: Exact range and complete mirror identity pass; unchanged .44 Unicode proof applies. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.47`: Four exact scopes, fixture JSON and unchanged canonical mirrors pass; .44 Unicode proof remains applicable. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.46`: Four exact scopes, JSON decode and unchanged mirror identities pass; .44 Unicode proof remains applicable. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.45`: exact range and complete canonical mirror identity pass; unchanged .44 Unicode proof applies. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.44`: four exact baseline scopes and JSON decode pass; all grammar mirrors match and the Unicode contract passes. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.43`: exact 53-scope baseline audit, 18 JSON decodes/105 unique manifest cases, twelve paired Perl Get observations and exact callee lowering; Knowledge, memory, histories, diff and doctrine hooks govern focused landing.

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Exact HEAD, empty activation Git status, `.githooks` configured, scoped read coverage | PASS; all remaining reading stays explicit. |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Memory architecture, doctrine driver, history pressure, diff/scope review | Memory and both history limits PASS; eight doctrines PASS initially. README routing rejected two review edits absent from the staged snapshot. |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Restage reviewed files; `bash scripts/check_readme_stability.sh` | PASS: 20 surfaces, 62 routes, 32/32 mutations; all nine doctrine checks now pass. Final exact-candidate proof also runs in pre-commit. |
| `2026-09-06` | `SESSION-STARTUP-READING.2` | Untruncated ranges, baseline diffs, current direction, staged scope | PASS; roadmap Yes, codebase/book No. |
| `2026-09-06` | `SESSION-STARTUP-READING.2` | Memory, nine doctrines, Knowledge Map, both history-pressure checks, staged diff | PASS; all nine doctrines complete successfully, both histories below rollover, no trailing-space errors. Final evidence edits are checked again by pre-commit. |
| `2026-09-06` | `SESSION-STARTUP-READING.6` | Managed 45-second process; paired restricted/permitted run-list and kill-zero probes; exact source trace; final wrapper/census | CONFIRMED DEFECT; EPERM was false-dead. Probe exits 0; no recovery used; zero leftovers. Repair `.7` is required, not claimed complete. |
| `2026-09-06` | `SESSION-STARTUP-READING.6` | Focused memory/history/diff plus required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `03d692c1`; diagnostic checkpoint complete, repair remains pending. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Exact baseline object/class census, binary/decoded inventory, whole-source delta, bounded first-child accounting | PASS; 2,547 disjoint entries and no source/test/tool/book delta; inventory is not reading credit. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Managed Perl facade/phase0 syntax; both history-pressure checks; diff review | PASS; both syntax checks OK, change-history warns below rollover, engineering notes OK. Required pre-commit supplies final doctrine/Knowledge proof. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `942c6138`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.1` | Exact five-file full reading, baseline identity, existing owner/trivia Knowledge, managed facade/phase0 syntax | PASS; 1,430 lines / 56,706 bytes covered, no production delta. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.1` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `c0eb1acf`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.2` | Independent byte-interval coverage/budget audit and baseline Perl diff | PASS: 52 leaves, 84 exact paths, 2,076,984 bytes, no gaps/overlaps/source delta. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.2` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `094e05bc`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.3` | Five-file full reading/baseline identity; existing Knowledge; managed comparison/public-error controls | PASS reading; CONFIRMED stale diagnostic defect, repair `.8` pending. All probe jobs completed. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.3` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `27fd160f`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.4` | Four exact core chunks/baseline identity; existing Knowledge; scanner/helper/descriptor/public controls | PASS reading; CONFIRMED regex-tail defect, repair `.9` pending; all probes consumed. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.4` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `4f311a9e`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.5` | Exact full reading/baseline identity; required rollover; independent suffix/count/SHA-256 proof | PASS; final canonical proof required before landing ADR 0102 capacity step. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.5` | Exact default canonical gate; staged receipt; all nine commit doctrines; promoted receipt; empty brief/clean status | PASS at `6c1234cc`; Phase 0 1,032/1,032 and primary CLI 66/66 twice. No pending job. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.6` | Four exact compiler chunks/baseline identity; Knowledge reconciliation; prior receipt and dated sample review; exact two-file cleanup | PASS reading/evidence; final focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.6` | Required Knowledge/all nine doctrines; post-commit pointer; empty brief/clean status; derived-map review | PASS at `f864f881`; 944 facts / 7,996 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.7` | Four suffix chunks/full-file identity; existing owner reconciliation; source-level Knowledge card | PASS reading; final focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.7` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `dc7f5f09`; 945 facts / 8,003 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.8` | Three complete-file reading chunks; baseline identity; isolated HandlerIR differential; public descriptor/source control; historical Knowledge reconciliation | PASS reading/probes; final focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.8` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `e4b1f296`; 946 facts / 8,008 keys. Literal old metadata pipes are corrected in `.3.2.9`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.9` | Six prefix chunks/baseline identity; direct context/formatter and callback/Get controls; corrected open-block reverify | PASS reading/probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.9` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `96a1c242`; 947 facts / 8,013 keys. Retrieval commands and evidence render correctly. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.10` | Three suffix chunks/full-file identity; existing edge/slash/gap/diagnostic reconciliation | PASS reading; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.10` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status | PASS at `ff6c228c`; derived-map count unchanged at 947 facts / 8,013 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.11` | Five complete-file chunks/baseline identity; OR spelling and AND public controls; direct RuleIR normalization | PASS reading/probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.11` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `3ab399d0`; 948 facts / 8,018 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.12` | Seven prefix chunks/full-file identity; exact registry extraction and existing Knowledge reconciliation | PASS reading/card reverify; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.12` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `5e2cf756`; 948 facts / 8,018 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.13` | Six suffix chunks/full-file identity; public AND/OR equivalent-target controls; descriptor/source and direct rewrite | PASS reading/retained probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.13` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `a7d17e6f`; 949 facts / 8,022 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.14` | Seven prefix chunks/full-file identity; direct builders; public selected-I literal/source/package controls; historical return reverify | PASS reading/probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.14` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `e421887d`; 950 facts / 8,026 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.15` | Exact three-file completion/identity; bounded REP literal/source/package controls; diagnostic JSON projection | PASS reading/probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.15` | Required Knowledge/all nine doctrines; post-pointer; zero-byte brief/clean status; derived-map review | PASS at `762bef64`; 950 facts / 8,028 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.16` | Exact prefix identity/reading; AST and public offset controls; two parser suites | PASS 30 top-level tests and retained probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.16` | Required Knowledge/all nine doctrines; post-pointer; empty brief/clean status; derived-map review | PASS at `9a881160`; 951 facts / 8,032 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.17` | Exact four-file baseline identity/ranges; Knowledge owner reconciliation | PASS reading; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.17` | Required Knowledge/all nine doctrines; post-pointer; empty brief/clean status; derived-map review | PASS at `34958c8f`; 951 facts / 8,036 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.18` | Exact prefix identity/ranges; catalog count/detachment; historical status reconciliation | PASS reading/catalog; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.19` | Exact suffix reading/identity; fourteen-group source extraction; owner reconciliation | PASS reading/structure; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.20` | Exact prefix reading/identity; candidate-context probe; compact trace suite | PASS probe and one file/four top-level tests; focused continuity/staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.21` | Exact reading/identity; pipeline trace; public emptiness/host-seed controls; required rollover/hash | PASS five trace tests and bounded controls; ADR 0103 exact staged canonical proof required before landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.21` | Canonical process-locality failure; same no-op initialization control in restricted/permitted execution; unchanged full oracle outside harness | Restricted control exits 71; permitted control and full six-family oracle PASS. Exact full canonical rerun remains required; no receipt from failed attempt. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.21` | Exact full canonical rerun, receipt, all nine doctrines, post-commit pointer and brief/status | PASS at `17d3e919`; mandatory chain, both CLI 66/66, Phase 0 1,032; optional flags unset/skipped. No pending job. |
| `2026-09-06` | `SESSION-STARTUP-READING.31` | Source/card/path and unique-ID audit; exact staged scope; Knowledge/memory/all nine doctrines; both history checks; diff review | PASS: 89 unchanged Perl files, 38 new unique IDs, 33 queued checkpoints pending, 14 new cards; no public/source changes. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.22` | Exact full-file reading/identity; authored-value/legacy arity controls; Knowledge reconciliation; focused continuity | PASS bounded controls and baseline identity; final staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.23` | Exact prefix/full-file identity; existing Knowledge milestone reconciliation; managed MethodLowering trace suite; focused continuity | PASS four top-level tests and prefix identity; required staged commit gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.24` | Exact range/full-file identity; signature/retirement Knowledge; variadic function suite; public mixed-path read; focused continuity | PASS 66 tests and error-free one result; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.25` | Exact range/full-file identity; function/callable Knowledge; eight Get/source/descriptor controls; focused continuity | PASS diagnostic controls; caller-local shadowing reproduced and repair .32 owned; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.26` | Exact range/full-file identity; block/receiver/traversal Knowledge; AST parser suite; three public root controls; focused continuity | PASS 23 tests and hash/array/scalar controls; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.27` | Exact range/full-file identity; AST/fallback/retirement/numeric Knowledge; scalar numeric suite; four public descriptors; focused continuity | PASS nine tests and four expected diagnostic counts; known Unicode-digit repair remains open; required gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.28` | Exact range/full-file identity; constructor/collection/mutation Knowledge; three public controls; paired Perl/PUC tagged controls; focused continuity | PASS bounded controls; tagged/split divergence rooted and .33 review/repair owned; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.29` | Exact range/full-file identity; progressive and normalization Knowledge; managed 129-assertion carrier consumer and neutral 9/9 checker; focused continuity | PASS; private six-runtime closeout pointers reconciled; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.30` | Exact range/full-file identity; scanner/AST/trace Knowledge; managed five-test pipeline suite and seven-dispatcher census; focused continuity | PASS; four Knowledge boundaries reconciled and known lexical repair linked; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.31` | Exact range/full-file identity; legacy/bare-read/uniform Knowledge; five public Get controls and generated handler-first source; focused continuity | PASS; existing push precedence confirmed and three historical records reconciled; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.32` | Exact range/full-file identity; pipeline/staged/recognition Knowledge; managed 143-check staged consumer, two neutral checkers and language inventory; focused continuity | PASS bounded Perl/neutral proof; two authoring/inventory records reconciled; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.33` | Exact range/full-file identity; separator/trace Knowledge; four compact trace tests; twelve public newline/comment cases plus dumped-source repeats; focused continuity | PASS reading/trace controls; comment failures reproduced and owned by `.34.1`/`.34.2`; one new/three qualified cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.34` | Exact baseline ranges; binding/callable/codeblock/gap Knowledge; managed 134 callable/gap tests; neutral gap 9/0/63 and public 8/15/10/34; six boolean controls and emitted AST; focused continuity | PASS reading and existing focused suites; boolean-literal defect rooted and owned by `.35`; one new/three qualified cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.35` | Exact 32768-byte fragment/full-file baseline identity; MCP binding/admission Knowledge; managed generator, five binding tests, six frame controls, admission complete/141; focused continuity | PASS bounded fragment and focused proof; one Knowledge card reconciles current topology and response-layer examples. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.36` | Exact fragment/full-file identity; MCP/ADR/repair Knowledge; three embedded-neutral equality checks and repaired-field controls; ordered materializer/validator35/10/10/76; focused continuity | PASS bounded contract data and neutral proof; two records reconcile; historical ADR clarification task-owned under `.5`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.37` | Exact suffix/full-file identity; MCP plan/contract Knowledge; canonical bundle/header, neutral payload, four response and seven source digests; managed binding freshness; focused continuity | PASS embedded suffix and digest/freshness controls; one Knowledge card records payload versus recurring-proof boundaries. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.38` | Exact baseline ranges; MCP/numeric Knowledge; 31 MCP and nine numeric tests; neutral 55/18; six decoded then six paired decoded/stdio precedence controls; focused continuity | PASS reading and existing suites; documented precedence discrepancy rooted and owned by `.36`; one new/three updated cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.39` | Exact baseline ranges; plugin/progressive Knowledge and ADR 0080; managed 138 tests and neutral 9/9/116 plus public 6/12/10/60; public plugin and six ceiling controls; focused continuity | PASS reading and existing proof; resource/diagnostic enforcement gaps rooted and owned by `.37`; one new/four updated cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.40` | Exact baseline ranges; recognition authority/integration/neutral Knowledge; managed 59 tests and 138/250/58 at 9/9; six post-terminal controls; focused continuity | PASS reading and existing proof; obsolete snapshot restoration rooted and repair-owned by `.38`; one new/three updated cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.41` | Exact source baseline; 137 Perl tests; typed/semantic/diagnostic/logical neutral proof; eight value/four exit controls; required history rollover and exact-source proof; staged canonical boundary | PASS focused reading/probes; `.39`/`.40` own defects; ADR 0104 finite history capacity requires final staged canonical receipt before landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.42` | Exact source/book identities; 20 semantic tests; neutral semantic/generated proof; four input/direct, nine Get, and eight isolated factory controls; Knowledge and focused continuity; four inline-lifecycle and two descriptor controls | PASS reading and finite controls; physical mdBook Yes, codebase No; .41/.42/.43 own repairs without premature implementation. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.43` | Exact 982-line baseline and unchanged prior-proof inputs; retained 9/106/5 tests and neutral 6/20/128; four Knowledge reconciliations; exact consumed-spool cleanup; focused continuity | PASS scoped reading and retained proof; July milestones dated; codebase still No; no runtime changes. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.44` | Exact static-source/test identity; retained five-test proof; two exact plus two initial public failure controls; retained inline/descriptor evidence; standalone neutral 15/7/14; precise Knowledge and focused continuity | PASS scoped reading and controls; retained diagnostic versus fabricated explanation distinguished; .23/.41.6 refined without runtime changes. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.45` | Exact 700-line source and prior-proof identities; retained three-suite 18-test/typed 14/0/231 evidence; scoped Knowledge reconciliation; memory/Knowledge/doctrines/history and staged review | PASS reading and unchanged evidence; authority/value privacy and compatibility boundaries retained; no behavior change. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.46` | Exact 1,498-line baseline and unchanged staged inputs; retained 143 and 9/9/123 plus public proof; 24 native and four modeled lifetime controls; four Knowledge owners; focused continuity | PASS bounded reading/native controls; isolated recycling counterexample tracked as .44 with native non-reproduction explicit. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.47` | Five complete ranges and exact baseline; unchanged staged runtime/consumer/checker/contract identity; four Knowledge owners; focused continuity | PASS bounded reading and retained proof; legacy metadata/general authority boundary explicit; .44 remains owned. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.48` | Complete Trace/baseline; 20 direct/wrapped exception controls; three generated suites 11 tests; unchanged CLI proof; Knowledge and focused continuity | PASS focused reading and tests; .24 retained with direct/wrapper distinction and exact object-identity evidence. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.49` | Prior full first-range reading + exact identity; ADR0027 and full checker/consumer; offline five-module regeneration/12 fixtures; Perl52; focused continuity | PASS; current regeneration coverage corrected, generated/carrier proof scoped, no new physical credit. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.50` | Prior complete middle-range reading; exact baseline and unchanged inputs; retained regeneration/12 fixtures/Perl52; Knowledge status; focused continuity | PASS; generated semantics unchanged; physical book/formal alignment distinction corrected. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.51` | Complete prior final range + exact identity; evaluator/12 fixtures; unchanged regeneration/Perl52; dated pressure census; Knowledge and focused continuity | PASS; complete case-table comprehension accounted; no runtime or generated-data change. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.52` | Complete prior XID range + baseline; ADR0051/consumer seams; Unicode806/9/8/2; direct3224/17/2; gap9/0/63/public8/15/10/34; focused continuity | PASS; generated classifier and current named-slot admission reconciled; historical stages retained. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.53` | Four complete files + baseline; 76 callable tests; neutral signature/codeblock; tracked plugin census13; canonical Knowledge and focused continuity | PASS; current registry metadata and legacy corpus/discovery boundaries reconciled. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.54` | Three complete files + exact baseline; three managed syntax checks; nine gdcheck diagnostic assertions; canonical utility Knowledge; focused continuity | PASS; final queued Perl utility checkpoint reconciled; .25/.26 remain unrepaired. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.55` | Independent Perl coverage/54 commit identities; Rust candidate and task Scope audits; current deltas; resulting pressure; memory/Knowledge/history; exact staged canonical CI | PASS coverage and ownership; canonical receipt required before parent-closeout landing. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.1` | Exact two-range reading/baseline; 199-package lock census; retained eleven CLI/isolated core controls and four regex-boundary controls; task-first repairs .45–.47 and .49; preceding canonical receipt; focused continuity | PASS reading and bounded diagnostic evidence; Rust parent active; all four new repairs pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.2` | Six exact reading ranges/current-baseline proof; locked offline 199-package metadata; neutral cursor 36/18/8/60; existing Knowledge; .41.2/.41.7 ownership; focused continuity | PASS reading/metadata/neutral proof; requirement and source-comment repairs pending; codebase reading still No. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.3` | Two exact reading ranges/current-baseline proof; existing callable/compiler Knowledge; neutral callable 7/11/9/7/4/8/23; selector zero-positive/20 classified; .45/.47 ownership; focused continuity | PASS reading and focused contract proof; compiler repairs remain pending; whole-codebase reading still No. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.4` | Four exact reading ranges/current-baseline proof; descriptor/entry/slot Knowledge; neutral slot 5/2/59 and entry 8/3/3/54; .41.2 comment ownership; retained native duplicate rejection; focused continuity | PASS reading and focused neutral proof; source/public-comment repairs pending; codebase reading still No. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.5` | Exact prefix/current-baseline proof; callable/staged/write/control Knowledge; neutral staged 123/129 mutations and write 5/7/11/16/3/3/8/105; retained .45–.47/.49; focused continuity | PASS reading and focused neutral proof; expression suffix and native repairs remain pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.6` | Exact continuation/current-baseline proof; mutation/hash/callable Knowledge; neutral mutation 4/14/5/10/8/6/1 and 167+592 mutations; retained .45/.46/.47 controls; focused continuity | PASS reading and neutral contract proof; source boundary repairs remain pending with unchanged diagnostic limits. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.7` | Exact lexical range/current-baseline proof; callable 7/11/9/7/4/8/23; six asserted Rust/Perl-lowering hash controls; three paired native cat controls; .50/.51 task-first ownership; .49 limits; focused continuity | PASS reading and bounded diagnosis; .50/.51 repairs pending; whole-codebase reading still No. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.8` | Three exact ranges/current-baseline proof; write 5/7/11/16/3/3/8/105; callable 7/11/9/7/4/8/23; uniform 11/7/6/8; historical Knowledge and .41.6 ownership; focused continuity | PASS reading and neutral proof; parser suffix and all runtime repairs remain pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.9` | Exact parser range/current-baseline proof; standalone 9/4/6/3/6/15/7/14; cursor 36/18/8/60; Unicode 806/9/8/2; ten paired body and three matches controls; four lowering/three bootstrap controls; .52-.54 ownership; focused continuity | PASS reading and bounded diagnosis; compact fluent/header/regex-brace repairs pending with exact evidence. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.10` | Exact parser/trace/type range and baseline proof; managed core trace 7/7; numeric 55/18; cursor 36/18/8/60; four paired native number controls; .55 ownership; trace closure/fixture Knowledge; focused continuity | PASS bounded reading and diagnosis; value and scalar-text repairs remain pending under .55. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.11` | Exact three-range/current-baseline proof; Unicode 806/9/8/2; cursor 36/18/8/60; duplicate slots 5/2/59; derived-state/AST-pass Knowledge; .41.2 comment ownership; focused continuity | PASS reading and neutral proof; remaining validator/native suites and all repair leaves stay separately owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.12` | Exact three-range/current-baseline proof; core validation 21/21; gap 9/0/63/public34; root 8/3/3/54; cursor 36/18/8/60; four paired registry/five paired AND/four descriptor controls; .56/.57 ownership; lossless segment 4983; ADR 0105; exact staged canonical proof | PASS bounded reading and lossless archive proof; .56/.57 remain pending; exact canonical receipt required before landing. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.13` | Exact six-range/baseline proof; managed core cursor 5/5 + types 8/8 + Unicode 5/5; cursor/Unicode/logical/progressive neutral proof; finalized prior canonical intake; eight capture identities and ten absence checks; Knowledge/history/memory/all doctrines and diff | PASS bounded source/contract proof and diagnostic intake; constructor/dispatch suffix and existing repairs remain pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.14` | Four-range/current-baseline identity; four managed neutral contracts; ceiling constructor/private-field and one-byte assertion source review; Knowledge/history/memory/all doctrines/diff | PASS bounded reading and neutral proof; prior native evidence remains dated, .37 review and engine suffix stay owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.15` | Exact engine-range/current-baseline identity; seven managed neutral checks; managed CLI build and seven paired split cases (five differences/two equal controls), .33 ownership and exact log/binary hashes; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS source/neutral proof and bounded split diagnosis; .33 owns contract review and repair; engine continuation stays pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.16` | Exact range/current-baseline proof; four managed neutral contracts; generated validation and invocation order reading; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded source and neutral proof; .41.2 owns stale comments, engine regex loop remains pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.17` | Exact source identity; six managed neutral contracts; four native diagnostic controls/field assertions and exact retained artifacts; .55.1 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded reading/neutral proof and exact index diagnosis; .55.1 repair and recursive writer continuation remain owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.18` | Exact source identity; four managed neutral contracts; invocation/guard/write Knowledge review; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines | PASS bounded reading/neutral proof; preserve later traversal/context/body ownership. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.19` | Exact source identity; four managed neutral contracts; 6 paired primary cases + 6 direct diagnostic cases with independent values/codes/spans; .58 ownership; consumed compiler sample; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded reading and exact guard-gap diagnosis; .58 owns repair/carrier/public closure. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.20` | Exact source identity; four managed neutral contracts; ten paired primary values/errors; ten lowered/generated captures; six callback descriptors; .59 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded reading and exact substitution diagnosis; .59 owns repairs and recurrence. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.21` | Exact source identity; three managed neutral contracts; eleven paired values/errors plus Rust-only overflow; twelve ready descriptors/source captures; exact scalar kinds/panic-site assertions; .60/.61 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded reading and exact slice/scalar diagnosis; .60/.61 own repairs and recurrence. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.22` | Complete source identity; five paired exact values/effects/JSON kinds; five ready source/descriptor captures; logical/typed/cursor neutral contracts; .62 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded capture/control reading and coalesce diagnosis; .62 owns runtime/carrier/public repair. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.23` | Full source identity; six informative and six inconclusive retained pairs; six three-rule descriptors/generated captures; exact sequence/error assertions; write/mutation/slot neutral proof; .63 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded engine/helper/export reading; .63 owns confirmed nonzero-cursor regex context repair. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.24` | Untruncated 65,536-byte source read/current-baseline identity; two byte-fresh generators; neutral transport/admission; decoded bundle/frame/schema assertions; supporting source identity; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS generated MCP prefix and authority identity; runtime/suffix reading remains next. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.25` | Untruncated scope/baseline identity; managed binding/neutral MCP; exact native panic test and captured stdout/stderr; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS reading checkpoint; .36 source evidence extended; new .64 owns confirmed synthetic panic-output gap. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.26` | Complete baseline scope; six native wire tests; twelve paired public size/delimiter cases; canonical-output and source-cause assertions; neutral MCP; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded source reading; .65 owns confirmed one-byte final EOF discrepancy; .64 wire source scope extended. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.27` | Exact baseline source/helper coverage; verified existing CLI 66/66 default; neutral recognition/current guards; source-bounded .38 comparison; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS CLI/recognition reading; current trace/admission facts reconciled and Rust invalidation helper guard qualified. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.28` | Exact baseline coverage; recognition 138/250/58, gap 9/0/63, typed source 14/0/231; 92/7 source catalogs; Knowledge/history/memory/staged diff/all nine doctrines | PASS recognition adapter and RuntimeContext reading; gap/alias milestones and .55.1 incoming conversion inventory reconciled. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.29` | Exact baseline coverage; typed14/0/231, binding11/7/6/8, write105, map167/592, diagnostic20; Knowledge/history/memory/staged diff/all nine doctrines | PASS context observation/projection/store reading; current Knowledge and private-versus-bare mutation boundaries reconciled. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.30` | Baseline scope/supporting proof; six paired public queries/exact IDs and excerpts; semantic6/20/128, callable23, binding11/7/6/8; Knowledge/history/memory/staged diff/all nine doctrines | PASS bounded reading and root cause; new .66 owns repeated binding-ID/source overwrite, .22 gains Rust evidence. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.31` | Baseline scope; ADR0049/source review; six paired query and six Get controls; independent signature/count/source assertions; semantic6/20/128; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading/root cause; .67 owns false signature acceptance and composite-call/source omissions. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.32` | Baseline scope; complete query/runtime and static prefix reading; eight native queries/four paired Get-CLI controls; independent assertions; semantic/diagnostic/recognition neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading/root cause; normal slot diagnostic correct; .68 token-use and .69 newline repairs owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.33` | Baseline scope; static/event/emitter reading; five paired query and three paired Get-CLI controls; independent source/index assertions; semantic/cursor/generated neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading/root cause; .70 owns grouped source/selector correlation and complete remainder handling. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.34` | Baseline scope; seven identity module compiles/two executable modules/ten results; independent assertions; generated/cursor/typed-source neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading/root cause; .71 literal encoding and .72 recognition parse coherence owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.35` | Baseline scope; complete source authority/loader and function projection reading; ADR0026/Knowledge reconciliation; resolution/typed/diagnostic/staged neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading; complete source authority/loader and accurate historical resolution provenance. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.36` | Baseline scope; spec parser helper completion and staged registry/seed/coordinator reading; .55.1 source inventory; staged/typed/scalar neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading; five bounded Knowledge cards preserve exact authority scope and existing numeric audit. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.37` | Baseline reading; paired target/returned-marker/budget assertions and backtrace; library/artifact hashes; staged/typed neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading and bounded diagnostic assertions; defects remain explicitly pending under .73/.74/.75. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.38` | Four baseline-identical source ranges; three staged files complete; six Knowledge/.55.1 reconciliation; Unicode/staged/typed checks; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading and generated/neutral checks; existing returned-marker and numeric repairs remain pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.39` | Five complete ranges/baseline identity; Unicode generation/12 fixtures; prior canonical receipt/log/two sample identities; five Knowledge cards; memory/history/diff/nine doctrines | PASS reading and evidence reconciliation; .3.3.38 canonical PASS at eba1a0ed; skipped optional results not refreshed. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.40` | Five complete upper-map ranges; baseline and retained-generation input identity; Unicode Knowledge; memory/history/diff/nine doctrines | PASS reading and retained-proof scope; upper map complete, evaluator remains pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.41` | Exact two-file reading/baseline identity; complete Unicode coverage; callable assertion scope; Unicode/callable neutral checks; four Knowledge cards; 99-commit batch census; memory/history/diff and receipt-bound canonical gate | PASS focused reading and census; exact staged canonical receipt required before landing, with final result in the commit body. |
| `2026-09-08` | `SESSION-STARTUP-READING.3.3.42` | Exact scoped reading/baseline identity; callable/named-mark neutral checks; Knowledge, memory, histories, diff and all doctrines | PASS focused reading; pressure maintenance owns the next clean pivot. |

Current CI intake, `2026-09-10` / `SESSION-STARTUP-READING.80.0`: eleven public build stages
(dependency-internal details removed September20), both successful samples and failed compiler-sample outcome, prior-record preservation,
Knowledge/book/memory/history/whitespace and all nine doctrines pass. Preceding canonical `bef5dafd` passes
CLI66x2 and Phase0 1032/1032; 1163 seconds is Phase0 only, with 25 optional gates skipped.

## Commit Log

- 2026-09-24 .86.3: `SESSION-STARTUP-READING.86.3 - close verified scanner repairs in lockstep`; activation52408086a; next .50.

- 2026-09-24 .86.5.3: `SESSION-STARTUP-READING.86.5.3 - preserve same-line regex slot identity`; activation4ca4f745e; canonical .86.3 follows.

- 2026-09-24 .86.5.2.2: `SESSION-STARTUP-READING.86.5.2.2 - validate same-line slash call members`; activationfb955602e; required .86.5.3 follows.

- 2026-09-24 .86.5.2.1: `SESSION-STARTUP-READING.86.5.2.1 - prove explicit book example returns`; activation917b4a42a; .86.5.2.2 follows.

- 2026-09-24 .86.5.1: `SESSION-STARTUP-READING.86.5.1 - validate final line-ending slash calls`; activationfe516141b; .86.5.2 follows.

- 2026-09-24 .86.4.4.2.2: `SESSION-STARTUP-READING.86.4.4.2.2 - verify public helper and book recomposition`; activation9f81d3162; .86.5 follows.

- 2026-09-24 .86.4.4.2.1: `SESSION-STARTUP-READING.86.4.4.2.1 - load tracing in fresh generated parsers`; activation af168d2fe; .86.4.4.2.2 follows.

- 2026-09-24 .86.4.8.2: `SESSION-STARTUP-READING.86.4.8.2 - preserve grouped regex helper operands`; activation9f0c6ca9e; .86.4.4.2 follows.

- 2026-09-24 .86.4.8.1: `SESSION-STARTUP-READING.86.4.8.1 - preserve grouped operand compatibility evidence`; activation f3f9fc74; required compatible implementation .86.4.8.2 follows.

- .86.4.1 — `SESSION-STARTUP-READING.86.4.1 - isolate Perl multiline regex scanner failures`.

- 2026-09-22 .83.2.2: `SESSION-STARTUP-READING.83.2.2 - implement complete s-expression documents`; activation eda9cd3dd; .83.2.3 follows clean handoff.

- 2026-09-22 .45.3: `SESSION-STARTUP-READING.45.3 - close Rust rule-code rejection repair`; activation 30c1ddeea; .83.2.2 follows clean handoff.

- 2026-09-22 .45.2: `SESSION-STARTUP-READING.45.2 - verify Rust rule-code rejection routes`; activation 10893fb71; canonical .45.3 follows clean handoff.

- 2026-09-22 .45.1: `SESSION-STARTUP-READING.45.1 - reject malformed Rust rule code`; activation 349bde2b1; .45.2 follows clean handoff.

- 2026-09-22 .83.1: `SESSION-STARTUP-READING.83.1 - define kind-preserving document grammar`; activation 8259719f8; compiler .45.1 follows clean handoff.

- 2026-09-22 .83.2.1: `SESSION-STARTUP-READING.83.2.1 - preserve multiline Lispish quoted strings`; activation 392bd5335; .83.1 follows clean handoff.

- 2026-09-22 .85: `SESSION-STARTUP-READING.85 - recover SEMULITH reports and repair ownership`; activation 8f0cdf6b; .83.2.1 follows clean handoff.

- 2026-09-22 .84: `SESSION-STARTUP-READING.84 - adopt targeted startup and fast ramp-up`; activation cb47fde46; .85 follows clean handoff.

- `2026-09-13` .3.7.0: `SESSION-STARTUP-READING.3.7.0 - own exact supporting-source reading ranges`; activation 735f0337883baef5ac4422976879d09725e0e8ea; next supporting .1.1 after clean proof and empty brief.

- `2026-09-12` .3.6.0: `SESSION-STARTUP-READING.3.6.0 - freeze exact Lua reading ownership and capacity intake`.

- .3.5.0: `SESSION-STARTUP-READING.3.5.0 - freeze exact bounded Julia reading plan`.

Each canonical task node owns its exact `Commit` subject and retained completion note. Query landed history with `git log --all --format="%h %s" --fixed-strings --grep="SESSION-STARTUP-READING."`; this replaces the proven duplicate 102-row table.

## Changelog

- 2026-09-24 .50: Repair isolated hash-key colons, execute the shared book example across Perl/Rust carriers, own immediate typed-index repair .88 and later headroom containment .16, and preserve the director's LS-004 notification condition.

- 2026-09-24 .86.3: Recompose verified symbol/scanner repairs and unchanged executable book sources; require exact canonical receipt before parent landing, then resume .50.

- 2026-09-24 .86.5.3: Repair same-line slot identity, shield bare code in the permanent grammar and add sixth executable book example. Compact60 blank-only mutable-ledger separators, preserving every prior nonblank line and its order.

- 2026-09-24 .86.5.2.2: Repair same-line slash-call validation, teach the verified edge form and require independent regex-slot metadata repair .86.5.3 before closure.

- 2026-09-24 .86.5.2.1: Correct the weak I/E division teaching/test carrier, retain .27 ownership and select same-line repair .86.5.2.2. Compact55 mutable-ledger blank separators with every nonblank line/order preserved; no content or budget is removed.

- 2026-09-24 .86.5.1: Repair line-ending slash-call outer validation, add fifth executable book example and own separate callable arithmetic/grouping findings. Shared slash precedence is unchanged.

- 2026-09-24 .86.4.4.2.2: Close only the measured Perl helper chain, preserve original public negative/EOF sources and select immediate EOF repair. Code and exact book examples remain unchanged from verified9f81d3162.

- 2026-09-24 .86.4.4.2.1: Repair emitted Trace bootstrap exposed by fresh-process book testing; retain exact Markdown source recurrence and immediate final public recomposition owner.

- 2026-09-24 .86.4.8.2: Preserve grouped helper operands and numeric compatibility through context-aware structural parsing; synchronize executable book guidance and extend existing .34.1 comment ownership.

- 2026-09-24 .86.4.8.1: Reject complete-token lookahead that changes accepted numeric/raw-host values; retain exact patch and public/AST/lowered probe, restore accepted implementation and own consistent grammar/context repair under .86.4.8.2. Book limitation and working alternative remain accurate.

- 2026-09-23 — .86.4.2.1 rejects lexical-only repair, preserves a second exact checkpoint and restores accepted source/tests; .86.4.2 splits into diagnosis, director precedence decision and implementation.

- 2026-09-23 — .86.4.5 preserves the incomplete candidate as a verified reconstructable patch; accepted source/tests restored and PNT director-paused.
- 2026-09-23 — .86.4.1 diagnoses two independent scanner failures and splits .86.4 before production work; .86.4.2 follows.

- 2026-09-22 .83.2.2: Implement the separate versioned grammar, six-runtime contract recurrence and public examples; preserve historical Lispish and continue native file delivery.

- 2026-09-22 .45.3: Close .45 error propagation only; retain separate parser defect owners and resume ADR0124 grammar delivery.

- 2026-09-22 .45.2: verify rejection across public source carriers and actual generated execution; retain precise compiled-artifact regeneration limits.

- `2026-09-13` .3.7.0: Decompose all supporting sources into exact bounded reading owners; preserve prior work, unread-source honesty and dependency reuse.

- `2026-09-12` .3.6.0: Freeze exact Lua reading ownership and route the measured capacity intake; all prior evidence and repairs remain.

- `2026-09-11`: .3.5.0 freezes the exact 52-child Julia plan and capacity ownership; first reading is JULIA-STARTUP-READING.1.1.

- `2026-09-06`: Created the owning leaf before any checkpoint edits; recorded baseline coverage and the remaining reading sequence.
- `2026-09-06`: Completed the focused checkpoint and synchronized continuity; remaining reading starts at `.2`.
- `2026-09-06`: `.2` completes the remaining roadmap ranges and current-direction reconciliation; codebase and
  mdBook reading remain No, and `.3` owns the next inventory/decomposition.
- `2026-09-06`: `.6` proves the surprising liveness report, records a fact card, and owns the repair as `.7`.
  Required reading resumes at `.3`; managed recovery/purge remains unused until repaired.
- `2026-09-06`: `.3.1` classifies every baseline entry, owns all source lanes, completes Toolbox reading, and
  defines exact `.3.2.1` coverage before source reading. No production or public-book change.
- `2026-09-06`: `.3.2.1` completes the five-file invocation boundary and reconciles it with existing Knowledge;
  `.3.2.2` owns decomposition of the remaining 84 Perl paths.
- `2026-09-06`: `.3.2.2` owns 52 exact remaining Perl groups, including byte fragments for generated MCP JSON;
  independent interval proof passes, and `.3.2.3` is the next reading leaf.
- `2026-09-06`: `.3.2.3` completes five dependency adapters, diagnoses stale comparison state, and owns repair
  `.8`; the next exact reading leaf is `.3.2.4`, with both repairs gated on required reading.
- `2026-09-06`: `.3.2.4` completes bootstrap core reading and diagnoses attached-tail regex truncation;
  `.9` owns repair and `.3.2.5` is the next required reading leaf.
- `2026-09-06`: `.3.2.5` completes compiler-state reading and required history rollover; ADR 0102 admits
  exactly one history member/manifest row under canonical verification. Next reading is `.3.2.6`.
- `2026-09-06`: `.3.2.6` reads Compiler.pm 1–1041, records prior canonical/loader evidence, and links the
  historical duplicate-slot card to its existing fix. Next reading is `.3.2.7`; codebase/book remain incomplete.
- `2026-09-06`: `.3.2.7` completes compiler reading and indexes its existing phase/mode boundaries.
  Thirteen Perl files are read; `.3.2.8` reads SpecEntry.pm next.
- `2026-09-06`: `.3.2.8` completes SpecEntry reading, reconciles old coupling records, and owns unbound
  AND_BCODE input repair `.10`; next reading is Validation.pm 1–1320 under `.3.2.9`.
- `2026-09-06`: `.3.2.9` reads Validation.pm 1–1320, owns diagnostic repairs `.11.1`–`.11.3`, and repairs
  stale Knowledge retrieval. `.3.2.10` reads the validation suffix next.
- `2026-09-06`: `.3.2.10` completes Validation.pm reading and reconciles the historical edge card.
  Fifteen Perl files are read; `.3.2.11` reads RuleIR.pm next.
- `2026-09-06`: `.3.2.11` completes RuleIR reading and proves bare/explicit execution-order drift.
  Repair `.12` is owned; `.3.2.12` reads EmitContext.pm next.
- `2026-09-06`: `.3.2.12` reads EmitContext 1–1489 and reconciles fourteen registry keys with the existing cards.
  `.3.2.13` reads the suffix next; codebase/book remain incomplete.
- `2026-09-06`: `.3.2.13` completes EmitContext reading and owns repeated blind-target repair `.13`.
  `.3.2.14` reads HandlerVariantEmitter next; codebase/book remain incomplete.
- `2026-09-06`: `.3.2.14` reads the emitter prefix, reconciles historical cards, and owns I-block literal/scope
  repairs `.14.1`/`.14.2`. `.3.2.15` reads the emitter suffix plus LinkedRE and ActionIR AST.
- `2026-09-06`: `.3.2.15` completes emitter/LinkedRE/AST reading, extends `.14` repairs to REP, and bounds
  JSON projection claims. `.3.2.16` reads ActionIR/AST/Parser.pm 1–1498 next.
- `2026-09-06`: `.3.2.16` reads the AST parser prefix, proves nested span loss, and owns repair `.15`;
  `.3.2.17` completes the parser and reads ArrayPipeline/CanonicalEvents adapters.
- `2026-09-06`: `.3.2.17` completes AST parser and pipeline/event adapters; twenty-four Perl files read.
  Existing Knowledge owners gain direct retrieval keys; `.3.2.18` reads the Contracts prefix.
- `2026-09-06`: `.3.2.18` reads Contracts 1–1396 and rechecks the detached typed-source catalog;
  historical status wording is reconciled, and `.3.2.19` finishes Contracts.
- `2026-09-06`: `.3.2.19` finishes Contracts and indexes its fourteen-group builder;
  twenty-five Perl files are fully read, and `.3.2.20` starts ControlFlow.
- `2026-09-06`: `.3.2.20` reads ControlFlow 1–1485, verifies candidate state isolation and compact trace,
  and retains existing caveat repair ownership; `.3.2.21` completes ControlFlow and the next adapters.
- `2026-09-06`: `.3.2.21` completes four files, owns emptiness/literal repairs `.16`, and preserves required
  notes history under finite ADR 0103 capacity; MethodExpr follows canonical checkpoint landing.
- `2026-09-06`: `.31` preserves forward reading and source-confirmed findings from the canonical wait,
  owns repairs `.17`–`.30`, indexes the JSON observation artifact, and routes back to queued MethodExpr.
- `2026-09-06`: `.3.2.22` closes MethodExpr comprehension, indexes its scope normalizer, and qualifies
  dated migration spellings. Queued checkpoints continue with the MethodLowering prefix.
- `2026-09-06`: `.3.2.23` records MethodLowering prefix comprehension and qualifies dated Knowledge rollout notes;
  four trace tests pass, and `.3.2.24` continues the next prefix range.
- `2026-09-06`: `.3.2.24` records signature/local-binding and statement-bridge comprehension, validates 66 variadic
  tests plus a current mixed-path read, and reconciles retired-syntax Knowledge; next `.3.2.25`.
- `2026-09-06`: `.3.2.25` reads value/function dispatch, preserves eight caller-scope controls, and owns repair `.32`;
  existing execution Knowledge is qualified, with `.3.2.26` next.
- `2026-09-06`: `.3.2.26` reads block/receiver/tree dispatch, validates 23 AST tests and three root controls, and
  reconciles existing traversal Knowledge; `.3.2.27` is next.
- `2026-09-06`: `.3.2.27` reads helper fallback and numeric/string/collection paths, passes nine numeric tests and
  four descriptor controls, and qualifies existing AST/numeric Knowledge; next `.3.2.28`.
- `2026-09-06`: `.3.2.28` reads collection/constructor/mutation paths, passes three value controls, and preserves
  paired Perl/PUC tagged-record drift with `.33.1`/`.33.2` ownership; `.3.2.29` follows.
- `2026-09-06`: `.3.2.29` reads the lowering suffix and private progressive scanner; the 129-assertion Perl consumer and
  9/9/116 neutral proof pass, three Knowledge pointers reconcile, and `.3.2.30` follows.
- `2026-09-06`: `.3.2.30` reads rewrite orchestration and scanner/flow surfaces; five trace tests and seven-dispatcher
  census pass, four Knowledge records reconcile, and `.3.2.31` follows.
- `2026-09-06`: `.3.2.31` reads legacy/basic scanners, passes five public controls and generated handler-first push
  inspection, reconciles three historical records, and advances to `.3.2.32`.
- `2026-09-06`: `.3.2.32` reads pipeline/recognition/staged/splitting owners, passes 143 staged checks and neutral/
  language proof, reconciles two Knowledge records, and advances to `.3.2.33`.
- `2026-09-06`: `.3.2.33` reads splitter/trace/value owners, passes four trace tests, roots comment/newline failures in
  twelve controls, creates `.34.1`/`.34.2`, and advances to `.3.2.34`.
- `2026-09-06`: `.3.2.34` reads binding/callable/codeblock/gap owners and MCP header, passes 134 tests and neutral gap
  proof, roots dynamic boolean kind loss under `.35`, and advances to `.3.2.35`.
- `2026-09-06`: `.3.2.35` reads the first MCP data fragment, passes binding freshness/five tests/six frame controls/
  complete-141 admission proof, reconciles one Knowledge card, and advances to `.3.2.36`.
- `2026-09-06`: `.3.2.36` reads MCP policy/corpus/schema data, passes exact embedded-neutral identity and 35/10/10/76
  proof, reconciles two records and ADR alignment ownership, and advances to `.3.2.37`.
- `2026-09-06`: `.3.2.37` reads the MCP schema/payload suffix, verifies canonical bundle and four/seven response/source
  digests plus binding freshness, updates one Knowledge card, and advances to `.3.2.38`.
- `2026-09-06`: `.3.2.38` reads MCP/numeric owners, passes 31 MCP/nine numeric and neutral 55/18 proof, reproduces
  competing-error order across two routes, owns `.36`, and advances to `.3.2.39`.
- `2026-09-06`: `.3.2.39` reads plugin/progressive owners, passes 138 tests and neutral/public proof, records facade and ceiling
  controls, owns `.37` repairs, and advances to `.3.2.40`.
- `2026-09-06`: `.3.2.40` reads recognition core/static policy, passes 59 tests and neutral/public proof, reproduces six
  post-terminal controls, owns `.38`, and advances to `.3.2.41`.
- `2026-09-06`: `.3.2.41` reads runtime observers, passes 137 tests and four neutral checks, owns `.39`/`.40`, and performs
  required change-history rollover with ADR 0104; next `.3.2.42` after exact staged canonical proof.
- `2026-09-06`: `.3.2.42` reads semantic call/index owners, preserves complete 50-file book reading, and owns .41/.42/.43 repairs with exact public and isolated controls.
- `2026-09-06`: `.3.2.43` completes query/runtime-projection/source-map comprehension, qualifies historical Knowledge milestones, and verifies exact preparation-spool cleanup.
- `2026-09-06`: `.3.2.44` reads static semantic projection, refines .23 to preserved diagnostics with fabricated dependency evidence, and attaches stale TOOLBOX lifecycle guidance to .41.6.
- `2026-09-06`: `.3.2.45` completes the typed source-location owner and compatibility adapter reading with exact baseline and retained proof.
- `2026-09-06`: `.3.2.46` reads staged authority, reconciles routed recursion, and owns .44's modeled identity-recycling risk with exact native and isolated controls.
- `2026-09-06`: `.3.2.47` completes staged runtime and legacy registry reading, records fresh authority/private marker lifetime, and separates legacy cache-key metadata from general scheduling.
- `2026-09-06`: `.3.2.48` completes Trace reading, records 20 direct/wrapped string/object controls and 11 generated tests, and qualifies exception-state and historical CLI claims.
- `2026-09-06`: `.3.2.49` reconciles the first Unicode table range from complete .31 reading, refreshes five-module regeneration coverage, and records 52 current Perl tests.
- `2026-09-06`: `.3.2.50` reconciles the middle Unicode mapping range and clarifies physical mdBook completion versus pending formal alignment in inventory Knowledge.
- `2026-09-06`: `.3.2.51` reconciles final Unicode mapping/property/evaluator coverage and records the dated task-storage census before native planning.
- `2026-09-06`: `.3.2.52` reconciles the generated XID classifier, records direct boundary/fixture proof, and corrects stale named-slot/gap admission Knowledge.
- `2026-09-06`: `.3.2.53` reconciles spec-owned function metadata, completes legacy plugin/path/config reading, and records current callable proof and the parked plugin census.
- `2026-09-06`: `.3.2.54` completes legacy utility comprehension and preserves existing repair evidence; owns the Perl closeout and Rust decomposition before advancing.
- `2026-09-06`: `.3.2.55` closes Perl reading after independent coverage reconciliation and owns all Rust reading ranges; existing repairs and whole-codebase reading remain pending.
- `2026-09-07`: `.3.3.1` reconciles the first Rust reading group and owns forward malformed-block acceptance, Unicode diagnostic panic, parser/compiler whitespace mismatch, and regex-newline loss as .45–.47 and .49; no repair is closed.
- `2026-09-07`: `.3.3.2` reconciles Rust manifests, complete AST, and callable-contract prefix; records locked toolchain-declaration drift and mode comments under existing documentation repairs.
- `2026-09-07`: `.3.3.3` reconciles callable traversal and compiler validation/lowering; retains existing fail-closed and mutation repair ownership.
- `2026-09-07`: `.3.3.4` reconciles regex resolution, descriptor projection, entry precedence and portable diagnostics; owns stale self-edge comments and preserves native duplicate rejection.
- `2026-09-07`: `.3.3.5` reconciles typed expression carriers and statement parsing; preserves staged declaration authority and exact source-coordinate boundaries.
- `2026-09-07`: `.3.3.6` reconciles expression parsing, nested writes/mutations and brace classification; links existing UTF-8 and whitespace defects without overstating runtime proof.
- `2026-09-07`: `.3.3.7` reconciles lexical/test reading and owns confirmed adjacent hash-colon loss and cat arity divergence under .50/.51; retains prior regex repair limits.
- `2026-09-07`: `.3.3.8` completes expression-test reading and core entry prefix; qualifies old reconstruction, assignment and rollout claims without changing runtime.
- `2026-09-07`: `.3.3.9` reads rule-body parsing and owns .52-.54 lexical repairs, preserving paired native and exact bootstrap truncation evidence without runtime changes.
- `2026-09-07`: `.3.3.10` reads remaining parser tests, core trace and types prefix; owns .55 value/text repair and reconciles dated trace closure and scalar fixture coverage.
- `2026-09-07`: `.3.3.11` completes compiled-type/Unicode reading and validator entry order; reconciles dated cursor/strict evidence and owns stale validation comments under .41.2.
- `2026-09-07`: `.3.3.12` completes static validator and descriptor-test reading; owns .56 helper shadowing and .57 nonnumeric bare-selector loss with paired native/descriptor controls; performs required lossless notes rollover and finite ADR 0105 capacity admission under exact staged canonical verification.
- `2026-09-07`: `.3.3.13` reads all six group-13 ranges, retains verification limits and suffix ownership, records the completed prior canonical gate, and verifies exact consumed-capture cleanup; existing claim repairs remain owned.
- `2026-09-07`: `.3.3.14` reads group 14 completely, resolves the zero-ceiling concern at the private positive constructor, updates current options/diagnostic Knowledge, and retains exact engine suffix and native-proof limits.
- `2026-09-07`: `.3.3.15` reads the complete group-15 engine range, records generated-loop and diagnostic/helper boundaries, and preserves exact split controls with existing .33 repair ownership.
- `2026-09-07`: `.3.3.16` reads all group-16 bytes, reconciles invocation/diagnostic/observation boundaries, and retains .41.2 comment repair plus the native regex-loop continuation.
- `2026-09-07`: `.3.3.17` reads group 17 completely, reconciles native action/control and write coordination, and retains exact numeric-boundary repair plus recursive-write continuation ownership.
- `2026-09-07`: `.3.3.18` reads group 18 completely, reconciles recursive writes, guards and callable scopes, and retains trailing-block/traversal continuation ownership.
- `2026-09-07`: `.3.3.19` reads group 19 completely, owns final-assignment receiver-guard repair .58, and preserves exact native/reference controls plus compiler-wait evidence.
- `2026-09-07`: `.3.3.20` reads group 20 completely, owns substitution repair .59, reconciles capture/helper Knowledge, and retains exact primary/lowering evidence.
- `2026-09-07`: `.3.3.21` completes helper reading, owns slice/scalar repairs .60/.61, and retains eleven paired controls plus one Rust-only overflow case.
- `2026-09-07`: `.3.3.22` reads capture/control tests, owns coalesce repair .62, and preserves five typed paired controls.
- `2026-09-07`: `.3.3.23` completes engine/helper/export reading, owns regex context repair .63, and retains six informative paired controls.
- `2026-09-07`: `.3.3.24` reads the first 65,536 generated MCP bytes and reconciles exact binding identity and proof limits.
- `2026-09-07`: `.3.3.25` completes the embedded MCP module/runtime prefix and owns caught-panic process-output repair .64.
- `2026-09-07`: `.3.3.26` completes MCP server/wire reading, reads primary trace prefix, and owns EOF byte-limit repair .65.
- `2026-09-07`: `.3.3.27` completes primary CLI reading, reads recognition authority/effects/progress, and reconciles .38 source scope and current Knowledge.
- `2026-09-07`: `.3.3.28` completes recognition adapters, reads RuntimeContext source connections and reconciles gap/alias/conversion Knowledge.
- `2026-09-07`: `.3.3.29` reads context observations/projections/stores and reconciles six Knowledge owners without a new runtime defect claim.
- `2026-09-07`: `.3.3.30` completes RuntimeContext/semantic foundation, adds Rust .22 evidence and owns repeated semantic binding identity repair .66.
- `2026-09-07`: `.3.3.31` completes semantic call reading, reads query prefix and owns signature/composite-call evidence repairs .67.
- `2026-09-07`: `.3.3.32` completes query/runtime projection and owns .68 authored token-use/.69 variable-newline repairs.
- `2026-09-07`: `.3.3.33` completes static/event reading and owns grouped semantic source/index and parser-remainder repairs .70.
- `2026-09-07`: `.3.3.34` completes emitter reading and owns generated literal and recognition adapter repairs .71/.72.
- `2026-09-07`: `.3.3.35` completes source authority/loader reading and reconciles staged function projection plus dated resolution evidence.
- `2026-09-07`: `.3.3.36` completes spec parser and reads staged registry/seed/coordinator; .55.1 retains another source conversion boundary.
- `2026-09-07`: `.3.3.37` reads staged execution and owns measured target reservation, returned-marker validation and exhausted-counter repairs .73/.74/.75.
- `2026-09-07`: `.3.3.38` completes all three staged source files, starts pinned Unicode mappings and expands existing .55.1 source inventory.
- `2026-09-07`: `.3.3.39` completes Unicode lower-map reading and preserves canonical .3.3.38 plus bounded sample/probe evidence.
- `2026-09-07`: `.3.3.40` completes the Unicode upper map and preserves exact reading and retained-proof scope.
- `2026-09-07`: `.3.3.41` completes Unicode module reading and bounds callable consumer coverage at the final 100-item batch checkpoint.

- `2026-09-08`: `.3.3.42` completes reading; pressure owner `.5` precedes `.3.3.43`, and the generic-rule question remains proposed intake.
- `2026-09-08`: `.3.3.43` reconciles corpus reading, owns SimEnv dispatch .76 and preserves proposed parser-authoring investigations.

- `2026-09-08`: `.3.3.44` reconciles self-hosted grammar reading and four-mirror freshness; next `.3.3.45`.
- `2026-09-08`: `.3.3.45` reconciles physical label boundaries and edge grammar fields; next `.3.3.46`.
- `2026-09-08`: `.3.3.46` reconciles comment-skip and minimal-rule reading; next `.3.3.47`.
- `2026-09-08`: `.3.3.47` reconciles minimal-rule and user-function reading; next `.3.3.48`.
- `2026-09-08`: `.3.3.48` reconciles user-function edge grammar reading; next `.3.3.49`.
- `2026-09-08`: `.3.3.49` reconciles Terse and legacy corpus reading; next `.3.3.50`.
- `2026-09-08`: `.3.3.50` reconciles corpus and diagnostic consumer reading; next `.3.3.51`.
- `2026-09-08`: `.3.3.51` reconciles classifier reading and owns verifier repair .77; next `.3.3.52`.
- `2026-09-08`: `.3.3.52` reconciles integration control and traversal reading; next `.3.3.53`.
- `2026-09-08`: `.3.3.53` completes integration reading and checkpoints gap capture; next `.3.3.54`.
- `2026-09-08`: `.3.3.54` completes gap and logical consumer reading; next `.3.3.55`.
- `2026-09-08`: `.3.3.55` completes mutation consumer and checkpoints MCP admission; next `.3.3.56`.
- `2026-09-08`: `.3.3.56` completes MCP tests and checkpoints progressive authority; next `.3.3.57`.
- `2026-09-08`: `.3.3.57` completes progressive and punctuation consumer reading; next `.3.3.58`.
- `2026-09-08`: `.3.3.58` completes recognition/observation reading and owns emitted-manifest portability repair .78; next `.3.3.59`.
- `2026-09-08`: `.3.3.59` completes root-selection consumer reading and qualifies historical rollout evidence; next `.3.3.60`.
- `2026-09-08`: `.3.3.60` completes cursor/diagnostic consumer reading and starts semantic-foundation tests; next `.3.3.61`.
- `2026-09-08`: `.3.3.61` completes semantic consumer reading and performs required engineering-notes rollover; next `.3.3.62`.
- `2026-09-08`: `.3.3.62` completes admission/emitter boundary reading and owns verifier signal repair .79; next `.3.3.63`.
- `2026-09-08`: `.3.3.63` completes emitter/loader/staged-prefix reading and corrects classifier proof scope; next `.3.3.64`.
- `2026-09-08`: `.3.3.64` completes staged recursive/carrier reading and starts standalone-lifecycle tests; next `.3.3.65`.
- `2026-09-08`: `.3.3.65` completes lifecycle/trace/typed/casing reading with precise carrier proof; next `.3.3.66`.
- `2026-09-08`: `.3.3.66` completes final Rust contract consumers; only parent closeout remains; next `.3.3.67`.
- `2026-09-08`: `.3.3.67` closes complete Rust reading; preserves pending repairs and routes Dart capacity first; next `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7`.
- `2026-09-10`: `.80.0` preserves CI build/watch/startup evidence, creates gated `.80` and `.81` repairs, and returns to Dart `.1.37` without implementation or reading credit.
