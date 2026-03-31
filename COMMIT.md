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

### 5) Source/test/docs changed by the task
- Examples: `perl/LinkedSpec.pm`, `t/phase0_regression.t`, `USER_GUIDE.md`, etc.
- Stage only files that belong to the completed task slice.

## Commit cadence (when to run this workflow)
- Run after a task/activity slice is completed and accepted.
- Preferred granularity: one coherent, validated change slice per commit.
- Typical trigger: after implementation + tests are green.

## Required pre-commit validation
- Run relevant syntax/tests for the task.
- For LinkedSpec action-rewriter slices, standard gate is:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`

## Exact workflow steps

1. **Inspect current state**
   - Review status/diff and confirm commit scope.
   - Ensure unrelated artifacts are excluded (for example swap files).

2. **Update persistent docs**
   - Add concise but precise entries to:
     - `CHANGES.md`
     - `DEVELOPMENT_NOTES.md`
     - `MEMORY.md`
   - Include validation commands/results.

3. **Prepare commit message**
   - Populate `git_message_brief.txt` with:
     - Short subject line.
     - Focused body (what changed).
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
- If `git_message_brief.txt` is accidentally committed, remove it from index immediately and restore the untracked-temp-file invariant. Amend when appropriate; otherwise make the corrective follow-up commit right away.
