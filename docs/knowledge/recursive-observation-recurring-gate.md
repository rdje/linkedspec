---
id: recursive-observation-recurring-gate
title: Recursive observation has one exact five-source six-runtime recurring gate
answers:
  - "how does recursive observation recurring proof run"
  - "which command runs recursive observation on all six runtimes"
  - "what does LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX run"
  - "which sources belong to the recursive observation recurring gate"
  - "why are there five recursive observation sources and six runtime routes"
  - "which support ledgers follow recursive observation runtime proof"
  - "what is the current recursive observation rollout"
  - "how many typed source mutations exist after recursive observation recurrence"
  - "does recursive observation recurrence add a public API"
  - "is recurring_public_no_drift complete after recursive observation recurrence"
date: 2026-08-12
status: current recurring proof and public projection/no-drift; final combined row complete
tags: [source-location, recursion, observation, recurring-gate, perl, rust, dart, julia, lua, luajit, local-ci]
evidence: "FUTURE-PARITY-BACKLOG.14.4.7 adds tools/check_recursive_observation_six_runtime.sh as one project-data-routed fail-fast driver. It runs the neutral checker, then the exact Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT recursive-observation consumers, followed by generated-source, capability, and language-coverage ledgers. Five tracked backend sources form six routes because lua/test/recursive_observation_contract_test.lua executes unchanged once per ABI. Canonical CI requires, path-audits, and syntax-checks the driver; LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX=1 opts into it. Eleven topology/storage mutations plus one recurrence regression advance typed-source governance from 75 to 87 and promote only recursive_observation, producing 9 complete / 5 pending. Definitive canonical proof passes containment/relocation, CLI 66/66 twice, RAM 62%, Phase 0 1031/1031 in 723 seconds, and the complete matrix through the exact local-CI marker. The combined recurring_public_no_drift row remains pending. No parser, compiler, runtime, facade, schema, semantic/MCP, CLI, README, or storage-root behavior changes."
evidence_update_2026_08_12_public_closeout: "FUTURE-PARITY-BACKLOG.14.4.8 leaves the five sources, six routes, support ledgers, storage route, CI switch, recursive_observation completion, and combined .14.8 row unchanged. It adds independent public projection/no-drift governance over six documents, six stale claims, and ten public surfaces through 27 mutations, advancing the checker from 87 to 114 while rollout remains 9 complete / 5 pending."
evidence_update_2026_08_28_program_wide_closeout: "Final .14.8 composes this unchanged driver with the five other recurring authorities, promotes only recurring_public_no_drift, and advances aggregate typed governance to 14/0/231 without changing recursive-observation sources, routes, results, or public API."
last_verified: 2026-08-12
reverify:
  - "bash tools/check_recursive_observation_six_runtime.sh"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "bash tools/test_project_data_workflow_routing.sh"
  - "LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX=1 bash tools/run_ci_local.sh"
---

# Recurring recursive-observation gate

This gate composes existing admitted consumers; it is not a seventh implementation or another semantic oracle.
The neutral contract runs first. Perl, Rust, Dart, and Julia then run their exact final-path consumer once. The one
Lua-5.1-compatible consumer runs independently on PUC Lua and LuaJIT, giving five source groups and six ordered
runtime routes. Generated-source, capability, and language-coverage ledgers close the support boundary.

Run it from the repository root:

```bash
bash tools/check_recursive_observation_six_runtime.sh
```

Canonical CI always inventories and syntax-checks the rooted driver. Set
`LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX=1` to execute the same all-toolchain composition from the local gate.
The project-data initializer derives every cache, build, native, test, and temporary path from the repository.

The checker binds exact source paths, commands, source-to-runtime mapping, order, multiplicity, support-ledger
order, storage initialization, workflow routing, CI registration, and rollout ownership. Its twelve recurrence
regressions reject drift in those properties or a complete-to-pending regression. Public closeout adds 27
independent projection, stale-claim, and surface mutations, bringing observation-boundary governance to 114.
Public helpers and values remain absent; final `.14.8` now completes the separate combined row without changing
this gate.

Related: [[recursive-observation-public-no-drift]], [[recursive-source-observation-audit]],
[[typed-source-location-recurring-gate]], and [[typed-source-location-runtime-rollout-plan]].
