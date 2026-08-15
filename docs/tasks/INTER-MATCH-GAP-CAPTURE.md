# INTER-MATCH-GAP-CAPTURE: Lossless Inter-Match Segmentation

## Metadata

- Tree ID: `INTER-MATCH-GAP-CAPTURE`
- Status: `active` / reconstructed/descriptor/generated Dart carrier leaf `.4.3` is signoff-complete from clean
  atomic 236 at `0b074e1c` under focused verification for intended atomic 237; emitted proof `.4.4` follows only
  after commit/brief-clear/clean handoff; no push
- Roadmap lane: `.spec language evolution / lossless segmentation and source preservation`
- Created: `2026-07-17`
- Last updated: `2026-08-15`
- Owner: repo-local workflow

## Goal

Recover, ratify, and eventually modernize LinkedSpec's historical “super split” mechanism as
inter-match gap capture for repeated OR/default regex rules with action edges. Preserve the
source text between successive matches without coupling the feature to blind-call parser
orchestration or to raw Perl cursor arithmetic.

## Non-Goals

- Do not treat blind calls as part of the “super split” contract.
- Do not change parser/compiler/runtime behavior in the decision-capture leaf.
- Do not start backend rollout before the neutral contract closes; explicit program activation occurred from
  clean cross-tree handoff `3d0384d1`, and runtime leaves `.2-.6` remain pending.
- Do not silently change the existing `@move_pos`, `@capture_from_here`, or `@capture_slice`
  compatibility behavior before a neutral migration contract exists.

## Acceptance Criteria

- The historical Perl algorithm and later documentation drift are recorded accurately.
- The current five-backend marker-scope drift is recorded accurately: Perl's anonymous marker is
  rule-level, Lua's is preceding-slot-local, and Rust/Dart/Julia do not execute the parsed marker in
  their native runtime paths.
- Examples keep regex declarations in their owning target rule and reference those slots from the
  enclosing repeated OR/default rule as `-> Rule` or `-> Rule[index]`; an adjacent regex is never
  presented as the trigger for the following action edge.
- The target rule is demonstrated as a real parser with its own lifecycle/action code, not as a
  passive regex catalog; the enclosing rule owns only repeated edge selection and gap orchestration.
- A durable decision fixes the formal concept, accepted future public name, state model, and rollout boundary.
- Public and continuity documentation no longer associates “super split” with blind calls.
- A future executable contract specifies prefix/interstitial/tail policy, typed spans, action context,
  compatibility aliases, diagnostics, and cross-backend parity before implementation.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `INTER-MATCH-GAP-CAPTURE`
  Status: `active` (2026-08-15; neutral parent `.1` landed cleanly at `db299789`; Perl parent `.2` landed cleanly
    through atomic 226 at `eceb15ac`; Rust `.3.0` landed as atomic 227 at `4a95e02a`; Rust `.3.1` landed as
    atomic 228 at `95127e1d`; Rust `.3.2` landed as atomic 229 at `5c4e9d50`; Rust `.3.3` landed as atomic 230 at
    `9e6ade98`; Rust `.3.4` landed as atomic 231 at `c3326f6d`; `.3.5` and parent `.3` landed as atomic 232 at
    `2800e7c3`; Dart behavior-free planning leaf `.4.0` is signoff-complete from that exact clean boundary for
    intended atomic 233; no push)
  Goal: Recover and modernize lossless inter-match gap capture without semantic drift.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `INTER-MATCH-GAP-CAPTURE.0`
  Status: `done`
  Goal: Recover the historical mechanism and ratify the director-approved design direction.
  Acceptance: Git history and live Perl source prove the repeated-OR/action-edge boundary algorithm;
    the blind-call association is removed; ADR, Knowledge Map, mdBook, task, roadmap, and live docs
    preserve the agreed meaning, the discovered backend drift, and the dependency boundary; no
    runtime behavior changes.
  Verification: Historical source/diff audit, current descriptor/live Perl probes, Knowledge Map,
    mdBook, memory architecture, doctrine enforcement, and whitespace checks pass.
  Commit: `INTER-MATCH-GAP-CAPTURE.0 - ratify inter-match gap capture`

- ID: `INTER-MATCH-GAP-CAPTURE.1`
  Status: `done; signoff-complete` (2026-08-13; `.1.3` independently closes the unchanged neutral authority in
    intended atomic 221/300 from activation commit `0490522b`; no behavior or rollout movement)
  Goal: Define an executable backend-neutral `@capture_gaps` and typed gap-span contract.
  Children: `.1.0`, `.1.1`, `.1.2`, `.1.3`
  Acceptance: The contract fixes prefix/interstitial/tail policy, empty-gap preservation, offsets,
    action ordering, tail handling, state commit, recursion scope, compatibility, diagnostics, and
    conformance fixtures before runtime changes. It also fixes named regex-slot declaration/selection
    syntax and typed target-slot identity before matcher or edge changes. Legacy-marker migration
    starts from the explicit backend matrix recorded in `.0`, not from the later parity claim.
  Verification: exact 1/8/55 model and routed skips, independent structure/absence/no-change proof, storage and
    outside-CWD routing, duplicate-slot 59, typed-source 9/5/114, mdBook 79/14,632 KiB, Knowledge 832/6,967, all
    eight doctrines, containment/relocation, CLI 66/66 twice, RAM 61%, Phase 0 1,031/1,031 in 725 seconds, and the
    exact opt-in route pass through local-CI exit 0.
  Commit: `INTER-MATCH-GAP-CAPTURE.1.3 - close unchanged neutral authority`

- ID: `INTER-MATCH-GAP-CAPTURE.1.0`
  Status: `done; landed at 31f3e664` (2026-08-13; atomic 218/300; no push)
  Goal: Audit committed syntax, matcher, action-edge, cursor, marker, typed-source, compatibility, diagnostic,
    neutral-contract, storage, and recurring-gate authorities and freeze the dependency-complete executable
    contract plan before adding a schema, fixtures, checker, parser, compiler, or runtime behavior.
  Depends on: `.0`, `FUTURE-PARITY-BACKLOG.14.5.0`, complete rule-local cursor and duplicate-slot rollouts.
  Acceptance: prove clean activation; retrieve canonical Knowledge/ADR/task/contracts before archaeology; use
    LinkedSpec Toolbox probes to verify current numeric/unindexed targets, named-surface absence, historical
    prefix/interstitial behavior, marker divergence, typed spans, rule-family/action ordering, commit/failure/
    recursion boundaries, and carriers; specify one exact versioned contract artifact, positive/negative fixtures,
    declaration/selector grammar, typed target identity, gap event/state model, prefix/interstitial/tail/empty
    policy, compatibility matrix, diagnostics, mutation classes, checker, storage and canonical routes, and
    `.1.1-.1.3` ownership; change no grammar, parser/compiler/runtime/descriptor/generated/helper/value/facade/
    schema/semantic/MCP/CLI/README/rollout/current behavior claim; synchronize task/index, ADR/Knowledge, mdBook,
    roadmaps, architecture, and live layers; pass focused/book/doctrine/canonical signoff; commit with the leaf id,
    clear the brief, and land clean before `.1.1`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove committed handoff `3d0384d1`, empty status/diffs, zero-byte brief,
    fresh Knowledge Map, absent rendered-book residue, and no background result before this task-tree-first edit.
  - [x] **RETRIEVE AUTHORITY** — Read the canonical Knowledge cards, ADRs `0045`/`0047`/`0048`/`0051`/`0056`, both handoff
    tasks, existing neutral contracts/checkers, and committed runtime/recurring owners before re-derivation.
  - [x] **TOOLBOX-LED CURRENT AUDIT** — Reverify syntax absence and exact historical/current behavior through
    descriptors, lowering/generated-source probes, direct runtime fixtures, and targeted source locations.
  - [x] **FREEZE EXECUTABLE PLAN** — Specify exact artifact paths, schema/version, cases, state transitions,
    diagnostics, mutations, independent validation, storage/canonical routing, and `.1.1-.1.3` boundaries.
  - [x] **NO OVERCLAIM / LOCKSTEP SIGNOFF** — Move no behavior or rollout; align durable docs and pass the full
    signoff/commit/brief/clean workflow before the next leaf.

- ID: `INTER-MATCH-GAP-CAPTURE.1.1`
  Status: `done; landed at f58dfcb3` (2026-08-13; atomic 219/300; no push)
  Goal: Add the versioned backend-neutral named-slot and lossless-gap contract, exact positive/negative fixtures,
    and independent checker with fail-first then passing mutation evidence; change no runtime implementation.
  Depends on: `.1.0`
  Acceptance: prove clean activation; add the independent checker first, then capture its exact RED for the absent
    governed artifact before creating that artifact; add `capability_conformance/inter_match_gap_capture_contract.json` format 1 / id
    `linkedspec-inter-match-gap-capture-v1` with the frozen 8 positive, 10 negative, 3 source, 8 private-field,
    16 machine-transition, 10 segmentation, 3 terminal-route, 7 transaction/recursion/return, 6 compatibility,
    9 diagnostic, 9 rollout, and 50 semantic-mutation count locks; add independent
    `tools/check_inter_match_gap_capture_contract.py` with exact schema/semantic validation and reason-checked
    in-memory mutation rejection; promote only the neutral rollout row; change no parser/compiler/runtime/
    descriptor/generated/helper/facade/schema/semantic/MCP/CLI/README/backend or public-current behavior claim;
    synchronize task/ADR/Knowledge/roadmaps/live/mdBook and pass focused/book/doctrine/canonical signoff; commit
    with this leaf id, clear the brief, and land clean before `.1.2`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove clean committed `31f3e664`, empty status/diffs, zero-byte brief,
    fresh Knowledge Map, no rendered-book or managed-run residue, and no background result before activation.
  - [x] **EXACT RED** — Add the final checker first, run its governed project-data route before artifact creation,
    and capture only the intended absent-contract failure.
  - [x] **NEUTRAL ARTIFACT** — Encode every frozen fixture, state-machine, lifecycle, compatibility, diagnostic,
    rollout, carrier, storage, and expected-count field without runtime or public promotion.
  - [x] **INDEPENDENT CHECKER / MUTATIONS** — Validate exact schema and semantics, execute the neutral model, and
    reject all 50 reason-checked semantic mutations from in-memory copies.
  - [x] **REPRODUCE / ISSUE** — Checker-first governed execution exits 1 with exact
    `inter-match gap capture contract is missing` while the required artifact is absent.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `.1.0` intentionally froze semantics without an executable artifact, so
    `capability_conformance/inter_match_gap_capture_contract.json` and an independent validator were the exact
    missing neutral authorities before any parser/runtime implementation could begin.
  - [x] **FIX** — Add format-1 contract data plus an independent project-routed checker that validates exact
    schema/policy, executes the frozen state model, and deep-copy corrupts all 50 semantic mutation identities.
  - [x] **ADDRESSED (verified)** — Focused GREEN proves every locked count, executable Unicode/empty/child/
    transaction case, rollout 1 complete + 8 pending, and 50/50 expected-reason rejections.
  - [x] **NO REGRESSION** — The unchanged duplicate-slot five-backend gate passes 59 mutations and typed-source
    six-runtime gate passes 9 complete / 5 pending / 114 mutations; the project-data inventory admits all 30
    Python tool entrypoints under the existing repository-routed boundary; no authored/runtime surface moved.
  - [x] **LOCKSTEP** — ADR, Knowledge, task/index, roadmaps, architecture, Toolbox, bounded live layers, and the
    rendered 79-file mdBook all project the executable-neutral/current-runtime-absent boundary consistently.
  - [x] **NO OVERCLAIM / LOCKSTEP SIGNOFF** — Keep every runtime pending, align durable/public docs, pass focused,
    rendered-book, Knowledge, doctrine, and canonical proof, then commit/clear/clean before `.1.2`.

- ID: `INTER-MATCH-GAP-CAPTURE.1.2`
  Status: `done; landed at 0490522b` (2026-08-13; atomic 220/300; no push)
  Goal: Add storage-rooted recurring/canonical routing, contract topology governance, and public no-overclaim
    guards for the neutral artifact without admitting any backend runtime.
  Depends on: `.1.1`
  Acceptance: prove clean activation; add one ordered six-runtime recurring driver that runs the neutral checker
    once plus only already-complete runtime consumers, so the current 1-complete/8-pending rollout executes no
    future consumer; register the driver under repository-rooted storage and canonical opt-in
    `LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX`; extend exact contract/checker topology, storage, route-order, pending-
    runtime, and public no-overclaim governance from 50 to 55 reason-checked mutations; guard tracked current
    public surfaces against claiming named declarations/selectors, `entry_slot()`, `@capture_gaps`, or `gap_*`
    availability; change no parser/compiler/runtime/descriptor/generated/helper/facade/schema/semantic/MCP/CLI/
    README/backend behavior or rollout status; synchronize task/ADR/Knowledge/roadmaps/live/mdBook and pass
    focused/storage/book/doctrine/canonical signoff; commit with this leaf id, clear the brief, and land clean
    before `.1.3`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove clean committed `f58dfcb3`, absent brief, no rendered-book or
    managed-run residue, and no background result before this task-tree-first activation.
  - [x] **RETRIEVE AUTHORITY** — Read the canonical Knowledge/ADR/task/contract/checker plus analogous recurring,
    storage, canonical-opt-in, and public no-overclaim owners before changing governed routes. Retrieved ADR
    `0045`, the executable-contract Knowledge card, typed-source/recursive-observation recurring and public
    no-drift authorities, both current six-runtime drivers, and the exact canonical/storage/routing registries
    before changing the checker or any governed route.
  - [x] **EXACT RED** — Added the final topology/storage/route/public assertions before the artifact or route;
    the governed checker exited 1 with only
    `inter-match gap capture contract: FAIL: required sections drifted` against the committed 50-mutation
    artifact, proving the new public/topology section is required rather than silently ignored.
  - [x] **ROUTING / TOPOLOGY** — The repository-derived driver enters managed project data, executes the complete
    neutral row once, reports the six pending consumers in exact order without invoking them, and is always
    inventoried/syntax-checked plus opt-in executed by canonical CI through the exact switch.
  - [x] **PUBLIC NO-OVERCLAIM** — Five exact current document markers and ten outward facade/schema/CLI/README
    surfaces prove that named declarations/selectors, `entry_slot()`, `@capture_gaps`, and `gap_*` remain absent.
  - [x] **MUTATION PROOF** — `rollout_sequence`, `runtime_rows_pending`, `storage_paths`, `route_order`, and
    `public_no_overclaim` corruptions are rejected for their exact reasons, advancing neutral governance from 50
    to 55 mutations.
  - [x] **BOUNDED HISTORY** — Required engineering-notes rollover created the eleventh controlled member; ADR
    `0070` reviews only the exact `max_files` 10 → 11 capacity step while every byte/line/member/aggregate limit
    remains unchanged and the new immutable segment stays queryable.
  - [x] **NO REGRESSION / LOCKSTEP** — Behavior and rollout remain at 1 complete + 8 pending. Focused neutral,
    routed-storage, outside-CWD, duplicate-slot 59, typed-source 9/5/114, rendered-book 78/14,632 KiB, Knowledge
    831/6,960, all eight doctrines, containment/relocation, CLI 66/66 twice, RAM 61%, Phase 0 1,031/1,031, and the
    opt-in neutral-plus-six-pending route all pass through exact local-CI success; commit/clear/clean precedes
    `.1.3`.

- ID: `INTER-MATCH-GAP-CAPTURE.1.3`
  Status: `done; signoff-complete` (2026-08-13; task-tree-first from clean recurring-governance commit
    `0490522b`; lands in intended atomic 221/300; no push)
  Goal: Recompose the committed neutral contract, fixtures, mutations, routes, documentation, and no-drift
    boundaries unchanged, close `.1`, and hand off cleanly to Perl implementation `.2`.
  Depends on: `.1.2`
  Acceptance: prove clean activation; retrieve the committed artifact/checker/driver, ADR, Knowledge, task,
    storage, canonical, and public no-overclaim authorities before recomposition; independently verify exact
    artifact identity/counts/schema/model/mutation set, rooted route order and pending-consumer behavior, public
    guards, rollout 1 complete + 8 pending, and absence of every planned parser/runtime/public surface; change no
    artifact, checker, driver, parser/compiler/runtime/descriptor/generated/helper/facade/schema/semantic/MCP/CLI/
    README/capability/typed-source behavior or rollout claim except when a fishy committed inconsistency requires
    a separately owned corrective prerequisite; synchronize task/index, ADR/Knowledge, roadmaps, architecture,
    bounded live layers, and mdBook only for exact closeout truth; pass focused/storage/book/Knowledge/doctrine/
    canonical signoff; close parent `.1`; commit with this leaf id, clear the brief, and land clean before `.2`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove committed `0490522b`, empty status/diffs, absent brief and rendered
    book, zero-byte managed-run root, and no background result owned by this work before task-tree-first activation.
  - [x] **RETRIEVE AUTHORITY** — Used the Knowledge Map first, then read exact committed neutral, recurring-route,
    storage, canonical-opt-in, public no-overclaim, ADR, and parent/task authorities before re-executing facts.
  - [x] **INDEPENDENT RECOMPOSITION** — The exact 1/8/55 checker, rooted neutral-plus-six-skip driver, independent
    JSON/order/marker/surface/consumer proof, storage/outside-CWD tests, duplicate-slot 59 matrix, and typed-source
    9/5/114 matrix pass without editing the governed artifact/checker/driver.
  - [x] **NO-CHANGE DIFF PROOF** — Before closeout-only documentation edits, `git diff 0490522b` contained only
    task-tree activation metadata. The contract/checker/driver, all backend code, ten outward API/schema/CLI/
    README surfaces, and canonical/storage routes were byte-unchanged; any later unexpected drift still stops
    closeout and becomes an owned fix.
  - [x] **PARENT CLOSEOUT / LOCKSTEP** — Durable projections say `.1` closed and `.2` next without claiming
    implementation. Rendered book is 79 files / 14,632 KiB; Knowledge is 832 facts / 6,967 keys; all eight
    doctrines pass; canonical CI passes containment/relocation, CLI 66/66 twice, RAM 61%, Phase 0 1,031/1,031 in
    725 seconds, the exact neutral-plus-six-pending route, and local-CI exit 0. Commit/brief/clean proof remains the
    atomic landing boundary before `.2` activation.

- ID: `INTER-MATCH-GAP-CAPTURE.2`
  Status: `done; signoff-complete` (2026-08-14; `.2.0-.2.3` landed through clean `45460329`; `.2.4` closes the
    Perl implementation/admission parent in intended atomic 226/300; no push)
  Goal: Implement the neutral contract on the Perl reference without overloading `$IPOS`.
  Children: `.2.0`, `.2.1`, `.2.2`, `.2.3`, `.2.4`
  Acceptance: Per-invocation gap state and typed action context replace implicit arithmetic for the new
    surface while legacy spellings retain their governed compatibility behavior. Parsing/metadata precedes live
    state/accessors; emitted/loaded execution follows the live path; admission closes only after every exact Perl
    role, diagnostic, recursion/rollback, legacy-compatibility, and no-overclaim boundary passes.
  Verification: All authored/static, native-live, emitted/loaded, and admitted Perl roles pass. Final admission
    proof is gap 2/7/56, Perl 124 ordinarily and through the rooted route, recognition 137/246/58, public helpers
    122, typed source 9/5/114, duplicate-slot 7/0/59, rendered mdBook, Knowledge 834/6,995, all eight doctrines,
    containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 765 seconds, exact five later-runtime
    skips, `[ci] local CI gate passed`, and exit 0.
  Commit: `INTER-MATCH-GAP-CAPTURE.2.4 - admit Perl inter-match gap capture` (intended atomic 226/300)

