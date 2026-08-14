# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

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

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.2.0 — freeze Perl implementation dependencies

- Started from clean neutral-closeout commit `db299789` and retrieved the Knowledge/ADR/task/neutral artifact,
  selector, cursor, source, transaction, storage, path, and Toolbox authorities before re-deriving Perl behavior.
- Toolbox descriptors and source dumps proved numeric/unindexed slot resolution, exact eligible rule metadata,
  current named/directive/accessor absence, and selection → match → `LS` → action → legacy/authored `LE` → `IT`
  ordering. The corrected historical runtime probe preserves prefix/interstitial pairs and no tail.
- Froze `.2.1` as parsing/static metadata plus a ten-mutation dormant final consumer, `.2.2` as same-guard live
  state/accessors plus recognition-effect synchronization, `.2.3` as emitted/loaded parity, and `.2.4` as Perl-
  only admission and 55→56 gap mutation advancement.
- Host Perl reports Unicode 13, so `.2.1` must generate a private classifier from pinned Unicode 17 data. Four
  private source-read accessor nodes in `.2.2` must update recognition from 133 to 137 rows while preserving 246
  calls, 58 mutations, 122 public helpers, and typed source 9/5/114.
- Changed no grammar, parser, compiler, descriptor, runtime, helper, generated carrier, facade, schema,
  semantic/MCP, CLI, README, capability, typed-source, recurring, rollout, or current behavior in this leaf.
  Synchronized ADR `0045`, a dedicated Knowledge card, task/index, roadmaps, architecture, live layers, and mdBook.
- Signoff passes the rendered mdBook at 79 files / 14,652 KiB, Knowledge at 833 facts / 6,984 keys, all eight
  doctrines, six-family containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 66%,
  Phase 0 1,031/1,031 in 745 seconds, the exact opt-in neutral-plus-six-pending route, and local-CI exit 0.

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.1.3 — close unchanged neutral authority

- Activated task-tree-first from clean recurring-governance commit `0490522b` and retrieved the committed neutral,
  route/storage, public no-overclaim, ADR, Knowledge, and task authorities before executable recomposition.
- Independently proved format/id, 55 unique mutations, exact nine-row 1-complete/8-pending status, neutral-plus-six
  route order, five single current markers, ten outward token guards, and absence of all five planned consumer
  sources; the existing checker and driver pass unchanged.
- Replayed repository-volume tool storage, outside-CWD workflow routing, duplicate-slot 59 across five backends,
  and typed-source 9/5/114 across six runtimes plus their support ledgers.
- Proved all governed artifact/checker/driver, backend, facade/schema/CLI, and README bytes unchanged from
  `0490522b`; only closeout documentation and continuity layers move. Parent `.1` closes with no runtime/public
  promotion, and Perl implementation `.2` is next.
- Synchronized ADR `0045`, a dedicated Knowledge fact, both roadmaps, architecture, task/index, bounded live
  layers, and the sole-facing mdBook while retaining all exact no-overclaim markers.
- Signoff passes rendered mdBook 79 files / 14,632 KiB, Knowledge Map 832 facts / 6,967 keys, all eight doctrines,
  six-family containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 61%, Phase 0
  1,031/1,031 in 725 seconds, the exact opt-in neutral-plus-six-pending route, and local-CI exit 0.

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.1.2 — govern recurring neutral route

- Added `tools/check_inter_match_gap_capture_six_runtime.sh` as one repository-rooted, managed-project-data
  driver. It executes the sole complete neutral route once, then emits exact ordered skips for the pending Perl,
  Rust, Dart, Julia, PUC Lua, and LuaJIT consumers instead of implying runtime admission.
- Registered the neutral checker as an always-on canonical input and the ordered driver behind exact opt-in
  `LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX=1`, with untracked-input, path-portability, syntax, tracked-file, and
  outside-CWD project-data routing coverage.
