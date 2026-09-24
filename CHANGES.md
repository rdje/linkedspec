# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`



## 2026-09-25 — SESSION-STARTUP-READING.89 - preserve state and receiver lifetime in Perl direct reads

Both typed-AST and compact lowering now share one guarded rvalue read expression. Missing/null roots and children remain unchanged; wrong-kind paths yield undef without a raw host exception. Each observed receiver stays alive across selector effects, so an unrelated retained alias no longer changes the result. Base and selectors evaluate once, generated locals avoid authored/nested names, and explicit selector effects remain visible. The existing write contract and all serialized/generated format authorities are unchanged.

Public replay repairs all five state mutations among the six original controls. Native and fresh-process generated tests cover25 direct cases twice, function parameters/locals, selector order/failures, binding presence/identity and temporary names. The existing neutral Perl consumer now actually executes all three frozen read exclusions. Seven focused suites compose89 passing top-level groups after three stale source assertions are updated; later final runtime20 includes the LF/CRLF shared book source. Frozen neutral105, public mutation50, storage24 and exact rendered source/result checks pass. Complete Phase0 passes1033/1033. Files=1, Tests=1033, 1723 wallclock secs ( 0.44 usr  0.09 sys + 1108.17 cusr 187.53 csys = 1296.23 CPU) Checkpoints .89-read-repair/.89-selector-lifetime/.89-verification retain scope and rejected attempts.

The book removes the repaired read limitation, explains Perl-specific selector timing and links the executed example. It corrects an adjacent historical write-rollout sentence and explicitly qualifies the separate function array-constructor defect. Startup .90 owns that next repair immediately after .89; .91 then repairs the independently confirmed numeric reducer source-shape rejection before .51; LS-004 and downstream notification remain unchanged. No canonical or push claim.

## 2026-09-24 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.2 - partition startup task evidence without loss

Partitioned the startup tree into three mutable semantic owners, one immutable historical part and a 77-line current root under ADR0125. Every original 7994-line/960362-byte source fragment and all 395 child blocks survive exactly. Shared lookup/refresh and the closed current-ID registry explicitly support both trees; cadence recognizes 166 unchanged historical triplets by task identity while retaining one new owning leaf and ordinary canonical receipts. No old limit, FUTURE source or parser behavior changes.

Independent proof passes 998 exact public lookups, eight invalid IDs, both outside-CWD tools, idempotent snapshots, thirteen byte-identical FUTURE files and eleven isolated corrupt-input rejections. Production validation passes 60 mutations/nine pressure controls; cadence passes 14 identity cases and 16 path/five tier controls. The rendered book matches its command block and current topology. Exact staged canonical CI, normal doctrines/hooks and both history-pressure checks govern atomic landing; .89 follows before .51.

## 2026-09-24 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.1 - freeze lossless startup task partition plan

Pinned the startup tree at 7994 lines/960362 bytes and 396 unique IDs. Three semantic parts plus immutable history preserve all nine source intervals; independent Python/Perl reconstruction and all four payload hashes pass. The conservative routed projection 115 files/93554 lines/10456687 bytes fits unchanged ceilings. The plan owns consumer transfer, 166 relocated verification triplets, strict negative proof and an execution-time ADR under canonical .16.2. No parser, tool, registry, startup-source or book bytes change; Perl read-purity .89 follows migration before .51. Focused task/route/memory/Knowledge/history checks, all nine doctrines, staged cadence and diff hygiene PASS.

## 2026-09-24 — SESSION-STARTUP-READING.88 - read indexed values from current typed bindings

Rust `items[0]` now resolves the current typed binding through the existing array-element helper. It no longer loses assigned/appended/split arrays or reads stale private array storage after rebinding. Index evaluation order and numeric conversion are unchanged; absent elements return undef without creating state.

