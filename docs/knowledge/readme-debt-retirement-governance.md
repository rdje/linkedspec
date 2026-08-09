---
id: readme-debt-retirement-governance
title: Routed debt retirement requires exact staged contract authority
answers:
  - how can a routed documentation debt become current without refreshing its baseline
  - why did the routing checker initially reject clearing a debt baseline
  - what authorizes debt to current route transitions
  - may an immutable routing debt baseline be deleted or refreshed
date: 2026-08-09
status: accepted and implemented under LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1 at 99fe03f3
tags: [readme, routing, debt, governance, documentation, transition]
evidence: "The original routing checker rejected every baseline difference before evaluating the exact staged old/new contract ADR, while non-debt surfaces were separately required to have empty baseline/transition objects. That made a ratified debt-to-current closure structurally impossible. The checker now permits baseline clearing only when HEAD state is debt, resulting state is current, resulting baseline/transition are empty, and a newly added indexed ADR matches the canonical old/new route contracts exactly. ADR 0067 authorizes live_status; all other baseline changes remain rejected, and mutation class 31 locks authorized versus unauthorized retirement."
last_verified: 2026-08-09
reverify:
  - "perl scripts/check_readme_routing_pressure.pl --report"
  - "rg -n 'debt_retirement_permitted|immutable debt baseline changed without exact reviewed debt retirement|threshold_and_debt_retirement_review' scripts/check_readme_routing_pressure.pl"
  - "sed -n '1,220p' docs/decisions/0067-live-achievement-status-history.md"
---

# Debt retirement is an authorized state transition

An immutable debt baseline must never be refreshed to the latest high-water mark. It also cannot remain attached
to a routed surface after that surface becomes `current`, because the route schema requires non-debt surfaces to
have empty baseline and transition objects.

The only legal bridge is exact execution-time review: HEAD must be `debt`, the resulting tree must be `current`
with empty debt metadata, and a newly added indexed ADR must match the complete old/new canonical route contracts.
This clears the active control object without rewriting the historical baseline fact in Git or ADR `0063`.
