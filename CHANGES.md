# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.5.2 — add Julia native gap execution

- Activated task-tree-first from clean atomic-241 commit `3a620ec0`; the permanent consumer first failed exactly
  on unsupported private helper `gap_kind`.
- Extended the existing private recognition invocation/token with capture activation, immutable invocation/input
  identity, detached entry-slot identity, committed gap cursor/count/current context, and rollback snapshots.
  Detached `RecognitionFrameState` remains exactly cursor/boundary/marks; no second state stack or cursor exists.
- Capture-enabled repetitions alone preselect/install candidates before `LS`, retain them through action/target/
  `LE`, commit the child-extended accepted cursor before `IT`, and install successful tails before `LX`/`EX`/`E`.
  Unflagged ordering and legacy marker behavior remain unchanged.
- Added private zero-argument `entry_slot()`, `gap_span()`, `gap_text()`, and `gap_kind()` dispatch with exact arity,
  unavailable-context, and cursor-regression diagnostics. Source spans cross the existing immutable input
  `SourceAuthority` from UTF-8 code-unit registers to zero-based Unicode-scalar coordinates.
- The duplicate-slot matrix caught an attempted Julia supported-call inventory widening. The corrected resolver
  gives the four helpers a separate private family, preserving exactly 246 supported ActionIR names and all
  language-capability ledgers.
- Expanded the dormant permanent consumer to 105 metadata + 33 native assertions covering Unicode/empty gaps,
  falsey and whole-rule results, named entry slots, child cursors, nesting, rollback, terminal modes, failed
  minimums, direct entry, legacy behavior, four-helper arity, and both typed failures.
- Complete Julia package/primary/storage 19/5 and corpus proof pass. Neutral/rooted governance remains 4/5/57
  with Julia skipped; duplicate-slot 7/0/59, recognition 137/246/58, and typed-source 9/5/114 matrices pass. The
  rendered book is 79/14,872 KiB and the Knowledge Map is 838 facts / 7,072 question keys.
- Synchronized roadmap, task frontier, book, Knowledge Map, and live history without changing normalized
  reconstruction, descriptors, generated format/plan, emitted source, primary admission, dependencies, storage,
  rollout, or outward surfaces. ADR `0073` therefore keeps this ordinary private-runtime slice at focused tier.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.5.1 — add Julia gap metadata

- Activated task-tree-first from clean atomic-240 commit `12a14ed0`; no Julia implementation, consumer, checker,
  route, or documentation change preceded ownership.
- Added backward-compatible `SpecFile.source_id` across ordinary, staged, loaded, JSON-reconstructed, and private
  primary parsing. Loaded absolute requests reduce to logical basenames, retaining the established no-host-path
  compiled/descriptor contract exposed by complete-package proof.
- Added spacing-insensitive named/anonymous regex declarations in one authored order through the pinned Unicode-17
  scanner, exact unindexed/numeric/named selector authorship, and a dedicated `@capture_gaps` body record.
- Added source-aware portable diagnostics for invalid/duplicate declarations, unknown/out-of-range/malformed
  selectors, duplicate directives, ineligible rule shapes, and anonymous legacy-marker conflicts.
- Compiled rules now retain ordered regex-slot and nullable directive rows; action edges retain source provenance
  and five-field resolved selector identity. Legacy descriptors, `resolved_edges`, dependency refs, generated
  format 2/plan rows, runtime state, and every outward surface remain unchanged.
- Created `julia/test/inter_match_gap_capture_contract_test.jl` at its permanent path. Explicit metadata proof
  passes 105 assertions, while ten reason-checked Julia dormancy mutations keep ordinary, canonical, rooted, and
  facade admission absent; rollout remains 4 complete / 5 pending / 57 semantic mutations.
- Complete Julia proof found and corrected two exact boundary risks without widening scope: an absolute loaded
  path would have entered compiled provenance, and a new `mktempdir` in the dormant consumer would have advanced
  storage ownership prematurely. Path opacity is restored and storage remains 19 owners / 5 locked packages.
- Synchronized the book's stale metadata-only Dart summaries to its already-landed private admission while
  teaching Julia's distinct metadata-only boundary. Native Julia state/accessors, reconstruction/descriptors/
  generated execution, emitted proof, primary/admission, Lua, and public rollout remain separately owned.
