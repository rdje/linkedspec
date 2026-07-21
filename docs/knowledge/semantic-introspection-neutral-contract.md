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
  - why are there 57 semantic introspection mutations
date: 2026-07-21
status: current corrected neutral contract; Perl static query implemented, backend admission pending
tags: [introspection, semantic-api, conformance, fixtures, mutations, privacy, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.10.2 freezes linkedspec-semantic-model-v1 and linkedspec-semantic-query-v1 in semantic_introspection_contract.json/model.json; corrections derive static rules, generated-plan identity, and spec names from independent authorities. The checker validates six groups, 20 full response digests, and 57 mutations. Perl .10.3.4 now matches all 19 static digests through native capabilities/query; runtime observation and composed admission remain pending. Neutral rollout is 1 complete / 8 pending; native admission is 0 complete / 6 pending."
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

The same external contract owns generated-source-v2 identity, format, and the exact ten handler families. The
calls snapshot's default entry header must therefore retain generated family `default`; the old `and_acode` value
was neither the selected family nor a legal v2 spelling. Independent validation rejects illegal and coordinated
valid-but-wrong family changes even when query hashes are refreshed.

Spec identity is independently derived from each fixture's caller-registered logical name. A snapshot id cannot
replace that identity: `calls_and_staging.spec` projects `calls_and_staging`, and direct/coordinated attempts to
restore the old short `calls` value fail even though no current query selects that record.

Six groups cover rule/regex/edge/lifecycle graphs, call resolution and shapes, staged/generated provenance,
diagnostics/explanations, caller-captured runtime observations, and privacy/page/budget/error behavior. Twenty
queries lock full canonical responses by SHA-256, not only selected fields. Record, relation, and zero-depth budget
prefixes; page cursor/boundary behavior; reverse traversal; source `none`/`identity`/`span`/`text`; UTF-8 byte and
Unicode-scalar coordinates; digests; redactions; a lowered ceiling; invalid requests; and unsupported contracts are
all executable.

The neutral leaf deliberately admits no native backend. Perl now has opaque construction, exact private static and
calls/staging/generated projections, and public immutable capabilities/query for all 19 static canonical cases.
The runtime-events case, route equivalence, and composed consumer remain pending, so its rollout/admission rows do
not advance. Those steps precede Rust, Dart, Julia, dual-ABI Lua, recurring six-runtime proof, thin MCP transport,
and public no-drift.

Related facts: [[semantic-introspection-api-mcp-direction]], [[semantic-introspection-static-rule-authority]],
[[semantic-introspection-generated-plan-authority]],
[[semantic-introspection-spec-name-authority]],
[[perl-semantic-static-projection]], [[perl-semantic-call-staged-projection]],
[[perl-semantic-query-evaluator]],
[[semantic-introspection-staged-artifact-schema]],
[[outward-descriptor-is-not-semantic-wire-model]].
