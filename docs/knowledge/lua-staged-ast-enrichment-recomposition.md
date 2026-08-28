---
id: lua-staged-ast-enrichment-recomposition
title: Shared Lua staged-AST enrichment is independently recomposed without executable movement
answers:
  - "is Lua staged AST enrichment independently recomposed"
  - "what closes FUTURE-PARITY-BACKLOG 14.7.7"
  - "what follows Lua staged AST enrichment"
  - "are all private staged AST enrichment runtime routes independently recomposed"
  - "does Lua staged AST recomposition change executable behavior"
date: 2026-08-28
status: current shared Lua parent closeout; recurrence and exact public assignment authoring complete
tags: [lua, PUC-Lua, LuaJIT, staged-parsing, recomposition, knowledge-map, task-tree, verification]
evidence: "FUTURE-PARITY-BACKLOG.14.7.7.5 starts from exact clean Lua-admission commit 97bfbac6 and reruns the committed shared carrier at 888/888 on PUC Lua and 888/888 on LuaJIT. Complete ordinary Lua passes 178/178 per ABI, both 66/66 CLI environments, the 105-case corpus, and repository-local storage while discovering the same source once per host. Admitted Perl passes 143/143, Rust 1/1 with its independently compiled emitted carrier in 268.47 seconds, Dart 19/19, and Julia 491/491. Neutral staged governance remains 5 source consumers / 6 runtime routes / 106 mutations; typed source remains 12/2/170, recognition 138/250/58, progressive 9/9/116 plus public 60, semantic 6/20/128, generated/capability 80/0/0, and language 250/105+1/126. Exact topology retains one canonical tracked path, one PUC invocation, one LuaJIT invocation, two ordinary references total, and no inline duplicate. Git proves no production, test, fixture, executable-contract/checker, ordinary/canonical topology, generated-format, public/outward, dependency/toolchain/storage/doctrine, or other-backend behavior byte moves from the admission commit. The committed carrier itself proves native, reconstructed, generated-plan, and independently loaded emitted-module equality, fresh authority, detached results, and absence of serialized authority. Only durable parent/frontier and current projections move; .14.7.7 closes unchanged and recurring proof .14.7.8 is next."
evidence_update_2026_08_28_recurring_and_public: "FUTURE-PARITY-BACKLOG.14.7.8 runs this unchanged source once per ABI in the recurring matrix at neutral 9/9/123. FUTURE-PARITY-BACKLOG.14.7.9 admits exact assignment-form parse_job authoring and updates only aggregate governance snapshots in this consumer."
last_verified: 2026-08-28
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_local.sh"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "PERL5LIB= prove -q -Iperl t/staged_ast_enrichment_perl_contract.t"
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl"
---

# Independent shared Lua staged-AST recomposition

This closeout adds no umbrella oracle and changes no executable owner. It reruns the already-admitted shared
Lua-5.1-compatible source on both supported hosts, recomposes the four carrier routes and fresh host authority,
checks every admitted peer/current projection, and then closes only task and continuity state.

All five backend sources and six runtime routes remain admitted at 123 neutral mutations. The Lua source
runs exactly once per ABI in ordinary and canonical proof; native, reconstructed, generated-plan, and emitted
results remain equal and authority-free outside their host invocation. Recurring proof and exact public scalar
assignment-form `parse_job(...)` authoring are current; `.14.7.10` owns final staged recomposition.

The executable checker governs behavior, lifecycle, and topology. Knowledge indexing guarantees card freshness
but cannot infer that bounded prose changed from "recomposition pending" to "recomposition complete", so this
leaf corrects those current projections while preserving every dated historical evidence field.

Related: [[lua-staged-ast-enrichment-carriers-admission]],
[[lua-staged-ast-enrichment-recursive-carriers]], [[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]], [[staged-consumer-current-projection-lockstep]], and ADR `0088`.
Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.7.7.5`.
