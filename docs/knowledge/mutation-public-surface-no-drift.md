---
id: mutation-public-surface-no-drift
title: "Current mutation teaching is bound to frozen semantics by one recurring public checker"
answers:
  - "which public documents teach write vivification and map_leaves bang"
  - "how is mutation public no drift checked"
  - "what prevents stale non-vivifying mutation claims"
  - "which mutation examples must the public guide contain"
  - "does mutation public closeout rewrite the frozen authorities"
  - "how many mutation public documents and mutations are governed"
date: 2026-09-05
status: current; public no-drift and parent FUTURE-PARITY-BACKLOG.19 closed under .19.9
tags: [documentation, mutation, autovivification, map-leaves, governance, no-drift, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.9 adds tools/check_mutation_public_surface.py and current examples without changing production or frozen contract bytes. The checker inventories 63 public Markdown files; requires exact current anchors in 14 mutation-owning documents; binds eleven example classes to exact write, map_leaves bang, and composition policy strings; rejects ten stale current claims; and rejects 50 isolated authority/document/status mutations. Canonical CI tracks and runs it unconditionally, while tools/check_capability_conformance.pl pins its .19.9 owner and exact-one registration through four additional mutations."
reverify: "bash tools/run_python_project_data.sh tools/check_mutation_public_surface.py && perl tools/check_capability_conformance.pl"
---

# Mutation public-surface no-drift

The canonical teaching destination is `docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md`.
Fourteen current public documents own exact mutation status or semantics; the checker inventories those documents
within a bounded 63-file public Markdown surface and fails when a new public file appears without explicit review.

The required examples cover missing-container creation, dense arrays, existing-kind conflicts, segment/RHS
evaluation order, original-shape traversal, callback fields, receiver-identity guarding, rollback, detached
results, callback-local nested-write composition, and post-commit continuation. Historical task, decision,
Knowledge, and history records are deliberately outside the stale-current scan.

The public checker reads exact policy strings from [[write-vivification-neutral-contract]],
[[map-leaves-mutation-neutral-contract]], and [[write-map-leaves-neutral-composition]]. It does not alter those
frozen authorities or replace the exact six-runtime behavior proof in [[mutation-recurring-six-runtime-gate]].
