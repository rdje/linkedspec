---
id: semantic-introspection-spec-name-authority
title: Semantic spec names derive from caller-registered logical identity
answers:
  - how is semantic introspection spec name derived
  - why did the semantic calls snapshot say calls instead of calls and staging
  - what is the semantic spec name for calls_and_staging.spec
  - can a semantic snapshot id replace its logical spec name
  - what independently validates semantic spec identity
  - which task corrected the semantic calls spec name
date: 2026-07-21
status: current corrected neutral authority boundary
tags: [semantic-introspection, identity, logical-name, oracle, mutations, privacy]
evidence: "FUTURE-PARITY-BACKLOG.10.3.3.1.0 full calls RED compared the private source-derived projection with the neutral 22/25 target. The caller identity calls_and_staging.spec produces spec name calls_and_staging, while the neutral model alone shortened it to calls. The model is corrected and the checker now derives every spec name from source_fixtures.logical_name, rejecting direct and coordinated wrong-model/hash drift."
reverify: "python3 tools/check_semantic_introspection_contract.py && jq '.snapshots[] | {id, spec: (.records[] | select(.kind == \"spec\") | .name)}' capability_conformance/semantic_introspection_model.json"
---

# Semantic Introspection Spec-Name Authority

The native semantic constructor accepts a caller-registered logical name and never discovers an implicit path.
The neutral `spec` record therefore uses that identity's `.spec`-stripped stem. Snapshot ids select test policy;
they are not spec names.

The calls fixture is registered as `calls_and_staging.spec`, so its exact semantic name is
`calls_and_staging`. The old neutral `calls` value was the only snapshot that differed from its logical identity.
It was not selected by the 20 queries, so stored response hashes could not detect the error.

The checker now derives the expected name for every snapshot from `source_fixtures.logical_name`. It rejects the
old value both directly and after all query hashes are refreshed. No path, compiler behavior, query answer,
rollout row, or backend admission changes.

Related facts: [[semantic-introspection-neutral-contract]], [[perl-semantic-index-source-foundation]],
[[semantic-introspection-generated-plan-authority]], [[outward-descriptor-is-not-semantic-wire-model]].
