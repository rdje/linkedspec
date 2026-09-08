# LIVE-DOCUMENT-PRESSURE-CONTAINMENT: Bounded Views over Durable Documentation

## Metadata

- Tree ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`
- Status: `active` / `.7.2` implements approved capacity; `.7.3` is next after canonical landing
- Roadmap lane: `Repository architecture / documentation sustainability`
- Created: `2026-08-09`
- Last updated: `2026-09-08` (`.7.2` implements the director-approved exception; independent `.7.3` remains pending)
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
  Status: `active` (`.0-.6` complete; `.7` is the current Dart capacity prerequisite)
  Goal: Replace measured oversized routed destinations with bounded views over durable stores.
  Depends on: `README-STABILITY-POLICY.4.2`
  Children: `.0-.7`

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
  Status: `done` (2026-08-09; committed atomically at `99fe03f3` as 177/300; brief cleared; clean proof passed;
    no push)
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
  Status: `done` (2026-08-10; landed clean at `61a52dbd` as atomic 178/300; no push)
  Goal: Partition the oversized `FUTURE-PARITY-BACKLOG` task evidence by stable semantic ranges without changing
    node ids, frontier truth, acceptance evidence, or central task metadata enforcement.
  Depends on: `.0`
  Acceptance: Preserve the exact clean future-task source while replacing the monolith with a bounded root index,
    seven mutable semantic parts, one immutable legacy-history part, and one strict schema-v1 JSONL index; add
    root-derived stable-ID lookup and mutation-checked metadata/range/digest/frontier enforcement; reroute every
    direct machine consumer; ratchet the route through a newly staged execution ADR; align public/live docs; pass
    focused and canonical signoff; commit, clear, remove exact residue, and prove clean before `.3`.

  #### Acceptance Checklist

  - [x] **CLEAN BASE / TASK-FIRST ACTIVATION** — Prove `99fe03f3` parent/subject, zero-byte brief, fresh memory/
    Knowledge/history, absent rendered book, zero managed runs, and empty index/worktree; make this task file the
    sole first `.2` mutation.
  - [x] **EXACT STRUCTURAL CLASSIFICATION** — Use the task metadata/toolbox owners to classify root-current,
    seven stable numeric node ranges, ID-scoped late evidence, and legacy global history without changing or
    duplicating any stable ID, status, checklist, frontier, decision, question, blocker, or evidence payload.
  - [x] **BOUNDED ROOT / INDEX / LOOKUP** — Install the bounded stable root, strict eight-part schema-v1 JSONL
    index, seven <=5,000-line / 786,432-byte mutable semantic parts, immutable history part, and repository-rooted
    `perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id <stable-id>` retrieval.
  - [x] **CONSUMER DECOUPLING** — Transfer all nine executable checker and two JSON-contract reads from the old
    monolith to exact semantic owners or governed lookup; mutation-lock zero residual machine authority and forbid
    root compatibility duplicates.
  - [x] **METADATA / MUTATION / ROUTE PROOF** — Strengthen task metadata to reject missing/duplicate/wrong-range
    IDs, uncovered/stale parts, unsafe paths/symlinks, stale digests/counts, broken frontier lookup, oversize
    members, mutable history, and unauthorized route debt retirement through a newly staged indexed ADR.
  - [x] **LOCKSTEP / NO BEHAVIOR REGRESSION** — Align task index, architecture, roadmap, Knowledge, changes/notes/
    live/memory, and sole-facing mdBook; preserve parser/compiler/runtime/backend/MCP/CLI/fixture/schema/language
    behavior and leave changes/notes migration to `.3`.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass exact source-accounting/lookup/consumer/metadata/mutation/routing,
    task/memory/Knowledge/doctrine/book checks and definitive canonical CI; commit atomically as 178/300, clear the
    brief, remove exact generated residue, and prove clean before `.3`.

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`
  Status: `done` (2026-08-10; landed clean at `921f0507` as atomic 179/300; no push)
  Goal: Give `CHANGES.md` and `DEVELOPMENT_NOTES.md` bounded current indexes/hot shards, ordered archive manifests,
    query-first retrieval, and finite rollover thresholds without losing history.
  Depends on: `.0`
  Acceptance: Preserve both exact clean sources while replacing each unbounded chronology with a bounded current
    index/hot shard over immutable ordered history; reuse or deliberately extend the accepted document-history
    contract; add repository-rooted query and deterministic threshold-driven rollover; make `COMMIT.md` the causal
    bounded author workflow; ratchet both route debts through a newly staged execution ADR; align public/live docs;
    pass focused and canonical signoff; commit, clear, remove exact residue, and prove clean before `.4`.

  #### Acceptance Checklist

  - [x] **CLEAN BASE / TASK-FIRST ACTIVATION** — Prove `61a52dbd` parent/subject, zero-byte brief, fresh memory/
    Knowledge/task history, absent rendered book, zero managed runs, removed stale incremental cache, and empty
    index/worktree; make this task file the sole first `.3` mutation.
  - [x] **EXACT SOURCE / RECORD CLASSIFICATION** — Measure and bind both clean Git sources, identify complete
    chronology-record boundaries and current hot material, and prove exact ordered accounting before moving bytes.
  - [x] **IMMUTABLE HISTORY / BOUNDED CURRENT VIEWS** — Install strict ordered archive manifests and bounded stable
    current indexes/hot shards that preserve every clean byte without making archives current-state authority.
  - [x] **QUERY / ROLLOVER / MUTATION PROOF** — Provide root-derived literal/segment/reconstruction retrieval and a
    deterministic 80%-warn / 90%-roll / <=50%-post-roll workflow with path, digest, ordering, and mutation checks.
  - [x] **AUTHOR WORKFLOW / ROUTE RETIREMENT** — Update `COMMIT.md` and bootstrap/toolbox guidance so appends stay
    bounded by construction; retire both immutable route debts only through an exact newly staged indexed ADR.
  - [x] **LOCKSTEP / SOLE-FACING BOOK** — Align task index, architecture, roadmaps, Knowledge, live/memory, and the
    mdBook without changing parser/compiler/runtime/backend/MCP/CLI/fixture/schema/language behavior or README.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass exact reconstruction/query/rollover/mutation/routing, task/
    memory/Knowledge/doctrine/book checks and definitive canonical CI; commit atomically as 179/300, clear the
    brief, remove exact generated residue, and prove clean before `.4`.

  #### TOOLBOX Task-Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Exact clean Git census, routed debt report, and `rg -n` consumer scan reproduce both
    unbounded author histories plus the causal cumulative workflow before any root replacement.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Consumer/toolbox audit proves the roots have no executable content parser;
    `COMMIT.md` mandates their growth, while ordered complete records and exact retrieval forbid blind truncation.
  - [x] **FIX** — Preserve both clean sources in strict immutable manifests, replace roots with bounded hot shards,
    add complete-record query/rollover, make the author checks mandatory, and retire routes through ADR `0069`.
  - [x] **ADDRESSED (verified)** — Result: PASS for exact source hashes, three surfaces / 21 segments, 12/12
    rollover cases, 34/34 history mutations, 32/32 routing mutations, outside-CWD query, and rendered-book review.
  - [x] **NO REGRESSION** — Consumer census stays content-parser-free; all eleven task consumers remain partitioned;
    parser/runtime/backend/MCP/CLI/fixture/schema/language behavior and README are unchanged.
  - [x] **LOCKSTEP** — Workflow/bootstrap/toolbox, routes/ADRs/Knowledge, task/roadmaps/architecture, continuity roots,
    and sole-facing book agree; final doctrine/canonical/commit evidence remains in the owning verification row.

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4`
  Status: `done` (2026-08-10; definitive focused/book/doctrine/canonical signoff complete from clean changes/
    notes commit `921f0507`; intended atomic 180/300 commit pending; no push)
  Goal: Ratchet all four registry surfaces to normal, recompose retrieval and pressure controls unchanged, close
    the program, and return to the prior product frontier from a clean boundary.
  Depends on: `.1-.3`
  Acceptance: Starting from the three clean migration commits, independently recompose exact durable/current
    state for live status, future tasks, changes, and engineering notes; prove every query, lookup, rollover,
    limit, mutation, route, consumer, and rollback contract unchanged; prove all debt metadata and finite migration
    allowances are already absent without rewriting the accepted route contracts; align all planning/continuity/
    public owners; pass focused and canonical
    signoff; commit, clear, remove exact residue, prove clean, and restore the prior product frontier.

  #### Acceptance Checklist

  - [x] **CLEAN BASE / TASK-FIRST ACTIVATION** — Prove `921f0507` parent/subject, zero-byte brief, absent rendered
    book, zero managed runs, and empty index/worktree; make this task file the sole first `.4` mutation.
  - [x] **FOUR-STORE RECOMPOSITION** — Independently enumerate and verify every current root, immutable archive,
    semantic task part, manifest/index record, clean source identity, exact reconstruction, and stable-ID lookup.
  - [x] **RETRIEVAL / PRESSURE / RECOVERY** — Exercise root-derived history queries and task lookup outside the
    repository cwd, both chronology rollover states, recoverable publication, finite limits, and failure behavior.
  - [x] **NORMAL ROUTE RATCHET / CONSUMERS** — Prove all four surfaces and every transferred consumer use only
    current bounded owners with empty debt metadata; preserve the exact accepted route contracts unchanged.
  - [x] **PROGRAM CLOSEOUT / FRONTIER RESTORE** — Mark ADR `0066` and this activity implemented, align task index,
    architecture, roadmaps, Knowledge, continuity roots, and the sole-facing book, and restore the prior product
    frontier without changing parser/compiler/runtime/backend/MCP/CLI/fixture/schema/language behavior or README.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass recomposition/retrieval/rollover/recovery/routing/consumer,
    task/memory/Knowledge/doctrine/book checks and definitive canonical CI; commit atomically as 180/300, clear
    the brief, remove exact generated residue, and prove the restored frontier clean.

  #### TOOLBOX Task-Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Clean-boundary Git, route, task, history, and rollover probes establish the exact
    three-migration state that must be recomposed before migration allowances can close.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Registry inspection proves all four route records are already current with
    empty `baseline`/`transition`; `.4` owns independent proof and status closure, not another route transition.
  - [x] **FIX** — Preserve the four accepted route contracts and update only composed closeout/status owners.
  - [x] **ADDRESSED (verified)** — Record exact four-store, retrieval, recovery, routing, mutation, and gate proof.
  - [x] **NO REGRESSION** — Preserve exact archived bytes, stable IDs, current limits, consumer authority, public
    behavior, README content, and repository-local/root-relative execution.
  - [x] **LOCKSTEP** — Close the ADR/task/program state and return every live/public pointer to the prior frontier.

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5`
  Status: `done`
  Goal: Recover task-collection headroom by removing proven duplicate startup chronology.
  Acceptance: Prove every removed batch/commit/verification statement has a richer retained task/Git owner;
    retain unique reading ranges, causal evidence, decisions, repair ownership and all stable IDs. Preserve
    every pressure limit and immutable file; run focused metadata, memory, routing and continuity proof.
    Commit before returning to SESSION-STARTUP-READING.3.3.43; split any required infrastructure change first.
  Verification tier: `canonical`
  Focused checks: Exact batch Git census and all commit-row/leaf/retained-note identities; unchanged stable
    task IDs, reading/repair fields, registry and immutable files; memory, metadata, routing, histories and diff.
  Canonical trigger: `parent closeout` — finish the reopened containment tree with exact staged local CI.
  Verification: Exact comparison passes 100 ordinal/leaf/hash identities, 102 identical commit subjects,
    all 102 verbatim retained notes and all 316 unchanged stable IDs/other node fields. The task file drops
    186 lines / 16,380 bytes; existing source/repair evidence remains unchanged. Exact staged canonical
    proof is required before landing; its completed result is recorded in the commit body.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5 - compact duplicate startup chronology without losing evidence`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.6`
  Status: `done`
  Goal: Recover capacity for the remaining Rust checkpoints through verified duplicate chronology consolidation.
  Acceptance: Measure resulting task pressure; audit closed-tree table/node/Git identities and every consumer;
    retain all unique notes, stable IDs, acceptance, reading/repair evidence and immutable bytes. Use `.5`'s exact
    equivalence precedent; correct proven historical commit-reference errors while retaining prior text, preserve limits, split infrastructure changes, and commit before `.3.3.44`.
  Verification tier: `focused`
  Focused checks: Exact source/table/node/Git and retained-note equivalence; consumer audit; task metadata,
    memory, Knowledge, routing pressure, both histories and diff; immutable and non-target identity.
  Canonical trigger: `none` — ordinary documentation consolidation; parent stays open for `.7`, with no mechanical-owner change.
  Verification: Exact 264-row/260-node retention and Git identity pass across four closed trees; six captions
    remain in table form. Non-Commit node fields and all outside text are unchanged; 251 lines / 8,210 bytes
    removed overall. The wrong .2.1.1 pointer is corrected with prior text retained; runnable audit is in
    docs/knowledge/startup-task-chronology-compaction.md. Metadata, memory, Knowledge, histories and doctrine proof govern landing.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.6 - consolidate verified task chronology and correct historical references`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7`
  Status: `active`
  Goal: Admit complete bounded Dart reading ownership within the governed task-store capacity.
  Dependencies: Rust reading closeout `SESSION-STARTUP-READING.3.3.67`; before Dart child ownership/reading begins.
  Children: `.7.0-.7.4`; the director approved the narrow capacity/reading-gate exception on 2026-09-08.
  Acceptance: Reverify the preserved estimate of 115 files / 56 groups / 169 range rows; measure resulting
    ownership and evidence capacity, preserve every unique record and all limits except ADR 0109's four director-approved aggregate scalars, and split required infrastructure design before changes.
  Evidence-capacity intake: `.3.3.61` measures 1,017 Knowledge Markdown files / 58,284 lines / 4,850,347 bytes against unchanged 1,024 / 64,000 / 6,291,456 ceilings. Include this evidence store in the capacity review before Dart; no count increase is authorized by this measurement.
  Verification: `.7.0` verifies exact Dart inventory; `.7.1` records the approved design. Implementation `.7.2` lands with canonical proof at 4489f5e9. Independent `.7.3` recomposes controls, preservation, lookup and the complete reserve; admission `.7.4` remains pending.
  Commit: `pending`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.0`
  Status: `done`
  Goal: Reverify Dart inventory and quantify bounded task and Knowledge capacity before selecting a solution.
  Acceptance: Account for every baseline/current Dart path and byte; reverify bounded group/range estimates with explicit packing assumptions;
    measure governed stores and projected ownership; preserve every current node, field, immutable byte and limit.
    Record an executable audit and route the next design leaf; no Dart source-reading or ownership credit.
  Verification tier: `focused`
  Focused checks: Exact inventory/range reconstruction; registry-derived pressure census; task metadata,
    memory, Knowledge, both histories, affected mdBook render, immutable/non-target identity and staged diff/scope.
  Canonical trigger: `none` — ordinary measurement and task decomposition; no infrastructure or public contract change.
  Verification: All 115 Dart paths / 80,296 physical lines / 2,471,305 bytes match baseline. Explicit packing proves 55 groups / 169 exact ranges / 80,297 fragments; a separate 56-group control retains the planning allowance. The 605-line scoped template exceeds activation task headroom of 60 lines and startup headroom of 562 lines. Knowledge has six file slots. Coordinate reconstruction, exact digests and executable pressure audit live in docs/knowledge/startup-task-chronology-compaction.md; focused continuity and book proof govern landing.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.0 - measure Dart reading demand and documentation capacity`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.1`
  Status: `done` (design/proposal only; director exception remains pending)
  Goal: Design sufficient bounded task and Knowledge capacity from the measured admission demand.
  Acceptance: Audit existing retrieval and preservation contracts and alternatives; retain stable ownership,
    unique evidence and explicit limits; define bounded implementation/verification leaves before any migration.
    Inventory measurements alone do not authorize a limit increase or Dart source reading.
  Verification tier: `focused`
  Focused checks: Exact historical growth/projection audit; policy/guard/retrieval review; unchanged node and implementation identity; task/memory/Knowledge/history/routing checks; mdBook render and staged scope.
  Canonical trigger: `none` — documentation-only proposed design; no accepted policy, registry, guard or capacity change.
  Verification: ADR 0108 freezes exact proposed limits, separate bounded Dart ownership, alternatives and .7.2-.7.4 proof. Twice the measured growth plus explicit overhead fits the proposed reserves; no completion guarantee or authorization is inferred. The task guard makes implementation depend on a director exception to the open reading gate. Executable measurement and the .7.0 INDEX/README label correction are retained in the existing Knowledge card.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.1 - design bounded Dart capacity and record the approval boundary`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.2`
  Status: `done` (director greenlight received 2026-09-08: "I greenlight the exception"; canonical evidence retained in this commit)
  Goal: Implement only the approved aggregate capacity and matching task guard from ADR 0108.
  Dependencies: `.7.1`; director approval granted 2026-09-08 for capacity infrastructure before remaining required reading.
  Acceptance: Add exact accepted execution ADR; synchronize both route objects and actual guard boundaries; retain every ID, record, member limit and unrelated control.
  Verification tier: `canonical`
  Focused checks: Task-validator RED/GREEN and 31 self-test classes; 16 registry-bound cases/24 validator executions; exact scope/node/Knowledge/immutable preservation; routing, metadata, memory, histories, Knowledge freshness and mdBook render.
  Canonical trigger: `approved capacity guard and registry infrastructure change` — exact staged canonical receipt required before commit.
  Verification: Shared actual member/aggregate validators enforce unchanged member/file ceilings and approved task totals; old guards fail five new boundary classes, approved guards pass all 31. The unchanged routing validator passes 16 approved-registry cases/24 validator executions. ADR 0109 binds exactly four limit changes. Full candidate, preservation and canonical results are retained in the commit; no Dart source-reading credit.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.2 - implement the approved Dart capacity controls`


  #### TOOLBOX Task-Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — The recorded Dart template exceeds former headroom; actual task-validator expectations fail with old guards (five classes).
  - [x] **ROOT CAUSE (WHY + WHERE)** — The tool-backed consumer census locates the two independent aggregate checks in scripts/check_task_tree_partitions.pl and the two governed registry records.
  - [x] **FIX** — Apply ADR 0109's four approved scalars; main census and boundary self-tests share the same pure validators without changing member/file controls.
  - [x] **ADDRESSED (verified)** — Task boundary GREEN passes 31/31; the unchanged routing validator passes 16 registry-bound cases and 24 actual validator executions.
  - [x] **NO REGRESSION** — Exact registry/node/scope audit preserves all other controls, prior ownership, immutable stores and parser/runtime sources; scripts/check_task_tree_metadata.sh and canonical proof govern landing.
  - [x] **LOCKSTEP** — Director approval, indexed ADRs, Knowledge, roadmaps, mdBook and bounded continuity agree; git diff --check and exact staged canonical receipt precede the per-leaf commit.

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.3`
  Status: `done`
  Goal: Independently recompose the committed capacity controls and complete projected Dart reserve.
  Dependencies: `.7.2` clean canonical commit.
  Acceptance: Prove exact registry/guard agreement, old task and Knowledge retention, unchanged immutable/FUTURE retrieval, generated-map freshness and resulting aggregate/member headroom.
  Verification tier: `focused`
  Focused checks: Committed guard/registry boundary proof; exact task/Knowledge/immutable retention and stable lookup; current and projected member/aggregate pressure; all doctrines, Knowledge freshness, both histories, mdBook render and staged scope.
  Canonical trigger: `none` — independent documentation verification of the canonically committed controls; no mechanical owner changes.
  Verification: Independent old/new scope audit proves only four approved registry scalars changed; every earlier task/Knowledge path and question survives. All 59 history-store files (56 immutable segments and three manifests) and 11 FUTURE files retain exact blobs; stable lookup is byte-identical from root and docs/. Actual validators pass 31 classes and 16 cases/24 executions. Complete current and projected aggregate/member reserve fits; exact final measurements and focused results belong to this commit. No additional capacity or mechanism change.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.3 - independently verify Dart capacity and evidence retention`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.4`
  Status: `pending`
  Goal: Admit a bounded pending Dart tree and close the capacity prerequisite.
  Dependencies: `.7.3`; the director-approved scope and complete admission projection.
  Acceptance: Create pending DART-STARTUP-READING ownership and bridge startup .3.4 without moving existing evidence; align book/index/continuity; no source-reading credit.
  Verification: Planned canonical milestone proof; clean commit and zero-byte brief before DART-STARTUP-READING.0 decomposition.
  Commit: `pending`

## Current Frontier

Next: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.4` admits the bounded pending Dart tree after independent `.7.3` verification. Canonical implementation 4489f5e9 and the independent audit preserve all existing limits beyond the four approved scalars, records and retrieval. No Dart source-reading credit yet.

