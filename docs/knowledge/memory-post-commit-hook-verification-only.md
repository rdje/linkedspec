---
id: memory-post-commit-hook-verification-only
title: "MEMORY.md post-commit hook is verification-only and does not rewrite the resume pointer"
answers:
  - "does the post-commit hook update MEMORY.md"
  - "does .githooks/post-commit rewrite MEMORY.md"
  - "why does the MEMORY.md post-commit hook warn after commits"
  - "what happens when MEMORY.md latest_commit lacks a parseable hash"
  - "is LINKEDSPEC-LOW-EFFORT.2 auto-regeneration current behavior"
  - "what owns stale task-tree wording about MEMORY auto regeneration"
date: 2026-07-08
status: current
tags: [memory-architecture, commit-workflow, task-tree-metadata-hygiene, hooks]
evidence: ".githooks/post-commit; docs/tasks/LINKEDSPEC-LOW-EFFORT.md; docs/tasks/TASK-TREE-METADATA-HYGIENE.md; MEMORY.md"
reverify: "sed -n '1,80p' .githooks/post-commit && rg -n 'verification-only|auto-regeneration|post-commit|latest_commit hash not found' docs/tasks/LINKEDSPEC-LOW-EFFORT.md docs/tasks/TASK-TREE-METADATA-HYGIENE.md MEMORY.md .githooks/post-commit"
---

`.githooks/post-commit` verifies `MEMORY.md` after each commit, but it does not
modify the commit or rewrite the file. It reads the current short HEAD hash,
tries to parse a hash from `MEMORY.md` with `latest_commit:`, and prints a soft
warning when the hash is missing, unparseable, or different from HEAD. Both
drift cases exit 0 so the commit is not blocked.

`LINKEDSPEC-LOW-EFFORT.2` previously used auto-regeneration wording. That
wording is superseded by `TASK-TREE-METADATA-HYGIENE.2`: the current behavior is
verification-only. The hard gates remain the pre-commit and local CI checks;
post-commit is a recovery signal for the operator to update `MEMORY.md` through
the normal `COMMIT.md` workflow.
