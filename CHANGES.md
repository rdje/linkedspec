# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-08-10 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4 — close bounded document store program

- Activated task-tree-first from clean changes/notes migration commit `921f0507` at cadence 179/300.
- Independently recomposed exact history at 34/34 mutations over three surfaces / 21 segments, task evidence at
  26/26 mutations over seven semantic parts / one immutable history part / 510 stable IDs, and rollover recovery
  at 12/12 without replacing any migration owner.
- Re-ran all nine executable plus two JSON task-consumer projections at their accepted cardinalities. Outside-CWD
  retrieval reproduced exact live/change/note source hashes, resolved all three literal queries plus active leaf
  `.14.3.1.1`, and reported both author roots below rollover pressure.
- Preserved the accepted registry unchanged at 20 surfaces / 62 routes / 32/32 mutations; all four stores are
  current/bounded with empty debt metadata. Aligned ADR, Knowledge, task/frontier, architecture, roadmaps,
  continuity, and sole-facing book status to composition-closed.
- The first canonical pass rejected a compacted task-index row that retained parent `.24` closure but dropped the
  checker-owned `.24.2` public-closeout marker; its focused rerun then rejected synonymous parent status prose.
  Restored both exact governed projections; no checker, expected marker, or mutation boundary was weakened.
- The corrected definitive repository-volume gate exits 0 after all eight doctrines, capability 80/0/0, MCP
  complete/141, Rust semantic 1/1 in 85.71 seconds, Julia semantic 416/416 in 29.9 seconds, cursor 288, containment
  and moved-root proof, CLI 66/66 twice, RAM 49%, and Phase 0 1,031/1,031 in 673 seconds.
- No parser, compiler, runtime, backend, MCP, CLI, fixture, protocol, schema, `.spec` language, README, route
  contract, or project-data root behavior changes.

## 2026-08-10 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 — bound changes and engineering notes

- Activated task-tree-first from clean future-task partition commit `61a52dbd` at cadence 178/300.
- Bound the exact clean `CHANGES.md` source (44,270 lines / 3,104,131 bytes, Git blob `2e951cab...b971`, SHA-256
  `c8ba1b7...c14e42`) into eleven immutable reverse-chronological archive segments starting at reserved ID `5000`.
- Bound the exact clean `DEVELOPMENT_NOTES.md` source (21,308 lines / 2,291,424 bytes, Git blob
  `0522cdf5...7508`, SHA-256 `ca9ad5c3...9443c`) into six equivalent archive segments.
- Extended the shared builder/checker protocol for bounded hot roots and added complete-record rollover tooling
  with 80%-warn / 90%-roll / <=50%-retained thresholds. Pre-signoff review repaired a root-before-manifest crash
  window through recoverable segment/manifest/root publication and exact idempotent rerun behavior.
- Focused syntax, rollover 12/12, history mutation 34/34 over three surfaces / 21 segments, exact query hashes,
  staged routing 20 surfaces / 62 routes / 32/32 mutations, Knowledge 800/6,616, and rendered-book proof pass.
- One uninterrupted repository-volume canonical gate exits 0 after all eight doctrines, containment, moved-root
  execution, CLI 66/66 in both option environments, RAM 51%, and Phase 0 1,031/1,031 in 716 seconds; only the
  atomic commit workflow remains.
- No parser, compiler, runtime, backend, MCP, CLI, fixture, protocol, schema, `.spec` language, README, or
  project-data root behavior changes.