- Focused signoff passes explicit metadata 105, Julia direct dependents 624, full Julia package/primary/storage
  19/5/corpus 105, neutral/rooted 4/5/57, duplicate slot 7/0/59, recognition 137/246/58, typed source 9/5/114,
  rendered book 79/14,868, Knowledge 838/7,071, and bounded-history rollover/checks. The rollover publishes
  immutable segment 4995; ADR `0076` admits only the exact 18th file / 17th manifest row under unchanged aggregate
  ceilings, after which all nine doctrines pass.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.5.0 — freeze Julia gap implementation plan

- Activated task-tree-first from clean atomic 239 at `43ed1c8f`; changed no Julia production/test behavior,
  runtime rollout, generated format, dependency/toolchain, or outward surface.
- Exact probes prove numeric selectors compile; named declarations/selectors and `@capture_gaps` are raw invalid
  body syntax; the four accessors are structured unknown helpers; legacy `@move_pos` has no native effect; and
  repeated execution runs enclosing `LS` before selection.
- Froze `.5.1-.5.5` across authored/static/compiled metadata plus dormancy, existing-recognition-authority native
  state, normalized reconstruction/compatible descriptors/same-engine generated execution, independently loaded
  emitted modules, and existing-primary exact nine-role admission.
- Preserved detached `RecognitionFrameState` as cursor/boundary/marks, normalized `SpecFile` as carrier, immutable
  input `SourceAuthority` as scalar-span bridge, and generated format 2 `{label,family}` rows. `.5.4` alone may
  advance Julia storage from 19 to 20 exact temp owners; `.5.5` alone may promote Julia from 4/5/57 to 5/4/58.
- Corrected ADR `0045` and two Knowledge cards that still described the pre-Dart boundary; added the Julia plan
  card and synchronized task, roadmap, architecture, live status, Toolbox, and sole-facing mdBook.
- Focused signoff passes Julia 624, primary, storage 19/5, neutral/rooted 4/5/57, recognition 137/246/58,
  duplicate slot 7/0/59, typed source 9/5/114, book 79/14,856, Knowledge 838/7,070, bounded histories, exact
  640-line ADR pressure, diff checks, and all nine doctrines. ADR `0073` requires no canonical run for `.5.0`.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.4.5 — admit Dart inter-match gap capture

- Activated task-tree-first from clean atomic 238 at `6a554312`. Exact primary RED stopped only because
  `runPrimaryCommandGapContract` was absent; exact admission RED stopped only because Dart remained pending.
- Reused the existing private primary adapter for heterogeneous separators, removed the final consumer skip, and
  execute all nine contract roles in declared order exactly once. No primary, emitter, plan-v2, CLI, or facade
  implementation changed.
- Registered the consumer once in canonical CI and once after Rust in the rooted route. Only Dart advances:
  governance is 4 complete / 5 pending / 57 semantic mutations plus ten Rust and ten Dart admission mutations.
- Added ADR `0074` after contract/Git evidence proved the frozen `dart_runtime_premature` row never existed;
  preserving all prior 56 guards and adding `dart_runtime_regression` is the non-weakening correction. Corrected
  both dedicated roadmap rows omitted from atomic 238.
- The mandatory engineering-notes rollover published immutable segment 4995. Canonical CI then failed closed at
  the finite 12-file/11-manifest-row route cap; indexed ADR `0075` raises only those bounds to 13/12, with every
  byte, root, per-segment, aggregate, lifecycle, storage, and verifier constraint unchanged.
- Focused proof passes primary 1/1, ordinary consumer 5/5, Dart format 102/0 plus analyzer and 407 tests, storage
  23/47, CLI 66x2, corpus 105, rooted neutral/Perl/Rust/Dart execution with three skips, recognition 137/246/58,
  duplicate slot 7/0/59, and typed source 9/5/114. Canonical CI passes all nine doctrines, containment/relocation,
  CLI 66x2, RAM 57%, Phase 0 1,031/1,031 in 753 seconds, exact gap routing, receipt generation, and exit 0. Parent
  `.4` closes for intended atomic 239; Julia `.5` follows only after commit/brief/clean proof.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.4.4 — prove Dart emitted gap execution

- Activated task-tree-first from clean atomic 237 at `4c8ab7ee`; the deliberate RED stopped only because the
  dedicated emitted-contract helper did not exist.
- Added one repository-routed offline caller with a private `PUB_CACHE`. Ten emitted value modules and two typed-
  error modules pass strict analysis plus paired direct/traced execution against native authority.
