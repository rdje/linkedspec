---
id: recognition-transaction-recurring-gate
title: Recognition transactions have one exact five-source six-runtime recurring gate
answers:
  - "how does recognition transaction recurring proof run"
  - "which command runs all recognition transaction runtime consumers"
  - "what does LINKEDSPEC_RUN_RECOGNITION_TRANSACTION_MATRIX run"
  - "which recognition transaction consumers does the recurring gate execute"
  - "why are there five recognition transaction source groups and six runtime routes"
  - "which support ledgers follow recognition transaction consumers"
  - "how many recognition transaction mutations exist after recurring admission"
  - "what is the recognition transaction rollout after recurring composition"
  - "does recurring recognition transaction proof change runtime behavior or public APIs"
  - "where does the recognition transaction recurring gate store project data"
  - "which recognition transaction work remains after recurring composition"
date: 2026-08-11
status: current recurring admission; public no-drift closeout complete under FUTURE-PARITY-BACKLOG.14.3.8
tags: [recognition, transaction, recurring-gate, perl, rust, dart, julia, lua, luajit, conformance, local-ci]
evidence: "FUTURE-PARITY-BACKLOG.14.3.7 adds tools/check_recognition_transaction_six_runtime.sh as one fail-fast repository-routed driver. It validates the neutral checker first, then executes exact Perl 51, Rust 12, Dart 10, Julia 207, PUC Lua 246, and LuaJIT 246 consumers in order, followed by generated-source, capability, and language-coverage ledgers. Five backend source groups become six runtime routes because one shared Lua-5.1-compatible source executes independently on both ABIs. Canonical CI always requires, path-audits, and syntax-checks the driver; LINKEDSPEC_RUN_RECOGNITION_TRANSACTION_MATRIX=1 opts into the all-toolchain route. Eleven topology/storage mutations plus one recurring rollout regression advance neutral governance from 46 to 58; public governance becomes 3 documents / 23 forbidden / 42 mutations and guide governance 1/12/16. Only recurring advances, so rollout is 8/9 and public no-drift remains RED. Signoff passes all eight doctrines, CLI 66x2, RAM 62%, and canonical Phase 0 1,031/1,031 in 745 seconds. No parser, runtime, schema, public API/facade, CLI, README, generated format, toolchain cache root, or authored transaction behavior changes."
evidence_update_2026_08_11_public_closeout: "Closeout .14.3.8 changes no recurring source, route, command, order, support check, storage initializer, or CI switch. It promotes only public no-drift, binds the final ledger row to the three book pages plus capability guide, and closes transaction rollout at 9/9 with public 3/26/45 and guide 1/14/18 while neutral/recurring governance remains 58."
last_verified: 2026-08-11
reverify:
  - "bash tools/check_recognition_transaction_six_runtime.sh"
  - "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
  - "bash tools/test_project_data_workflow_routing.sh"
  - "LINKEDSPEC_RUN_RECOGNITION_TRANSACTION_MATRIX=1 bash tools/run_ci_local.sh"
---

# Recurring recognition-transaction gate

Recurring admission is orchestration over the already admitted transaction implementations, not a seventh
implementation or a broader transaction model. The neutral checker runs before every backend. Perl, Rust, Dart,
Julia, PUC Lua, and LuaJIT then execute in that exact order, and the three support ledgers close the run.

The source and runtime counts intentionally differ. Perl, Rust, Dart, and Julia each own one final-path consumer.
Lua owns one shared Lua-5.1-compatible source that must pass independently on PUC Lua and LuaJIT. The artifact
therefore freezes five source groups and six runtime routes, including command text, order, multiplicity, support
checks, CI switch, and repository-derived storage.

Canonical CI always treats the driver as a tracked, portable, syntax-checked input. The expensive all-toolchain
composition is opt-in through `LINKEDSPEC_RUN_RECOGNITION_TRANSACTION_MATRIX=1`; the admitted individual consumers
remain part of ordinary/canonical proof. The driver creates no storage authority: it enters the existing
`tools/project_data_env.sh` route, and every nested wrapper continues to derive data from the repository root.

Eleven new topology/storage mutations reject source, route, command, order, duplication, support, initializer,
driver, and CI-switch drift. A twelfth mutation rejects a recurring complete-to-RED regression. Together they move
the contract suite to 58 while promoting only rollout row eight. `FUTURE-PARITY-BACKLOG.14.3.8` now closes the
unchanged public projection at 9/9; `.14.8` still retains the broader program-wide source-location closeout.

Related: [[recognition-transaction-neutral-contract]], [[lua-recognition-transaction-admission]],
[[typed-source-location-recurring-gate]], and [[semantic-introspection-recurring-gate]].