Three regression groups are RED before repair; full runtime unit182 plus selected integration215 are GREEN. Public Perl/Rust17 proof repairs exactly12 wrong Rust values and preserves five controls. Parsed/compiled roundtrips and native/reconstructed/generated18x2 pass. One included book fixture passes Perl26 and independently compiled emitted Rust1, with exact rendered source/result checks. Checkpoints `.88-indexed-read-repair.json` and `.88-verification.json` preserve sources, binary/log identities and focused scope. Existing pre-main delay remains .81-owned; containment .16 precedes .51. The independent read-purity audit exposes five Perl mutations in six public controls; checkpoint .89-read-purity.json, the Knowledge card and corrected book qualify the former unconditional purity claim. Required repair .89 follows containment .16 before .51. No new push or LS-004 closure is claimed.

## 2026-09-24 — SESSION-STARTUP-READING.50 - preserve compact hash-key separators

Rust parse_name now stops at an isolated hash-pair colon while retaining existing namespace colon runs. Compact dynamic, nested, computed, Unicode-valued and bare receiver keys keep evaluated-key semantics and exact source/scalar spans. One shared examples/compact-hash-keys.spec is included by the book and executed by Perl native/emitted and Rust emitted tests; the book also states the independently confirmed indexed-read limitation.

Focused proof: four new core groups fail before repair; full core258 and selected runtime226 pass, plus registered-function keyword policy1 and emitted book1. The final cleaned-up compact/emitted2 rerun passes without first-party warnings. Perl book26 and thirteen exact public source/value pairs pass; five baseline Rust compile rejections are repaired. Later normal builds refresh the CLI, so the same public13 are replayed against final binary a2058123; both correct post-fix observations remain in the tracked checkpoint. Book rendering/exact include and JSON extraction, neutral cursor/binding, formatting, task metadata, Knowledge/memory/history/doctrines and diff checks form the focused landing gate. Exact commands/source/log hashes are in docs/checkpoints/SESSION-STARTUP-READING.50-verification.json; no canonical run is claimed here.

The separate typed-array IndexedVar/get_array defect is diagnosed with seven public controls and scheduled for immediate .88 repair. Existing .87.4 owns excluded Perl grouped-postfix reconciliation. Containment .16 owns measured startup-task headroom after .88 and before .51 without raising limits. Related stale scanner status pointers are corrected against committed aa057b107; original dated evidence remains. Remote main is reverified at a8d34c845, and the director's ARCHOGEN notification waits for a verified LS-004 fix.

## 2026-09-24 — SESSION-STARTUP-READING.86.3 - close verified scanner repairs in lockstep

Fresh public Rust replay passes56 cases:53 exact integer results and3 malformed rejections, including both published symbol/division examples. Rust production and carrier tests are byte-identical to19ba2e0d5, retaining254 core/404 selected runtime/15 emitted-mutation proof. Perl/spec/Dart sources match verified52408086a, retaining focused240/book103/Phase0 1033,120 exact checkpoint records, composed grammar72 and Dart20/package502/storage25owners47packages/CLI66x2/corpus105. All Perl/Rust book fences remain exact; only reciprocal guide links change and the book renders. All .86 implementation children are done or explicitly superseded. Independent .27/.34/.54.1/.63/.87 and Dart .2.24/.2.25 remain owned; no full optional Dart gate or global defect-free claim. Landing requires successful tools/run_ci_local.sh on the exact staged candidate; its receipt and commit body record the final canonical result.

The first canonical attempt stopped at an unowned mode-aware Dart grammar test. Register that exact consumer under the existing Dart group and advance only the current census from76 to77, including contract/checker/stable-marker/book mirrors. Independent JSON comparison preserves every non-census semantic field, fixture, rollout and forbidden claim. Focused cursor proof passes36 families/18 edges/8 parent-child/77 files/60 mutations; stable markers pass8 families/12 markers/15 consumers/4 mutations, and repeated-action passes54 mutations. Earlier dated counts remain unchanged; the failed gate has no receipt.

## 2026-09-24 — SESSION-STARTUP-READING.86.5.3 - preserve same-line regex slot identity

Preserve Perl named and anonymous regex members beside lifecycle blocks, including header rest and compact forms. The existing structural scan now observes only rule-level members; exact Unicode names, order, selector provenance and typed errors remain intact. Align the permanent grammar and BootstrapSpec bridge, shield complete bare lifecycle payloads, and update all four exact grammar mirrors. The sixth complete mdBook example proves second-slot selection with a mismatch control.

