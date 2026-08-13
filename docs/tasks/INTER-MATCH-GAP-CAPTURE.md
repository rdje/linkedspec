# INTER-MATCH-GAP-CAPTURE: Lossless Inter-Match Segmentation

## Metadata

- Tree ID: `INTER-MATCH-GAP-CAPTURE`
- Status: `active` / neutral governance/routing `.1.2` signoff-complete from clean `f58dfcb3`; `.1.3` waits for
  the atomic-220 clean boundary
- Roadmap lane: `.spec language evolution / lossless segmentation and source preservation`
- Created: `2026-07-17`
- Last updated: `2026-08-13`
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
  Status: `active` (2026-08-13; `.1.1` landed cleanly at `f58dfcb3`; `.1.2` is signoff-complete and lands in the
    intended atomic 220/300 commit; no push)
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
  Status: `active` (2026-08-13; neutral artifact/checker `.1.1` landed; governance/routing `.1.2` is
    signoff-complete; unchanged recomposition `.1.3` follows after the clean commit)
  Goal: Define an executable backend-neutral `@capture_gaps` and typed gap-span contract.
  Children: `.1.0`, `.1.1`, `.1.2`, `.1.3`
  Acceptance: The contract fixes prefix/interstitial/tail policy, empty-gap preservation, offsets,
    action ordering, tail handling, state commit, recursion scope, compatibility, diagnostics, and
    conformance fixtures before runtime changes. It also fixes named regex-slot declaration/selection
    syntax and typed target-slot identity before matcher or edge changes. Legacy-marker migration
    starts from the explicit backend matrix recorded in `.0`, not from the later parity claim.
  Verification: `pending`
  Commit: `pending`

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
  Status: `done; signoff-complete` (2026-08-13; task-tree-first from clean neutral-contract commit `f58dfcb3`;
    lands as atomic 220/300 in this commit; no push)
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
  Status: `pending`
  Goal: Recompose the committed neutral contract, fixtures, mutations, routes, documentation, and no-drift
    boundaries unchanged, close `.1`, and hand off cleanly to Perl implementation `.2`.
  Depends on: `.1.2`

- ID: `INTER-MATCH-GAP-CAPTURE.2`
  Status: `pending`
  Goal: Implement the neutral contract on the Perl reference without overloading `$IPOS`.
  Acceptance: Per-invocation gap state and typed action context replace implicit arithmetic for the new
    surface while legacy spellings retain their governed compatibility behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.3`
  Status: `pending`
  Goal: Implement exact Rust native/generated/primary parity.
  Acceptance: Rust passes the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.4`
  Status: `pending`
  Goal: Implement exact Dart native/reconstructed/generated/primary parity.
  Acceptance: Dart passes the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

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
| 4 | `INTER-MATCH-GAP-CAPTURE.1.2` | `done; signoff-complete` from clean `f58dfcb3` | Storage-rooted routing, topology governance, and public no-overclaim guards pass without runtime admission. |
| 5 | `INTER-MATCH-GAP-CAPTURE.1.3` | `pending` after atomic-220 clean landing | Recompose the unchanged neutral authority, close `.1`, and hand off to Perl `.2`. |

## Decisions

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

## Open Questions

- No semantic question blocks `.1.3`. Exact names, selector provenance, directive eligibility,
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
| Julia | Same four forms retained in AST and compiled `body_elements` | The compiler creates no event and the native interpreter never reads `body_elements`; no marker execution. |
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
  Until then the mdBook must label every planned spelling and helper as not implemented; README, facades,
  semantic/MCP schemas, CLI, capability status, and typed-source `lossless_gap_composition` do not move.

## Activation Boundary