- ID: `INTER-MATCH-GAP-CAPTURE.2.0`
  Status: `done; signoff-complete` (2026-08-13; task-tree-first from clean neutral-closeout commit `db299789`;
    lands in intended atomic 222/300; no push; behavior-free audit and dependency plan complete)
  Goal: Reverify the committed Perl grammar/descriptor/generated/runtime/action/typed-source seams and freeze a
    dependency-complete Perl implementation/admission plan before changing behavior.
  Depends on: `.1`, complete rule-local cursor, duplicate-slot identity, typed-source Perl, and recognition
    transaction Perl admission.
  Acceptance: prove clean activation and retrieve canonical Knowledge/ADR/task/contract authorities first; use
    LinkedSpec Toolbox descriptors and generated-source/runtime probes before source inspection; locate exact
    parsing, RuleIR/metadata, resolved-edge provenance, invocation-state, matcher/action/lifecycle, transaction,
    recursion, accessor lowering, diagnostic, emitted-source, independently loaded, recurring-driver, storage,
    and public-no-overclaim seams; reproduce current named declaration/selector/directive/accessor absence and
    legacy anonymous-marker behavior; specify exact RED fixtures, mutation/rollout increments, consumer roles,
    `.2.1-.2.4` ownership, canonical/storage routes, and no-change boundaries; change no grammar, parser, compiler,
    runtime, descriptor, generated carrier, helper, facade, schema, semantic/MCP, CLI, README, capability,
    typed-source, recurring, public, or current behavior in this leaf; synchronize durable projections; pass
    focused/book/Knowledge/doctrine/canonical signoff; commit/clear/clean before `.2.1`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Proved committed `db299789`, empty status/diffs, absent brief/render,
    empty managed-run residue, and no background result owned by this work before activation.
  - [x] **RETRIEVE AUTHORITY** — Queried Knowledge Map first, then read the exact gap contract/checker/driver,
    ADR `0045`, storage/path decisions, selector/cursor/source/transaction authorities, task plan, and Perl
    Toolbox owners before re-deriving a fact.
  - [x] **TOOLBOX-LED PERL AUDIT** — Reproduced current absence and legacy behavior through descriptors,
    generated source, exact runtime probes, and targeted source locations; do not infer behavior by eyeballing.
  - [x] **FREEZE DEPENDENCY PLAN** — Assigned exact files, RED/GREEN fixtures, roles, diagnostics, mutations,
    storage/canonical routes, and `.2.1-.2.4` boundaries with no overlapping owner or premature promotion.
  - [x] **NO OVERCLAIM / LOCKSTEP SIGNOFF** — Rollout remains 1/8 and every planned public surface remains
    absent. Task, ADR/Knowledge, roadmaps, architecture, live layers, and mdBook align; focused and canonical
    proof pass, and the leaf lands clean before `.2.1` activation.

  ### Verified Perl baseline and exact implementation freeze

  - Toolbox descriptors prove unindexed action targets resolve slot zero and `Rule[1]` resolves slot one with
    `family=or_default`, `cursor_policy=seek`, `edge_ownership=action`, `uses_loop=1`, and `repeat_loop`. The
    current frontend rejects `name=/regex/`, `Rule[name]`, and `@capture_gaps`; all four planned accessors lower
    to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:*` and return `undef` today.
  - The corrected historical Perl probe over `preHgapSmoreFtail` returns exactly
    `[["pre","H"],["gap","S"],["more","F"]]` at cursor 13: anonymous `@move_pos` supplies prefix and
    interstitial text but no tail. Generated source orders selection, match extraction, `LS`, edge action,
    legacy marker `LECODE`, authored `LE`, then `IT`; repeat exhaustion branches before selection-local data.
  - `.2.1` changes only authored parsing/static metadata. It updates `specs/spec.spec` first and keeps the
    necessary hardcoded reference bridge in `perl/LinkedSpec/BootstrapSpec/Core.pm` in lockstep; extends
    `Validation.pm`, `RuleIR.pm`, `RuleIR/EmitContext.pm`, `SpecEntry.pm`, `Compiler.pm`, `RuntimeContext.pm`, and
    focused Phase-0/self-host proof. A generated private `perl/LinkedSpec/UnicodeXIDContinue.pm`, owned by the
    existing Unicode-17 generator/checker, prevents host Perl's Unicode 13 tables from defining slot identity.
    Parsed declarations populate ordered `regex_slots`; action dependencies and generated `dependency_slot_map`
    rows carry the five frozen provenance fields. The generated-source v2 plan shape stays unchanged.
  - `.2.1` creates the exact final consumer path in dormant mode. Environment selector
    `LINKEDSPEC_PERL_INTER_MATCH_GAP_RED_MODE=metadata|live|generated` defaults to `metadata`; only metadata is
    GREEN in `.2.1`. Ten checker-local mutations separately lock consumer/mode/three boundaries/diagnostic/
    rooted commands plus absence from canonical execution, the recurring route, and `LinkedSpec.pm`. They do not
    alter the JSON's 55 semantic/topology mutations or 1-complete/8-pending rollout.
  - `.2.2` adds private `perl/LinkedSpec/InterMatchGapRuntime.pm` and threads state through the existing
    `RecognitionTransactionRuntime::InvocationGuard`; there is no second invocation stack and `$IPOS` remains
    legacy-only. Candidate install occurs after match extraction and before `LS`; accepted commit is after
    authored `LE` and before `IT`; successful tails are installed before default `LX`, satisfied-repeat `EX`, or
    maximum `E`. A target child receives a private, target-checked detached `entry_slot`; direct entry is `undef`
    and nested children cannot see a parent's gap candidate.
  - Recognition checkpoints store the three gap snapshot members on the same invocation guard keyed by the
    existing token identity; commit discards that snapshot and rollback restores it. `RecognitionTransaction.pm`'s
    frozen cursor/boundary/marks authority schema does not widen. Four private ActionIR nodes
    `ENTRY_SLOT_READ`, `GAP_SPAN_READ`, `GAP_TEXT_READ`, and `GAP_KIND_READ` classify as `source_read`, so `.2.2`
    synchronizes the closed recognition-effect authority and admitted consumer snapshots from 133 to 137 rows
    (133 current + four dedicated) while keeping 246 canonical calls, 58 mutations, rollout 9/9, and the 122
    public helper inventory unchanged. Language coverage classifies the four staged Perl names non-public;
    typed-source 9/5/114 and its 92+7 helper algebra do not move before `.7`/`.14.5.1` composition.
  - `.2.3` adds emitted and independently loaded execution without changing plan v2: generated handler source
    imports the private runtime, generated dependency rows retain selector provenance, gap errors remain typed
    across `Execute`/`ExecuteWithTrace`, and the unchanged `generated` consumer mode proves values, diagnostics,
    recursion, rollback, lifecycle, and legacy compatibility against live execution.
  - `.2.4` removes dormancy from the already-full consumer, executes it exactly once through canonical CI and
    the rooted gap driver, and promotes only `perl_runtime` under owner `.2.4`. The JSON checker keeps the existing
    pending-runtime intent as exact `perl_runtime_regression` and `rust_runtime_premature` corruptions, advancing
    55 to 56. Public-current markers may teach private Perl
    implementation while outward facade/schema/semantic/MCP/CLI/README guards remain unchanged; Rust through
    public no-drift stay pending.

  Verification: Focused proof preserves gap 1/8/55, recognition 133/246/58, language coverage 246 calls / 122
    public helpers, typed source 9/5/114, duplicate-slot identity, and all six typed-source runtime routes. The
    rendered mdBook is 79 files / 14,652 KiB; Knowledge is 833 facts / 6,984 keys; all eight doctrines pass;
    repository containment and all-five-anchor relocation pass; CLI passes 66/66 in both option environments;
    RAM is 66% below the 88% ceiling; Phase 0 passes 1,031/1,031 in 745 seconds; the opt-in gap route passes the
    neutral contract and six exact pending skips; local CI exits 0.
  Commit: `intended atomic 222/300; no push`

- ID: `INTER-MATCH-GAP-CAPTURE.2.1`
  Status: `done; signoff-complete` (2026-08-13; task-tree-first from clean Perl-plan commit `8f826923`; intended
    atomic 223/300; no push; clean fresh-session handoff follows landing)
  Goal: Add exact Perl authored parsing, static validation, resolved named-slot identity, directive metadata, and
    descriptor/generated-carrier provenance without executing gap capture.
  Acceptance: checker-first dormant RED covers accepted/rejected declaration, selector, directive, diagnostics,
    stable identity, duplicate-regex identity, exact Unicode-17 classification, metadata/generated provenance,
    ten dormancy mutations, and no-execution boundaries; runtime/accessor behavior remains pending.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove atomic 222 at `8f826923`, empty staged/unstaged status, zero-byte
    brief, zero managed-run residue, and no background result before this task-tree-first activation.
  - [x] **RETRIEVE AUTHORITY / TOOLBOX FIRST** — Read the `.2.0` Knowledge/ADR/task freeze and exact current
    grammar, BootstrapSpec, descriptor, generated-source, Unicode, duplicate-slot, and dormant-consumer owners;
    use descriptors/source dumps before source inference.
  - [x] **CHECKER-FIRST DORMANT RED** — Add the exact full-path Perl consumer and its independent checker-local
    ten-mutation dormancy contract first. Prove metadata mode fails only for absent named-slot/directive metadata
    while live/generated modes remain intentionally dormant and canonical/recurring/facade routes stay absent.
    The checker-first consumer ran six metadata subtests before implementation: five failed, with named selectors
    rejected as malformed and `@capture_gaps` rejected as malformed, while live/generated remained deliberately
    fenced rather than being mistaken for implementation failures.
  - [x] **AUTHORED GRAMMAR / UNICODE IDENTITY** — Add spacing-insensitive named declarations, named selectors,
    and eligible `@capture_gaps` parsing in `specs/spec.spec` plus the necessary hardcoded reference bridge.
    Generate and consume pinned Unicode-17 slot identity; reserve all-digit ASCII names for positional selectors.
  - [x] **STATIC METADATA / DIAGNOSTICS** — Preserve authored declaration order and exact selector provenance in
    RuleIR, resolved dependencies, descriptors, and generated dependency-slot rows. Reject duplicate/invalid
    names, unknown named selectors, illegal directives, and legacy-marker conflicts with exact typed diagnostics.
  - [x] **NO LIVE EXECUTION / NO OVERCLAIM** — Keep gap accessors unsupported and introduce no invocation state,
    lifecycle placement, transaction/effect-census change, emitted execution, recurring/canonical consumer route,
    facade/schema/semantic/MCP/CLI/README claim, rollout promotion, or current-count movement.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index, ADR/Knowledge, roadmaps, architecture, bounded live layers,
    and mdBook; pass focused self-host/Phase-0, dormant-contract mutations, duplicate-slot, Unicode, generated-
    source, storage, Knowledge, doctrine, and canonical proof; commit/clear/clean atomic 223 before `.2.2`. The
    first fully staged canonical run passed every earlier gate through composed semantic-introspection, then the
    repeated-action checker rejected the bounded `MEMORY.md` rewrite because it had dropped historical next owner
    `FUTURE-PARITY-BACKLOG.10.1`. This is the already-known marker-anchor coupling owned by
    `FUTURE-PARITY-BACKLOG.22`; restore the exact compact fact and rerun unchanged without weakening the checker.
    The repaired repeated-action check passes 8/0/54. The sandboxed restart then reached only the outer harness's
    expected nested-`sandbox-exec` status 71 at representative-process containment; the unchanged authorized run
    passes all eight doctrines, six-family containment, all-five-anchor relocation, CLI 66/66 in both option
    environments, RAM 65% below the 88% ceiling, Phase 0 1,031/1,031 in 755 seconds, the exact neutral-plus-six-
    pending opt-in gap route, and `[ci] local CI gate passed`. Knowledge is 834 facts / 6,992 keys and the rendered
    mdBook is 79 files / 14,668 KiB. Per the director's fresh-session instruction, land/clear/prove clean and stop
    for `/clear`; do not activate `.2.2` in this session.

  Verification: Dormant Perl consumer 108 assertions; eight focused Perl files 599 assertions; Unicode 17
    regeneration 806 ranges / 9 semantic groups / 8 invalid cases / 2 drift mutations; gap 1/8/55 plus 10 Perl
    dormancy mutations; five-backend self-host 5x2; recognition 133/246/58; public helpers 122; typed source
    9/5/114; Knowledge 834/6,992; rendered mdBook 79/14,668 KiB; eight doctrines; containment/relocation; CLI
    66/66 twice; RAM 65%; Phase 0 1,031/1,031 in 755 seconds; exact opt-in gap route; local-CI exit 0.
  Commit: `intended atomic 223/300; no push`

- ID: `INTER-MATCH-GAP-CAPTURE.2.2`
  Status: `done; signoff-complete` (2026-08-13;
    activated task-tree-first from clean `912fc5ed`; no implementation edit preceded this activation)
  Goal: Add invocation-local Perl gap state, exact matcher/action/lifecycle/terminal/transaction/recursion behavior,
    and detached `entry_slot()`/`gap_*` accessors on the live native path without overloading `$IPOS`.
  Acceptance: prefix/interstitial/tail/empty spans, commit/failure/unwind, falsey results, child-extended exits,
    recursion isolation, diagnostics, legacy compatibility, same-guard transaction snapshots, and the exact
    137/246/58 recognition plus 122-public-helper no-drift boundary match the neutral model.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove clean atomic 223 at `912fc5ed`, empty staged/unstaged status,
    absent brief and background work, retrieve Knowledge/ADR/task authorities, and activate this leaf before code.
  - [x] **REPRODUCE / ISSUE** — The project-routed neutral checker passes 1/8/55 and metadata mode passes 108;
    `LINKEDSPEC_PERL_INTER_MATCH_GAP_RED_MODE=live` fails only at the deliberate `.2.2` placeholder.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Descriptor/lowering/generated-source probes proved that `.2.1` supplied
    slot/directive metadata but deliberately had no same-guard state, accessor nodes, candidate/commit/tail
    lifecycle seams, or transaction snapshots. Existing recognition guards/tokens and emitted hook order are the
    exact composition authorities; a second cursor or stack would violate them.
  - [x] **FIX** — Add only the private live Perl authority, exact four ActionIR source-read nodes, lifecycle
    integration, same-token snapshots, and full live-mode fixtures; do not admit generated/loaded or public use.
  - [x] **ADDRESSED (verified)** — All nine live groups prove neutral segmentation, lifecycle, failure, rollback,
    recursion, target-slot, diagnostic, falsey, and legacy-compatibility behavior; metadata mode passes 110.
  - [x] **NO REGRESSION** — Recognition is exactly 137/246/58, public helpers remain 122, gap rollout remains
    1/8/55 plus dormant admission locks, typed source remains 9/5/114, all focused matrices pass, and Phase 0
    passes 1,031/1,031 canonically in 756 seconds.
  - [x] **LOCKSTEP** — Task/index, ADR/Knowledge, roadmaps, architecture, bounded live layers, and mdBook agree
    without claiming generated/loaded execution, Perl admission, another backend, or an outward API. Rendered
    book 79/14,672 KiB, Knowledge 834/6,992, all eight doctrines, containment/relocation, CLI 66/66 twice, RAM
    76%, Phase 0 1,031/1,031 in 756 seconds, and the exact opt-in gap route pass canonical CI with exit 0.

- ID: `INTER-MATCH-GAP-CAPTURE.2.3`
  Status: `done; signoff-complete` (2026-08-13; intended atomic 225/300 from clean activation `34d02e0c`;
    no push)
  Goal: Carry the admitted Perl metadata/state/accessor behavior through emitted source and independently loaded
    execution, preserving exact source/slot identity and repository-local storage.
  Acceptance: live and emitted/loaded roles agree byte-for-byte on values, diagnostics, lifecycle, rollback,
    recursion, selector provenance, and legacy compatibility without generated-plan-v2 or facade/schema/CLI/
    README promotion.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove clean atomic 224 at `34d02e0c`, empty staged/unstaged status,
    absent brief and background work, retrieve Knowledge/ADR/task authorities, and activate this leaf before code.
  - [x] **REPRODUCE / ISSUE** — Metadata passed 110, all nine native-live groups passed, and generated mode failed
    only at the deliberate independently-loaded `.2.3` placeholder before implementation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Toolbox source dumps proved emitted handlers retained gap calls and
    five-field provenance, while the generated preamble omitted the private runtime, `Execute` omitted typed-gap
    passthrough and ordinary zero-entry cursor initialization, and generated descriptor entries are handlers rather
    than the live metadata hashes assumed by the unindexed fallback.
  - [x] **FIX** — Add only the private generated carrier seams, exact descriptor-shape guard, and a full
    independently-loaded parity consumer;
    do not widen generated plan v2 or promote facade/schema/CLI/README/runtime admission.
  - [x] **ADDRESSED (verified)** — Five generated groups / 138 internal assertions agree exactly with live on
    source/slot values, cursors, diagnostics, lifecycle, rollback, recursion, provenance, falsey returns, direct
    entry, and legacy compatibility through `Execute` and `ExecuteWithTrace`.
  - [x] **NO REGRESSION** — Recognition remains 137/246/58, public helpers 122, gap 1/8/55 plus ten dormancy locks,
    and typed source 9/5/114. Focused recognition, typed-source, duplicate-slot, generated-source, cursor,
    repeated-action, and logical-helper proof passes; canonical Phase 0 passes 1,031/1,031 in 773 seconds.
  - [x] **LOCKSTEP** — Task/index, ADR/Knowledge, roadmaps, architecture, bounded live layers, and rendered mdBook
    agree while Perl admission and all outward/later-backend surfaces remain pending. Knowledge is 834/6,995;
    all eight doctrines, containment/relocation, CLI 66/66 twice, RAM 57%, and the exact opt-in gap route pass.

  Verification: metadata 110; native-live nine groups; generated five groups / 138 internal assertions; exact
    gap 1/8/55 + ten dormancy mutations; recognition 137/246/58; public helpers 122; typed source 9/5/114;
    focused dependent matrices; rendered book; Knowledge/doctrines; permission-authorized canonical CI with
    containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 773 seconds, and exit 0.

  Commit: `INTER-MATCH-GAP-CAPTURE.2.3 - carry Perl gaps through generated execution` (intended atomic 225/300)

- ID: `INTER-MATCH-GAP-CAPTURE.2.4`
  Status: `done; signoff-complete` (2026-08-14; task-tree-first from clean atomic-225 commit `45460329`;
    intended atomic 226/300; no push)
  Goal: Compose exact Perl admission, mutation/rollout updates, recurring-route activation, ledgers, and unchanged
    public no-overclaim, then close parent `.2` cleanly for Rust `.3`.
  Acceptance: the exact Perl consumer runs once ordinarily and canonically; only `perl_runtime` becomes complete
    and semantic/topology mutation proof advances exactly 55 to 56; remaining runtimes, recurring, public
    no-drift, capability, typed-source composition, and outward APIs stay pending; all focused and broad gates
    pass.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove atomic 225 at `45460329`, empty Git status, zero-byte brief, no
    background work, and retrieve task/ADR/Knowledge authorities before admission edits.
  - [x] **EXACT ADMISSION DELTA** — Register the existing full Perl consumer once in canonical CI and once in the
    repository-rooted recurring route; remove only obsolete Perl dormancy enforcement.
  - [x] **ROLLOUT / MUTATION** — Promote only `perl_runtime` to complete with this leaf as owner and advance the
    checker from 55 to 56 through exact Perl regression plus premature-Rust rejection.
  - [x] **NO OVERCLAIM** — Keep Rust, Dart, Julia, PUC Lua, LuaJIT, recurring/public no-drift, capability admission,
    typed `gap_composition`, facade/schema/semantic/MCP/CLI/README, and generated-plan v2 unchanged or pending.
  - [x] **PROOF** — Pass the full Perl consumer, neutral checker and mutations, rooted recurring driver, focused
    dependent matrices, rendered mdBook, Knowledge Map, all doctrines, and canonical local CI with the opt-in route.
  - [x] **LOCKSTEP / HANDOFF** — Synchronize task/index, ADR/Knowledge, roadmaps, bounded live layers, and mdBook;
    close parent `.2`, commit with this leaf id, clear the brief, and hand a clean frontier to Rust `.3`.

  Verification: Full Perl passes 124 ordinarily and through the rooted route; gap is 2/7/56; project-data and
    outside-CWD routing pass; language is 246/122; recognition is 137/246/58; typed source is 9/5/114; duplicate
    slot is 7/0/59; rendered mdBook and Knowledge 834/6,995 pass; all eight doctrines pass. Canonical CI passes
    containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 765 seconds, the exact neutral-plus-
    Perl route with five ordered later-runtime skips, `[ci] local CI gate passed`, and exit 0.
  Commit: `INTER-MATCH-GAP-CAPTURE.2.4 - admit Perl inter-match gap capture` (intended atomic 226/300)

- ID: `INTER-MATCH-GAP-CAPTURE.3`
  Status: `done; signoff-complete` (2026-08-15; `.3.1-.3.4` landed through emitted proof atomic 231 at
    `c3326f6d`; final private Rust primary/admission `.3.5` closes the parent for intended atomic 232)
  Goal: Implement exact Rust native/generated/primary parity.
  Children: `.3.0`, `.3.1`, `.3.2`, `.3.3`, `.3.4`, `.3.5`
  Acceptance: Rust passes the neutral gap corpus and every admitted execution role.
  Verification: Rust executes all nine admitted roles once; gap governance is 3/6/56 plus ten Rust admission
    mutations. Focused, ordinary, rooted, storage, rendered-book, Knowledge, all-doctrine, containment,
    relocation, CLI 66x2, RAM 73%, Phase 0 1,031/1,031, and canonical local-CI exit-0 proof pass.
  Commit: `INTER-MATCH-GAP-CAPTURE.3.5 - admit Rust inter-match gap capture` (intended atomic 232/300)

- ID: `INTER-MATCH-GAP-CAPTURE.3.0`
  Status: `done; signoff-complete` (2026-08-14; task-tree-first from clean atomic-226 commit `eceb15ac`; intended
    atomic 227/300; no Rust behavior or rollout change; no push)
  Goal: Reverify the committed Rust parser/compiler/runtime/carrier/emitter/primary seams and freeze an exact
    dependency-complete implementation/admission plan before changing Rust behavior.
  Depends on: `.2`, the neutral gap contract, complete Rust duplicate-slot identity, rule-local cursor, typed
    source, recognition transaction, generated-source, primary-CLI, and emitted-source authorities.
  Acceptance: prove clean activation and retrieve canonical Knowledge/ADR/task/contract authorities first; use
    LinkedSpec's contract and source/runtime probes before inference; locate exact named declaration/selector,
    directive, source-AST, validation, compiled metadata, selected-slot identity, invocation state, matcher/action/
    lifecycle, transaction/recursion, accessor, diagnostic, serialization/reconstruction, descriptor,
    generated-plan, emitted-source, primary-command, recurring-driver, storage, and public-no-overclaim seams;
    reproduce current Rust absence or drift against the admitted Perl/neutral behavior; specify exact RED/GREEN
    fixtures, role boundaries, mutation/rollout increments, canonical/storage routes, and `.3.1-.3.5` ownership;
    change no Rust parser/compiler/runtime/carrier/emitter/CLI behavior, gap rollout, public facade/schema/MCP,
    capability, typed-source composition, README, or generated format in this leaf; synchronize durable
    projections; pass focused/book/Knowledge/doctrine/canonical signoff; commit/clear/clean before `.3.1`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove atomic 226 at `eceb15ac`, empty staged/unstaged/untracked status,
    zero-byte brief, absent rendered-book residue, and no owned background result before this task-tree-only edit.
  - [x] **RETRIEVE AUTHORITY** — Query the Knowledge Map first, then read the exact gap, Rust selector/cursor/
    transaction/source/generated/primary, storage, path, and public-no-overclaim owners before re-derivation.
  - [x] **TOOLBOX-LED RUST AUDIT** — Reproduce current grammar/metadata/runtime/carrier/primary behavior and locate
    the exact mechanism plus source location through project probes and focused tests.
  - [x] **FREEZE DEPENDENCY PLAN** — Assign exact files, RED/GREEN roles, diagnostics, mutations, routes, and
    non-overlapping `.3.1-.3.5` boundaries before implementation.
  - [x] **NO OVERCLAIM / LOCKSTEP SIGNOFF** — Move no behavior or rollout; align durable projections and pass
    focused/rendered-book/Knowledge/doctrine/canonical proof before the atomic landing.

  ### Verified Rust Baseline

  - The exact neutral checker passes 8 positive + 10 negative fixtures, 3 sources, 16 transitions, 10
    segmentation cases, 9 diagnostics, rollout 2 complete + 7 pending, and 56 rejected mutations. The rooted
    route executes neutral then the admitted 124-test Perl consumer and skips Rust plus four later runtime rows.
  - Primary-process probes through the committed `rust/target/debug/linkedspec-rust` prove current behavior rather
    than inferred absence. Numeric `Rule[N]` selection succeeds; named `name=/regex/` is classified as raw text and
    leaves the target with zero regexes; `Rule[name]` silently falls back to numeric slot zero while leaving its
    bracket suffix unconsumed; `@capture_gaps` is ignored as raw text; all four accessors remain unknown helpers.
  - `rust/linkedspec-core/src/parser.rs::parse_single_element` recognizes only bare `/regex/` declarations and the
    four legacy split markers. `parse_action_edge_prefix` delegates brackets to digit-only `parse_index_at`, whose
    failure returns the default index without consuming `[name]`. `ast.rs` consequently retains neither a slot id,
    typed selector, nor a dedicated gap directive.
  - `rust/linkedspec-core/src/compiler.rs::compile_rule` reduces declarations to `regex_patterns`, edges to numeric
    `DependencyRef`/`AcodeEntry` fields, drops split markers, and has no capture flag. `types.rs` and
    `descriptor.rs` therefore cannot preserve the five resolved-edge fields or directive/slot provenance.
  - Native `Engine` and the separate `GeneratedPlanExecutor` both enter the existing recognition invocation,
    execute `LS`, select a match, dispatch the edge/target, execute `LE`, then `IT`. Their selected-slot helpers
    already preserve exact `{target_rule,regex_index}` identity, but candidate installation must move ahead of
    `LS` only for capture-enabled rules. Both executors need the same candidate/commit/tail calls; unflagged order
    must remain byte-for-byte compatible.
  - `RuntimeContext` already owns the immutable `input` source authority and the single
    `RecognitionTransactionAuthority`. Its checkpoint snapshots cursor, anonymous boundary, and marks; gap state
    must extend that same private frame/snapshot and invocation stack. A second cursor, transaction token family,
    or invocation stack is prohibited. Existing public `state_record()` output must not widen.
  - `rust/linkedspec-runtime/src/source_emitter.rs` embeds serialized `CompiledSpec` and emits a static
    label/family-only v2 plan. Gap metadata belongs in that compiled payload, descriptor projection, and both
    runtime executors; generated plan v2 remains `{label,family}`. The primary adapter already uses the same
    parse/validate/compile/execute pipeline and needs proof, not a new CLI option.
  - The neutral recognition ledger already includes the four Perl-established gap read nodes as `source_read` and
    is current at 137 rows / 246 calls / 58 mutations. Rust private zero-argument helper execution joins that
    semantic class without adding public canonical-call rows or moving the ledger. The 122 public-helper inventory,
    typed-source 9 complete / 5 pending / 114 mutations, capability census, facade/schema/MCP/README surfaces, and
    public no-overclaim remain unchanged.
  - Two older Knowledge cards still reported the pre-admission 1/8 rollout and six runtime skips after committed
    `.2.4` had established 2/7 and five skips. `.3.0` repairs those retrieval authorities as a behavior-free
    governance correction and records the Rust plan so subsequent sessions do not repeat this audit.

  ### Frozen `.3.1-.3.5` Dependency Plan

  - `.3.1` owns `rust/linkedspec-core/src/ast.rs`, `parser.rs`, `validation.rs`, `types.rs`, `compiler.rs`, and their
    focused tests plus the final-path `rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs` staging.
    Add Unicode-17 named/anonymous declaration identity, an explicit unindexed/numeric/named selector type,
    directive provenance, exact source/line-aware static diagnostics, compiled slot rows, capture eligibility, and
    five-field resolved edges. Preserve serde defaults for legacy reconstructed state. This leaf proves authored
    parsing/static/compiled provenance only; it must not execute gap state or admit the consumer.
  - `.3.2` owns `rust/linkedspec-runtime/src/recognition_transaction.rs`, `runtime.rs`, and the native `Engine`
    branches in `engine.rs`. Attach `{source_id,invocation_id,committed_gap_cursor,accepted_edge_count,current_gap}`
    plus detached entry-slot identity to the existing invocation frame; include only the three mutable gap members
    in its existing checkpoint snapshot. Add private zero-argument `entry_slot`/`gap_*` evaluation and exact typed
    unavailable-context errors. Native selection installs the decoded-scalar candidate before `LS`, preserves it
    through target/action/`LE`, commits post-`LE` before `IT`, and installs successful tails before `LX`/`EX`/`E`.
  - `.3.3` owns `rust/linkedspec-core/src/descriptor.rs`, compiled-state reconstruction assertions, and the
    generated-plan branches in `rust/linkedspec-runtime/src/engine.rs`/`source_emitter.rs`. Project slot/directive/
    five-field edge provenance, prove serde round trips, and make `GeneratedPlanExecutor` use the same runtime gap
    frame/lifecycle without adding plan fields or changing `linkedspec-generated-source-v2`.
  - `.3.4` owns the independently compiled emitted-source role in the final Rust consumer. Emit with
    `emit_rust_source_v2`, compile offline, and execute direct/traced values, terminal lifecycle, diagnostics,
    rollback, recursion, direct-entry, and legacy controls from a repository-derived scratch workspace and target
    directory. Do not use `std::env::temp_dir()`, `/tmp`, home caches, or another volume.
  - `.3.5` owns the `primary_command` role, exact nine-role once-only composition, ordinary/canonical registration,
    recurring-driver activation, contract/checker admission delta, live ledgers/docs, and parent closeout. Promote
    only `rust_runtime`: rollout becomes 3 complete + 6 pending, the route executes neutral/Perl/Rust then skips
    Dart, Julia, PUC Lua, and LuaJIT, and `rust_runtime_premature` becomes `rust_runtime_regression` while the
    mutation total stays 56. Recurring/public rows, typed gap composition, capability admission, generated-plan
    format, public facade/schema/semantic/MCP/CLI/README surfaces, and later runtimes remain pending or unchanged.

  ### Role and Verification Boundaries

  - The final Rust consumer implements exactly the contract-declared roles in order:
    `native_execution`, `ordinary_reconstruction`, `descriptor`, `generated_plan`, `emitted_source`,
    `target_lifecycle`, `recursion_and_rollback`, `portable_diagnostics`, and `primary_command`. Earlier leaves may
    stage only their implemented subsets; `.3.5` removes every staging guard and proves each declared role once.
  - Focused work uses `bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml ...`, the neutral checker,
    the rooted gap route, recognition 137/246/58, typed source 9/5/114, duplicate-slot 7/0/59, and project-data
    locality/oracle checks. Each leaf also renders/verifies the mdBook, regenerates/checks Knowledge, runs all
    doctrines, and completes canonical local CI before its commit/brief-clear/clean boundary.
  Verification: Exact gap 2/7/56 and rooted neutral-plus-Perl-124/five-skip route pass; recognition remains
    137/246/58, public helpers 122, typed source 9/5/114, and duplicate-slot 7/0/59. The focused Rust duplicate-
    slot test passes 1/1 in 17.61 seconds. Rendered mdBook is 79 files / 14,704 KiB, Knowledge is 835/7,009, all
    eight doctrines pass, and the unchanged permission-authorized canonical run passes containment/relocation,
    CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 741 seconds, exact opt-in gap routing, `[ci] local CI gate
    passed`, and exit 0. The preceding sandboxed run stopped only at the outer harness's nested-`sandbox-exec`
    status 71. No Rust implementation source, contract, checker, driver, rollout, or outward surface moved.
  Commit: `INTER-MATCH-GAP-CAPTURE.3.0 - freeze Rust gap implementation plan`

- ID: `INTER-MATCH-GAP-CAPTURE.3.1`
  Status: `done; signoff-complete` (2026-08-14; task-tree-first from clean atomic-227 commit `4a95e02a`; intended
    atomic 228/300; no live gap execution or rollout admission in this leaf; no push)
  Goal: Add exact Rust authored parsing, static validation, slot/directive metadata, and compiled provenance.
  Depends on: `.3.0`, neutral gap contract format 1, pinned Unicode-17 rule-label identity, Rust duplicate-slot
    identity, repeated-action ownership, recognition-effect policy, and serde reconstruction compatibility.
  Acceptance: prove clean activation and retrieve the frozen Rust plan plus exact neutral/Perl/slot/Unicode/
    repeated-action/serialization authorities before code; add spacing-insensitive named declarations, explicit
    unindexed/numeric/named selectors, dedicated directive evidence, source/line-aware static diagnostics,
    declaration-order slot rows, capture eligibility, and five-field resolved edge provenance through Rust source
    AST, validation, types, and compilation; preserve anonymous/numeric compatibility and serde defaults; add the
    final Rust consumer at `rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs` in an explicitly
    dormant metadata-only stage; capture exact RED before implementation and GREEN after it; extend only the
    neutral checker's local dormancy governance with ten reason-checked Rust mutations plus canonical/recurring/
    facade absence locks, following admitted Perl `.2.1` precedent; change no native gap state/accessor/lifecycle,
    reconstruction/descriptor/generated/emitted/primary behavior, neutral JSON semantics/counts, recurring route,
    rollout 2/7/56, generated-plan v2, facade/schema/semantic/MCP/CLI/README/public surface, or later runtime;
    synchronize live/public/durable projections; pass focused Rust/neutral/recognition/typed-source/duplicate-slot/
    storage/book/Knowledge/doctrine/canonical signoff; commit/clear/clean before `.3.2`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove committed `4a95e02a`, empty staged/unstaged/untracked status,
    zero-byte brief, no rendered-book residue or owned background result, and activate only this task node before
    any source, test, or other documentation change.
  - [x] **RETRIEVE AUTHORITY** — Query the Knowledge Map first, then read the Rust implementation card, neutral
    artifact/checker, Perl authored/static implementation, Unicode-17 identity, duplicate-slot, repeated-action,
    serde/descriptor, and exact existing Rust tests before implementation.
  - [x] **EXACT RED** — Add the final-path consumer in metadata-only staging and prove only the expected absent
    named-slot/directive/provenance assertions fail against clean atomic 227.
  - [x] **AUTHORED / STATIC / COMPILED GREEN** — Implement named declarations/selectors, directive/eligibility,
    slot rows, selector provenance, and portable diagnostics through one typed AST/compiler path.
  - [x] **COMPATIBILITY / CARRIERS** — Preserve anonymous declaration order, unindexed/numeric selectors, legacy
    markers, serde defaults, ordinary existing descriptors, and generated plan v2 without live gap execution.
  - [x] **NO OVERCLAIM / LOCKSTEP SIGNOFF** — Keep Rust pending at 2/7/56, align durable projections, and pass
    focused/rendered-book/Knowledge/doctrine/canonical proof before the atomic landing.
  Verification: Exact RED failed 1/1 in 0.31 seconds only on absent authored slot rows. Focused GREEN passes 1/1
    in 1.47 seconds only when explicitly selected with `--ignored --exact`; ordinary consumer execution reports
    0 passed / 1 ignored under the `.3.5` owner. Full `linkedspec-core` passes 197 unit + 4 descriptor + 5
    normalization + 8 types + 5 Unicode; Rust duplicate-slot passes 1/1 in 17.52 seconds and Unicode routes pass
    3/3. The final 105-source generated manifest passes after its `/=/ /next/` compatibility RED was root-caused
    and guarded; rule-local cursor is 6/6 and source emitter 6/6. The neutral checker passes exact 2/7/56 plus ten
    Rust dormancy mutations; recognition remains 137/246/58, typed source 9/5/114, duplicate slot 7/0/59, and the
    17-owner Rust storage/relocation oracle passes. Rendered book is 79 files / 14,704 KiB and Knowledge is 835
    facts / 7,013 keys. All eight doctrines and canonical containment/relocation pass with CLI 66/66 twice, RAM
    55%, Phase 0 1,031/1,031, exact neutral-plus-Perl routing with five skips, and local-CI exit 0.
  Commit: `INTER-MATCH-GAP-CAPTURE.3.1 - add Rust authored gap metadata`

  ### 2026-08-14 Dormant-consumer governance resolution

  - This leaf simultaneously requires the exact final consumer at
    `rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs` and forbids changing the neutral checker.
    The unchanged checker rejects that exact filesystem fact while `rust_runtime` is pending, so its focused route
    exits 1 with `pending runtime consumer exists before admission: rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs`.
  - Atomic 223 (`912fc5ed`, Perl `.2.1`) resolved the identical staging condition by extending the checker with ten
    reason-checked dormant-consumer mutations plus canonical/recurring/facade absence locks, without changing the
    neutral JSON counts or rollout. Rust `.3.1` did not assign equivalent checker ownership, and moving the test to
    another path would violate its final-path acceptance instead.
  - The director authorized the precedent-matching Rust dormancy checker and ten local mutations in `.3.1`, while
    preserving neutral JSON semantics/counts, rollout 2/7/56, and canonical/recurring/facade absence. This amended
    ownership precedes every checker edit and resolves the final-path contradiction without admission.
  - Route audit found that absence of an explicit `--test inter_match_gap_capture_contract` command is not alone
    sufficient: the optional canonical Rust package gate executes every runtime integration test. `.3.1` therefore
    owns an explicit ignored-until-`.3.5` test attribute plus a reason-checked dormancy mutation for that lock.
    Focused metadata proof uses `--ignored --exact`; ordinary package/canonical execution must report the staged
    test ignored, while recurring and public-facade routes remain absent.

- ID: `INTER-MATCH-GAP-CAPTURE.3.2`
  Status: `done; signoff-complete` (2026-08-14; task-tree-first from clean atomic-228 commit `95127e1d`; intended atomic 229/300;
    native invocation-local behavior only; no generated/emitted/primary execution or rollout admission)
  Goal: Add Rust invocation-local gap state, lifecycle, transaction/recursion, and private accessor behavior.
  Depends on: `.3.1`, the neutral gap state machine, admitted Perl live behavior, Rust recognition-transaction
    authority, typed source authority, repeated-action selection, and rule-local cursor semantics.
  Acceptance: prove clean activation and retrieve the exact frozen plan plus neutral/Perl/recognition/source
    authorities before code; add the three mutable gap members to the existing private recognition-frame
    checkpoint snapshot without widening public `state_record()`; retain source/invocation and detached entry-slot
    identity on the same invocation stack; add private zero-argument `entry_slot`/`gap_span`/`gap_text`/`gap_kind`
    evaluation with the exact typed unavailable-context diagnostic; for capture-enabled native rules select and
    install decoded-scalar candidates before `LS`, preserve them through target/action/`LE`, commit after `LE`
    before `IT`, and expose successful tails before `LX`/`EX`/`E`; preserve unflagged order and all legacy behavior;
    prove prefix/interstitial/empty/Unicode/tail, child cursor extension, falsey return, lifecycle, recursion,
    rollback, direct-entry, detached-slot, and unavailable-context cases through the ignored final consumer;
    change no descriptor, generated-plan executor, emitted source, primary route, rollout 2/7/56, recurring/public
    admission, facade/schema/MCP/CLI/README surface, or later runtime; synchronize durable projections and pass
    focused Rust/neutral/recognition/typed-source/storage/book/Knowledge/doctrine/canonical signoff.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Proved committed `95127e1d`, empty staged/unstaged/untracked status,
    zero-byte brief, valid post-commit memory pointer, and passing memory architecture before this task-only edit.
  - [x] **RETRIEVE AUTHORITY** — Queried the Knowledge Map first and read the frozen Rust plan, neutral contract,
    admitted Perl live runtime, existing Rust recognition/source/runtime owners, and final consumer before code.
  - [x] **EXACT RED** — Extend only the ignored final consumer with native cases and record the expected missing
    gap-state/accessor behavior against clean atomic 228.
  - [x] **NATIVE STATE / LIFECYCLE GREEN** — Implement exact frame/snapshot, candidate/commit/tail, detached slot,
    typed accessor, Unicode, recursion, and rollback behavior on the single existing authority.
  - [x] **COMPATIBILITY / NO OVERCLAIM** — Preserve unflagged behavior and every generated/emitted/primary/public
    boundary while rollout remains 2/7/56 and the final consumer remains ordinarily ignored until `.3.5`.
  - [x] **LOCKSTEP SIGNOFF** — Align task/roadmap/live/book/Knowledge projections and pass focused, rendered-book,
    Knowledge, doctrine, and canonical proof before atomic landing.
  Verification: Exact RED failed 1/1 in 1.68 seconds on unknown `gap_kind`/`gap_text` and null prefix/tail values.
    Focused GREEN passes 1/1 in 3.75 seconds only with `--ignored --exact`; ordinary discovery remains 0 passed /
    1 ignored. Private gap units pass 3/3; runtime units pass 170/170; recognition 12/12, recursive observation
    7/7, rule-local cursor 6+3, and duplicate slot 1/1 remain green. Neutral and rooted proof remain exact at
    2/7/56 plus ten Rust dormancy mutations, Perl 124, and five later-runtime skips. Rendered-book, Knowledge,
    doctrine, storage, and canonical results are recorded in the verification log below.
  Commit: `INTER-MATCH-GAP-CAPTURE.3.2 - add Rust native gap execution` (intended atomic 229/300)

  ### 2026-08-14 Engineering-notes rollover capacity resolution

  - The mandatory commit-workflow check found `DEVELOPMENT_NOTES.md` at 472/512 lines, above its 90% action
    threshold. The repository rollover published immutable content-addressed segment 4996 and retained the current
    root at 250/512 lines after the required `.3.2` engineering note is present.
  - That exact resulting tree has twelve controlled files and an eleven-line manifest, exceeding only the prior
    finite 11-file / 10-manifest-line pressure controls. ADR `0071` authorizes those two one-step increases under
    this already-active documentation-sync owner; every byte/root/history-member/aggregate limit plus lifecycle,
    verifier, storage authority, and route shape remains unchanged.
  - This is required continuity governance inside `.3.2`, not a pivot to another task tree and not an exemption
    from future review. The next count increase again requires a new staged, indexed, exact old/new ADR.

- ID: `INTER-MATCH-GAP-CAPTURE.3.3`
  Status: `done; signoff-complete` (2026-08-14; task-tree-first from clean atomic-229 commit `5c4e9d50`;
    intended atomic 230/300; reconstruction/descriptor/generated-plan behavior only; no emitted/primary execution
    or rollout admission)
  Goal: Carry exact Rust gap metadata and execution through ordinary serialization, reconstruction, descriptors,
    and the governed generated-plan carrier.
  Depends on: `.3.2`, compiled slot/directive/selector provenance from `.3.1`, the existing serde-compatible
    `CompiledSpec`, descriptor-state authority, generated plan v2, native gap lifecycle, and source/recognition
    authorities.
  Acceptance: prove clean activation and retrieve the exact Rust plan plus compiled/descriptor/generated/runtime
    authorities before code; extend only the ignored final consumer to produce deliberate RED for ordinary
    reconstruction, descriptor projection, and generated-plan execution; prove serialized `CompiledSpec`
    reconstruction retains exact authored slot order, nullable stable ids, directive/source/line evidence, and
    five-field selector provenance, then executes the already-current native behavior without a second carrier;
    project those same fields through the existing descriptor-state model with detached values and no runtime
    object leakage; apply candidate-before-`LS`, commit-after-`LE`, tail-before-terminal, entry-slot, rollback,
    recursion, Unicode-scalar source, falsey-return, and typed-diagnostic behavior to the separate
    `GeneratedPlanExecutor`; preserve generated plan v2 exactly `{label,family}`, all unflagged behavior, and the
    one recognition/source authority; change no source emitter, independently compiled artifact, primary route,
    ordinary/canonical/recurring consumer registration, rollout 2/7/56, facade/schema/semantic/MCP/CLI/README
    surface, or later runtime; synchronize durable projections and pass focused Rust/neutral/recognition/source/
    storage/book/Knowledge/doctrine/canonical signoff before atomic landing.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Proved committed `5c4e9d50`, empty tracked/untracked status, zero-byte
    brief, and passing post-commit activation pointer before this task-only edit.
  - [x] **RETRIEVE AUTHORITY** — Queried Knowledge first and read the exact descriptor, serde reconstruction,
    generated-plan, native lifecycle, source, recognition, consumer, and no-overclaim owners before code. The
    established compatible projection is separate `regex_slots`, `capture_gaps`, and five-field
    `resolved_slot_edges` metadata; legacy `resolved_edges`/`dependency_refs` stay narrow, generated plan v2 stays
    label/family-only, and serialized `CompiledSpec` remains the single carrier.
  - [x] **EXACT RED** — Extended only the ignored final consumer with reconstructed/descriptor/generated-plan
    roles against clean atomic 229. Ordinary reconstructed execution already passed; the combined carrier
    assertion then observed `null` for all three descriptor fields and
    `LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable` from generated-plan execution exactly as
    expected (1 failed / 0 passed in 1.21 seconds; 345.85 seconds wall including the one-time dependency rebuild).
  - [x] **CARRIER / EXECUTION GREEN** — Preserved compiled metadata through ordinary reconstruction, projected
    separate slot/directive/five-field selector metadata without widening legacy edges/references, and joined the
    separate generated-plan loop to the same frame, entry-slot, and lifecycle authority.
  - [x] **COMPATIBILITY / NO OVERCLAIM** — Generated plan v2 remains exact `{label,family}` with no emitter change;
    unflagged source-emitter/cursor/runtime suites pass, the consumer remains 0/1 ignored ordinarily, and neutral/
    rooted governance remains 2/7/56 plus ten Rust dormancy mutations, Perl 124, and five skips.
  - [x] **LOCKSTEP SIGNOFF** — Align task/roadmap/live/book/Knowledge projections and pass focused, rendered-book,
    Knowledge, doctrine, storage, and canonical proof before atomic landing.
  Verification: Exact combined RED failed 1/1 after 1.21 seconds of test execution: reconstructed native behavior
    was already green, all three descriptor projections were null, and generated-plan access returned exact typed
    unavailable context. Focused GREEN passes 1/1 in 5.96 seconds only with `--ignored --exact`; ordinary discovery
    remains 0 passed / 1 ignored. Descriptor 4/4, runtime units 170/170, recognition 12/12, recursive observation
    7/7, cursor 6/6, source emitter 6/6, and duplicate slot 1/1 pass. Neutral/rooted proof remains 2/7/56 plus ten
    Rust dormancy mutations, Perl 124, and five later-runtime skips; the 17-owner Rust storage oracle passes.
    Rendered-book, Knowledge, doctrine, and canonical results are recorded in the verification log below.
  Commit: `INTER-MATCH-GAP-CAPTURE.3.3 - carry Rust gap generated execution` (intended atomic 230/300)

- ID: `INTER-MATCH-GAP-CAPTURE.3.4`
  Status: `done; signoff-complete` (2026-08-14; task-tree-first from clean atomic-230 commit `9e6ade98`;
    intended atomic 231/300; independently compiled emitted-source proof only; no primary execution or rollout
    admission)
  Goal: Prove independently compiled emitted Rust execution parity for values, lifecycle, diagnostics, rollback,
    recursion, and legacy compatibility.
  Depends on: `.3.3`, serialized `CompiledSpec` as the single generated carrier, generated-source v2, the existing
    Rust source emitter, repository-derived project-data scratch/target routing, and the final ignored consumer.
  Acceptance: prove clean activation and retrieve the exact emitted-source, generated-runtime, storage, and
    final-consumer authorities before code; extend only the ignored final consumer to produce deliberate RED for
    independently compiled emitted direct/traced gap execution; emit source through the existing v2
    `{label,family}` plan plus serialized compiled payload, compile it offline in a repository-derived managed
    scratch/target workspace, and execute exact values, lifecycle, detached entry-slot, Unicode/empty spans,
    falsey results, child cursor extension, nested isolation, rollback, terminal tails, typed diagnostics, failed
    minimums, direct entry, and unflagged legacy controls; prove direct/traced emitted results agree with the
    already-current native/reconstructed/generated-plan authority; change no source-emitter schema unless exact
    RED proves a carrier defect, no primary route, ordinary/canonical/recurring registration, rollout 2/7/56,
    facade/schema/semantic/MCP/CLI/README surface, or later runtime; preserve repository-root-relative durable
    paths and same-volume storage; synchronize durable projections and pass focused Rust/neutral/source/storage/
    book/Knowledge/doctrine/canonical signoff before atomic landing.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Proved committed `9e6ade98`, empty tracked/untracked status, zero-byte
    brief, and passing post-commit activation pointer before this task-only edit.
  - [x] **RETRIEVE AUTHORITY** — Queried Knowledge first, then read the exact v2 emitter/API, independently
    compiled transaction/recursive-observation precedents, repository-derived test-workspace/storage rules,
    generated trace roles, final ignored consumer, and `.3.5` no-overclaim boundary before code.
  - [x] **EXACT RED** — Extended only the ignored final consumer against clean atomic 230. The focused compile
    failed exactly at the absent `independently_compiled_emitted_gap_contract` owner (`E0425`, exit 101), after
    which only that consumer gained the emitted direct/traced proof.
  - [x] **EMITTED GREEN** — One managed offline crate compiles fifteen isolated emitted modules: thirteen value
    cases and two typed-error cases pass paired direct/traced execution across the complete owned behavior set.
  - [x] **COMPATIBILITY / NO OVERCLAIM** — Generated plan v2 and the source emitter are byte-unchanged; ordinary
    discovery is 0/1 ignored, the rooted route is neutral + Perl 124 + five skips, rollout stays 2/7/56 plus ten
    Rust dormancy mutations, and `.3.5` retains primary/canonical/recurring admission.
  - [x] **LOCKSTEP SIGNOFF** — Align task/roadmap/live/book/Knowledge projections and pass focused, rendered-book,
    Knowledge, doctrine, storage, and canonical proof before atomic landing.
  Verification: Exact RED is Rust `E0425` at the absent emitted-proof owner / exit 101. Focused GREEN passes 1/1
    in 32.82 seconds, including fifteen independently emitted modules and paired direct/traced execution. Ordinary
    discovery remains 0 passed / 1 ignored. Runtime units pass 170/170; recognition 12/12, recursive observation
    7/7, cursor 1/1, duplicate slot 1/1, and source emitter 6/6 pass. Neutral/rooted proof remains 2/7/56 plus ten
    Rust dormancy mutations, Perl 124, and five later-runtime skips. The Rust project-data oracle passes all 17
    owners plus Cargo cache, generated-workspace, trace, and relocation locality. Rendered book is 79 files /
    14,724 KiB and Knowledge is synchronized at 835 facts / 7,019 keys. All eight doctrines pass. The sandboxed
    canonical run stopped only where the outer harness denied nested `sandbox-exec` with status 71; the unchanged
    authorized run passes six-family containment, all-five-anchor relocation, CLI 66/66 twice, RAM 60%, Phase 0
    1,031/1,031 in 780 seconds, the exact neutral-plus-Perl route with five skips, `[ci] local CI gate passed`, and
    exit 0.
  Commit: `INTER-MATCH-GAP-CAPTURE.3.4 - prove Rust emitted gap execution` (intended atomic 231/300)

  ### 2026-08-14 Change-history rollover capacity resolution

  - The mandatory commit-workflow check found `CHANGES.md` above its 90% action threshold. The repository rollover
    published immutable, content-addressed segment 4996 and retained the current root at 238/512 lines.
  - That exact resulting tree has seventeen controlled files, exceeding only the prior finite 16-file collection
    limit. ADR `0072` authorizes the one-step increase to 17 while every root, manifest, byte, per-history-file,
    aggregate, lifecycle, verifier, owner, and storage control remains unchanged.
  - This continuity work remains inside `.3.4`, not a task-tree pivot or a growth exemption. The next collection
    member increase again requires a new staged/indexed exact-limit ADR and an independent manifest-limit review.

- ID: `INTER-MATCH-GAP-CAPTURE.3.5`
  Status: `done; signoff-complete` (2026-08-15; task-tree-first from clean atomic-231 commit `c3326f6d`; intended
    atomic 232/300; exact private Rust primary/admission and parent `.3` closeout only)
  Goal: Compose exact Rust primary/admission, mutation/rollout updates, recurring routing, ledgers, and unchanged
    public no-overclaim, then close parent `.3` cleanly for Dart `.4`.
  Acceptance: prove clean activation and retrieve the exact final consumer, primary adapter, contract/checker,
    canonical CI, recurring driver, storage, role-ledger, rollout/mutation, and public-no-overclaim authorities
    before code; produce deliberate RED for the absent ninth primary-command role and for the dormant admission
    topology; extend only the final Rust consumer with primary-command parity, make its one complete test ordinary,
    register it exactly once in canonical CI and exactly once after Perl in the rooted route, and prove all nine
    contract roles execute once; promote only `rust_runtime` so rollout becomes 3 complete / 6 pending, replace
    `rust_runtime_premature` with `rust_runtime_regression` while retaining 56 semantic mutations, and replace the
    ten Rust dormancy mutations with reason-checked admission/regression mutations; leave Dart, Julia, both Lua
    ABI rows, recurring, and public-no-drift pending; keep generated plan v2, runtime facade, capability, typed
    `lossless_gap_composition`, semantic/MCP schemas, CLI surface, README, and every outward token unchanged;
    synchronize ledgers, live docs, Knowledge, and mdBook; pass focused/ordinary/rooted/storage/book/Knowledge/
    doctrine/canonical signoff; close parent `.3`, then land/clear/clean before activating Dart `.4`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Proved committed `c3326f6d`, empty tracked/untracked status, zero-byte
    brief, and passing post-commit activation pointer before this task-tree-first edit.
  - [x] **RETRIEVE AUTHORITY / EXACT RED** — Query Knowledge first; read final consumer, primary adapter, checker,
    contract, canonical/recurring/storage routes, role and outward ledgers; prove exact primary/admission absence.
    Primary RED is exact Rust `E0425` for absent `primary_command_gap_contract`; admission RED is exact
    `rust_runtime rollout drifted` against the pre-promotion checker.
  - [x] **NINE-ROLE PRIMARY GREEN** — Add primary-command parity and an exact once-only nine-role composition to
    the final consumer without changing the primary adapter, emitter, generated plan, or runtime facade.
    The existing primary adapter returns four exact item/gap pairs from heterogeneous separators, and the ledger
    validates declared role identity/order plus exactly-once completion.
  - [x] **PRIVATE RUST ADMISSION** — Remove the final consumer's ignore boundary and register it once canonically
    plus once after Perl in the rooted route; later runtime skips remain ordered and exact.
  - [x] **ROLLOUT / MUTATION / NO OVERCLAIM** — Advance only Rust to 3/6/56, replace premature/dormancy locks with
    admitted regression locks, and preserve all recurring/public/capability/typed/schema/CLI/README boundaries.
  - [x] **PARENT CLOSEOUT / LOCKSTEP SIGNOFF** — Close `.3`, align task/roadmap/live/book/Knowledge projections,
    and pass focused, ordinary, rooted, storage, rendered-book, doctrine, and canonical proof before landing.
  Verification: Primary RED exits 101 at exact absent owner; pre-admission focused GREEN passes 1/1; admission RED
    rejects the pending Rust row; ordinary admitted GREEN passes 1/1 with zero ignored tests. The neutral checker
    passes exact 3/6/56 plus ten Rust admission mutations; the rooted route passes neutral, Perl 124, Rust 1/1,
    and four later-runtime skips. Runtime 170/170, recognition 12/12, recursive observation 7/7, cursor,
    duplicate-slot, source-emitter, recognition 137/246/58, and typed-source 9/5/114 compatibility checks pass.
    The 17-owner Rust storage oracle, rendered book 79/14,732 KiB, Knowledge 835/7,020, and all eight doctrines
    pass. The sandboxed canonical run stops only at expected nested-`sandbox-exec` status 71; the unchanged
    authorized run passes containment/relocation, CLI 66/66 twice, RAM 73%, Phase 0 1,031/1,031, exact rooted
    neutral/Perl/Rust routing, `[ci] local CI gate passed`, and exit 0.
  Commit: `INTER-MATCH-GAP-CAPTURE.3.5 - admit Rust inter-match gap capture` (intended atomic 232/300)

- ID: `INTER-MATCH-GAP-CAPTURE.4`
  Status: `active` (2026-08-15; behavior-free implementation/admission plan `.4.0` landed cleanly as atomic 233
    at `e40de948`; authored/static/compiled metadata `.4.1` landed cleanly as atomic 234 at `1e6d326d`; private
    native runtime leaf `.4.2` is active from clean workflow-policy atomic 235 at `c234ef9f`)
  Goal: Implement exact Dart native/reconstructed/generated/primary parity.
  Children: `.4.0`, `.4.1`, `.4.2`, `.4.3`, `.4.4`, `.4.5`
  Acceptance: Dart passes the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.4.0`
  Status: `done; signoff-complete` (2026-08-15; task-tree-first from clean atomic-232 commit `2800e7c3`; intended
    atomic 233/300; behavior-free Dart implementation/admission plan only)
  Goal: Reverify the committed Dart parser/compiler/runtime/carrier/emitter/primary seams and freeze an exact,
    dependency-complete implementation/admission plan before changing Dart behavior.
  Depends on: `.3`, the neutral gap contract, complete Dart duplicate-slot identity, rule-local cursor, typed
    source, recognition transaction, generated-source, primary-CLI, and emitted-source authorities.
  Acceptance: prove clean activation and retrieve canonical Knowledge/ADR/task/contract authorities first; use
    LinkedSpec's contract and Dart source/runtime probes before inference; locate exact named declaration/selector,
    directive, source-AST, validation, compiled metadata, selected-slot identity, invocation state, matcher/action/
    lifecycle, transaction/recursion, accessor, diagnostic, serialization/reconstruction, descriptor,
    generated-plan, emitted-source, primary-command, recurring-driver, storage, and public-no-overclaim seams;
    reproduce current Dart absence or drift against admitted Perl/Rust and neutral behavior; specify exact RED/
    GREEN fixtures, role boundaries, mutation/rollout increments, canonical/storage routes, and non-overlapping
    `.4.1+` ownership; change no Dart parser/compiler/runtime/carrier/emitter/CLI behavior, gap rollout, public
    facade/schema/MCP, capability, typed-source composition, README, or generated format in this leaf; synchronize
    durable projections; pass focused/book/Knowledge/doctrine/canonical signoff; commit/clear/clean before `.4.1`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove atomic 232 at `2800e7c3`, empty staged/unstaged/untracked status,
    zero-byte brief, absent rendered-book residue, and no owned background result before this task-tree-only edit.
  - [x] **RETRIEVE AUTHORITY** — Query the Knowledge Map first, then read the exact gap, Dart selector/cursor/
    transaction/source/generated/primary, storage, path, and public-no-overclaim owners before re-derivation.
  - [x] **TOOLBOX-LED DART AUDIT** — Reproduce current authored/runtime/carrier/primary absence or drift through
    exact contract, source, descriptor, generated, emitted, and primary probes; record mechanisms and locations.
  - [x] **FREEZE IMPLEMENTATION PLAN** — Assign dependency-ordered `.4.1+` leaves with exact RED/GREEN, carrier,
    lifecycle, transaction, diagnostics, primary, admission, mutation, storage, and no-overclaim obligations.
  - [x] **NO BEHAVIOR / LOCKSTEP SIGNOFF** — Move no code, rollout, generated format, or outward surface; align
    task/ADR/Knowledge/roadmaps/live/mdBook and pass focused/book/doctrine/canonical proof before landing.

  ### Verified Dart Baseline

  - The neutral checker passes exact 3 complete + 6 pending / 56 semantic mutations plus ten Rust admission
    mutations. The rooted route executes neutral, Perl 124, and Rust 1/1, then skips Dart, Julia, PUC Lua, and
    LuaJIT. The final Dart consumer path declared by the neutral contract does not yet exist.
  - A repository-routed Dart probe proves numeric/unindexed declarations and selectors still parse and compile.
    `word=/[a-z]+/`, `-> Item[word]`, and `@capture_gaps` become raw body syntax and fail validation. The four
    accessor spellings parse as ordinary calls and produce exact `unknown_helper` contract diagnostics.
  - `dart/lib/src/ast/spec_ast.dart` represents a regex body element with only `pattern`, an action-edge target
    with only `label/index`, and no directive record. `dart/lib/src/parser/spec_parser.dart` recognizes only
    anonymous slash regexes, the four legacy split-marker forms, and digit-only `_parseIndexAt` selectors.
  - `dart/lib/src/validation/spec_validator.dart` and `dart/lib/src/compiler/compiled_spec.dart` consequently
    validate/count only anonymous regex elements, reduce them to `regexPatterns`, resolve action edges by numeric
    index, and discard split markers. They retain no named slot, authored selector, directive, source identity, or
    five-field resolved-edge provenance.
  - `LinkedSpecRuntimeEngine._executeRegexRule` currently executes `LS` before `_executeRegexOnce` for repeated
    rules. `_executeRegexOnce` selects and records a slot, `_acceptRegexMatch` installs registers/cursor and
    dispatches the edge/child, then `LE` runs; the outer loop runs `IT`. Only capture-enabled rules may select and
    install a candidate before `LS`; every unflagged rule must retain this current order.
  - `dart/lib/src/runtime/recognition_transaction.dart` is the sole private invocation/token authority.
    `_InvocationState` already carries source/rule/invocation lineage and owns one `RecognitionFrameState`; token
    rollback restores its snapshot. Gap state must join that private authority without widening the existing
    cursor/boundary/marks `RecognitionFrameState`, its detached observation, or the public facade.
  - `_RuntimeExecutionContext` already creates immutable `SourceAuthority(sources: {'input': input})` and uses
    Unicode-scalar projection for public positions. Gap spans use that authority and source id `input`; static
    declaration/directive diagnostics require a new backward-compatible spec source identity threaded through
    `parseSpec`, staged parsing, loaded-spec parsing, `SpecFile` JSON, validation, and compilation.
  - `dart/lib/src/source_emitter.dart` already embeds normalized `SpecFile` JSON, recompiles it, and runs the same
    engine. Its v2 static plan remains `{label,family}`. `dart/lib/src/cli/primary_cli.dart` already delegates both
    loaded and inline specs through the normal parse/compile/engine pipeline; no option or secondary command path
    is needed.
  - Exact lifecycle trace projection is `lifecycle_block`, `regex_match`, `lifecycle_block`, `regex_match`, proving
    current `LS` precedes first selection. A valid existing primary fixture returns `"trace"` with exit 0; the
    planned complete source fails at parser compilation, isolating absence to the unimplemented authored surface.
  - Focused parser/validator/compiler/matcher/interpreter/transaction/emitter/primary proof passes 123 tests.
    Complete Dart proof passes format 101 files / 0 changed, strict analysis, 400 package tests, storage 22 exact
    `Directory.systemTemp` owners / 47 packages, CLI 66/66 in both option environments, and corpus 105/105. The
    22nd storage owner is the already-admitted semantic-introspection emitted workspace; its stale 21-owner
    Knowledge projection is corrected in this behavior-free leaf.

  ### Frozen `.4.1-.4.5` Dependency Plan

  - `.4.1` owns `dart/lib/src/ast/spec_ast.dart`, `parser/spec_parser.dart`, staged-parser source-identity
    propagation, `validation/spec_validator.dart`, `compiler/compiled_spec.dart`, focused tests, and dormant
    `dart/test/inter_match_gap_capture_contract_test.dart` staging. Add one authored slot sequence shared by named
    and anonymous declarations, an unindexed/numeric/named selector record, directive provenance, logical source
    identity with backward-compatible JSON defaults, exact static diagnostics/eligibility, compiled slot rows,
    and five-field resolved edges. Reuse the pinned Unicode-17 rule-label scanner for slot identity and reject
    ASCII-digit-only names. The final consumer carries a library-level
    `@Skip('INTER-MATCH-GAP-CAPTURE.4.5')` that the checker mutation-locks until admission; no live state or
    rollout moves.
  - `.4.2` owns private runtime execution in `dart/lib/src/runtime/recognition_transaction.dart`,
    `runtime/source_location.dart`, `runtime/interpreter.dart`, and the staged consumer. Extend `_InvocationState`
    with activation, detached entry slot, immutable source/invocation identity, and only the three mutable gap
    members `committed_gap_cursor`, `accepted_edge_count`, and `current_gap`; extend the existing token's private
    snapshot for those members without changing `RecognitionFrameState`. Implement private zero-argument
    `entry_slot`/`gap_*` dispatch and exact typed unavailable-context/cursor-regression diagnostics. Capture-enabled
    selection installs a Unicode-scalar candidate before `LS`, commits the post-`LE` cursor before `IT`, exposes
    successful tails before `LX`/`EX`/`E`, and preserves falsey acceptance, whole-rule returns, rollback, and nested
    isolation. Unflagged ordering remains unchanged.
  - `.4.3` owns ordinary `SpecFile` JSON reconstruction, compatible descriptor projection, and generated-plan
    execution proof in the staged consumer. The serialized normalized spec remains the only carrier; descriptors
    add separate `regex_slots`, `capture_gaps`, and `resolved_slot_edges` fields without changing existing
    `resolved_edges`; generated execution uses the same engine/runtime state and the v2 static plan remains exact
    `{label,family}`.
  - `.4.4` owns independently analyzed and executed emitted-Dart proof via `emitDartSourceV2`. Create one
    repository-routed generated caller workspace with its own project-local `PUB_CACHE`; add that exact
    `Directory.systemTemp` owner to `tools/test_dart_project_data_storage.sh`. Direct/traced emitted roles cover
    mixed separators, Unicode/empty spans, falsey values, lifecycle, child cursors, nesting, rollback, tails,
    minimum failure, direct entry, legacy behavior, and typed errors. Generated-source v2 and the production
    emitter contract remain unchanged.
  - `.4.5` owns the real primary-command role, exact nine-role once-only composition, ordinary/canonical
    registration, rooted-driver activation, contract/checker admission delta, live ledgers/docs, and parent `.4`
    closeout. Promote only `dart_runtime`: rollout becomes 4 complete + 5 pending; the route executes neutral,
    Perl, Rust, and Dart before Julia/PUC Lua/LuaJIT skips. Replace `dart_runtime_premature` with
    `dart_runtime_regression` while retaining 56 semantic mutations, and add ten reason-checked Dart admission
    mutations. Recurring/public rows, typed `gap_composition`, capability status, facades, schemas, semantic/MCP,
    CLI shape, README, and later runtimes remain pending or unchanged.

  ### Role and Verification Boundaries

  - The final Dart consumer implements the contract roles in exact order: `native_execution`,
    `ordinary_reconstruction`, `descriptor`, `generated_plan`, `emitted_source`, `target_lifecycle`,
    `recursion_and_rollback`, `portable_diagnostics`, and `primary_command`. Earlier leaves stage only their owned
    subset; `.4.5` requires every declared role exactly once and removes dormancy.
  - Focused work uses only `bash tools/run_dart_project_data.sh ...`, the neutral checker, rooted gap route,
    recognition 137/246/58, typed source 9/5/114, duplicate-slot 7/0/59, complete Dart/storage proof, rendered
    mdBook, Knowledge regeneration, all doctrines, and canonical local CI. Every emitted workspace, package cache,
    generated output, and trace stays beneath repository-derived `.linkedspec-data` storage.
  Verification: Exact gap 3/6/56 plus ten Rust admission mutations and rooted neutral/Perl-124/Rust-1/four-skip
    route pass. Focused Dart proof is 123/123; complete Dart proof passes format 101/0, strict analysis, 400/400,
    storage 22/47, CLI 66x2, corpus 105/105, and its exact success marker. Rendered-book, Knowledge, doctrine, and
    canonical signoff are recorded in the verification log below. No Dart implementation source, contract,
    checker, driver, rollout, generated format, or outward surface moves.
  Commit: `INTER-MATCH-GAP-CAPTURE.4.0 - freeze Dart gap implementation plan` (intended atomic 233/300)