Focused checks pass 240 tests across 11 files; six exact book sources pass 103 assertions. Clean4ca4f745e finishes 111 metadata groups and fails only new group4. Fourteen LF/CRLF layouts preserve names/order, selectors, source, live/generated values and permanent grammar nodes; bare payloads remain exact. Typed/Unicode/comment/code/unsupported-tail controls and gap/slot/bare neutral checks pass; four grammar mirrors remain exact. Six slot-focused CLI grammar cases pass on Perl, Rust, Dart, Julia, PUC Lua and LuaJIT in both environments (72 case legs). The unchanged final-E projection defect has a permanent .63 regression and public qualification. Dart exact shipped-pattern recognition now preserves cursor/physical-line semantics, captures, suffixes and three carriers. Focused Dart20 and independent remaining stages pass502 tests/storage25owners47packages/CLI66x2/corpus105. Complete Dart gate attempts remain failed at existing .2.24/.2.25 formatter/SDK blockers; six unrelated formatter edits are restored exactly, without suppression. The72 grammar legs compose retained Perl/Rust passes and fresh Dart/Julia/PUC/LuaJIT passes; neither stopped full-driver attempt is reported green. All 120 final checkpoint records match the preceding candidate after the last bare-block shield; the first five book sources are unchanged. Full Phase0 passes 1033/1033 at frozen diff a80c914626100ac1fbe7c7448a42547574d7adfbc7ec0de8da4aadef88394a32. Book rendering and syntax pass. .86.5 closes its bounded implementation; .86.3 canonical remains pending. Files=1, Tests=1033, 2099 wallclock secs ( 0.41 usr  0.08 sys + 1043.99 cusr 137.50 csys = 1181.98 CPU)

## 2026-09-24 — SESSION-STARTUP-READING.86.5.2.2 - validate same-line slash call members

Recognize a complete final slash call before an outer closing brace even when another admitted member follows on the same line. Preserve full-source regex-first trial selection, explicit host operators, authored bytes and the shared closing-brace safeguard. Eleven explicit-edge forms under LF/CRLF verify live/emitted results and unmatched input; the fifth exact mdBook example now puts its edge on the same line.

Recognize the balanced slash-call end before an outer brace and following members, retaining full-source regex-first trial selection. Focused9 files/207, exact book84 and rendering pass. Clean fb955602e finishes14 groups and fails only new group14. Exactly8 bare-slash rows in the30-case intake now match named controls; other22 are exact. Original12/helper13+syntax/grouped22/numeric12/multiline5 stay exact. Context15 changes only intended next_member/quoted-slash public outcomes; private fragment scans do not select the full-source interpretation. Slot5 stays exact and required .86.5.3-owned. Full Phase0 passes1033/1033 at frozen diff86881406bf815024ee8c7cf00482ce547ebae315a6165fd350cfe9d258b05a92. No canonical or push claim. Files=1, Tests=1033, 1394 wallclock secs ( 0.42 usr  0.09 sys + 1081.47 cusr 110.13 csys = 1192.11 CPU)

## 2026-09-24 — SESSION-STARTUP-READING.86.5.2.1 - prove explicit book example returns

Correct the final-division example and regression carriers after a distinct E return exposed the known Perl .27 omission/value leakage. The old I/regex/E shape returns7 on both x and y even with E returning42; the generated handler contains only I. The corrected zero-regex parent uses an explicit edge to Done, computes out=7, and returns8 from the edge only on x; y returns undef without an error. Production is unchanged.

Five focused files pass31 tests; the five exact book sources pass84 public/fresh-generated assertions. LF/CRLF final-call fixtures also distinguish the explicit edge value and mismatching input in live/emitted execution. Restoring the old book fixture in an isolated snapshot fails only book group7, including value, mismatch, descriptor and generated-plan assertions. The first four book sources remain unchanged. Public/generated checkpoint and book rendering pass; .27 retains the lifecycle repair, .86.5.2.2 resumes same-line validation. No new full Phase0 or canonical result is claimed.

