---
id: publication-approximate-budget
title: Director clarifies that the 1.5GB checkpoint target is approximate
answers:
  - "does the1.5GB publication target require an exact byte boundary"
  - "what did the director authorize before the November17 checkpoint push"
  - "must source registration close before the authorized November17 checkpoint"
date: 2026-11-17
status: director clarification received; canonical checkpoint publication next
tags: [publication, git, authority, checkpoint, budget]
evidence: "Exact director reply and initial question retained in docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md and director-reply.json; adopted in TYPE-REFERENCE-BOOK.1.2.23.4.30/.30.2 and handoff37."
reverify: "Read the received clarification and its exact reply in docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md, then the current publication leaf."
---

The director clarifies that around1.5GB permits a little below or above. Finish
the current retention/reader slice, run full exact-candidate canonical CI and
normal workflow, then push the checkpoint. No further approval is pending.

This resolves the priority question against unfinished discovery/registration:
the authorized checkpoint may publish first, while every original source,
registration and native-admission owner remains open. Resume PNT after the push.
Do not label the checkpoint as admission of unregistered tests or provenance.

The existing monitor trigger remains a preparation signal; no exact-byte push,
new hard cap, rewritten history or skipped CI is authorized. See
[[github-size-safe-publication]] for the monitor, output scope and uncertainty.
