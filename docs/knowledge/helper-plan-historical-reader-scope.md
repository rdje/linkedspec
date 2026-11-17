---
id: helper-plan-historical-reader-scope
title: Helper-plan recovery defaults to its accepted historical state
answers:
  - "why did helper plan recovery fail after MEMORY advanced"
  - "which epoch does the Perl helper path plan reader recover"
  - "does helper plan reader current mode mean a new runtime verdict"
date: 2026-11-17
status: focused historical/current boundary repair
tags: [history, readers, scope, memory, tasks]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.37; docs/checkpoints/artifact-review-2026-11-17/plan-reader-qualification.json. Actual old default RED, new accepted36428fa1 historical GREEN and explicit current-boundary RED; original sources/inputs/channels/claims retained."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/perl-helper-path-plan-2026-11-17/review.py"
---

The original helper-plan reader checks the live child status, task frontier and
MEMORY pointer. Ordinary transition to a blocked source frontier exposes an
actual refusal at its old pending-status assertion. That does not invalidate
the accepted plan or establish a runtime defect.

Default recovery now reads those state surfaces from accepted36428fa1. Optional
`--current` tests whether that original live boundary still holds; it remains
RED at the recorded handoff. Actual old/new sources and separate command
channels are retained in the later checkpoint. Original producer, before-images,
plan observations and claim values are unchanged.

This applies the existing epoch discipline in
[[normal-hook-archive-reference-contracts]]. It admits no new source role,
runtime, native provenance, canonical test registration or publication result.