## 2026-09-24 — SESSION-STARTUP-READING.86.5.1 - validate final line-ending slash calls

Recognize a final bare arithmetic slash call before physical-line-ending block closers in Perl's outer validation scans. Use the existing balanced-call parser on a temporary classification copy. Preserve accepted full-source regex interpretations first; retry the final-call form only after failure, buffering callbacks/trace so rejected attempts publish no errors. The shared regex discriminator, explicit host quote routes and authored bytes remain unchanged. LF/CRLF, compact/spaced/nested/value/lifecycle blocks, variable/nested/quoted operands and live/emitted execution are covered.

Clean-baseline replay fails only new consumer groups12/13; candidate focused proof passes206 tests in9 files. The five exact integration-book sources pass82 public/fresh-generated assertions. Five multiline-regex records remain exact, including two that exposed and rejected the earlier physical-line-only candidate; its interrupted Phase0 is excluded. The original12 and context15 replays change only bare/spaced division to7; helper13 plus its syntax record, grouped22 and numeric12 remain exact. Full Phase0 passes: Files=1, Tests=1033, 1528 wallclock secs ( 0.51 usr  0.11 sys + 1129.24 cusr 129.84 csys = 1259.70 CPU). Final book rendering and syntax pass. The book documents repaired division and preserves same-line member repair .86.5.2 plus independently discovered numeric-callable .87.3 and grouping .87.4 boundaries. Parent .86.3 canonical remains pending.

## 2026-09-24 — SESSION-STARTUP-READING.86.4.4.2.2 - verify public helper and book recomposition

Close the measured Perl multiline-helper chain after validation, statement, quoted-subject, grouped-operand and fresh generated Trace repairs. Fifty-nine fixed public controls retain exact expected values/readiness/error stages: helper13, grouped22, numeric12 and original12. The malformed quoted regex retains rule_handler_compile/Unmatched ); both slash EOF forms remain .86.5-owned. The permanent original-source checkpoint makes those distinctions reproducible.

Production/tests and all four exact book sources match verified9f81d3162, retaining its focused173/book66 proof and both mutation checks without repeating unchanged suites. Checkpoint syntax and book rendering pass. Public guidance explicitly limits this acceptance to ordinary rule actions; .87 helper gaps, .2.4 escapes, .34 comments and .54.1/.9 brace scanners remain owned. Select .86.5, then exact canonical parent .86.3.

## 2026-09-24 — SESSION-STARTUP-READING.86.4.4.2.1 - load tracing in fresh generated parsers

The generated preamble now imports LinkedSpec::Trace explicitly. Fresh plain Execute previously failed at trace_generated_handler_branch; existing same-process tests had already loaded Trace. The new generated-source subtest extracts the four exact integration-book specifications and checks public SpecLoader values, source identity, descriptors, errors and independent child-process values/metadata. The format remains v2.

All four cold-process failures become green and the book subtest passes66 assertions. Isolated mutations fail only the intended book group: a changed result fails both live/generated values, and a missing example fails the coverage count. Focused generated/loader/AST/trace/cursor proof passes173 tests across9 files; syntax and generated-source contract checks pass. Both book chapters explain the bootstrap and the runnable recurring check. Final public recomposition remains .86.4.4.2.2; existing helper, escape, comment and EOF owners remain open.

## 2026-09-24 — SESSION-STARTUP-READING.86.4.8.2 - preserve grouped regex helper operands

Recognize grouped slash patterns in regex-helper argument positions while retaining numeric calls, raw-host expressions and original source bytes. Carry that context through structural method parsing, CSV, typed AST and synthetic receiver lowering; let the return scanner and contract handle quoted pattern payloads. The expanded consumer covers dot/comma bodies, flags, quoted and bracket payloads, LF/CRLF, continuation, control, substitution, filtering, indexed q/m/qr variables and generated execution.

