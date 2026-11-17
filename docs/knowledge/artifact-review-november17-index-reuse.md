---
id: artifact-review-november17-index-reuse
title: November17 retention review recovers its exact logical Git input from the clean base
answers:
  - "where is the November17 artifact retention review"
  - "how is the artifact census Git index input retained without another large archive"
  - "did November17 cleanup remove caches or proof"
date: 2026-11-17
status: focused retention metadata and exact logical input recovery; native physical closure remains open
tags: [artifacts, cleanup, retention, git, inputs]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.37; docs/checkpoints/artifact-review-2026-11-17/. Dated1322 rows/eight named scopes/six evidence controls and stage-byte source RED; separate readonly recovery, zero removals."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/artifact-review-2026-11-17/review.py"
---

The published primary scanner and independent scandir/lstat walk agree on the
dated path/suffix/byte rows. Every artifact, cache and proof remains retained.
The latest-only date and summary live in `docs/ARTIFACT_CLEANUP.md`.

Before interpreting the actual `git ls-files --stage -z` input, the capture
compares it byte-for-byte with sorted mode/object/path rows reconstructed from
the clean-base `git ls-tree -r -z` output. The retained base, source commands,
byte count and SHA256 recover the exact logical stream without copying another
large base64 index packet. An actual source-stream stage0-to-stage1 alteration
is RED; the real Git index remains unchanged. Wrong index identity is also one
of the six effective evidence controls.

This is logical input recovery, not physical-index/cache/native/filesystem
custody. The review is dated and limited to the existing eight scopes, not a
whole-project census, liveness, deletion or reclamation guarantee. Complete
native/OS/outer-first-use/per-read/source-origin/physical closure remains4.2/
SESSION5. The director approximate-budget/checkpoint clarification is retained separately in
`docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md`.