- Extended the format-1 contract and independent checker with fixed neutral-plus-six route order,
  repository-volume storage, all-runtime-pending assertions, five current-document markers, and ten outward
  facade/schema/CLI/README guards. Named slot syntax, `entry_slot()`, `@capture_gaps`, and `gap_*` remain absent.
- Added checker-first governance before changing the artifact: the committed 50-mutation document failed with
  exact `inter-match gap capture contract: FAIL: required sections drifted`. GREEN preserves rollout 1 complete +
  8 pending and rejects all 55 mutations, including the five new topology/storage/no-overclaim corruptions.
- Synchronized ADR `0045`, architecture, Knowledge, task/index, roadmaps, Toolbox, capability guidance, the
  bounded live layers, and the sole-facing mdBook without changing README or any parser/runtime/public behavior.
- Focused proof passes the neutral/recurring routes, repository-volume tool storage, outside-CWD workflow routing,
  duplicate-slot 59, typed-source 9/5/114, rendered mdBook 78/14,632 KiB, and Knowledge 831/6,960. Canonical
  signoff passes all eight doctrines, six-family containment, all-five-anchor relocation, CLI 66/66 in both
  environments, RAM 61%, Phase 0 1,031/1,031, the exact opt-in pending-route matrix, and local-CI exit 0.

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.1.1 — add executable-neutral contract

- Added format-1 `linkedspec-inter-match-gap-capture-v1` as the behavior-free authority for named regex-slot
  identity, selector provenance, `@capture_gaps` eligibility, typed gap state, exact lifecycle/terminal placement,
  compatibility, diagnostics, planned routes, and the nine-leg rollout.
- Added the independent checker first and proved exact fail-closed absence through the repository-routed command:
  it exited 1 with only `inter-match gap capture contract is missing` before the artifact existed.
- The passing checker independently executes decoded Unicode-scalar prefix/interstitial/tail segmentation, every
  empty boundary, child-extended accepted exit, falsey accepted payload, rollback restoration, and nested-state
  isolation. It locks 8 positive + 10 negative fixtures, 3 sources, 8 private fields, 16 transitions, 10
  segmentation cases, 3 terminal routes, 7 transaction/recursion/return cases, 6 compatibility rows, 9
  diagnostics, and all 50 reason-checked semantic corruptions.
- Promoted only `neutral_contract`: rollout is exactly 1 complete + 8 pending. Named declarations/selectors,
  `entry_slot()`, `@capture_gaps`, and `gap_*` remain future surfaces; no parser, compiler, runtime, descriptor,
  generated carrier, helper, facade, schema, semantic/MCP, CLI, README, capability, or typed-source behavior moved.
- Advanced the existing project-data test's exact Python-entrypoint inventory from 29 to 30 for the new checker;
  this preserves repository-volume containment without registering the future six-runtime/canonical matrix.
- Synchronized ADR `0045`, Knowledge, task/index, roadmaps, architecture, Toolbox, the sole-facing mdBook, and
  bounded live layers. Focused project-routed proof passes with 50/50 corruptions rejected; broader signoff is
  recorded in the owning task verification log.
- Final signoff passes the rendered 79-file/14,628-KiB book, Knowledge 830/6,950, all eight doctrines,
  six-family containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 55%, and
  canonical Phase 0 1,031/1,031 in 737 seconds through exact `[ci] local CI gate passed` and exit 0. The prior
  status 71 was solely the outer workspace denying the gate's nested `sandbox-exec`.

## 2026-08-13 — INTER-MATCH-GAP-CAPTURE.1.0 — freeze executable-neutral plan

- Activated from clean cross-tree handoff `3d0384d1` and retrieved ADRs `0045`/`0047`/`0048`/`0051`/`0056`, the owning tasks,
  Knowledge cards, existing typed-source/transaction/slot contracts, and recurring routes before archaeology.
- Toolbox probes confirm current `Top::OR` is an action-owned seek repetition; `Document[1]` resolves slot 1;
  named declaration and selection reject; emitted Perl orders selection, `LS`, action/target, legacy `LE` rolling,
  then `IT`; the exact historical live result remains `[pre,H]`, `[gap,S]`, `[more,F]` with no automatic tail.
