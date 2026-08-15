# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

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

- 2026-08-14 (`INTER-MATCH-GAP-CAPTURE.3.2` — Rust native gap lifecycle): activation base is clean atomic 228 at
  `95127e1d`. The ignored final consumer's exact RED was native unknown-helper behavior, not metadata drift.
- Keep one authority: `RecognitionRuntime` owns the invocation stack and checkpoint token. Gap state adds immutable
  source/invocation identity plus only three snapshot members: committed cursor, accepted-edge count, and current
  candidate/tail. Do not widen public recognition `state_record()` or create another cursor/token/stack.
- Capture-enabled selection is intentionally different from legacy execution: select, install LMATCH, and create
  the gap before `LS`; retain it through edge/target/`LE`; commit the child-extended cursor before `IT`. Unflagged
  rules still run `LS` before matching, so the directive cannot silently reorder existing grammars.
- Entry-slot propagation is capability-scoped. The parent frame creates a detached five-field row only while its
  current candidate is active; the child accepts it only when owner invocation and target rule agree. Direct,
  generic `call(...)`, blind, unrelated, and stale entries receive no slot identity.
- Gap spans stay byte-rooted inside the private frame but cross `SourceAuthority` before authored exposure, yielding
  decoded Unicode-scalar half-open offsets and exact text. A commit cursor before the selected match end is a typed
  `source_location_cursor_regression`; an accessor outside a candidate/tail is typed
  `gap_capture_context_unavailable` with rule/source/invocation/phase/accessor context.
- Default capture-enabled action rules continue scanning to the terminal miss so lossless tail context reaches
  `LX`; repeated rules expose terminal context through `EX`, and maximum/non-repetition completion through the
  existing `E` path. Failed repetition minimum runs no tail hooks. An unadorned action return still unwinds the
  whole rule without committing the candidate or inventing a tail.
- `.3.3` still owns ordinary reconstruction, descriptor projection, and the separate generated-plan executor;
  `.3.4` owns independently compiled emitted proof; `.3.5` owns primary/canonical/recurring admission. Keep the
  final consumer ignored and rollout 2/7/56 until then; generated plan v2 and outward surfaces do not move.
- The required notes rollover adds immutable segment 4996 and one manifest row. That exact resulting-tree growth
  must be reviewed, not bypassed: ADR `0071` raises only the controlled file count 11→12 and manifest line cap
  10→11 while every byte, root, history-member, aggregate, lifecycle, owner, verifier, and storage bound stays fixed.
- Final `.3.2` signoff passes rendered book 79/14,708 KiB, Knowledge 835/7,016, all eight doctrines, the 17-owner
  Rust storage oracle, containment/relocation, CLI 66/66 twice, RAM 49%, Phase 0 1,031/1,031 in 735 seconds, and
  exact neutral-plus-Perl routing with five pending-runtime skips through local-CI exit 0. The first run's status
  71 was solely the outer harness denying nested `sandbox-exec`; the unchanged authorized invocation is definitive.

- 2026-08-14 (`INTER-MATCH-GAP-CAPTURE.3.1` — Rust authored/static/compiled metadata): activation base is clean
  atomic 227 at `4a95e02a`. The exact RED was the final consumer's missing `regex_slots`; no runtime failure or
  rollout change was hidden behind the staged boundary.
- `SpecFile` now carries caller-settable logical source identity. Named and anonymous regex rows share authored
  order; exact Unicode-17 names exclude ASCII digit-only identities; action targets retain explicit
  unindexed/numeric/named/invalid selector evidence until portable validation resolves the target slot.
- Validation must preserve established prerequisites: declaration errors precede selector work, but undefined
  targets retain the older undefined-rule diagnostic. Directive eligibility is exactly looping seek-based
  OR/default plus at least one action owner; none, blind, mixed, AND/consume, and same-line local adjacency reject.
- Resolve named selectors before dependency expansion. Keep the authored slot catalog separate from compiler-
  appended dependency regexes, and retain selector kind, authored value, resolved index, and nullable slot id in
  compiled dependencies/actions. Strip those new fields from the legacy descriptor until `.3.3` owns projection.
- The 105-source generated manifest found the classifier regression that unit fixtures missed: `/=/ /next/` was
  misread as an invalid named declaration. Anonymous slash syntax now has explicit priority, guarded by a parser
  unit test; full manifest, source-emitter, and rule-local-cursor carriers pass afterward.
- A named-command absence check is insufficient dormancy because the optional Rust package gate executes every
  integration test. The single final-path stage is therefore `#[ignore]` under `.3.5`; focused metadata proof uses
  `--ignored --exact`, ordinary package execution proves 0 passed / 1 ignored, and one of the ten checker-local
  dormancy mutations deletes that exact owner lock.