- ID: `INTER-MATCH-GAP-CAPTURE.4.1`
  Status: `done; signoff-complete` (2026-08-15; task-tree-first from clean atomic-233 commit `e40de948`; no
    implementation edit preceded this activation)
  Goal: Add exact Dart authored/static/compiled gap metadata and a mechanically dormant final consumer.
  Depends on: `.4.0`
  Acceptance: prove clean activation and retrieve the frozen Dart plan plus exact neutral/Perl/Rust/Unicode/
    duplicate-slot/source-identity authorities before code; add spacing-insensitive named declarations, one
    authored named/anonymous slot sequence, explicit unindexed/numeric/named selectors, dedicated directive
    evidence, backward-compatible logical spec-source identity, source-aware static diagnostics, compiled slot
    rows, capture eligibility, and five-field resolved-edge provenance; add the final Dart consumer at its exact
    contract path with a library-level `.4.5` skip and reason-checked dormancy governance; prove checker-first RED
    before implementation and focused GREEN afterward; change no private live gap state/accessor/lifecycle,
    reconstructed descriptor/generated-plan behavior, emitted/primary route, rollout 3/6/56, generated-plan v2,
    facade/schema/semantic/MCP/CLI/README/public surface, or later runtime; synchronize durable projections and
    pass focused Dart/neutral/recognition/typed-source/duplicate-slot/storage/book/Knowledge/doctrine/canonical
    signoff before commit/brief-clear/clean handoff to `.4.2`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Proved committed `e40de948`, empty tracked/untracked status, zero-byte
    brief, passing memory architecture/task metadata, and activated only this task node before implementation.
  - [x] **RETRIEVE AUTHORITY** — Query Knowledge first and read the Dart plan, neutral artifact/checker, admitted
    Perl/Rust metadata precedents, pinned Unicode-17 identity, duplicate-slot, source-identity, and exact current
    Dart tests before implementation.
  - [x] **EXACT RED** — Add the final-path library-skipped consumer and dormancy governance first; prove only the
    expected absent named-slot/directive/provenance assertions fail when the owned group is run explicitly.
  - [x] **AUTHORED / STATIC / COMPILED GREEN** — Implement exact syntax, identity, validation, metadata, source
    defaults, and five-field provenance through one typed Dart AST/compiler path.
  - [x] **COMPATIBILITY / NO OVERCLAIM** — Preserve anonymous/numeric/unindexed behavior, normalized JSON
    compatibility, generated plan v2, ordinary skipped discovery, every outward surface, and rollout 3/6/56.
  - [x] **LOCKSTEP SIGNOFF** — Align task/roadmap/live/book/Knowledge projections and pass focused, complete Dart,
    storage, rendered-book, Knowledge, doctrine, and canonical proof before atomic landing.

  ### Implemented Metadata Boundary

  - Checker-first staging created the exact final consumer with a library-level `.4.5` skip and ten independently
    reason-checked Dart dormancy mutations. Explicit RED failed only on absent `parseSpec(sourceId:)` and
    `SpecFile.sourceId`; the neutral checker otherwise remained 3/6/56 plus ten Rust admission mutations.
  - `RegexBodyElementKind` now carries nullable `slotId`; `EdgeTarget` carries exact selector authorship; and a
    dedicated directive kind preserves `@capture_gaps`. Named/anonymous declarations share authored order and
    reuse the generated pinned Unicode-17 scanner, with ASCII-digit-only names reserved/rejected.
  - `SpecFile.sourceId` defaults to `inline` and survives ordinary parsing, both staged layers, logical loaded
    requests, JSON, validation, and compilation. Static diagnostics carry exact source/line and contract context.
  - Compiled rules carry ordered slot rows plus nullable directive metadata; action edges carry source identity
    and five-field resolved provenance. Legacy dependency refs and descriptor action/resolved-edge projections
    remain unchanged; generated-plan v2 remains `{label,family}`.
  - Explicit dormant proof passes 1/1; strict Dart analysis and ordinary package discovery pass 400 plus the one
    intended skip. Native state/accessors, reconstructed/generated/descriptor execution, emitted/primary routes,
    rollout, facade, README, and later backends did not move.
  Verification: Checker-first RED isolated the absent `parseSpec(sourceId:)`/`SpecFile.sourceId` carrier; the
    final dormant consumer then passes 1/1. Complete Dart proof passes format 102/0, strict analysis, package 400
    plus one intended skip, storage 22 owners / 47 packages, CLI 66/66 twice, corpus 105/105, and its local-gate
    marker. Neutral governance passes 3/6/56 plus ten Rust admission and ten Dart dormancy mutations;
    recognition remains 137/246/58, typed source 9/5/114, and duplicate-slot 7/0/59. The book renders 79 files /
    14,788 KiB; Knowledge is 836 facts / 7,039 keys; all eight doctrines pass. The sandboxed canonical precursor
    stops solely at outer nested-`sandbox-exec` status 71; the unchanged authorized run passes six-family
    containment, all-five-anchor relocation, CLI 66/66 twice, RAM 56%, Phase 0 1,031/1,031 in 745 seconds, the
    rooted neutral/Perl-124/Rust-1/four-skip route, `[ci] local CI gate passed`, and exit 0.
  Commit: `INTER-MATCH-GAP-CAPTURE.4.1 - add Dart authored gap metadata` (intended atomic 234/300)

