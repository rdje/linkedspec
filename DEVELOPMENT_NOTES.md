# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.5.2` — Julia private native gap execution): activation base is clean
  atomic 241 at `3a620ec0`; the explicit native group first reaches exact unsupported helper `gap_kind`.
- Put gap state on `_InvocationState` and its existing transaction snapshot. Capture activation, input/invocation
  identity, entry slot, committed cursor/count/current context, rollback, and nesting belong there; observed
  `RecognitionFrameState` remains the exact detached cursor/boundary/marks projection.
- Only flagged rules may preselect before `LS`. Candidate visibility spans action, child entry, and `LE`; commit
  uses the child-extended post-`LE` cursor before `IT`. Successful minimum installs a terminal tail before the
  existing `LX`/`EX`/`E` routes. Failed minimum and whole-rule unwind commit neither match nor synthetic tail.
- Entry identity is a detached five-field record. Runtime registers remain zero-based UTF-8 code units, and the
  existing immutable input `SourceAuthority` is the only bridge to detached Unicode-scalar spans and exact text.
- `entry_slot`, `gap_span`, `gap_text`, and `gap_kind` are resolver-private zero-argument runtime calls. Do not put
  them in `_SUPPORTED_ACTION_IR_CALL_NAMES`: the duplicate-slot matrix caught that widening because Dart/Julia
  supported inventories stopped agreeing. The separate `inter_match_gap` family preserves exact inventory 246.
- Exact diagnostics remain structured runtime envelopes: unavailable context uses stage `access_gap_context` and
  code `gap_capture_context_unavailable`; cursor regression uses stage `advance_gap_context` and code
  `source_location_cursor_regression`. All four helpers reject nonzero arity before runtime access.
- Focused signoff is explicit 105 metadata + 33 native, complete Julia package/primary/storage 19/5/corpus,
  neutral/rooted 4/5/57, duplicate-slot 7/0/59, recognition 137/246/58, typed-source 9/5/114, rendered book
  79/14,872, Knowledge 838/7,072, bounded histories, and all nine doctrines. Reconstruction/generated/emitted/primary admission,
  rollout, and outward surfaces remain `.5.3-.5.5`-owned, so canonical CI is not triggered.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.5.1` — Julia authored/static/compiled metadata): activation base is clean
  atomic 240 at `12a14ed0`. The permanent consumer is explicit-only; the neutral checker mutation-locks its
  identity, metadata role, contract source, parse/validate/compile seams, diagnostic token, discovery/rooted
  absence, and facade absence.
- Keep authored selector identity separate from resolved execution identity. `EdgeTarget` owns
  `selector_kind`/`authored_selector`; compilation resolves exact target index and nullable slot name once.
  Compiled JSON owns the new rows, while descriptor serialization deliberately calls the legacy edge projector.
- Named regex declarations reuse the generated pinned Unicode-17 rule-label classifier. Anonymous and named rows
  share one zero-based order; ASCII-digit-only names remain reserved for numeric brackets, and duplicate regex
  text never substitutes for stable slot identity.
- Validate slot declarations before generic raw syntax, selectors before directive eligibility, and flagged
  directive eligibility before generic mixed-edge rejection. Unflagged legacy diagnostics retain their prior
  route; flagged rules receive exact ownership/mode evidence, and named `@mark(...)` remains independent.
- `SpecFile.source_id` is logical provenance, never resolved host authority. Preserve it through every parser/
  stitching copy. Relative loaded requests retain caller spelling; absolute requests reduce to basename. The
  complete Julia suite caught the first implementation leaking scratch paths into `to_json(compiled)`.
- Do not claim emitted workspace ownership early. The dormant metadata consumer proves loaded parsing by invoking
  the production `_parse_loaded_spec` boundary over an in-memory `LoadedSpec`, so storage remains exactly 19
  owners / 5 packages; `.5.4` still exclusively owns 19→20.
- The implementation changes no recognition invocation, runtime matcher/interpreter, accessor dispatch,
  descriptor metadata, generated plan, emitter API, primary command, rollout, dependency, or facade. `.5.2-.5.5`
  retain those boundaries in dependency order.
- The mdBook audit repaired two stale Dart metadata-only sentences left after `.4.5`; current teaching now clearly
  distinguishes admitted Perl/Rust/Dart behavior from dormant Julia metadata.
- Focused signoff is explicit metadata 105, direct dependents 624, full Julia package plus primary/storage 19/5/
  corpus 105, rooted neutral/Perl/Rust/Dart with three skips, duplicate-slot 7/0/59, recognition 137/246/58,
  typed-source 9/5/114, book 79/14,868, Knowledge 838/7,071, bounded histories, and all nine doctrines. ADR `0076`
  authorizes only the required 18th change-history member / 17th manifest row; aggregate ceilings do not move.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.5.0` — behavior-free Julia gap plan): activation is clean atomic 239
  `43ed1c8f`; the only pre-audit edit was the owning task-tree leaf, and no production/test behavior moves.
