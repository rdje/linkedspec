---
id: lua-semantic-introspection-admission
title: Lua semantic introspection is admitted by one identical consumer on both ABIs
answers:
  - "is Lua semantic introspection admitted"
  - "what admits the Lua semantic index"
  - "which test composes every Lua semantic introspection path"
  - "does PUC Lua use the same semantic admission consumer as LuaJIT"
  - "how many Lua semantic admission roles exist"
  - "does Lua match all 20 semantic query responses"
  - "which Lua semantic runtime routes are admitted"
  - "what is semantic introspection rollout after Lua admission"
  - "what is semantic introspection native admission after Lua"
  - "how many semantic introspection mutations are rejected after Lua admission"
  - "what task follows Lua semantic introspection admission"
date: 2026-07-28
status: current
supersedes: lua-semantic-introspection-admission-plan
tags: [lua, luajit, semantic-introspection, admission, conformance, mutations, rollout, parity]
evidence: "FUTURE-PARITY-BACKLOG.10.7.7 adds lua/test/semantic_introspection_lua_admission_test.lua, one exact Lua-5.1-compatible ordered 12-role consumer run unchanged on PUC Lua and LuaJIT. It composes strict source/outcome snapshots, static/call/staged/generated projections, immutable typed/raw-neutral queries, native observations, observed-index derivation, public generated helpers, fresh emitted modules, trace, and isolated hosts. Each ABI passes 408 assertions. Both admission rows share the same path/driver/roles; nine Lua mutations bring the neutral contract to 98 rejected mutations and advance only lua_dual_abi to rollout 6/9 and native admission 6/6."
last_verified: 2026-07-28
reverify:
  - "bash tools/run_lua_local.sh"
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
---

# Lua Semantic Introspection Admission

Lua is the fifth and final native implementation admitted for `linkedspec-semantic-model-v1` and
`linkedspec-semantic-query-v1`. Admission adds no second semantic model. One source file declares the established
twelve roles once and runs unchanged under PUC Lua and LuaJIT.

The consumer covers strict source normalization; compiled graph/call/privacy, failed, and observed runtime
snapshots; direct, loaded, JSON-reconstructed, generated-plan, public-helper, fresh-emitted, isolated, and traced
execution; native/neutral JSON identity; all twenty exact response digests; privacy, pages, budgets, portable
errors, explanations, isolation, and query non-execution; and denial of paths, host tables/metatables, Lua
implementation/type text, AST/ActionIR, observation objects, generated source, trace, and pointer identity.

The neutral checker requires identical consumer objects for both ABI rows, exact ordered role markers, one
canonical invocation per ABI, and canonical CI registration. Nine mutations independently lock the two admission
statuses, path omission/alteration, role omission/reordering, driver alteration, rollout rollback, and
registration omission. Governance is six fixture groups, twenty response hashes, 98 rejected mutations, rollout
6/9, and native admission 6/6. Recurring six-runtime composition remains the separate next owner.

Related facts: [[semantic-introspection-neutral-contract]], [[lua-semantic-introspection-authority-map]],
[[lua-semantic-query-public-api]], [[lua-semantic-runtime-observation-authority-map]],
[[lua-semantic-runtime-observation-generated-routes]], [[perl-semantic-introspection-admission]],
[[rust-semantic-introspection-admission]], [[dart-semantic-introspection-admission]], and
[[julia-semantic-introspection-admission]].
