---
id: startup-task-chronology-compaction
title: Startup chronology is derived from Git and canonical per-leaf commit records
answers:
  - where is the completed startup batch chronology
  - why was the startup task commit table removed
  - how was startup task compaction checked without losing evidence
  - what owns current task collection pressure cleanup
date: 2026-09-08
status: source equivalence verified; containment .5 canonical closeout required
tags: [continuity, task-tree, history, containment]
evidence: "LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5 checks all 100 batch ordinal/leaf/hash identities against first-parent Git history and all 102 duplicate commit subjects against canonical task nodes; every completion note is retained verbatim beside its node's Commit field. Other task-node fields and stable IDs are identical."
reverify: 'git log --reverse --first-parent --format="%h %s" a5d5dcd2955aaaa41166bd87de6bdc39a4502bc4..fb307dae35d0ecfdcbb4b29e65bec36855d6971b'
---

# Exact retained owners

Canonical leaf nodes in `docs/tasks/SESSION-STARTUP-READING.md` retain the exact commit subjects and
all 102 completion notes. Their other fields, stable IDs, and source-reading scope remain unchanged.
Git is the complete immutable commit authority; the removed table duplicated subjects already in those nodes.
The 100-item enumeration is exactly reproducible through the command above. The earlier `.1` checkpoint
is outside that batch. Current execution state remains in `MEMORY.md` and each task's frontier.

Comparison source: clean `e455be6a3c85cb7a75bc7ccd36c579efe74bcc97:docs/tasks/SESSION-STARTUP-READING.md`;
whole-file SHA-256 `fff0d54a37685f8b3792be8a4c221627a3b3efcd35ccbe08c259ce00f6b0ab43`.
The removed batch is source lines 6917–7003, 4361 bytes,
SHA-256 `343b4e562a42fa056b1105c9a5c898ff5620c3dfb6b1592ee3716bbacbea51da`. All listed ordinal/leaf/hash triples
agree with the 100 first-parent commits ending at `fb307dae35d0ecfdcbb4b29e65bec36855d6971b`.

Exact source retrieval: `git show e455be6a3c85cb7a75bc7ccd36c579efe74bcc97:docs/tasks/SESSION-STARTUP-READING.md`.
No immutable task part, history segment, route registry, limit or implementation file changes in this cleanup.
The separately retained verification and changelog sections remain available for their additional context.