## Decisions

- `2026-09-08`: `.6` is bounded documentation consolidation with focused proof under ADR 0073; the parent remains open because the preserved Dart decomposition estimate needs `.7` capacity admission. No mechanical owner, limit or current product contract changes.

- Exact history is durable data; containment changes its live projection and retrieval topology, not its truth.
- The README routing registry's clean baselines are immutable. Transition allowances name owners and finite deltas
  instead of silently redefining the current high-water mark after every append.
- An archive descriptor must name the source/range, immutable revision locator, line/byte counts, digest, current
  replacement, and a repository-rooted retrieval command before working-tree content can move.
- ADR `0066` freezes one schema-v1 document-history manifest per chronological family, one bounded live root per
  stable path, exact byte reconstruction from a clean Git source, and semantic rather than chronological task
  partitioning. Execution-time route-contract changes still require newly added staged ADRs because the registry
  correctly refuses to treat this already-committed planning authority as a later mutation permit.
- ADR `0068` implements the task partition from clean `99fe03f3`: exact source-line provenance, seven mutable
  semantic owners, immutable global history, strict current snapshots, stable-ID lookup, and route ratchet.
- ADR `0069` implements the two author histories from clean `61a52dbd`: eleven/six exact immutable initial
  segments, bounded stable hot roots, reserved reverse-chronological IDs, complete-record rollover, exact Git
  source-slice checks, both debt retirements, and a mandatory two-surface author check in `COMMIT.md`.

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