- ID: `INTER-MATCH-GAP-CAPTURE.4.2`
  Status: `signoff-complete` (2026-08-15; task-tree-first from clean atomic-235 workflow-policy commit
    `c234ef9f`; intended atomic 236/300; no implementation or test edit preceded activation; no push)
  Goal: Add exact private native Dart gap state, lifecycle, accessors, entry identity, rollback, and recursion.
  Depends on: `.4.1`
  Acceptance: prove clean activation and retrieve the frozen Dart plan plus the exact Dart recognition-token,
    source-authority, interpreter lifecycle, admitted Perl/Rust native behavior, and staged final-consumer
    authorities before code; extend only the staged consumer's native role to produce deliberate RED for absent
    private gap state/accessors; add activation, detached entry identity, immutable source/invocation identity,
    and exactly three mutable gap members to `_InvocationState`; extend the existing token's private snapshot
    without widening `RecognitionFrameState`; implement private zero-argument `entry_slot`, `gap_span`,
    `gap_text`, and `gap_kind` dispatch plus exact typed unavailable-context and cursor-regression diagnostics;
    install capture-enabled Unicode-scalar candidates before `LS`, commit the post-`LE` cursor before `IT`, and
    expose successful tails before `LX`/`EX`/`E`; preserve falsey accepted values, whole-rule returns, rollback,
    recursion, direct entry, nested isolation, and every unflagged lifecycle order; change no reconstruction,
    descriptor, generated-plan, emitted-source, primary/admission route, rollout 3/6/56, facade/schema/semantic/
    MCP/CLI/README surface, generated format, dependency, toolchain, CI, hook, storage, doctrine, or later runtime;
    synchronize durable projections and pass the declared focused proof before commit/brief-clear/clean handoff
    to `.4.3`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / RETRIEVAL** — Prove committed `c234ef9f`, empty tracked/untracked status, zero-byte
    brief, exact committed canonical receipt, and retrieve all named runtime/contract authorities before code.
  - [x] **EXACT NATIVE RED** — Extend only the staged final consumer with the `.4.2` native role and isolate the
    absent gap-state/accessor/lifecycle behavior against clean atomic 235.
  - [x] **PRIVATE STATE / TOKEN GREEN** — Add only invocation-local activation, identity, three mutable members,
    and token snapshot/restore on the existing private recognition authority without public-state widening.
  - [x] **LIFECYCLE / ACCESSOR GREEN** — Prove candidate-before-`LS`, commit-after-`LE`/before-`IT`, terminal
    tails, Unicode/empty spans, detached slot identity, falsey values, child cursor extension, and exact errors.
  - [x] **ROLLBACK / RECURSION / COMPATIBILITY** — Prove token rollback, failed minimums, nested isolation,
    direct entry, whole-rule return behavior, and byte-for-behavior-equivalent unflagged lifecycle order.
  - [x] **FOCUSED SIGNOFF / NO OVERCLAIM** — Pass the native consumer and direct Dart dependents, neutral/rooted
    dormancy governance, Dart-local gate/storage, rendered book if changed, Knowledge, all doctrines, and exact
    diff checks without canonical CI; align live docs and hand off cleanly to `.4.3`.

  Verification tier: `focused`
  Focused checks: explicit skipped native Dart gap consumer; recognition-transaction, source-location,
    interpreter/runtime-matching, rule-local cursor, duplicate-slot, recursive-observation, and existing lifecycle
    suites; neutral gap checker and rooted neutral/Perl/Rust route with Dart still skipped; complete Dart local gate
    plus Dart storage proof; affected mdBook render, Knowledge regeneration, all doctrines, and exact diff checks.
  Canonical trigger: `none` — this is an ordinary private native-runtime slice with no admission, public or
    cross-backend contract, descriptor/generated format, dependency/toolchain, CI/hook/gate, storage/path, or
    doctrine-infrastructure movement; final push/milestone canonical proof remains separately required.
  Verification: Deliberate explicit-consumer RED failed at exact `unknown_helper name="gap_kind"`; GREEN passes
    the two metadata/native groups and two direct private-authority tests. Direct dependents pass 105 plus one
    intended skip before the two new authority units; the complete Dart-local gate then passes format 102/0,
    strict analysis, 402 plus one intended skip, storage 22/47, CLI 66x2, and corpus 105/105. Neutral governance
    remains 3/6/56 plus ten Rust admission and ten Dart dormancy mutations; rooted proof passes neutral, Perl
    124, Rust 1/1, then skips Dart and the three later runtimes. The book renders 79 files / 14,812 KiB,
    Knowledge is 837 facts / 7,052 keys, and all nine doctrines pass. ADR `0073` requires focused proof and no
    full CI. Exact diff checks are clean; commit/brief/clean proof follows through `COMMIT.md`.
  Commit: `INTER-MATCH-GAP-CAPTURE.4.2 - add Dart native gap execution`

