---
id: aggregate-selector-self-test-concurrency-boundary
title: Untracked selector discovery probes must span one serialized repository scan outside backend packages
answers:
  - "why did concurrent aggregate selector scanners reject each other's untracked probes"
  - "why did Dart format report a disappearing aggregate selector probe"
  - "how are aggregate selector discovery self-tests made concurrency safe"
  - "where may the untracked aggregate selector probe be created"
  - "what scope must the aggregate selector scanner lock cover"
date: 2026-07-22
status: current
tags: [ci, concurrency, aggregate-selectors, untracked-files, dart, scanner]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.2.3.0; tools/check_executable_aggregate_selector_sources.py; tools/check_public_aggregate_selector_surface.py; tools/run_dart_local.sh
reverify: "python3 tools/check_executable_aggregate_selector_sources.py --concurrency-self-test; python3 tools/check_public_aggregate_selector_surface.py; cd dart && dart format --output=none --set-exit-if-changed ."
---

The executable aggregate-selector scanner creates a positive untracked Dart source to prove that its
`git ls-files --cached --others --exclude-standard` inventory really discovers and rejects new files. The original
self-test put a unique probe under `dart/test`, removed it after checking, and then scanned the repository. Unique
names prevented same-path collisions but did not isolate concurrent processes: one scanner could include another
scanner's live positive probe, and `dart format .` could enumerate the test file before its owner deleted it.

The ownership boundary is one complete scanner transaction, not probe creation alone. A repository-local advisory
lock now spans probe creation, inventory proof, rejection proof, cleanup, and the final repository candidate scan.
The lock lives in ignored Dart tool state, so it never becomes a source candidate or tracked artifact. The positive
probe lives at the repository root, which remains visible to the git inventory but outside backend package
formatters. Cleanup remains in `finally`.

The public aggregate-selector admission checker runs a deterministic concurrency proof: three scanner processes
hold their probes for staggered intervals, must all succeed under serialization, and must leave no root or legacy
`dart/test` probes. This preserves untracked-source discovery and positive-selector rejection; no probe namespace is
excluded from the actual scan.