- Process probes are decisive: numeric `Item[1]` parses/compiles; `name=/a/`, `Item[name]`, and `@capture_gaps`
  remain raw invalid body syntax. `entry_slot`, `gap_span`, `gap_text`, and `gap_kind` parse as action calls and
  fail through the existing structured unknown-helper envelope. Legacy `@move_pos` parses as a split marker but
  is ignored by compilation/runtime. The primary adapter rejects the complete future source at compilation.
- A repeated-OR trace runs enclosing `LS` before candidate selection. Preserve that order for unflagged rules;
  capture-enabled rules alone preselect/install before `LS`, retain through target/`LE`, commit accepted post-`LE`
  cursor before `IT`, and install successful tails before existing `LX`/`EX`/`E`.
- Extend the existing private recognition invocation/token; do not widen detached `RecognitionFrameState` or add
  a parallel cursor/stack. Token rollback owns mutable gap cursor/count/current state. Runtime registers remain
  zero-based UTF-8 code units and cross the current immutable input `SourceAuthority` only at scalar projection.
- `.5.1` owns logical source, Unicode-17 declarations, selector/directive/static/compiled provenance, diagnostics,
  and a permanent dormant consumer. `.5.2` owns native state/accessors. `.5.3` owns normalized reconstruction,
  compatible descriptor additions, and unchanged-v2 generated execution. `.5.4` owns one repository-routed
  emitted host with ten value/two typed-error modules and exact storage 19→20. `.5.5` alone owns primary,
  nine-role admission, Julia 5/4/58 promotion, registration, and parent closeout.
- Focused baseline is duplicate slot 121, cursor 104, recognition 207, typed source 127, and source emitter 65 =
  624 assertions, plus existing primary process conformance and storage 19 owners / 5 packages. Gap remains
  neutral/Perl/Rust/Dart plus three skips at 4/5/57; outward and generated-format surfaces remain unchanged.
