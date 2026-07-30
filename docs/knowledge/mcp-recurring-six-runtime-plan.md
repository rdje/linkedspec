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
status: accepted signoff-complete behavior-free plan; implementation and promotion pending
tags: [mcp, semantic-introspection, recurring-gate, perl, rust, dart, julia, lua, luajit, conformance]
evidence: "FUTURE-PARITY-BACKLOG.10.9.7.0 and ADR 0062 audit the neutral semantic contract, all six native/MCP consumers, the implementation ledger/checker, canonical CI, the semantic recurring precedent, and project-data routing. Current semantic consumers prove all 20 native cases; current MCP consumers prove capabilities plus one representative direct/MCP query. Leaf .1 must extend those same consumers to all 20 cases before coordinated rollout promotion. Planning signoff passes semantic 6/20/105, MCP 35/10/10/68, current six-runtime admission, repository containment/moved-root proof, CLI 66x2, Phase 0 1,031/1,031, and the complete dual-ABI Lua gate without behavior or status movement."
last_verified: 2026-07-29
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
twenty ordered neutral query cases. The six MCP admissions cover the complete transport/security/lifecycle
twelve-role inventory but directly compare only capabilities plus one representative graph query to the native
API. Merely running them together cannot prove the stronger all-twenty direct/MCP identity claim.

ADR `0062` therefore requires `.10.9.7.1` to extend the existing MCP consumers, not add another semantic model.
Their capabilities/query identity roles will build the already-governed native snapshots, register those indexes,
send the exact neutral requests through MCP, compare canonical tool text and structured content with direct native
answers, and verify the existing neutral response digests for all twenty cases. Expected records and responses
remain solely in `semantic_introspection_contract.json`; production MCP and semantic owners do not change.

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
