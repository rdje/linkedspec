---
id: mcp-implementation-admission-ledger
title: MCP implementation and runtime admission ledger
status: current; Perl/Rust/Dart admitted at 3/5 implementations + 3/6 runtimes; rollout pending
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
  - bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py
  - PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t
  - bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py
  - PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib mcp_
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_dispatch
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_stdio
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_admission
  - cd dart && bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart
  - cd dart && bash ../tools/run_dart_project_data.sh test test/mcp_server_dart_admission_test.dart
---

# MCP implementation and runtime admission ledger

`capability_conformance/mcp_implementation_admission.json` is the sole status/proof ledger for native MCP rollout.
It is deliberately separate from normative `linkedspec-mcp-transport-v1`: admitting or deferring a backend must
not change the protocol schema, corpus, canonical frames, or root digest. The ledger pins that unchanged digest
and the exact 35 canonical, ten raw-input, ten lifecycle, four handle-state, and four policy inventories.

Topology is five native implementations—Perl, Rust, Dart, Julia, and one Lua-5.1-compatible source—but six runtime
admissions because the Lua source must qualify unchanged on both PUC Lua and LuaJIT. Current formal state is Perl,
Rust, and Dart complete at 3/5 implementations and 3/6 runtimes. Dart's one ordered consumer composes its
generated/frozen/decoded/strict-stdio production owners without changing them. Julia, Lua, PUC Lua, and LuaJIT
remain pending, and shared `thin_mcp_transport` rollout remains pending under
`FUTURE-PARITY-BACKLOG.10.9.7` until all six runtimes qualify.

Each admitted consumer declares exactly twelve omission-sensitive roles: contract inventory, canonical
static dispatch, native capabilities identity, native query identity, raw outcomes, lifecycle outcomes, handle
indistinguishability, policy overlay, cancellation emission, shutdown/I/O, hostile-output/log privacy, and
authority-surface fences. It composes existing public server, native query, and neutral contract authorities; it
does not synthesize another expected-response model.

`tools/check_mcp_implementation_admission.py` validates ledger/status/ownership/count topology, unchanged transport
identity, exact role declaration/invocation/completion, tracked canonical inputs, and canonical command order. It
rejects 28 mutations for the Perl-only state, 39 after Rust admission, 43/46 while Dart decoded/strict-stdio proof
remained unadmitted, and 58 after exact Dart admission. Static fences prohibit production MCP owners from
parser construction, descriptors, substitution handlers, parser-source dumps, trace, shell/process/network
execution, and arbitrary reads; the sole documented Perl production `sysopen` is fail-closed `/dev/urandom` for
opaque handles, Rust uses locked OS entropy without filesystem authority, and Dart uses core `Random.secure()`;
its only production `dart:io` import is the exact borrowed `IOSink` type, with file/process/network/source-tool
authority still forbidden.

No-change closeout `FUTURE-PARITY-BACKLOG.10.9.2.4` recomposes these committed transport, binding, server, ledger,
and admission owners unchanged. It deliberately adds no umbrella oracle. Canonical signoff closes parent Perl
`.10.9.2` while the shared rollout row remains pending; Rust `.10.9.3` receives the same contract after the clean
closeout commit. Rust decoded implementation `.10.9.3.1`, strict stdio `.10.9.3.2`, exact admission `.10.9.3.3`,
and unchanged-owner closeout `.10.9.3.4` are complete. Parent `.10.9.3` is closed without ledger movement; Dart
`.10.9.4.0` and ADR `0059` freeze its generated/runtime/server/wire/admission/closeout seams without status
movement. Dart generated binding and decoded server `.10.9.4.1` plus strict stdio `.10.9.4.2` are implemented
without status movement; `.10.9.4.3` now admits their unchanged four owners through
`dart/test/mcp_server_dart_admission_test.dart`, advancing only Dart to 3/5 implementations and 3/6 runtimes.
No-change `.10.9.4.4` recomposes every committed neutral, Perl, Rust, and Dart owner without replacing an oracle
or moving status, preserves all 58 mutations, closes parent `.10.9.4`, and hands off to Julia `.10.9.5`.

Related facts: [[dart-native-mcp-server-plan]], [[dart-mcp-decoded-server]], [[dart-mcp-strict-stdio]],
[[mcp-native-server-topology]], and [[mcp-2026-07-28-stdio-contract]].
