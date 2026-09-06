# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-09-06 — SESSION-STARTUP-READING.3.2.26 — read receiver chains and reconcile tree dispatch

Read MethodLowering 3744–4911 (1,168 lines / 58,949 bytes); 23 AST tests and three public root controls pass.
Reconcile hash/array traversal chronology and historical suite counts in existing Knowledge; focused continuity checks apply.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.25 — read value calls and own caller shadowing repair

Read MethodLowering 2379–3743 (1,365 lines / 65,506 bytes); eight public controls expose caller-local shadowing.
Own repair .32 and record the exact generated-source cause in Knowledge; required focused continuity checks apply.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.24 — read function signatures and statement lowering

Read MethodLowering 1496–2378 (883 lines / 33,969 bytes); 66 variadic tests and a public mixed-path control pass.
Reconcile fixed-function history and retired read/selector syntax in existing Knowledge; focused continuity checks apply.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.23 — read method lowering prefix and reconcile milestones

Read and reconcile MethodLowering 1–1495 (61,967 bytes); four focused trace tests pass.
Existing Knowledge clarifies completed statement migration and historical rollout scope; focused continuity checks apply.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.22 — read method expression normalization

Complete the MethodExpr checkpoint (298 lines / 7,800 bytes) and reconcile authored-value/scope precedence.
Bounded normalizer controls and focused continuity checks apply; MethodLowering prefix is next.

## 2026-09-06 — SESSION-STARTUP-READING.31 — preserve forward reading and own confirmed repairs

- Preserve exact forward Perl/book coverage, confirmed diagnostics, donor-policy provenance, and prior CI completion.
- Own repairs .17–.30 before remediation; fourteen Knowledge cards index causes and the typed-error JSON artifact.
- All baseline Perl source has been read; individual .3.2.22–.3.2.54 checkpoints remain open. Codebase/book stay No.
- The preceding canonical candidate passed and committed at 17d3e919. This tracking intake uses focused
  Knowledge, memory/doctrine, history, baseline/evidence, and staged-scope checks; MethodExpr is next.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.21 — read flow adapters and preserve required history

- Complete ControlFlow/DeclareMethod/Diagnostics/FlowExpr: 1,439 lines / 59,142 bytes; twenty-nine files read.
- Public/source/host-seed controls prove emptiness and literal-slot defects; `.16.1`/`.16.2` own repair.
- Required notes rollover preserves 223 exact clean-source lines; ADR 0103 admits only one member/manifest row.
- Pipeline trace passes five tests; focused identity/Knowledge/history and exact staged canonical proof apply.
  Product/book remain unchanged; MethodExpr reading follows checkpoint landing.
- The first gate hit nested macOS sandbox denial; controlled permitted execution passes the unchanged storage
  oracle. Knowledge records the environment requirement; full canonical proof must be rerun before landing.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.20 — read control flow prefix and verify candidate isolation

- Read ControlFlow 1–1485 / 56,984 bytes; full-file baseline identity passes. Existing control owners reconcile.
- Controlled candidate rejection/acceptance and four compact trace tests pass; existing backlog owns caveats.
- Focused identity/probe/trace, Knowledge, memory/doctrines/history, and staged review; source/book unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.19 — finish contract catalog reading

- Finish Contracts.pm: suffix 1,117 lines / 48,433 bytes, full-file baseline identity; twenty-five Perl files read.
- Index the fourteen ordered builder groups in the existing lowering card. ControlFlow reading is next.
- Focused reading/structure, Knowledge, memory/doctrines/history, and staged review; source/book unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.18 — read contract prefix and reconcile projection status

- Read Contracts.pm 1–1396 / 65,503 bytes; full-file identity passes and its detached catalog remains 92 rows.
- Existing projection/transaction cards distinguish historical pending milestones from completed final status.
- Focused reading/catalog/Knowledge, memory/doctrines/history, and staged review; source/book unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.17 — finish AST parser and read pipeline adapters