`tools/check_capability_conformance.pl` now scans all seven semantic parts for its complete census and `.15-.24`
for the public exclusion projection. Repeated action reads `.09` plus the `.10.0-.6` handoff; root selection
reads `.09`; semantic introspection reads `.10.0-.6` for implementation ownership and `.10.7-.10` for its public
projection. Their two contract JSON files name the matching public owners. The stable root remains navigation,
not a compatibility duplicate. Logical-helper, diagnostic-output, generated-source, and native-resolution
checkers read `.00-08`; duplicate-slot identity reads `.09`. The partition checker rejects the old monolith path
in all nine executable and two JSON scopes.

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
late ID-scoped evidence lines routed to `.1` or `.5`. A strict nine-record JSONL index fixes range identity,
clean source digests, and same-commit current digests. Every part stays below 5,000 lines / 786,432 bytes; the
collection ratchets globally to 8,000 lines / 1 MiB per file while retaining 128 files / 80,000 lines / 8 MiB
aggregate. All 510 clean stable IDs remain exact and unique.

## Migration, Failure, And Rollback Contract

1. `.1`: from clean `.0`, decouple all live capability assertions; add the root-derived query, strict document-
   history checker, registered doctrine, initial exact live snapshot, bounded current view, and a newly staged
   indexed route-transition ADR. Verify reconstruction and all affected capability/public mutations before the
   root rewrite commits.
