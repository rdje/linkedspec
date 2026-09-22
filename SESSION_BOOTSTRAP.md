# Session Bootstrap

Read `README.md`, then recover the current task from:

- `MEMORY_ARCHITECTURE.md` — the durable, harness-agnostic memory system (mandatory; mechanically enforced). It defines the four memory layers and the write/read paths; derive current `HEAD` from Git, then resume from `MEMORY.md` (the bounded layer-A pointer whose `activation_commit` names the clean leaf base).
- `COMMIT.md` — commit workflow and hygiene conventions.
- Relevant `ROADMAP_V2.md` requirements and current active-lane status.
- The relevant active row and PNT selection rules in `docs/TASK_TREE.md`.
- The active task-tree leaf named by `MEMORY.md` — its requirements, evidence and next action.
- Relevant records under `docs/decisions/` — durable cross-cutting facts/decisions (memory layer C).

## Targeted startup and fast ramp-up

Director-approved on 2026-09-22; decision: `docs/decisions/0123-targeted-session-startup.md`.
Target **2–5 minutes** to recover context, establish Git state and select the next task.
This is a startup target, not a limit on the investigation or verification a fix needs.
If recovery takes longer, identify the concrete blocker instead of silently expanding scope.

Before each change, understand the relevant roadmap requirements, affected code paths,
interfaces/contracts, tests and mdBook sections. Use the Knowledge Map and canonical
records to recover established facts; reverify changed facts or contrary evidence.
Expand reading when a dependency or uncertainty requires it. Confirm task ownership,
Git state and this scope-specific understanding, and state any gaps honestly.

Whole-repository reading and historical audits remain separately tracked activities.
They are not prerequisites for ordinary fixes unless explicitly required for that task.
This replaces the original paragraph0 blanket full-reading prerequisite; prior reading
coverage remains honest and incomplete where recorded. Quality, focused verification,
commit hygiene, project-data locality and dependency black-box boundaries still apply.

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

Analyze `LinkedSpec.pm` or its import paths only as needed for the selected task.

When done, update `ARCHITECTURE_STATE.md` if deemed necessary, then help me fulfil all the objectives as captured in the roadmap. When PNT is requested, select the first eligible leaf from the active task tree's current frontier.