- Finish AST parser and read ArrayPipeline/CanonicalEvents/Core: 1,195 lines / 47,612 bytes, baseline-identical.
- Twenty-four Perl files are read; existing pipeline/event Knowledge gains retrieval keys and dated owner notes.
- Focused identity, memory/doctrines/Knowledge/history, and staged review; product/book unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.16 — read AST parser and own nested span repair

- Read AST/Parser.pm 1–1498 / 47,935 bytes; full-file baseline identity passes.
- Direct and public controls prove omitted nested offsets; `.15` owns repair and source-span regression coverage.
- Two parser suites pass 30 top-level tests; focused memory/doctrines/Knowledge/history and staged review.
  Product/book remain unchanged; `.3.2.17` completes the parser and adapter reading.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.15 — finish emitter adapters and extend return repairs

- Complete emitter suffix, LinkedRE, and AST facade: 736 lines / 24,430 bytes; twenty Perl files read.
- Bounded REP controls prove literal corruption and package writes; existing `.14.1`/`.14.2` now cover this path.
  Diagnostic JSON is explicitly a selected-field projection. Product source/book remain unchanged.
- Focused reading/identity/probes, Knowledge, memory/doctrines/history, and staged review; AST parser is next.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.14 — read emitter prefix and own I-block repairs

- Read HandlerVariantEmitter 1–1403 / 53,304 bytes and reconciled historical HandlerIR/return records.
- Public/source/seed controls prove quoted return text is rewritten and single-acode I-result state reaches
  the SpecEntry package. `.14.1`/`.14.2` own literal-safe lowering and invocation-local state after reading.
- Focused identity/probes, Knowledge, memory/doctrines/history, and staged review; source/book unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.13 — complete EmitContext reading and own blind-edge repair

- Read the 1,094-line suffix; EmitContext is fully covered at 2,583 lines / 95,475 bytes, seventeen Perl files total.
- Public AND/OR controls and source/direct-owner probes confirm repeated blind targets overwrite attached code.
  Repair `.13` owns occurrence identity through emission and carriers after required reading.
- Focused identity/probes, Knowledge, memory/doctrines/history, and staged review; product source/book unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.12 — read EmitContext bridge and reconcile registry

- Read EmitContext.pm 1–1489 / 49,396 bytes; sixteen whole Perl files plus this prefix are covered.
- Corrected existing registry cards: fourteen keys comprise thirteen ActionIR owners and Trace. Exact source
  extraction replaces mention counting. Focused identity/retrieval, continuity/doctrines/history, and staged review.
- The suffix remains `.3.2.13`; codebase/book reading are incomplete and product source/book are unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.11 — read RuleIR and own edge-order repair

- Read all 987 lines / 31,462 bytes of RuleIR; sixteen whole Perl files covered.
- Public OR/AND controls and direct normalization prove bare-before-explicit execution-order drift while metadata
  retains authored order. Repair `.12` owns correction and carrier verification after mandatory reading.
- Focused identity/probes, Knowledge, memory/doctrines/history, and staged review; product source/book unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.10 — complete validation reading

- Read Validation.pm 1321–1904; all 1,904 lines / 61,929 bytes now covered, with fifteen whole Perl files read.
- Reconciled edge/slash/diagnostic owners and historical edge-card staging notes with current admissions.
- Focused identity/reading, Knowledge, memory/doctrines/history, and staged review. No source or book change.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.9 — read validation and own diagnostic repairs

- Read Validation.pm 1–1320 / 43,290 bytes. Direct and public probes confirm incorrect diagnostic context,
  repeated-line positions, and regex rule attribution; bounded repairs `.11.1`–`.11.3` are owned.
- Corrected stale Knowledge retrieval fields and the open-block reverify command. Invalid specs still reject;
  product source/book unchanged. Focused coverage/probes, memory/Knowledge/doctrines/history, and diff review.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.8 — read SpecEntry and own unbound input repair

- Read all 600 lines / 23,171 bytes of SpecEntry; fourteen whole Perl files covered. Validation reading follows.
- Reconciled two historical coupling cards. Isolated probes confirm AND_BCODE reads unbound package variables;
  repair `.10` owns explicit-state cleanup with current entry semantics preserved. No public result defect claimed.