2. `.2`: from clean `.1`, add the task index/lookup and semantic parts; strengthen metadata uniqueness/frontier/
   range/digest oracles; reroute eleven direct machine consumers; archive legacy global logs; ratchet the task route
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

- None. `.4` activated task-tree-first from verified clean `921f0507`.

## Verification Log

- `2026-09-08` `.6`: four-source Git/node/table/retained-note audit, byte-exact inverse reconstruction and corrected-reference provenance pass; metadata passes partitions 27/27, current-ID 10/10 and stable-marker controls. Final focused continuity proof belongs to its commit.

Planning evidence: clean activation `0bcb5a36`; route report 20 surfaces / 62 routes / 32/32 mutations; exact
four-file line/byte/SHA-256 census; 121 / 117 / 75 / 132 repository-reference counts; seven live required-marker
families; an initial four-executable plus two-JSON future-task inventory; 25 top-level future-node boundaries; exact
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

Task-partition implementation focused proof: source coverage, 510 unique/range-owned stable IDs, bounded lookup,
current digests, immutable history, 26/26 mutations, task limits, staged route retirement, and the first six
transferred consumers pass. The first canonical E4 attempt then fails at logical-helper owner `.5.2.2`, proving
the prose-led consumer audit incomplete. Exact executable-scope search finds five more readers: logical-helper,
diagnostic-output, generated-source, and native-resolution in `.00-08`, plus duplicate-slot identity in `.09`.
All five focused contracts pass after transfer; the partition checker now guards the complete nine-executable +
two-JSON topology. This is root-caused consumer-discovery evidence, not a relaxed gate or classification-only move.

