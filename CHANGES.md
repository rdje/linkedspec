# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

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

## 2026-08-14 — INTER-MATCH-GAP-CAPTURE.3.4 — prove Rust emitted gap execution

- Activated task-tree-first from clean atomic-230 commit `9e6ade98`. Extending only the ignored final consumer
  produced the deliberate compile-time RED for its absent independently compiled emitted-gap proof owner.
- Added one scoped emitted-project harness beneath `rust/target/test-workspaces`. It writes one isolated offline
  crate, directs Cargo output to that workspace's local target, and removes the complete workspace on drop.
- Emitted fifteen isolated v2 modules from serialized `CompiledSpec` state. Thirteen value cases prove paired
  direct/traced behavior for heterogeneous list separators, Unicode/empty spans, falsey results, selection and
  terminal lifecycle, child-extended cursors, nesting, rollback, failed minimum, direct entry, and unflagged
  legacy behavior; two error cases prove paired typed unavailable-context and cursor-regression failures.
- The mixed-list case matches `alpha`, `beta`, `gamma`, and `delta` while preserving exact gaps `", "`, `" | "`,
  and `"\n- "`, confirming item recognition and separator preservation remain independent.
- No production runtime or emitter change was needed. Generated source already carries serialized compiled state;
  generated-source v2 stays exact `{label,family}`, and emitted trace output retains generated-plan roles and each
  module's source identity.
- This is carrier proof, not admission: ordinary discovery remains 0 passed / 1 ignored; the rooted route remains
  neutral plus Perl 124 and five skips at rollout 2/7/56 plus ten Rust dormancy mutations. Primary/canonical/
  recurring registration, rollout promotion, outward surfaces, and later runtimes remain `.3.5+` work.
- The mandatory bounded change-history rollover published immutable segment 4996 and retained a 238-line hot
  shard. ADR `0072` reviews only the resulting collection step from 16 to 17 files; all root, manifest, member,
  aggregate, byte, lifecycle, verifier, owner, and storage limits remain unchanged.
- Focused compatibility, neutral/rooted governance, the 17-owner Rust storage/relocation oracle, rendered mdBook
  at 79 files / 14,724 KiB, and synchronized Knowledge at 835 facts / 7,019 keys are green. All eight doctrines
  pass. The sandboxed canonical attempt stopped only at outer nested-`sandbox-exec` status 71; the unchanged
  authorized run passes containment/relocation, CLI 66/66 twice, RAM 60%, Phase 0 1,031/1,031 in 780 seconds,
  exact neutral-plus-Perl routing with five skips, `[ci] local CI gate passed`, and exit 0.

## 2026-08-14 — INTER-MATCH-GAP-CAPTURE.3.3 — carry Rust gap generated execution

- Activated task-tree-first from clean atomic-229 commit `5c4e9d50`. The ignored final consumer's combined RED
  proved ordinary reconstructed execution already green, all three descriptor projections absent, and generated-
  plan execution failing with exact `gap_capture_context_unavailable`.
- Added compatible Rust descriptor metadata for declaration-order `regex_slots`, source/line-aware
  `capture_gaps`, and separate five-field `resolved_slot_edges`. Existing semantic `resolved_edges` and legacy
  `{label,idx}` dependency references retain their exact outward shape.
- Kept serialized `CompiledSpec` as the single carrier. Ordinary JSON reconstruction preserves the exact slot,
  directive, and selector values and executes current native behavior without a second state model.
- Joined `GeneratedPlanExecutor` to the existing recognition invocation, candidate/commit/tail lifecycle, and
  detached action-edge entry-slot authority. Capture-enabled generated rules select before `LS`, commit after
  `LE` before `IT`, and install successful tails before terminal hooks; unflagged generated behavior is unchanged.
- Generated source already embeds serialized compiled state, so `source_emitter.rs`, generated-source contract v2,
  and the exact `{label,family}` static plan need no change. The expanded focused consumer compares native and
  generated values and structured diagnostics across Unicode/empty spans, falsey results, child cursor extension,
  nesting, rollback, terminal lifecycle, failed minimums, and direct entry.
- This remains dormant carrier work, not Rust admission: ordinary discovery is 0 passed / 1 ignored; neutral and
  rooted governance stay 2/7/56 plus ten Rust dormancy mutations, Perl 124, and five later-runtime skips. Emitted,
  primary, canonical/recurring admission, outward surfaces, and later runtimes remain pending.