- Focused proof: exact coverage/identity, descriptor/source and private controls, Knowledge, memory/doctrines/history,
  and staged review. Runtime source and public book remain unchanged during required reading.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.7 — complete compiler pipeline reading

- Read Compiler.pm lines 1042–2002; all 2,002 lines / 84,924 bytes now read, with thirteen whole Perl files covered.
- Reconciled existing state/root/generated/diagnostic owners and indexed source-level phase and return-mode boundaries.
- Focused proof: exact reading/identity, Knowledge, memory/doctrines/history, and staged review. Product and book unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.6 — read compiler generation and state assembly

- Read Compiler.pm baseline-identical lines 1–1041; generated-v2, state, slot, and diagnostic owners reconcile.
- Recorded the prior canonical PASS and dated macOS loader observations; linked the historical duplicate-slot
  finding to its existing resolution. Two consumed sample reports were hash-verified, removed, and checked absent.
- Focused proof covers exact reading/identity, Knowledge, memory/doctrines/history, and staged review. No source or book change.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.5 — read compiler state and preserve history

- Read all 590 baseline-identical CompilerState lines and reconciled existing descriptor ownership.
- Applied the required complete-record changelog rollover; exact history preservation and finite capacity
  admission accompany this checkpoint. Product behavior and required-reading status remain unchanged.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.4 — read bootstrap grammar core

- Read all 1,196 baseline-identical core lines; eleven Perl files now read. Next is CompilerState `.3.2.5`.
- Proved attached-tail regex delimiters truncate code: the quoted-pattern control returns 1; `/}/` fails handler
  compilation. Knowledge records the unreachable slash-quote condition; `.9` owns repair after required reading.
- Validation: untruncated reading/identity, existing Knowledge, exact scanner/helper/public controls, focused
  memory/doctrine/Knowledge/history checks, and staged review. No production or public-book change.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.3 — read resolution and bootstrap adapters

- Read five complete baseline-identical adapters: 1,103 lines / 36,759 bytes; ten Perl files now read.
- Proved stale bootstrap comparison state after an empty comparison; public Get still rejects malformed source.
  Knowledge records the exact mechanism and controls; `.8` owns repair after mandatory reading and cleanup `.7`.
- Validation: full reading/identity, existing contract retrieval, managed negative/positive/public-error probes,
  focused memory/doctrine/Knowledge, both history checks, and staged review. No production/public change.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.2 — partition remaining Perl reading

- Owned all 84 remaining baseline Perl paths in 52 bounded leaves, including exact byte fragments for the long
  generated MCP JSON payload. Independent interval checks prove 2,076,984 bytes covered once and all budgets met.
- Perl remains baseline-identical. No new reading credit or public change; `.3.2.3` reads the dependency group next.
- Validation: exact coverage/budgets/delta, focused memory/doctrine/Knowledge, history pressure, and staged review.

## 2026-09-06 — SESSION-STARTUP-READING.3.2.1 — read facade invocation owners

- Read all five exact facade/dispatch/runtime/parser-factory/context files through EOF: 1,430 lines / 56,706
  bytes. Reconciled owner flow and leading-trivia behavior with existing Knowledge rather than re-deriving them.
- Preserved complete source identity against the reading baseline. Codebase/book reading remains No; `.3.2.2`
  splits the remaining 84 Perl paths next. No runtime, public documentation, or new-defect claim changes.
- Validation: full bounded reading, baseline diff, managed facade/phase0 syntax, focused memory/doctrine/Knowledge,
  both history-pressure checks, and staged review.

## 2026-09-06 — SESSION-STARTUP-READING.3.1 — bound the codebase reading inventory

- Classified all 2,547 baseline Git entries with exact object-byte counts and disjoint selectors, including
  legacy code, fixtures, generated files, tooling, four compressed Unicode inputs, book, and durable-memory owners.
- Split the codebase reading into owned lanes and bounded the first executable child to five exact files;
  all later children require explicit byte/line ranges before reading. Inventory does not confer reading credit.