- ID: `INTER-MATCH-GAP-CAPTURE.4.3`
  Status: `done; signoff-complete` (2026-08-15; task-tree-first from clean atomic-236 commit `0b074e1c`;
    focused verification; intended atomic 237; no push)
  Goal: Carry Dart gap metadata and execution through ordinary reconstruction, descriptors, and generated plans.
  Depends on: `.4.2`
  Acceptance: prove clean activation and retrieve the frozen Dart plan plus exact normalized-`SpecFile`, compiled
    metadata, descriptor-state, generated-plan-v2, native gap lifecycle, and Rust `.3.3` precedent before code;
    extend only the library-skipped final consumer with deliberate reconstruction/descriptor/generated-plan RED;
    prove ordinary `SpecFile` JSON reconstruction preserves source-aware declaration order, nullable slot ids,
    directive metadata, and five-field selector provenance, then recompiles and executes the same native gap
    behavior; project separate `regex_slots`, `capture_gaps`, and five-field `resolved_slot_edges` values through
    the existing descriptor rule metadata without changing legacy `resolved_edges`, dependency references, or
    runtime ownership; prove direct and traced generated-plan execution use the same engine gap state and typed
    diagnostics while the static plan remains exact `{label,family}`; correct the discovered stale `.4.2` status
    in the sole-facing project status and architecture summary and record that past-sync audit; change no emitted
    source proof, primary/admission route, rollout 3/6/56, contract/checker/driver, facade/schema/semantic/MCP/CLI/
    README surface, generated format, dependency/toolchain, storage/path/doctrine infrastructure, or later
    runtime; synchronize durable projections and pass the declared focused proof before commit/brief-clear/clean
    handoff to `.4.4`.

  ### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Proved committed `0b074e1c`, empty tracked/untracked status, atomic 236
    at the durable resume pointer, and activated only this existing task node before implementation.
  - [x] **RETRIEVE AUTHORITY / PAST-SYNC AUDIT** — Queried Knowledge first and read the exact Dart/Rust carrier,
    descriptor, normalized-state, generated-plan, native lifecycle, consumer, Toolbox, and verification owners.
    Git history proves atomic 236 updated the detailed gap chapter but omitted the stale project-status and
    architecture summaries; this leaf owns their correction as part of roadmap/code/book lockstep.
  - [x] **EXACT CARRIER RED** — Extend only the skipped final consumer and isolate absent descriptor projection or
    generated/reconstruction behavior against clean atomic 236 before production repair.
  - [x] **RECONSTRUCTION / DESCRIPTOR / GENERATED GREEN** — Preserve one normalized carrier, add only the three
    compatible descriptor projections, and prove same-engine direct/traced generated execution and diagnostics.
  - [x] **COMPATIBILITY / NO OVERCLAIM** — Keep legacy descriptor/reference shapes and generated plan v2 exact;
    keep the consumer skipped, rollout/outward surfaces unchanged, and emitted/primary/admission work pending.
  - [x] **FOCUSED SIGNOFF / CLEAN HANDOFF** — Align task/roadmap/live/book/Knowledge projections, pass selected
    Dart/direct-dependent/governance/storage/book/doctrine/diff proof, and land/clear/clean before `.4.4`.

  ### Implemented Carrier Boundary

  - Deliberate explicit-consumer RED proved normalized reconstruction already executed the exact native result
    and stopped only at absent descriptor `regex_slots`. GREEN keeps normalized `SpecFile` JSON as the sole
    serialized carrier and adds fresh detached `regex_slots`, nullable `capture_gaps`, and five-field
    `resolved_slot_edges` rule metadata without altering established semantic `resolved_edges` or dependency refs.
  - Direct and disabled-trace generated-plan entrypoints retain exact ordered `{label,family}` rows and call the
    same engine, preserving Unicode prefix/tail values plus typed unavailable-context and cursor-regression
    failure details. There is no descriptor decoder, second execution engine, or emitted-source claim.
  - Exact descriptor equality now uses caller-logical source ids in three relocatable direct dependents. The full
    Dart gate found and this leaf repaired one remaining root-route fixture that compared a logical normalized
    spec with an absolute scratch-path load; targeted proof is 3/3 and no production path was weakened.
  - The startup past-sync audit is closed: project status, architecture state, roadmap, decision, Knowledge,
    current task/live views, and mdBook now agree that `.4.1-.4.3` are implemented behind the `.4.5` skip while
    `.4.4-.4.5`, rollout, generated format, and outward surfaces remain pending or unchanged.

  Verification tier: `focused`
  Focused checks: explicit skipped Dart gap consumer carrier group; compiled-spec/descriptor, source-emitter,
    runtime interpreter/matching, recognition-transaction, rule-local cursor, duplicate-slot, and typed-source
    direct dependents; neutral gap checker and rooted neutral/Perl/Rust route with Dart still skipped; complete
    Dart local gate plus Dart storage proof; rendered mdBook, Knowledge regeneration, all doctrines, both bounded
    history checks, and exact diff checks.
  Canonical trigger: `none` — this is the frozen private Dart carrier slice: it adds compatible backend-local
    descriptor fields but changes no admitted public/cross-backend contract or generated format and performs no
    admission/promotion, milestone/parent closeout, dependency/toolchain, CI/hook/gate, storage/path, or doctrine
    infrastructure movement; final push/admission canonical proof remains separately required.
  Verification: Deliberate RED stopped only at missing descriptor `regex_slots`; explicit skipped carrier proof
    passes 3/3 and the descriptor/generated direct-dependent set passes 100/100. The root-route portability
    correction passes 3/3. Complete Dart passes format 102/0, strict analysis, 402 tests plus one intended skip,
    storage 22 owners / 47 packages, CLI 66/66 in both environments, and corpus 105/105. Gap governance remains
    3/6/56 plus ten Rust admission and ten Dart dormancy mutations; its rooted route passes neutral, Perl 124,
    Rust 1/1, then four skips. Recognition 137/246/58, duplicate slot 7/0/59, and typed source 9/5/114 pass across
    their declared runtimes. The book renders 79 files / 14,816 KiB; Knowledge is 837 facts / 7,052 keys; both
    bounded-history checks, document history, memory architecture, all nine doctrines, and exact diff checks
    pass. ADR `0073` correctly excludes full canonical CI from this ordinary private carrier leaf.
  Commit: `INTER-MATCH-GAP-CAPTURE.4.3 - carry Dart gap generated execution`

- ID: `INTER-MATCH-GAP-CAPTURE.4.4`
  Status: `pending`
  Goal: Prove independently analyzed/executed emitted Dart gap behavior on repository-local storage.
  Depends on: `.4.3`
  Verification: `pending`
  Commit: `INTER-MATCH-GAP-CAPTURE.4.4 - prove Dart emitted gap execution`

- ID: `INTER-MATCH-GAP-CAPTURE.4.5`
  Status: `pending`
  Goal: Prove primary parity, admit the exact nine-role Dart consumer, and close parent `.4`.
  Depends on: `.4.4`
  Verification: `pending`
  Commit: `INTER-MATCH-GAP-CAPTURE.4.5 - admit Dart inter-match gap capture`

- ID: `INTER-MATCH-GAP-CAPTURE.5`
  Status: `pending`
  Goal: Implement exact Julia native/generated/primary parity.
  Acceptance: Julia passes the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.6`
  Status: `pending`
  Goal: Implement exact Lua/LuaJIT native/reconstructed/generated/primary parity.
  Acceptance: Both Lua ABIs pass the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.7`
  Status: `pending`
  Goal: Close cross-backend admission, migration, public documentation, and compatibility policy.
  Acceptance: Five backends and all generated/primary roles agree; aliases are retained or retired only
    through the ratified migration policy; the mdBook fully teaches lossless segmentation with examples.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `INTER-MATCH-GAP-CAPTURE.0` | `done` | History, runtime truth, terminology, ownership, future name, and named-slot syntax are durably ratified without behavior change. |
| 2 | `INTER-MATCH-GAP-CAPTURE.1.0` | `done; landed at 31f3e664` | The behavior-free executable neutral-contract plan is frozen and canonically green as atomic 218/300. |
| 3 | `INTER-MATCH-GAP-CAPTURE.1.1` | `done; landed at f58dfcb3` | The versioned neutral artifact, fixtures, independent checker, fail-first proof, and 50 mutations landed as atomic 219/300. |
| 4 | `INTER-MATCH-GAP-CAPTURE.1.2` | `done; landed at 0490522b` | Storage-rooted routing, topology governance, and public no-overclaim guards pass without runtime admission. |
| 5 | `INTER-MATCH-GAP-CAPTURE.1.3` | `done; landed at db299789` | The unchanged neutral authority is independently recomposed; parent `.1` closes without behavior movement. |
| 6 | `INTER-MATCH-GAP-CAPTURE.2.0` | `done; signoff-complete` from clean `db299789` | Exact Perl seams, dormancy, implementation, effect-ledger, carrier, and admission ownership are frozen without behavior changes; canonical proof is green. |
| 7 | `INTER-MATCH-GAP-CAPTURE.2.1` | `done; landed at 912fc5ed` | Parsing/static metadata/provenance landed without live gap execution. |
| 8 | `INTER-MATCH-GAP-CAPTURE.2.2` | `done; signoff-complete` from clean `912fc5ed` | Exact invocation-local live Perl state and accessors are implemented and canonically green for atomic 224. |
| 9 | `INTER-MATCH-GAP-CAPTURE.2.3` | `done; landed at 45460329` | Emitted and independently loaded Perl execution parity is exact without admission or plan-v2 movement. |
| 10 | `INTER-MATCH-GAP-CAPTURE.2.4` | `done; signoff-complete from clean 45460329` | Perl alone is admitted at gap 2/7/56; parent `.2` closes for intended atomic 226. |
| 11 | `INTER-MATCH-GAP-CAPTURE.3.0` | `done; landed at 4a95e02a` | Exact Rust implementation/admission seams are frozen without behavior or rollout movement as atomic 227. |
| 12 | `INTER-MATCH-GAP-CAPTURE.3.1` | `done; signoff-complete from clean 4a95e02a` | Exact Rust authored/static/compiled provenance plus dormant final-consumer governance are green without live execution or rollout movement as intended atomic 228. |
| 13 | `INTER-MATCH-GAP-CAPTURE.3.2` | `done; landed at 5c4e9d50` | Invocation-local native Rust gap state/accessors are exact on the existing recognition authority without generated or rollout movement as atomic 229. |
| 14 | `INTER-MATCH-GAP-CAPTURE.3.3` | `done; landed at 9e6ade98` | Ordinary reconstruction, compatible descriptors, and separate generated-plan parity are exact without emitted/primary/admission movement as atomic 230. |
| 15 | `INTER-MATCH-GAP-CAPTURE.3.4` | `done; landed at c3326f6d` | Fifteen independently compiled direct/traced emitted modules, storage, lockstep, and canonical proof landed as atomic 231. |
| 16 | `INTER-MATCH-GAP-CAPTURE.3.5` | `done; landed at 2800e7c3` | Exact primary parity and private Rust admission landed at 3/6/56 plus ten Rust admission mutations as atomic 232, closing parent `.3`. |
| 17 | `INTER-MATCH-GAP-CAPTURE.4.0` | `done; signoff-complete from clean 2800e7c3` | Exact Dart seams and the behavior-free `.4.1-.4.5` implementation/admission plan are frozen for intended atomic 233 without behavior or rollout movement. |
| 18 | `INTER-MATCH-GAP-CAPTURE.4.1` | `done; signoff-complete from clean e40de948` | Authored/static/compiled Dart provenance and the mechanically dormant final consumer are exact for intended atomic 234. |
| 19 | `INTER-MATCH-GAP-CAPTURE.4.2` | `signoff-complete from clean c234ef9f; focused tier` | Private native Dart gap state/accessors/lifecycle are exact for intended atomic 236 with no full CI or rollout movement. |
| 20 | `INTER-MATCH-GAP-CAPTURE.4.3` | `signoff-complete from clean 0b074e1c; focused tier` | Normalized Dart reconstruction, compatible descriptors, unchanged-v2 generated execution, and the audited stale-summary correction are exact for intended atomic 237; `.4.4` follows after clean handoff. |

## Decisions

- `2026-08-15`: Dart implementation is split across `.4.1-.4.5` before behavior. `.4.1` owns authored/static/
  compiled provenance and a library-level skipped final consumer; `.4.2` owns private same-authority native state;
  `.4.3` owns reconstruction/descriptors/generated-plan; `.4.4` owns repository-routed independently analyzed
  emitted source; `.4.5` alone owns primary, exact nine-role admission, Dart promotion, and parent closeout.
- `2026-08-15`: Dart gap state extends private `_InvocationState` and its existing token snapshot, not observed
  `RecognitionFrameState`. Runtime spans reuse the immutable input `SourceAuthority`; static diagnostics receive a
  backward-compatible logical spec source identity. Normalized `SpecFile` remains the carrier and generated plan
  v2 stays `{label,family}`.
- `2026-08-15`: The complete Dart storage oracle's current 22nd owner is the already-admitted semantic-
  introspection emitted workspace. The prior 21-owner Knowledge projection was stale documentation, not storage
  drift; `.4.0` corrects that fact without behavior or owner-list changes.
- `2026-07-17`: “Super split” is historical shorthand for inter-match gap capture in repeated
  OR/default regex rules with action edges; it is unrelated to blind calls.