- Do not infer live Rust gap support. `.3.2` still owns invocation state/lifecycle/accessors, `.3.3` descriptors and
  generated execution, `.3.4` emitted proof, and `.3.5` primary/canonical/recurring admission. Gap stays 2/7/56;
  generated plan v2, recognition 137/246/58, public helpers 122, typed source 9/5/114, and outward guards do not
  move.
- Final canonical proof passes all eight doctrines, containment/relocation, CLI 66/66 twice, RAM 55%, Phase 0
  1,031/1,031, and the opt-in gap route at neutral 2/7/56 plus Perl 124 and five exact later-runtime skips before
  `[ci] local CI gate passed` with exit 0. The first invocation reached only the outer harness's status-71 denial
  of nested `sandbox-exec`; the identical permission-authorized invocation is definitive.

- 2026-08-14 (`INTER-MATCH-GAP-CAPTURE.3.0` — Rust dependency freeze): activation base is clean atomic 226 at
  `eceb15ac`. The neutral checker and rooted route are the first runtime truth: 2/7/56, Perl 124, and five exact
  pending skips. Direct primary probes precede source inspection and prove numeric selection works while named
  declaration/selection, directive, and accessors are absent or drifted in their exact current ways.
- Root causes are intentionally narrow: bare-regex and legacy-marker classification in `parser.rs`, digit-only
  `parse_index_at`, numeric-only AST/compiled edge state, absent compiled slot/directive provenance, two separate
  native/generated execution loops, and an existing recognition frame with no gap members. `source_emitter.rs`
  already embeds compiled JSON, so widening its label/family plan would duplicate authority.
- `.3.1` owns authored/static/compiled provenance; `.3.2` owns native state/lifecycle/accessors on the existing
  recognition invocation and snapshot; `.3.3` owns reconstruction/descriptor/generated execution; `.3.4` owns
  offline emitted execution under repository-derived scratch/target storage; `.3.5` alone owns primary/admission.
- Candidate placement is before capture-enabled `LS`, persistence continues through target/action/`LE`, accepted
  commit occurs before `IT`, and successful tails precede `LX`/`EX`/`E`. Unflagged ordering, falsey acceptance,
  return authority, structural slot identity, and public recognition snapshots remain unchanged.
- Final admission is exactly 3 complete / 6 pending / 56 mutations: replace premature Rust completion with Rust
  regression, run neutral/Perl/Rust then four skips, and execute the nine declared Rust roles once. Preserve
  recognition 137/246/58, language 246/122, typed source 9/5/114, generated plan v2, capability/public no-overclaim,
  and all later owners. The two stale pre-Perl Knowledge cards are corrected in this behavior-free slice.
- Behavior-free signoff passes exact gap 2/7/56, rooted Perl 124/five skips, focused Rust 1/1 in 17.61 seconds,
  rendered book 79/14,704 KiB, Knowledge 835/7,009, all eight doctrines, containment/relocation, CLI 66/66 twice,
  RAM 57%, Phase 0 1,031/1,031 in 741 seconds, exact opt-in routing, and local-CI exit 0. The first sandboxed run
  stopped only at the outer harness's nested-`sandbox-exec` status 71; the unchanged authorized run is definitive.
  `.3.0` is signoff-complete for intended atomic 227 and `.3.1` stays pending until commit/brief/clean proof.

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.2.4` — exact private Perl admission): activation base is clean atomic 225
  at `45460329`. Keep the neutral model behavior-free; admission changes only rollout truth, execution topology,
  governed status markers, and the already-complete consumer's default mode.
- The canonical and recurring command is `PERL5LIB= prove -Iperl t/inter_match_gap_capture_perl_contract.t`.
  Canonical CI contains it once. The rooted driver runs it once after the neutral checker, then skips exactly five
  later runtimes in frozen order. The default consumer passes all three phases as 124 top-level tests.
- Replace dormancy validation rather than preserving dead staging machinery. Registration checks exact phase
  boundaries, default `all` mode, one canonical command, one recurring command, and continued facade absence.
  Semantic/topology proof is exactly 56 mutations: Perl complete-to-pending plus premature Rust are both rejected.
- Current no-drift is gap 2/7/56, recognition 137/246/58, language 246/122, typed source 9/5/114, and duplicate
  slot 7/0/59. Project-data routing, rendered mdBook, Knowledge 834/6,995, all eight doctrines, containment/
  relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 765 seconds, exact neutral-plus-Perl routing, and
  local-CI exit 0 pass. `.2.4` and parent `.2` are signoff-complete for intended atomic 226; Rust `.3` is next
  only after commit/brief/clean proof.

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.2.3` — Perl emitted/loaded gap parity): activation base is clean
  `34d02e0c`. Metadata 110 and all nine native-live groups were GREEN; generated mode failed only at its intended
  placeholder, so no carrier defect was hidden behind the staged fence.
