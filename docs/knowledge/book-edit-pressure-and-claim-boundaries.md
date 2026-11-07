---
id: book-edit-pressure-and-claim-boundaries
title: Mutable book edits must respect every routed cap and dated claim binding
answers:
  - "why can mdBook render pass while the CI chapter exceeds a commit budget"
  - "why did the 4.16 book edit reject a live advisory claim input"
  - "which claim preserves the CI chapter at the November7 boundary"
  - "how can a book edit preserve old measurements without refreshing input hashes"
  - "why do old claim preservation recipes require their accepted Git inputs"
date: 2026-11-07
status: scoped book/claim preservation verified; normal hooks govern landing
tags: [book, doctrine, claim-verification, historical-inputs, routing]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.16; book-budget-record.json, actual bound validator RED/GREEN and advisory-preservation-result.json in docs/checkpoints/task-headroom-lua-2026-11-07/."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/task-headroom-lua-2026-11-07/preserve_advisory_claim.py"
---

The diagnostics surface in doctrine/readme_stability/routes.jsonl separately caps
the local-CI chapter at2048 lines. Broader public-reference admission and a
successful mdBook render do not replace that control. Check every matching routed
surface before editing.4.16 retains its2063-line draft; only its own new example
becomes inline, two redundant outside-example blank lines are removed, and every
pre-existing fenced example remains byte-exact. The chapter fits2047 lines.

Before qualification, an exact claim-input search finds110 historical chapter
bindings and one live binding:4.8/intersecting-claim-mode-only-preservation. Actual selected validation
rejects the edited book. Only that claim's durability mode/revision changes to
historical at clean2286c6606a9fb86290801e1c8a0053e59d342a1f. All64 original input
rows are independently verified there; every statement/result/hash and the two
unselected claims stay exact. Six type/field/hash/revision/population controls and
actual bound validator RED/GREEN pass. No new pack/publication measurement.

The initial recorder's expected diagnostic word was wrong; its actual inner
validator rejection, channels and failing instrument remain. Separate bound
recording retains producer/material bytes before use and complete wrapper channels.
Its checker explicitly overlays only current book/record over a captured index;
ordinary complete staged validation remains authoritative at landing.

Old artifact-growth preserve_claim.py/preserve_publication_claim.py recompute a
then-current edited-book hash and compare it with retained reports. Their original
recipes require their accepted Git boundary; they are not fresh measurements of
later book edits. The new preserver replays captured edited bytes and fixed-Git
inputs, so future live prose does not masquerade as or invalidate that dated proof.
Full OS/toolchain/transitive closure remains separate4.2/SESSION5.
