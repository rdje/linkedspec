# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.1.2 — repair neutral transaction status boundary

- Activated task-tree-first from clean neutral-authority commit `e0cc7182` as intended atomic 182/300.
- Re-ran the committed independent contract at 132 ActionIR rows, 246 call rows, token 8/17, six effect graphs,
  six mark cases, eight progress cases, fifteen diagnostics, 40 mutations, and neutral rollout 1/9 unchanged.
- Proved byte identity for the artifact, checker, canonical/storage routes, ADR, Knowledge owners, and three public
  book owners before rendering. Language coverage remains exact at 246 current calls / 105+1 fixtures / 122 public
  Perl contracts; project-local tool storage passes.
- Rendered review caught one contradictory milestone sentence: the page said both that the neutral authority was
  executable and still next. Blame traces the old sentence to `7c2ff407`; `e0cc7182` added the executable paragraph
  without updating it. Corrected only that sentence and preserved the causal fact in Knowledge/task evidence.
- Opened `.14.3.1.2.0` for fail-closed public milestone-sequence governance before Perl RED. No neutral artifact,
  checker, fixture, mutation, runtime, backend, grammar, CLI, schema, capability, README, or public capability changed.
- Definitive signoff passes all eight doctrines, repository-contained process/moved-root proofs, both primary CLI
  matrices at 66/66, RAM 59% below the 88% threshold, and Phase 0 1,031/1,031 in 695 wall-clock seconds.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.1.1 — add neutral recognition transaction contract

- Activated task-tree-first from clean bounded-document closeout commit `c26a9556` as intended atomic 181/300.
- Added `linkedspec-recognition-transaction-v1` and an independently implemented checker over the exact future
  authored forms, five-state linear token lifecycle, falsey-safe match/payload channels, invocation-mark snapshots,
  cursor-only repetition/recursion progress, fifteen diagnostics, and neutral/backend/public rollout ownership.
- Classified all 128 live ActionIR node kinds plus four dedicated future transaction nodes and all 246 current
  cross-backend call contracts exactly once under a closed nine-allowed/eleven-rejected base-effect vocabulary.
  Six named-rule graphs compute transitive effects to a recursive fixed point and fail closed on unknown effects.
- Added 8 positive / 17 negative token cases, six mark cases, eight progress cases, and 40 exact schema/syntax/
  token/effect/inventory/graph/mark/progress/diagnostic/rollout/registration/freshness mutations. The checker
  re-derives live inventories and locks the full classifications independently.
- Registered the tracked neutral authority unconditionally in canonical CI through repository-local Python project
  data and advanced the exact rollout to neutral 1/9 complete. Perl, Rust, Dart, Julia, PUC Lua, LuaJIT,
  recurring, and public legs remain RED; authored transaction syntax remains unavailable.
- Aligned ADR `0056`, Knowledge, both roadmaps, architecture, capability guide, toolbox, task/index, continuity,
  and the sole-facing book. A real 79-file mdBook build renders the future/current boundary correctly.
- No grammar, compiler, runtime, backend, generated carrier, `.spec`/corpus, CLI, capability ledger, semantic/MCP,
  README, project-data root, hosted workflow, or current public behavior changes.
- Definitive signoff passes all eight doctrines, repository-contained process/moved-root proofs, both primary CLI
  matrices at 66/66, RAM 55% below the 88% threshold, and Phase 0 1,031/1,031 in 675 wall-clock seconds.

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
