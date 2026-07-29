---
id: mcp-implementation-admission-ledger
title: MCP implementation and runtime admission ledger
status: current; Perl admitted, remaining implementations and runtimes pending
date: 2026-07-29
answers:
  - Where are MCP implementation and runtime admission statuses recorded?
  - How many LinkedSpec MCP server implementations exist?
  - Why are there five MCP implementations but six runtime admissions?
  - Is Perl admitted for MCP?
  - Is thin MCP transport rollout complete?
  - Does backend admission change the normative MCP transport digest?
  - What roles does an MCP admission consumer prove?
  - How is premature MCP admission detected?
  - What authority is forbidden to an MCP server implementation?
reverify:
  - bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
  - bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
  - bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py
  - PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t
  - bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py
  - PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t
---

# MCP implementation and runtime admission ledger

`capability_conformance/mcp_implementation_admission.json` is the sole status/proof ledger for native MCP rollout.
It is deliberately separate from normative `linkedspec-mcp-transport-v1`: admitting or deferring a backend must
not change the protocol schema, corpus, canonical frames, or root digest. The ledger pins that unchanged digest
and the exact 35 canonical, ten raw-input, ten lifecycle, four handle-state, and four policy inventories.

Topology is five native implementations—Perl, Rust, Dart, Julia, and one Lua-5.1-compatible source—but six runtime
admissions because the Lua source must qualify unchanged on both PUC Lua and LuaJIT. Current exact state is Perl
complete at 1/5 implementations and 1/6 runtimes. Every other implementation/runtime row is pending, and shared
`thin_mcp_transport` rollout remains pending under `FUTURE-PARITY-BACKLOG.10.9.7` until all six runtimes qualify.

The Perl admission consumer declares exactly twelve omission-sensitive roles: contract inventory, canonical
static dispatch, native capabilities identity, native query identity, raw outcomes, lifecycle outcomes, handle
indistinguishability, policy overlay, cancellation emission, shutdown/I/O, hostile-output/log privacy, and
authority-surface fences. It composes existing public server, native query, and neutral contract authorities; it
does not synthesize another expected-response model.

`tools/check_mcp_implementation_admission.py` validates ledger/status/ownership/count topology, unchanged transport
identity, exact role declaration/invocation, tracked canonical inputs, and canonical command order. It rejects 28
mutations. Static fences prohibit production MCP owners from parser construction, descriptors, substitution
handlers, parser-source dumps, trace, shell/process execution, and arbitrary reads; the sole documented production
`sysopen` is fail-closed `/dev/urandom` for opaque handles.
