# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

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

## 2026-09-03 — FUTURE-PARITY-BACKLOG.19.5.1 — implement Julia write vivification

- Unified authored Julia one- and many-segment bracket writes under `ActionAssignNestedAccessExpr` with typed
  expression-bearing `ActionWritePathSegment` records, exact source, and half-open Unicode-scalar spans. Reserved,
  empty, unclosed, malformed, and non-addressable targets now fail through exact typed parse diagnostics.
- Preserved and validated the carrier across action visitors, callable/semantic contracts, compiled-state JSON
  reconstruction, generated plans, source emission, and direct runtime execution. Empty or malformed programmatic
  paths fail closed at every executable boundary.
- Implemented segment-left-to-right then RHS evaluation, post-evaluation binding-presence snapshots, evaluated
  string/integer harray/array selection, dense absent-root/intermediate creation, isolated atomic publication,
  completed-expression-effect preservation, and detached mutable ingress/egress.
- Added exact `nested_write_segment_invalid`, `nested_write_kind_conflict`, and `nested_write_array_gap` Julia
  diagnostics. Bound null and wrong existing kinds are never coerced; expression failures preserve identity;
  reads remain non-creating; Julia `map_leaves!`, Lua, and portable/public admission do not move.
- Added permanent fixture-driven proof for all 5 AST / 7 syntax / 11 success / 16 structural-failure / 3
  expression-failure / 3 read-exclusion cases, four exclusions, astral spans, detachment, fresh function state,
  corrupt carriers, and native/reconstructed/generated-plan/emitted-module/primary-CLI routes. The focused suite
  passes 406 assertions and the unchanged neutral checker rejects all 105 mutations.
- The complete Julia package suite, primary CLI, and corpus 105/105 pass. Project-data containment registers the
  exact 21st temporary owner, retains five locked package trees, and corrects only its stale hard-coded 20-owner
  success sentence after the substantive 21-versus-21 inventory comparison already passed.
- Synchronized the task/index, Knowledge, ADR `0036`/index, architecture, roadmaps, Toolbox, continuity docs, and
  sole-facing mdBook. This also corrects two stale current Dart-bang book sentences and the task registry's stale
  pre-Dart frontier while preserving dated history. Exact staged canonical CI binds the completed candidate.

## 2026-09-02 — FUTURE-PARITY-BACKLOG.19.4.2 — implement Dart map-leaves receiver mutation

- Added the dedicated typed Dart `receiver_mutation_chain` carrier for exact
  `binding.map_leaves!() { block }` syntax, including typed receiver, callback, continuation, source, and
  Unicode-scalar spans. Invalid bang spellings and corrupt serialized state now fail through exact diagnostics.
- Implemented detached original-shape harray/array traversal, copied callback frames, result replacement without
  revisit, atomic one-time receiver publication, detached return, and commit-before-continuation behavior.
- Added stable runtime binding identities and guarded every direct, nested, helper, array-end, and binding-target
  pipeline write route before operand/segment/RHS evaluation. Distinct same-spelling scoped identities and
  unrelated writes remain legal; callback failure releases the guard without publishing a partial receiver.
- Preserved the existing `FUTURE-PARITY-BACKLOG.5` ownership of Dart statement write-back gaps for
  `split_each`, `filter_match`, and `uniq`; this slice recognizes and guards those attempts without widening their
  ordinary behavior.
- Corrected the composition contract's two stale `Top:: /x/ -> Done` current-boundary sources to zero-regex
  `Top:: -> Done`. This locks the established semantic that entering `Top` runs its loop while the outgoing edge
  selects and matches `Done`'s regex; no expected runtime value or mutation inventory changed.
- Added permanent Dart native/reconstructed/generated/emitted/independent-caller/CLI proof. The exact contract
  remains 4 valid / 14 invalid / 5 exclusions / 10 successes / 8 failures, 167 base + 592 composition mutations;
  the write checker remains 5/7/11/16/3/3 plus 105 mutations. Dart format 111/0, analysis, package 461/461,
  storage 25 owners / 47 packages, CLI 66/66 twice, and corpus 105/105 pass.
