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

## 2026-09-11 — binding completion and admission-prefix reading

Julia reading .1.36 reads the complete MCP binding consumer1-100 (4,365 bytes,
SHAebc3cd9ea9751f179151cb4e8133ceba21f7125067236361753a499741193bef)
and admission1-304 (9,517 bytes,
SHAb5b0ed57d2027e9939bf06ed28cbcf55b98c5d8b836826a010b8786a5a68b11d).
Admission source after304 remains unread. The binding checks clone isolation,
embedded bundle shape, exact canonical-frame classifications, closed objects,
UTF-8 size constraints, recursively sorted JSON and nonfinite rejection. Its
finite handle-length pair does not cover or close terminal-LF repair .2.4.

Admission's read prefix declares12 roles,10 raw inputs,10 lifecycle IDs, four
handle states and four policy IDs; it constructs caller semantic indexes, including
observed runtime events, and defines hostile I/O doubles, frame identity/digest,
request overlays and raw encodings. Later role implementations are not yet read.
The full consumer nevertheless executes as focused compatibility proof:257 fresh
assertions. The178 assertion and4/5,4/6 counts above are dated earlier admission
boundaries; today's neutral ledger is5/5 implementations,6/6 runtimes,141 mutations.
Transport remains35 frames /10 raw /10 lifecycle cases with76 mutations.

Together with logical197-387 and map-leaves1-905, this group reads1,500 fragments
/56,141 baseline-identical bytes, ordered SHA
bfa4c4f3f08c79eea5116e2868c09196594d5a49493ca465ec9150549e6ee8ce.
Cumulative credit is36/52 groups,52,425 lines /1,825,930 bytes and51 complete files.
Seven untruncated windows grant no admission-suffix reading credit. Existing logical232,
map-leaves496, binding53 and admission257 pass1,038 assertions. All prior repairs,
including MCP patterns, callback identity and semantic-budget boundaries, remain open.
No source/contract change, full backend/canonical gate or dependency build occurs.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP36_EXISTING'
using LinkedSpecJulia,JSON3,Test
const REPO_ROOT=pwd()
include("julia/test/logical_helper_contract_test.jl")
include("julia/test/map_leaves_mutation_contract_test.jl")
include("julia/test/mcp_contract_julia_binding_test.jl")
include("julia/test/mcp_server_julia_admission_test.jl")
JULIA_GROUP36_EXISTING
bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py
bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py
bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py
bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py
```
