---
id: task-verification-single-owner
title: Each staged commit changes verification declarations for exactly one task leaf
answers:
  - "can I declare verification tiers for pending future leaves in the current commit"
  - "why does verification cadence reject two changed owners"
  - "when should planned task verification become exact declarations"
date: 2026-10-02
status: current enforced workflow; no policy or checker change
tags: [task-tree, verification, continuity, commit]
evidence: "tools/check_task_verification_fields.pl compares three declarations by stable ID; its14 controls reject split ownership. SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.1 hook rejected premature future closeout fields; corrected owner passed all9 doctrines and committed f07d827f7."
reverify: "perl tools/check_task_verification_fields.pl --self-test && bash scripts/check_verification_cadence.sh"
---

The staged task-tree delta must change `Verification tier`, `Focused checks` and `Canonical trigger`
for exactly one stable leaf ID. Each declaration must appear once and be nonempty; tier is focused
or canonical. Comparison follows task identity, so relocating unchanged historical fields creates
no new owner. Merely updating status without new declarations does not satisfy the owning slice.

Keep verification plans for future pending leaves in prose. At activation from clean HEAD, declare
the three exact fields for that leaf before implementation. Declaring fields for both the current
repair and its future closeout creates two owners and correctly blocks the current commit. Do not
bypass the hook or weaken the checker; defer the future declarations until their own activation.
