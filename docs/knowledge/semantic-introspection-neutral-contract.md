---
id: semantic-introspection-neutral-contract
title: Semantic introspection v1 has an executable neutral oracle before backend admission
answers:
  - where is the executable semantic introspection contract
  - how many semantic introspection fixture groups and exact queries exist
  - how is semantic introspection response parity locked
  - what does the semantic introspection mutation checker reject
  - are any semantic introspection backends implemented or admitted yet
  - what is the current semantic introspection rollout state
  - how are semantic query pagination budgets and source privacy tested
  - what task follows FUTURE-PARITY-BACKLOG.10.2
  - how are semantic introspection static rule facts cross-checked
  - why are there 53 semantic introspection mutations
date: 2026-07-21
status: current corrected neutral contract; backend rollout pending
tags: [introspection, semantic-api, conformance, fixtures, mutations, privacy, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.10.2 freezes linkedspec-semantic-model-v1 and linkedspec-semantic-query-v1 in semantic_introspection_contract.json/model.json; correction .10.3.2.0 derives static rule facts from linkedspec-rule-local-cursor-v1 after finding stale default-family/no-edge rows. The independent checker validates six fixture groups, derives 20 full canonical responses and compares their SHA-256 digests, rejects 53 representative mutations including three coordinated model-plus-hash changes, and is registered unconditionally in tools/run_ci_local.sh. Neutral rollout is 1 complete / 8 pending; native admission is 0 complete / 6 pending."
reverify: "python3 tools/check_semantic_introspection_contract.py && rg -n 'semantic_introspection_contract|check_semantic_introspection' tools/run_ci_local.sh capability_conformance/README.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

# Semantic Introspection Neutral Contract

The executable v1 oracle lives in:

- `capability_conformance/semantic_introspection_contract.json` — schema, query/source policy, fixtures, exact
  requests and response digests, rollout, and mutation inventory;
- `capability_conformance/semantic_introspection_model.json` — immutable compiled, failed-compilation, execution,
  and source-ceiling snapshots;
- `capability_conformance/semantic_introspection/` — exact strict-UTF-8 source/input bundles; and
- `tools/check_semantic_introspection_contract.py` — independent schema/model/query evaluator and mutation gate.

The checker also consumes `capability_conformance/rule_local_cursor_contract.json` as the independent authority
for rule header family/cursor semantics. It derives entry-marker and repetition facts from exact headers and
reconciles rule ownership with normalized edge records. This closes the gap where model rows and response hashes
could agree with each other while disagreeing with already-admitted parser semantics.

Six groups cover rule/regex/edge/lifecycle graphs, call resolution and shapes, staged/generated provenance,
diagnostics/explanations, caller-captured runtime observations, and privacy/page/budget/error behavior. Twenty
queries lock full canonical responses by SHA-256, not only selected fields. Record, relation, and zero-depth budget
prefixes; page cursor/boundary behavior; reverse traversal; source `none`/`identity`/`span`/`text`; UTF-8 byte and
Unicode-scalar coordinates; digests; redactions; a lowered ceiling; invalid requests; and unsupported contracts are
all executable.

The neutral leaf deliberately admits no native backend and adds no semantic API behavior. Perl `.10.3` is the next
owner, followed by Rust, Dart, Julia, dual-ABI Lua, recurring six-runtime proof, thin MCP transport, and public
no-drift.

Related facts: [[semantic-introspection-api-mcp-direction]], [[semantic-introspection-static-rule-authority]],
[[semantic-introspection-staged-artifact-schema]], [[outward-descriptor-is-not-semantic-wire-model]].
