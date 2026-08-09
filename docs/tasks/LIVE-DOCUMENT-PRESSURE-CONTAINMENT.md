# LIVE-DOCUMENT-PRESSURE-CONTAINMENT: Bounded Views over Durable Documentation

## Metadata

- Tree ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`
- Status: `active` / audit-and-descriptor leaf `.0` active
- Roadmap lane: `Repository architecture / documentation sustainability`
- Created: `2026-08-09`
- Last updated: `2026-08-09` (`.0` activated task-tree-first from clean README closeout `0bcb5a36`; intended
  atomic 176/300; consumer-aware descriptor contract accepted; no content migration or push)
- Owner: repo-local workflow

## Goal

Resolve the measured destination-pressure debt exposed by README routing closure. Preserve exact history and
maintained reference material while replacing oversized neighboring sinks with bounded current views,
query-first history, navigable partitions, and mechanically controlled aggregate stores.

## Non-Goals

- Do not delete unique information, historical evidence, task acceptance data, or user-facing reference prose.
- Do not hide maintained user documentation only in Git history when it still needs direct navigation.
- Do not treat sharding alone as containment; every collection needs per-part, file-count, and aggregate controls.
- Do not change language, compiler, runtime, backend, fixture, CLI, protocol, storage-root, or hosted-CI behavior.
- Do not activate a migration while `README-STABILITY-POLICY.4` is dirty or before its closure checker lands;
  clean closeout `0bcb5a36` satisfies this dependency.

## Measured Intake

Clean activation commit `7c2ff407` exposes four routed families whose baseline is durable evidence of debt, not a
healthy default:

| Surface | Clean measurement | Why it needs a bounded-view owner |
| --- | ---: | --- |
| `LIVE_ACHIEVEMENT_STATUS.md` | 14,769 lines / 1,262,969 bytes | A current-facing status surface has accumulated chronology and is already above the planned 80% warning boundary. |
| `docs/tasks/` | 85 files / 64,378 lines / 6,204,304 bytes; largest part 26,979 lines / 2,720,175 bytes | The collection is partitioned, but one active history-bearing part is itself an oversized neighboring sink. |
| `CHANGES.md` | 44,128 lines / 3,091,199 bytes | Append-only exact history needs query-first access plus a shard/rotation threshold. |
| `DEVELOPMENT_NOTES.md` | 21,169 lines / 2,277,541 bytes | The engineering ledger needs a bounded current index/hot shard and preserved historical partitions. |

The routing-pressure registry may declare finite implementation-transition headroom, but ordinary feature work
must not refresh these baselines or use that headroom. Growth is authorized only for the owning containment leaf
or the README `.4` adoption/closeout that installs the guard.

## Acceptance Criteria

- Every migration begins from a clean task-tree-owned leaf and records exact pre/post path, count, line, byte, and
  digest evidence.
- Current/live state becomes a genuinely bounded view with overwrite, review, or staleness semantics.
- Historical ledgers retain exact ordered retrieval through root-relative indexes and Git-compatible query proof.
- Task evidence remains addressable by stable leaf id after semantic partitioning; the central index stays bounded
  and task metadata gates still operate over every canonical node.
- All archives/parts stay tracked and repository-relative; generated/disposable indexes remain reproducible and
  cannot own unique facts.
- The README pressure registry ratchets each migrated surface from debt/transition state to a reviewed normal state.
- Public book, roadmaps, task index, decisions, Knowledge, continuity docs, and commit workflow remain lockstep.
- Each leaf passes focused checks plus the canonical gate when warranted and lands as an atomic commit before the
  next migration.

## Task Tree

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`
  Status: `active` (2026-08-09; clean README dependency closed at `0bcb5a36`; planning `.0` active)
  Goal: Replace measured oversized routed destinations with bounded views over durable stores.
  Depends on: `README-STABILITY-POLICY.4.2`
  Children: `.0-.4`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.0`
  Status: `done` (2026-08-09; committed atomically at `dc8dd896` as 176/300; brief cleared; clean proof passed;
    no push)
  Goal: Reverify the committed route registry, audit semantic retrieval obligations for all four debt families,
    and freeze exact archive/partition descriptors plus migration order without moving content.
  Depends on: `README-STABILITY-POLICY.4.2`
  Acceptance: Prove clean activation and dependency closure; use the committed pressure checker and repository
    queries to remeasure the immutable baseline/current state and semantic retrieval contracts of all four debt
    families; freeze exact descriptor schemas, stable identities, archive/index/current-view topology, retrieval
    commands, migration ordering, failure/rollback proof, registry ratchets, and `.1-.4` ownership without moving
    content; align durable/public planning truth; pass focused and canonical signoff; commit and prove clean.

  #### Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Commit `0bcb5a36` is clean at 175/300 with exact parent/subject,
    zero-byte brief, valid memory/Knowledge, absent rendered book, zero managed runs, and this task-only first diff.
  - [x] **REVERIFY / CLASSIFY ALL FOUR DEBTS** — Reproduce clean registry baselines and current counts/digests for
    live status, task evidence, changes, and engineering notes; classify what is current view, ordered history,
    maintained reference, machine input, stable identity, and Git-only recovery evidence.
  - [x] **RETRIEVAL / CONSUMER AUDIT** — Inventory every repository/public/checker/book/agent consumer that depends
    on paths, headings, order, anchors, task ids, metadata, or append behavior; freeze compatibility obligations.
  - [x] **DESCRIPTOR / TOPOLOGY CONTRACT** — Define exact root-relative descriptor fields, stable range identities,
    digests/counts, current replacements, archive/index topology, query commands, freshness, and non-loss proof.
  - [x] **MIGRATION / ROLLBACK ORDER** — Dependency-order `.1-.4`, exact pre/post verification, copy/verify/use/delete
    where applicable, rollback boundaries, registry state/limit ratchets, and mutation/failure oracles.
  - [x] **LOCKSTEP / NO CONTENT MOVE** — Align task/index, roadmaps, ADR/Knowledge, architecture, continuity, and
    sole-facing mdBook without moving or rewriting debt-family content or changing language/runtime behavior.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused query/metadata/routing/book/Knowledge/memory/doctrine
    checks and canonical CI; commit through `COMMIT.md`, clear the brief, remove exact residue, and prove clean.

  #### TOOLBOX Task-Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Committed README route report identifies four debt surfaces and exact controls.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Tool-assisted consumer/retrieval audit explains why each live surface grew
    and which semantics prevent a mechanical split.
  - [x] **FIX** — Freeze migration descriptors and dependency order only; implementation belongs to `.1-.4`.
  - [x] **ADDRESSED (verified)** — Named queries prove every unique fact/identity/order/consumer has a destination.
  - [x] **NO REGRESSION** — No debt-family content, registry control, checker, source, test, or runtime behavior moves.
  - [x] **LOCKSTEP** — Plan, public book, continuity, atomic commit, brief, cleanup, and next-owner handoff align.

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1`
  Status: `active / signoff-complete pending atomic commit` (2026-08-09; activated task-tree-first from clean
    descriptor commit `dc8dd896`; intended atomic 177/300; no push)
  Goal: Convert `LIVE_ACHIEVEMENT_STATUS.md` into a bounded current view while preserving its exact historical
    chronology in indexed repository-relative durable partitions and Git history.
  Depends on: `.0`
  Acceptance: Decouple every executable current-state assertion from live chronology before shrinking it; archive
    the exact clean `dc8dd896` live-status blob into strict schema-v1 root-relative segments and manifest; install
    deterministic query/reconstruction and mutation-checked doctrine enforcement; replace the stable root with the
    five-section bounded current view; update the commit workflow and public/live architecture; ratchet routing
    through a newly staged execution ADR; pass focused and canonical signoff; commit, clear, remove exact residue,
    and prove clean before `.2`.

  #### Acceptance Checklist

  - [x] **CLEAN BASE / TASK-FIRST ACTIVATION** — Descriptor commit `dc8dd896` has parent `0bcb5a36`, exact `.0`
    subject, zero-byte brief, fresh 797/6,590 Knowledge Map, absent rendered book, zero managed runs, and empty
    index/worktree; this task file is the sole first `.1` mutation.
  - [x] **CURRENT-AUTHORITY DECOUPLING** — Remove all seven capability/public-closeout required-marker and stale-
    claim dependencies on `LIVE_ACHIEVEMENT_STATUS.md`; route current assertions to governed contracts, ADRs,
    Knowledge/task/roadmap/architecture/book owners, and mutation-lock zero residual live-history authority.
  - [x] **EXACT HISTORY STORE / QUERY** — Snapshot `dc8dd896:LIVE_ACHIEVEMENT_STATUS.md` byte-for-byte into greedy
    line-preserving <=4,096-line / 524,288-byte immutable repository segments, a strict schema-v1 JSONL manifest,
    and `perl tools/read_document_history.pl` source/query/reconstruction modes with root-safe path handling.
  - [x] **BOUNDED CURRENT VIEW / ROUTE TRANSITION** — Replace only the stable live root with five fixed sections,
    at most sixteen recent rows, and <=256 lines / 32 KiB; add a staged execution ADR and ratchet the routing
    registry/checker to indexed history plus bounded-current controls without refreshing the debt baseline.
  - [x] **DOCTRINE / MUTATION / FAILURE PROOF** — Register strict document-history enforcement and reject schema,
    order, identity, path, symlink, gap/overlap, count/hash/blob/reconstruction, immutable-segment, current-view,
    marker-authority, limit, and transition-governance mutations with deterministic diagnostics.
  - [x] **LOCKSTEP / NO LANGUAGE REGRESSION** — Align COMMIT/bootstrap/toolbox/architecture/task/roadmap/Knowledge,
    changes/notes/live/memory, and sole-facing mdBook; preserve parser/compiler/runtime/backend/MCP/CLI/fixture/
    schema/language behavior and leave future-task plus changes/notes migrations to `.2-.3`.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass exact reconstruction/query/current-view/consumer/mutation/routing,
    task/memory/Knowledge/doctrine/book checks and definitive canonical CI; commit atomically as 177/300, clear the
    brief, remove exact generated residue, and prove clean before `.2`.

  Implementation evidence: `dc8dd896:LIVE_ACHIEVEMENT_STATUS.md` is 14,872 lines / 1,271,326 bytes, blob
  `221159c6e15bdf1505186b3714c4b5c5848df889`, SHA-256
  `683ef70df66c64e5f195c8bfe0e70f9561a13ed61ef4b1686a73a41ae35a9d55`. Greedy segments are 4,096 / 4,096 /
  4,096 / 2,584 lines and their `--all` query hashes identically to the clean Git source. The new root is 36 lines
  and has the exact six-heading title/section sequence. Six JSON files plus seven executable checkers now name
  ADR `0067`; a complete repository scan under those scopes finds zero live-status authority.

  Focused evidence: document history passes 20/20 mutation classes and 1 surface / 4 segments; callable remains
  23 governance mutations, capability 80/0/0 + 24/6, duplicate 21 documents / 59 mutations, logical 19/26,
  repeated 54, root 24/54, and cursor 28/60. The staged route report passes 44 reader + 18 author routes, all 20
  surfaces, 32/32 mutations, and current/bounded `live_status` at 6 files / 14,913 lines / 1,276,086 bytes. mdBook
  builds and generated HTML shows the history heading, three-command block, current status, and doctrine text as
  separate rendered blocks; output and the exact empty managed run are removed. All eight doctrines pass. The
  definitive repository-volume canonical gate exits 0 with MCP complete/141, Rust semantic admission 1/1 in
  81.92 seconds, Julia semantic admission 416/416 in 31.5 seconds, cursor 288, containment and moved-root proof,
  CLI 66/66 in both option environments, RAM 25%, and Phase 0 1,031/1,031 in 685 seconds.

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2`
  Status: `pending`
  Goal: Partition the oversized `FUTURE-PARITY-BACKLOG` task evidence by stable semantic ranges without changing
    node ids, frontier truth, acceptance evidence, or central task metadata enforcement.
  Depends on: `.0`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`
  Status: `pending`
  Goal: Give `CHANGES.md` and `DEVELOPMENT_NOTES.md` bounded current indexes/hot shards, ordered archive manifests,
    query-first retrieval, and finite rollover thresholds without losing history.
  Depends on: `.0`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4`
  Status: `pending`
  Goal: Ratchet all four registry surfaces to normal, recompose retrieval and pressure controls unchanged, close
    the program, and return to the prior product frontier from a clean boundary.
  Depends on: `.1-.3`

## Current Frontier

`.0` landed clean at `dc8dd896` as atomic 176/300. `.1` is signoff-complete and remains the only active/eligible
leaf through its intended atomic 177/300 commit, brief clearing, residue check, and clean proof. `.2-.4` remain
pending; no pivot is permitted from the dirty `.1` worktree.

## Decisions

- Exact history is durable data; containment changes its live projection and retrieval topology, not its truth.
- The README routing registry's clean baselines are immutable. Transition allowances name owners and finite deltas
  instead of silently redefining the current high-water mark after every append.
- An archive descriptor must name the source/range, immutable revision locator, line/byte counts, digest, current
  replacement, and a repository-rooted retrieval command before working-tree content can move.
- ADR `0066` freezes one schema-v1 document-history manifest per chronological family, one bounded live root per
  stable path, exact byte reconstruction from a clean Git source, and semantic rather than chronological task
  partitioning. Execution-time route-contract changes still require newly added staged ADRs because the registry
  correctly refuses to treat this already-committed planning authority as a later mutation permit.

## Reverification And Classification

The committed route registry still reports the immutable clean `7c2ff407` baselines. From activation commit
`0bcb5a36`, the exact current files are:

| Surface | Current lines / bytes | SHA-256 | Classification |
| --- | ---: | --- | --- |
| `LIVE_ACHIEVEMENT_STATUS.md` | 14,844 / 1,269,091 | `c13abe0052f8f43730cb9c7ed71311558ee5de02a2f883bf90c2590f113f1994` | Hot/current intent plus accumulated newest-first chronology and machine-required closeout markers. |
| `CHANGES.md` | 44,193 / 3,097,056 | `c19ba672c1fc445d60d92b9afc3520e95fd81f94e404cd57c8de714ec0a58b06` | Ordered newest-first technical history; exact path is an author/reader entry point, not a machine content oracle. |
| `DEVELOPMENT_NOTES.md` | 21,220 / 2,282,687 | `2735b56d46ed81810339eba2f6f7c6e6459f81cf70347c2245ee9c5a97cbe0f5` | Ordered newest-first rationale ledger with dated records and older maintained sections. |
| `docs/tasks/FUTURE-PARITY-BACKLOG.md` | 26,979 / 2,720,175 | `48de44a56bcde1ae6d5e274e2786d939b596d2063756f994d4cfb407be4b3f95` | Mutable canonical node evidence, current and superseded frontier prose, global decisions, and legacy verification/commit/changelog history. |

The current task collection before this leaf's edits is 86 files / 64,751 lines / 6,236,424 bytes. Its next
largest members are `SPEC-FORMAT-TERSE.md` at 6,981 lines / 791,991 bytes and `LUA-BACKEND-PARITY.md` at 5,304 /
477,656, proving an 8,000-line / 1-MiB global ratchet is feasible once the 26,979-line outlier is partitioned.
Git remains a recovery backstop, but maintained task identities and directly queryable chronology stay tracked.

## Consumer And Retrieval Audit

### Live achievement status

Seven public-closeout families treat the live chronology as a required-marker authority: callable codeblocks,
logical helpers, root selection, duplicate regex-slot identity, repeated-action results, rule-local cursors, and
capability exclusions. The dependencies are declared in six `capability_conformance/*.json` files plus
`tools/check_capability_conformance.pl`, and are duplicated by their Python contract checkers. A stale-claim
denial in the repeated-action contract also reads the live file. `.1` must move required current assertions to
the already governed contract/ADR/Knowledge/task-index/architecture/roadmap/mdBook owners and mutation-lock the
absence of live-history authority before shrinking the root. The historical archive is positive evidence, never
a current-state denial surface.

### Future-parity task evidence

`tools/check_capability_conformance.pl`, `tools/check_repeated_action_result_contract.py`,
`tools/check_root_rule_selection_contract.py`, and `tools/check_semantic_introspection_contract.py` read the exact
monolith and require nodes/statuses/checklist headings for `.9.1.1.2*`, `.9.1.10*`, `.10.2`, `.10.10`, and `.24*`.
`repeated_action_result_contract.json` and `semantic_introspection_contract.json` also name the exact path. The
stable root path must remain navigable, but `.2` changes these consumers to the exact semantic part or governed
ID lookup; it may not duplicate node blocks into a compatibility summary. `scripts/check_task_tree_metadata.sh`
already expands `docs/tasks/*.md`, so strengthening uniqueness, part-manifest, and frontier checks composes its
existing scope.

### Changes and engineering notes

`t/phase0_regression.t` includes the three root paths only in repository-root portability discovery and does not
parse their content. The routing checker measures them. Remaining references are author/reader doctrine or prose,
so `.3` may preserve the exact roots as bounded hot shards and route historical reading through manifests without
breaking an executable content contract. `COMMIT.md` is the causal append owner: it currently calls changes
“cumulative and not reset” and asks every slice to add entries to all three live documents. `.1` and `.3` must
rewrite those instructions to bounded current/rollover semantics.

## Frozen Descriptor And Topology Contract

ADR `0066` is normative. Chronology manifests live beside repository-volume segments under
`docs/history/{live-achievement-status,changes,development-notes}/`. Each source-order record fixes source path,
40-hex clean commit, whole-file Git blob, exact line range/count, bytes, SHA-256, target path, current replacement,
and a root-relative `perl tools/read_document_history.pl` command. Segments are greedy line-preserving slices of
at most 4,096 lines / 524,288 bytes; concatenation must equal `git show <commit>:<path>` byte-for-byte.

The live root becomes a 256-line / 32-KiB overwrite view with five fixed sections and sixteen recent one-line
rows. Changes and notes become 512-line / 64-KiB hot shards; 80% warns, 90% atomically moves oldest complete
records until the root is at most 50%. Their initial snapshots archive the whole pre-migration source.

The future root retains only metadata, authoritative frontier, current global state, part navigation, and lookup.
Seven semantic parts own `.0-.8`, `.9`, `.10.0-.6`, `.10.7-.10`, `.11-.13`, `.14`, and `.15-.24`; one immutable
history part owns superseded frontier plus legacy global logs. The exact clean structural intake is 351 root
lines, 3,340 legacy-history lines, 3,108 / 3,596 / 4,188 / 4,139 / 2,016 / 3,952 / 1,804 node lines, and 485
late ID-scoped evidence lines routed to `.1` or `.5`. A strict JSONL index fixes range identity and current
digests. Every part stays below 5,000 lines / 786,432 bytes; the collection ratchets globally to 8,000 lines /
1 MiB per file while retaining 128 files / 80,000 lines / 8 MiB aggregate.

## Migration, Failure, And Rollback Contract

1. `.1`: from clean `.0`, decouple all live capability assertions; add the root-derived query, strict document-
   history checker, registered doctrine, initial exact live snapshot, bounded current view, and a newly staged
   indexed route-transition ADR. Verify reconstruction and all affected capability/public mutations before the
   root rewrite commits.
2. `.2`: from clean `.1`, add the task index/lookup and semantic parts; strengthen metadata uniqueness/frontier/
   range/digest oracles; reroute six direct machine consumers; archive legacy global logs; ratchet the task route
   through its own newly staged ADR.
3. `.3`: from clean `.2`, snapshot changes and notes, install bounded hot shards/rollover/query, align
   `COMMIT.md`/bootstrap/task doctrine, and ratchet both route contracts through one newly staged execution ADR.
4. `.4`: independently recompose every committed checker/store/consumer, repeat complete retrieval and registry
   mutations, close debt state, and return to `FUTURE-PARITY-BACKLOG.14.3.1.1` only after a clean commit.

Mutations reject missing/reordered/duplicate descriptors, gap/overlap/count/hash/blob drift, unsafe paths,
symlinks, oversize/stale current views, source reconstruction failure, missing/duplicate/wrong-range task IDs,
uncovered or stale parts, broken frontier lookup, and residual old-monolith authority. Before commit, the clean
activation commit is rollback authority; after commit, only an explicit revert of the atomic migration is valid.
All files and transient proof stay on the repository filesystem; no off-volume copy/delete workflow applies.

## Open Questions

- None. Exact archive boundaries are intentionally computed from each migration's clean activation source so
  `.0` does not falsely predeclare hashes for continuity entries that must land before `.1` or `.3`.

## Blockers

- None. `.1` activated task-tree-first from verified clean `dc8dd896`.

## Verification Log

Planning evidence: clean activation `0bcb5a36`; route report 20 surfaces / 62 routes / 32/32 mutations; exact
four-file line/byte/SHA-256 census; 121 / 117 / 75 / 132 repository-reference counts; seven live required-marker
families; four executable plus two JSON future-task consumers; 25 top-level future-node boundaries; exact
semantic range sizing; task metadata parser and commit-workflow owner audit. Focused signoff passes whitespace,
task metadata, memory architecture at 58/60 lines, Knowledge Map at 797 facts / 6,590 keys, route closure at 20
surfaces / 62 routes / 32/32 mutations, all seven doctrines, mdBook build, and direct generated-HTML block/anchor
inspection. The definitive repository-volume canonical rerun exits 0 after MCP 5/5 implementations + 6/6
runtimes complete/141, Rust semantic admission in 82.47 seconds, Julia semantic 416/416 in 31.0 seconds, cursor
288, project-data process containment, moved-root execution, primary CLI 66/66 in both option environments, RAM
66%, and Phase 0 1,031/1,031 in 710 seconds. No optional matrix is claimed.

Live-history implementation signoff: exact reconstruction/query/current-view and 20/20 history mutations pass;
all seven transferred capability consumers preserve their admitted cardinalities; staged routing passes 20
surfaces / 62 routes / 32/32 mutations with bounded `live_status`; task, memory, Knowledge, book, and all eight
doctrines pass. The definitive repository-volume canonical gate exits 0 after MCP complete/141, Rust semantic
admission 1/1 in 81.92 seconds, Julia semantic admission 416/416 in 31.5 seconds, cursor 288, project-data process
containment, moved-root execution, CLI 66/66 in both option environments, RAM 25%, and Phase 0 1,031/1,031 in 685
seconds. Optional matrices remain explicitly unclaimed.

## Commit Log

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.0 - freeze bounded document store contract` — `dc8dd896`, atomic 176/300.

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1 - bound live status over exact history` — intended atomic 177/300;
commit pending.

## Changelog

- `2026-08-09`: Opened from the director-priority README routing-pressure audit. Recorded exact clean measurements
  and owners before policy/checker enforcement or any content migration.
- `2026-08-09`: README routing-pressure implementation/closeout commits `5c570719`/`0bcb5a36`; brief clearing,
  memory/Knowledge, absent book, zero managed runs, and clean cadence 175/300 pass. Activated `.0` task-tree-first;
  descriptor/retrieval audit follows without moving content.
- `2026-08-09`: `.0` tool-assisted audit finds real machine coupling in live status and the future task monolith,
  freezes ADR `0066` manifest/topology/query/limit/mutation/rollback contracts, and routes `.1-.4` without moving
  any debt-family content or changing language/runtime behavior.
- `2026-08-09`: Focused routing/task/memory/Knowledge/doctrine/book proof and the definitive repository-volume
  canonical gate pass; canonical evidence includes containment, moved-root execution, CLI 66x2, RAM 66%, and
  Phase 0 1,031/1,031 in 710 seconds. Atomic commit/brief/clean proof remain the final workflow actions.
- `2026-08-09`: `.0` lands at `dc8dd896` with exact parent/subject, hook/doctrine/post-pointer proof, zero-byte
  brief, fresh memory/Knowledge, absent book, empty managed runs, and clean cadence 176/300. Activated `.1` as the
  sole first mutation for live consumer/history/current-view migration.
- `2026-08-09`: `.1` preserves the exact clean chronology in four immutable segments, transfers all thirteen
  capability consumers to ADR `0067`, installs query/doctrine enforcement, and ratchets `live_status` from debt to
  bounded current. Focused, book, eight-doctrine, and canonical proof pass; atomic commit/clean proof remain.
