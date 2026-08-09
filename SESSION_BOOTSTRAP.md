# Session Bootstrap

Read `README.md`, then read and thoroughly understand:

- `MEMORY_ARCHITECTURE.md` — the durable, harness-agnostic memory system (mandatory; mechanically enforced). It defines the four memory layers and the write/read paths; derive current `HEAD` from Git, then resume from `MEMORY.md` (the bounded layer-A pointer whose `activation_commit` names the clean leaf base).
- `COMMIT.md` — commit workflow and hygiene conventions.
- `ROADMAP_V2.md` — current active lanes and tracker status.
- `docs/TASK_TREE.md` — active task trees, current frontier, and PNT selection rules.
- Active task files listed in `docs/TASK_TREE.md` — the detailed task breakdown and current executable leaf.
- Relevant records under `docs/decisions/` — durable cross-cutting facts/decisions (memory layer C).

Before editing root `README.md`, read `README_POLICY.md`; changing detail routes to its canonical owner and the
registered `README-STABILITY` doctrine enforces the reviewed line/byte budgets and cap-increase decision rule.

`LIVE_ACHIEVEMENT_STATUS.md` is a bounded current view. Query exact older chronology through
`perl tools/read_document_history.pl --surface live_status --grep '<literal>'`; use `--all` only when full
byte reconstruction is required. `scripts/check_document_history.sh` enforces the manifest and current view.

`CHANGES.md` and `DEVELOPMENT_NOTES.md` are bounded current hot shards. Query older records with
`perl tools/read_document_history.pl --surface change_history|engineering_notes --grep '<literal>'`. After
prepending complete current records, run the matching `perl tools/roll_document_history.pl --surface <surface>
--check`; if it requires rollover, use `--apply`, inspect the atomic archive/manifest/root update, and recheck.
Never edit an immutable history segment.

`docs/tasks/FUTURE-PARITY-BACKLOG.md` is a bounded current index. Resolve a stable leaf with
`perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id <stable-id>`; after editing the returned mutable
semantic part, refresh its current index snapshot with
`perl tools/update_task_tree_index.pl --tree FUTURE-PARITY-BACKLOG`. Never append new evidence to its immutable
history part. `scripts/check_task_tree_metadata.sh` enforces the complete partition contract.

After reading the above, thoroughly, meticulously and precisely analyze `LinkedSpec.pm` and its import tree.

When done, update `ARCHITECTURE_STATE.md` if deemed necessary, then help me fulfil all the objectives as captured in the roadmap. When PNT is requested, select the first eligible leaf from the active task tree's current frontier.