Exact accepted-source replay fails only the new grouped-pattern group; candidate focused187 and four directly extracted book examples21 pass. Full Phase0 passes1033/1033 (Files=1, Tests=1033, 1423 wallclock secs ( 0.44 usr  0.10 sys + 1086.49 cusr 125.81 csys = 1212.84 CPU)). The book teaches supported grouped forms and preserves remaining escape/callable/EOF limits. A six-case inline-comment intake isolates a separate pre-existing validation-depth defect and adds it to existing .34.1 with a verified standalone-comment alternative. No comment repair or broad helper-family closeout is claimed.

## 2026-09-24 — SESSION-STARTUP-READING.86.4.8.1 - preserve numeric compatibility before grouped operand repair

Archive the rejected grouped-operand lookahead and a fixed12-case public/AST/lowered diagnostic. Although it repairs all22 prior grouped-pattern probes, it changes accepted array(/(14,2),14/cos) from [7,14] to [] without an error and hides a numeric runtime failure. Restore production/tests exactly to f3f9fc74; require grammar-aware repair .86.4.8.2 before public recomposition. The book retains the measured limitation and working string alternative. No runtime repair, precedence change, full Phase0 or canonical acceptance is claimed.

## 2026-09-24 — SESSION-STARTUP-READING.86.4.4.1 - own grouped regex operand failures before public closeout

Public recomposition at verified9e2c26b1c finds four bare grouped-dot/comma failures among22 fixed public/splitter/CSV/lowered probes. The shared numeric slash-call discriminator mistakes regex-body punctuation for an expression boundary; comma becomes a third helper argument and continuation statements remain joined. Eighteen nearby/string/binding controls work. Add the permanent diagnostic and causal Knowledge record; required .86.4.8 repair precedes .86.4.4.2 public closeout.

Production/tests remain unchanged, both retained division controls return7 and the original helper audit retains only its known helper gaps. All three complete book sources match verified9e2c26b1c byte-for-byte; their16 public/generated assertions remain applicable. The rendered book now records the measured limitation and working string-pattern alternative. Remove80 blank separators from the mutable task ledger, proving every prior nonblank line and its order unchanged, to keep the bounded tree within budget. Focused metadata/doc checks and normal hooks govern landing; no new full Phase0, canonical or broad helper acceptance is claimed.

## 2026-09-23 — SESSION-STARTUP-READING.86.4.7 - preserve physical multiline quoted subjects during validation

Protect complete multiline quoted tokens inside expression scopes in the existing structural validation view. Keep original compilation bytes and diagnostic offsets; leave bare rule-level strings and unterminated tokens visible. Both quote styles preserve LF/CRLF through ordinary literals, inline helper subjects, substitution and lifecycle assignments.

Exact committed-source replay fails the new regression groups8/9; the candidate passes all nine. Eight focused files pass198 tests; all three complete mdBook examples are extracted and independently executed live/generated for16 passing assertions, and rendering succeeds. The permanent diagnostic retains identical action/lowered source while public physical_subject changes from structural failure to ok; all four separate escape-route records stay identical. Complete Phase0 passes1033/1033 in1276 seconds, including the exact nine-group consumer. SUPPORTING-SOURCE-READING.2.4 retains escape fidelity; .86.4.4 owns public recomposition before EOF and canonical closeout.

## 2026-09-23 — SESSION-STARTUP-READING.86.4.6 - preserve regex helper statement boundaries

Recognize slash-pattern operands at parenthesized argument boundaries before a closing y/ can become a translation opener. Reuse the numeric slash-call discriminator; retain assignment-position interpretation, authored bytes and the existing lowering owners. The repair restores substitution, newline continuation and conditional matches without a regex runtime type.

The seven-group consumer fails groups5/7 against isolated committed d2af200325 and passes on the candidate. Four direct-dependent files pass52 top-level tests; retained division controls return7. LF/CRLF, eight host-operator suffixes, punctuation, once-only substitution and independent generated execution are covered. Both complete mdBook examples are read from Markdown and pass11 live/generated assertions; rendering succeeds. Complete Phase0 passes1033/1033 in1545 seconds, including the exact seven-group consumer. Separate physical quoted-subject validation is task-owned by .86.4.7 before public recomposition; observed escape-route differences stay with existing SUPPORTING-SOURCE-READING.2.4. No canonical CI or push is claimed.

