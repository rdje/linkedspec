---
id: bounded-live-document-store-contract
title: Oversized live documents require consumer-aware bounded views over verified stores
answers:
  - how will LinkedSpec contain live document pressure
  - why can LIVE_ACHIEVEMENT_STATUS not simply be truncated
  - which machine consumers read LIVE_ACHIEVEMENT_STATUS
  - why can FUTURE-PARITY-BACKLOG not simply be split mechanically
  - which machine consumers read the future parity task file
  - where will changes and development notes history live
  - what fields are in a document history descriptor
  - how is archived documentation reconstructed without loss
  - how do I search old live achievement status chronology
  - what are the future parity semantic partitions
  - how are stable task ids retrieved after partitioning
  - what are the live document migration and rollback order
date: 2026-08-09
status: accepted descriptor contract; live-status migration implemented, remaining migrations pending
tags: [documentation, history, task-tree, retrieval, pressure, continuity, doctrine]
evidence: "From clean 0bcb5a36, LIVE is 14,844 lines/1,269,091 bytes, CHANGES 44,193/3,097,056, notes 21,220/2,282,687, and FUTURE 26,979/2,720,175 with SHA-256 c13abe..., c19ba6..., 2735b5..., and 48de44.... Seven capability JSON/checker families require LIVE closeout markers. Four executable checkers plus two JSON contracts consume the exact FUTURE path. FUTURE top-level intervals show .10 at 8,327 lines; splitting it at .10.0-.6/.10.7-.10 yields 4,188/4,139 and lets seven semantic parts plus one immutable history part stay below 5,000 lines. ADR 0066 freezes schemas, topology, mutation classes, migration order, and rollback without moving content."
evidence_update_2026_08_09_live_status: "LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1 transfers all six JSON and seven checker references from live chronology to indexed ADR 0067 without changing their document counts. Four immutable segments reconstruct dc8dd896:LIVE_ACHIEVEMENT_STATUS.md exactly at 14,872 lines / 1,271,326 bytes, Git blob 221159c6..., SHA-256 683ef70d.... The stable root is a five-section 36-line current view. tools/read_document_history.pl provides --grep/--segment/--all; the eighth registered doctrine validates 20 mutation classes plus real schema/path/order/count/hash/blob/source/immutability/current-view oracles."
last_verified: 2026-08-09
reverify:
  - "wc -l -c LIVE_ACHIEVEMENT_STATUS.md CHANGES.md DEVELOPMENT_NOTES.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
  - "shasum -a 256 LIVE_ACHIEVEMENT_STATUS.md CHANGES.md DEVELOPMENT_NOTES.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
  - "rg -n -C 2 'LIVE_ACHIEVEMENT_STATUS.md' capability_conformance/*.json tools/check_*"
  - "rg -n -C 2 'docs/tasks/FUTURE-PARITY-BACKLOG.md' capability_conformance/*.json tools/check_*"
  - "sed -n '1,360p' docs/decisions/0066-bounded-live-document-store.md"
  - "bash scripts/check_document_history.sh"
  - "perl tools/read_document_history.pl --surface live_status --grep 'FUTURE-PARITY-BACKLOG.9.1.10.7'"
---

# Bounded live documents are consumer migrations

The four pressure debts have different semantics. Live achievement status is a current view contaminated by
chronology; changes and engineering notes are ordered histories; the task collection is already partitioned but
has one monolithic active tree. They therefore cannot share a blind line-count rewrite.

Before `.1`, the live file was direct required-marker authority for callable, logical-helper, root-selection,
duplicate-slot, repeated-action, rule-local-cursor, and capability-exclusion closeouts. Those assertions now live
under indexed ADR `0067`, and the bounded current root is mutation-locked against regaining that role. The future task file is
read directly by capability-exclusion, repeated-action, root-selection, and semantic-introspection checkers, and
by two contract JSON projections. Those dependencies must move to stable contract owners or semantic task parts
before either root can shrink.

ADR `0066` preserves the stable root paths while adding repository-relative manifests, exact source commit/blob,
line/byte/SHA-256 evidence, immutable archive segments, and reconstruction queries. Live status is now an
overwrite-oriented five-section snapshot. Changes and notes will become 512-line/64-KiB hot shards over ordered
archives. The future tree keeps its root as a bounded live index and routes stable node IDs into seven semantic
parts plus one immutable legacy-history part; `.10` is divided at a real child boundary so no part approaches the
old 26,979-line sink.

Migration is `.1` live/history mechanism, `.2` task partition, `.3` changes/notes and author workflow, then `.4`
unchanged recomposition/registry closure. Every move is atomic from a clean Git boundary, reconstructs the old
source byte-for-byte, and rolls back only by the activation commit before landing or an explicit revert after.
