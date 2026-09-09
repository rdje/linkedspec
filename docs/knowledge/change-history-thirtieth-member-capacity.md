---
id: change-history-thirtieth-member-capacity
title: Required segment 4983 needs 30 history files and a 29-line 16463-byte manifest
answers:
  - "which ADR authorizes change history segment 4983"
  - "why does change history allow 30 collection files"
  - "why did the change history manifest byte ceiling increase"
  - "what are change history routing limits after the staged source reading checkpoint"
date: 2026-09-07
status: exact finite ADR0106 admission; canonical receipt required before checkpoint landing
tags: [documentation, history, rollover, capacity, doctrine]
evidence: "SESSION-STARTUP-READING.3.3.38 required rollover preserves 247 exact clean-source lines as immutable segment 4983. Independent source/blob/SHA-256/count and prior-manifest comparison pass; ADR0106 admits only 30 files, 29 manifest lines and 16463 manifest bytes."
reverify:
  - "perl tools/roll_document_history.pl --surface change_history --check"
  - "bash scripts/check_readme_stability.sh"
  - "perl tools/read_document_history.pl --surface change_history --segment 4983"
---

The reading record crosses the hot-root 90% line threshold at 461 lines. The governed rollover preserves
clean source `77cad4543e72ab304ce2a66b26a876b02cd6d3c4` lines 211–457 as 247 lines / 18,635 bytes,
SHA-256 `90ac78b4747014cf1c23511da66b37cd4c1e2e3d100d0b62ef7719e4cbc5bc3a`.
The source Git blob is `1affd77066b02718adca5aca9a7a14fbf03053da`. Independent comparisons verify these
identities and every prior manifest record byte-for-byte; the header count alone advances from 27 to 28.

The 28 immutable segments plus root and manifest require 30 files; the manifest requires 29 lines and
16,463 bytes. Routing initially rejects files30/29, lines29/28 and bytes16463/16384. The 79-byte excess is
required schema/source evidence, not an appended status note. ADR0106 admits exactly those three measured
ceilings, with no future manifest member reserved. Root, per-segment and aggregate ceilings remain unchanged.

The current root already routed complete old records to history. Deleting or rewriting immutable records,
removing identity fields, or reformatting historical records cannot preserve the exact store contract.
A new partition/index architecture would be broader separately owned work. Stable responsibility remains
LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3; the mandatory checkpoint owns this finite admission.

A receipt-bound canonical gate must pass for the exact staged candidate before commit. This is required
history continuity during source reading; runtime/public behavior and incomplete reading prerequisites
remain unchanged. See `docs/decisions/0106-change-history-thirtieth-member-capacity.md`.

## Subsequent approved capacity — 2026-09-09

ADR0110 / containment .8 subsequently admit segment 4982, 31 collection files and
30 manifest lines / 17,039 bytes. The earlier ADR0106 evidence above remains exact
for its boundary. Current approval, actual provenance and reproducible preservation
proof live in `docs/knowledge/dart-reading-history-capacity-blocker.md`.
