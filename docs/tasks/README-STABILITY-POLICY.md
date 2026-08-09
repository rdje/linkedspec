# README-STABILITY-POLICY: Stable Landing Page and Mechanical Growth Guard

## Metadata

- Tree ID: `README-STABILITY-POLICY`
- Status: `active` / routing-pressure revision reopened
- Roadmap lane: `Repository architecture / documentation sustainability`
- Created: `2026-07-29`
- Last updated: `2026-08-09` (director-priority routing-pressure revision `.4` activated task-tree-first from
  clean cursor-transaction contract commit `7c2ff407`; `.4.0` audit/ratification is active; no push)
- Owner: repo-local workflow

## Goal

Adopt the director-approved project-neutral README stability policy as a repository-owned LinkedSpec doctrine:
turn `README.md` into a concise stable landing page, route changing detail to canonical homes, and enforce reviewed
line/byte budgets through the existing doctrine registry, pre-commit hook, and canonical local CI gate. The
director-priority 2026-08-09 revision extends that doctrine with transitive routing-pressure closure: every actual
reader and author-overflow route must terminate at a classified, mechanically controlled destination rather than
moving unbounded append pressure into a neighboring live document.

## Non-Goals

- Do not delete unique user, architecture, operational, historical, or roadmap information; route it first.
- Do not change LinkedSpec production, parser, runtime, backend, contract, fixture, test, CLI, or protocol behavior.
- Do not make `README.md` a generated file or copy mdBook/roadmap/task-tree content back into it.
- Do not raise a cap merely to accommodate ordinary feature detail.
- Do not modify the external FSMGen template; it is an explicitly director-authorized, read-only adoption source.

## Acceptance Criteria

- A repository-owned root `README_POLICY.md` defines the landing-page content/routing contract and cap-change rule.
- Every unique current README content class has a verified canonical destination before duplicated changing detail is
  removed.
- The retained README covers purpose/audience/scope, prerequisites, one verified quick start, stable architecture,
  canonical navigation, contribution/support, and license/essential notices within deliberately reviewed budgets.
- A deterministic, non-mutating, repository-rooted checker enforces both budgets with actionable routing guidance,
  includes rejection/acceptance self-tests, and is registered as a doctrine.
- The existing registry makes the checker run through pre-commit and canonical local CI; doctrine prose, bootstrap,
  task-tree, roadmap/live docs, Knowledge Map, and mdBook remain aligned.
- Every path-shaped destination named by README, the adopted policy, or checker failure guidance is inventoried as
  `reader_navigation`, `author_overflow`, or both; every route reaches a controlled terminal without an unclassified
  hop, cycle, or pressure-shifting chain.
- Hot/live, partitioned, generated, append-only, external, and frozen destinations have class-appropriate pressure
  controls and reviewed threshold governance. Legacy measured ceilings are recorded as debt, never reusable ideals.
- The README checker validates the routed-destination inventory and controls unconditionally, including when README
  itself is unchanged, and mutation tests reject missing routes, undeclared hints, cycles, invalid lifecycle/control
  combinations, stale generated owners, and unauthorized threshold increases.
- Each completed leaf is committed through `COMMIT.md`; no push occurs before cadence 300.

## Task Tree

