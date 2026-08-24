---
id: change-history-twenty-first-member-capacity
title: Change history has a finite twenty-one-member routing capacity
answers:
  - "how many files may the bounded change history contain now"
  - "how many lines may the change history manifest contain now"
  - "why did change history routing capacity increase to twenty-one files"
  - "which ADR authorizes change history segment 4992"
  - "did change history aggregate pressure limits increase for segment 4992"
date: 2026-08-24
status: current
tags: [documentation, history, rollover, routing, pressure, doctrine, continuity]
evidence: "FUTURE-PARITY-BACKLOG.14.6.5.2 mandatory rollover creates immutable change segment 4992 from exact clean activation commit bb34a85e. The resulting collection is 21 files / 46,371 lines / 3,308,828 bytes with a 20-line manifest; root, per-history-file, aggregate-line, aggregate-byte, and manifest-byte controls remain below their existing ceilings. ADR 0086 authorizes only max_files 20→21 and manifest max_lines 19→20. Owner, lifecycle, verifier, patterns, every byte control, aggregate ceilings, and ADR 0069 storage authority do not change. The infrastructure movement upgrades the carrier leaf from focused to receipt-bound canonical verification."
reverify: "perl tools/roll_document_history.pl --surface change_history --check && bash scripts/check_readme_stability.sh && wc -lc CHANGES.md docs/history/changes/manifest.jsonl docs/history/changes/*.md"
---

# Change-history twenty-first-member capacity

The bounded change-history store consists of the current root, its manifest, and immutable content-addressed
segments. The mandatory rollover that creates segment `4992` adds exactly one segment and one manifest record, so
finite collection controls advance to twenty-one files and twenty manifest lines.

This is not a refreshed high-water mark. Aggregate ceilings remain 55,000 lines and 4,194,304 bytes; the current
root remains capped at 512 lines / 65,536 bytes; each history segment remains capped at 4,096 lines / 524,288
bytes; and the manifest remains capped at 16,384 bytes. Any twenty-second member requires another exact staged
ADR.

## Links

- Decision: [ADR 0086](../decisions/0086-change-history-twenty-first-member-capacity.md).
- Store authority: [ADR 0069](../decisions/0069-bounded-change-and-notes-history.md).
- Prior finite capacity: [[change-history-twentieth-member-capacity]].
- Owner: [FUTURE-PARITY-BACKLOG.14.6.5-8](../tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md) `.14.6.5.2`.
