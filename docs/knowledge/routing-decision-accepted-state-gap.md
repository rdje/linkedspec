---
id: routing-decision-accepted-state-gap
title: Exact routing markers do not establish accepted decision status in the current authorization functions
answers:
  - "can a proposed routing decision satisfy the current authorization functions"
  - "does a missing decision Status reject a routing increase"
  - "which task owns accepted-state routing enforcement"
  - "does the isolated accepted-state observation prove a full doctrine bypass"
date: 2026-10-08
status: measured function-level gap; composed-path diagnosis and repair .3.1.3 pending
tags: [doctrine, routing, accepted-status, authorization, verification]
evidence: "Actual unchanged adr_authorizes_limit_change and adr_authorizes_contract_change each return true for independently proposed and missing Status fixtures with exact indexed old/new markers. The owning capacity-controls.json retains all four observations separately from seven rejecting controls. Current ADR0128 is explicitly accepted and independently reviewed."
reverify: "At the unchanged checker boundary, run perl docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-capacity-controls.pl. After .3.1.3 repair, use its retained before/after proof; do not refresh the original producer or observations."
---

`README_POLICY.md` requires a newly added accepted indexed decision for a
routing-limit increase. The actual `adr_authorizes_limit_change` and
`adr_authorizes_contract_change` functions in
`scripts/check_readme_routing_pressure.pl` match the indexed filename and exact
surface/old/new canonical markers. They do not inspect the record's Status.

The source-bound instrument changes only ADR0128's Status to proposed or removes
that line while preserving the index and all exact markers. Both actual
functions authorize each fixture. These four observed answers are diagnostics,
not rejection controls or an inference about every composed doctrine consumer.
The current capacity record is explicitly accepted; its independent reviewer
rejects a proposed-status corruption and its byte-bound claim retains that guard.

P1 owner `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3` must verify the
complete resulting-tree path before claiming a composed bypass, then repair the
smallest reached owner with independent status/index/marker RED/GREEN. It runs
immediately after clean finite-capacity admission and before private origin
handoff. Preserve accepted-record behavior, exact object matching, independent
pressure limits and historical producer bytes; exact staged canonical proof is
required for any checker change.