- Completed Toolbox reading, retained exact prior coverage, and verified source/test/tool/book bytes are unchanged
  from baseline. Roadmap remains Yes; codebase and mdBook remain No. Cleanup repair `.7` remains mandatory.
- Validation: exact Git/blob and decoded-data census, complete/disjoint accounting, current-delta review, focused
  continuity/doctrine/Knowledge/history checks, Perl syntax checks, and staged diff review. No production change.

## 2026-09-06 — SESSION-STARTUP-READING.6 — diagnose denied liveness probes

- Confirmed that restricted kill-zero inspection returns EPERM for a known live managed process, while current
  liveness helpers collapse all failures into false/dead. Restricted run listing reports abandoned; permitted
  inspection of the identical process reports live. Recovery uses the same unsafe authorization predicate.
- Recorded exact source locations and non-destructive paired evidence in a Knowledge card; repair `.7` is owned
  after mandatory reading and before recovery/purge or Rust mutation setup. No premature deletion was attempted.
- The controlled 45-second run completed normally with zero leftovers. Production and public book are unchanged;
  this narrow startup checkpoint records diagnosis and repair ownership, not a fixed-defect claim.
- Validation: exact controlled probe, source trace, focused memory/doctrine/Knowledge checks, history and diff review.

## 2026-09-06 — SESSION-STARTUP-READING.2 — complete roadmap reading

- Read the remaining baseline ROADMAP_V2.md lines 1341–1585 without truncation and reviewed both roadmap diffs.
  Roadmap reading is complete; codebase and mdBook reading remain incomplete.
- Reconciled current direction with task ownership and ADRs 0039/0073: finish startup reading, add safe Rust
  mutation configuration, then run a separately owned pilot. No feature or runtime-proof claim changes.
- Updated exact reading coverage and batch continuity; `.3` next inventories and decomposes codebase reading.
- Validation: focused memory/doctrine/Knowledge checks, both history-pressure checks, diff and staged-scope review.

## 2026-09-06 — SESSION-STARTUP-READING.1 — preserve required reading progress

- Added the director-authorized startup-tracking checkpoint with exact clean baseline, completed reading ranges,
  `rgx`/nested-dependency exclusion, remaining reading, and explicit No answers for all three full-reading gates.
- Aligned the task index, both roadmaps, and bounded continuity pointers. The next action finishes the roadmap
  reading; first-party codebase, mdBook, and supplied-policy review remain prerequisites to Rust mutation setup.
- Recorded the narrow documentation exception without changing doctrine, runtime behavior, or public teaching.
  No mutation campaign or feature implementation is claimed by this checkpoint.
- Verification is focused: memory/doctrine checks, both history-pressure checks, diff hygiene, and staged-scope
  review. The public book remains a product explanation; detailed reading progress lives in the task tree.

## 2026-09-05 — FUTURE-PARITY-BACKLOG.19.9 — close public mutation semantics

- Published exact current nested-write and `map_leaves!` semantics across the governed public surface. The primary
  mdBook guide now demonstrates missing-container creation, dense append and gap rejection, wrong-kind conflicts,
  evaluation order, original-shape traversal, callback fields, identity guarding, rollback, detached results,
  callback-local nested-write composition, and post-commit continuation.
- Corrected current-surface drift in the Dart guide and design/helper status prose: all five backends implement both
  admitted mechanisms, while non-bang `map_leaves` remains a detached non-mutating value form.
- Added `tools/check_mutation_public_surface.py`. It inventories 63 public Markdown files, requires exact anchors in
  14 mutation-owning documents, binds eleven semantic example classes to the unchanged frozen authorities, rejects
  ten stale-current claims, and rejects 50 isolated authority/document/status mutations.
- Registered the checker unconditionally in canonical CI and pinned its `.19.9` owner, tracked path, and exact-one
  execution through four capability-governance mutations. Its repository-routed Python entrypoint advances only
  the storage census from 37 to 38; temporary-owner counts remain three Python and 15 shell.