- Froze planned `linkedspec-inter-match-gap-capture-v1`, its checker/path/sections, Unicode named-slot identity,
  selector provenance, directive eligibility/legacy conflict, detached `entry_slot()` and gap accessors, exact
  prefix/interstitial/tail/empty lifecycle, post-`LE` commit, transaction/recursion policy, diagnostics, fixtures,
  mutations, repository-rooted routes, nine rollout legs, carrier roles, and no-overclaim boundary.
- Locked existing return authority: repeated edge returns remain per-hit values, while a default-loop edge return
  unwinds without gap commit or tail fabrication. Corrected ADR `0051`'s stale Lua-pending status from committed
  dual-ABI closure `b14126a6`; no identifier policy changed.
- Changed no parser/compiler/runtime/descriptor/generated/helper/value/facade/schema/semantic/MCP/CLI/README,
  rollout, or current behavior claim. The unchanged duplicate-slot matrix passes 59 mutations and the typed-source
  six-runtime matrix passes 114 mutations.
- The first canonical run caught one condensed task-index row omitting the unrelated preserved marker that
  capability-exclusion public closeout `.24.2` remains closed; restoring that exact marker keeps the capability
  no-drift checker unchanged.
- The restarted canonical run passed all runtime gates through typed source, then caught the same condensation
  class in both roadmap summaries: their closed semantic marker `128 mutations, rollout 9/9` was restored without
  changing the semantic contract or rollout.
- The fully corrected sandboxed run reached only the expected outer-harness denial of nested macOS
  `sandbox-exec` at representative containment. The unchanged permission-authorized retry passed all eight
  doctrines, six-family containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 52%,
  and Phase 0 1,031/1,031 in 735 seconds through exact `[ci] local CI gate passed` and exit 0. The synchronized
  rendered book passes 79 files / 14,628 KiB and Knowledge passes 830 facts / 6,950 question keys.

## 2026-08-13 — FUTURE-PARITY-BACKLOG.14.5.0 — freeze lossless gap handoff

- Audited committed duplicate-slot, typed-source, historical-gap, marker-divergence, ADR, Knowledge, task, and
  recurring-gate authorities from clean recursive-observation closeout `d26e4d4e`.
- Toolbox-led probes confirm current numeric `Rule[N]` descriptor identity, rejection of both named declaration
  and `Rule[name]` surfaces, and exact historical Perl prefix/interstitial gap-plus-lifecycle output without an
  automatic tail. Current markers remain rule-level in Perl, preceding-slot-local in Lua, and non-executing in
  native Rust/Dart/Julia paths.
- Froze `INTER-MATCH-GAP-CAPTURE.1-.7` as the sole named-slot/`@capture_gaps` syntax, lifecycle,
  compatibility, six-runtime, carrier, and public-admission owner. `.14.5.1` may promote only typed-source
  `gap_composition` after that program closes; combined no-drift remains `.14.8`.
- Kept brackets as the selector namespace: numeric selectors are positional compatibility and named selectors
  are stable identity. Dot remains fluent rule behavior, and its first occurrence after an edge target is
  mandatory; neither selector-dot nor whitespace-only fluent attachment is an alias.
- Changed no grammar, parser, compiler, runtime, descriptor, generated carrier, helper/value, facade, schema,
  semantic/MCP, CLI, README, rollout, or current behavior claim. The unchanged duplicate-slot and typed-source
  six-runtime gates pass at 59 and 114 rejected mutations.
- The first canonical attempt correctly exposed an omitted unrelated repeated-action next-owner pointer in the
  bounded MEMORY rewrite; restoring `FUTURE-PARITY-BACKLOG.10.1` made the focused 8-mode / 10-special / 54-mutation
  contract pass. The fully sandboxed restart then reached only the outer harness's expected nested-sandbox denial.
- The unchanged permission-authorized canonical run passes all eight doctrines, complete six-family repository
  containment and all-five-anchor relocation, CLI 66/66 in both option environments, RAM 68%, and Phase 0
  1,031/1,031 in 771 seconds through exact `[ci] local CI gate passed` and exit 0.

