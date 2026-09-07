---
id: change-history-twenty-ninth-member-capacity
title: Change-history segment 4984 requires exactly 29 collection files and 28 manifest lines
answers:
  - "which ADR authorizes change history segment 4984"
  - "why does change history allow 29 collection files"
  - "what are change history routing limits after the runtime reading checkpoint"
date: 2026-09-06
status: historical capacity; superseded by ADR0106 under SESSION-STARTUP-READING.3.3.38
tags: [documentation, history, rollover, capacity, doctrine]
evidence: "SESSION-STARTUP-READING.3.2.41 archives exact clean e548ce4b source lines 248–459; independent source/blob/SHA-256/count and prior-manifest comparison pass. ADR 0104 admits only collection max_files 28 to 29 and manifest max_lines 27 to 28."
reverify: "perl tools/roll_document_history.pl --surface change_history --check && bash scripts/check_readme_stability.sh && wc -lc CHANGES.md docs/history/changes/manifest.jsonl docs/history/changes/*.md"
---

The required complete checkpoint takes the current root to 464 lines, triggering ADR 0069's 90% rollover.
Segment `4984` preserves exact clean source `e548ce4be5d3164ab8be54dc3d63dece2dda0ffb` lines 248–459:
212 lines / 19,054 bytes, SHA-256 `d720d564937dc8d5f5d14a2942335ec874a481dda01e8824b2956a0742e9c69f`.
The source Git blob is `daf0f6f1a571377da88009f340a844ff627ff10f`. Prior segment records remain byte-identical;
the manifest header's segment count increases from 26 to 27.

After current-root-only EOF whitespace normalization, the root is 251 lines / 18,276 bytes and the manifest
28 lines / 15,887 bytes. Twenty-seven immutable segments, root, and manifest total 29 files / 48,131 lines /
3,467,471 bytes. The archive bytes are unchanged by that current-root normalization.

ADR `0104` changes only max_files 28 to 29 and manifest max_lines 27 to 28. Aggregate ceilings remain
55,000 lines / 4,194,304 bytes; root 512 / 65,536; segment 4,096 / 524,288; manifest bytes 16,384.
Owner, lifecycle, patterns, verifier, and storage authority stay unchanged. Routing already moved complete
old records out of the root; deleting or rewriting accepted history cannot provide the missing count slots
under the immutable-store contract. Exact staged canonical verification is required before this infrastructure
checkpoint lands. Every later capacity increase needs a newly indexed exact-limit decision.

Related: [[bounded-change-notes-history-contract]],
`docs/decisions/0102-change-history-twenty-eighth-member-capacity.md`, and
`docs/decisions/0104-change-history-twenty-ninth-member-capacity.md`.

## September 7 successor

Required segment 4983 consumes another member and exceeds the manifest byte ceiling by 79 bytes.
ADR0106 admits exactly 30 collection files, 29 manifest lines and 16,463 manifest bytes; all other controls
remain unchanged. `change-history-thirtieth-member-capacity.md` owns the current measured boundary.
The preceding evidence above remains the exact historical ADR0104 admission.
