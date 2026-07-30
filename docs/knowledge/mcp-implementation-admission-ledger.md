---
id: mcp-implementation-admission-ledger
title: MCP implementation and runtime admission ledger
status: current; all five implementations and all six runtimes admitted; shared rollout pending
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
  - bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py
  - bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py
  - PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t
  - bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py
  - PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib mcp_
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_dispatch
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_stdio
  - cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_admission
  - cd dart && bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart
  - cd dart && bash ../tools/run_dart_project_data.sh test test/mcp_server_dart_admission_test.dart
  - bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include("julia/test/mcp_contract_julia_binding_test.jl"); include("julia/test/mcp_server_julia_dispatch_test.jl"); include("julia/test/mcp_server_julia_stdio_test.jl")'
  - bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include("julia/test/mcp_server_julia_admission_test.jl")'
  - bash tools/run_lua_project_data.sh puc lua/test/mcp_server_lua_admission_test.lua
  - bash tools/run_lua_project_data.sh luajit lua/test/mcp_server_lua_admission_test.lua
---

# MCP implementation and runtime admission ledger

`capability_conformance/mcp_implementation_admission.json` is the sole status/proof ledger for native MCP rollout.
It is deliberately separate from normative `linkedspec-mcp-transport-v1`: admitting or deferring a backend must
not change the protocol schema, corpus, canonical frames, or root digest. The ledger pins that unchanged digest
and the exact 35 canonical, ten raw-input, ten lifecycle, four handle-state, and four policy inventories.

Topology is five native implementations—Perl, Rust, Dart, Julia, and one Lua-5.1-compatible source—but six runtime
admissions because the Lua source must qualify unchanged on both PUC Lua and LuaJIT. Current formal state is all
five implementations and all six runtimes complete. Each ordered consumer composes its generated/frozen/decoded/
strict-stdio production owners without changing them. Shared `thin_mcp_transport` rollout remains pending under
`FUTURE-PARITY-BACKLOG.10.9.7` until the recurring six-runtime composition is separately admitted.

Each admitted consumer declares exactly twelve omission-sensitive roles: contract inventory, canonical
static dispatch, native capabilities identity, native query identity, raw outcomes, lifecycle outcomes, handle
indistinguishability, policy overlay, cancellation emission, shutdown/I/O, hostile-output/log privacy, and
authority-surface fences. It composes existing public server, native query, and neutral contract authorities; it
does not synthesize another expected-response model.

`tools/check_mcp_implementation_admission.py` validates ledger/status/ownership/count topology, unchanged transport
identity, exact role declaration/invocation/completion, tracked canonical inputs, and canonical command order. It
rejects 28 mutations for the Perl-only state, 39 after Rust admission, 43/46 while Dart decoded/strict-stdio proof
remained unadmitted, 58 after exact Dart admission, 65 after registering Julia's still-unadmitted generated/
runtime/decoded owners, 68 after requiring Julia's strict wire plus stdio proof, 79 after exact Julia admission,
and 93 after locking Lua's still-unadmitted generated/runtime/native-system/decoded owners and dual-ABI focused
proof. Exact shared Lua admission raises the boundary to 114 mutations: one identical 202-assertion consumer runs
all twelve roles independently on PUC Lua and LuaJIT, the Lua implementation and both runtime rows are complete,
and shared rollout remains pending. Static fences prohibit production MCP owners from
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
Behavior-free Julia `.10.9.5.0` and ADR `0060` freeze generated/runtime/server/wire/admission owners under
`.1-.4`. Decoded leaf `.10.9.5.1` implements and canonically registers the generated binding, frozen runtime,
secure registry, public decoded server, and exact focused proof while leaving Julia's formal source/status and
consumer rows pending. Strict `.10.9.5.2` adds the fourth production wire owner and exact stdio proof without
moving those rows. Exact `.10.9.5.3` now admits their unchanged owners through
`julia/test/mcp_server_julia_admission_test.jl`, advances only Julia to 4/5 implementations plus 4/6 runtimes,
and leaves shared rollout pending. No-change Julia closeout `.10.9.5.4` recomposes the committed transport,
binding, server, wire, consumer, and ledger owners unchanged; it preserves all 79 mutations, closes parent
`.10.9.5`, and hands the same boundary to shared Lua planning `.10.9.6.0`.

Behavior-free Lua `.10.9.6.0` and ADR `0061` freeze one generated literal binding, private frozen runtime,
protected decoded server, strict pre-decode number-kind wire, and one package-private C99 entropy/monotonic-time
source compiled per ABI. Decoded `.10.9.6.1` implements and gate-registers the generated/frozen/server/native
owners plus identical 111 + 210 focused assertions on PUC Lua and LuaJIT. Strict wire `.2` adds one bounded
iterative transport unchanged on both ABIs. Exact admission `.3` now runs one shared consumer independently on
PUC Lua and LuaJIT, advances the existing Lua owners to 5/5 implementations plus 6/6 runtimes, and leaves
recurring rollout pending. Canonical CI passes all six doctrines, the unchanged 35/10/10/68 transport boundary,
Phase 0 1,031/1,031 in 659 seconds, and the complete dual-ABI Lua opt-in. No-change closeout `.4` follows after
the clean admission commit.

Related facts: [[julia-native-mcp-server-plan]], [[julia-mcp-decoded-server]], [[julia-mcp-strict-stdio]],
[[julia-mcp-implementation-admission]], [[dart-native-mcp-server-plan]], [[dart-mcp-decoded-server]], [[dart-mcp-strict-stdio]],
[[lua-mcp-implementation-admission]], [[mcp-native-server-topology]], and [[mcp-2026-07-28-stdio-contract]].