- Final signoff passes the 17-owner Rust storage oracle, rendered mdBook at 79 files / 14,720 KiB, synchronized
  Knowledge at 835 facts / 7,019 keys, all eight doctrines, six-family containment, all-five-anchor relocation,
  CLI 66/66 in both option environments, RAM 69%, Phase 0 1,031/1,031 in 772 seconds, the exact opt-in neutral-plus-
  Perl route with five skips, and canonical `[ci] local CI gate passed` / exit 0. The preceding sandboxed run
  stopped only at nested-`sandbox-exec` status 71.

## 2026-08-14 — INTER-MATCH-GAP-CAPTURE.3.2 — add Rust native gap execution

- Activated task-tree-first from clean atomic-228 commit `95127e1d`. Extending only the ignored final consumer
  produced the exact native RED: `gap_kind()` and `gap_text()` followed the unknown-helper path and returned no
  prefix/tail values before runtime changes.
- Attached private Rust gap activation, source/invocation identity, detached entry-slot identity, and the exact
  three-member mutable snapshot (`committed_gap_cursor`, `accepted_edge_count`, `current_gap`) to the existing
  recognition invocation and checkpoint authority. Public cursor/boundary/marks state records remain unchanged.
- Capture-enabled native rules now select and install the local match plus gap candidate before `LS`, retain it
  through action/target/`LE`, commit the accepted post-`LE` cursor before `IT`, and expose successful tails to
  `LX`/`EX`/`E`. Unflagged rules retain the historical LS-before-selection order and existing return authority.
- Added private zero-argument `entry_slot()`, `gap_span()`, `gap_text()`, and `gap_kind()` evaluation with detached
  Unicode-scalar spans, exact named/numeric/unindexed slot provenance, typed unavailable-context errors, and typed
  source-location cursor-regression errors. Nested invocations isolate state and restore the parent candidate;
  recognition rollback restores the same three-member gap snapshot.
- The ignored native consumer covers Unicode and empty prefix/interstitial/tail gaps, candidate-before-LS,
  falsey values, child-extended commits, nested isolation, rollback, lifecycle terminal routes, failed minimum,
  direct entry, detached named slots, and typed failures. Focused execution passes 1/1; private gap units pass 3/3;
  all 170 runtime units and recognition/recursion/cursor/duplicate-slot compatibility suites remain green.
- This is not Rust admission. The ordinary consumer remains 0 passed / 1 ignored; generated plan v2, descriptors,
  reconstruction, generated/emitted/primary execution, canonical/recurring routes, rollout 2/7/56, recognition
  137/246/58, public helpers 122, typed source 9/5/114, and every outward surface remain unchanged.
- The mandatory engineering-notes rollover published content-addressed segment 4996. ADR `0071` reviews only the
  resulting finite capacity step from 11 to 12 controlled files and 10 to 11 manifest lines; all byte, root,
  per-history-file, aggregate, owner, lifecycle, and storage controls remain unchanged.
- Final signoff passes the rendered 79-file / 14,708-KiB mdBook, Knowledge Map 835/7,016, all eight doctrines,
  the 17-owner Rust storage oracle, six-family containment, all-five-anchor relocation, CLI 66/66 in both option
  environments, RAM 49%, Phase 0 1,031/1,031 in 735 seconds, and the exact neutral-plus-Perl gap route with five
  skips through `[ci] local CI gate passed` and exit 0. The first sandboxed run stopped only at the outer harness's
  expected nested-`sandbox-exec` status 71; the unchanged permission-authorized run is authoritative.

## 2026-08-14 — INTER-MATCH-GAP-CAPTURE.3.1 — add Rust authored gap metadata

- Activated task-tree-first from clean atomic-227 commit `4a95e02a`. The final-path Rust consumer produced the
  exact RED on absent declaration-order slot rows before production changes.
- Added one typed Rust AST/validation/compiler path for spacing-insensitive named regex declarations, mixed named
  and anonymous authored order, unindexed/numeric/named selectors, pinned Unicode-17 exact identity, the dedicated
  `@capture_gaps` directive, static eligibility, source/line-aware portable diagnostics, compiled slot/directive
  rows, and resolved selector provenance.
