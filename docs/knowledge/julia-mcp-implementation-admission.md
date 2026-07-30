---
id: julia-mcp-implementation-admission
title: Julia MCP implementation and runtime are admitted by one exact consumer
answers:
  - "is the Julia MCP implementation admitted"
  - "which test admits Julia MCP"
  - "how many roles does the Julia MCP admission consumer execute"
  - "how many assertions does Julia MCP admission run"
  - "how many MCP implementations and runtimes are admitted after Julia"
  - "how many MCP implementation admission mutations are rejected after Julia"
  - "does Julia MCP admission change the server or transport contract"
  - "what MCP work follows Julia admission"
  - "is the Julia MCP implementation parent closed"
  - "why did one mdBook paragraph still say Julia MCP admission was pending"
date: 2026-07-29
status: current exact Julia MCP admission and parent closeout
tags: [julia, mcp, admission, conformance, mutations, rollout, security]
evidence: julia/test/mcp_server_julia_admission_test.jl; capability_conformance/mcp_implementation_admission.json; tools/check_mcp_implementation_admission.py; tools/run_ci_local.sh; FUTURE-PARITY-BACKLOG.10.9.5.3-.4
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include(\"julia/test/mcp_server_julia_admission_test.jl\")' && bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
---

# Julia MCP Implementation Admission

`FUTURE-PARITY-BACKLOG.10.9.5.3` adds one external consumer,
`julia/test/mcp_server_julia_admission_test.jl`. Its exact ordered roles are contract inventory, canonical static
dispatch, native capabilities identity, native query identity, raw input outcomes, lifecycle outcomes, handle-
state indistinguishability, policy overlay, cancellation emission, shutdown/I/O, hostile-output/log privacy, and
authority-surface fences. Each role executes once, followed by one exact role-order completion assertion.

The consumer passes 178 assertions. It uses the public `McpServer`, caller-created `SemanticIndex`, decoded
dispatch, registration/revocation/shutdown, and strict caller-owned stdio; it also composes the already-required
focused private pre-emission cancellation and injected-native-failure seams by checking their non-skipped proof
owners. The lifecycle role exercises the production registry's real 1,024-handle capacity boundary rather than
substituting the smaller private test seam.

Admission adds no production server code and does not change the normative transport digest, canonical frames,
semantic APIs, primary CLI, or shared rollout. Julia alone advances to 4/5 implementations and 4/6 runtime
admissions. Lua remains the fifth implementation and must pass unchanged on both PUC Lua and LuaJIT before
recurring rollout can complete.

`tools/check_mcp_implementation_admission.py` now rejects 79 mutations. Julia-specific guards cover source and
consumer paths, package and canonical-CI registration, focused-before-admission-before-checker ordering, exact
role declaration/invocation/completion, no skip/broken markers, status regressions, and production authority
fences. No-change `.10.9.5.4` reruns those committed owners without another implementation or oracle, preserves
the exact 4/5 + 4/6 pending/79 boundary, and closes parent `.10.9.5`. Its lockstep review found one early duplicate
paragraph in the mdBook public-API chapter that still described `.3` as pending even though the same chapter's
later table and section were current. That prose was outside the present machine ledger inventory; the closeout
corrects it now and records the escape durably, while `.10.10` remains the later public no-drift owner. Shared Lua
planning `.10.9.6.0` follows after the clean closeout commit.

Related facts: [[mcp-implementation-admission-ledger]], [[julia-native-mcp-server-plan]],
[[julia-mcp-decoded-server]], [[julia-mcp-strict-stdio]], and [[mcp-2026-07-28-stdio-contract]].