## 2026-08-12 — FUTURE-PARITY-BACKLOG.14.4.8 — close recursive observation rollout

- Added an independent recursive-observation public projection/no-drift section to the typed-source contract. Six
  documents now require exact current markers, six stale milestone claims are forbidden, and ten facade/API/schema
  surfaces reject five private observation tokens.
- Added nine contract mutations and eighteen in-memory document/surface mutations, advancing governance from 87
  to 114 without changing the accepted 14-row ledger: `recursive_observation` remains complete and combined
  `recurring_public_no_drift` remains pending under final program-wide `.14.8`.
- Updated the mdBook, capability guide, Toolbox, ADR `0056`, roadmaps, architecture state, Knowledge, and live docs
  to distinguish current public documentation/no-drift from a public API admission. No parser, compiler, runtime,
  storage, helper/value, facade, schema, semantic/MCP, CLI, or README behavior moved.
- Recomposition passes the checker at 6 documents / 6 forbidden / 10 surface guards / 9 complete / 5 pending /
  114 mutations, then Perl/Rust/Dart 7 each, Julia 30, Lua 43 per ABI, and all three support ledgers.
- Definitive canonical CI passes all eight doctrines, containment and relocation, CLI 66/66 in both option
  environments, RAM 57%, Phase 0 1,031/1,031 in 713 seconds, and the full opt-in observation matrix before exact
  `[ci] local CI gate passed` and exit 0. The first staged run stopped only at the outer harness's nested-sandbox
  denial; the unchanged permission-authorized run supplied the authoritative result.

## 2026-08-12 — FUTURE-PARITY-BACKLOG.14.4.7 — recur recursive observation

- Added `tools/check_recursive_observation_six_runtime.sh` as one project-data-routed fail-fast proof over the
  neutral checker, exact Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT observation consumers, then generated-source,
  capability, and language-coverage ledgers. Five sources form six routes because shared Lua runs once per ABI.
- Extended the neutral contract/checker with exact source/route/command/order/multiplicity/support/storage/CI
  topology. Eleven topology/storage mutations plus one recurrence regression advance governance from 75 to 87.
- Promoted only `recursive_observation`, producing 9 complete / 5 pending. The combined final public no-drift row
  remains pending; no parser, compiler, runtime, facade, schema, semantic/MCP, CLI, README, or storage root changed.
- Canonical CI now inventories, machine-path-audits, syntax-checks, and optionally runs the driver through
  `LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX=1`; the workflow-routing harness proves outside-CWD rooted storage.
- Focused proof passes Perl 7, Rust 7, Dart 7, Julia 30, PUC Lua 43, LuaJIT 43, all three support ledgers, storage
  locality across 1,886 governed files, outside-CWD routing, and the broader six-runtime typed-source composition.
- Definitive canonical proof passes all eight doctrines, repository containment/relocation, CLI 66/66 in both
  option environments, RAM 62%, Phase 0 1,031/1,031 in 723 seconds, and the complete recurrence matrix through
  exact `[ci] local CI gate passed`; the prior status-71 stop was solely the outer harness denying nested sandboxing.

## 2026-08-12 — FUTURE-PARITY-BACKLOG.14.4.6 — admit Lua recursive observation

- Added the exact private `observe_recognition(observation, call(Child))` form to shared Lua as one dedicated,
  serialized action node with fail-closed target, operand, static-rule, and transaction-effect validation.
- Reused the existing parse-local recognition invocation authority for direct-parent lineage and fresh rejected-
  attempt ids. One pending-entry scope consumes one ephemeral completion and binds the detached nine-field record
  without adding a second stack or retained parse history.
- Preserved child payload/error identity, zero-based UTF-8-byte registers, child-owned family/cursor policy,
  terminal local match, action-edge single dispatch, and rule-local binding across native, reconstructed,
  generated-plan, and independently loaded emitted-source carriers.
