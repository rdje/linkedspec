---
id: mcp-implementation-admission-ledger
title: MCP implementation and runtime admission ledger
status: current; Perl parent closed, Rust admitted at 2/5 implementations and 2/6 runtimes, remaining rows pending
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
  - bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py
  - PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t
  - bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py
  - PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib mcp_
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_dispatch
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_stdio
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_admission
---

# MCP implementation and runtime admission ledger

`capability_conformance/mcp_implementation_admission.json` is the sole status/proof ledger for native MCP rollout.
It is deliberately separate from normative `linkedspec-mcp-transport-v1`: admitting or deferring a backend must
not change the protocol schema, corpus, canonical frames, or root digest. The ledger pins that unchanged digest
and the exact 35 canonical, ten raw-input, ten lifecycle, four handle-state, and four policy inventories.

Topology is five native implementations—Perl, Rust, Dart, Julia, and one Lua-5.1-compatible source—but six runtime
admissions because the Lua source must qualify unchanged on both PUC Lua and LuaJIT. Current exact state is Perl
and Rust complete at 2/5 implementations and 2/6 runtimes. Dart, Julia, Lua, PUC Lua, and LuaJIT remain pending,
and shared `thin_mcp_transport` rollout remains pending under `FUTURE-PARITY-BACKLOG.10.9.7` until all six runtimes
qualify.

Each admitted consumer declares exactly twelve omission-sensitive roles: contract inventory, canonical
static dispatch, native capabilities identity, native query identity, raw outcomes, lifecycle outcomes, handle
indistinguishability, policy overlay, cancellation emission, shutdown/I/O, hostile-output/log privacy, and
authority-surface fences. It composes existing public server, native query, and neutral contract authorities; it
does not synthesize another expected-response model.

`tools/check_mcp_implementation_admission.py` validates ledger/status/ownership/count topology, unchanged transport
identity, exact role declaration/invocation, tracked canonical inputs, and canonical command order. It rejects 28
mutations for the Perl-only state and 39 after Rust admission. Static fences prohibit production MCP owners from
parser construction, descriptors, substitution handlers, parser-source dumps, trace, shell/process/network
execution, and arbitrary reads; the sole documented Perl production `sysopen` is fail-closed `/dev/urandom` for
opaque handles, while Rust uses locked OS entropy without filesystem authority.

No-change closeout `FUTURE-PARITY-BACKLOG.10.9.2.4` recomposes these committed transport, binding, server, ledger,
and admission owners unchanged. It deliberately adds no umbrella oracle. Canonical signoff closes parent Perl
`.10.9.2` while the shared rollout row remains pending; Rust `.10.9.3` receives the same contract after the clean
closeout commit. Rust decoded implementation `.10.9.3.1`, strict stdio `.10.9.3.2`, and exact admission
`.10.9.3.3` are now complete; no-change committed-owner closeout remains `.10.9.3.4`.
