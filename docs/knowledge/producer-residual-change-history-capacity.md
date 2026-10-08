---
id: producer-residual-change-history-capacity
title: One finite change-history rollover precedes producer-bound residual repair
answers:
  - "which change history capacity precedes producer-bound residual repair"
  - "does ADR0129 grant unlimited PNT history reserve"
  - "how are prior bytes preserved in residual repair history"
date: 2026-10-08
status: finite accepted engineering decision; exact canonical admission governs landing
tags: [history, capacity, continuity, replacement, verification]
evidence: "ADR0129 and the owning capacity plan retain the exact clean suffix, original inputs, actual rollover channels and independent reconstruction. Only five finite registry scalars change."
reverify: "At the owning committed boundary run bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0-capacity.py review. Later changed inputs require historical claim preservation; the one-shot apply/publish producers must not be replayed."
---

The clean activation is `e7674382295936a1d6d3dbd34272d9c6803a269d`.
ADR0129 admits one archive member and its actual manifest row, plus one indexed
decision and its measured line allowance. Every prior archive, manifest row,
accepted decision and unrelated registry row remains byte-identical. Root,
segment and aggregate history budgets and rollover thresholds stay unchanged.

The source and exact range/hash are owned by the retained
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0-plan.json`.
Independent reconstruction and effective corruptions separate losslessness
from merely fitting the new capacity. Actual production functions separately
reject missing, proposed, duplicate and malformed accepted authority.

Initial publication normalized unrelated JSON rows and appended the new ADR
after the index instructions. Its exact used source, initial registry/index
and first review survive. Final publication restores unrelated physical rows
and puts the single decision into the table; the strengthened reviewer checks
both. No parser repair, book behavior change, new explicit director grant,
unlimited reserve or verification waiver is claimed. Producer-bound residual
selection follows the clean capacity commit.
