---
id: memory-post-commit-hook-verification-only
title: "MEMORY.md post-commit hook is verification-only and does not rewrite the resume pointer"
answers:
  - "does the post-commit hook update MEMORY.md"
  - "does .githooks/post-commit rewrite MEMORY.md"
  - "why does the MEMORY.md post-commit hook warn after commits"
  - "what happens when MEMORY.md latest_commit lacks a parseable hash"
  - "does the post-commit hook validate activation_commit against HEAD first parent"
  - "is LINKEDSPEC-LOW-EFFORT.2 auto-regeneration current behavior"
  - "what owns stale task-tree wording about MEMORY auto regeneration"
date: 2026-07-30
status: current
tags: [memory-architecture, commit-workflow, task-tree-metadata-hygiene, hooks]
evidence: ".githooks/post-commit; scripts/check_memory_commit_pointer.sh; tools/test_memory_commit_pointer.sh; ADR 0065; docs/tasks/MEMORY-COMMIT-POINTER-ENFORCEMENT.md"
reverify: "bash tools/test_memory_commit_pointer.sh && sed -n '1,80p' .githooks/post-commit && sed -n '1,220p' scripts/check_memory_commit_pointer.sh"
---

`.githooks/post-commit` verifies `MEMORY.md` after each commit, but it does not
modify the commit or rewrite the file. It delegates to the shared phase-aware
checker, reads committed `HEAD:MEMORY.md`, and requires `activation_commit` to
resolve to exact first parent `HEAD^1`. The initial repository commit uses
the explicit `root` sentinel. A malformed field or genuine mismatch emits a soft,
actionable recovery warning because the commit already exists.

ADR `0065` and `MEMORY-COMMIT-POINTER-ENFORCEMENT.1` supersede the
self-referential historical `latest_commit == HEAD` comparison while retaining
verification-only post-commit behavior. The hard pre-commit gate checks the staged
pointer against current `HEAD`; the memory doctrine/local CI auto-check the
appropriate dirty or clean phase. Post-commit remains a recovery signal through the
normal `COMMIT.md` workflow.