- README pressure correctly rejected the first 663-line ADR projection against its 640-line cap. Compress the
  adjacent Dart/Julia planning amendments into decision-sized pointers to their canonical Knowledge/task owners;
  ADR `0045` returns to exact 640 lines and all nine doctrines pass without losing implementation detail.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.4.5` — Dart primary/private admission): activation base is clean atomic
  238 at `6a554312`; no implementation, contract, checker, driver, or roadmap repair preceded task ownership.
- Primary parity belongs inside the permanent final consumer and must reuse `runLinkedSpecDartPrimaryCli`; no
  second CLI or direct engine shortcut is an admissible primary role. The mixed-separator case returns four item/
  gap pairs with exact empty, comma-space, bar-space, and newline-dash gaps.
- Role admission is executable composition, not a list assertion. Read the nine ordered roles from the neutral
  contract, reject key/order drift, execute each real owner exactly once, and reject missing or duplicate roles.
- Remove the library skip only at the admission boundary. Ordinary discovery, canonical CI, and the rooted route
  must each contain the final consumer once; the rooted order is neutral, Perl, Rust, Dart, then three explicit
  later-runtime skips.
- Exact Git/contract history disproves the `.4.0` assumption that `dart_runtime_premature` could be replaced.
  Rust admission had already consumed `rust_runtime_premature` without creating a Dart successor. ADR `0074`
  therefore preserves all 56 current mutations and adds `dart_runtime_regression` as 57.
- Ten Dart admission mutations now lock consumer identity, role ledger, ordinary/canonical/recurring registration
  and multiplicity, later-runtime skip, and facade absence. Recurring/public rows, Julia/Lua, typed composition,
  generated plan v2, primary adapter, CLI, schemas, README, dependencies, and toolchain remain unchanged.
- The required complete-record rollover publishes segment 4995 and makes the collection 13 files / 12 manifest
  rows. The first canonical precursor correctly rejects the prior finite 12/11 registry cap. ADR `0075` changes
  only those two maxima; all byte, root, segment, aggregate, lifecycle, verifier, and storage controls stay fixed.
- Focused signoff is primary 1/1, ordinary consumer 5/5, Dart format 102/0 plus analyzer and 407 tests, storage
  23/47, CLI 66x2, corpus 105, gap 4/5/57, rooted four-runtime execution, recognition 137/246/58, duplicate slot
  7/0/59, and typed source 9/5/114. Canonical CI passes all nine doctrines, containment/relocation, CLI 66x2, RAM
  57%, Phase 0 1,031/1,031 in 753 seconds, exact gap routing, receipt generation, and exit 0; parent `.4` closes.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.4.4` — independent emitted Dart proof): activation base is clean atomic
  237 at `4c8ab7ee`; the final consumer remains library-skipped and rollout remains 3/6/56.
- Use one caller package for the emitted stage, with its own repository-routed `PUB_CACHE`, offline resolution,
  strict analysis, and paired direct/traced entrypoints. This proves isolation without multiplying package state.
- Ten value modules cover every frozen lifecycle/value/compatibility case; two error modules lock the generated
  unavailable-context and cursor-regression envelopes. Every result is compared with current native authority.
- Traced roles must exercise the actual traced generated entrypoint with per-case logical source and trace files;
  a disabled-trace alias would not prove emitted trace routing.
- `Directory.systemTemp` is safe only through `run_dart_project_data.sh`; enumerate this consumer as owner 23 and
  prove complete caller/cache/output/trace cleanup. No production emitter or generated-format repair was needed.
- Focused signoff is emitted 1/1, explicit consumer 4/4, direct dependents 100/100, Dart 402 plus one skip,
  storage 23/47, CLI 66x2, corpus 105, gap/recognition/duplicate/typed matrices, rendered book, Knowledge Map,
  bounded histories, and nine doctrines. Canonical admission remains exclusively `.4.5`.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.4.3` — Dart reconstructed/descriptor/generated carrier): activation base
  is clean atomic 236 at `0b074e1c`; the permanent consumer stays library-skipped and rollout stays 3/6/56.
- Keep normalized `SpecFile` JSON as the single Dart carrier. Reconstruction must parse that detached value and
  compile normally; do not add a descriptor decoder, gap-only payload, or second runtime state model.
- Add provenance without widening meaning. `regex_slots`, `capture_gaps`, and `resolved_slot_edges` are separate
  rule-metadata projections; legacy semantic `resolved_edges` and dependency refs remain byte-shape compatible.
- Generated-plan execution is not a second executor in Dart. Direct and traced generated entrypoints validate the
  v2 `{label,family}` plan and call `LinkedSpecRuntimeEngine`, so the correct repair is descriptor projection plus
  proof of the already-shared native lifecycle and typed failure paths—not duplicated gap logic.
- Loaded descriptor identity tests must use caller-logical repository-relative request names when exact equality
  includes source provenance. Persisting a resolved scratch/host path would violate the relocatable source model.
- Complete-Dart proof found this same issue in the root-selection direct dependent; route-relative request names
  and matching `parseSpec(sourceId:)` identities repair the fixture, and targeted proof passes 3/3.
- The startup audit found atomic 236 updated the detailed gap chapter but omitted `overview/project-status.md` and
  the top architecture summary. `.4.3` owns and records that past-sync correction so roadmap, code, and book are
  locked together rather than merely reporting the drift.
- Focused signoff is explicit carrier 3/3, direct dependents 100/100, Dart 402 plus one intended skip, storage
  22/47, CLI 66x2, corpus 105, unchanged gap 3/6/56, recognition 137/246/58, duplicate slot 7/0/59, typed source
  9/5/114, book 79/14,816, Knowledge 837/7,052, bounded histories, and all nine doctrines. ADR `0073` correctly
  excludes the canonical gate because this leaf changes no admission, public contract, generated format,
  dependency/toolchain, CI/hook/gate, storage/path, or doctrine infrastructure.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.4.2` — Dart private native execution): activation base is clean
  workflow-policy atomic 235 at `c234ef9f`. The permanent final consumer stays library-skipped; explicit execution
  is the only pre-admission path. Its deliberate RED reached exact unknown-helper `gap_kind` before runtime work.
