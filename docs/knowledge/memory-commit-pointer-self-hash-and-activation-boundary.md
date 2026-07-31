---
id: memory-commit-pointer-self-hash-and-activation-boundary
title: "MEMORY.md records the leaf activation boundary because a commit cannot contain its own hash"
answers:
  - "can a Git commit contain its own hash in MEMORY.md"
  - "what commit hash should MEMORY.md store"
  - "why is latest_commit equal to HEAD self-referential"
  - "what does activation_commit mean in MEMORY.md"
  - "what should the pre-commit memory pointer check compare"
  - "what should the post-commit memory pointer check compare"
  - "who owns the MEMORY post-commit self-hash correction"
date: 2026-07-30
status: current
tags: [memory-architecture, commit-workflow, git, hooks, continuity, enforcement]
evidence: "ADR 0065; docs/tasks/MEMORY-COMMIT-POINTER-ENFORCEMENT.md; .githooks/post-commit; MEMORY.md; Git first-parent history 4a044914..b9c3e676"
reverify: "git rev-list --count --merges HEAD && git show HEAD:MEMORY.md && git show HEAD^1:MEMORY.md && sed -n '1,120p' .githooks/post-commit"
---

A normal Git commit cannot contain its own literal hash in tracked `MEMORY.md`: the hash covers the tree, so
changing the embedded value changes the resulting commit identity. Adding a cleanup commit repeats rather than
solves the self-reference. Git itself is the canonical current-commit owner.

The 31 consecutive first-parent commits from `4a044914` through `b9c3e676` that contain a parseable
`latest_commit` value all store the exact short hash of their immediate first parent; none stores itself. The
branch had 2,418 commits and zero merge commits when measured on 2026-07-30.

ADR `0065` names that value honestly as `activation_commit`: the clean `HEAD` from which a leaf starts. Before
the leaf commit it must equal current `HEAD`; in the committed leaf it must equal `HEAD^1`. The leaf ID/subject
joins the activation boundary to the landing commit, whose exact identity is always derived from Git. Tree
`MEMORY-COMMIT-POINTER-ENFORCEMENT` owns implementation and historical reconciliation.