- The dedicated root-selection proof passes Perl 12/12, Rust/Dart 1/1, Julia 137/137, both Lua ABIs 139, the exact
  5-backend x 2-environment x 6-case CLI matrix, and all generated/capability/language ledgers.

## 2026-09-02 — FUTURE-PARITY-BACKLOG.19.4.1 — implement Dart write vivification

- Unified every authored Dart bracket write, including one-segment assignment, under one
  `ActionAssignNestedAccessExpr` with expression-bearing `ActionWritePathSegment` values, exact source, and
  half-open Unicode-scalar spans. Seven malformed/non-addressable forms now fail through exact typed parse errors.
- Preserved the carrier through callable/compiled-state validation, `SpecFile` JSON reconstruction, generated
  plans, emitted source, independently analyzed/executed caller-package code, and the primary CLI. Malformed or
  empty serialized segment sequences fail closed.
- Implemented segment-left-to-right then RHS evaluation, post-evaluation presence snapshots, evaluated
  string/integer harray/array selection, dense absent-root/intermediate creation, isolated atomic publication,
  completed-expression-effect preservation, and detached mutable boundaries.
- Added exact `nested_write_segment_invalid`, `nested_write_kind_conflict`, and `nested_write_array_gap` runtime
  diagnostics. Bound null and existing wrong kinds are never coerced; reads remain non-creating; Dart
  `map_leaves!`, Julia/Lua behavior, and portable/public admission do not move.
- Added permanent fixture-driven Dart proof for all 5 AST / 7 syntax / 11 success / 16 structural-failure / 3
  expression-failure / 3 read-exclusion cases plus detachment, functions, astral spans, malformed carriers, and
  every supported execution route. The neutral checker retains all 105 rejected mutations.
- The complete Dart gate passes format 110/0, strict analysis, 450/450 package tests, 24 managed temporary owners /
  47 locked packages, CLI 66/66 in default and POSIX environments, and corpus 105/105. Task/index, Knowledge,
  architecture, roadmaps, continuity docs, and the sole-facing mdBook now name Perl/Rust/Dart vivification and
  Julia/Lua's remaining boundary. Exact staged canonical attempt one also catches and repairs the stale public-
  Markdown cardinality guard left when `.19.3.4.0` added the macOS launch-latency page: the corrected public
  selector proof is 62 files / 32 classified historical references / zero current examples. Restarted exact
  staged canonical CI binds the final candidate before commit.

## 2026-09-02 — FUTURE-PARITY-BACKLOG.19.3.4.0 — classify macOS Rust first-launch latency

- Separated dependency compilation, linking, first process launch, and test execution under controlled serial,
  repository-managed runs. Two older distinct `trace_controls` binaries first-listed in 45.32 and 51.75 seconds,
  then repeated in 0.00 seconds without executing a test body.
- During both delayed launches, the Rust process was not yet visible and `syspolicyd` owned substantial CPU; prior
  stack evidence fixed the wait at `_dyld_start`, before Rust `main`. The delay is therefore macOS per-artifact
  policy/cache assessment, not a LinkedSpec test loop.
- Built two unique controls in isolated same-volume targets in 37.18 and 23.17 seconds. The first hash's signed-
  copy/original pair launched in 0.44/0.45 seconds; the second hash remained wholly unmanipulated and launched in
  0.41 seconds, excluding a persistent source, build, storage, signature form, provenance, or first-launch defect.
- Classified the original canonical interval separately from its independently observed target deletion and
  `cargo sweep` interference. No Gatekeeper weakening, provenance clearing, prelaunch, re-signing, cache-layout
  change, or test-coverage reduction is justified; repair leaf `.19.3.4.1` closes as not required.
