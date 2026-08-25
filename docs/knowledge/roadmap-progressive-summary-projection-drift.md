---
id: roadmap-progressive-summary-projection-drift
title: Progressive roadmap summaries can drift independently from their current lead projection
answers:
  - "why did the roadmap still say progressive rollout 4/9 after Julia admission"
  - "why did ROADMAP V2 still say Julia progressive admission was pending"
  - "which roadmap projections were stale after Julia progressive closeout"
  - "does roadmap synchronization enforce agreement between the lead and summary table"
date: 2026-08-25
status: repaired under FUTURE-PARITY-BACKLOG.14.6.6.0
tags: [roadmap, projection, drift, progressive-parsing, Julia, continuity, root-cause]
evidence: "At clean e25791e5, the lead progressive paragraphs in ROADMAP.md and ROADMAP_V2.md correctly recorded Julia closeout at 5/9/106, while their Future parity backlog summary-table rows still recorded 4/9/103 and .14.6.5.3-.4 pending. Git blame fixes both stale rows at carrier commit 35a2b56c; admission 7823f6fc and recomposition e25791e5 changed only the lead projections. Existing roadmap/README/task/Knowledge doctrines bound size, routing, metadata, and selected content but did not compare repeated live claims inside each roadmap. FUTURE-PARITY-BACKLOG.14.6.6.0 repairs both bounded current rows while recording the causal gap; dated historical evidence remains unchanged."
reverify: "rg -n 'Progressive.*5/9|Future parity backlog.*5/9/106|Lua.*85-pass/one-RED|Lua.*private authority' ROADMAP.md ROADMAP_V2.md; ! rg -n 'Progressive neutral \\+ Perl \\+ Rust \\+ Dart (rollout )?is 4/9/103|[.]3-[.]4.*admission and recomposition' ROADMAP.md ROADMAP_V2.md"
---

# Roadmap repeated-current projection drift

The roadmaps contain a detailed current lead and a compact status-table row.
They are separate manually maintained projections. Julia admission and
recomposition advanced only the lead text, leaving both compact rows at the
earlier carrier boundary.

The existing gates correctly checked bounded size, route ownership, task
metadata, and other governed phrases, but did not assert semantic equality
between these repeated roadmap claims. Lua RED synchronization repaired both
rows and records this limitation so later admissions review every repeated
current projection, not only the lead paragraph.

Related facts: [[progressive-span-dispatch-audit-plan]] and
[[julia-progressive-span-dispatch-recomposition]].
