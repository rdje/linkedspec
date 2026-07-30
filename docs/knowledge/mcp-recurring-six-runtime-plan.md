---
id: mcp-recurring-six-runtime-plan
title: Recurring MCP proof must compare all twenty semantic responses on six runtimes
answers:
  - how will recurring MCP conformance run
  - which task owns the recurring six runtime MCP gate
  - does current MCP admission prove all twenty semantic query responses
  - why is one representative MCP query insufficient for rollout
  - how will all twenty native and MCP responses be compared
  - will recurring MCP proof add another response oracle
  - what will LINKEDSPEC_RUN_MCP_MATRIX run
  - which runtime order will recurring MCP proof use
  - what may promote thin MCP transport
  - does recurring MCP proof add a primary CLI surface
date: 2026-07-29
status: accepted and director-authorized; atomic repair and all-twenty consumer proof implemented; routed rollout pending
tags: [mcp, semantic-introspection, recurring-gate, perl, rust, dart, julia, lua, luajit, conformance]
evidence: "FUTURE-PARITY-BACKLOG.10.9.7.0 and ADR 0062 audit the neutral contract, six native/MCP consumers, ledgers, canonical CI, recurring precedent, and storage routing. Probe .10.9.7.1.0 found three shared blockers; atomic repair .10.9.7.1.1.1 admits the exact 72 fact keys, bounded future contract strings, and explicit-component-only pre-dispatch policy in all five servers. Leaf .10.9.7.1.1.2 strengthens the unchanged twelve-role consumers to prove capabilities plus nineteen governed queries across direct native object/canonical JSON, MCP structured/text/decoded payload, and existing response digest on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. Focused proof passes Perl 13, Rust 1, Dart 1 plus analysis, Julia 257, and Lua 281x2; canonical repeats all six admissions and passes Rust semantic 81.63s, Julia 416/416 in 29.5s, CLI 66x2, and Phase 0 1,031/661s. Neutral state remains semantic 6/20/105 and MCP 35/10/10/76; formal rollout remains pending/114 until the rooted recurring driver and coordinated promotion."
last_verified: 2026-07-30
reverify:
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
  - "rg -n 'native_capabilities_identity|native_query_identity|exact_twenty_queries' t/mcp_server_perl_admission.t rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs dart/test/mcp_server_dart_admission_test.dart julia/test/mcp_server_julia_admission_test.jl lua/test/mcp_server_lua_admission_test.lua t/semantic_introspection_perl_admission.t rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs dart/test/semantic_introspection_dart_admission_test.dart julia/test/semantic_introspection_julia_admission_test.jl lua/test/semantic_introspection_lua_admission_test.lua"
---

# Recurring MCP six-runtime plan

The admitted topology is one neutral contract, five native server implementations, and six runtime rows because
one Lua source runs unchanged on PUC Lua and LuaJIT. Shared `thin_mcp_transport` rollout remains pending until one
repository-routed recurring gate proves the complete topology.

The planning audit found that the six native semantic admission consumers already derive and digest-check all
twenty ordered neutral query cases. Before `.10.9.7.1.1.2`, the six MCP admissions covered the complete
transport/security/lifecycle twelve-role inventory but directly compared only capabilities plus one
representative graph query to the native API. Merely running that earlier form together could not prove the
stronger all-twenty direct/MCP identity claim.

Implementation audit `.10.9.7.1.0` proved a second boundary: a real Perl all-twenty spend preserved capabilities
plus sixteen of nineteen query identities, while three valid native responses were preempted by shared MCP
schema/default-policy behavior. See [[mcp-all-twenty-transport-blocker]]. Exploratory code was removed. The
director authorized the exact all-twenty contract and five-server policy repair on 2026-07-30;
`.10.9.7.1.1.1` now implements that repair with independently validated neutral artifacts and focused
six-runtime proof. Keeping the old bytes was the non-selected weaker claim. Rollout remains pending.

ADR `0062` originally required `.10.9.7.1` to extend only the existing MCP consumers. The `.1.0` evidence proves
that consumer-only scope cannot satisfy the accepted claim. Expected records and responses must still remain
solely in `semantic_introspection_contract.json`, and no second model is allowed; however, exact all-twenty proof
now depends on the authorized neutral transport and identical five-server policy correction recorded in the
blocker card. The repair moved atomically: exact schema/policy bytes, independent validation, all generated
bindings, and all five servers changed together. Consumer proof `.10.9.7.1.1.2` is now complete: those same five
consumers, with shared Lua run under both ABIs, construct the governed native snapshots and compare all twenty
responses across direct native/canonical JSON, MCP structured/text/decoded content, and the existing digest.
Promotion and unchanged closeout remain separate commits.

The planned `tools/check_mcp_six_runtime.sh` runs the neutral semantic checker, MCP materializer/validator, five
binding generators, Perl/Rust/Dart/Julia/PUC Lua/LuaJIT consumers, MCP ledger checker, and three existing primary
no-drift cases in exact order. It uses repository-derived managed scratch plus disposable Rust and Julia child
roots. Canonical CI will require and syntax-check it, with expensive execution opt-in through
`LINKEDSPEC_RUN_MCP_MATRIX=1`.

Only the coordinated `.1` transition may mark `thin_mcp_transport` complete in both the MCP and semantic ledgers,
with the same leaf owner. Implementations and runtime rows remain complete. Governance must reject partial or
premature promotion, topology/order/command drift, skipped or representative-only proof, missing identity/digest
checks, routing/storage drift, authority expansion, and any primary CLI surface. Aggregator and legacy adapter
work remain outside this task.

Related: [[mcp-implementation-admission-ledger]], [[mcp-native-server-topology]],
[[mcp-2026-07-28-stdio-contract]], [[semantic-introspection-recurring-gate]], and
[[project-data-workflow-routing]].
