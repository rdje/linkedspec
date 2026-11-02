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
  - "why does the executable selector scan flag array false"
  - "how are maintained negative selector fixtures classified"
date: 2026-11-02
status: current
tags: [ci, concurrency, aggregate-selectors, untracked-files, dart, scanner]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.2.3.0; tools/check_executable_aggregate_selector_sources.py; tools/check_public_aggregate_selector_surface.py; tools/run_dart_local.sh
reverify:
  - "bash tools/run_python_project_data.sh tools/check_executable_aggregate_selector_sources.py --concurrency-self-test"
  - "bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
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

## Literal arguments and maintained diagnostic sites

Restoration `TYPE-REFERENCE-BOOK.1.2.20.1.13` restores the explicit uniform-binding supersession note in the
Dart array card; its updated-array behavior paragraph was already correct. Direct selector admission then
reproduces20 executable sites: eight legitimate literal constructors and twelve negative/AST-observation
sites in eight exact files. Public AST and native probes confirm that `true`, `false` and `undef` are literal
arguments; `null`, `nothing` and case variants remain binding names. The public documentation regex had the
same literal false positive, reproduced before the two exact pattern repairs.

Components13.1/.2 preserve original fixtures and runtime code. Executable diagnostics require an exact owned
path, whole-file SHA and diagnostic-line SHA; copied paths, edited files/lines, foreign owners, missing entries
and added positives reject. Literal/binding/mixed-line controls,84 finite denial controls, actual untracked
discovery and staggered concurrency pass. Public inline/fenced literal controls preserve the existing70-file,
40-reference inventory and all eleven migration mutations. Historical audit reverses only the two exact regex
edits, retains its original selector denials and adds six distinguishing edit denials; no fresh runtime admission
is inferred. Exact pre-repair inputs and producer sources are recoverable from
`docs/checkpoints/document-pressure-restoration/selector-source-population.json.gz` and its verified primary
artifact references; the original compressed population reconstructs byte-for-byte. Current focused proof and
rendered book guidance are retained separately. Exact staged canonical CI and normal hooks govern landing.