- Added durable Knowledge, Toolbox, and mdBook guidance for future diagnosis, synchronized the task/index,
  roadmaps, live status, memory, changes, and engineering notes, and closed the Rust `.19.3` lane with focused
  documentation/doctrine proof. Dart nested write-vivification `.19.4.1` is next.

## 2026-09-01 — FUTURE-PARITY-BACKLOG.19.3.3 — restore exact oracle and root-target semantics

- Reproduced the `capability_position_helper_surface` drift through current Perl and Rust before changing the
  oracle. The expectation was correct: Perl skipped the child after strict source-location projection received an
  absent local-match offset, while Rust retained the rich committed result.
- Corrected all nine Perl local-match projections to distinguish absent state from a real zero-width match at
  offset zero. Structural length/start/end values remain null when absent, display lines/columns retain their
  one-based default, and present zero-width positions remain concrete.
- Replaced 67 inline and one source-backed inert `Top:: /x/ -> Done` controls with zero-regex roots. This locks the
  language rule that selecting a root starts its handler loop; only an outgoing edge selects and tests its target
  rule's regex. Expected values, input bytes, and manifest bytes are unchanged.
- Added a neutral fixture-shape guard and complementary Rust traces: direct entry is lifecycle-positive and own-
  regex-negative, while a zero-regex `Top` edge selects `Done`, enters it, and records exactly one successful
  target-regex match.
- Ran two complete repository-routed Perl generations across all 105 fixtures. Both produced the same 68 input-
  only changes at SHA-256 `4df3a7eec18215dc05d823089abc2635fbd9f7df3827fc4fe5cfcafb8eba7e21`.
- Repaired pre-existing full-corpus blockers without widening language contracts: Dart and Julia now accept legal
  whitespace in `I.return ([])`, and Dart's bounded structural bridge recognizes only the exact complete-line
  `blkLBL`/`blkSLB` self-hosted patterns. Complete Rust, Dart, Julia, PUC Lua, and LuaJIT corpus routes pass 105/105
  with unchanged expectations.
- Corrected one stale Dart `next()` test to give its block action-edge ownership through `-> Skip { next() }` plus
  child `Skip: /skip/`. The established result remains `keep` at cursor eight; production Dart parsing and
  execution do not move.
- Routed the new absent-match explanation into its own focused Knowledge card because the canonical typed-source
  rollout card had only six bytes of headroom. The original card remains unchanged and every existing per-file,
  collection, aggregate, and README pressure limit remains fixed.
- Root-caused an abnormally slow cold Rust verification boundary far enough to exclude the semantic test itself:
  after a 55m44s build, the launched binary remained in macOS `_dyld_start` while `syspolicyd` was active. Opened
  measured audit/repair task `.19.3.4`; this slice changes no trust policy or verification topology.
- Synchronized task/index, Knowledge Map, bounded status/memory/engineering notes, and mdBook teaching with the
  exact cross-runtime entry-versus-target-regex invariant.
- Completed the composed proof: recursive observation passes all six runtime routes; root selection passes exact
  Rust 1/1, Dart 1/1, Julia 137/137, PUC Lua 139, and LuaJIT 139 admission consumers plus the 5×2×6 CLI matrix;
  the repository-managed trace suite passes 12/12. Generated-source 105/105, capability 90/0/0, and language
  coverage 250 current names / 105+1 fixtures / 126 public Perl contracts remain green.
- Canonical Phase 0 exposed three stale exact-string expectations for the repaired local-match start, length, and
  end projections. Aligned only those test-oracle strings with the already-proven two-register guards; direct
  probes, the 202-projection contract, and the complete Phase-0 file pass 1,032/1,032 without production movement.
- Exact staged canonical signoff passes all nine doctrines, the complete recurring cross-backend composition,
  repository storage/process locality and relocation, both 66/66 CLI environments, and Phase 0 1,032/1,032 in
  1,000 seconds. The staged receipt is bound to the clean activation HEAD and exact landing candidate.