- Aligned ADR `0036`, its index, Knowledge Map cards, both roadmaps, architecture, Toolbox, capability guidance,
  task/index, live continuity, bounded histories, and the sole-facing mdBook. Parent `.19` closes without changing
  runtime production code, capability rows, generated carriers, or any of the three frozen JSON authority bytes.
- Re-ran the exact Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT mutation matrix plus generated-source, capability, and
  language ledgers, then passed focused storage/doctrine/book proof and receipt-bound staged canonical CI.

## 2026-09-05 — FUTURE-PARITY-BACKLOG.19.8 — register recurring mutation proof

- Added one repository-routed driver that validates the unchanged nested-write and `map_leaves!`/composition
  authorities, then executes their exact consumers on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT in fixed order.
- Followed the runtime routes with generated-source, capability, and language-coverage ledgers. Rust requests both
  integration targets in one Cargo invocation; Dart refreshes locked project-local metadata offline before its
  two separately reported suites.
- Bound the recurring owner, driver, CI switch, storage initializer, three exact authority digests/statuses,
  commands, route/support order, executable state, and exact-one canonical registration through 17 rejected
  recurring mutations in the capability checker.
- Registered unconditional tracked-file, path, and syntax checks in canonical CI plus one opt-in execution under
  `LINKEDSPEC_RUN_MUTATION_MATRIX=1`. No production behavior, frozen contract bytes, public-current examples,
  facade/schema/MCP/CLI contract, parent status, or push changed.
- Preserved the diagnosed stale-Dart-metadata wait and its offline safeguard in the Knowledge Map, synchronized
  task/index, roadmaps, architecture, Toolbox, capability guide, bounded live/continuity state, and the mdBook,
  and passed the complete recurring route plus focused/doctrine/storage/render and exact staged canonical proof.
- The required notes rollover creates immutable segment `4985-18da440ab1c4`; ADR `0101` advances only the finite
  engineering-notes collection/manifest capacity to 23/22 and leaves every byte and aggregate ceiling unchanged.

## 2026-09-04 — FUTURE-PARITY-BACKLOG.19.7 — admit portable mutation capabilities

- Restored the omitted `.19.8` recurring-proof and `.19.9` public-closeout task records promised by the prior
  `.19.7-.19.9` split, then narrowed `.19.7` to portable capability admission only.
- Added exact `language.nested_write_vivification` and `language.map_leaves_receiver_mutation` rows with pass
  evidence for Perl, Rust, Dart, Julia, and shared Lua plus explicit independent PUC Lua/LuaJIT execution.
- Advanced the current capability census from 18 rows / 90 pass states to 20 / 100 with no partial or gap state.
  Production behavior, public facade/schema/MCP/CLI surfaces, and frozen neutral contract bytes remain unchanged.
- Extended the capability checker to pin row order, contract text, sources, backend evidence, the Lua dual-ABI
  note, tracked owner state, neutral authority IDs/formats/statuses/canonical JSON digests, and the composition
  ID/path/digest dependency through 16 rejected admission mutations.
- Updated only the two neutral checker success summaries to say that their authority remains frozen and later
  capability admission is external, removing a stale global “unadmitted” claim without changing fixture bytes.
- Synchronized ADR `0036`, Knowledge Map sources, both roadmaps, architecture/live/continuity state, task/index,
  Toolbox, and sole-facing mdBook status. Recurring six-runtime execution remains `.19.8`; public-current examples,
  final no-drift, parent closeout, and push remain `.19.9`.

## 2026-09-04 — FUTURE-PARITY-BACKLOG.19.6.2 — implement Lua map-leaves receiver mutation

- Added the dedicated Lua `receiver_mutation_chain` for exact
  `binding.map_leaves!() { block }` syntax. Typed receiver, mutation call, callback body, ordinary continuation,
  authored source, and half-open Unicode-scalar spans survive action contracts and static projection.
- Validated the carrier at compile, direct-runtime, generated-plan, public `SpecFile` reconstruction, and source-
  emitter boundaries. Malformed or reserved programmatic state fails closed before execution.