- `2026-07-17`: Use **inter-match gap capture** as the formal concept, **lossless segmentation** as
  the broader architectural model, and `@capture_gaps` as the accepted future public directive.
- `2026-07-17`: The modern design uses per-rule-invocation gap state and typed spans/action context;
  `$IPOS` remains legacy compatibility machinery rather than the new neutral contract.
- `2026-07-17`: Regex slots remain owned by their declared rule. The enclosing repeated OR/default
  rule observes successful action edges such as `-> Document`, `-> Document[1]`, and
  `-> Document[2]`; a regex written immediately before an edge is not that edge's trigger.
- `2026-07-17`: A target such as `Document` retains its own lifecycle/code. Gap capture does not
  flatten child-rule behavior into the enclosing OR rule or turn child declarations into regex-only
  tables.
- `2026-07-17`: The director accepts stable named regex slots as the direction for avoiding positional
  magic numbers. Numeric/unindexed selectors remain compatibility forms.
- `2026-07-17`: The director ratifies same-line `name=/regex/` as the future named-slot declaration and
  `Document[name]` as its selector. Horizontal whitespace around `=` is insignificant, so
  `name=/regex/`, `name= /regex/`, `name =/regex/`, and `name = /regex/` are equivalent.
- `2026-07-17`: A closeout audit found current anonymous-marker scope is not portable. Perl lowers all
  three anonymous spellings to unconditional rule-level `LECODE`; Lua attaches them to the preceding
  regex slot; Rust drops the parsed marker during compilation; Dart and Julia preserve it only in
  compiled body/source state and do not consume it in native runtime execution. No backend behavior is
  changed in `.0`; `.1` owns the migration decision and executable reconciliation.
- `2026-07-20`: Rule-local cursor recurring/public rollout closes at 8 complete / 0 pending. The dependency
  prerequisite is satisfied; `.1-.7` remain proposed and require explicit activation rather than starting
  automatically.
- `2026-08-13`: Behavior-free handoff `FUTURE-PARITY-BACKLOG.14.5.0` closes at `3d0384d1` and selects this tree as
  the sole implementation/admission owner. `.1` is split into audit, executable artifact, governance/routing, and
  no-change closeout leaves; `.1.0` activates first and changes no behavior or rollout.
- `2026-08-13`: `.1.0` freezes one exact v1 neutral artifact/checker, nine-leg rollout, named-slot identity,
  directive eligibility, detached accessor records, lifecycle/terminal order, transaction/recursion policy,
  diagnostics, fixtures, mutations, storage routes, and carrier boundaries. It remains a plan only: no authored
  syntax, helper, descriptor field, runtime, rollout, or public claim becomes current.
- `2026-08-13`: Return-channel audit adds ADR `0048` as authority: repeated action returns remain accepted per-hit
  values, while default-loop action returns unwind without a gap commit or synthetic tail. The same retrieval found
  ADR `0051`'s header still said Lua pending after committed closure `b14126a6`; only that stale status was aligned.
- `2026-08-13`: Perl preflight fixes a four-leaf implementation route: `.2.1` parsing/metadata plus dormant
  final-path RED, `.2.2` same-guard live state/accessors and recognition-effect synchronization, `.2.3` emitted/
  loaded parity, and `.2.4` Perl-only admission. Host Perl Unicode tables, a second invocation stack, a widened
  transaction-authority schema, generated-plan v3, public helper admission, and typed-source promotion are all
  rejected as implementation shortcuts.

## Open Questions

- No semantic question blocks `.2.1`. Exact names, selector provenance, directive eligibility,
  prefix/interstitial/tail and empty-span policy, lifecycle timing, transaction/recursion behavior, accessors,
  compatibility, diagnostics, fixtures, mutations, routes, and rollout are frozen below.
- Implementation discoveries may refine mechanics only. Any semantic change requires a new task-tree leaf and an
  ADR amendment before changing the contract artifact.

## Current Legacy-Marker Execution Audit

| Backend | Parsed surface | Native execution today |
| --- | --- | --- |
| Perl | `@capture_slice`, `@capture_from_here`, `@move_pos`, `@mark(name)` | Anonymous spellings lower to unconditional rule-level `LECODE` and roll after every successful action; `@mark(name)` is separately guarded by the preceding regex index. |
| Rust | Same four forms retained in the AST | `CompiledRule` has no marker/body-event field and the compiler drops `SplitMarker`; the native runtime cannot execute it. |
| Dart | Same four forms retained in AST and compiled `bodyElements` | The compiler creates no event and the native interpreter never reads `bodyElements`; no marker execution. |
| Lua / LuaJIT | Same four forms | Compiler creates preceding-regex `rule_slot_events`; runtime executes them post-action/pre-`LE`. This is a later positional reinterpretation, not Perl's anonymous rule-level behavior. |

This matrix distinguishes marker members from explicit action helpers such as
`start_capture_slice()` and `mark_here(name)`, whose separately governed contracts are not changed by
this finding.

## Ratified Named Regex-Slot Syntax

- Stable named regex-slot identity is accepted. The ratified terse syntax binds a rule-local
  slot as `header = /.../` and selects it as `Document[header]`. At rule-paragraph level and outside
  code blocks, same-line `IDENT HSPACE* = HSPACE* REGEX` is a regex-slot declaration, not mutable
  assignment. Horizontal spacing around `=` is non-semantic.
- Compile every action target to a typed `{target_rule, target_slot_id}` reference and carry that exact
  identity through matcher results. Never recover slot identity from adjacency, regex text, or which
  alternation happened to match; this also addresses the existing identical-regex identity hazard
  tracked by `FUTURE-PARITY-BACKLOG.9.1.8.1`.
- The frozen neutral plan selects only `entry_slot()` so a multi-regex target can inspect one detached entry
  identity without pattern inspection, backend state, or an unnecessary alias family.

## Frozen Executable-Neutral Contract Plan (`.1.0`)

This section is the behavior-free implementation specification for `.1.1-.1.3`. None of the authored forms,
helpers, descriptor fields, diagnostics, or runtime behavior below is current until its owning implementation and
admission leaves close.

### Exact artifact, checker, routing, and rollout

- `.1.1` creates `capability_conformance/inter_match_gap_capture_contract.json` with `format: 1`,
  `contract_id: linkedspec-inter-match-gap-capture-v1`, and the independent oracle
  `tools/check_inter_match_gap_capture_contract.py`. The routed command is
  `bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py`.
- The artifact sections are exact: `expected_counts`, `policy`, `canonical_execution`, `identifier_policy`,
  `authored_surfaces`, `selector_resolution_fixtures`, `gap_sources`, `gap_context_schema`,
  `gap_state_machine`, `segmentation_cases`, `lifecycle_matrix`, `transaction_recursion_cases`,
  `compatibility_matrix`, `diagnostics`, `mutation_ids`, `recurring_gate`, and `rollout`.
- `.1.1` count locks are 8 positive selector fixtures, 10 negative selector/directive fixtures, 3 decoded source
  fixtures, 8 private current-gap fields, 16 ordered main-machine transitions, 10 segmentation cases, 3 terminal
  lifecycle routes, 7 transaction/recursion/return-channel cases, 6 compatibility rows, 9 new diagnostics, 9
  rollout legs, and 50 semantic mutations. `.1.2` adds five topology/storage/no-overclaim mutations for 55 total; later runtime
  admissions append only task-owned implementation/admission mutations and update every earlier consumer snapshot.
- The nine ordered rollout legs are `neutral_contract`, `perl_runtime`, `rust_runtime`, `dart_runtime`,
  `julia_runtime`, `puc_lua_runtime`, `luajit_runtime`, `recurring`, and `public_no_drift`. `.1.1` promotes only
  neutral; `.2-.6` own the six runtime rows; `.7` owns recurrence and public no-drift.
- `.1.2` adds `tools/check_inter_match_gap_capture_six_runtime.sh`, storage/rooting checks, the canonical opt-in
  `LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX`, and public no-overclaim guards without promoting a runtime or recurring
  row. Runtime consumers are fixed at `t/inter_match_gap_capture_perl_contract.t`,
  `rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs`,
  `dart/test/inter_match_gap_capture_contract_test.dart`,
  `julia/test/inter_match_gap_capture_contract_test.jl`, and
  `lua/test/inter_match_gap_capture_contract_test.lua`; shared Lua runs independently on PUC Lua and LuaJIT.
- All scratch/cache/build state routes through repository-derived project data. No contract command may default
  to OS temp, home caches, or an off-volume workspace. `.1.3` recomposes the unchanged neutral artifact, fixtures,
  mutations, routing, and no-overclaim proof, then hands off to Perl `.2` without a behavior change.

### Named declaration and selector grammar

- `REGEX_SLOT_NAME` reuses the pinned Unicode 17.0.0 `XID_Continue` scalar classifier already governing rule
  labels. Identity is the exact decoded scalar sequence: case-sensitive and normalization-sensitive. A name made
  only of ASCII decimal digits is reserved for positional selection and is invalid as a declared name; no keyword
  blacklist is added because rule-paragraph declaration and bracket-selector contexts are structurally distinct.
- One rule-local declaration is exactly `REGEX_SLOT_NAME HSPACE* = HSPACE* REGEX` on one physical rule-paragraph
  line outside code. Named and anonymous regex declarations may mix. Every declaration increments the same
  zero-based `regex_index` in authored order, and a name must be unique within its owning rule.
- `Rule`, `Rule[N]`, and `Rule[name]` are the only selector forms. Unindexed selection resolves slot zero;
  `Rule[N]` resolves the written nonnegative index; `Rule[name]` resolves the exact rule-local name. Bracket names
  never fall back to numbers, regex text, adjacency, or normalization. Dot remains fluent behavior only.
- Every compiled edge retains exact `{selector_kind, authored_selector, target_rule, regex_index,
  target_slot_id}` provenance. `selector_kind` is `unindexed`, `numeric`, or `named`; `authored_selector` is null,
  an integer, or an exact string respectively; `target_slot_id` is the declared name or null for an anonymous
  slot. Numeric and named forms may resolve the same named slot, but only the named source form survives reorder
  by identity. Matcher results and descriptor projection carry both resolved index and nullable stable id.
- Future `entry_slot()` returns a recursively detached ordinary harray with ordered fields `target_rule`,
  `regex_index`, `slot_id`, `selector_kind`, and `authored_selector` when a target rule is entered from an action
  edge; direct invocation returns `undef`. It introduces no new value kind or source authority.

### Directive eligibility and compatibility

- `@capture_gaps` is one placement-insensitive rule-level directive, canonically written after `I` and before the
  first action edge. It is valid exactly when compiled metadata says `family = or_default`, `cursor_policy = seek`,
  `edge_ownership = action`, `uses_loop = true`, execution shape is `default_scan_loop` or `repeat_loop`, and at
  least one statically resolved action edge exists. Blind, mixed, AND/consume, and local-adjacency ownership are
  ineligible.
- Target rules retain their regexes, entry match, lifecycle, cursor policy, recursion, and result behavior. The
  enclosing eligible rule alone owns repeated choice and gap state. The directive never turns a target into a
  passive regex table and never makes a nearby regex trigger a following edge.
- Legacy member markers `@capture_slice`, `@capture_from_here`, and `@move_pos` retain their current compatibility
  behavior and are not aliases for `@capture_gaps`. An eligible rule may not combine one of those anonymous member
  markers with `@capture_gaps`; that conflict is diagnosed instead of choosing backend-dependent timing.
  `@mark(name)` and explicit capture/mark helper calls remain separate and may coexist; they mutate the existing
  anonymous boundary/marks, never the new gap cursor. No `@emit_gaps` surface or forced AST emission is introduced.

### Typed gap context, lifecycle order, and tail

- Each activated rule invocation owns `{source_id, invocation_id, committed_gap_cursor, accepted_edge_count,
  current_gap}`. Entry sets the committed cursor to the rule-entry Unicode-scalar position, count to zero, and
  current gap to absent. Nested and recursive entries allocate independent state on the existing monotonic
  invocation authority; a child suspends rather than aliases its parent's candidate.
- After matcher selection and before enclosing `LS`, form one read-only candidate span
  `[committed_gap_cursor, selected_match.start)` with `provenance = gap`. Its kind is `prefix` for the first
  accepted edge and `interstitial` thereafter. The candidate stays current through enclosing `LS`, the selected
  edge action and any target call, and all enclosing `LE` code. A child sees only its own invocation's gap state.
- Future `gap_span()` returns a fresh detached `{source_id, start, end, provenance}` harray, `gap_text()`
  materializes its exact decoded text from the current source authority, and `gap_kind()` returns `prefix`,
  `interstitial`, or `tail`. Empty spans are first-class and are never trimmed or suppressed. Calling any accessor
  without an active current gap is a portable diagnostic.
- On accepted completion of the edge and all `LE` code, require the accepted cursor to be at or after the selected
  match end, commit it as the next gap cursor, increment the accepted-edge count, and clear the candidate before
  `IT`. Falsey action payloads remain accepted when match presence says accepted. Reject/rollback/abnormal unwind
  discards the candidate and does not advance committed gap state; user variables, AST mutation, output, external
  calls, and other effects remain outside rollback, matching the existing recognition-transaction boundary.
- A successful terminal loop path installs one read-only `tail` candidate
  `[committed_gap_cursor, input_end)` before the existing terminal hook: `LX` for a default scan-loop miss, `EX`
  for repetition exhaustion after its minimum, or `E` after a repetition reaches its maximum. A failed minimum
  exposes no tail. A successful zero-match/zero-min path exposes the whole entry-to-input-end span. Tail access
  never consumes input, advances the parser cursor, or appends a result automatically; its candidate clears when
  the terminal path returns or unwinds.
- Existing same-source, range, reversed-span, cursor-regression, zero-progress repetition, transaction, and
  recursive-progress rules remain authoritative. Gap cursor state joins the owning invocation snapshot so
  backtracking/rollback cannot leak a candidate or committed boundary; detached spans remain immutable data only.
- Existing return-channel ownership remains exact. In repeated action handlers, an action-edge `return(value)` is
  the accepted iteration payload defined by ADR `0048`, so gap finalization and the remaining successful-iteration
  path still run. In the unadorned default scan loop, an action-edge return remains a direct whole-rule return: it
  unwinds the active candidate without committing a new gap boundary and without fabricating a tail. A return from
  `LS`, `LE`, `IT`, `LX`, `EX`, or `E` likewise retains whole-rule authority; candidate cleanup follows that
  terminal unwind and never changes the returned value.

The private current-gap record has exact ordered fields `source_id`, `rule_label`, `invocation_id`, `edge_ordinal`,
`kind`, `start`, `end`, and `provenance`. `rule_label` is the enclosing gap-owning rule; `edge_ordinal` is the
zero-based accepted-edge count before a selected candidate and the final accepted-edge count for a tail; and
`provenance` is exact string `gap`. The main machine uses decoded source `αHβ\nS🙂Fω` (scalar length 8),
with selected spans `H=[1,2)`, `S=[4,5)`, and `F=[6,7)`, and executes these exact transitions:

1. `enter_root` initializes cursor 0, count 0, and no current gap.
2. `select_header` installs `prefix=[0,1)` before `LS`.
3. `enter_header_ls` proves prefix context is current.
4. `accept_falsey_header_edge` preserves accepted match presence despite false payload.
5. `enter_header_le` proves the same candidate survives the edge.
6. `commit_header` advances committed cursor to 2 and count to 1.
7. `enter_header_it` proves current gap has cleared.
8. `select_section` installs `interstitial=[2,4)` including the newline.
9. `suspend_for_section_child` preserves but hides parent context during isolated child entry.
10. `resume_section_parent` restores the same detached parent candidate.
11. `commit_section` advances cursor to 5 and count to 2.
12. `select_footer` installs Unicode `interstitial=[5,6)`.
13. `commit_footer` advances cursor to 7 and count to 3.
14. `terminal_miss` installs `tail=[7,8)` without moving the parser cursor.
15. `enter_terminal_lx` proves exact tail context at the default-loop terminal hook.
16. `accept_root` clears current state and leaves no retained gap history.

The other source fixtures are `HS` for empty prefix/interstitial/tail and `p{abc}gap!` for an opening match whose
target accepts through `}` at scalar 6, making the next gap exact `[6,9) = gap` before `!`.

### Exact fixture and mutation families

- Declaration/selector positives are `spacing_compact`, `spacing_before_equals`, `spacing_after_equals`,
  `spacing_both`, `unicode_xid_exact`, `mixed_named_anonymous`, `numeric_named_same_target`, and
  `named_reorder_stable`. Negative cases are `invalid_slot_name`, `numeric_only_name`, `duplicate_slot_name`,
  `unknown_named_selector`, `selector_index_out_of_range`, `malformed_named_selector`, `duplicate_directive`,
  `ineligible_and_family`, `ineligible_blind_owner`, and `legacy_marker_conflict`.
- Segmentation cases are `unicode_prefix_interstitial_tail`, `empty_prefix`, `empty_interstitial`, `empty_tail`,
  `zero_match_whole_tail`, `child_extended_accepted_exit`, `falsey_action_accepted`, `maximum_exit_tail`,
  `failed_edge_no_commit`, and `nested_recursive_isolation`. The lifecycle matrix independently proves
  selection → candidate → `LS` → edge/target → `LE` → commit → `IT`, plus terminal `LX`/`EX`/`E` placement.
- The seven transaction/recursion/return-channel rows are `accepted_falsey_commits`, `edge_failure_discards`,
  `recognition_rollback_restores`, `abnormal_unwind_clears`, `nested_child_suspends_parent`, and
  `recursive_invocation_isolates_state`, plus `default_action_return_unwinds_without_commit_or_tail`. The six
  compatibility rows are the three anonymous legacy members
  (retained, not aliases, conflict when mixed), `@mark(name)` (independent and allowed), explicit capture/mark
  helpers (independent and allowed), and absent `@emit_gaps`/forced emission.
- Diagnostics are exact records for `regex_slot_name_invalid`, `regex_slot_duplicate_name`,
  `regex_slot_unknown_name`, `regex_slot_index_out_of_range`, `regex_slot_selector_invalid`,
  `capture_gaps_duplicate_directive`, `capture_gaps_rule_ineligible`, `capture_gaps_legacy_marker_conflict`, and
  `gap_capture_context_unavailable`. Cursor/source/range/progress failures reuse the existing typed-source and
  recognition diagnostic codes rather than inventing aliases. Every record carries rule/source location plus the
  relevant selector, slot, family, ownership, phase, invocation, or coordinate fields without source-text leakage.
- The diagnostic schema is `{code, phase, detection, required_context}`. Required contexts are exact:
  `regex_slot_name_invalid` uses `parse_declaration` / `static` →
  `{rule_label,source_id,line,slot_name}`;
  `regex_slot_duplicate_name` uses `resolve_declaration` / `static` →
  `{rule_label,source_id,line,slot_name,first_line}`;
  `regex_slot_unknown_name` uses `resolve_selector` / `static` →
  `{rule_label,source_id,line,target_rule,authored_selector}`;
  `regex_slot_index_out_of_range` uses `resolve_selector` / `static` →
  `{rule_label,source_id,line,target_rule,regex_index,regex_count}`;
  `regex_slot_selector_invalid` uses `parse_selector` / `static` →
  `{rule_label,source_id,line,target_rule,authored_selector}`;
  `capture_gaps_duplicate_directive` uses `parse_directive` / `static` →
  `{rule_label,source_id,line,first_line}`;
  `capture_gaps_rule_ineligible` uses `validate_directive` / `static` →
  `{rule_label,source_id,line,family,cursor_policy,edge_ownership,execution_shape}`;
  `capture_gaps_legacy_marker_conflict` uses `validate_directive` / `static` →
  `{rule_label,source_id,line,marker,marker_line}`; and `gap_capture_context_unavailable` uses
  `access_gap_context` / `static_or_runtime` → `{rule_label,source_id,invocation_id,phase,accessor}` so
  reconstructed/programmatic artifacts cannot bypass it.
- Checker mutation classes cover contract identity/counts, identifier classification and digit reservation,
  spacing/uniqueness/mixing/order, selector provenance/equivalence/reorder/duplicate-regex identity, directive
  cardinality/eligibility/compatibility, typed source/Unicode/empty spans, prefix/interstitial/tail boundaries,
  lifecycle order, falsey acceptance, commit/rollback/failure/recursion isolation, diagnostics, rollout,
  storage/routing, and public no-overclaim. `.1.1` proves fail-first absence, passing semantics, and reason-checked
  in-memory corruptions; `.1.2` adds topology/storage/current-claim corruptions without changing behavior.
- The 50 `.1.1` semantic mutation ids are `contract_id`, `format`, `task_owner`, `expected_counts`,
  `required_section`, `identifier_classifier`, `digit_reservation`, `normalization_identity`, `case_identity`,
  `spacing_compact`, `spacing_before_equals`, `spacing_after_equals`, `spacing_both`, `mixed_declaration_order`,
  `duplicate_slot_name`, `selector_unindexed`, `selector_numeric`, `selector_named`, `named_reorder_stability`,
  `numeric_reorder_position`, `selector_provenance`, `duplicate_regex_identity`, `directive_cardinality`,
  `directive_family`, `directive_cursor_policy`, `directive_edge_ownership`, `directive_loop`,
  `directive_static_edge`, `legacy_marker_conflict`, `explicit_helper_independence`, `gap_source_identity`,
  `gap_half_open`, `gap_empty`, `gap_unicode`, `gap_prefix`, `gap_interstitial`, `gap_tail`, `zero_match_tail`,
  `candidate_before_ls`, `candidate_through_le`, `commit_before_it`, `falsey_acceptance`, `child_extended_exit`,
  `failure_no_commit`, `rollback_no_commit`, `unwind_clear`, `recursion_isolation`, `nested_suspend_resume`,
  `action_return_authority`, and `diagnostic_schema`. `.1.2` adds `rollout_sequence`, `runtime_rows_pending`,
  `storage_paths`, `route_order`, and `public_no_overclaim`.

### Carrier and no-overclaim boundary

- Perl `.2` must prove authored parse, descriptor provenance, live execution, target lifecycle, recursion and
  rollback, portable diagnostics, emitted-source generation, and independently loaded generated execution.