- Coverage includes Unicode and empty gaps, falsey values, child cursors, detached entries, lifecycle tails,
  nesting, rollback, failed minimums, direct entry, legacy behavior, and exact unavailable/regression failures.
- Advanced only the exact Dart test temp-owner inventory from 22 to 23 and proved caller, cache, output, and trace
  cleanup. The production emitter, generated plan v2, dormant consumer, rollout 3/6/56, admission, and outward
  surfaces remain unchanged.
- Focused signoff passes emitted 1/1, explicit consumer 4/4, direct dependents 100/100, Dart 402 plus one intended
  skip, storage 23/47, CLI 66x2, corpus 105, all cross-runtime governance matrices, rendered book, Knowledge Map,
  bounded history, and all nine doctrines. ADR `0073` reserves canonical proof for `.4.5`.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.4.3 — carry Dart gap generated execution

- Activated task-tree-first from clean atomic 236 at `0b074e1c`. The isolated carrier RED proved normalized
  reconstruction already executed, then failed exactly because descriptor `regex_slots` was absent.
- Added detached `regex_slots`, nullable `capture_gaps`, and five-field `resolved_slot_edges` values to Dart rule
  descriptor metadata. Existing `resolved_edges` and `{label,idx}` dependency refs retain their exact shapes.
- Proved normalized `SpecFile` JSON preserves logical source, slot/directive/selector metadata and recompiles to
  the same Unicode prefix/tail result. Direct and disabled-trace generated-plan entrypoints spend the same engine
  and preserve typed unavailable-context and cursor-regression failures through the generated error envelope.
- Preserved generated plan v2 as exact ordered `{label,family}` rows and left emitted-source, primary/admission,
  registration, rollout 3/6/56, outward surfaces, and later runtimes unchanged or pending.
- Corrected the audited atomic-236 documentation omission: sole-facing project status and the architecture
  summary now report private native `.4.2` as current rather than pending, alongside this `.4.3` carrier state.
- The complete Dart gate exposed one direct-dependent fixture comparing logical normalized source identity with
  an absolute scratch-path load. Its loaded and reconstructed routes now share the caller-logical request name;
  targeted root-route proof is 3/3 without weakening production identity or descriptor equality.
- Focused signoff passes explicit carrier 3/3, direct dependents 100/100, Dart 402 plus one intended skip,
  storage 22/47, CLI 66x2, corpus 105, unchanged neutral/rooted governance, six-runtime recognition and typed
  source, five-backend duplicate-slot, book 79/14,816, Knowledge 837/7,052, bounded history, and all nine
  doctrines. ADR `0073` excludes full canonical CI for this ordinary private leaf.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.4.2 — add Dart native gap execution

- Activated task-tree-first from clean workflow-policy atomic 235 at `c234ef9f`. Extending only the permanent
  library-skipped consumer produced the deliberate focused RED at exact `unknown_helper name="gap_kind"` on its
  first native assertion.
- Extended the existing private `RecognitionTransactionAuthority`; no second cursor, invocation stack, or token
  family was added. Capture activation and detached entry identity join immutable source/invocation identity,
  while committed gap cursor, accepted-edge count, and current gap are the three token-snapshotted mutable values.
  Public/observed `RecognitionFrameState` remains cursor/boundary/marks.
- Capture-enabled native rules now preselect and install Unicode prefix/interstitial candidates before `LS`, keep
  them visible through edge/target/`LE`, commit the accepted child-extended cursor before `IT`, and install tails
  for successful terminal hooks. Unflagged `LS`-before-selection behavior remains unchanged.
- Added private zero-argument `entry_slot()`, `gap_span()`, `gap_text()`, and `gap_kind()` dispatch. Spans project
  UTF-16 code-unit registers through the existing input `SourceAuthority` to detached Unicode-scalar offsets;
  exact unavailable-context and cursor-regression failures retain typed records.
- Added focused native and recognition-authority proof for Unicode/empty gaps, falsey acceptance, child cursor
  extension, detached named slots, rollback, nested owner restoration, all terminal routes, failed minimum,
  direct entry, whole-rule unwind, and unflagged compatibility.
- Kept the final consumer skipped until `.4.5`. Reconstruction, descriptors, generated-plan execution, emitted
  source, primary/canonical/recurring registration, rollout, generated plan v2, facade/schema/semantic/MCP/CLI/
  README surfaces, and later runtimes do not move; governance remains 3/6/56 plus ten Rust admission and ten Dart
  dormancy mutations.
