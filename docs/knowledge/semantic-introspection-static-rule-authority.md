---
id: semantic-introspection-static-rule-authority
title: Semantic static rule facts are derived from the admitted rule-local contract
answers:
  - what independently validates semantic introspection rule family facts
  - why did semantic introspection default rules incorrectly say and contiguous
  - what family and cursor does a bare default LinkedSpec rule have
  - what edge ownership does a semantic rule with no compiled edges report
  - what ownership does the failed semantic bare-edge fixture report
  - can semantic model and response digest edits drift together
  - which task corrected the semantic introspection static oracle
date: 2026-07-21
status: current corrected neutral authority boundary
tags: [semantic-introspection, rule-family, cursor, edge-ownership, oracle, mutations, parity]
evidence: "FUTURE-PARITY-BACKLOG.10.3.2.0 compared exact LinkedSpec::Get(return_descriptor, runtime_ctx_ref) results with linkedspec-rule-local-cursor-v1 before adapter behavior. It corrected every default-rule snapshot from and/contiguous to neutral or/seek, changed compiled no-edge rules from blind to none, retained action for the failed default-family bare edge, and added three coordinated model-plus-hash mutations."
reverify: "python3 tools/check_semantic_introspection_contract.py && jq '.static_rule_authority' capability_conformance/semantic_introspection_contract.json && jq '.snapshots[] | {id, rules: [.records[] | select(.kind == \"rule\") | {name, facts: {family: .facts.family, cursor_policy: .facts.cursor_policy, edge_ownership: .facts.edge_ownership}}]}' capability_conformance/semantic_introspection_model.json"
---

# Semantic Introspection Static Rule Authority

The semantic model is an oracle projection, not its own parser-semantics authority. Its static rule facts therefore
cross-check the already admitted `linkedspec-rule-local-cursor-v1` contract:

- descriptor `and` / `consume` normalizes to neutral `and` / `contiguous`;
- descriptor `or_default` / `seek` normalizes to neutral `or` / `seek`;
- an entry marker changes selection identity, never family or cursor;
- a compiled rule with no normalized edges reports ownership `none`;
- a failed default-family bare edge reports its family-derived `action` intent alongside the portable
  `unknown_rule_reference` diagnostic.

The original neutral rows were schema-valid and their query responses matched their stored digests, so the old
checker could not detect a shared wrong assumption. The corrected checker reads the rule-local family-case table,
derives exact header facts, reconciles ownership with edge records, and rejects coordinated family, cursor, or
ownership changes even when the mutation refreshes every response digest.

Related facts: [[semantic-introspection-neutral-contract]], [[rule-local-cursor-and-bare-edge-contract]],
[[perl-semantic-introspection-authority-map]].