- ID: `README-STABILITY-POLICY`
  Status: `active` (2026-08-09; original adoption `.0-.2` remains complete; `.3` remains an independent proposed
    director decision; routing-pressure revision `.4` is active)
  Goal: Adopt and mechanically enforce a stable, bounded LinkedSpec repository landing page.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`

- ID: `README-STABILITY-POLICY.0`
  Status: `done` (2026-07-29; behavior-free adoption plan signoff-complete from clean recurring MCP plan commit
    `c6f36fe3`)
  Goal: Audit the complete README, freeze lossless routing, reviewed budgets, enforcement design, and implementation
    split without changing README content or executable enforcement.
  Acceptance: Read the 71-line director-authorized external policy in full; measure the current README; classify
    every top-level section and unique content owner; prove destinations exist or assign explicit implementation
    owners; select post-trim line/byte caps with modest headroom; specify checker diagnostics/self-tests, doctrine
    registration, bootstrap discovery, mdBook/live-doc alignment, and `.1-.2` dependency order; commit a
    documentation-only plan from a clean boundary.

  #### Acceptance Checklist

  - [x] **CLEAN BASE / OWNERSHIP** — Commit `c6f36fe3` is clean; brief is zero bytes; rendered-book and managed-run
    residue are absent; this leaf exists before any LinkedSpec policy, README, checker, or documentation change.
  - [x] **EXTERNAL POLICY READ** — The director-authorized same-volume FSMGen policy template was read fully and
    read-only: 71 lines defining a
    repository-owned policy, stable landing-page content, canonical routing, deliberate trim, dual caps,
    non-mutating routing-aware enforcement, pre-commit/CI wiring, and reviewed cap increases.
  - [x] **COMPLETE README INVENTORY / LOSSLESS ROUTING** — Classify all current README sections and map every unique
    retained fact to a stable landing-page need or a verified canonical repository destination.
  - [x] **REVIEWED BUDGET / ENFORCEMENT DESIGN** — Freeze measured post-trim budgets, exact checker contract,
    mutation/self-test coverage, doctrine identity, registry/prose/bootstrap wiring, and cap-increase governance.
  - [x] **IMPLEMENTATION / CLOSEOUT SPLIT** — Freeze `.1` as the only content/check adoption owner and `.2` as
    unchanged recurring signoff/parent closeout; record exact exclusions and commit/brief/cleanup handoff.
  - [x] **LOCKSTEP / SIGNOFF** — Plan/task-index/roadmap/live/notes/memory/Knowledge Map/mdBook align; focused
    documentation checks, Knowledge Map, mdBook, memory architecture, doctrines, whitespace, scope, and cleanup pass.

  Verification: README unchanged at 1,615 lines / 159,437 bytes; prototype measured 105 lines / 5,072 bytes and
    its exact Lispish command returned `["hello",["world"]]`; Knowledge Map 756 facts / 6,129 keys; mdBook build
    PASS; memory architecture PASS at 56/60 lines; all six current doctrines PASS; `git diff --check` PASS; no
    runtime/source/test/checker/policy/README behavior changed.
  Planned commit: `README-STABILITY-POLICY.0 - plan bounded README adoption`

- ID: `README-STABILITY-POLICY.1`
  Status: `done` (2026-07-29; committed at `ca846e7a` from clean plan commit `adcc89fe`)
  Goal: Adopt the policy, route and trim README content, and mechanically admit the dual-budget doctrine.
  Depends on: `.0`
  Acceptance: Add the repository-owned policy; preserve or route every unique current README fact; produce a
    verified minimal quick start and stable navigation within the frozen caps; add the deterministic checker and
    rejection/acceptance self-tests; register the doctrine and mirror it in enforcement architecture/bootstrap/
    contributor guidance; update affected public and continuity docs; pass focused and canonical signoff; commit,
    clear the brief, remove only exact generated residue, and prove clean.

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — `wc -l -c README.md` recorded the pre-change 1,615-line / 159,437-byte mixed
    landing/status/history/inventory surface; `.0` verified every section's canonical destination before removal.
  - [x] **ROOT CAUSE (WHY + WHERE)** — The `.0` route table and ADR `0063` show duplicate changing detail had
    accumulated in README despite canonical mdBook/roadmap/task/Toolbox/continuity owners. Canonical E4 then
    exposed a second mechanism: six capability contracts/checkers plus two public-surface checkers still treated
    root README status/examples as machine inputs; no parser/runtime defect.
  - [x] **FIX** — Root `README_POLICY.md`, the 105-line / 5,072-byte landing page, executable self-rooted
    `scripts/check_readme_stability.sh`, `README-STABILITY` registry/prose/E1/E4 wiring, and exact initial/future
    cap governance are implemented within this leaf. Capability marker requirements now use their already-
    canonical guide/capability/mdBook owners; root README remains in broad public forbidden-syntax scans but owns
    no volatile capability marker.
  - [x] **ADDRESSED (verified)** — `bash scripts/check_readme_stability.sh` reports README 105/128 lines and
    5,072/6,144 bytes and cap self-tests/stable anchors/routed headings/governance PASS; the exact Lispish quick
    start returns `["hello",["world"]]`; every retained local README link exists.
    Eight affected focused checkers PASS; exact derived current counts are cursor 74/8+0/60, logical 19 docs/12
    forbidden/26 mutations, root 24/17/54, duplicate 21/11/59, aggregate selector 59/25/0, and uniform-binding 51
    scanned/12 anchors/9 historical cards.
  - [x] **NO REGRESSION** — Stage-index initial-ADR proof, all seven doctrines, mdBook, Knowledge Map, memory
    architecture, canonical `bash tools/run_ci_local.sh`, whitespace/path/scope checks, and cleanup are the named
    E4 oracles; the canonical rerun independently verifies the claim before commit.
  - [x] **LOCKSTEP** — Policy/README/checker/registry/enforcement/bootstrap/Toolbox/local-CI requirement, ADR/KM,
    task/index, roadmaps, public book, changes/notes/live/memory, commit/brief/cleanup are synchronized; focused
    staged-snapshot checks pass and canonical E4 is the final truth test.

  Verification: **PASS 2026-07-29.** The staged commit snapshot passes all seven doctrines, exact README
    105/128-line and 5,072/6,144-byte enforcement plus initial-ADR governance, Knowledge Map 756/6,129, mdBook,
    memory architecture, and the complete canonical local gate. Canonical proof includes MCP 5/5 implementations
    + 6/6 runtimes pending/114, Perl/Rust/Dart/Julia/Lua admission, Rust semantic 1/1 in 82.89 seconds, Dart 1/1,
    Julia 416/416 in 29.3 seconds, rule-local cursor 288 assertions, repository-volume containment, moved-root
    execution, primary CLI 66x2, RAM 74%, and Phase 0 1,031/1,031 in 668 seconds. No parser, runtime, backend,
    MCP, neutral-contract, fixture, primary-CLI, or user-visible language behavior changes.

  Commit: `README-STABILITY-POLICY.1 - adopt bounded README doctrine`

- ID: `README-STABILITY-POLICY.2`
  Status: `done` (2026-07-29; unchanged closeout signoff-complete from clean implementation commit `ca846e7a`;
    awaiting this leaf's closeout commit)
  Goal: Recompose the committed policy, landing page, canonical destinations, and enforcement unchanged; close the
    adoption parent and hand back to the interrupted MCP frontier.
  Depends on: `.1`
  Acceptance: Rerun the exact policy/checker/doctrine/navigation/link/book/canonical chain without cap, README,
    destination, checker, or unrelated behavior movement; prove no unique information was stranded; close the tree;
    commit/clear/clean; resume `FUTURE-PARITY-BACKLOG.10.9.7.1` only from that clean boundary.

  #### Acceptance Checklist

  - [x] **CLEAN COMMITTED BASE / OWNERSHIP** — Implementation commit `ca846e7a` is clean, the brief is zero bytes,
    rendered-book and managed-run residue are absent, and `.2` is active before any closeout or continuity change.
  - [x] **UNCHANGED POLICY / LANDING RECOMPOSITION** — Re-read the committed policy and README; rerun exact cap,
    stable-anchor, retained-link, quick-start, initial/future governance, and all seven doctrine proofs without
    changing caps, content, routes, or checker behavior.
  - [x] **CANONICAL OWNER RECOMPOSITION** — Rerun all eight affected capability/public-surface owners, Knowledge
    Map, memory architecture, mdBook, and canonical local CI; preserve cursor 74/8+0/60, selector 59/25/0, and
    every admitted backend/runtime contract unchanged.
  - [x] **NO REGRESSION / NO STRANDED INFORMATION** — Compare committed `.0` route inventory to the landing page
    and canonical destinations; prove no unique information or user-visible behavior moved and no policy bypass,
    off-volume output, generated residue, or unrelated diff exists.
  - [x] **LOCKSTEP / PARENT CLOSURE** — Close `.2` and parent only after exact proof; synchronize task/index,
    roadmaps, ADR/KM/book/live/continuity, commit through `COMMIT.md`, clear the brief, prove clean, and resume MCP
    `.10.9.7.1` without pushing before cadence 300.

  Verification: **PASS 2026-07-29.** From clean implementation commit `ca846e7a`, Git proves only this owning
    closeout task changed before verification. The committed 105-line / 5,072-byte README, hard 128-line /
    6,144-byte budgets, policy, and checker are unchanged; the exact quick start returns the expected nested JSON;
    all 27 local README links exist; all seven doctrines and eight affected owner checks pass at cursor
    74/8+0/60 and selector 59/25/0; Knowledge Map is 756/6,129; memory is 57/60; and mdBook builds. Canonical CI
    exits 0 with MCP 5/5
    implementations + 6/6 runtimes pending/114, Rust semantic 1/1 in 82.85 seconds, Dart 1/1, Julia 416/416 in
    29.3 seconds, cursor 288, repository containment, moved-root execution, primary CLI 66x2, RAM 64%, and Phase
    0 1,031/1,031 in 663 seconds. No implementation, policy, cap, route, contract, fixture, or behavior moved.

  Commit: `README-STABILITY-POLICY.2 - close bounded README adoption`

- ID: `README-STABILITY-POLICY.3`
  Status: `proposed` (non-blocking; requires director decision)
  Goal: Decide whether LinkedSpec should declare a project-level license and, if so, which license and notice text.
  Depends on: explicit director direction
  Acceptance: Preserve the current truthful README notice until the director chooses terms; never infer licensing
    rights from the licenses of vendored or nested components; after a decision, use a dedicated implementation leaf
    to add the approved root license/notice and synchronize public documentation.

- ID: `README-STABILITY-POLICY.4`
  Status: `active`
  Goal: Deliberately adopt the director-supplied routing-pressure revision without changing README caps or turning
    the external template into an upstream dependency.
  Depends on: `.2`; director priority on 2026-08-09
  Children: `.4.0-.4.2`
  Acceptance: Ratify the project-owned policy revision and exhaustive destination/control model before enforcement;
    implement one repository-rooted data registry plus unconditional checker closure and mutations; recompose the
    committed policy/registry/checker unchanged; preserve the 128-line / 6,144-byte README ceilings, stable landing
    role, root-relative paths, repository-volume data locality, hosted-CI policy, and all language/runtime behavior.

- ID: `README-STABILITY-POLICY.4.0`
  Status: `signoff-complete` (2026-08-09; behavior-free plan from clean `7c2ff407`; intended atomic 173/300,
    no push)
  Goal: Audit every actual README/policy/checker route and freeze exact lifecycle, control, threshold, closure, and
    implementation ownership before policy/checker behavior changes.
  Depends on: `.2`; clean commit `7c2ff407`
  Acceptance: Read the supplied policy revision completely; compare it with LinkedSpec's adopted policy and ADR
    `0063`; inspect the established checker and canonical route owners; inventory direct and transitive reader versus
    author-overflow destinations; measure every controlled surface; identify legacy debt without normalizing it;
    freeze a minimal data schema, validation/mutation design, threshold-increase authority, and `.4.1-.4.2` split.
    Change only task/decision/Knowledge/roadmap/live/public-book planning truth—no policy, checker, README, threshold,
    route registry, source, runtime, fixture, CLI, storage, hosted workflow, or current behavior.
  Verification: **PASS 2026-08-09.** Clean activation/parent/subject proof; full 185-line supplied revision read;
    exact old/new policy comparison; README Markdown/code/command candidate census; Git root-cause of absent
    `test_input/`; direct/grouped measurements; 62 routes, 20 named surface ids, and 32 mutation classes; separate
    debt task owner; and exact no-change diff for README/policy/checker/registry/source/runtime pass. Knowledge is
    795 facts / 6,574 keys; memory is 60/60 lines; task metadata, README 105/128 lines and 5,072/6,144 bytes, all
    seven doctrines, and the 78-file / 14,260-KiB book pass with rendered paragraph inspection. Canonical CI exits
    0 with MCP 5/5 implementations + 6/6 runtimes complete/141, Rust semantic 1/1 in 82.69 seconds, Julia semantic
    416/416 in 32.4 seconds, cursor 288, repository containment/moved-root proof, CLI 66x2, RAM 53%, and Phase 0
    1,031/1,031 in 688 seconds before exact `[ci] local CI gate passed`.
  Commit: `README-STABILITY-POLICY.4.0 - plan routing-pressure closure`

  #### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `7c2ff407` is the clean atomic 172/300 cursor-contract
    handoff, zero-byte brief, valid pointer, fresh Knowledge, absent rendered book, zero managed runs, and this
    task-tree activation is the first mutation.
  - [x] **READ / COMPARE REVISION** — Read the director-supplied revision fully and classify every semantic delta
    from LinkedSpec's project-owned policy and ADR `0063`.
  - [x] **INVENTORY / MEASURE ROUTES** — Derive every path-shaped destination and emitted checker hint; classify
    reader/overflow use, follow transitive routes, measure surfaces, and identify cycles, gaps, or legacy debt.
  - [x] **RATIFY SCHEMA / CONTROLS / MUTATIONS** — Freeze exact data schema, lifecycle/control compatibility,
    thresholds/freshness/identity rules, closure algorithm, mutation corpus, and reviewed-increase authority.
  - [x] **SPLIT / LOCKSTEP / NO BEHAVIOR** — Assign `.4.1` implementation and `.4.2` unchanged closeout; align
    durable/public planning truth without changing policy, checker, registry, README, or executable behavior.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused documentation checks and canonical CI; commit through
    `COMMIT.md`, clear the brief, remove exact generated residue, and prove a clean boundary before `.4.1`.

- ID: `README-STABILITY-POLICY.4.1`
  Status: `pending`
  Goal: Adopt the fenced local policy revision, routed-destination registry, unconditional closure checker, exact
    pressure controls, and mutation corpus under the existing `README-STABILITY` doctrine.
  Depends on: `.4.0`

- ID: `README-STABILITY-POLICY.4.2`
  Status: `pending`
  Goal: Recompose the committed policy, registry, controls, and checker unchanged; close `.4` and hand back to
    `FUTURE-PARITY-BACKLOG.14.3.1.1` only from a clean boundary.
  Depends on: `.4.1`

  ### `README-STABILITY-POLICY.4.0` Ratified Audit and Implementation Contract

  Clean activation evidence 2026-08-09: cursor-transaction decision commit `7c2ff407` has first parent
  `c8fcea6f`, exact subject `FUTURE-PARITY-BACKLOG.14.3.1.0 - ratify cursor transaction contract`, empty
  worktree/index, zero-byte brief, valid activation pointer, fresh Knowledge, absent rendered book, and zero
  managed runs. The first README-revision mutation is task-tree-only and task metadata passes.

  Revision delta 2026-08-09: the supplied 185-line project-neutral policy retains LinkedSpec's original stable
  content contract and dual-cap/review rule, then adds fenced project-local authority/provenance, proof-before-
  relocation, transitive route closure, separate reader versus author-overflow classes, lifecycle-specific pressure
  controls, legacy-debt handling, unconditional resulting-tree checks, and reviewed increases for every routed
  threshold. LinkedSpec adopts those semantics deliberately; it does not copy FSMGen owner names, decisions,
  paths, measurements, health targets, or implementation packages and does not treat the source as an upstream.

  Exact route census 2026-08-09: current README contains 22 unique Markdown destinations—21 root-relative files
  and one exact GitHub Issues HTTPS service—plus 16 repository-layout path markers and two command paths. One
  layout marker, root `test_input/`, is invalid; `.4.1` removes it, leaving 15 valid component markers. The revised
  project policy names 18 exact author destinations across public behavior, direction/task, architecture,
  diagnostics, rationale/facts, history, continuity, and contribution. It also names the policy, route registry,
  checker, doctrine registry, and canonical CI owners. Implementation therefore freezes exactly 62 route records:
  39 README reader routes after stale-path removal, 18 author-overflow routes, and 5 policy/enforcement navigation
  routes. Duplicate markers may target one surface but route ids and `(kind, source, marker)` triples are unique.

  The 20 frozen surface ids are `landing_readme`, `readme_policy`, `public_reference`, `roadmaps`,
  `architecture_state`, `task_index`, `task_evidence`, `decisions`, `knowledge_cards`, `knowledge_map`,
  `diagnostics`, `active_memory`, `live_status`, `change_history`, `engineering_notes`, `contributor_doctrine`,
  `git_history`, `issue_service`, `repository_components`, and `command_paths`. These ids, not prose-family names,
  are the `.4.1` registry join keys; a lifecycle or control change requires explicit task/decision evidence.

  Stale-layout root cause 2026-08-09: `git blame` and `-S` assign absent root `test_input/` solely to original
  adoption commit `ca846e7a`. Neither its parent nor current Git tree contains that directory; current fixtures are
  rooted at `t/` and `tests/`, with Pgen-specific inputs nested under `rgx/subs/pgen/tests/`. No deleted root path
  or later rename exists. `.4.1` corrects README to `t/`, `tests/` and makes route existence mutation-sensitive.

  Surface schema 2026-08-09: `doctrine/readme_stability/routes.jsonl` version 1 contains strict `registry`,
  `surface`, and `route` objects. Registry metadata pins 80/90 warning/rollover percentages and ADR `0063` initial
  authority. Surface objects require id, root-relative target patterns, owner, lifecycle, pressure control,
  verifier, route targets, state, and applicable independent line/byte/per-file/file-count/aggregate limits;
  debt adds immutable baseline plus finite transition owners/deltas. Route objects require id, kind, source path,
  exact marker, source surface, and target surface. Keys are closed by record type; ids, paths, and order are
  deterministic; absolute/home/traversal paths, symbolic-link targets, duplicate coverage, or null required limits
  fail closed.

  Reviewed surface controls 2026-08-09:

  | Surface family | Clean measurement | Initial control selected for `.4.1` |
  | --- | ---: | --- |
  | README | 105 lines / 5,072 bytes | Existing hard 128 / 6,144 bounded snapshot; unchanged. |
  | Policy | 88 lines / 4,156 bytes before revision | Bounded policy, max 256 lines / 24,576 bytes; only stable contract/provenance. |
  | Public reference | 50 files / 33,956 lines / 2,058,834 bytes; largest 4,282 / 290,387 | Membership indexes; max 64 files, 5,000 lines / 524,288 bytes each, 50,000 lines / 4,194,304 bytes total. |
  | Roadmap pair | 2 files / 3,815 lines / 638,608 bytes | Reviewed snapshots; max 4,096 lines / 524,288 bytes each and 6,144 / 1,048,576 total. |
  | Architecture state | 3,466 lines / 364,083 bytes | Reviewed snapshot; max 5,000 lines / 524,288 bytes. |
  | Task index | 3,492 lines / 329,500 bytes | Bounded generated/current index; max 5,000 / 524,288 plus task-metadata freshness. |
  | Task evidence | 85 files / 64,378 lines / 6,204,304 bytes; max 26,979 / 2,720,175 | Max 128 files, 32,000 / 4,194,304 each, 80,000 / 8,388,608 total; warning debt owned by containment `.2`. |
  | Decisions | 66 files / 6,909 lines / 473,214 bytes; max 435 / 32,139 | Indexed collection; max 128 files, 640 / 65,536 each, 12,000 / 2,097,152 total. |
  | Knowledge cards/map | 794 cards / 40,663 lines / 3,281,081 bytes; map 13,672 / 4,571,555 | Cards max 1,024 files, 512 / 65,536 each, 64,000 / 6,291,456 total; map max 20,000 / 8,388,608 plus freshness gate. |
  | Diagnostics | Toolbox + local-CI chapter 2 files / 2,818 lines / 210,835 bytes | Maintained reference; max 2 files, 2,048 / 196,608 each, 4,096 / 393,216 total. |
  | Active memory | `MEMORY.md` 55 / 5,431; architecture 451 / 24,044 | Existing 60-line overwrite pointer plus 512 / 32,768 architecture snapshot. |
  | Live status | 14,769 / 1,262,969 | Immutable debt baseline; finite `.4`/containment transition only, hard 18,000 / 1,572,864; containment `.1`. |
  | Changes | 44,128 / 3,091,199 | Query-first append debt; finite transition only, hard 55,000 / 4,194,304; containment `.3`. |
  | Engineering notes | 21,169 / 2,277,541 | Query-first rolling debt; finite transition only, hard 27,000 / 3,145,728; containment `.3`. |
  | Contributor/doctrine entry | 5 files / 766 lines / 40,339 bytes | Bounded reference set; max 8 files, 640 / 65,536 each, 1,600 / 131,072 total. |
  | Git history / issue service / source and command paths | Query, external HTTPS, 15 components, 2 commands | Archive/query terminal, named external owner, and exact existence/executable terminals; never author sinks unless separately declared. |

  Debt semantics 2026-08-09: baseline measurements never refresh automatically. A debt surface may grow only when
  the staged task evidence names README `.4` or its exact `LIVE-DOCUMENT-PRESSURE-CONTAINMENT` owner and remains
  within its finite transition delta and hard ceiling. Any other growth fails even below the hard cap. Warning at
  80% requires a nonempty owner; rollover at 90% requires the active migration owner. Limit changes require a new
  staged accepted/indexed ADR with exact surface id plus old/new canonical limit objects.

  Checker/mutation split 2026-08-09: `.4.1` adds one core-Perl, dependency-free,
  repository-rooted `scripts/check_readme_routing_pressure.pl`, invoked unconditionally by the existing Bash
  checker after cap/navigation checks. It reads the staged resulting tree when an index exists, rejects controlled
  staged/worktree disagreement, extracts Markdown/code path candidates and exact `route_hint` emissions, validates
  62 routes and transitive acyclic closure across 20 surfaces, measures every surface, runs freshness/identity/
  existence controls, and audits threshold authority. Its exact 32-class self-test covers JSON/type/key/id/order,
  unsafe/missing/symlink targets, missing/duplicate/source-marker routes, reader/overflow drift, emitted-hint gaps,
  undeclared endpoints, cycles, every lifecycle/control mismatch, line/byte/file/aggregate overflow, stale
  generated projection, invalid external authority, frozen-identity drift, debt without owner, unauthorized debt
  growth, unauthorized threshold increase, valid reviewed increase, and resulting-tree disagreement.

  Dependency split 2026-08-09: `.4.1` exclusively changes policy, README stale path, registry, checker, mutation
  proof, doctrine mirrors, task-acceptance path classification, public book, and continuity owners. `.4.2` changes
  no admitted policy/route/control/checker behavior; it recomposes the committed state, closes `.4`, then makes
  `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.0` the next documentation-sustainability leaf before transaction work can
  append to debt surfaces. Root README caps, language/runtime behavior, storage locality, and hosted-CI policy stay
  unchanged throughout.

## Audited README Routing Contract

Baseline: `README.md` is 1,615 lines / 159,437 bytes. The adoption prototype is 105 lines / 5,072 bytes and its
Perl quick start returns the exact expected JSON. The retained/routed section classes are:

| Current README class | Stable landing-page residue | Canonical owner for changing/deep detail |
| --- | --- | --- |
| Current design frontier and milestone history | None; link to status owners | `ROADMAP.md`, `ROADMAP_V2.md`, `docs/tasks/`, `CHANGES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, mdBook project status |
| Machine-checked capability status/markers | None; stable links only | Neutral contracts, `capability_conformance/README.md`, `USER_GUIDE.md`, backend READMEs, mdBook status/API/DSL/local-CI chapters, Knowledge cards |
| Repository relocation invariant | One concise invariant and navigation link | ADR `0052`, `REPO-ROOT-PATH-PORTABILITY`, relocation Knowledge card, mdBook local CI |
| Project-data locality and same-volume storage | One concise invariant and navigation link | ADR `0053`, `PROJECT-DATA-SSD-ROOTING`, storage Knowledge cards, mdBook local CI |
| Documentation layers | Compact canonical navigation | `MEMORY_ARCHITECTURE.md`, `docs/TASK_TREE.md`, `docs/decisions/INDEX.md`, `KNOWLEDGE_MAP.md`, `DOCTRINE_ENFORCEMENT.md`, mdBook documentation workflow |
| Project objective and feature catalog | Concise purpose/audience plus recursion, cursor, capture, and staging differentiators | mdBook overview/user model/DSL, `USER_GUIDE.md`, architecture and capability records |
| Fast ramp-up map | Minimal first-use and contributor links | `AGENTS.md`, `SESSION_BOOTSTRAP.md`, `TOOLBOX.md`, mdBook summary |
| Exhaustive project file/path map | Short top-level repository layout | `ARCHITECTURE_STATE.md`, mdBook, backend READMEs, repository owner trees |
| Local-CI gate inventory | One canonical command and authority sentence | `TOOLBOX.md`, mdBook local-CI chapter, backend READMEs |
| README maintenance policy | One link | Root `README_POLICY.md` (normative after `.1`) and ADR `0063` |
| Git/session status instructions | Short contribution/support links | `COMMIT.md`, `AGENTS.md`, `SESSION_BOOTSTRAP.md`, task tree and changelog |
| License/notices | Accurate current no-project-license notice | Proposed `.3` for director decision; nested/vendor license files retain their own terms |

