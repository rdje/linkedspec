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
  - why are there 81 semantic introspection mutations
  - how is semantic introspection TOOLBOX current state guarded
  - does the semantic toolbox guard change the contract mutation count
date: 2026-07-21
status: current complete neutral contract; all six runtimes admitted and public rollout closed
tags: [introspection, semantic-api, conformance, fixtures, mutations, privacy, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.10.2 freezes linkedspec-semantic-model-v1 and linkedspec-semantic-query-v1 in semantic_introspection_contract.json/model.json; later backend, recurring, MCP, and public leaves preserve that authority. FUTURE-PARITY-BACKLOG.10.10 completes the current checker at six groups, 20 exact response digests, 128 rejected mutations, public rollout 9/9, and native admission 6/6."
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py && rg -n 'semantic introspection contract|RUNTIME OBSERVATION|COMPOSED ADMISSION' TOOLBOX.md && rg -n 'semantic_introspection_contract|check_semantic_introspection' tools/run_ci_local.sh capability_conformance/README.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
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

The filesystem leg also owns the corresponding `TOOLBOX.md` diagnostic entry and public current-state contract.
It requires exact 6/20/128, rollout 9+0, admission 6+0 output; current runtime/admission claims; 28 public surfaces;
nine worked examples; both recurring drivers; and the companion-book boundary. Omission, stale-claim, and wrong-
value probes run internally.

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

The neutral leaf itself deliberately admitted no native backend. Subsequent exact twelve-role consumers admit Perl,
Rust, Dart, Julia, PUC Lua, and LuaJIT across typed/raw-neutral static and observed-runtime answers. Native and MCP
recurring proofs are complete, and public rollout is complete at 9/9 with admission 6/6; no second evaluator or
semantic owner was introduced.

Related facts: [[semantic-introspection-api-mcp-direction]], [[semantic-introspection-static-rule-authority]],
[[semantic-introspection-generated-plan-authority]],
[[semantic-introspection-spec-name-authority]],
[[perl-semantic-static-projection]], [[perl-semantic-call-staged-projection]],
[[perl-semantic-query-evaluator]], [[perl-semantic-runtime-observation]],
[[perl-semantic-introspection-admission]],
[[rust-semantic-query-evaluator]], [[rust-semantic-runtime-observation]],
[[rust-semantic-introspection-admission]],
[[semantic-introspection-staged-artifact-schema]],
[[outward-descriptor-is-not-semantic-wire-model]].
