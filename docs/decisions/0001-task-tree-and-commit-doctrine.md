# 0001 — Task-tree ownership before any change; strict commit workflow; zero drift

- Date: 2026-06-04
- Status: accepted
- Tags: process, doctrine, continuity

## Context

The project's non-negotiable working doctrine (re-stated by the user multiple times)
governs every coding and non-coding activity. Until now it lived in the user's prompts
and in harness-home-directory memory (`~/.claude/.../memory/`), which is invisible to a
different tool and lost on a harness/model switch. It is recorded here as a layer-C fact
that points at the authoritative tracked docs — not duplicated — so any AI in any
harness is bound by it.

## Decision

Follow these, without exception:

1. **Task-tree ownership FIRST.** No change — code or docs, however small — occurs
   without an owning task-tree leaf first. All activities are tracked under
   `docs/tasks/*`; the index is `docs/TASK_TREE.md`; the workflow is defined in
   `docs/TASK_TREE_README.md` and `docs/TASK_TREE.md`. Pre-system work is audited into
   trees. (Task-trees are **layer B** of `MEMORY_ARCHITECTURE.md`.)
2. **Signoff-level quality.** Quality over speed; no rushing; sloppy work is rejected.
   "We have all the time we need."
3. **Strict commit workflow** per `COMMIT.md` after every completed leaf/slice: update
   the relevant live docs (`CHANGES.md`, `DEVELOPMENT_NOTES.md`, `MEMORY.md`,
   `LIVE_ACHIEVEMENT_STATUS.md`, the owning `docs/tasks/*.md`, and the public book when
   user-facing behavior changes); populate `git_message_brief.txt` (untracked; cleared
   to 0 bytes after commit); put the task-tree leaf id in the commit subject; do not add
   an automatic `Co-Authored-By` line unless explicitly requested.
4. **Zero drift** between `ROADMAP.md` / `ROADMAP_V2.md` ↔ codebase ↔ the mdBook
   (`docs/linkedspec-book/`). The book is the user-facing surface and must always reflect
   what the code does. If the two roadmaps diverge, update both in the same slice.
5. **Batch / PNT modes** (`README.md` doctrine block): a batch runs N leaves
   back-to-back, committing after each; PNT ("pick the next task") loops until no
   eligible leaf remains or the user pauses. Push only after a requested batch completes
   or on explicit ask — not at arbitrary milestones.

## Consequences

- A new AI/harness reads this record (reached via `MEMORY_ARCHITECTURE.md` →
  `AGENTS.md`) and is bound by the same doctrine — continuity survives a model/harness
  switch even though harness-home-dir memory would not.
- Enforcement of (1) and (3) is mechanical via `MEMORY_ARCHITECTURE.md` §9: the
  self-check script (`scripts/check_memory_architecture.sh`), the `.githooks/` gate, and
  the local CI gate (`tools/run_ci_local.sh`).

## Links

- Authoritative docs: `docs/TASK_TREE_README.md`, `docs/TASK_TREE.md`, `COMMIT.md`,
  `MEMORY_ARCHITECTURE.md`, `README.md`, `ROADMAP_V2.md`.
- Related tree: `docs/tasks/MEMORY-ARCHITECTURE-DOC.md`.
