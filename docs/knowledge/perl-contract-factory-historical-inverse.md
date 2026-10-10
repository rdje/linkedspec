---
id: perl-contract-factory-historical-inverse
title: Historical Contracts replay admits exactly the two committed private factory changes
answers:
  - "why did canonical CI reject unreviewed boundary contract drift after private factory capture"
  - "how does the historical audit normalize Contracts private dependency and constructor changes"
  - "does historical Contracts reconciliation admit unrelated source changes"
  - "does the private factory historical inverse rerun old runtime producers"
date: 2026-10-10
status: exact committed-source inverse and isolated recovery verified; canonical receipt required before landing
tags: [historical-audit, perl, contracts, factories, claims, verification]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3 owns the canonical blocker. The old auditor requires decoder-only b2156813 bytes; current Contracts exactly matches accepted constructor33e57dee after dependencybe7d7071. Exact Git parent/source lineage joins baseline2d878478 to b2156813. Full isolated recovery preserves134 inputs/84613241 bytes,22 recovery controls and64 evolution denials with zero healthy original-log reads/tracked writes. Original runtime/book241 bindings are preserved at cdc45f9cb before book teaching changes; complete book57/two controls pass."
reverify: "Historical commands below require the card's recorded accepted Git inputs; they do not run against later source/book edits. bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-audit-review.py; original capacity and metadata repair readonly reviewers remain separately valid. Preserve current claim inputs before future writes. Current local-return integration, complete book and original399 preservation: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0-final-review.py under tools/run_python_project_data.sh; use only readonly defaults. MEMORY.md owns the current frontier."
---

The canonical gate passed all ten doctrines, syntax and structural checks before
its historical recovery proof rejected Contracts. The auditor only admitted the
earlier decoder import/loop inverse. Current Contracts has no post-constructor
drift: its complete bytes equal committed33e57dee. The missing compatibility
inverse is an auditor defect, owned as a P1 prerequisite of this canonical slice.

`restore_contract_factory_capture` binds exactly dependencybe7d7071 and
constructor33e57dee. Their whole-file Git parents must join baseline2d878478,
which equals the earlier b2156813 decoder source. Current source must equal the
complete accepted constructor blob; every later or foreign byte change rejects.
Only then does the existing decoder inverse recover the original historical
source and hash. Metadata reports both accepted factory owners and exact revisions.

This is explicit committed-source reconciliation, not refreshed historical
runtime execution or expanded factory admission. Original milestones, checkpoints,
source hashes and all archived logs remain exact. The retained original auditor,
failed staged binary candidate and actual RED recovery channel precede the repair.
The complete recovery proof preserves134 inputs/84,613,241 bytes and retains22
recovery controls/64 source-evolution denials with zero healthy original-log reads
or tracked writes. Four new source controls alter actual private bindings or
registration; old unrelated/decoder faults still reject.

Before book teaching edits, all241 committed block-component runtime/book
bindings are preserved at clean cdc45f9cb with mode/revision-only changes. Runtime
fixture review remains source-bound; the newer complete57-source book has both
missing-SUMMARY and removed-rendered-marker controls. Exact staged canonical CI,
its receipt and normal hooks still govern landing. No current runtime, threshold
checker, dependency pin or external repository is changed by this repair.
