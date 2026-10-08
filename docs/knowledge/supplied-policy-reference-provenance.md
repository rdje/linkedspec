---
id: supplied-policy-reference-provenance
title: Supplied portable-policy comparisons have one canonical historical record
answers:
  - "where are the supplied portable policy source hashes recorded"
  - "where should startup check supplied policy updates"
  - "does the supplied containment guide establish complete local adoption"
date: 2026-10-08
status: canonical retrieval pointer; broader adoption audit remains owned
tags: [bootstrap, policy, provenance, read-only, continuity]
evidence: "The Supplied-policy comparison evidence block in docs/tasks/SESSION-STARTUP-READING.04-49.md retains the three reviewed source identities and their historical comparison. ADR0126 records subsequent local claim-publishing adoption; SESSION-STARTUP-READING.5 retains the broader audit."
reverify: "Read the Supplied-policy comparison evidence block in docs/tasks/SESSION-STARTUP-READING.04-49.md and ADR0126. Compare any director-supplied read-only source using shasum -a256; resolve the source only through the authorized external policy references. Local policy and builds must remain independent of other repositories."
---

The original supplied README policy, claim-verification policy and live-document
containment adoption guide were compared under the startup-reading task. Their
source hashes, source-change boundaries, neutral/local distinctions and later
September recheck have one canonical home: the **Supplied-policy comparison
evidence** block in `docs/tasks/SESSION-STARTUP-READING.04-49.md`.

Use that record before repeating source discovery or inspecting donor history.
The donor files are authorized read-only policy references. A matching source
identity needs no automatic synchronization; a changed identity requires local
review under an owner. Never copy another project's thresholds or registry data.

`README_POLICY.md` and ADR0063 own local README authority. `DOCTRINE_ENFORCEMENT.md`
section 12 and ADR0126 own the adopted local claim-publishing rules. The supplied
containment guide describes a complete package; existing bounded memory, README
and history implementations establish partial adoption only. The wider policy,
field/consumer and source/alignment audit remains `SESSION-STARTUP-READING.5`.
This retrieval pointer makes no new donor-revision or whole-package adoption claim.
