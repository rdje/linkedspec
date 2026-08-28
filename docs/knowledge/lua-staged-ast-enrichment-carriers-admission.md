---
id: lua-staged-ast-enrichment-carriers-admission
title: Shared Lua staged-AST enrichment is admitted once on each supported ABI
answers:
  - "is Lua general staged AST enrichment admitted"
  - "does ordinary Lua run the staged AST enrichment consumer"
  - "does canonical CI run the Lua staged AST enrichment consumer"
  - "how many Lua staged AST enrichment assertions pass"
  - "how many times does the Lua staged AST consumer run per ABI"
  - "which Lua staged AST rollout rows are complete"
  - "does Lua staged AST admission change production behavior"
  - "what does FUTURE-PARITY-BACKLOG 14.7.7.4 implement"
date: 2026-08-27
status: current private dual-ABI admission; independent recomposition, six-runtime recurrence, and public authoring remain pending
tags: [lua, PUC-Lua, LuaJIT, staged-parsing, carriers, admission, ci, rollout, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.7.4 preserves the exact 888-assertion shared Lua-5.1 consumer and every production/carrier byte. tools/run_lua_local.sh invokes that path exactly once through PUC Lua and once through LuaJIT; lua/test/run.lua contains no duplicate. Canonical CI requires the tracked path exactly once and has one exact repository-routed marker/invocation per ABI. The consumer remains 888/888 on both hosts, and complete ordinary Lua passes 178/178 on both ABIs. Neutral governance promotes only the shared Lua backend lifecycle and rollout rows 6/7, adds eight exact topology mutations for 106 total, and leaves recurrence/public rows pending. Admitted Perl 143/143, Rust 1/1, Dart 19/19, and Julia 491/491 current projections move in lockstep without backend behavior changes. Function-body v1, generated-source v2, production, public/outward surfaces, capability state, and later recurrence remain unchanged."
last_verified: 2026-08-27
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_local.sh"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "test \"$(rg -c '^require_tracked_file lua/test/staged_ast_enrichment_contract_test[.]lua$' tools/run_ci_local.sh)\" -eq 1"
  - "test \"$(rg -c 'lua/test/staged_ast_enrichment_contract_test[.]lua' tools/run_lua_local.sh)\" -eq 2"
  - "! rg -n 'staged_ast_enrichment_contract_test[.]lua' lua/test/run.lua"
---

# Shared Lua staged-AST carrier admission

One Lua-5.1-compatible source is the complete private behavior oracle for both supported hosts. Admission does not
copy or fork it: the ordinary driver runs the same file once with PUC Lua and once with LuaJIT, while the inline
TAP suite omits it. Canonical CI owns one tracked-file requirement and one exact project-data-routed execution per
ABI.

Admission changes lifecycle and proof topology only. The committed marker/provenance, caller-frozen resolution and
plan cache, complete-depth policies, breadth-first recursion, source rebasing, and fresh native/reconstructed/
generated-plan/emitted carriers remain byte-for-byte unchanged. Each explicit and discovered route reports
888/888.

The neutral contract now records every private backend complete, promotes rollout rows six and seven, and rejects
106 mutations. Recurring six-runtime proof and public `parse_job(...)` authoring remain pending under `.14.7.8-.9`;
independent dual-ABI recomposition and final program recomposition retain `.14.7.7.5` and `.14.7.10`.

Related: [[lua-staged-ast-enrichment-recursive-carriers]],
[[lua-staged-ast-enrichment-dormant-red]], [[staged-consumer-current-projection-lockstep]],
[[general-staged-ast-enrichment-neutral-contract]], [[general-staged-ast-current-boundary]], and ADR `0088`.
