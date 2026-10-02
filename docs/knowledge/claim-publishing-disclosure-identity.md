---
id: claim-publishing-disclosure-identity
title: Local three-leg claim publishing gates disclosure and declared source identity
answers:
  - "where is the local claim verification policy adopted"
  - "what does CLAIM VERIFICATION actually prove"
  - "how should a new task leaf declare measured claims"
  - "may a claim checker execute recorded commands"
  - "who owns the broader claim verification adoption audit"
  - "how are live and historical claim input identities distinguished"
date: 2026-10-02
status: bounded working-rule and infrastructure adoption; broader audit open
tags: [claims, doctrine, verification, durability]
evidence: "ADR0126 and SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1 adopt DOCTRINE_ENFORCEMENT section12, COMMIT review template, strict records and the registered checker. Tracked fixture and alternate-index programs exercise actual acceptance/rejection; source identities are recorded in the owning docs/claims record."
reverify: "bash scripts/check_claim_verification.sh --self-test && perl tools/check_task_verification_fields.pl --self-test && bash scripts/check_verification_cadence.sh --self-test && bash scripts/check_claim_verification.sh"
---

The local normative publishing contract is `DOCTRINE_ENFORCEMENT.md` section12,
not a runtime dependency on the supplied read-only external policy. Every new staged
owning leaf declares ``Claim verification: `docs/claims/LEAF.json` `` or explains that
no measured claim is published. The existing owner classifier's default tier-only
API is unchanged; `--owner` is an explicit read-only query of the same staged delta.

Records name the claim/scope, source command/result, competing hypothesis/oracle/RED,
and tracked producer/all-artifact-input identities, or disclose a leg gap with an
open repair owner. Live hashes watch regular index blobs; historical hashes refer
to an exact existing Git capture. Current gap ownership excludes only task parts
registered immutable in the tracked indexes. Recorded commands are never executed.

The doctrine checks declaration/schema/identity and rejects declared source drift.
It cannot establish truth, dependency-list completeness, actual execution or oracle
independence. Author review, the selected behavior oracle and receipt-bound canonical
CI retain those jobs. The tracked alternate-index test is specific to the adoption
candidate; historical replay must restore its declared capture in an owned isolated
workspace rather than stage or rewrite the current tree to match it.

Working rules and this bounded mechanism are adopted. Wider constants, ignored
published-producer, deliberate-control and alignment auditing remain under
`SESSION-STARTUP-READING.5`, and diagnostic-path repair `.29` precedes its closeout.
Original historical callable evidence is unchanged; source preservation `.4.0` is
not a fresh historical runtime pass or whole-project policy completion.