- Rust/Dart/Julia `.3-.5` must each prove native, ordinary serialized/normalized reconstruction, descriptor,
  generated-plan, emitted-source, target-lifecycle, recursion/rollback, portable-diagnostic, and primary-command
  roles. Shared Lua `.6` proves those roles independently on PUC Lua and LuaJIT from one Lua source.
- `.7` runs every complete runtime exactly once, all generated/capability/language ledgers, both primary option
  environments, migration locks, and public/mdBook no-drift before promoting recurrence/public admission.
  Until then the mdBook must distinguish complete private Perl runtime admission from unimplemented later-runtime
  and portable/public admission; README, facades, semantic/MCP schemas, CLI, capability status, and typed-source
  `lossless_gap_composition` do not move.

## Activation Boundary

- The cursor and duplicate-slot prerequisites are satisfied. Neutral `.1` landed through `db299789`; behavior-free
  Perl plan `.2.0` landed at `8f826923`, and authored/static `.2.1` landed at atomic-223 commit `912fc5ed`.
  Live `.2.2` is atomic 224. Generated/loaded `.2.3` landed as atomic 225 at `45460329`. Runtime admission `.2.4`
  and parent `.2` landed cleanly as atomic 226 at `eceb15ac`. Rust behavior-free preflight `.3.0` is signoff-
  complete behavior-free `.3.0` landed cleanly as atomic 227 at `4a95e02a`; authored/static `.3.1` landed cleanly
  as atomic 228 at `95127e1d` without live execution or rollout movement. Native runtime `.3.2` is signoff-
  complete and landed at `5c4e9d50`; reconstructed/generated carrier `.3.3` is signoff-complete from that exact
  boundary. Emitted proof `.3.4` landed as atomic 231 at `c3326f6d`; final private admission `.3.5` closed parent
  `.3` in atomic 232 at `2800e7c3`. Dart planning `.4.0` landed at `e40de948`, authored metadata `.4.1` at
  `1e6d326d`, focused-verification policy atomic 235 at `c234ef9f`, and private native `.4.2` at atomic 236
  `0b074e1c`. Reconstructed/descriptor/generated `.4.3` is signoff-complete from that exact boundary for intended
  atomic 237; `.4.4` may activate only after commit/brief-clear/clean proof.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-08-15` | `INTER-MATCH-GAP-CAPTURE.4.3` | Clean `0b074e1c` activation; exact carrier RED/GREEN; normalized reconstruction; compatible descriptor metadata; same-engine direct/traced generated execution and typed failures; direct dependents; root-route logical-source correction; neutral/rooted gap, recognition, duplicate-slot, and typed-source matrices; complete Dart/storage; rendered mdBook; Knowledge Map; bounded history; all nine doctrines; focused tier with no canonical CI | Pass: RED stops only at absent descriptor `regex_slots`; explicit proof is 3/3, direct dependents 100/100, and root-route 3/3. Dart-local is format 102/0, strict analysis, 402 plus one intended skip, storage 22/47, CLI 66x2, and corpus 105. Gap remains 3/6/56 plus ten Rust admission and ten Dart dormancy mutations; rooted execution is neutral, Perl 124, Rust 1/1, then four skips. Recognition 137/246/58, duplicate slot 7/0/59, and typed source 9/5/114 pass. Book is 79/14,816 KiB, Knowledge 837/7,052, and all nine doctrines pass. ADR `0073` correctly excludes full CI; emitted/primary/admission, rollout, plan v2, and outward surfaces remain unchanged or pending. |
| `2026-08-15` | `INTER-MATCH-GAP-CAPTURE.4.2` | Clean `c234ef9f` activation; exact explicit-consumer RED/GREEN; one-authority native state/accessors/lifecycle/entry/rollback/nesting; direct Dart dependents; neutral and rooted gap governance; complete Dart-local/storage gate; rendered mdBook; Knowledge Map; all nine doctrines; focused tier with no canonical CI | Pass: RED reaches exact unknown-helper `gap_kind`; explicit metadata/native proof is 2/2 and direct private-authority proof is 2/2. Dart-local is format 102/0, strict analysis, 402 plus one intended skip, storage 22/47, CLI 66x2, and corpus 105. Gap stays 3/6/56 plus ten Rust admission and ten Dart dormancy mutations; rooted execution is neutral, Perl 124, Rust 1/1, then Dart/Julia/PUC-Lua/LuaJIT skips. Book is 79/14,812 KiB, Knowledge 837/7,052, and all nine doctrines pass. ADR `0073` correctly excludes full CI: reconstructed/generated, emitted/primary/admission, rollout, plan v2, and outward surfaces remain unchanged or pending. |
| `2026-08-15` | `INTER-MATCH-GAP-CAPTURE.4.1` | Clean `e40de948` activation; checker-first dormant RED/GREEN; authored parser/AST/static/compiler/source-identity proof; complete Dart/storage; neutral, recognition, typed-source, and duplicate-slot matrices; rendered mdBook; Knowledge Map; all eight doctrines; authorized canonical local CI with opt-in gap route | Pass: the final dormant consumer is 1/1 while ordinary Dart remains 400 plus one intended skip. Complete Dart is format 102/0, strict analysis, storage 22 owners / 47 packages, CLI 66/66 twice, and corpus 105/105. Gap remains 3/6/56 plus ten Rust admission and ten Dart dormancy mutations; recognition 137/246/58, typed source 9/5/114, and duplicate-slot 7/0/59 remain unchanged. The book is 79/14,788 KiB, Knowledge is 836/7,039, and all eight doctrines pass. The sandboxed precursor stops solely at outer nested-`sandbox-exec` status 71; the unchanged authorized run passes containment/relocation, CLI 66/66 twice, RAM 56%, Phase 0 1,031/1,031 in 745 seconds, neutral/Perl-124/Rust-1/four-skip routing, `[ci] local CI gate passed`, and exit 0. |
| `2026-08-15` | `INTER-MATCH-GAP-CAPTURE.4.0` | Clean `2800e7c3` activation; Knowledge-first Dart parser/compiler/runtime/carrier/emitter/primary audit; repository-routed authored/accessor/lifecycle/primary probes; neutral and rooted gap governance; focused and complete Dart proof; storage; rendered mdBook; Knowledge Map; all eight doctrines; authorized canonical local CI with opt-in gap route | Pass: exact absence is localized to unimplemented named declaration/selector/directive syntax and four accessors; numeric syntax and the existing primary path remain healthy. The dependency-complete `.4.1-.4.5` plan changes no behavior or rollout. Focused Dart is 123/123; complete Dart is format 101/0, strict analysis, package 400/400, storage 22 owners / 47 packages, CLI 66/66 twice, and corpus 105/105. Gap remains 3/6/56 plus ten Rust admission mutations; the rooted route runs neutral, Perl 124, Rust 1/1, then four skips. Rendered book, Knowledge 836/7,036, and all eight doctrines pass. The sandboxed precursor stops solely at outer nested-`sandbox-exec` status 71; the unchanged authorized run passes six-family containment, all-five-anchor relocation, CLI 66/66 twice, RAM 59%, Phase 0 1,031/1,031 in 771 seconds, the rooted gap route, `[ci] local CI gate passed`, and exit 0. |
| `2026-08-15` | `INTER-MATCH-GAP-CAPTURE.3.5` | Clean `c3326f6d` activation; exact primary/admission RED/GREEN; nine-role once-only consumer; ordinary/canonical/rooted registration; runtime, recognition, recursion, cursor, source-emitter, duplicate-slot, typed-source and neutral ledgers; 17-owner storage; rendered mdBook; Knowledge Map; all eight doctrines; authorized canonical local CI with opt-in gap route | Pass: the existing primary adapter returns exact item/gap pairs for mixed separators; only Rust advances to gap 3/6/56 plus ten admission mutations. Rust admission is 1/1 with zero ignored tests; runtime is 170/170, recognition 12/12, recursion 7/7, and the rooted route runs neutral, Perl 124, Rust 1/1, then four skips. Book is 79/14,732 KiB and Knowledge 835/7,020. The sandboxed precursor stops solely at outer nested-`sandbox-exec` status 71; the unchanged authorized run passes containment/relocation, CLI 66/66 twice, RAM 73%, Phase 0 1,031/1,031, `[ci] local CI gate passed`, and exit 0. Generated plan v2 and every outward/later-runtime row remain unchanged or pending; parent `.3` closes. |
| `2026-08-14` | `INTER-MATCH-GAP-CAPTURE.3.4` | Clean `9e6ade98` activation; exact ignored-consumer emitted-owner RED/GREEN; fifteen independently compiled direct/traced modules; runtime, recognition, recursion, cursor, source-emitter, and duplicate-slot compatibility; neutral checker and rooted route; project-data storage; rendered mdBook; Knowledge Map; all eight doctrines; canonical local CI with opt-in gap route | Pass: thirteen value and two typed-error modules prove emitted mixed separators, Unicode/empty spans, falsey values, lifecycle, child cursors, nesting, rollback, tails, minimum failure, direct entry, legacy behavior, and exact generated trace identity. Ordinary discovery remains 0/1 ignored; gap remains 2/7/56 plus ten Rust dormancy mutations; generated plan v2, emitter, primary/admission, and outward surfaces remain unchanged. Focused proof is 1/1 in 32.82 seconds; runtime 170/170, recognition 12/12, recursion 7/7, cursor 1/1, emitter 6/6, duplicate slot 1/1, the 17-owner storage oracle, rendered book 79/14,724 KiB, Knowledge 835/7,019, and all doctrines pass. The sandboxed canonical run stopped only at outer nested-`sandbox-exec` status 71; the unchanged authorized run passes containment/relocation, CLI 66/66 twice, RAM 60%, Phase 0 1,031/1,031 in 780 seconds, exact neutral-plus-Perl routing with five skips, `[ci] local CI gate passed`, and exit 0. |
| `2026-08-14` | `INTER-MATCH-GAP-CAPTURE.3.3` | Clean `5c4e9d50` activation; exact ignored-consumer carrier RED/GREEN; ordinary reconstruction; compatible descriptors; generated-plan lifecycle/entry/diagnostics; full runtime unit library; recognition, recursion, cursor, source-emitter, and duplicate-slot compatibility; neutral checker and rooted route; project-data storage; rendered mdBook; Knowledge Map; all doctrines; canonical local CI with opt-in gap route | Pass: serialized `CompiledSpec` remains the single carrier; exact slot/directive/selector metadata survives reconstruction and descriptor projection; native and generated-plan values/diagnostics agree while plan v2 and the emitter stay unchanged. Ordinary discovery remains 0/1 ignored; gap remains 2/7/56 plus ten Rust dormancy mutations; recognition 137/246/58, typed source 9/5/114, emitted/primary/admission roles, and outward surfaces remain unchanged. The focused test is 1/1 in 5.96 seconds; descriptor 4/4, runtime 170/170, recognition 12/12, recursion 7/7, cursor 6/6, emitter 6/6, duplicate slot 1/1, the 17-owner storage oracle, rendered book 79/14,720 KiB, Knowledge 835/7,019, and all eight doctrines pass. The sandboxed canonical run stopped only at the outer harness's nested-`sandbox-exec` status 71; the unchanged elevated run passes six-family containment, all-five-anchor relocation, CLI 66/66 twice, RAM 69%, Phase 0 1,031/1,031 in 772 seconds, exact neutral-plus-Perl routing with five skips, `[ci] local CI gate passed`, and exit 0. |
| `2026-08-14` | `INTER-MATCH-GAP-CAPTURE.3.2` | Clean `95127e1d` activation; exact ignored-consumer RED/GREEN; native state/lifecycle/accessors; private gap units; full runtime unit library; recognition, recursion, cursor, and duplicate-slot compatibility; neutral checker and rooted route; project-data storage; rendered mdBook; Knowledge Map; all doctrines; canonical local CI with opt-in gap route | Pass: exact private native candidate/commit/tail behavior, Unicode/empty gaps, detached slots, rollback/nesting, lifecycle, and typed failures are green while ordinary discovery remains 0/1 ignored. Gap remains 2/7/56 plus ten Rust dormancy mutations; recognition 137/246/58, typed source 9/5/114, generated plan v2, reconstructed/generated/emitted/primary roles, recurring/facade routes, and outward surfaces remain unchanged. Rendered book is 79 files / 14,708 KiB, Knowledge is 835 facts / 7,016 keys, the 17-owner Rust storage oracle and all eight doctrines pass. The sandboxed canonical run stopped only at the outer harness's nested-`sandbox-exec` status 71; the unchanged authorized run passes containment/relocation, CLI 66/66 twice, RAM 49%, Phase 0 1,031/1,031 in 735 seconds, exact neutral-plus-Perl routing with five skips, `[ci] local CI gate passed`, and exit 0. |
| `2026-08-14` | `INTER-MATCH-GAP-CAPTURE.3.1` | Clean `4a95e02a` activation; exact consumer RED/GREEN; parser/AST/validation/compiler/serde/descriptor compatibility; full core; 105-source generated manifest; source emitter and rule-local cursor; Unicode and duplicate slot; neutral checker plus ten Rust dormancy mutations; recognition, typed source, project-data storage; rendered mdBook; Knowledge Map; all doctrines; canonical local CI with opt-in gap route | Pass: Rust authored declarations/selectors/directive and compiled provenance are exact while the final consumer is ignored in ordinary package execution and runnable only through focused `--ignored --exact`. Anonymous `/=/` priority and undefined-target precedence have permanent guards. Gap remains 2/7/56; recognition 137/246/58, typed source 9/5/114, duplicate slot 7/0/59, generated plan v2, descriptors, runtime/facade/recurring routes, and outward surfaces remain unchanged. Rendered book is 79/14,704 KiB, Knowledge is 835/7,013, and all eight doctrines pass. The sandboxed canonical attempt stopped only at nested-`sandbox-exec` status 71; the unchanged authorized run passes containment/relocation, CLI 66/66 twice, RAM 55%, Phase 0 1,031/1,031, exact neutral-plus-Perl routing with five skips, `[ci] local CI gate passed`, and exit 0. |
| `2026-08-14` | `INTER-MATCH-GAP-CAPTURE.3.0` | Clean `eceb15ac` activation; Knowledge-first authority retrieval; exact neutral/rooted route; primary-process baseline probes; parser/AST/compiler/runtime/carrier/emitter/primary source audit; focused duplicate-slot test; recognition, typed-source, storage, rendered mdBook, Knowledge Map, all eight doctrines; permission-authorized canonical local CI with the opt-in gap route | Pass: exact baseline is gap 2/7/56, ordinary/rooted Perl 124, five later-runtime skips, recognition 137/246/58, public helpers 122, typed source 9/5/114, and duplicate slot 7/0/59. The Rust focused test passes 1/1 in 17.61 seconds. The dependency-complete `.3.1-.3.5` plan preserves generated plan v2, one recognition authority, all outward guards, and every rollout row. Rendered book is 79 files / 14,704 KiB, Knowledge is 835/7,009, and all eight doctrines pass. The sandboxed canonical run reached only the outer harness's nested-`sandbox-exec` status 71; the unchanged authorized run passes containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 741 seconds, exact neutral-plus-Perl routing, `[ci] local CI gate passed`, and exit 0. No Rust behavior or rollout moved. |
| `2026-08-14` | `INTER-MATCH-GAP-CAPTURE.2.4` | Clean `45460329` activation; ordinary full consumer; exact admission/route/topology checker; rooted recurring route; language, recognition, typed-source, duplicate-slot, public-no-overclaim, project-data and outside-CWD proof; rendered mdBook; Knowledge Map; all eight doctrines; permission-authorized canonical local CI with the opt-in gap route | Pass: the consumer executes metadata/live/generated phases as 124 top-level tests, once canonically and once after the neutral checker in the rooted route. Only `perl_runtime` advances; gap is exactly 2 complete + 7 pending / 56 mutations, followed by five ordered later-runtime skips. Recognition remains 137/246/58, public helpers 122, typed source 9/5/114, duplicate-slot 7/0/59, generated plan v2 and ten outward guards unchanged. Knowledge is 834/6,995 and all eight doctrines pass. Canonical CI passes containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 765 seconds, exact neutral-plus-Perl routing, `[ci] local CI gate passed`, and exit 0. Parent `.2` closes without public or later-runtime promotion. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.2.3` | Clean `34d02e0c` activation; metadata/live GREEN and deliberate generated RED; Toolbox emitted-source/descriptor root cause; private runtime import, typed-error/entry-boundary carrier, descriptor guard, and five-group loaded parity; gap/recognition/typed-source/duplicate-slot and focused dependent matrices; rendered book; Knowledge/doctrines; canonical local CI with opt-in gap route | Pass: metadata 110, all nine live groups, and five generated groups / 138 internal assertions prove byte-identical values, cursors, source/selector provenance, Unicode/empty gaps, lifecycle tails, rollback, recursion, typed diagnostics, direct entry, and legacy rolling. Plan v2 stays exact `{label,family}`; gap stays 1/8/55 plus ten dormancy locks, recognition 137/246/58, public helpers 122, and typed source 9/5/114. The sandboxed gate reached only the outer harness's nested-`sandbox-exec` status 71; the unchanged authorized run passes all eight doctrines, Knowledge 834/6,995, six-family containment, all-five-anchor relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 773 seconds, exact neutral-plus-six-pending gap routing, `[ci] local CI gate passed`, and exit 0. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.2.2` | Clean `912fc5ed` activation; exact live RED; private runtime/lifecycle/accessor/transaction implementation; metadata and nine-group native-live contract; recognition neutral checker and all admitted snapshots; gap, recognition, typed-source, and duplicate-slot cross-runtime matrices; rendered book; Knowledge/doctrines; Phase 0; durable lockstep; permission-authorized canonical local CI with the gap-route opt-in | Pass: metadata 110 and all nine live groups cover Unicode/empty prefix/interstitial/tail, falsey and child-extended commits, recursion isolation, same-token rollback, LX/EX/E tails, typed context/cursor-regression failures, detached/direct slot identity, and legacy compatibility. Recognition is 137/246/58 with 122 public helpers; gap remains 1/8/55 plus ten dormancy locks; typed source remains 9/5/114. Cross-runtime recognition, gap, typed-source, and duplicate-slot matrices pass without generated/loaded execution or outward admission. The checker-caught “runtime unimplemented” marker was truthfully narrowed to pending runtime admission with counts unchanged. Rendered book is 79/14,672 KiB, Knowledge 834/6,992, and all eight doctrines pass. The first staged gate reached only the outer harness's nested-`sandbox-exec` status 71; the unchanged authorized run passes containment/relocation, CLI 66/66 twice, RAM 76%, Phase 0 1,031/1,031 in 756 seconds, the exact opt-in neutral-plus-six-pending route, `[ci] local CI gate passed`, and exit 0. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.2.1` | Clean `8f826923` activation; checker-first dormant RED; permanent grammar/reference-bridge self-hosting; private Unicode-17 generation; exact metadata/diagnostics/generated provenance; ordinary named selection; focused compatibility suites; five-backend self-host matrix; Phase 0; neutral and dormancy mutations | Interim pass pending final canonical recomposition: checker-first six-subtest RED failed five expected authored/static cases before implementation. The final dormant consumer passes 108 assertions; neutral proof remains 8+10 fixtures / 3 sources / 16 transitions / 10 segmentations / 9 diagnostics / 1 complete + 8 pending / 55 mutations, plus 10 independent Perl dormancy mutations. Unicode proof passes 806 ranges, 9 positive, 8 negative, and 2 exact-distinct pairs. The five-backend self-host matrix passes in both option environments; focused legacy suites pass; Phase 0 passes 1,031/1,031 in 781 seconds. The first staged canonical run passed through composed semantic-introspection, then correctly rejected omission of repeated-action historical next owner `FUTURE-PARITY-BACKLOG.10.1` from bounded memory; the known `.22`-owned marker coupling was restored without behavior or checker change. No live gap/accessor/generated gap execution or outward admission moved. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.1.3` | Clean `0490522b` activation; authority-first retrieval; independent JSON/order/marker/surface/consumer recomposition; exact checker and routed driver; base-relative governed-byte proof; storage and outside-CWD routing; duplicate-slot and typed-source full matrices; rendered mdBook; Knowledge Map; all eight doctrines; permission-authorized canonical local CI with the gap-route opt-in | Pass: exact format/id and 8+10 fixtures / 3 sources / 16 transitions / 10 segmentations / 9 diagnostics remain at rollout 1 complete + 8 pending and 55 rejected mutations. Neutral executes once; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT skip in exact order because all five planned consumer sources remain absent. Five current markers and ten outward guards are exact. Contract/checker/driver, canonical/storage routes, all backend code, API/schema/CLI surfaces, and README are byte-unchanged from `0490522b`. Storage/outside-CWD, duplicate-slot 59, typed-source 9/5/114, rendered book 79/14,632 KiB, Knowledge 832/6,967, and all eight doctrines pass. Canonical CI passes containment/relocation, CLI 66/66 twice, RAM 61%, Phase 0 1,031/1,031 in 725 seconds, the exact opt-in neutral-plus-six-pending route, `[ci] local CI gate passed`, and exit 0. Parent `.1` closes without authored/runtime/public behavior or rollout movement. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.1.2` | Clean `f58dfcb3` activation; checker-first topology RED; focused neutral checker and 55 mutations; rooted recurring route; project-data storage and outside-CWD routing; duplicate-slot five-backend and typed-source six-runtime matrices; rendered mdBook; Knowledge Map; all eight doctrines; staged canonical local CI with the gap-route opt-in | Pass: RED exited 1 with only `inter-match gap capture contract: FAIL: required sections drifted`; GREEN locks 8+10 fixtures / 3 sources / 16 transitions / 10 segmentations / 9 diagnostics / rollout 1 complete + 8 pending / 55 rejected mutations. The driver executes neutral once and skips exactly Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT without invoking absent consumers. Duplicate-slot remains 59; typed-source remains 9/5/114; storage/outside-CWD routing passes; rendered book is 78 files / 14,632 KiB; Knowledge is 831 facts / 6,960 keys; all eight doctrines pass. The sandboxed canonical run passed every earlier gate before the outer harness denied nested `sandbox-exec` with status 71. The unchanged permission-authorized run passed six-family containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 61%, Phase 0 1,031/1,031, the exact neutral-plus-six-pending route, and `[ci] local CI gate passed` with exit 0. No authored/runtime/public behavior or rollout row moved. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.1.1` | Clean `31f3e664` activation; checker-first governed RED; focused neutral checker; exact 50 deep-copy corruptions; duplicate-slot five-backend matrix; typed-source six-runtime matrix; rendered mdBook; Knowledge Map; all eight doctrines; staged canonical local CI | Pass: exact absence exited 1 with only `inter-match gap capture contract is missing`; GREEN locks 8+10 fixtures / 3 sources / 8 private fields / 16 transitions / 10 segmentations / 3 terminal routes / 7 transaction-recursion-return rows / 6 compatibility rows / 9 diagnostics / rollout 1 complete + 8 pending / 50 rejected semantic mutations. Duplicate-slot remains 59 across five backends and typed-source remains 9/5/114 across six runtimes. Rendered book passes 79 files / 14,628 KiB, Knowledge passes 830 facts / 6,950 keys, and all eight doctrines pass. The first staged gate caught the exact Python-entrypoint census drift at 29 versus 30; after that containment lock was repaired, the sandboxed restart reached only the outer harness's status-71 denial of nested `sandbox-exec`. The unchanged permission-authorized run passed six-family containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 55%, and Phase 0 1,031/1,031 in 737 seconds through exact `[ci] local CI gate passed` and exit 0. Exact generated verification residue is removed; no authored or runtime behavior moved. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.1.0` | Clean `3d0384d1` activation; ADR/Knowledge/contract/task retrieval; `LinkedSpec::Get(return_descriptor)` numeric/named probes; generated-source order; corrected historical live fixture; five-backend marker audit; duplicate-slot and typed-source matrices; rendered book; Knowledge Map; doctrines; canonical local CI | Pass: current `Top::OR` is action-owned/seek/repeating; numeric slot 1 resolves; named forms reject; generated order is selection → `LS` → action/target → legacy `LE` → `IT`; historical result is exact `[pre,H]`, `[gap,S]`, `[more,F]` without tail; marker divergence is unchanged; duplicate 59 and typed-source 9/5/114 pass. Rendered book passes 79 files / 14,628 KiB and Knowledge passes 830 facts / 6,950 question keys. Canonical signoff caught and rejected two condensed no-drift projection omissions, then the corrected permission-authorized run passed all eight doctrines, six-family containment, all-five-anchor relocation, CLI 66/66 twice, RAM 52%, and Phase 0 1,031/1,031 in 735 seconds through exact `[ci] local CI gate passed`. The prior status 71 was solely the outer harness denying nested `sandbox-exec`. No behavior or rollout moved. |
| `2026-07-17` | `INTER-MATCH-GAP-CAPTURE.0` | Baseline `cf25bd37` source/spec audit; drift commits `8588b07b`/`300e6950`; current descriptor `Document[0..2]`; live three-gap/lifecycle probe; five-backend marker-scope code audit; `knowledge-map/scripts/check_knowledge_map.sh`; `mdbook build docs/linkedspec-book`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check` | Pass: current code preserves external target-slot ownership and automatic prefix/interstitial rolling; legacy marker divergence is explicit; derived map 583 facts / 4,106 keys; all documentation/governance gates green. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `INTER-MATCH-GAP-CAPTURE.4.3` | `INTER-MATCH-GAP-CAPTURE.4.3 - carry Dart gap generated execution` | Signoff-complete reconstructed/descriptor/generated Dart carrier for intended atomic 237/300 from `0b074e1c`; focused proof only, final consumer remains dormant, and rollout is unchanged; no push. |
| `INTER-MATCH-GAP-CAPTURE.4.2` | `INTER-MATCH-GAP-CAPTURE.4.2 - add Dart native gap execution` | Signoff-complete private native Dart execution for intended atomic 236/300 from `c234ef9f`; focused proof only, final consumer remains dormant, and rollout is unchanged; no push. |
| `INTER-MATCH-GAP-CAPTURE.4.1` | `1e6d326d` — `INTER-MATCH-GAP-CAPTURE.4.1 - add Dart authored gap metadata` | Authored/static/compiled Dart metadata landed cleanly as atomic 234/300; final consumer remains dormant and rollout unchanged; no push. |
| `INTER-MATCH-GAP-CAPTURE.4.0` | `INTER-MATCH-GAP-CAPTURE.4.0 - freeze Dart gap implementation plan` | Signoff-complete behavior-free Dart freeze for intended atomic 233/300 from `2800e7c3`; no push. |
| `INTER-MATCH-GAP-CAPTURE.3.5` | `2800e7c3` — `INTER-MATCH-GAP-CAPTURE.3.5 - admit Rust inter-match gap capture` | Rust admission and parent `.3` closeout landed cleanly as atomic 232/300; no push. |
| `INTER-MATCH-GAP-CAPTURE.3.4` | `c3326f6d` — `INTER-MATCH-GAP-CAPTURE.3.4 - prove Rust emitted gap execution` | Emitted proof landed cleanly as atomic 231/300; the consumer remains ignored and Rust admission stays `.3.5`; no push. |
| `INTER-MATCH-GAP-CAPTURE.3.2` | `5c4e9d50` — `INTER-MATCH-GAP-CAPTURE.3.2 - add Rust native gap execution` | Private native gap execution landed cleanly as atomic 229/300; Rust remains generated/admission-pending at 2/7/56; no push. |
| `INTER-MATCH-GAP-CAPTURE.3.1` | `INTER-MATCH-GAP-CAPTURE.3.1 - add Rust authored gap metadata` | Signoff-complete for intended atomic 228/300 from `4a95e02a`; Rust remains runtime-pending at 2/7/56; no push. |
| `INTER-MATCH-GAP-CAPTURE.3.0` | `4a95e02a` — `INTER-MATCH-GAP-CAPTURE.3.0 - freeze Rust gap implementation plan` | Behavior-free freeze landed cleanly as atomic 227/300 from `eceb15ac`; no push. |
| `INTER-MATCH-GAP-CAPTURE.2.4` | `INTER-MATCH-GAP-CAPTURE.2.4 - admit Perl inter-match gap capture` | Signoff-complete Perl-parent closeout for intended atomic 226/300 from `45460329`; no push. |
| `INTER-MATCH-GAP-CAPTURE.2.3` | `INTER-MATCH-GAP-CAPTURE.2.3 - carry Perl gaps through generated execution` | Signoff-complete for intended atomic 225/300 from `34d02e0c`; no push. |
| `INTER-MATCH-GAP-CAPTURE.2.2` | `INTER-MATCH-GAP-CAPTURE.2.2 - add Perl native-live gap capture` | Signoff-complete for intended atomic 224/300 from `912fc5ed`; no push. |
| `INTER-MATCH-GAP-CAPTURE.2.1` | `INTER-MATCH-GAP-CAPTURE.2.1 - add Perl authored gap metadata` | Signoff-complete for intended atomic 223/300 from `8f826923`; no push. |
| `INTER-MATCH-GAP-CAPTURE.1.3` | `INTER-MATCH-GAP-CAPTURE.1.3 - close unchanged neutral authority` | Signoff-complete closeout for intended atomic 221/300; activation pointer must prove `0490522b == HEAD^1`. |
| `INTER-MATCH-GAP-CAPTURE.1.2` | `0490522b` — `INTER-MATCH-GAP-CAPTURE.1.2 - govern recurring neutral route` | Recurring-neutral governance landed cleanly as atomic 220/300. |
| `INTER-MATCH-GAP-CAPTURE.1.1` | `f58dfcb3` — `INTER-MATCH-GAP-CAPTURE.1.1 - add executable neutral contract` | Executable-neutral authority landed cleanly as atomic 219/300. |
| `INTER-MATCH-GAP-CAPTURE.1.0` | `31f3e664` — `INTER-MATCH-GAP-CAPTURE.1.0 - freeze executable neutral plan` | Behavior-free audit/plan landed cleanly as atomic 218/300. |
| `INTER-MATCH-GAP-CAPTURE.0` | `INTER-MATCH-GAP-CAPTURE.0 - ratify inter-match gap capture` | Historical recovery and design ratification only; no runtime change. |

## Changelog

- `2026-08-15`: Completed `.4.3` reconstructed/descriptor/generated Dart carrier from clean `0b074e1c`.
  Normalized `SpecFile` JSON remains the only carrier; detached descriptor projections add slot/directive/
  selector provenance without changing legacy shapes; direct/traced generated plans retain `{label,family}` and
  the same native engine. RED stopped only at absent `regex_slots`; explicit proof is 3/3, direct dependents
  100/100, root-route 3/3, and Dart-local 402 plus one skip/storage 22/47/CLI 66x2/corpus 105. Neutral/rooted,
  recognition, duplicate-slot, typed-source, book 79/14,816, Knowledge 837/7,052, bounded history, and all nine
  doctrines pass under focused ADR `0073` proof. The stale `.4.2` summary omission is corrected; emitted/primary/
  admission, rollout, generated plan v2, and outward surfaces remain pending or unchanged for intended atomic 237.
- `2026-08-15`: Completed `.4.2` private native Dart execution from clean `c234ef9f`. The existing recognition
  authority now owns exact candidate/commit/tail state, detached entry identity, Unicode-scalar accessors,
  rollback, nested isolation, and typed failures without widening observed state. Explicit proof is 2/2, private
  authority is 2/2, Dart-local is 402 plus one skip/storage 22/47/CLI 66x2/corpus 105, rooted governance remains
  neutral→Perl 124→Rust 1 with four skips, book is 79/14,812, Knowledge 837/7,052, and nine doctrines pass. ADR
  `0073` keeps this ordinary private leaf focused; no full CI, admission, rollout, generated format, or outward
  movement occurs. Intended atomic 236 follows through commit/brief/clean proof before `.4.3`.
- `2026-08-15`: Implemented `.4.1` Dart authored/static/compiled metadata from clean `e40de948`. The exact
  final-path consumer remains library-skipped until `.4.5`; ten Dart dormancy mutations join unchanged 3/6/56
  governance plus ten Rust admission mutations. Pinned-Unicode named slots, selector authorship, logical source
  identity, static diagnostics, directive eligibility, compiled slot/directive rows, and five-field edge
  provenance are GREEN. Native gap state, descriptor/generated execution, emitted/primary proof, rollout, and
  every outward surface remain separately owned by `.4.2-.4.5`. Signoff is complete at dormant 1/1, Dart 400
  plus one skip, book 79/14,788 KiB, Knowledge 836/7,039, all doctrines, Phase 0 1,031/1,031 in 745 seconds, and
  canonical exit 0 for intended atomic 234.
- `2026-08-15`: Landed behavior-free `.4.0` cleanly as atomic 233 at `e40de948`, cleared the commit brief, proved
  memory/task metadata and an empty tree, and activated authored/static/compiled Dart leaf `.4.1` task-tree-first
  from that exact boundary. Runtime state, reconstructed/generated execution, emitted proof, primary/admission,
  and every outward surface remain separately owned by `.4.2-.4.5`.
- `2026-08-15`: Completed behavior-free Dart planning `.4.0` from clean `2800e7c3`. Exact source and runtime
  probes, focused 123/123, complete Dart format 101/0, strict analysis, package 400/400, storage 22/47, CLI 66x2,
  corpus 105/105, rendered book, Knowledge 836/7,036, and all eight doctrines pass. The sandboxed canonical
  precursor stops only at outer status 71; the unchanged authorized run passes containment/relocation, CLI 66x2,
  RAM 59%, Phase 0 1,031/1,031 in 771 seconds, exact rooted routing, and local-CI exit 0. Gap stays 3/6/56 plus
  ten Rust admission mutations; no Dart behavior or rollout moves before dependency-frozen `.4.1-.4.5`.
- `2026-08-15`: Completed `.3.5` and parent `.3` signoff from clean `c3326f6d`. Exact primary execution, the
  once-only nine-role consumer, ordinary/canonical/rooted admission, 3/6/56 governance, ten Rust admission
  mutations, storage, book, Knowledge, all doctrines, containment/relocation, CLI 66x2, RAM 73%, Phase 0
  1,031/1,031, exact rooted routing, and local-CI exit 0 pass for intended atomic 232. Dart `.4` follows only
  after commit/brief-clear/clean proof.
- `2026-08-15`: Landed `.3.4` cleanly as atomic 231 at `c3326f6d`, cleared the commit brief, proved the post-commit
  pointer and empty tree, and activated final private Rust primary/admission leaf `.3.5` task-tree-first from that
  exact boundary. Only Rust admission, nine-role composition, 3/6/56 governance, and parent `.3` closeout are in
  scope; later runtimes and every outward surface remain pending.
- `2026-08-14`: Completed `.3.4` implementation and signoff from clean `9e6ade98`. Fifteen independently compiled
  emitted modules prove paired direct/traced values, lifecycle, diagnostics, rollback, recursion, source identity,
  and mixed-separator list preservation while ordinary discovery remains 0/1 ignored and rollout remains 2/7/56.
  The 17-owner storage oracle, rendered book 79/14,724 KiB, Knowledge 835/7,019, all eight doctrines, containment/
  relocation, CLI 66x2, RAM 60%, Phase 0 1,031/1,031 in 780 seconds, exact opt-in routing, and local-CI exit 0 pass.
  Atomic-231 commit/brief/clean proof then landed at `c3326f6d` before `.3.5` activation.
- `2026-08-14`: Completed `.3.3` implementation and signoff from clean `5c4e9d50`. Ordinary reconstruction,
  separate compatible descriptor metadata, and generated-plan gap parity are exact; focused proof is 1/1 while
  ordinary discovery remains 0/1 ignored and rollout remains 2/7/56. The 17-owner storage oracle, rendered book
  79/14,720 KiB, Knowledge 835/7,019, all eight doctrines, containment/relocation, CLI 66x2, RAM 69%, Phase 0
  1,031/1,031 in 772 seconds, exact opt-in routing, and local-CI exit 0 pass. Only commit/brief/clean proof remains
  before `.3.4`.
- `2026-08-14`: Completed `.3.2` implementation from clean `95127e1d`. The existing recognition authority now
  owns exact private native gap state, accessors, entry identity, lifecycle, rollback, and nested isolation;
  focused ignored proof is 1/1, ordinary discovery remains 0/1 ignored, runtime units are 170/170, and dependent
  recognition/recursion/cursor/slot plus neutral/rooted checks pass without rollout or outward movement.
- `2026-08-14`: Completed `.3.2` signoff at rendered book 79/14,708 KiB, Knowledge 835/7,016, all eight doctrines,
  the 17-owner Rust storage oracle, containment/relocation, CLI 66x2, RAM 49%, Phase 0 1,031/1,031 in 735 seconds,
  exact opt-in routing, and local-CI exit 0. Only commit/brief/clean proof remains before `.3.3`.
- `2026-08-14`: Completed `.3.1` signoff from clean `4a95e02a`. Dormant Rust metadata proof, rendered book
  79/14,704 KiB, Knowledge 835/7,013, all eight doctrines, containment/relocation, CLI 66x2, RAM 55%, Phase 0
  1,031/1,031, exact opt-in routing, and local-CI exit 0 pass. Only commit/brief/clean proof remains before `.3.2`.
- `2026-08-14`: Landed behavior-free `.3.0` cleanly as atomic 227 at `4a95e02a`, passed the post-commit pointer,
  cleared the brief to zero bytes, and activated authored/static `.3.1` task-tree-first. This leaf alone owns Rust
  source-AST/static/compiled provenance plus dormant consumer staging; live gap execution and rollout stay fixed.
- `2026-08-14`: Completed `.3.0` signoff from clean `eceb15ac`. Exact gap 2/7/56, rooted Perl 124 plus five
  skips, focused Rust 1/1, recognition 137/246/58, typed source 9/5/114, rendered mdBook 79/14,704 KiB,
  Knowledge 835/7,009, all eight doctrines, containment/relocation, CLI 66x2, RAM 57%, Phase 0 1,031/1,031 in
  741 seconds, exact opt-in routing, and local-CI exit 0 pass. Only the atomic-227 commit/brief/clean boundary
  remains before `.3.1`; no Rust behavior or rollout moved.
- `2026-08-14`: Landed `.2.4` and parent `.2` cleanly as atomic 226 at `eceb15ac`, cleared the commit brief, and
  activated behavior-free Rust preflight `.3.0` task-tree-first. Rust implementation is dependency-split under
  `.3.1-.3.5`; no Rust parser/compiler/runtime/carrier/emitter/CLI behavior or rollout has moved.
- `2026-08-14`: Completed `.2.4` and parent `.2` signoff from clean `45460329`. Focused proof, rendered mdBook,
  Knowledge 834/6,995, all eight doctrines, containment/relocation, CLI 66x2, RAM 57%, Phase 0 1,031/1,031 in
  765 seconds, exact neutral-plus-Perl routing with five later-runtime skips, and local-CI exit 0 pass. Only the
  atomic-226 commit/brief/clean boundary remains before Rust `.3`.
- `2026-08-13`: Implemented `.2.4` admission: the full consumer defaults to all phases and passes 124 tests,
  canonical CI and the rooted neutral-first driver each register it once, only `perl_runtime` becomes complete,
  and governance advances to 2/7/56 while later runtimes/public rows and ten outward surfaces remain pending.
- `2026-08-13`: Landed `.2.3` as clean atomic 225 at `45460329`, cleared the commit brief, and activated Perl-only
  admission `.2.4` task-tree-first from that exact boundary. Only canonical/recurring registration, the Perl
  rollout row, exact mutation 55→56, ledgers, and parent closeout are in scope.
- `2026-08-13`: Completed `.2.3` from clean `34d02e0c`: generated source imports the private runtime, aligns the
  ordinary entry cursor, preserves typed gap errors, and guards live-only descriptor metadata. Five groups / 138
  internal assertions match live execution without plan-v2 or admission movement. Focused matrices and canonical
  containment/relocation, CLI 66x2, RAM 57%, Phase 0 1,031/1,031 in 773 seconds, and opt-in routing pass.
- `2026-08-13`: Activated `.2.3` task-tree-first from clean atomic 224 at `34d02e0c`. Authority retrieval and
  complete roadmap/codebase/mdBook review identify only the generated private-runtime import, typed-error carrier,
  and independently-loaded parity proof as in-scope; generated-plan v2, admission, and outward surfaces stay fixed.
- `2026-08-13`: Implemented `.2.2` private native-live behavior from clean `912fc5ed`: one same-guard state,
  exact candidate/commit/tail placement, detached slot/gap accessors, transaction rollback, recursion isolation,
  typed diagnostics, and four private source-read nodes. Metadata 110, all nine live groups, recognition
  137/246/58, public helpers 122, gap 1/8/55 plus dormancy, typed source 9/5/114, and focused cross-runtime matrices
  pass. Generated/loaded execution, admission, and outward surfaces remain pending.
- `2026-08-13`: Activated `.2.2` task-tree-first from clean atomic 223 at `912fc5ed`. Authority retrieval and
  project-tool preflight prove neutral 1/8/55, metadata 108, recognition 133/246/58, and the exact live placeholder
  RED before any implementation edit; `.2.2` alone now owns live same-guard state/accessors and the 137-row sync.
- `2026-08-13`: Implemented `.2.1` from clean `8f826923`: permanent grammar and reference bridge accept four
  declaration spacings, Unicode-17 names, named/numeric/unindexed selectors, and eligible `@capture_gaps` static
  metadata. RuleIR/descriptors/generated dependency rows retain stable five-field provenance and exact typed
  diagnostics; the 108-assertion dormant consumer and 10 no-admission mutations pass. Live gap state/accessors,
  generated gap execution, rollout, recognition, public helpers, typed source, and outward surfaces do not move.
- `2026-08-13`: Completed `.1.3` and parent `.1` from clean `0490522b`: independent recomposition, governed-byte
  no-change, storage/outside-CWD, duplicate-slot 59, typed-source 9/5/114, rendered book, Knowledge, all doctrines,
  containment/relocation, CLI 66x2, RAM 61%, Phase 0 1,031/1,031 in 725 seconds, and exact opt-in routing pass.
  Runtime/public rollout remains 1 complete + 8 pending; only atomic-221 commit/brief/clean precedes Perl `.2`.
- `2026-08-13`: Landed `.1.2` cleanly at `0490522b` as atomic 220/300, then activated `.1.3` task-tree-first from
  that boundary for independent unchanged recomposition and neutral-parent closeout; runtime rows remain pending.
- `2026-08-13`: Completed `.1.2` from clean `f58dfcb3`: one rooted driver executes neutral once and reports six
  exact pending-runtime skips; five new corruptions lock route/status/storage/public truth at unchanged 1/8
  rollout and 55 mutations. Focused, storage, outside-CWD, rendered-book, Knowledge, all-doctrine, containment,
  relocation, CLI 66x2, Phase 0 1,031/1,031, and opt-in canonical signoff pass; only the atomic-220 commit remains.
- `2026-08-13`: Landed `.1.1` cleanly at `f58dfcb3` as atomic 219/300, then activated `.1.2` task-tree-first from
  that boundary for routing/topology/storage/public no-overclaim governance only; all runtime rows remain pending.
- `2026-08-13`: Completed `.1.1` checker-first: its governed route failed exactly on the absent artifact, then
  the format-1 neutral artifact passed executable Unicode/empty/child/transaction modeling and all 50 reason-
  checked corruptions at 1 complete + 8 pending. No parser, compiler, runtime, descriptor, helper, schema, CLI,
  README, or current authored-surface behavior moved. Focused, rendered-book, Knowledge, all-doctrine, containment,
  relocation, CLI 66x2, and Phase 0 1,031/1,031 canonical signoff pass; only the per-slice commit remains.
- `2026-08-13`: Landed `.1.0` cleanly at `31f3e664` as atomic 218/300, then activated `.1.1` task-tree-first from
  that clean boundary for the neutral artifact/checker only.
- `2026-08-13`: Activated `.1.0` task-tree-first from clean cross-tree handoff `3d0384d1`; dependency-split the
  neutral contract into audit, artifact, governance/routing, and closeout leaves before any implementation edit.
- `2026-08-13`: Completed the behavior-free `.1.0` authority audit and froze the dependency-complete executable
  contract plan for `.1.1-.1.3`; canonical signoff is complete, while implementation and rollout remain pending.
- `2026-07-17`: Created the task tree before recording the ratified decision or correcting documentation.
- `2026-07-17`: Completed `.0`: recovered the faithful Perl behavior, corrected blind-call/adjacency drift,
  accepted `@capture_gaps`, and ratified spacing-insensitive `name=/regex/` plus `Rule[name]` as future syntax.