- Preserved anonymous and numeric compatibility, undefined-target diagnostic precedence, serde reconstruction,
  ordinary descriptor shape, generated plan v2, and every runtime carrier. The full 105-source generated manifest
  exposed one `/=/ /next/` ambiguity; restoring anonymous-regex priority repaired it and a focused parser guard
  now makes that precedence durable.
- Staged the final Rust consumer as an explicitly ignored metadata-only test until `.3.5`. The neutral checker
  admits only that dormant file and rejects ten reason-checked Rust mutations covering identity, metadata lock,
  source/parser/validator/compiler/diagnostic seams, canonical and recurring absence, and facade absence. Ordinary
  package execution reports the consumer ignored; focused proof requires `--ignored --exact`.
- Rollout remains exactly 2 complete / 7 pending / 56 semantic mutations; the ten Rust dormancy mutations are
  checker-local. Rust native gap state/accessors/lifecycle, descriptors, generated/emitted/primary behavior,
  canonical/recurring execution, facade/schema/semantic/MCP/CLI/README surfaces, and later runtimes do not move.
- Focused proof passes the dormant stage 1/1, ordinary dormancy 0/1 ignored, core 197 + 4 + 5 + 8 + 5,
  generated manifest 105/105, rule-local cursor 6/6, source emitter 6/6, recognition 137/246/58, typed source
  9/5/114, duplicate slot 7/0/59, and the Rust 17-owner storage/relocation oracle.
- Definitive canonical proof passes all eight doctrines, six-family containment, all-five-anchor relocation, CLI
  66/66 in both option environments, RAM 55%, Phase 0 1,031/1,031, and the opt-in neutral-plus-Perl route with
  five exact pending-runtime skips through `[ci] local CI gate passed` and exit 0. The sandboxed attempt stopped
  only at the outer harness's nested-`sandbox-exec` status 71; the unchanged authorized run is authoritative.

## 2026-08-14 — INTER-MATCH-GAP-CAPTURE.3.0 — freeze Rust gap implementation plan

- Activated task-tree-first from clean atomic-226 commit `eceb15ac`. Retrieved the exact neutral/Perl gap,
  duplicate-slot, rule-local cursor, typed-source, recognition-transaction, generated-source, primary, storage,
  path, task, Knowledge, Toolbox, and ADR authorities before behavior inspection.
- Reproduced current Rust behavior through the committed primary process: numeric selectors succeed; named
  declarations become raw/no-regex state; named selectors fall back to slot zero with an unconsumed suffix;
  `@capture_gaps` is ignored; and `entry_slot()`/`gap_*` remain unknown helpers. Targeted source inspection then
  located the exact parser, AST, compiler, descriptor, native/generated-loop, runtime-frame, accessor, carrier,
  emitter, and primary mechanisms.
- Dependency-split Rust implementation under `.3.1-.3.5`: authored/static/compiled metadata; native state on the
  existing recognition authority; reconstruction/descriptor/generated-plan parity; repository-local independently
  compiled emitted proof; and final primary/admission/route/ledger closeout. Generated plan v2 remains
  `{label,family}` and no second cursor, token family, or invocation stack is permitted.
- Froze final admission at exactly nine once-only roles. Only `.3.5` may promote `rust_runtime` to produce 3/6 and
  replace `rust_runtime_premature` with `rust_runtime_regression` while preserving 56 mutations. Recognition
  137/246/58, public helpers 122, typed source 9/5/114, capability/public surfaces, recurring/public rows, and
  later runtimes remain unchanged or pending.
- Repaired the executable-contract and recurring-governance Knowledge cards that still reported the pre-Perl
  1/8/six-skip boundary, and added the Rust implementation card, ADR amendment, Toolbox route, task/index,
  roadmaps, architecture, bounded live layers, capability guide, and sole-facing mdBook plan. No Rust source,
  contract, checker, driver, rollout, facade/schema/MCP/CLI, or README behavior changed.
- Signoff passes exact gap 2/7/56 and rooted Perl 124/five skips, focused Rust 1/1 in 17.61 seconds, recognition
  137/246/58, typed source 9/5/114, rendered mdBook 79/14,704 KiB, Knowledge 835/7,009, all eight doctrines,
  containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 741 seconds, exact opt-in routing,
  `[ci] local CI gate passed`, and exit 0. The initial sandboxed run stopped only at the outer harness's nested-
  `sandbox-exec` status 71; the unchanged authorized run is authoritative. Atomic 227 remains before `.3.1`.

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.2.4 — admit Perl inter-match gap capture