- Focused proof passes the explicit dormant consumer 2/2, private recognition units 2/2, direct dependents,
  neutral/rooted governance, and the complete Dart-local gate: format 102/0, strict analysis, 402 tests plus one
  intended skip, storage 22/47, CLI 66x2, and corpus 105/105. The book renders 79 files / 14,812 KiB, Knowledge
  is 837/7,052, and all nine doctrines pass. Per ADR `0073`, no full canonical CI runs for this ordinary private-
  runtime leaf.

## 2026-08-15 — VERIFICATION-CADENCE-POLICY.0 — enforce tiered verification cadence

- Adopted ADR `0073`: ordinary bounded leaves use focused changed-surface, direct-dependent, component, doctrine,
  Knowledge/history, diff, and applicable book proof. Full canonical CI is reserved for designated admission/
  milestone/public/infrastructure boundaries and the final clean batch/push boundary.
- Every new leaf commit must add exactly one verification tier, focused-check selection, and canonical trigger.
  The ninth registered doctrine rejects missing/duplicate tier evidence and forces canonical tier for staged CI,
  hook, gate, dependency, storage/path, or doctrine infrastructure.
- Canonical CI now requires a fully staged candidate and binds success to base `HEAD` plus a read-only SHA-256 of
  Git's full-index binary staged diff in a repository-local receipt. Pre-commit rejects stale/missing receipts;
  post-commit may promote an exact
  receipt; pre-push reuses only exact committed proof or runs the complete gate once from a clean tree.
- The first real staged check rejected `git write-tree` because it attempted `.git/index.lock` in a read-only
  sandbox. The final fingerprint avoids that mutation and post-commit verifies the identical parent-to-commit diff.
- Kept pre-commit fast, hosted Actions disabled, and `tools/run_ci_local.sh` authoritative. No parser, compiler,
  runtime, backend, DSL, public API, schema, descriptor, or generated-format behavior changed.
- Focused proof passes shell syntax, 15 path/tier cases, nine receipt cases, dirty pre-push rejection, Knowledge
  837/7,049, book 79/14,796 KiB, history/diff checks, and all nine doctrines. The full canonical gate writes the
  exact staged-candidate receipt and exits 0 before intended atomic 235.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.4.1 — add Dart authored gap metadata

- Activated task-tree-first from clean atomic-233 commit `e40de948`. The final-path Dart consumer and ten
  reason-checked dormancy mutations produced the exact checker-first RED: only the absent `parseSpec(sourceId:)`
  and `SpecFile.sourceId` carriers prevented the explicitly unskipped contract from loading.
- Added spacing-insensitive named regex declarations beside anonymous declarations in one authored order,
  explicit unindexed/numeric/named selector provenance, pinned Unicode-17 `XID_Continue` identity with the
  ASCII-digit-only reservation, and a dedicated rule-level `@capture_gaps` AST record.
- Added exact source-aware static diagnostics for invalid/duplicate names, unknown/out-of-range/malformed
  selectors, duplicate directives, ineligible rule modes/ownership, and legacy anonymous-marker conflicts.
  Logical source identity now survives ordinary, staged, loaded, and `SpecFile` JSON paths with legacy `inline`
  defaults.
- Compiled rules now retain ordered regex-slot rows and optional directive evidence; compiled action edges retain
  the exact five-field selector resolution plus source provenance. Existing dependency refs, descriptors,
  `resolved_edges`, generated plan v2, and anonymous/numeric/unindexed behavior remain compatible.
- Staged `dart/test/inter_match_gap_capture_contract_test.dart` at its final path with a library-level `.4.5`
  skip. Ordinary discovery remains skipped; explicit execution proves the complete authored/static/compiled
  group, while canonical and recurring routes remain absent and the facade remains unchanged.
- This leaf adds no native gap state, accessor, lifecycle, reconstruction/descriptor/generated projection,
  emitted or primary route, rollout promotion, or outward claim. Governance remains 3 complete / 6 pending / 56
  semantic mutations plus ten Rust admission and ten Dart dormancy mutations.
- Signoff passes the explicit dormant consumer 1/1; complete Dart format 102/0, analysis, 400 plus one intended
  skip, storage 22/47, CLI 66x2, and corpus 105; recognition 137/246/58, typed source 9/5/114, duplicate slot
  7/0/59; book 79/14,788 KiB; Knowledge 836/7,039; and all doctrines. The authorized canonical run passes
  containment/relocation, RAM 56%, Phase 0 1,031/1,031 in 745 seconds, exact rooted routing, and exit 0.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.4.0 — freeze Dart gap implementation plan