- Generated gap execution needs four exact seams: an explicit private-runtime import; typed-error passthrough via
  `InterMatchGapRuntime::is_error`; a guarded zero input boundary matching ordinary `Get`; and a live-metadata
  fallback guard because emitted descriptor `spec` entries are code references, not live rule hashes.
- `dependency_slot_map` remains the generated selection authority. Named rows already preserve five-field
  provenance. For unindexed compatibility rows, absent generated rule metadata means `slot_id` remains nullable;
  never dereference a generated handler as though it were a live descriptor record.
- Do not widen generated plan v2. The exact plan remains ordered `{label,family}` rows; gap policy/state belongs in
  emitted handler code and the existing private runtime, not serialized plan metadata.
- The generated consumer now has five groups / 138 internal assertions comparing canonical JSON bytes and cursors
  against live execution. It covers Unicode/empty spans, provenance, falsey values, lifecycle, recursion,
  same-token rollback, `Execute`/`ExecuteWithTrace` diagnostics, direct entry, and legacy rolling.
- This is still private staging. Keep gap 1/8/55 plus ten dormancy locks, recognition 137/246/58, public helpers
  122, and typed source 9/5/114. `.2.4` alone removes dormancy, registers routes, advances 55→56, and admits Perl.
- Canonical closeout is green: rendered mdBook, Knowledge 834/6,995, all eight doctrines, containment/relocation,
  CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 773 seconds, and the exact opt-in gap route all pass with exit
  0. A prior unchanged sandboxed run reached only nested macOS `sandbox-exec` status 71 at process containment;
  the authorized run proves that was an outer-harness permission boundary, not a repository failure.

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.2.2` — private Perl native-live gap capture): activation base is clean
  `912fc5ed`. The exact RED was the staged live placeholder; metadata 108 and neutral gap 1/8/55 already passed.
- Reuse `RecognitionTransactionRuntime::_current_guard` as the sole invocation authority. Gap state belongs on
  that guard; do not create another stack/cursor or overload legacy `$IPOS`. Same-token checkpoint snapshots must
  contain detached `committed_gap_cursor`, `accepted_edge_count`, and `current_gap` only.
- Install a candidate after match extraction and before enclosing `LS`; keep it visible through edge/target/`LE`;
  commit the accepted post-`LE` cursor before `IT`. Install successful tails before default `LX`, satisfied-repeat
  `EX`, and max `E`; failed minimum and direct default-action unwind synthesize neither commit nor tail.
- The selected-match carrier is private and owner-checked. Only the direct target child under the candidate's
  parent guard receives detached `entry_slot()` identity; direct entry is `undef`, and nested/recursive invocations
  cannot observe or alias parent candidate state.
- `ENTRY_SLOT_READ`, `GAP_SPAN_READ`, `GAP_TEXT_READ`, and `GAP_KIND_READ` are private `source_read` effects.
  Recognition moves exactly 133→137 rows while calls remain 246, mutations remain 58, public helpers remain 122,
  and typed-source remains 9/5/114. Generated-source import/error propagation is still owned by `.2.3`.
- Default metadata passes 110 and native-live mode passes all nine behavior groups. Recognition, gap, typed-source,
  and duplicate-slot cross-runtime matrices pass. Gap rollout deliberately remains 1/8/55 plus ten dormancy locks;
  `.2.4` alone registers the consumer and promotes Perl.
- The gap no-overclaim marker must evolve with private staging: “every runtime unimplemented” becomes false at
  `.2.2`, while “every runtime-admission row pending” remains exact. Update the artifact and independent checker
  together; keep 1/8/55 unchanged and continue forbidding generated/loaded, cross-backend, schema/CLI, and public
  admission claims.
- Pre-canonical focused signoff renders 79 book files / 14,672 KiB, regenerates Knowledge at 834/6,992, and
  passes all eight doctrines. The sandboxed canonical run reaches representative-process containment and stops
  only because the outer harness denies nested `sandbox-exec` with status 71. Its unchanged authorized rerun
  passes containment/relocation, CLI 66/66 twice, RAM 76%, Phase 0 1,031/1,031 in 756 seconds, the exact opt-in
  neutral-plus-six-pending gap route, the local-CI pass marker, and exit 0.

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.2.1` — Perl authored/static metadata): activation base is clean
  `8f826923`. The final consumer/checker came first and failed five of six metadata subtests because named
  selectors and `@capture_gaps` were not parseable; this is the leaf's exact RED.
