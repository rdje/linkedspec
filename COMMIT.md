# COMMIT WORKFLOW

This document defines the standard commit workflow for this repository so any new AI (or human contributor) can run it consistently.

## Goal
- Preserve technical continuity between sessions.
- Keep commit history clean and professional.
- Ensure accepted work is documented before commit.

## Files involved and exact purpose

### 1) `git_message_brief.txt`
- **Type:** temporary commit message file.
- **Purpose:** commit subject/body source for `git commit -F`.
- **Lifecycle:**
  - Populate before commit.
  - Use as commit message input.
  - Clear immediately after successful commit.
- **Important:** this file is workflow tooling and should remain untracked.

### 2) `CHANGES.md`
- **Type:** persistent, git-tracked technical change history.
- **Purpose:** record what changed, why, and how it was validated.
- **Lifecycle:** append/update for each accepted implementation slice.
- **Important:** this file is cumulative and not reset.

### 3) `DEVELOPMENT_NOTES.md`
- **Type:** persistent, git-tracked technical knowledge base.
- **Purpose:** capture architecture insights, design rationale, migration notes, and key implementation details for future maintainers/AI sessions.
- **Lifecycle:** update whenever meaningful technical understanding or workflow-relevant implementation details are added.
- **Important:** this file is cumulative and not reset.

### 4) `MEMORY.md`
- **Type:** persistent, git-tracked continuity log.
- **Purpose:** preserve interruption-safe continuation context after session loss, crash, or handoff.
- **Lifecycle:** update for each accepted implementation slice so the latest execution state and decisions are recoverable.
- **Important:** this file is cumulative and not reset.

### 5) `LIVE_ACHIEVEMENT_STATUS.md`
- **Type:** persistent, git-tracked live batch status.
- **Purpose:** preserve current batch progress, latest completed slice, and immediate next direction for crash recovery and handoff.
- **Lifecycle:** update for each accepted implementation slice when batch/workflow status changes.
- **Important:** this file is cumulative/current-state documentation and is not reset.

### 6) Source/test/docs changed by the task
- Examples: `perl/LinkedSpec.pm`, `t/phase0_regression.t`, `USER_GUIDE.md`, etc.
- Stage only files that belong to the completed task slice.

### 7) `docs/linkedspec-book/`
- **Type:** persistent, git-tracked public documentation book.
- **Purpose:** explain LinkedSpec to the outside world: what it does, how it works, why it is designed that way, and how to use it.
- **Lifecycle:** evolve alongside the project; update when public-facing behavior, architecture understanding, rationale, or user-facing surfaces change materially.
- **Important:** this book is a public product surface, not a crash-recovery log.

## Commit cadence (when to run this workflow)
- Run after a task/activity slice is completed and accepted.
- Preferred granularity: one coherent, validated change slice per commit.
- Typical trigger: after implementation + tests are green.
- For task-tree-managed work: run after each completed leaf; one commit per leaf before selecting another leaf.

## Required pre-commit validation
- Run relevant syntax/tests for the task.
- For LinkedSpec action-rewriter slices, standard gate is:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`

## Documentation Layers
- Keep the public book and the continuity docs separate.
- `docs/linkedspec-book/` is the public-facing explanation of LinkedSpec.
- `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `MEMORY.md`, `LIVE_ACHIEVEMENT_STATUS.md`, roadmap notes, and the workflow described here exist for interruption recovery, handoff continuity, and execution hygiene.
- Updating continuity docs does **not** replace updating the public book when a slice changes what users or outside readers need to understand.

## Exact workflow steps

1. **Inspect current state**
   - Review status/diff and confirm commit scope.
   - Ensure unrelated artifacts are excluded (for example swap files).

2. **Update persistent docs**
   - Add concise but precise entries to:
     - `CHANGES.md`
     - `DEVELOPMENT_NOTES.md`
     - `MEMORY.md`
     - `LIVE_ACHIEVEMENT_STATUS.md`
   - If the completed activity belongs to a task-tree leaf, update the owning `docs/tasks/*.md` file (node status, verification log, commit log, blockers, decisions, and changelog).
   - Include validation commands/results.
   - If the slice changes the public understanding of LinkedSpec, update `docs/linkedspec-book/` too.
   - If a slice adds, renames, or materially clarifies DSL methods, treat user-facing documentation as required completion work: update the relevant guides with clear semantics and extensive worked examples, and backfill older methods in that same user-facing family when the documentation is still too thin for confident adoption.

3. **Prepare commit message**
   - Populate `git_message_brief.txt` with:
     - Short subject line.
     - Focused body (what changed).
   - For task-tree-managed work: identify the completed leaf ID in the commit subject or first body line.
   - Do **not** add an automatic `Co-Authored-By` line unless it is explicitly requested for the current contribution.

4. **Stage intended files only**
   - Stage source/test/docs for the slice.
   - Do not stage swap/temp files.

5. **Create commit**
   - Run commit with:
     - `git --no-pager commit -F git_message_brief.txt`

6. **Post-commit cleanup**
   - Clear `git_message_brief.txt` (truncate to empty).
   - Verify status is clean except expected untracked local artifacts.

## Guardrails
- Do not bundle unrelated changes in the same commit.
- Keep commit messages specific and technically descriptive.
- Keep `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` synchronized with the actual committed slice.
- In tracked live docs and the public book, write repository file references relative to the git repo root (for example `perl/LinkedSpec.pm`), never as machine-local absolute checkout paths or developer-specific checkout directories.
- If `git_message_brief.txt` is accidentally committed, remove it from index immediately and restore the untracked-temp-file invariant. Amend when appropriate; otherwise make the corrective follow-up commit right away.
