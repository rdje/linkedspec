---
id: retained-unified-diff-storage
title: Retain exact unified diffs as gzip when blank context violates whitespace checks
answers:
  - "why does a retained source patch fail git diff check with trailing whitespace"
  - "how can original unified diff bytes survive a compression storage qualification"
date: 2026-11-07
status: bounded source78.0 storage qualification verified
tags: [artifacts, evidence, diff, gzip, preservation]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.78.0; docs/checkpoints/array-transform-source-perl-2026-11-07/REVIEW.md. Exact diff bytes are gzip-retained with a logical-input mapping. Both original readonly input manifests recover unchanged; wrong logical path and wrong hash reject."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-source-perl-2026-11-07/review_patch_storage.py"
---

A valid unified diff represents a blank context line with one space. Tracking
that text as a new artifact can therefore fail `git diff --cached --check`, even
when the production diff itself is clean. Store new retained diff artifacts as
gzip from the start; do not weaken the whitespace check or strip original bytes.

Source78.0's already captured text diff is preserved byte-for-byte in gzip before
the exact text artifact is removed. Its original logical name and hashes remain
in both original review input manifests. A separate tracked mapping and readonly
reader resolve that logical input to the compressed material, validate every
original declared input and reject wrong logical names or hashes. Original
producers, observations, metadata and SDK/test artifacts remain untouched.

This is the historical source78.0 input boundary. If a declared test, fixture or
wrapper later changes, resolve that leaf's owning commit through Git and use its
original inputs for this qualification; never refresh an old recorded hash.