- Activated task-tree-first from clean atomic-225 commit `45460329`. The existing complete Perl consumer now
  defaults to all metadata, native-live, and independently loaded generated phases while retaining private
  phase selection for focused diagnosis; its ordinary run passes 124 top-level tests.
- Registered the full consumer exactly once in canonical CI and exactly once after the neutral checker in the
  repository-rooted recurring route. The route then emits five ordered skips for Rust, Dart, Julia, PUC Lua, and
  LuaJIT; project-data routing passes from outside the working directory.
- Promoted only `perl_runtime` under owner `.2.4`, advanced the nine-row ledger to 2 complete / 7 pending, replaced
  the Perl-pending mutation with a complete-to-pending regression, and added one premature-Rust mutation for an
  exact total of 56. The obsolete ten-mutation Perl dormancy fence is removed.
- Updated the five governed public-status markers to state private Perl admission while retaining the same ten
  facade/schema/semantic/MCP/CLI/README token guards. Recognition stays 137/246/58, public helpers stay 122,
  typed source stays 9/5/114, duplicate-slot identity stays 7/0/59, and generated plan v2 does not move.
- Closed `.2.4` and parent `.2` after the rendered mdBook, Knowledge 834/6,995, all eight doctrines, containment/
  relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 765 seconds, exact neutral-plus-Perl routing with
  five later-runtime skips, and final local-CI exit 0. Rust `.3` follows only after atomic 226 lands cleanly.

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.2.3 — carry Perl gaps through generated execution

- Started from clean atomic-224 commit `34d02e0c`. Metadata passed 110 assertions, all nine native-live groups
  passed, and generated mode failed only at its deliberate independently-loaded placeholder before implementation.
- Emitted source now imports private `InterMatchGapRuntime`, initializes the generated `Execute` input cursor at
  the same zero boundary as ordinary `Get`, and rethrows every gap-classified typed error through `Execute` and
  `ExecuteWithTrace` instead of replacing it with a generic generated-execution error.
- Made unindexed generated selection use its authoritative dependency-slot row without dereferencing live-only
  rule metadata. Named rows retain exact selector kind, authored selector, target rule/index, and stable slot id;
  unindexed rows retain their compatible nullable slot id. Generated plan v2 stays exact `{label,family}`.
- Replaced the generated placeholder with five independently loaded parity groups / 138 internal assertions over
  Unicode and empty gaps, exact source/slot provenance, falsey values, detached records, child-extended commits,
  LX/EX/E and failed-minimum lifecycle, recursion isolation, same-token rollback, typed context/cursor diagnostics,
  direct entry, and historical legacy-marker output.
- Focused generated-source, rule-local-cursor, typed-source, recognition-transaction, duplicate-slot,
  repeated-action, and logical-helper suites pass. Gap remains 1 complete + 8 pending / 55 mutations plus ten
  dormancy locks; recognition remains 137/246/58, public helpers 122, and typed source 9/5/114. `.2.4` alone may
  register the consumer or admit Perl; facades, schemas, semantic/MCP, CLI, README, and later backends do not move.
- Final canonical proof passes the rendered mdBook, Knowledge Map 834/6,995, all eight doctrines, six-family
  containment, all-five-anchor relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 773 seconds, and the
  exact opt-in neutral-plus-six-pending gap route with local-CI exit 0. The preceding unchanged sandboxed run
  reached only the outer harness's nested-`sandbox-exec` status 71; the permission-authorized run resolved that
  harness boundary without a source change.

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.2.2 — add private Perl native-live gap capture

- Started from clean authored-metadata commit `912fc5ed`. The neutral checker remained green at 1/8/55, metadata
  passed 108, and the deliberately staged live mode failed only at its exact `.2.2` placeholder before runtime
  implementation.
- Added private `LinkedSpec::InterMatchGapRuntime` state directly to the existing recognition invocation guard.
  Candidate gaps install after match extraction, remain visible through `LS`/edge/target/`LE`, commit the accepted
  post-`LE` cursor before `IT`, and expose successful tails to the existing `LX`/`EX`/`E` hooks.
