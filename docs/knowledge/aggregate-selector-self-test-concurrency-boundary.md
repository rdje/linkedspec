---
id: aggregate-selector-self-test-concurrency-boundary
title: Untracked selector discovery probes must span one serialized repository scan outside backend packages
answers:
  - "why did concurrent aggregate selector scanners reject each other's untracked probes"
  - "why did Dart format report a disappearing aggregate selector probe"
  - "how are aggregate selector discovery self-tests made concurrency safe"
  - "where may the untracked aggregate selector probe be created"
  - "what scope must the aggregate selector scanner lock cover"
  - "why are private array-end callback probes classified by exact path and hash"
  - "did array-end required capture admit retired selectors as public syntax"
date: 2026-10-20
status: current
tags: [ci, concurrency, aggregate-selectors, untracked-files, dart, scanner]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.2.3.0; tools/check_executable_aggregate_selector_sources.py; tools/check_public_aggregate_selector_surface.py; tools/run_dart_local.sh
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/type-evaluated-values/publish.py. Original .7 proof requires accepted557a7d9e533710c6aae211f905ca2f231a8aedae inputs."
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

## Exact private array-end fixture registration

Canonical attempt02 of `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7` exits1 at
aggregate-selector admission after the doctrines and reached runtime checks pass.
The scanner finds three retired-selector string sites in each of the accepted
array-end native probe and its compile-failed draft. Those fixtures call the
private parser with injected callbacks; they do not establish public authoring
acceptance. The existing exact path-and-SHA classification mechanism now registers
only those two unchanged files. No classifier rule, public example, runtime or
historical probe byte changes.

The retained original scanner reports six positive occurrences. The real
`scan_files` function classifies exactly six with the two registrations and
rejects eleven edited/copied/appended-positive/wrong-hash/missing-entry/ordinary
positive controls. Each edited fixture and registry entry restores exactly.
Original380 live bindings/full publication and its actual pre-extension publisher
PASS are preserved before the bounded publisher extension. The complete failed
canonical log remains compressed with its byte count and SHA. This proof covers
fixture classification; fresh composed public admission and exact canonical CI
separately govern landing. Neither failed canonical attempt proves full CI.

Current fixture revisions keep historical registrations and add exact owner/prior/current identities. Three fixtures retain their selector occurrences;28 denials and actual source faults9/6/3 distinguish edited or foreign admissions. See docs/checkpoints/type-values-selector/.