- Keep one authority. `RecognitionTransactionAuthority` now owns capture activation, immutable input/invocation
  identity, detached entry-slot identity, and a private three-value mutable snapshot. Do not widen
  `RecognitionFrameState`, create a parallel cursor, or duplicate transaction semantics.
- Selection must precede `LS` only for capture-enabled rules. Install the candidate after local-match selection,
  retain it through action/child/`LE`, commit the child-extended cursor before `IT`, and install a tail only for a
  successful terminal path. The unflagged loop retains its old `LS` ordering.
- Gap spans originate in Dart code-unit registers but cross `SourceAuthority` before actions observe them. This
  yields scalar offsets for Unicode input while `gap_text()` materializes exact decoded source. Entry identity is
  accepted only from the active parent candidate and is returned as a fresh five-field ordinary map.
- Recognition rollback restores committed cursor, accepted count, and current candidate from the existing token.
  Nested gap owners temporarily replace only the active invocation view; return restores the parent candidate.
  Falsey action payloads remain accepted, whole-rule returns do not commit, failed minimums expose no tail, and
  direct entry has no slot.
- Exact private errors are `gap_capture_context_unavailable` and `source_location_cursor_regression`; both retain
  typed records internally and map to the existing runtime diagnostic envelope without a public schema change.
- Focused signoff is explicit consumer 2/2, private authority 2/2, direct runtime/recognition/source/cursor/slot/
  recursion dependents, neutral 3/6/56, rooted neutral→Perl 124→Rust 1 with Dart skipped, and complete Dart-local
  format 102/0, strict analysis, 402 plus one skip, storage 22/47, CLI 66x2, and corpus 105. Book 79/14,812,
  Knowledge 837/7,052, and all nine doctrines pass. ADR `0073` correctly excludes full canonical CI because
  `.4.2` changes no admission, public contract, generated format, dependency, toolchain, CI/hook/gate,
  storage/path, or doctrine infrastructure.

- 2026-08-15 (`VERIFICATION-CADENCE-POLICY.0` — proportional verification): the canonical gate remains the source
  of truth, but it is no longer an ordinary per-commit tax. Focused leaves must name exact changed behavior,
  direct dependents, relevant component gates, and the always-on structural/documentation checks. Designated
  admission, milestone, public/cross-backend, dependency/toolchain, CI/hook/gate, and storage/path/doctrine leaves
  remain canonical.
- Canonical evidence is content-addressed. `tools/verification_receipt.sh` fingerprints base `HEAD` plus the
  SHA-256 of Git's full-index binary staged diff, refuses unstaged/untracked inputs, and writes only after
  `tools/run_ci_local.sh` succeeds. Pre-commit validates that receipt; post-commit promotes it only when the exact
  parent-to-commit diff became `HEAD`;
  pre-push reuses exact committed proof or runs canonical CI once.
