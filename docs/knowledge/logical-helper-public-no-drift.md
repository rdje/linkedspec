---
id: logical-helper-public-no-drift
title: Logical-helper public guidance is an executable projection of the 8/0 contract
answers:
  - "which documents define the public logical helper contract"
  - "how is stale logical helper documentation detected"
  - "is logical helper public no drift complete"
  - "what closes FUTURE-PARITY-BACKLOG 5.2"
  - "how many logical helper public documents are checked"
date: 2026-07-17
status: current
tags: [logical, documentation, no-drift, truthiness, generated-source, ci, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.9 adds public_contract to linkedspec-logical-helper-v1. Twenty ordered authoritative documents require exact semantic, backend/generated, recurring, status, and Knowledge Map markers; 13 stale-current claims are forbidden. The offline checker rejects 26 total mutations, including public document, marker, stale-claim, and final-admission drift. Rollout is 8 complete / 0 pending and parent .5.2 is closed."
reverify: "python3 tools/check_logical_helper_contract.py && bash knowledge-map/scripts/check_knowledge_map.sh"
---

The logical-helper public contract is checked from the same neutral JSON as semantics and recurring admission.
It covers the root README, two ActionIR guides, all four non-reference backend READMEs, the mdBook helper catalog,
value/flow guide, action-surface guide, backend handoff and status, capability and CLI guidance, both roadmaps,
architecture/live/task state, and the neutral Knowledge Map fact.

Required markers make each surface teach the part it owns: exact eager/arity/truth behavior, lazy-control contrast,
backend-specific native/generated entrypoints, Rust's typed-versus-compatibility result shape, the selected primary
case, recurring command and CI switch, or final 8/0 status. Forbidden strings prevent measured historical states
such as Perl-only 1/7 or pending Julia/Lua projection from returning as current guidance.

Related facts: [[logical-helper-neutral-contract]], [[logical-helper-generated-primary-projection]],
[[logical-helper-recurring-five-backend-gate]], [[logical-helper-five-backend-audit]].
