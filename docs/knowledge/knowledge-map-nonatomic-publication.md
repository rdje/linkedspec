---
id: knowledge-map-nonatomic-publication
title: Knowledge Map generator publishes directly and can expose partial output
answers:
  - "why did git diff briefly show the entire Knowledge Map deleted"
  - "is Knowledge Map regeneration atomic"
  - "which task owns partial Knowledge Map publication"
date: 2026-10-30
status: P2 owned20.1.1 before admission; await terminal generation before reads
tags: [knowledge-map, continuity, publication, concurrency]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.56.3.0 observed live generator/read overlap; generator session58884 later exited0 and completed map retained intended changes. Source: knowledge-map/scripts/gen_knowledge_map.sh rendering block redirects directly to KM_OUTPUT, with validation afterward."
reverify: "rg -n 'KM_OUTPUT|validate_output' knowledge-map/scripts/gen_knowledge_map.sh; inspect rendering redirection and await actual terminal generation before git diff -- KNOWLEDGE_MAP.md"
---

The generator renders directly into KM_OUTPUT. Shell redirection truncates that
file before the block writes it; validation afterward cannot make publication
atomic. A concurrent diff during Dart56.3.0 finalization read partial content and
reported apparent mass deletion. The completed exit0 file immediately had only
intended changes and remained intact. No current map loss or runtime defect is
inferred from that transient diff. Interruption during rendering could leave a
partial derived map until regeneration.

Owner TYPE-REFERENCE-BOOK.1.2.20.1.1 schedules atomic same-directory publication
with interruption/reader/path validation controls under infrastructure/canonical
proof before admission/push. Until then, serialize generation and dependent reads;
consume actual terminal success before build, diff or staging. Use a separate
project-local KM_OUTPUT for future controlled interruption, never the live map.
