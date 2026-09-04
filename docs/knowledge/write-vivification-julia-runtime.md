---
id: write-vivification-julia-runtime
title: Julia nested writes use one evaluated typed path and isolated dense publication
answers:
  - how does Julia implement nested write vivification
  - what Julia AST node owns document key position assignment
  - does Julia nested assignment create missing containers
  - how does Julia distinguish absent from bound null during nested writes
  - do Julia emitted parsers preserve nested write path expressions
  - where is the Julia write vivification regression test
date: 2026-09-03
status: current; Julia nested writes and map_leaves bang implemented, Lua now implements both, portable admission pending
tags: [julia, actionir, assignment, autovivification, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.5.1 replaces authored Julia key/index-tagged assignment lowering with ActionWritePathSegment plus ActionAssignNestedAccessExpr. Parser/compiler/runtime/source-emitter validation carries typed expressions and Unicode-scalar spans through native, SpecFile reconstruction, generated-plan, emitted-module, and primary-CLI routes. Runtime evaluates every segment then RHS, snapshots afterward, distinguishes absent from bound null, builds selector-determined dense harray/array state on an isolated copy, publishes once, preserves completed expression effects and original expression failures, and returns detached results. julia/test/write_vivification_contract_test.jl directly consumes the unchanged 5/7/11/16/3/3 neutral fixture and verifies malformed-carrier rejection. Julia map_leaves! and Lua/public admission remain pending."
evidence_update_2026_09_03_julia_map_leaves: "FUTURE-PARITY-BACKLOG.19.5.2 adds Julia's separate typed receiver-mutation carrier and identity-guarded copy-on-write runtime without changing nested-write semantics. The 496-assertion permanent suite composes callback-local, unrelated, same-receiver, shadow, and post-commit nested writes across native, reconstructed, generated-plan, emitted-module, and CLI routes. Both Julia mechanisms are current; Lua and portable/public admission remain pending."
evidence_update_2026_09_04_lua_map_leaves: "FUTURE-PARITY-BACKLOG.19.6.2 implements the same unchanged receiver-mutation contract in shared Lua on PUC Lua and LuaJIT. Julia behavior remains unchanged; all five backend implementations are current while portable/public admission remains pending."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include(\"julia/test/write_vivification_contract_test.jl\")' && bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py"
---

# Julia write-vivification runtime

Julia parses every authored one- or many-segment bracket assignment into one
`ActionAssignNestedAccessExpr`. Each `ActionWritePathSegment` owns its original typed
expression, source text, and half-open Unicode-scalar span; source spelling no longer
preselects harray versus array behavior.

`_assign_runtime_nested!` evaluates all segment expressions from left to right and then
the RHS exactly once. Only afterward does it read binding presence and copy the current
root. Evaluated strings select harrays, nonnegative integers select zero-based arrays,
missing containers are created only when the current or next selector determines their
kind, and arrays may replace or append at exactly `length` but may not contain invented
gap fillers. Present null and existing wrong-kind values fail rather than becoming new
containers.

Structural work mutates only the copied root. Success publishes once and returns another
copy; failure publishes no partial path while retaining ordinary segment/RHS side effects
that completed before the snapshot. Reads keep their older non-creating behavior.
Malformed typed write carriers are rejected by compiler, direct runtime, generated-plan,
and source-emission boundaries.

Related: [[write-vivification-neutral-contract]], [[terse-nested-value-path-assignment]],
[[julia-runtime-core-value-capture-helpers]], [[write-vivification-receiver-mutation-direction]],
and ADR `0036`.
