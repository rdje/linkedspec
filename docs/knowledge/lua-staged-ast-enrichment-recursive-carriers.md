---
id: lua-staged-ast-enrichment-recursive-carriers
title: Lua has private breadth-first staged-AST recurrence through four fresh-authority carriers
answers:
  - "where is Lua recursive staged AST enrichment implemented"
  - "how does Lua queue parse_job markers breadth first"
  - "does Lua rescan old staged parse job markers"
  - "how does Lua detect staged parse job cycles"
  - "when may Lua recursively call the same staged parser and top rule"
  - "what resources are shared across Lua staged parse depths"
  - "how do Lua staged callback safe points work"
  - "when does a Lua staged callback context expire"
  - "how are Lua staged child positions and spans rebased"
  - "which Lua production carriers execute staged AST enrichment"
  - "how does Lua staged AST enrichment get fresh authority per execution"
  - "does Lua generated source serialize staged parser authority"
  - "is Lua staged AST enrichment admitted in ordinary and canonical CI"
  - "how many Lua staged AST enrichment assertions pass"
  - "what does FUTURE-PARITY-BACKLOG 14.7.7.3 implement"
date: 2026-08-27
status: current private dual-ABI recursive carrier; dormant from ordinary and canonical discovery until FUTURE-PARITY-BACKLOG.14.7.7.4
tags: [lua, PUC-Lua, LuaJIT, staged-parsing, recursion, breadth-first, carriers, cancellation, budgets, source-location, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.7.3 preserves enrich_current_depth and adds private Lua-5.1-compatible enrich_recursively, StagedRecursiveAuthority, ephemeral callback authority views, and an opaque StagedAstEnrichmentSeed. The scheduler prepares and reserves a complete depth before callback one, queues only markers found inside successful detached callback results, and maps those markers through the exact replace_marker/replace_field/sibling_field/append_child destination; it never rescans the stitched AST. Active frames carry resolved parser, selected top, exact-text SHA-256, and full direct or ordered-derived provenance. Exact repeats reject as staged_cycle; same parser/top recurrence requires segment containment and a strictly smaller total Unicode-scalar extent. One invocation shares cancellation identity/probe, caller clock and absolute deadline, remaining steps, seeded calls, depth/call maxima, cumulative atomic-marker result nodes, and canonical UTF-8 diagnostic bytes. Fresh callback contexts expose safe_point plus direct/derived position/span/diagnostic rebasing, then expire on return or throw. A host-only execution seed starts only after the complete parent result and creates a new callback map, frozen registry, empty plan cache, cancellation/clock authority, lineage, budget, and queue for every native, SpecFile-JSON reconstructed, validated generated-plan, or independently loaded emitted-module execution. Each route runs twice with eight equal detached outcomes, one miss/no hit/one call per run, fresh run/token observations, no-seed inert-marker compatibility, no authority consumption on parent failure, live-transaction denial, and primary staged-error preservation. Compiled JSON, generated plans, and emitted source contain no callback, registry/source authority, cancellation/deadline/budget state, queue/cache, absolute checkout path, or host handle. The unchanged stable consumer passes 888 assertions independently on PUC Lua and LuaJIT while remaining absent from ordinary and canonical discovery; both Lua rollout rows, neutral 98-mutation lifecycle, function-body v1, generated-source-v2 format, public/outward behavior, other backends, and later recurrence remain unchanged."
root_cause: "The committed .14.7.7.2 engine deliberately discovered and settled one marker depth, hard-coded stage_depth=1 with an empty chain, and returned without recording marker paths from child results. LinkedSpecRuntimeEngine returned the completed parent value directly, while generated-plan and emitted wrappers forwarded only progressive authority. Lua therefore lacked producer-bound lineage, non-resetting recursive resources, callback-lifetime safe points/source projection, and a fresh post-parent host recipe across the four carriers."
last_verified: 2026-08-27
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua"
  - "rg -n 'recursive_authority|evaluate_chain_case|safe_point|rebase_(position|span|diagnostic)|enrich_recursively|execution_seed|start_execution|complete_execution' lua/src/linkedspec/staged_ast_enrichment.lua lua/test/staged_ast_enrichment_contract_test.lua"
  - "rg -n 'staged_ast_enrichment_seed' lua/src/linkedspec/interpreter.lua lua/src/linkedspec/source_emitter.lua"
  - "rg -n 'staged_ast_enrichment_contract_test.lua' tools/run_lua_local.sh lua/test/run.lua tools/run_ci_local.sh"
---

# Lua staged recursive carriers

`enrich_recursively` owns one detached working AST, one caller-frozen registry
and plan-only cache, and one invocation resource record. It prepares a complete
queue depth before executing that depth. Only marker-shaped plain data in a
successful detached callback result enters the next queue. Its future path is
calculated from the stitch policy before settlement, so old inert markers are
never rediscovered.

An active frame is:

```text
[resolved_spec_id, selected_top_rule, payload_sha256, full_provenance]
```

An exact tuple repeat is a cycle. Reusing the parser and top is permitted only
when every child segment stays inside an active segment and the sum of child
Unicode-scalar extents decreases. The rule applies identically to direct and
nonempty `concatenate_in_order` provenance.

Dispatch and child safe points observe the same cancellation probe and
absolute deadline. Required call work, callback work, total calls, depth,
result nodes, and diagnostic bytes never reset at a new job or depth. Callback
contexts have fresh cursor/marks/captures/variables. Their private view can
query remaining work and rebase local positions, half-open spans, or nested
diagnostics, but expires immediately after callback settlement.

`StagedAstEnrichmentSeed` is an opaque host recipe. It validates and owns only
logical snapshot/options plus a factory. Every top-level execution invokes the
factory after the parent AST completes, then constructs a new frozen registry,
empty cache, recursive authority, and mutable scheduler state. Native,
reconstructed, generated-plan, and independently loaded emitted-module routes
all forward the same optional host seed without serializing it. With no seed,
the existing inert marker result is unchanged.

This is private production behavior. Leaf `.14.7.7.4` alone owns ordinary and
canonical dual-ABI admission plus Lua rollout promotion.

Related: [[lua-staged-ast-enrichment-current-depth-authority]],
[[lua-staged-ast-enrichment-marker-provenance]],
[[lua-staged-ast-enrichment-dormant-red]],
[[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]], and ADR `0088`.