Task-partition definitive signoff: a restricted outer attempt reaches the process-locality proof only after all
preceding checks pass, then denies nested macOS `sandbox-exec` with status 71. The unchanged isolated six-family
proof passes with the required permission. One uninterrupted approved canonical rerun exits 0 after all eight
doctrines, capability 80/0/0, MCP complete/141, Rust semantic admission 1/1 in 82.34 seconds, Julia semantic
admission 416/416 in 31.7 seconds, cursor 288, six-family containment, moved-root/outside-CWD execution, CLI 66/66
in both option environments, RAM 57%, and Phase 0 1,031/1,031 in 696 seconds. Optional matrices remain unclaimed.

Changes/notes clean-source classification: activation commit
`61a52dbdd625230a69ae7cbc792be7a1ca7ee702` owns `CHANGES.md` at 44,270 lines / 3,104,131 bytes, Git blob
`2e951cabd39f4f8cc00b5eebb499c9fbf417b971`, SHA-256
`c8ba1b7c92fe2536d75bad23f047f46da6cf1fc036f5f420bdf997f2b2c14e42`, and 3,540 `^## ` record boundaries.
The same commit owns `DEVELOPMENT_NOTES.md` at 21,308 lines / 2,291,424 bytes, Git blob
`0522cdf5b9b1b182c44ffa764e56b1a6ed087508`, SHA-256
`ca9ad5c3e3d243d972053cfbdc8a37fe545c92e41e143b1a70a8bd2fcfe9443c`, and 2,110 dated-entry or `^## `
boundaries. Both working files remain byte-identical to HEAD before migration. Initial history may use exact
line-greedy segments; future rollover must move only complete root records at those surface-specific boundaries.
The first staged whitespace proof finds legacy trailing spaces in the exact notes tail. Byte preservation forbids
normalizing them, so the existing raw-history-only Git attribute expands narrowly from blank-at-EOF to blank-at-
EOL/EOF exemption for `docs/history/**/segment-*.md`; all current roots and non-archive files retain normal checks.
Pre-signoff code review then finds the first rollover draft replacing the bounded root before publishing its
manifest, creating a crash window where records could leave the current view before becoming queryable. The
corrected recoverable transaction publishes segment/manifest/root in that order and idempotently completes an
exact orphan or pending generation on rerun; mismatched bytes/metadata fail closed. Rollover self-proof expands
from 10 to 12 cases for record identity and publication order.

