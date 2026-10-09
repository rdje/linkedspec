---
id: finite-engineering-notes-aggregate
title: Engineering notes have one finite hot-shard aggregate allowance
answers:
  - "why did engineering notes aggregate lines increase to 29512"
  - "which decision admits the October 9 engineering notes aggregate allowance"
  - "does ADR0130 admit another engineering notes archive member"
  - "what preserves history during the engineering notes aggregate admission"
date: 2026-10-09
status: finite focused proof verified; exact staged canonical receipt required before landing
tags: [documentation, history, capacity, verification]
evidence: "Exactly three registry scalars admit engineering_notes aggregate lines29000→29512 and the sole new indexed ADR0130 decision: files130→131 and aggregate lines13077→13109. Independent Git reconstruction preserves220 prior history/decision files and all prior current-root records; engineering notes use45 files/29004 lines/3238344 bytes, decisions use131 files/13109 lines/966986 bytes. Twelve actual production aggregate observations, sixteen actual accepted/indexed/exact-authority RED controls and three actual reviewer evidence REDs pass. Root, byte, per-file, manifest, membership and every other registry control stay exact. No new archive member is admitted."
reverify: "At the frozen admission boundary, run bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6-capacity.py review and docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6-evidence.py. Preserve the original claim inputs at later root/registry publication; canonical receipt governs landing."
---

# A finite aggregate allowance preserves existing storage rules

ADR0130 admits exactly512 aggregate engineering-note lines, one existing bounded
hot-shard line allowance, under the current full-PNT engineering instruction and
the ADR0128/0129 maintenance precedent. It makes no new explicit director-grant
claim and does not reuse an earlier finite grant. The decision store accounts for
only this new file and its exact32 additional aggregate lines, including the
index row. Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3.

The actual resulting collection contains45 files/29,004 lines/3,238,344 bytes.
Its hard aggregate-line limit is29,512. The mutable root remains512 lines/65,536
bytes; every engineering-note byte, per-file, manifest and file-count control is
unchanged. No archive reserve is granted. A later rollover or exhausted allowance
requires another separately owned, indexed finite decision.

The retained producer independently reconstructs all220 prior history/decision
file identities from clean bece12874183477b6e601dd122cb1c39119b613e and preserves both current roots by exact
record insertion. The unchanged production functions execute twelve aggregate
observations and sixteen accepted/indexed/exact-marker authority denials. Three
actual reviewer subprocesses reject a missing immutable member, a forged original
hash and a forged resulting registry hash. Only mutable plan evidence is changed
and restored during those controls; successful outputs remain byte-identical.

The first producer draft misindexed the registry header and is retained beside
its explicitly limited failure transcript. Verified literal current-root additions
were restored before corrected one-shot publication; no immutable history, registry
or decision was changed by that failed draft. Existing book authority teaching
already covers this data-only admission. Parser/runtime, tests, dependencies,
checker implementations and other repositories remain unchanged. Exact staged
canonical CI, its receipt, normal hooks and a clean per-leaf commit govern landing.