- Added stable runtime binding identities across ordinary writes plus fresh callback and user-function identities.
  Direct assignment, append, nested write/bang, mutation helpers, array-end methods, regex substitution, and every
  binding-target array pipeline reject an active receiver before evaluating operands, segments, or RHS values.
- Implemented detached original-shape harray/array traversal, root-kind-only recursion, copied callback values and
  paths, non-revisited replacements, one atomic receiver publication, detached return, guaranteed guard release,
  and commit-before-continuation ordering. Unrelated and distinct same-spelling scoped writes remain ordinary.
- Added one permanent shared 530-assertion suite per ABI covering all frozen 4 valid / 14 invalid / 5 excluded
  syntax rows, 10 successes, 8 pre-commit failures, all 18 guarded write routes, six callback compositions, one
  continuation composition, detachment, native/reconstructed/generated/emitted/CLI routes, and user-function
  bodies. The adjacent write suite passes 438 assertions per ABI with the frozen typed bang-arguments diagnostic.
- Preserved Lua 5.1 compatibility at its 200-local chunk ceiling by publishing the coherent implementation under
  the existing private `typed_source.receiver_mutation` namespace. PUC Lua and LuaJIT syntax/load and complete
  execution remain identical.
- The unchanged neutral oracle rejects all 167 base and 592 composition mutations. The complete Lua local gate
  passes both ABIs, 178 integration cases each, CLI 66/66 in default and POSIX environments, corpus 105/105, and
  repository-local storage proof.
- Synchronized the parent task closeout, both roadmaps, Toolbox, live/continuity state, Knowledge Map sources, and
  sole-facing mdBook at the five-backend implementation boundary. Portable capability, recurring proof, and
  public admission remain owned by `.19.7-.9`.

## 2026-09-04 — RUST-DEPENDENCY-WARNING-ZERO.0 — own Rust warning cleanup

- Converted the director-identified canonical Rust warning stream into a dedicated non-blocking task tree rather
  than leaving it as a conversational observation. Repeated clean carriers report 1,870 `pgen` warnings with
  1,360 automated suggestions plus 26 `rgx-core` warnings; these remain output counts pending a unique-cause census.
- Recorded the nested repository boundary: LinkedSpec pins `rgx` at
  `8763a0e6bea97879f027237439d57725f83ead23`, and `pgen` is nested beneath it. Durable remediation therefore
  requires explicit upstream commits and reviewed gitlink integration.
- Split future work into census, authored `pgen`, generator/generated `pgen`, `rgx-core`, direct LinkedSpec,
  dependency-pin integration, and zero-warning enforcement leaves. Broad allowances, warning filtering,
  `RUSTFLAGS=-Awarnings`, blind `cargo fix`, and reduced canonical coverage are explicit non-solutions.
- Synchronized the task ledger, both roadmaps, architecture/live/continuity state, Knowledge Map source, and
  sole-facing project status without changing Rust source, dependency pins, generators, generated artifacts, CI,
  or runtime behavior. The non-blocking intake returns PNT to Lua `map_leaves!` `.19.6.2` after commit.

## 2026-09-04 — FUTURE-PARITY-BACKLOG.19.6.1 — implement Lua write vivification

- Unified authored Lua one- and many-segment bracket writes under one `assign_nested_access` `ActionExpr` with
  typed expression-bearing `ActionWritePathSegment` records, exact source, and half-open Unicode-scalar spans.
  Reserved, empty, unclosed, malformed, and non-addressable targets fail through structured parse diagnostics.
- Preserved and validated the carrier across action-contract and semantic-static visitors, compiler, public
  `SpecFile` reconstruction, direct runtime, generated plans, and source emission. Empty, malformed, or reserved
  programmatic paths fail closed at every executable boundary.
- Implemented segment-left-to-right then RHS evaluation, post-evaluation binding-presence snapshots, evaluated
  string/integer harray/array selection, dense absent-root/intermediate creation, isolated atomic publication,
  completed-expression-effect preservation, exact expression-failure identity, and detached mutable boundaries.