- This avoids both stale-log trust and redundant immediate pre-push reruns. A later focused commit changes the Git
  identity and naturally invalidates the receipt. Hooks remain bypassable because hosted CI is disabled; the
  honest guarantee is strong normal-workflow enforcement, not literal impossibility.
- Focused policy proof is 15 classifier/tier plus nine receipt cases, shell syntax, dirty pre-push rejection,
  Knowledge 837/7,049, book 79/14,796 KiB, bounded-history/diff checks, and all nine doctrines. This foundational
  gate/hook leaf also passes the full canonical gate and exact staged-candidate receipt before landing.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.4.1` — Dart authored/static/compiled metadata): activation base is clean
  atomic 233 at `e40de948`. The final consumer is a library-skipped, final-path contract artifact rather than a
  temporary test; the neutral checker mutation-locks its identity, metadata role, contract source, parse/
  validation/compiler boundaries, canonical/recurring absence, diagnostic token, and facade absence.
- Keep selector authorship separate from resolution. `EdgeTarget` retains `selector_kind` and
  `authored_selector`; compilation resolves the target rule's authored slot order once and records
  `target_rule`, `child_regex_index`, and nullable `target_slot_id`. Legacy dependency refs remain only
  `{label,idx}`, and descriptor projection deliberately uses the legacy action-edge shape until `.4.3`.
- Named regex slots reuse the generated pinned Unicode-17 rule-label classifier without normalizing or folding.
  All-ASCII digits remain the numeric selector namespace. Anonymous and named regexes share one ordered list,
  so duplicate regex text never substitutes for slot identity and a named selector survives reordering.
- `SpecFile.sourceId` is the single logical static-source carrier. It defaults to `inline` for old constructors
  and JSON, is threaded through ordinary and both staged parser layers, uses the caller's logical request on the
  loaded path, and supplies every slot/directive/edge diagnostic and compiled row. No resolved host path is
  persisted as the logical identity.
- Validate gap directives after selector resolution but before generic mixed-edge rejection. This preserves
  existing diagnostics for unflagged rules while giving flagged rules exact `none`, `mixed`,
  `local_adjacency`, `blind`, or `action` eligibility evidence. Anonymous legacy markers conflict; named
  `@mark(...)` remains independent.
- `CompiledRule.toJson()` owns private slot/directive metadata and `CompiledActionEdge.toJson()` owns five-field
  provenance. `toDescriptorRuleJson()` stays deliberately legacy-shaped, generated plan v2 stays
  `{label,family}`, and no runtime invocation or transaction object changes in this leaf.
- Final `.4.1` proof is dormant 1/1; complete Dart format 102/0, strict analysis, package 400 plus one intended
  skip, storage 22/47, CLI 66x2, and corpus 105; neutral 3/6/56 plus ten Rust admission and ten Dart dormancy
  mutations; book 79/14,788 KiB; Knowledge 836/7,039; all doctrines; and canonical Phase 0 1,031/1,031 in 745
  seconds with the rooted neutral/Perl/Rust route and exit 0.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.4.0` — Dart behavior-free implementation freeze): activation base is
  clean atomic 232 at `2800e7c3`. Exact probes precede source inference: named declarations/selectors/directive
  are raw-invalid, the four accessors are unknown helpers, and lifecycle trace proves repeated `LS` precedes
  selection.
- Dart's split must respect existing authorities. `.4.1` adds source-aware authored/static/compiled metadata and
  a dormant consumer; `.4.2` adds private state to `_InvocationState` and its existing token snapshot; `.4.3`
  proves normalized reconstruction/descriptors/generated execution; `.4.4` proves emitted source; `.4.5` alone
  proves primary, requires all nine roles, registers, promotes Dart, and closes the parent.
- Do not add gap members to observed `RecognitionFrameState`. Keep its cursor/boundary/marks projection exact;
  store activation, detached entry identity, immutable source/invocation identity, and the three mutable gap
  members on the private invocation authority, with those mutable members restored by the existing token.
