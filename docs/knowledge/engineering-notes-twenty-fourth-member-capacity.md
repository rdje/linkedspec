---
id: engineering-notes-twenty-fourth-member-capacity
title: Engineering-notes segment 4984 requires exactly 24 collection files and 23 manifest lines
answers:
  - "which ADR authorizes engineering notes segment 4984"
  - "why does engineering notes history allow 24 files"
  - "what are engineering notes routing limits after the startup reading rollover"
date: 2026-09-06
status: current
tags: [documentation, history, rollover, capacity, doctrine]
evidence: "SESSION-STARTUP-READING.3.2.21 archives exact clean ba9a494c source lines 238–460; independent source/blob/SHA-256 and prior-manifest comparison pass. ADR 0103 admits only collection max_files 23→24 and manifest max_lines 22→23."
reverify: "perl tools/roll_document_history.pl --surface engineering_notes --check && bash scripts/check_readme_stability.sh && wc -lc DEVELOPMENT_NOTES.md docs/history/development-notes/manifest.jsonl docs/history/development-notes/*.md"
---

The September 6 checkpoint below is historical; current finite capacity is recorded in
[[engineering-notes-twenty-fifth-member-capacity]] under ADR `0105`.

Required rollover `4984` preserves 223 lines / 22,371 bytes under SHA-256
`dd7eba212246efd893dbff32143a2c821576c7a704e1a697265213dc728d1f9a`. The resulting collection contains 22
immutable segments, the bounded root, and a 23-record manifest: 24 files / 25,194 lines / 2,691,497 bytes.
The root is 245 lines / 20,216 bytes and the manifest is 13,782 bytes at this checkpoint.

ADR `0103` changes only the two finite count controls. Aggregate ceilings remain 27,000 lines / 3,145,728 bytes,
root ceilings 512 lines / 65,536 bytes, segment ceilings 4,096 lines / 524,288 bytes, and manifest byte ceiling
16,384. Immutable content, prior manifest records, owner, lifecycle, patterns, and verifier are unchanged.
The exact route movement requires canonical verification; any later increase needs a new indexed decision.

Related: [[bounded-change-notes-history-contract]], [[engineering-notes-twenty-second-member-capacity]],
`docs/decisions/0101-engineering-notes-twenty-third-member-capacity.md`, and
`docs/decisions/0103-engineering-notes-twenty-fourth-member-capacity.md`.