- A canonical-run process census also caught an independent Claude-owned cleanup deleting four repository-local
  Rust target/cache directories and running `cargo sweep --time 7`; a separate MCP binary waited over five minutes
  in `_dyld_start` before passing 3/3 in 2.43 seconds. Queued `.19.3.4.0` owns controlled serial classification;
  this leaf changes no trust, cache, or verification policy.
- The complete closeout note triggers the governed engineering-history rollover: 218 clean-HEAD lines become
  immutable segment `4986`, leaving the hot root at 247/512 lines. ADR `0099` admits only collection file capacity
  21→22 and manifest lines 20→21; all byte, segment, aggregate, route, lifecycle, verifier, and storage ceilings
  remain fixed.

## 2026-09-01 — FUTURE-PARITY-BACKLOG.19.3.2 — implement Rust map leaves mutation

- Added the dedicated Rust `receiver_mutation_chain` carrier for only bare
  `IDENTIFIER.map_leaves!() { ACTION_BLOCK } CONTINUATION*`, with exact typed receiver/callback/continuation
  structure and authored Unicode-scalar spans across compiler validation, serde, generated plans, and emission.
- Added stable runtime binding identities and an active-receiver guard. Direct assignment/append, nested write or
  bang, mutation helpers, array-end methods, and binding-target pipelines reject before operand/segment/RHS
  evaluation only when they resolve to the guarded receiver; same-spelling shadows and unrelated bindings remain
  legal.
- Implemented detached original-shape traversal by root kind, copied callback frames, non-revisited replacement,
  one atomic publication, exception-safe guard release, ordinary unrelated effects, detached returned roots, and
  commit-before-continuation semantics.
- Added permanent Rust proof for all frozen 4 valid / 14 invalid / 5 excluded syntax cases, 10 successes, 8 pre-
  commit failures, special state boundaries, six callback compositions, one continuation composition, malformed
  carrier rejection, and native/serde/generated/emitted/independently compiled execution.
- Focused proof passes 9/9 integration and 3/3 private failure-state tests; the unchanged neutral checker rejects
  all 167 base and 592 composition mutations. No Dart/Julia/Lua or portable capability admission moves.
- The required complete Rust component gate exposed and repaired one stale trace assertion: direct entry starts
  `Top`'s handler/lifecycle loop but does not test `Top`'s own inert regex. The corrected negative lock passes the
  trace target 11/11 and the complete Rust local gate; production dispatch behavior is unchanged.
- Synchronized ADR `0036`, Knowledge, task/index, roadmaps, architecture/capability/Toolbox guidance, bounded live
  docs, and the sole-facing mdBook. The already-owned `.19.3.3` root/target-regex oracle cleanup follows.

## 2026-09-01 — FUTURE-PARITY-BACKLOG.19.3.1 — implement Rust write vivification

- Replaced Rust's static quoted-key/computed-index lowering with one `WritePathSegment` carrying typed expression,
  source, and Unicode-scalar span. One `AssignNestedAccess` now owns one- and many-segment assignments; exact
  syntax diagnostics and scalar-assignment-RHS parsing retain the frozen boundaries.
- Added compiler/callable validation and fail-closed checks at direct engine, serde/generated-plan, source-emitter,
  and decoded emitted-plan seams. Native, serialized, generated, emitted, and independently compiled emitted Rust
  preserve the same typed node rather than reconstructing a lossy key/index path.
- Implemented segment-then-RHS evaluation, post-evaluation binding snapshot, evaluated string/integer harray/array
  selection, absent root/intermediate creation, dense arrays, bound-null/wrong-kind/gap rejection, exact typed
  errors, isolated atomic publication, completed-expression-effect preservation, and detached values.