No current class lacks a destination. Historical statements remain recoverable from `CHANGES.md`, task trees,
decision records, and git; they do not need a second current-facing copy in README.

## Frozen Budget and Enforcement Design

- ADR `0063` fixes hard maxima at **128 lines** and **6,144 bytes**, leaving 23 lines / 1,072 bytes above the
  reviewed prototype (about 22% / 21% headroom).
- Root `README_POLICY.md` owns unique machine-readable cap lines and routing rules. `README.md` links to it.
- `scripts/check_readme_stability.sh` self-roots, reads without mutation, enforces both caps, required stable
  headings/links, and forbidden status/history/inventory heading classes, and prints the correct destination class
  on failure.
- Inline repository-local self-tests admit exact caps and reject line-only, byte-only, and combined overflow.
  No OS-temp or home data is used.
- Doctrine ID `README-STABILITY` is registered once in `scripts/check_doctrines.sh` and mirrored in
  `DOCTRINE_ENFORCEMENT.md`; the registry already runs in pre-commit and canonical local CI.
- A staged cap increase relative to `HEAD` requires a newly staged, indexed ADR naming the old/new values and
  stable responsibility. Initial adoption requires ADR `0063`; ordinary feature work routes elsewhere.
- `.1` exclusively owns policy/README/checker/doctrine/bootstrap/book/live-doc implementation and canonical
  admission. `.2` changes no admitted content or behavior; it recomposes committed owners and closes the critical
  adoption path. Proposed licensing leaf `.3` is independent and requires director direction.