- `specs/spec.spec` remains permanent authority and `BootstrapSpec::Core` is its necessary reference bridge.
  Anonymous regex AST rows must stay byte-shape compatible. Named and anonymous declarations share one authored
  zero-based sequence; unindexed legacy selection remains permissive, while explicit numeric selection range-
  checks and named selection follows exact identity.
- Never use host Perl Unicode properties for slot names. Regenerate private `UnicodeXIDContinue.pm` from the
  pinned Unicode 17 table, byte-compare all 806 ranges, and reserve ASCII digit-only bracket text for positions.
- Keep stable edge identity separate from the legacy projection: `regex_slots` catalogs declarations and
  `resolved_slot_edges` carries exactly selector kind, authored selector, target rule, resolved index, and nullable
  slot id. Preserve provenance through ordinary and self-target generated dependency expansion.
- `@capture_gaps` ends at static eligibility/descriptor metadata in this leaf. Do not add invocation state,
  lifecycle hooks, transaction snapshots, `entry_slot()`/`gap_*`, tail behavior, or emitted/loaded gap execution.
  Metadata is green; live/generated modes must remain deliberate failures behind 10 independent dormancy guards.
- Focused proof is 108 assertions in the dormant consumer and 599 across eight Perl files; neutral remains
  1/8/55 plus 10 dormancy mutations; Unicode 17 regeneration proves 806 ranges; five-backend self-host is 5x2.
  Knowledge is 834/6,992 and the rendered mdBook is 79/14,668 KiB.
- The first fully staged canonical run passed through composed semantic-introspection, then correctly rejected
  the bounded-memory rewrite for omitting repeated-action historical next owner `FUTURE-PARITY-BACKLOG.10.1`.
  This is the known `.22` marker-anchor defect: restore the compact memory fact and rerun unchanged; do not weaken
  the checker or change this leaf's runtime/admission scope.
- After that exact repair, the staged sandboxed restart reached only the outer harness's expected nested-
  `sandbox-exec` status 71 at representative-process containment. The unchanged authorized run passes all eight
  doctrines, six-family containment, all-five-anchor relocation, CLI 66/66 twice, RAM 65%, Phase 0 1,031/1,031
  in 755 seconds, the exact neutral-plus-six-pending gap route, and local-CI exit 0.
- Director session-continuity instruction: recommend `/clear` after at most three completed commits and sooner
  after unusually large/debug-heavy work or context compaction, but only at a verified committed clean boundary.
  Atomic 223 is an immediate fresh-session handoff; do not activate `.2.2` before the director clears.

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.2.0` — Perl dependency freeze): activation base is clean `db299789`.
  This leaf is behavior-free; documentation may freeze exact mechanisms, but grammar/runtime bytes and the
  1-complete/8-pending, 55-mutation gap authority must remain unchanged.
- Use Toolbox evidence before implementation. Current named declaration/selector/directive forms reject; all four
  accessors lower to unsupported sentinels. The legacy runtime returns three prefix/interstitial pairs and no tail,
  and generated source fixes the actual hook order needed by the new lifecycle snippets.
- `.2.1` changes `specs/spec.spec` first and the hardcoded bootstrap bridge in lockstep. Slot identity must use a
  generated Unicode-17 classifier; host Perl exposes Unicode 13 and is not an acceptable identity authority.
- Stage the exact final Perl consumer under metadata/live/generated modes. Ten checker-local mutations lock its
  dormancy and rooted commands separately from the neutral JSON's 55 mutations. Do not execute or register the
  pending consumer through canonical CI or the recurring driver before `.2.4`.
- `.2.2` owns one private runtime attached to `RecognitionTransactionRuntime::InvocationGuard`. Do not create a
  second stack, overload `$IPOS`, or widen `RecognitionTransaction.pm`'s cursor/boundary/marks state. Token-keyed
  snapshots on the same guard compose rollback.
- Candidate installation is after match extraction and before `LS`; accepted commit is after authored `LE` and
  before `IT`; successful tail is before default `LX`, satisfied-repeat `EX`, or maximum `E`. Direct default-action
  return and failed minimum synthesize neither commit nor tail.
- Four private source-read ActionIR nodes necessarily advance recognition effect rows 133→137. Update the neutral
  recognition artifact/checker, policy, all admitted consumer snapshots, current Knowledge/book/guide projections,
  and keep 246 calls/58 mutations/9-of-9 rollout. Classify the four names non-public so language coverage stays
  122; do not add them to the typed-source 92+7 helper map before `.7`/`.14.5.1`.
- `.2.3` owns generated import/error propagation and independently loaded parity without plan-v2 change. `.2.4`
  alone removes dormancy, runs the full path once canonically and once in the rooted driver, promotes Perl, and
  adds only the premature-Rust mutation for 56 total.
- Final behavior-free signoff preserves gap 1/8/55, recognition 133/246/58, public helpers 122, and typed source
  9/5/114. The rendered book is 79 files / 14,652 KiB; Knowledge is 833/6,984; all eight doctrines, containment,
  relocation, CLI 66/66 twice, RAM 66%, Phase 0 1,031/1,031 in 745 seconds, the opt-in pending route, and exact
  local-CI exit 0 pass. Atomic 222 must land and clear cleanly before `.2.1` activation.

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.1.3` — unchanged neutral closeout): activation base is clean `0490522b`.
  A closeout leaf must consume only committed authority: do not edit the JSON/checker/driver to make recomposition
  pass, and stop for a separately owned correction if their bytes, routes, public guards, or results disagree.
