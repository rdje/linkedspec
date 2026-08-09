# ADR 0066: Live documentation uses bounded views over verified durable stores

- Date: 2026-08-09
- Status: accepted direction; descriptor contract frozen, migrations pending under
  `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1-.4`
- Tags: architecture, documentation, history, task-tree, retrieval, pressure, continuity, doctrine

## Context

README routing-pressure closure measured four destinations that are durable but not sustainably shaped:
`LIVE_ACHIEVEMENT_STATUS.md` is a 14,844-line chronology presented as a current view;
`docs/tasks/FUTURE-PARITY-BACKLOG.md` is one 26,979-line member of an otherwise partitioned task collection;
`CHANGES.md` is 44,193 lines; and `DEVELOPMENT_NOTES.md` is 21,220 lines. Their clean debt baselines remain the
smaller measurements captured at `7c2ff407`; the larger values include the three README closure slices and are
diagnostic state, not refreshed baselines.

A mechanical split would break real consumers. Seven capability contracts require historical public-closeout
markers from `LIVE_ACHIEVEMENT_STATUS.md`. Four executable checkers and two contract JSON files read the exact
future-backlog path and search node blocks, statuses, acceptance headings, or closure markers. The commit and
task-tree doctrines also instruct every slice to append or update all three chronological documents. Growth is
therefore caused by workflow and checker ownership, not merely by prose length.

Git history alone is insufficient: maintained task evidence and ordered chronology still require direct,
root-relative retrieval. Sharding alone is also insufficient: without descriptors, identity, per-part ceilings,
aggregate ceilings, and reconstruction proof, it only creates more unchecked sinks.

## Decision

### 1. One descriptor protocol governs immutable chronology snapshots

Each chronology family has its own tracked manifest:

```text
docs/history/live-achievement-status/manifest.jsonl
docs/history/changes/manifest.jsonl
docs/history/development-notes/manifest.jsonl
```

The first JSONL record has exactly these fields: `type`, `schema_version`, `authority`, `surface`,
`current_path`, `source_order`, `segment_count`, `max_segment_lines`, and `max_segment_bytes`. `type` is
`document_history`; `schema_version` is `1`; `authority` is this ADR; and `source_order` is `source-file`.

Every remaining record has exactly these fields:

```text
type, surface, segment_id, source_path, source_commit, source_blob,
source_start_line, source_end_line, line_count, byte_count, sha256,
target_path, current_path, retrieval_command, immutable
```

`type` is `segment`; `segment_id` is a zero-padded source-order ordinal; paths and commands are repository-root
relative; `source_commit` is the clean 40-hex activation commit; `source_blob` is Git's blob identity for the
whole source file; `sha256` covers the target bytes; and `immutable` is `true`. Segment paths are
`docs/history/<family>/segment-NNNN-<first-12-sha256>.md`. JSON objects use UTF-8, LF, canonical key order, and
source-order records. No persisted absolute path is allowed.

Initial migration snapshots the complete pre-migration source, including content selected for the replacement
view. A greedy line-preserving partition keeps each segment at or below 4,096 lines and 524,288 bytes; a line
that would cross either ceiling starts the next segment. Concatenating targets in `segment_id` order must equal
`git show <source_commit>:<source_path>` byte-for-byte and must reproduce its line count, byte count, SHA-256,
and Git blob identity.

`perl tools/read_document_history.pl --surface <surface> --all` is the normative whole-history query.
`--segment <segment_id>` and `--grep <literal>` are the bounded alternatives. Each manifest record stores its
exact `--segment` command. The tool derives the repository root from its own location, never the caller's cwd.

### 2. Live achievement status becomes an overwrite-oriented current view

`LIVE_ACHIEVEMENT_STATUS.md` remains the stable reader path. Its replacement contains only a title and the
sections `Current Activity`, `Latest Completed Slice`, `Next Action`, `Recent Completions`, and `History`.
The first four are overwritten on each accepted slice; `Recent Completions` retains at most sixteen one-line
rows. The file is capped at 256 lines and 32,768 bytes and links the manifest/query for exact older evidence.

Before the rewrite, `.1` removes live-status authority from the seven capability/public-closeout contracts and
their executable checkers. Required current assertions move to already normative contract, ADR, Knowledge,
task-index, architecture, roadmap, or mdBook owners. Mutation coverage must reject restoring a chronology file
as capability authority. Historical forbidden-claim checks may still scan the bounded current view, but an
immutable archive is not a current-state denial surface.

The resulting routing contract retains `hot_live`, changes control from `debt_bounded` to
`bounded_collection`, changes state from `debt` to `current`, includes the current file, its manifest, and its
archive parts, and uses the fixed `document_history` verifier. Aggregate ceilings are eight files, 18,000 lines,
and 1,572,864 bytes; archive parts retain the 4,096/524,288 ceilings and the current/member manifest receive
their smaller exact member limits. A newly added, indexed execution ADR must authorize the staged old/new
contract because routing governance deliberately does not accept a previously committed plan as execution-time
authority.

### 3. The future backlog uses stable semantic task parts, not chronological shards

`docs/tasks/FUTURE-PARITY-BACKLOG.md` remains the stable tree entry point and bounded live index. It retains tree
metadata, root status, the authoritative frontier, current decisions/questions/blockers, the part table, and
retrieval help. Superseded frontier narrative and the legacy global verification/commit/changelog sections move
unchanged to `docs/tasks/FUTURE-PARITY-BACKLOG.history.md`; that file is immutable after migration.