## 2026-09-23 — SESSION-STARTUP-READING.86.4.3 - preserve multiline helper patterns during Perl validation

Use a character-position-preserving structural view for complete multiline regex arguments. All three validator passes consume the same view, while compilation and diagnostics retain original source; physical line offsets distinguish real errors from identical pattern payloads. Assignment-position slash decisions and runtime value kinds are unchanged.

Add a six-group focused consumer and invoke it from Phase0. Accepted-source replay fails groups1/2/3/5/6; candidate focused checks pass. LF/CRLF, rule/directive-like payloads, real malformed structure, helper/lifecycle values, division compatibility and original diagnostic attribution are covered. The expanded matrix owns separate statement-lowering defects under .86.4.6 before .86.4.4 public recomposition. Book rendering succeeds; complete Phase0 passes1033/1033 in1211 seconds. Normal staged doctrines govern landing; no canonical CI or push is claimed.

## 2026-09-23 — CONSUMER-REPORT-DELIVERY.6 - audit consumer fix commits and bootstrap history

Audit the original ten reports against task trees, Knowledge cards, ADR0124 and Git commit evidence. Record June15 cold-build adoption c4926f871 of upstream RGX8763a0e6 separately from September workspace remedy effe3e7b2 and still-open ARCHOGEN/LS-004. Integration a1166ee1d explicitly discarded an uncommitted custom preparation helper and left LS-004 open; it is not a failure-handling repair.

Add the bounded canonical report/commit ledger and exact Git identities, link it from current owners and expose repair commits in the book. Eight relevant commits are verified as ancestors of published a8d34c845. Seven addressed requirements include grammar, integration documentation and a design request; one report is open, one withdrawn and one no-action. Preserve document opt-in/admission/publication and downstream-acceptance distinctions. Focused memory/Knowledge/history/book/doctrine/diff checks govern this local documentation commit; source and dependency pins are unchanged.

## 2026-09-23 — CONSUMER-REPORT-DELIVERY.5 - distinguish integration contact from defect attribution

Correct the overly broad RGX-defect/repair-owner wording. ARCHOGEN's original LS-004 identifies PGEN bootstrap; LinkedSpec's public recurrence establishes a misleading intermediate message but correctly propagated failure (exit 2), not a defect in RGX's own code. The empty offline package store deliberately induces an expected resolution failure. RGX's published integration contract also treats PGEN as read-only from RGX.

Keep LinkedSpec report tracking and the director-owned relay, using RGX as the direct integration contact and leaving implementation repair with the affected upstream maintainer. Preserve the original fail-fast and truthful-progress requests without internal diagnosis. Update the local report, tasks, Knowledge, roadmap/resume pointers and book; runtime, dependency sources/pins and published a8d34c845 remain unchanged. Focused memory/Knowledge/history/book/doctrine/diff checks govern this local commit; any later push requires exact-HEAD canonical proof.

## 2026-09-23 — CONSUMER-REPORT-DELIVERY.4 - record director-owned RGX handoff

Record completed canonical publication at `a8d34c84595d46c24cd1820d5fc0414261706412`: live remote main and origin/main match, and the tested f60a70df3 baseline is an ancestor. Canonical CI passes both CLI 66/66 environments and Phase 0 1032/1032 in 1113 seconds, with 25 opt-in gates skipped. The push reused the exact promoted receipt; all nine commit doctrines and the post-commit memory boundary passed.

The director requests local task-tree feedback and will relay the ready report to RGX after the fix publication, now complete. Remove obsolete pending-permission wording from current owners and resume pointers; retain LS-004 as open, with RGX-owned repair and public failure/success/reuse acceptance. No external message, dependency change or downstream acceptance is claimed. This is a focused local administrative commit; a future push requires fresh exact-HEAD canonical proof. Memory/Knowledge/history/diff and all doctrine checks govern landing. Book migration instructions remain accurate and unchanged.

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

