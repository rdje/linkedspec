---
id: engineering-notes-twenty-fifth-member-capacity
title: Engineering-notes segment 4983 requires exactly 25 collection files and 24 manifest lines
answers:
  - "which ADR authorizes engineering notes segment 4983"
  - "why does engineering notes history allow 25 files"
  - "what are current engineering notes routing limits after the September 7 startup rollover"
  - "which startup leaf owns the next projected engineering notes rollover"
date: 2026-09-07
status: historical capacity; superseded by engineering-notes-twenty-sixth-member-capacity
tags: [documentation, history, rollover, capacity, doctrine]
evidence: "SESSION-STARTUP-READING.3.3.12 archives exact clean 75ce8db8 source lines 253–458; independent source/blob/SHA-256 and prior-manifest comparison pass. ADR 0105 admits only collection max_files 24→25 and manifest max_lines 23→24."
reverify: "perl tools/roll_document_history.pl --surface engineering_notes --check && bash scripts/check_readme_stability.sh && wc -lc DEVELOPMENT_NOTES.md docs/history/development-notes/manifest.jsonl docs/history/development-notes/*.md"
---

Required rollover `4983` preserves 206 lines / 17,316 bytes under SHA-256
`274cdb2ddc2b6672965d365d2cb98b0f7800db1e84f491bb2ec4436c2d98a6d1`. The new collection has 23 immutable
segments, the bounded root, and a 24-line manifest: 25 files / 25,411 lines /
2,715,309 bytes at this checkpoint. The updated root is 255 lines /
26,100 bytes; the manifest is 14,394 bytes.

The source is clean activation `75ce8db839888a5091d25ee4e5e1c3c501daf3b8`, lines 253–458, blob
`20a8202bafbcdb83a06be8c956fdafea33c18060`. Independent comparison proves exact segment bytes, digest and
source identity; every prior manifest row remains byte-identical in order. Before the two count changes,
the pressure checker fails only files 25/24 and manifest lines 24/23.

ADR `0105` changes only those finite count controls. Aggregate ceilings remain 27,000 lines / 3,145,728 bytes,
root ceilings 512 lines / 65,536 bytes, segment ceilings 4,096 lines / 524,288 bytes, and manifest byte ceiling
16,384. Immutable content, prior manifest rows, owner, lifecycle, patterns, and verifier stay unchanged.
The rollover retained a final blank separator in the mutable root; trimming that one newline satisfies
Git whitespace checks without changing any immutable source bytes. The route movement requires exact staged
canonical verification before landing. A later increase requires
another indexed decision; these measurements do not establish future capacity.

Related: [[bounded-change-notes-history-contract]], [[engineering-notes-twenty-fourth-member-capacity]],
and `docs/decisions/0105-engineering-notes-twenty-fifth-member-capacity.md`.

## September 8 next rollover projection

Startup `.3.3.55` measures the candidate root at 439 lines / 55,736 bytes,
and the existing 25-file collection at 25,595 lines / 2,744,945 bytes. The manifest
remains 24 lines / 14,394 bytes. Six further ordinary four-line records would put
the root at 463 lines, crossing its 90% rollover threshold. Pending `.3.3.61` owns
the required archive and exact-limit review, with a fresh pressure check at activation.
This projection authorizes no capacity increase or archive rewrite; any required count
admission needs a new indexed ADR and exact staged canonical proof under COMMIT.md.
If actual pressure triggers earlier, the triggering leaf follows that same workflow.

The September 8 projection is fulfilled by completed startup .3.3.61: segment 4982 and exact ADR 0107
capacity are recorded in [[engineering-notes-twenty-sixth-member-capacity]].