- Activated task-tree-first from clean atomic-232 commit `2800e7c3`; changed no Dart implementation before the
  owning leaf existed.
- Repository-routed probes prove numeric declarations/selectors remain healthy while named declarations,
  named selectors, and `@capture_gaps` are raw invalid syntax; all four planned accessors fail through exact
  `unknown_helper` diagnostics. Trace proves repeated `LS` currently precedes selection, and the existing primary
  pipeline returns its valid baseline while the complete planned source fails at compilation.
- Froze dependency-ordered `.4.1-.4.5`: authored/static/compiled metadata plus dormancy; private same-authority
  native state; reconstructed/descriptor/generated-plan carriers; independently analyzed/executed emitted Dart;
  then primary proof, exact nine-role composition, Dart-only admission, and parent closeout.
- Preserved one private recognition invocation/token authority, cursor/boundary/marks observation shape, Unicode-
  scalar input `SourceAuthority`, normalized `SpecFile` carrier, generated-plan v2 `{label,family}`, existing
  primary adapter, and every outward no-overclaim boundary.
- Corrected the stale Dart storage Knowledge projection from 21 to the current exact 22 `Directory.systemTemp`
  owners. The 22nd is the already-admitted semantic-introspection emitted workspace; no storage behavior changed.
- Gap governance remains 3 complete / 6 pending / 56 semantic mutations plus ten Rust admission mutations. Dart,
  Julia, both Lua runtimes, recurring/public rows, typed composition, capability, facade/schema/semantic/MCP/CLI/
  README surfaces, and generated format remain pending or unchanged.
- Focused Dart proof passes 123/123. Complete Dart proof passes format 101/0, strict analysis, 400/400 package
  tests, storage 22/47, CLI 66x2, corpus 105/105, and its success marker. Rendered-book, Knowledge 836/7,036, and
  all eight doctrines pass. The sandboxed canonical precursor stops only at outer status 71; the unchanged
  authorized run passes containment/relocation, CLI 66x2, RAM 59%, Phase 0 1,031/1,031 in 771 seconds, exact
  rooted routing, `[ci] local CI gate passed`, and exit 0.

## 2026-08-15 — INTER-MATCH-GAP-CAPTURE.3.5 — admit Rust inter-match gap capture

- Activated task-tree-first from clean atomic-231 commit `c3326f6d`. Primary-first RED exits 101 with exact Rust
  `E0425` at the absent `primary_command_gap_contract` owner; admission RED independently rejects the still-pending
  `rust_runtime` row.
- Added a real primary-adapter proof for `alpha, beta | gamma\n- delta`. One `[a-z]+` item slot returns `alpha`,
  `beta`, `gamma`, and `delta` with exact gaps `""`, `", "`, `" | "`, and `"\n- "`, proving that recognition and
  heterogeneous separator preservation remain independent.
- Made the final Rust consumer ordinary and required the contract's nine roles in declared order, each completed
  exactly once: native, reconstructed, descriptor, generated-plan, emitted, lifecycle, recursion/rollback,
  diagnostics, and primary command.
- Registered that consumer once in canonical CI and once after Perl in the rooted route. Only `rust_runtime`
  advances: governance is 3 complete / 6 pending / 56 semantic mutations plus ten Rust admission/regression
  mutations; the route executes neutral, Perl 124, Rust 1/1, then four exact later-runtime skips.
- Generated plan v2, recognition 137/246/58, public helpers 122, typed source 9/5/114, capability, facade,
  semantic/MCP, CLI, README, Dart/Julia/Lua, recurring, and public rows remain unchanged or pending.
- Focused and compatibility proof passes Rust admission 1/1, runtime 170/170, recognition 12/12, recursive
  observation 7/7, cursor, duplicate-slot, source-emitter, neutral/rooted governance, and related neutral ledgers.
  The rendered book passes at 79 files / 14,732 KiB, Knowledge at 835 facts / 7,020 keys, and the 17-owner Rust
  storage/relocation oracle passes with all Cargo workspaces, caches, traces, and generated output on repository
  storage. All eight doctrines pass. The sandboxed canonical run stops only at the outer harness's expected
  nested-`sandbox-exec` status 71; the unchanged authorized run passes containment/relocation, CLI 66/66 twice,
  RAM 73%, Phase 0 1,031/1,031, the exact neutral/Perl/Rust route, `[ci] local CI gate passed`, and exit 0.