Node blocks and every ID-scoped `##` evidence section move by stable numeric ownership into these seven mutable
semantic parts:

```text
docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md
docs/tasks/FUTURE-PARITY-BACKLOG.09.md
docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md
docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md
docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md
docs/tasks/FUTURE-PARITY-BACKLOG.14.md
docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md
```

The clean source digest for this mapping is
`48de44a56bcde1ae6d5e274e2786d939b596d2063756f994d4cfb407be4b3f95`. Source node intervals are
`.0-.8` 3,108 lines, `.9` 3,596, `.10.0-.6` 4,188, `.10.7-.10` 4,139, `.11-.13` 2,016, `.14` 3,952, and
`.15-.24` 1,804. The root's prelude/current global material is 351 lines; legacy history is 3,340 lines; 485
ID-scoped evidence lines currently following the frontier route to `.1` or `.5`. Migration recomputes and
records exact post-routing counts/digests before changing content.

`docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl` has one schema-v1 metadata record and exactly eight part records
(seven semantic plus history). A part record fixes `partition_id`, `path`, inclusive numeric prefix range,
`mutable`, line/byte count, content SHA-256, and exact
`perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id <stable-id>` retrieval. Partition identity is
the stable range, while the digest is a same-commit snapshot and may change only with the owning task leaf.

Every node ID remains unique and unchanged. `scripts/check_task_tree_metadata.sh` expands all top-level Markdown
parts, rejects missing/duplicate nodes and frontier targets, verifies manifest coverage/digests/ranges, and
proves lookup. The four executable consumers and two JSON contracts switch from the old monolith to the exact
semantic part or lookup; no duplicate compatibility node is allowed in the root index. New verification,
commit, and changelog evidence lives with its owning semantic part, while the root keeps bounded current state.

The task collection ratchets to a global 8,000-line / 1,048,576-byte per-file ceiling and retains 128 files,
80,000 aggregate lines, and 8,388,608 aggregate bytes. Exact future-backlog members receive 5,000-line /
786,432-byte member limits. The task surface becomes `current`, uses the executable `task_tree_metadata`
verifier, and receives an execution-time old/new contract ADR.

### 4. Changes and engineering notes use bounded hot shards over ordered archives

`CHANGES.md` and `DEVELOPMENT_NOTES.md` remain the stable author/reader paths. Their complete clean activation
versions are archived through the descriptor protocol before each root becomes a titled hot shard containing
retrieval metadata plus new entries. Each root is capped at 512 lines and 65,536 bytes. At the 90% boundary, an
atomic rollover moves the oldest complete entries to new immutable segments until the root is at or below 50%;
the warning boundary remains 80%. Future records split only at `^## ` for changes and at a dated-entry or
top-level-heading boundary for notes; initial legacy snapshots may split at any line boundary because exact
concatenation, not individual-fragment rendering, is authoritative.

`COMMIT.md` changes from “cumulative and not reset” to bounded hot-shard plus queryable durable-store semantics.
The task-tree and bootstrap docs make the same distinction. The `change_history` and `engineering_notes` route
surfaces become `partitioned` / `bounded_collection` / `current`, use `document_history`, and retain their
existing aggregate ceilings while adding 16-file and 10-file ceilings respectively. Each transition has its own
new staged execution ADR with exact old/new route contracts.

### 5. One checker owns non-loss, locality, freshness, and failure behavior

`scripts/check_document_history.sh` is registered in `scripts/check_doctrines.sh` and calls a core-Perl checker.
It validates strict schemas, safe relative nonsymlink paths, current/member/aggregate ceilings, Git source
identity, segment counts/digests, byte-exact reconstruction, root shape/freshness, and rollover order. Embedded
mutations reject missing/reordered/duplicated records, gaps/overlaps, count/hash/blob drift, absolute or traversal
paths, symlinks, oversized current/segment/collection state, stale current headings, unknown surfaces, and
unreconstructable source bytes.

Task partition mutations additionally reject missing/duplicate IDs, wrong ranges, uncovered parts, stale
digests, a frontier pointing at no canonical node, old-monolith consumer coupling, and duplicate compatibility
projections. The mdBook documents retrieval and current-view semantics but does not ingest the raw archives.

### 6. Migration and rollback are dependency ordered

`.1` installs the history protocol/checker/query and migrates live status after consumer decoupling. `.2` uses
that proven discipline for the future task tree and strengthens task metadata. `.3` migrates changes and notes
and revises the commit/bootstrap workflow. `.4` independently recomposes all stores, ratchets registry reports,
and closes the program.

Each migration begins at a clean activation commit, writes new tracked targets on the repository volume, verifies
counts/hashes/reconstruction and all consumers before replacing the root view, and stages the whole result
atomically. Before commit, the activation commit remains the rollback authority. After commit, rollback is an
explicit `git revert` of that migration commit; archive deletion or partial manual restoration is forbidden.
No off-volume copy, temporary root, cache, or generated owner is introduced.

## Consequences

- Current-facing files become bounded and readable while exact history remains directly retrievable.
- Stable task IDs survive physical partitioning; checkers no longer depend on a historical monolith.
- Routing-pressure debt baselines stay immutable and are replaced by reviewed current contracts, not refreshed.
- Archive parts are immutable data, not user-facing book chapters or new append sinks.
- The migrations require checker/workflow changes and execution-time ADRs; this planning leaf moves no content.

## Links

- Owning tree: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`
- Routing authority: `docs/decisions/0063-bounded-readme-landing-page.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Task doctrine: `docs/TASK_TREE.md`
- Commit workflow: `COMMIT.md`