- Runtime gaps use the existing immutable `input` `SourceAuthority` and Unicode-scalar projection. Static gap
  diagnostics need a backward-compatible logical spec source id threaded through ordinary/staged/loaded parsing,
  `SpecFile` JSON, validation, and compilation.
- Keep normalized `SpecFile` JSON as the only generated carrier. Descriptor additions are separate from existing
  `resolved_edges`; generated plan v2 stays `{label,family}` and emitted source must inherit behavior through the
  same engine rather than a copied gap executor.
- The emitted consumer must use a repository-routed Dart caller workspace and local package cache, then register
  that exact temporary owner. The current storage baseline is already 22 owners / 47 packages; the previously
  documented 21 was stale because semantic-introspection emitted proof is the 22nd owner.
- Focused 123/123 and complete Dart format 101/0, analysis, 400/400, storage 22/47, CLI 66x2, and corpus 105/105
  validate the behavior-free baseline. Rendered book, Knowledge 836/7,036, and all eight doctrines pass; the
  unchanged authorized canonical run passes containment/relocation, CLI 66x2, RAM 59%, Phase 0 1,031/1,031 in
  771 seconds, exact rooted routing, and local-CI exit 0. Gap remains 3/6/56 plus ten Rust admission mutations
  until `.4.5`.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.3.5` — Rust private admission): activation base is clean atomic 231 at
  `c3326f6d`. Keep the primary proof on the existing `run_with_context` adapter; admission must not create a new
  CLI option or a second execution path.
- The director-highlighted list use is now an exact executable contract. With one `[a-z]+` item slot, input
  `alpha, beta | gamma\n- delta` yields exact item/gap pairs for empty prefix, comma, pipe, and bullet/newline
  separators. Gap capture preserves unknown separator text; it does not bypass item matching or commit/rollback.
- Admission composition is executable data, not comments. The Rust test reads the contract's nine-role array,
  rejects identity/order drift, records every role once, and rejects a duplicate, missing, or undeclared role.
- Registration is multiplicity-sensitive: one ordinary test, one explicit canonical command, and one rooted
  command after Perl. The checker also preserves one exact skip for each of Dart, Julia, PUC Lua, and LuaJIT.
- Promote only `rust_runtime`. Keep the semantic mutation total at 56 by replacing premature promotion with a
  complete-to-pending regression; replace the ten dormancy checks with ten role/registration/facade admission
  checks. Recurring/public and all outward ledgers stay pending or unchanged.
- Focused proof passes admitted Rust 1/1 plus runtime 170/170, recognition 12/12, recursive observation 7/7,
  cursor, duplicate-slot, source-emitter, neutral/rooted governance, recognition 137/246/58, and typed source
  9/5/114. Book 79/14,732 KiB, Knowledge 835/7,020, the 17-owner storage/relocation oracle, and all eight doctrines
  pass. The sandboxed canonical run reaches the expected outer nested-`sandbox-exec` status 71; its unchanged
  authorized rerun passes containment/relocation, CLI 66/66 twice, RAM 73%, Phase 0 1,031/1,031, the exact rooted
  neutral/Perl/Rust route, and local-CI exit 0. Parent `.3` is signoff-complete for atomic 232.

- 2026-08-14 (`INTER-MATCH-GAP-CAPTURE.3.4` — independently compiled Rust emitted proof): activation base is
  clean atomic 230 at `9e6ade98`. The deliberate ignored-consumer RED was a missing emitted-proof owner; once the
  consumer supplied that role, no runtime/emitter defect remained.
- Keep the carrier singular. `emit_rust_source_v2` embeds serialized `CompiledSpec`; after `.3.3` joined the
  generated-plan executor to the gap lifecycle, independently compiled source inherited exact behavior without a
  new plan field, schema version, emitter branch, or second state model.
- One emitted workspace is enough for broad proof. Generate isolated Rust modules for each fixture, compile the
  aggregate crate once offline, execute each module through both direct and traced APIs, and retain typed failure
  comparisons for negative paths. This avoids one expensive child compilation per semantic case.
- Emitted proof storage is capability-scoped to `rust/target/test-workspaces/inter-match-gap-emitted-probe-*`.
  Cargo's child target and trace files stay inside that root, and the drop owner removes it on every unwind path.
- The matrix has thirteen value modules and two error modules. It covers the director-highlighted heterogeneous
  list use case plus Unicode/empty gaps, falsey values, selection/lifecycle ordering, child cursor extension,
  nesting, rollback, terminal tails, failed minimum, direct entry, unflagged legacy behavior, unavailable context,
  and cursor regression.
- `.3.5` remains the only admission owner. Keep the final test ignored ordinarily, the rooted Rust row skipped,
  rollout at 2/7/56 plus ten dormancy mutations, and all primary/recurring/facade/public surfaces unchanged.
- The required `CHANGES.md` rollover adds immutable segment 4996. ADR `0072` reviews the exact 16→17 collection
  member step while preserving every root, manifest, per-history-file, aggregate, byte, lifecycle, verifier,
  owner, and storage bound; the next member increase still requires a new exact-limit decision.
- The full storage oracle independently discovers the new emitted-gap owner and passes all 17 Rust owners, Cargo
  cache, generated workspaces, traces, and relocation on repository storage. Rendered book is 79/14,724 KiB and
  Knowledge is synchronized at 835/7,019. All eight doctrines pass. The sandboxed canonical attempt's only stop
  is the outer harness's nested-`sandbox-exec` status 71; the unchanged authorized run passes containment and
  relocation, CLI 66/66 twice, RAM 60%, Phase 0 1,031/1,031 in 780 seconds, exact rooted gap routing, and local-CI
  exit 0.

- 2026-08-14 (`INTER-MATCH-GAP-CAPTURE.3.3` — Rust reconstructed/generated carrier): activation base is clean
  atomic 229 at `5c4e9d50`. The exact RED separated the carriers: ordinary reconstructed native execution already
  worked, descriptors returned null for all new metadata, and generated-plan access failed with typed unavailable
  context.
- Descriptor evolution must preserve older record meanings. Keep semantic `resolved_edges` at its exact five
  legacy fields and `{label,idx}` dependency references narrow; publish selector provenance separately as
  `resolved_slot_edges`, alongside cloned `regex_slots` and `capture_gaps` values.
- Serialized `CompiledSpec` is the sole carrier. Generated source already embeds it, so adding directive/slot
  fields to plan v2 would duplicate truth. The static plan remains only `{label,family}` and `source_emitter.rs`
  remains unchanged.
- Generated action entry must carry the same active parent capability as native execution. Derive the detached
  slot row only while the parent candidate is active, enter the child on the same recognition stack, and keep
  direct/blind/unrelated/stale entries slot-free.
- Capture-enabled generated rules deliberately differ only where the directive requires it: select and install
  before `LS`, retain through action/target/`LE`, commit before `IT`, and install successful tails before terminal
  hooks. Every unflagged rule retains historical LS-before-selection order.
- The final consumer now pairs native and generated results and structured diagnostics over the complete private
  behavior set. It stays ignored until `.3.5`; `.3.4` still owns independently compiled emitted proof, and `.3.5`
  owns primary/canonical/recurring admission. Rollout remains 2/7/56 and outward surfaces remain absent.
- Final signoff passes the 17-owner Rust storage oracle, rendered book at 79 files / 14,720 KiB, synchronized
  Knowledge at 835 facts / 7,019 keys, all eight doctrines, containment/relocation, CLI 66/66 twice, RAM 69%,
  Phase 0 1,031/1,031 in 772 seconds, and the exact opt-in gap route through canonical exit 0. The sandboxed run's
  sole status-71 stop was the outer harness denying nested `sandbox-exec`; the unchanged elevated command passed
  its own containment proof.
