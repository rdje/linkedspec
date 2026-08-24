---
id: change-history-twentieth-member-capacity
title: Change history has a finite twenty-member routing capacity
answers:
  - "how many files may the bounded change history contain"
  - "how many lines may the change history manifest contain"
  - "why did change history routing capacity increase to twenty files"
  - "which ADR authorizes change history segment 4993"
  - "did change history aggregate pressure limits increase for segment 4993"
date: 2026-08-17
status: former finite capacity; superseded by ADR 0086 twenty-first-member step
tags: [documentation, history, rollover, routing, pressure, doctrine, continuity]
evidence: "FUTURE-PARITY-BACKLOG.14.6.2.3 mandatory rollover creates immutable change segment 4993. The resulting collection is 20 files / 46,130 lines / 3,286,198 bytes with a 19-line manifest, while root, per-history-file, aggregate-line, aggregate-byte, and manifest-byte controls remain below their existing ceilings. ADR 0082 authorizes only max_files 19→20 and manifest max_lines 18→19; owner, lifecycle, verifier, patterns, and ADR 0069 storage authority do not change."
evidence_update_2026_08_24: "FUTURE-PARITY-BACKLOG.14.6.5.2 mandatory rollover creates segment 4992 and ADR 0086 advances only finite file/manifest-line capacity to 21/20. This card remains the historical twentieth-member boundary; change-history-twenty-first-member-capacity owns current limits."
reverify: "perl tools/roll_document_history.pl --surface change_history --check && bash scripts/check_readme_stability.sh && wc -lc CHANGES.md docs/history/changes/manifest.jsonl docs/history/changes/*.md"
---

# Change-history twentieth-member capacity

The bounded change-history store consists of the current root, its manifest,
and immutable content-addressed segments. The rollover that creates segment
4993 adds exactly one segment and one manifest record, so finite collection
controls advance to twenty files and nineteen manifest lines.

This is not a refreshed high-water mark. Aggregate ceilings remain 55,000 lines
and 4,194,304 bytes; the current root remains capped at 512 lines / 65,536
bytes; each history segment remains capped at 4,096 lines / 524,288 bytes; and
the manifest remains capped at 16,384 bytes. The required twenty-first member is now separately authorized by
ADR `0086`; this card preserves the prior exact finite boundary.

## Links

- Decision: [ADR 0082](../decisions/0082-change-history-twentieth-member-capacity.md).
- Store authority: [ADR 0069](../decisions/0069-bounded-change-and-notes-history.md).
- Owner: [FUTURE-PARITY-BACKLOG.14](../tasks/FUTURE-PARITY-BACKLOG.14.md) `.14.6.2.3`.
- Current capacity: [[change-history-twenty-first-member-capacity]].
