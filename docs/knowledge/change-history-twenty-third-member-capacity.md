---
id: change-history-twenty-third-member-capacity
title: Change history has a finite twenty-three-member routing capacity
answers:
  - "how many files may the bounded change history contain now"
  - "how many lines may the change history manifest contain now"
  - "why did change history routing capacity increase to twenty-three files"
  - "which ADR authorizes change history segment 4990"
  - "did change history aggregate pressure limits increase for segment 4990"
date: 2026-08-26
status: historical finite boundary; superseded by the exact twenty-fourth-member capacity
tags: [documentation, history, rollover, routing, pressure, doctrine, continuity]
evidence: "FUTURE-PARITY-BACKLOG.14.7.5.0 mandatory rollover creates immutable change segment 4990 from exact clean activation commit 94d20bec. The resulting collection is 23 files / 46,806 lines / 3,348,383 bytes with a 22-line manifest. ADR 0091 authorizes only max_files 22→23 and manifest max_lines 21→22. Root, per-history-file, aggregate-line, aggregate-byte, and manifest-byte controls remain below their existing ceilings. Owner, lifecycle, verifier, patterns, every byte control, aggregate ceilings, and ADR 0069 storage authority do not change. The infrastructure movement upgrades the dormant-RED leaf from focused to receipt-bound canonical verification."
evidence_update_2026_08_27: "FUTURE-PARITY-BACKLOG.14.7.7.2 mandatory rollover creates segment 4989. ADR 0093 advances only finite collection and manifest-line capacity to 24 files / 23 manifest lines. This card preserves the exact historical twenty-third-member boundary; change-history-twenty-fourth-member-capacity owns current limits."
reverify: "perl tools/roll_document_history.pl --surface change_history --check && bash scripts/check_readme_stability.sh && wc -lc CHANGES.md docs/history/changes/manifest.jsonl docs/history/changes/*.md"
---

# Change-history twenty-third-member capacity

The bounded change-history store consists of the current root, its manifest, and immutable content-addressed
segments. Mandatory segment `4990` adds exactly one segment and one manifest record, so finite collection controls
advance to twenty-three files and twenty-two manifest lines.

This is not a refreshed high-water mark. Aggregate ceilings remain 55,000 lines and 4,194,304 bytes; the current
root remains capped at 512 lines / 65,536 bytes; each history segment remains capped at 4,096 lines / 524,288
bytes; and the manifest remains capped at 16,384 bytes. ADR `0093` subsequently authorizes the exact twenty-fourth
member.

## Links

- Decision: [ADR 0091](../decisions/0091-change-history-twenty-third-member-capacity.md).
- Store authority: [ADR 0069](../decisions/0069-bounded-change-and-notes-history.md).
- Prior finite capacity: [[change-history-twenty-second-member-capacity]].
- Current finite capacity: [[change-history-twenty-fourth-member-capacity]].
- Owning task: [[FUTURE-PARITY-BACKLOG]] `.14.7.5.0`.