## Closure State

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `README-STABILITY-POLICY.0` | `done` | Lossless routing, measured budgets, doctrine design, and implementation seams are frozen in ADR `0063`. |
| 2 | `README-STABILITY-POLICY.1` | `done` | Canonical implementation is committed at clean `ca846e7a`; brief and exact residue are cleared. |
| 3 | `README-STABILITY-POLICY.2` | `done` | Unchanged canonical recomposition passes; closeout awaits its per-leaf commit. |
| — | `README-STABILITY-POLICY.3` | `proposed` | Separate director decision; it does not block bounded-README adoption or MCP handback. |

## Decisions

- `2026-07-29`: Adopt the external policy's principles, but keep the normative copy and every persisted path in
  LinkedSpec. The external FSMGen file is a read-only template, not a runtime or documentation dependency.
- `2026-07-29`: Treat README stability as a doctrine. Per `DOCTRINE_ENFORCEMENT.md`, adoption requires a check and
  one registry line; the existing registry already supplies pre-commit and local-CI execution.
- `2026-07-29`: Split audit, implementation/admission, and unchanged closeout so a 1,615-line / 159,437-byte README
  is never truncated before unique information has a verified destination.
- `2026-07-29`: The repository has licenses for nested/vendor components but no declared project-level root license.
  Track that governance question in `.3`; adoption states the current truth and does not invent terms.
