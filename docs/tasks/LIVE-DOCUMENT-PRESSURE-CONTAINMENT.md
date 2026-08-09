# LIVE-DOCUMENT-PRESSURE-CONTAINMENT: Bounded Views over Durable Documentation

## Metadata

- Tree ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`
- Status: `proposed` / dependency-queued behind `README-STABILITY-POLICY.4.2`
- Roadmap lane: `Repository architecture / documentation sustainability`
- Created: `2026-08-09`
- Last updated: `2026-08-09`
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
- Do not activate a migration while `README-STABILITY-POLICY.4` is dirty or before its closure checker lands.

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
  Status: `proposed` / dependency-queued
  Goal: Replace measured oversized routed destinations with bounded views over durable stores.
  Depends on: `README-STABILITY-POLICY.4.2`
  Children: `.0-.4`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.0`
  Status: `pending`
  Goal: Reverify the committed route registry, audit semantic retrieval obligations for all four debt families,
    and freeze exact archive/partition descriptors plus migration order without moving content.
  Depends on: `README-STABILITY-POLICY.4.2`

- ID: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1`
  Status: `pending`
  Goal: Convert `LIVE_ACHIEVEMENT_STATUS.md` into a bounded current view while preserving its exact historical
    chronology in indexed repository-relative durable partitions and Git history.
  Depends on: `.0`

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

None until `README-STABILITY-POLICY.4.2` closes cleanly. Then `.0` is the only eligible leaf.

## Decisions

- Exact history is durable data; containment changes its live projection and retrieval topology, not its truth.
- The README routing registry's clean baselines are immutable. Transition allowances name owners and finite deltas
  instead of silently redefining the current high-water mark after every append.
- An archive descriptor must name the source/range, immutable revision locator, line/byte counts, digest, current
  replacement, and a repository-rooted retrieval command before working-tree content can move.

## Verification Log

Pending dependency closure.

## Commit Log

Pending.

## Changelog

- `2026-08-09`: Opened from the director-priority README routing-pressure audit. Recorded exact clean measurements
  and owners before policy/checker enforcement or any content migration.