- Added detached direct/action-edge entry-slot identity; exact Unicode-scalar prefix/interstitial/tail spans and
  text/kind reads; falsey-safe accepted edges; child-extended cursor commits; nested/recursive owner isolation;
  typed unavailable-context/cursor-regression errors; and unchanged legacy-marker and return-channel behavior.
- Recognition checkpoints now associate token-keyed detached snapshots of exactly `committed_gap_cursor`,
  `accepted_edge_count`, and `current_gap` on the same guard. Commit discards and rollback restores that snapshot
  without widening the frozen cursor/boundary/marks transaction state or adding another stack/cursor.
- Added four private source-read ActionIR nodes and synchronized the neutral recognition artifact, independent
  checker, policy, and all admitted backend snapshots to 137 rows / 246 calls / 58 mutations. Language coverage
  keeps the staged names non-public, preserving 122 public Perl helpers and typed source 9/5/114.
- Metadata now passes 110 assertions and native-live mode passes all nine behavior groups. Recognition, gap,
  typed-source, and duplicate-slot focused cross-runtime matrices pass. Gap rollout remains 1 complete + 8
  pending / 55 mutations plus ten dormancy locks; generated loading remains `.2.3`, Perl admission remains `.2.4`,
  and outward facades/schemas/semantic/MCP/CLI/README surfaces remain unchanged.
- Updated the gap contract's exact no-overclaim policy/sole-facing marker from “runtime unimplemented” to
  “runtime-admission pending.” The first phrase became false when private native-live staging landed; the new
  marker still rejects generated/loaded, rollout, cross-backend, schema, CLI, and public-admission overclaims
  without changing rollout or mutation counts.
- Rendered the 79-file / 14,672-KiB mdBook, regenerated Knowledge at 834 facts / 6,992 question keys, and passed
  all eight doctrines. The staged sandbox run reached only the outer harness's expected nested-`sandbox-exec`
  status 71 at representative process containment; the unchanged authorized canonical run passed six-family
  containment, all-five-anchor relocation, CLI 66/66 twice, RAM 76%, Phase 0 1,031/1,031 in 756 seconds, the
  exact opt-in neutral-plus-six-pending gap route, `[ci] local CI gate passed`, and exit 0.

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.2.1 — add Perl authored gap metadata

- Started from clean Perl-plan commit `8f826923` and added the dormant final consumer/checker before changing the
  parser. Its six metadata subtests produced five expected RED failures on absent named/directive support.
- Permanently extended `specs/spec.spec` and the reference bridge for spacing-insensitive named regex declarations,
  named/numeric/unindexed selectors, and eligible `@capture_gaps` static metadata. A generated private 806-range
  Perl classifier makes the pinned Unicode 17 table authoritative and reserves ASCII digit-only selector names.
- Added ordered `regex_slots`, exact five-field `resolved_slot_edges`, source/line-aware typed diagnostics, and
  selector provenance in dependency references and generated `dependency_slot_map` rows while preserving legacy
  anonymous AST, `resolved_edges`, and dependency shapes.
- The dormant consumer passes 108 metadata assertions, ordinary named selection, self-target expansion, generated
  provenance, ten exact diagnostics, and unsupported-accessor locks. Its live/generated modes remain deliberately
  unavailable; 10 independent mutations prevent canonical, recurring, or facade admission.
- Neutral rollout remains 1 complete + 8 pending / 55 mutations; recognition remains 133/246/58, public helpers
  122, and typed source 9/5/114. Focused proof passes 108/599 assertions, Unicode regeneration locks 806 ranges,
  five-backend self-host passes 5x2, Knowledge is 834/6,992, and the rendered mdBook is 79/14,668 KiB.
- The first staged canonical pass exposed a bounded-memory omission of historical repeated-action owner
  `FUTURE-PARITY-BACKLOG.10.1`; restoring that exact compact fact fixed the known `.22` marker-anchor coupling
  without weakening the checker. The sandboxed restart then stopped only at expected nested-sandbox status 71.
  Its unchanged authorized rerun passes all eight doctrines, containment/relocation, CLI 66/66 twice, RAM 65%,
  Phase 0 1,031/1,031 in 755 seconds, the exact opt-in gap route, and local-CI exit 0.