Changes/notes focused implementation proof: builder, reader, rollover, and checker syntax pass; rollover self-
tests pass 12/12; document-history mutations pass 34/34 and all three surfaces / 21 segments reconstruct or source-
slice exactly. Manifest-order full queries hash to clean-source SHA-256 `c8ba1b7...c14e42` and
`ca9ad5c3...9443c`; literal queries succeed from `docs/`, proving caller-CWD independence. Current roots are
27/512 lines and 2,184/65,536 bytes plus 34/512 lines and 3,251/65,536 bytes, both `OK`. Staged routing passes 44
reader + 18 author routes, 20 current surfaces, and 32/32 mutations; exact routed totals are change history 13
files / 44,305 lines / 3,112,606 bytes and notes 8 / 21,349 / 2,298,664. Knowledge passes at 800 facts / 6,616
keys. The sole-facing 79-file book builds, and generated HTML isolates all-four-current, author-rollover,
recoverable-publication, query, and remaining-closeout claims into rendered blocks before exact output removal.

Changes/notes definitive signoff: one uninterrupted approved repository-volume canonical gate exits 0 after all
eight doctrines, capability 80/0/0, MCP complete/141, Rust semantic admission 1/1 in 81.16 seconds, Julia
semantic admission 416/416 in 30.9 seconds, cursor 288, six-family process containment, moved-root/outside-CWD
execution, primary CLI 66/66 in both option environments, RAM 51%, and Phase 0 1,031/1,031 in 716 seconds.
Optional matrices remain explicitly unclaimed; only the atomic commit, brief clearing, and clean proof remain.