- Added permanent fixture-driven Rust proof for all frozen AST/syntax/success/failure cases, user-function presence,
  evaluation/detachment/read exclusions, corrupt carriers, and every supported execution route. Focused proof
  passes 5/5 contract tests, 197/197 integration tests, all 105 oracle fixtures, and both neutral mutation checkers.
- Corrected the owned oracle case from obsolete soft-null behavior to vivifying success. Full regeneration exposed
  an unrelated pre-existing expectation drift and inert root regexes; the unrelated file is restored and exact
  repair/systematic cleanup is task-tree-owned by `.19.3.3`. New fixtures use a zero-regex parent whose edge
  selects the child regex, matching runtime semantics.
- Synchronized ADR `0036`, Knowledge, task/index, roadmaps, architecture, capability/Toolbox guidance, bounded live
  docs, and the sole-facing mdBook. Rust `map_leaves!`, Dart/Julia/Lua, and portable/public admission remain pending.

## 2026-08-31 — FUTURE-PARITY-BACKLOG.19.2.2 — implement Perl map leaves mutation

- Implemented only bare `IDENTIFIER.map_leaves!() { ACTION_BLOCK }` on Perl as a dedicated
  `receiver_mutation_chain`, preserving the frozen 4 valid / 14 invalid / 5 exclusion syntax boundary and exact
  authored Unicode-scalar spans. Arbitrary bang identifiers/functions/methods remain invalid.
- Added an original-shape, root-kind traversal runtime over a detached snapshot. Copied callback `value`,
  `path`/`@path`, `depth`, and `key|index` bindings produce replacement leaves; aggregate replacements are not
  revisited. Complete success publishes one detached rebuilt root atomically and returns another detached value.
- Guarded the actual receiver scalar-slot identity during callbacks. Direct assignment, nested write/bang,
  `set`, `set_key`, `push`, array-end methods, and binding-target array pipelines reject before writing; unrelated
  bindings and distinct same-spelling shadows remain legal. Failure leaves the receiver unchanged and releases
  the guard; ordinary continuation starts after commit.
- Signoff expansion caught the documented three-argument `split(target, source, delimiter)` statement taking an
  AST unsupported-helper route inside callbacks instead of the array-pipeline owner. Statement lowering now sends
  every binding-target pipeline spelling through that owner first; exact guard/span proof covers all eight names,
  all four array-end methods, and a composed pipeline.
- Applied the director-selected pure-function carrier correction: inline explicit-target `set` proves helper-
  mediated rejection and caller-scoped `.with` proves post-commit writes. No implicit caller capture or arbitrary
  user-defined bang method was added. The corrected composition corpus retains its observations at 592 mutations.
- Added permanent fixture-driven Perl projection. Fatal-warning focused proof passes 58 tests; neutral checkers
  pass 105 write and 167 base + 592 composition mutations; Phase 0 passes all 1,032 tests in 1,016 seconds.
  Rust/Dart/Julia/Lua, generated formats, capability/public admission, facades/schemas/MCP, and CLI remain unchanged.
- The complete record required a bounded change-history rollover. Immutable segment `4987` and ADR `0098` advance
  only finite collection/manifest capacity to 26/25; unchanged aggregate and byte ceilings remain below limits.
  This infrastructure movement upgrades the leaf to receipt-bound canonical verification.

## 2026-08-31 — FUTURE-PARITY-BACKLOG.19.2.2 — record function-scope contract blocker

- Activated the Perl `map_leaves!` leaf from clean `6b960624` and confirmed two future helper carriers assume
  caller binding capture forbidden by the admitted fresh function-local contract. Exact Perl proof keeps caller
  `tree`/`audit` unchanged; existing explicit-target `set` and caller-scoped `.with` can carry the intended proof.
- Recorded the unresolved director choice across task/index, ADR, Knowledge, roadmap, architecture, Toolbox,
  continuity docs, and mdBook. No contract fixture, parser, runtime, backend, capability, or public behavior moves.