- Recomposition has two independent layers. The checker executes the full semantic model and 55 corruptions; a
  separate structural proof locks JSON identity/count/status/order, exact markers, guarded tokens, and absent
  consumer files. Both agree at 1 complete + 8 pending.
- Base-relative no-change proof covers the contract/checker/driver, canonical/storage routes, all backend trees,
  ten outward API/schema/CLI/README surfaces, and README. Closeout docs are the only permitted projection changes.
- Duplicate-slot 59 and typed-source 9/5/114 are prerequisites rather than gap runtime evidence. Their complete
  matrices pass unchanged, preventing neutral closeout from hiding selector or source-span regression.
- Closing `.1` means the specification is implementation-ready; it does not make any planned spelling, accessor,
  runtime consumer, recurring row, or public no-drift row current. Perl `.2` owns the first behavior change.
- Canonical closeout passes rendered mdBook 79/14,632 KiB, Knowledge 832/6,967, all eight doctrines,
  containment/relocation, CLI 66/66 twice, RAM 61%, Phase 0 1,031/1,031 in 725 seconds, exact neutral-plus-six-
  pending opt-in routing, and local-CI exit 0. Commit/brief/clean proof is the only remaining boundary before `.2`.

- 2026-08-13 (`INTER-MATCH-GAP-CAPTURE.1.2` — recurring neutral governance): activation base is clean `f58dfcb3`.
  A recurring-driver file is not a runtime admission. Until each runtime rollout row becomes complete, execute
  the neutral checker once and emit one exact skip per pending route in the frozen order.
- Keep canonical layers distinct: the always-on neutral checker proves behavior-free semantics and current
  no-overclaim; `LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX=1` additionally proves the storage-rooted ordered driver.
  Neither promotes `recurring` or `public_no_drift`, both of which remain owned by `.7`.
- The driver must derive its root from `BASH_SOURCE`, source `tools/project_data_env.sh`, enter the managed run
  before invoking Python, and run from `REPO_ROOT`. Outside-CWD routing and tool-storage tests are mandatory.
- Public no-overclaim is executable: five exact documentation markers explain the 1/8 boundary, while ten
  outward facade/schema/CLI/README paths reject `@capture_gaps`, `entry_slot`, `gap_span`, `gap_text`, `gap_kind`,
  `Rule[name]`, and `name=/regex/` until actual admission.
- The checker-first RED against the committed artifact is exact `required sections drifted`. Final GREEN is 55
  mutations: the original 50 plus `rollout_sequence`, `runtime_rows_pending`, `storage_paths`, `route_order`, and
  `public_no_overclaim`. Keep each corruption reason-specific and registration checks outside mutation copies.
- Do not create placeholder runtime consumers to satisfy topology. Their exact root-relative paths live in the
  contract; the driver proves they remain pending and absent until `.2-.6` own implementation and admission.
- Focused no-regression proof remains duplicate-slot 59 and typed-source 9 complete / 5 pending / 114 mutations.
  Knowledge regenerates at 831 facts / 6,960 keys and the mdBook remains the sole truthful public projection.
- The staged sandboxed canonical run passes all earlier tests and stops only when the outer harness denies nested
  macOS `sandbox-exec` with status 71. The unchanged permission-authorized opt-in run passes containment,
  relocation, CLI 66/66 twice, RAM 61%, Phase 0 1,031/1,031, exact neutral-plus-six-pending routing, and
  `[ci] local CI gate passed` with exit 0.