Four-store recomposition focused proof: the committed `921f0507` migration boundary is unchanged outside
closeout/status owners. Document history passes 34/34 mutations across three surfaces / 21 segments; task metadata
passes 26/26 across seven semantic parts, one immutable history part, and all 510 stable IDs; rollover recovery
passes 12/12. Capability 80/0/0 plus logical 8/0/26, diagnostic 8/0/20, generated source, native resolution,
duplicate slot 7/0/59, repeated action 8/0/54, root selection 7/0/54, and semantic introspection 9/0/128 prove
all nine executable plus two JSON consumer projections. From `docs/`, full history queries hash exactly to
`683ef70d...a9d55`, `c8ba1b7c...c14e42`, and `ca9ad5c3...9443c`; three literal queries and bounded task lookup
for `.14.3.1.1` resolve; change/notes roots remain `OK` at 44/512 and 44/512 lines. The unchanged route registry
passes 44 reader + 18 author routes, 20 current/terminal surfaces, and 32/32 mutations; target totals are live
6 files / 14,918 lines / 1,276,548 bytes, tasks 95 / 65,222 / 6,283,181, changes 13 / 44,326 / 3,114,398, and
notes 8 / 21,359 / 2,299,646. Memory 60/60, Knowledge 800/6,617, task metadata, exact index refresh, and
rendered 79-file book inspection pass; generated book output is removed. Definitive canonical CI remains.

The first `.4` canonical attempt passes all eight doctrines and syntax, then fails the capability census because
the closeout rewrite of `docs/TASK_TREE.md` retained parent `.24` closure but removed its checker-owned marker
“exclusion public closeout `.24.2` remains closed”. The canonical consumer is correct: parent state is not
an interchangeable public projection. Its focused rerun next rejects synonymous “remains public-closed” in place
of the exact parent “is public-closed” marker. Both governed projections are restored without weakening any
oracle. Focused capability passes at 80/0/0 from the restored projections, and the complete corrected canonical
rerun exits 0 without weakening any checker, expected marker, or mutation boundary.

