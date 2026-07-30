# README-STABILITY-POLICY: Stable Landing Page and Mechanical Growth Guard

## Metadata

- Tree ID: `README-STABILITY-POLICY`
- Status: `active`
- Roadmap lane: `Repository architecture / documentation sustainability`
- Created: `2026-07-29`
- Last updated: `2026-07-29`
- Owner: repo-local workflow

## Goal

Adopt the director-approved project-neutral README stability policy as a repository-owned LinkedSpec doctrine:
turn `README.md` into a concise stable landing page, route changing detail to canonical homes, and enforce reviewed
line/byte budgets through the existing doctrine registry, pre-commit hook, and canonical local CI gate.

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
- Each completed leaf is committed through `COMMIT.md`; no push occurs before cadence 300.

## Task Tree

- ID: `README-STABILITY-POLICY`
  Status: `active`
  Goal: Adopt and mechanically enforce a stable, bounded LinkedSpec repository landing page.
  Children: `.0`, `.1`, `.2`, `.3`

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
  Status: `done` (2026-07-29; signoff-complete from clean plan commit `adcc89fe`; awaiting this leaf's
    implementation commit)
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
  Status: `pending`
  Goal: Recompose the committed policy, landing page, canonical destinations, and enforcement unchanged; close the
    adoption parent and hand back to the interrupted MCP frontier.
  Depends on: `.1`
  Acceptance: Rerun the exact policy/checker/doctrine/navigation/link/book/canonical chain without cap, README,
    destination, checker, or unrelated behavior movement; prove no unique information was stranded; close the tree;
    commit/clear/clean; resume `FUTURE-PARITY-BACKLOG.10.9.7.1` only from that clean boundary.

- ID: `README-STABILITY-POLICY.3`
  Status: `proposed` (non-blocking; requires director decision)
  Goal: Decide whether LinkedSpec should declare a project-level license and, if so, which license and notice text.
  Depends on: explicit director direction
  Acceptance: Preserve the current truthful README notice until the director chooses terms; never infer licensing
    rights from the licenses of vendored or nested components; after a decision, use a dedicated implementation leaf
    to add the approved root license/notice and synchronize public documentation.

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

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `README-STABILITY-POLICY.0` | `done` | Lossless routing, measured budgets, doctrine design, and implementation seams are frozen in ADR `0063`. |
| 2 | `README-STABILITY-POLICY.1` | `done` | Canonical signoff passes from clean `adcc89fe`; implementation awaits its per-leaf commit. |
| 3 | `README-STABILITY-POLICY.2` | `pending` | Next after `.1` commit/brief-clear/clean; re-verifies committed owners and returns the clean frontier to MCP work. |
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

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `README-STABILITY-POLICY.0` | `README-STABILITY-POLICY.0 - plan bounded README adoption` | Behavior-free adoption plan; commit hash recorded by git history. |
| `README-STABILITY-POLICY.1` | `README-STABILITY-POLICY.1 - adopt bounded README doctrine` | Policy, trim, checker, doctrine, and canonical lockstep. |
| `README-STABILITY-POLICY.2` | `pending` | Unchanged closeout and MCP handback. |
| `README-STABILITY-POLICY.3` | `proposed` | Project-level license decision; not part of the adoption critical path. |

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