- Added exact `nested_write_segment_invalid`, `nested_write_kind_conflict`, and `nested_write_array_gap` runtime
  diagnostics. Bound null and wrong existing kinds are never coerced, and reads remain non-creating.
- Added one permanent shared Lua consumer covering all frozen 5 AST / 7 syntax / 11 success / 16 structural /
  3 expression-failure / 3 read-exclusion cases, exclusions, astral spans, detachment, fresh function state,
  corrupt/reserved carriers, and native/reconstructed/generated-plan/emitted-module/primary-CLI routes. It passes
  436 assertions on PUC Lua and 436 on LuaJIT and locks `map_leaves!` as still unsupported raw syntax.
- The complete Lua gate passes both ABIs, all 178 integration cases, CLI 66/66 in default and POSIX environments,
  corpus 105/105, and repository-local storage proof. The unchanged neutral checker rejects all 105 mutations.
- The full gate exposed stale cursor expectations in existing action-edge tests. Only expected endpoints change
  from 1 to 6: zero-regex `Top` enters its loop, whose edge selects and consumes `Done`'s regex for `xhello`.
  Runtime dispatch and fixture source remain unchanged, and the durable Lua action-edge fact now records the proof.
- Synchronized the Lua guide, sole-facing mdBook, architecture, ADR `0036`, Toolbox, task/index, roadmaps,
  Knowledge, and live pointers at the exact five-backend-write/four-backend-bang frontier. Receipt-bound canonical
  CI validates the final staged candidate; Lua `map_leaves!` and portable/public admission remain pending.

## 2026-09-03 — FUTURE-PARITY-BACKLOG.19.5.2 — implement Julia map-leaves receiver mutation

- Added the dedicated typed Julia `receiver_mutation_chain` for exact
  `binding.map_leaves!() { block }` syntax, retaining receiver, mutation, direct callback block, ordinary
  continuation, source projections, and half-open Unicode-scalar spans without widening identifiers or callees.
- Validated the carrier at compiler, direct-runtime, generated-plan, and source-emitter boundaries. Malformed
  reconstructed or caller-built receiver mutation state fails closed before execution.
- Added stable visible-binding identities plus fresh callback and user-function parameter identities. Every direct,
  nested, nested-bang, helper, array-end, regex-substitution, and binding-target pipeline write checks the active
  receiver identity before evaluating operands, segments, or RHS expressions; unrelated and same-spelling shadow
  writes retain ordinary behavior.
- Implemented detached original-shape hash/array traversal, root-kind-only recursion, copied callback frames,
  non-revisited detached replacements, one atomic receiver publication, detached return, unconditional guard
  release, and commit-before-continuation ordering. The non-bang twin remains non-mutating.
- Added a permanent 496-assertion suite covering every frozen success and failure row by stable ID, 18 guarded
  write forms, nested-write composition, detachment, shadowing, diagnostics, corrupt state, reconstruction,
  native/generated-plan/emitted-module/primary-CLI routes, and the zero-regex-parent/child-regex dispatch
  interpretation.
- Registered the emitted-module test as Julia's 22nd repository-local temporary owner. The unchanged neutral
  oracles still reject 167 base and 592 composition mutations; Lua, recurring proof, and portable/public admission
  remain pending.
- The mandatory complete-record rollover creates immutable change segment `4986`. ADR `0100` advances only the
  finite collection/manifest route from 26/25 to 27/26, preserves every byte and aggregate ceiling, and upgrades
  this slice to receipt-bound canonical verification.
- Final typed-state review found that a caller-corrupted top-level node `kind` could evade validation dispatch.
  Structural detection now rejects that carrier through compiler, runtime, generated-plan, and source-emitter
  boundaries, alongside malformed receiver projections.
- Guard integration preserves ordinary helper evaluation order and the four-argument statement-mutation threshold:
  three-argument `substr(value, start, length)` remains a pure discarded expression outside a callback, while an
  active-receiver attempt is still rejected before evaluating its operands.