Four-store recomposition definitive signoff: one uninterrupted approved repository-volume canonical gate passes
all eight doctrines, capability 80/0/0, MCP 5/5 implementations plus 6/6 runtimes complete with 141 rejected
mutations, Rust semantic admission 1/1 in 85.71 seconds, Julia semantic admission 416/416 in 29.9 seconds, cursor
288, six-family project-data process containment, moved-root/outside-CWD execution, primary CLI 66/66 in both
option environments, RAM 49%, and Phase 0 1,031/1,031 in 673 seconds. The gate exits 0; only the atomic commit,
brief clearing, generated-residue census, post-pointer check, and clean proof remain.

- `2026-09-08` `.5`: exact duplicate-equivalence checks pass; memory, task metadata, routing, Knowledge, both histories and exact staged canonical proof govern landing. All route limits and immutable bytes remain unchanged.

## Commit Log

- `.6`: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.6 - consolidate verified task chronology and correct historical references`.

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.0 - freeze bounded document store contract` — `dc8dd896`, atomic 176/300.

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1 - bound live status over exact history` — `99fe03f3`, atomic 177/300.

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2 - partition future task evidence` — `61a52dbd`, atomic 178/300.

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 - bound changes and engineering notes` — `921f0507`, atomic 179/300.

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4 - close bounded document store program` — intended atomic 180/300.

- `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5`: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5 - compact duplicate startup chronology without losing evidence`.

## Changelog

- `2026-09-08`: `.6` consolidates 264 records with complete retention; `.7` keeps future Dart capacity task-owned.

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
- `2026-08-09`: `.1` lands at `99fe03f3` with exact parent/subject, hook/doctrine/post-pointer proof, zero-byte
  brief, fresh memory/Knowledge/history, absent book, empty managed runs, and clean cadence 177/300. Activated `.2`
  as the sole first mutation for future-task semantic partitioning and consumer/metadata transfer.
- `2026-08-09`: `.2` initially transfers the six consumers found by planning. Canonical E4 fails at the omitted
  logical-helper task owner; exact executable census finds and transfers five additional consumers, focused-green,
  and expands durable checker/docs/Knowledge ownership to the complete eleven-consumer topology.
- `2026-08-10`: `.2` focused/book/eight-doctrine proof and one uninterrupted permission-correct canonical rerun
  pass through containment, relocation, CLI 66x2, RAM 57%, and Phase 0 1,031/1,031 in 696 seconds. Atomic commit,
  brief clearing, residue census, and clean proof are the remaining workflow actions.
- `2026-08-10`: `.2` lands at `61a52dbd` with exact parent/subject, hook/doctrine/post-pointer proof, zero-byte
  brief, fresh memory/Knowledge, absent book, empty managed runs, and 2.4-GiB stale incremental-cache cleanup;
  clean cadence 178/300 passes. Activated `.3` as the sole first mutation for exact changes/notes hot stores.
- `2026-08-10`: `.3` preserves both clean sources as eleven/six immutable segments, replaces the stable roots with
  bounded hot shards, installs deterministic query/complete-record rollover, and retires both route debts through
  ADR `0069`. Pre-signoff review closes a root-before-manifest interruption window with recoverable segment/
  manifest/root publication. Focused history/routing/Knowledge/rendered-book proof and one uninterrupted canonical
  gate pass through containment, relocation, CLI 66x2, RAM 51%, and Phase 0 1,031/1,031 in 716 seconds; the atomic
  commit workflow remains.
- `2026-08-10`: `.3` lands at `921f0507` with exact parent/subject, hook/doctrine/post-pointer proof, zero-byte
  brief, absent book, empty managed runs, and clean cadence 179/300. Activated `.4` as the sole first mutation for
  independent four-store recomposition, normal route ratchets, program closeout, and product-frontier restoration.
- `2026-08-10`: `.4` focused recomposition passes history 34/34, task metadata 26/26 over 510 IDs, rollover 12/12,
  all eleven consumers, three outside-CWD source hashes/literal queries, task lookup, normal routes 20/62/32,
  bounded memory/roots, Knowledge, and rendered-book inspection. After two exact governed marker corrections, the
  definitive canonical gate passes MCP complete/141, Rust semantic 1/1 in 85.71 seconds, Julia semantic 416/416
  in 29.9 seconds, containment/relocation, CLI 66x2, RAM 49%, and Phase 0 1,031/1,031 in 673 seconds. Atomic commit,
  brief clearing, residue census, post-pointer verification, and clean proof remain.

- `2026-09-08`: `.5` removes proven duplicate batch/commit chronology, preserves per-leaf notes and restores startup `.3.3.43`; exact proof is indexed in `docs/knowledge/startup-task-chronology-compaction.md`.