- The cursor and duplicate-slot prerequisites are satisfied. Neutral-contract audit `.1.0` landed at `31f3e664`,
  and artifact/checker `.1.1` landed at `f58dfcb3`. Governance/routing `.1.2` is signoff-complete from that clean
  boundary and lands in atomic 220/300; `.1.3` waits for that commit to become clean. No gap-capture implementation
  is current, and runtime leaves `.2-.6` remain pending until `.1.3` closes the complete neutral contract.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.1.2` | Clean `f58dfcb3` activation; checker-first topology RED; focused neutral checker and 55 mutations; rooted recurring route; project-data storage and outside-CWD routing; duplicate-slot five-backend and typed-source six-runtime matrices; rendered mdBook; Knowledge Map; all eight doctrines; staged canonical local CI with the gap-route opt-in | Pass: RED exited 1 with only `inter-match gap capture contract: FAIL: required sections drifted`; GREEN locks 8+10 fixtures / 3 sources / 16 transitions / 10 segmentations / 9 diagnostics / rollout 1 complete + 8 pending / 55 rejected mutations. The driver executes neutral once and skips exactly Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT without invoking absent consumers. Duplicate-slot remains 59; typed-source remains 9/5/114; storage/outside-CWD routing passes; rendered book is 78 files / 14,632 KiB; Knowledge is 831 facts / 6,960 keys; all eight doctrines pass. The sandboxed canonical run passed every earlier gate before the outer harness denied nested `sandbox-exec` with status 71. The unchanged permission-authorized run passed six-family containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 61%, Phase 0 1,031/1,031, the exact neutral-plus-six-pending route, and `[ci] local CI gate passed` with exit 0. No authored/runtime/public behavior or rollout row moved. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.1.1` | Clean `31f3e664` activation; checker-first governed RED; focused neutral checker; exact 50 deep-copy corruptions; duplicate-slot five-backend matrix; typed-source six-runtime matrix; rendered mdBook; Knowledge Map; all eight doctrines; staged canonical local CI | Pass: exact absence exited 1 with only `inter-match gap capture contract is missing`; GREEN locks 8+10 fixtures / 3 sources / 8 private fields / 16 transitions / 10 segmentations / 3 terminal routes / 7 transaction-recursion-return rows / 6 compatibility rows / 9 diagnostics / rollout 1 complete + 8 pending / 50 rejected semantic mutations. Duplicate-slot remains 59 across five backends and typed-source remains 9/5/114 across six runtimes. Rendered book passes 79 files / 14,628 KiB, Knowledge passes 830 facts / 6,950 keys, and all eight doctrines pass. The first staged gate caught the exact Python-entrypoint census drift at 29 versus 30; after that containment lock was repaired, the sandboxed restart reached only the outer harness's status-71 denial of nested `sandbox-exec`. The unchanged permission-authorized run passed six-family containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 55%, and Phase 0 1,031/1,031 in 737 seconds through exact `[ci] local CI gate passed` and exit 0. Exact generated verification residue is removed; no authored or runtime behavior moved. |
| `2026-08-13` | `INTER-MATCH-GAP-CAPTURE.1.0` | Clean `3d0384d1` activation; ADR/Knowledge/contract/task retrieval; `LinkedSpec::Get(return_descriptor)` numeric/named probes; generated-source order; corrected historical live fixture; five-backend marker audit; duplicate-slot and typed-source matrices; rendered book; Knowledge Map; doctrines; canonical local CI | Pass: current `Top::OR` is action-owned/seek/repeating; numeric slot 1 resolves; named forms reject; generated order is selection → `LS` → action/target → legacy `LE` → `IT`; historical result is exact `[pre,H]`, `[gap,S]`, `[more,F]` without tail; marker divergence is unchanged; duplicate 59 and typed-source 9/5/114 pass. Rendered book passes 79 files / 14,628 KiB and Knowledge passes 830 facts / 6,950 question keys. Canonical signoff caught and rejected two condensed no-drift projection omissions, then the corrected permission-authorized run passed all eight doctrines, six-family containment, all-five-anchor relocation, CLI 66/66 twice, RAM 52%, and Phase 0 1,031/1,031 in 735 seconds through exact `[ci] local CI gate passed`. The prior status 71 was solely the outer harness denying nested `sandbox-exec`. No behavior or rollout moved. |
| `2026-07-17` | `INTER-MATCH-GAP-CAPTURE.0` | Baseline `cf25bd37` source/spec audit; drift commits `8588b07b`/`300e6950`; current descriptor `Document[0..2]`; live three-gap/lifecycle probe; five-backend marker-scope code audit; `knowledge-map/scripts/check_knowledge_map.sh`; `mdbook build docs/linkedspec-book`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check` | Pass: current code preserves external target-slot ownership and automatic prefix/interstitial rolling; legacy marker divergence is explicit; derived map 583 facts / 4,106 keys; all documentation/governance gates green. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `INTER-MATCH-GAP-CAPTURE.1.2` | `INTER-MATCH-GAP-CAPTURE.1.2 - govern recurring neutral route` | Signoff-complete recurring-neutral governance lands as atomic 220/300 in this commit. |
| `INTER-MATCH-GAP-CAPTURE.1.1` | `f58dfcb3` — `INTER-MATCH-GAP-CAPTURE.1.1 - add executable neutral contract` | Executable-neutral authority landed cleanly as atomic 219/300. |
| `INTER-MATCH-GAP-CAPTURE.1.0` | `31f3e664` — `INTER-MATCH-GAP-CAPTURE.1.0 - freeze executable neutral plan` | Behavior-free audit/plan landed cleanly as atomic 218/300. |
| `INTER-MATCH-GAP-CAPTURE.0` | `INTER-MATCH-GAP-CAPTURE.0 - ratify inter-match gap capture` | Historical recovery and design ratification only; no runtime change. |

## Changelog

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