- `2026-07-29`: Accept ADR `0063`: a 105-line / 5,072-byte lossless prototype supports hard ceilings of 128 lines
  and 6,144 bytes. Any increase requires a new accepted, indexed ADR and cannot be ordinary feature work.
- `2026-07-29`: Canonical E4 revealed root README was still a machine input for six capability public contracts
  and two surface checkers. Route required current markers to their already-governed canonical documents; keep
  README in broad forbidden-syntax discovery where useful, but never require volatile status/examples from it.
  The resulting exact current cursor and selector inventories are 74 files and 59/25/0; dated 75/27 history stays.

## Open Questions

- None blocking. Leaf `.0` owns the evidence-based cap and routing decisions. Project-level licensing is the
  director-owned, non-blocking `.3` decision.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-29` | `README-STABILITY-POLICY.0` | Clean `c6f36fe3`; external policy 71/71 lines read-only; baseline 1,615/159,437; prototype 105/5,072 and quick start exact; Knowledge Map 756/6,129; mdBook, memory 56/60, six doctrines, whitespace, path scan, and scope checks PASS. | DONE. README/policy/checker behavior unchanged; `.1` follows only after commit/brief-clear/clean proof. |
| `2026-07-29` | `README-STABILITY-POLICY.1` | First E4 run exposed the stale root-marker coupling after seven doctrines/syntax passed. After complete routing, all eight focused owners pass; the canonical rerun passes MCP 5/5 + 6/6 pending/114, Rust semantic 82.89s, Julia 416/416 in 29.3s, cursor 288, containment/moved-root, CLI 66x2, RAM 74%, and Phase 0 1,031/1,031 in 668s. | DONE. Signoff-complete; no runtime semantics changed; implementation commit/brief-clear/clean follows. |
| `2026-07-29` | `README-STABILITY-POLICY.2` | Clean `ca846e7a`; README/policy/checker unchanged; quick start exact; 27/27 local links; seven doctrines; eight owners; KM 756/6,129; memory 57/60; mdBook; canonical MCP 5/5 + 6/6 pending/114, Rust 82.85s, Julia 416/416 in 29.3s, cursor 288, containment/moved-root, CLI 66x2, RAM 64%, Phase 0 1,031/1,031 in 663s. | DONE. Parent closed unchanged; closeout commit/brief-clear/clean then MCP `.10.9.7.1`. |
| `2026-08-09` | `README-STABILITY-POLICY.4.0` | Clean `7c2ff407`; 185-line revision; 62 routes / 20 surface ids / 32 mutations; stale-path Git root cause; four debt baselines and new owner; README/policy/checker unchanged; KM 795/6,574; memory 60/60; book 78/14,260 KiB; seven doctrines; canonical MCP 5/5 + 6/6 complete/141, Rust semantic 82.69s, Julia 416/416 in 32.4s, cursor 288, containment/moved-root, CLI 66x2, RAM 53%, Phase 0 1,031/1,031 in 688s. | DONE. Behavior-free plan is signoff-complete; atomic commit/brief-clear/clean precedes `.4.1`. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `README-STABILITY-POLICY.0` | `README-STABILITY-POLICY.0 - plan bounded README adoption` | Behavior-free adoption plan; commit hash recorded by git history. |
| `README-STABILITY-POLICY.1` | `ca846e7a` — `README-STABILITY-POLICY.1 - adopt bounded README doctrine` | Policy, trim, checker, doctrine, and canonical lockstep. |
| `README-STABILITY-POLICY.2` | `README-STABILITY-POLICY.2 - close bounded README adoption` | Unchanged closeout and MCP handback. |
| `README-STABILITY-POLICY.3` | `proposed` | Project-level license decision; not part of the adoption critical path. |
| `README-STABILITY-POLICY.4.0` | `README-STABILITY-POLICY.4.0 - plan routing-pressure closure` | Behavior-free route/control audit and implementation plan; hash supplied by Git history after landing. |

## Changelog

- `2026-07-29`: Created the task tree first from clean commit `c6f36fe3`; recorded full external-policy read and
  measured README baseline before any LinkedSpec policy, README, checker, or documentation mutation.
- `2026-07-29`: Recorded the absence of a project-level root license as proposed leaf `.3`; nested/vendor licenses
  are not authority to choose LinkedSpec's license.
- `2026-07-29`: Completed `.0`: lossless route table, ADR `0063`, 128-line / 6,144-byte enforcement design,
  implementation/closeout split, public-book explanation, Knowledge fact/map, continuity alignment, and focused
  signoff are complete without changing README or executable behavior.
- `2026-07-29`: Activated `.1` only after plan commit `adcc89fe`, zero-byte brief, absent rendered/prototype
  residue, and clean worktree proof.
- `2026-07-29`: Canonical gate found the old README was an executable status-marker owner. Root-caused and routed
  all such requirements to canonical public owners, preserved broad forbidden-syntax scans, updated exact derived
  inventories, and passed every affected focused checker before the canonical rerun.
- `2026-07-29`: Completed `.1` signoff: the full staged-snapshot canonical rerun exits 0 through all seven
  doctrines, six-runtime MCP admission, semantic/cursor/storage/relocation proof, primary CLI 66x2, and Phase 0
  1,031/1,031. The leaf is ready for its per-slice commit; `.2` remains dependency-ordered behind clean handoff.
- `2026-07-29`: Committed `.1` at `ca846e7a`, cleared the brief, removed exact empty managed-run residue, proved
  the tree clean, and activated unchanged closeout `.2` task-tree-first from that boundary.
- `2026-07-29`: Completed `.2` and closed the adoption parent after byte-unchanged policy/README/checker proof,
  27/27 retained links, exact quick start, all seven doctrines/eight public owners, mdBook/KM/memory, and full
  canonical signoff. MCP `.10.9.7.1` resumes only after closeout commit/brief-clear/clean.
- `2026-08-09`: Activated `.4.0` from clean `7c2ff407`, read the complete supplied revision, froze the exact local
  route/control/debt contract, opened the separate containment owner, and root-caused stale root `test_input/`.
  Focused checks and canonical CI pass without changing README, policy, checker, registry, or executable behavior;
  `.4.1` remains dependency-ordered behind atomic commit, brief clearing, and clean proof.