- Added one Lua-5.1-compatible 43-assertion ordinary/canonical consumer covering static drift, falsey success,
  typed Unicode-scalar projection, detachment, failed/zero-regex/action-edge outcomes, nested separation, abort,
  direct/mutual rejection, and all four carriers independently on PUC Lua and LuaJIT.
- Recorded both Lua runtimes alongside Perl, Rust, Dart, and Julia on the still-pending observation row. Typed-
  source governance is now 75 mutations at unchanged 8 complete / 6 pending; recognition remains 129+4/246/58,
  repeated action remains 8/54, language remains 246/105+1/122, and public surfaces stay closed.
- Complete ordinary Lua, storage 18/3, exact six-runtime typed-source, and five-backend repeated-action proof pass.
  ADR, Knowledge, capability guidance, roadmaps/live state, and the sole-facing mdBook are synchronized; recurrence
  and public closeout remain owned by `.14.4.7-.8`. The rendered book passes 79 files / 14,548 KiB, Knowledge
  passes 826 facts / 6,897 question keys, and all eight doctrines pass.
- The first staged canonical run stopped at the README-policy routed-destination guard because ADR `0056` reached
  653 lines against its reviewed 640-line cap. Content-preserving compaction of recent admission amendments and
  consequences returns the ADR to exactly 640 lines without raising or bypassing the pressure control.
- The corrected staged sandbox run passed every doctrine and project gate through relocation, then stopped only
  when the outer harness denied nested macOS `sandbox-exec` with status 71. The unchanged permission-authorized
  canonical run passes containment/relocation, CLI 66/66 in both option environments, RAM 61%, Phase 0
  1,031/1,031 in 734 seconds, and the complete six-runtime typed-source opt-in through exact
  `[ci] local CI gate passed` with exit 0.

## 2026-08-12 — FUTURE-PARITY-BACKLOG.14.4.5 — admit Julia recursive observation

- Added the exact private `observe_recognition(observation, call(Child))` form to Julia as one dedicated action
  expression with fail-closed target, operand, static-rule, and transaction-effect validation.
- Reused the existing parse-local recognition invocation authority for direct-parent lineage and fresh rejected-
  attempt ids. One pending-entry scope consumes one ephemeral completion and binds the detached nine-field record
  without adding a second stack or retained parse history.
- Preserved child payload/error identity, zero-based UTF-8 code-unit registers, child-owned family/cursor policy,
  terminal local match, action-edge single dispatch, and rule-local binding across native, reconstructed,
  generated-plan, and independently loaded emitted-module carriers.
- Added seven ordinary/canonical groups and 30 assertions covering static drift, falsey success, typed Unicode-
  scalar projection, detachment, failed/zero-regex/action-edge outcomes, nested separation, abort, direct/mutual
  rejection, and all four carriers. The combined Julia transaction/observation/typed-source/repeated-action run
  passes 207+30+127+162 assertions.
- Promoted only Julia alongside Perl, Rust, and Dart on the still-pending observation row. Typed-source governance
  is now 74 mutations at unchanged 8 complete / 6 pending; recognition remains 129+4/246/58 and public surfaces
  stay closed. Focused, final full ordinary, storage, six-runtime typed-source, and five-backend repeated-action
  proof pass. The rendered book passes 79 files / 14,528 KiB, Knowledge passes 825 facts / 6,883 question keys,
  and all eight doctrines pass.
- Canonical CI caught a bounded-memory projection dropping the repeated-action contract's historical next owner
  `FUTURE-PARITY-BACKLOG.10.1`; restoring that compact marker keeps `MEMORY.md` at 60 lines and returns the exact
  repeated-action checker to 8/0/54 without weakening it. The sandboxed rerun then stopped only at the expected
  outer-harness denial of nested macOS `sandbox-exec`; the unchanged permission-authorized run passes containment,
  relocation, CLI 66/66 twice, RAM 60%, Phase 0 1,031/1,031 in 725 seconds, and the complete six-runtime typed-
  source opt-in through exact `[ci] local CI gate passed` with exit 0.
