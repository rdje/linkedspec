# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

- 2026-08-10 (`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4` — unchanged four-store recomposition): the four routed
  records already have their final normal shape: `state=current`, bounded controls, executable verifiers, and
  empty `baseline`/`transition` objects. Closeout therefore must not invent another transition ADR, rewrite the
  migration owners, or refresh old debt facts. It independently composes the committed history/task/consumer/
  rollover/route checks and updates only durable status/frontier owners. This preserves the exact contracts while
  proving they work together and returns product work to `FUTURE-PARITY-BACKLOG.14.3.1.1` after the clean commit.
- The first closeout canonical run rejects a shortened `docs/TASK_TREE.md` future-backlog row because it dropped
  the capability checker-owned marker “exclusion public closeout `.24.2` remains closed”. The parent `.24`
  statement is not an equivalent projection. The focused rerun then rejects “remains public-closed” in place of
  the exact parent “is public-closed” marker. Restore both exact projections and rerun the focused consumer plus
  the complete canonical gate; do not weaken the checker or classify either failure away.
- Corrected closeout signoff passes capability 80/0/0 and one uninterrupted definitive repository-volume gate:
  all eight doctrines, MCP complete/141, Rust semantic 1/1 in 85.71 seconds, Julia semantic 416/416 in 29.9
  seconds, cursor 288, process containment, moved-root execution, CLI 66x2, RAM 49%, and Phase 0 1,031/1,031 in
  673 seconds. The two failures therefore remain useful exact-projection regression evidence, not open blockers.

- 2026-08-10 (`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3` — bounded chronology hot stores): reverse-chronological
  roots need insertion headroom that immutable legacy segment IDs cannot provide after landing. Changes and notes
  therefore reserve initial archive IDs from `5000` upward. Each later rollover removes only an exact suffix of
  complete records already present at clean HEAD, assigns the next lower ID, and prepends that content-addressed
  segment to the manifest. IDs remain ascending in manifest/read order while later rollover generations naturally
  sort before older history; the reserve supports 4,999 rollovers without renaming an immutable target.
- Initial legacy records may split at any line because their only rendering contract is exact reconstruction.
  Once the bounded roots exist, `CHANGES.md` rolls only at `^## ` and engineering notes at a dated-entry or `^## `
  boundary. The rollover tool rejects rewritten/reordered HEAD records and refuses to archive uncommitted entries,
  so every new segment is an exact Git-addressable source suffix rather than conversational or working-tree state.
- Warning, action, and completion are distinct: 80% reports pressure without failing; 90% requires rollover; the
  resulting root must be at or below both 256 lines and 32,768 bytes. The doctrine independently rejects a root at
  the action boundary, so the author workflow cannot defer rollover into the next slice.
- Exact legacy notes include historical trailing spaces. Archive reconstruction forbids normalization, so the
  existing raw-segment attribute exempts only `docs/history/**/segment-*.md` from blank-at-EOL/EOF reporting.
  Current hot roots and every non-archive path remain under the ordinary whitespace gate.
- Pre-signoff review found the first rollover draft published the bounded root before its manifest. An
  interruption in that window could remove current records before the query index named their already-written
  segment. The corrected transaction publishes segment, then manifest, then root. A rerun accepts an exact orphan
  segment or recognizes the exact pending first manifest record and completes the retained-root installation;
  mismatched existing bytes fail closed. Thus every interruption point retains either the unchanged author root or
  a fully queryable archive generation, and recovery is deterministic.
- Definitive signoff uses one uninterrupted approved repository-volume gate: all eight doctrines, six-family
  containment, moved-root/outside-CWD execution, both 66-case CLI option environments, the 51% RAM checkpoint,
  and Phase 0 at 1,031/1,031 in 716 seconds pass before the atomic commit workflow begins.
