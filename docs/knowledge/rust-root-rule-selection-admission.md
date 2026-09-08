---
id: rust-root-rule-selection-admission
title: "Rust root selection is topology-admitted; the complete backend rollout is closed"
answers:
  - "is Rust root rule selection fully admitted"
  - "how many shared primary CLI cases does Rust pass"
  - "which Rust root selection roles are topology checked"
  - "what topology does the Rust root selection checker require"
  - "which Rust root selection test runs through the backend gate"
  - "what is the root selection rollout count after Rust"
  - "which variants have root selection parity"
  - "which variants still lack root selection parity after Rust"
date: 2026-09-08
status: Rust admission complete; current five-backend rollout 7 complete / 0 pending
supersedes: rust-root-rule-selection-routes
tags: [rust, root-rule, top-rule, cli, conformance, topology, rollout, FUTURE-PARITY-BACKLOG]
evidence: "Historical July 18 Rust admission: FUTURE-PARITY-BACKLOG.9.1.1.2.2.3 adds `rust/linkedspec-runtime/tests/root_rule_selection_admission.rs`, one omission-sensitive consumer whose 15 contract-declared roles execute exactly once: neutral selection/failure/strict rows; native; loaded; reconstructed; generated direct/traced; emitted direct/traced; descriptor; diagnostic; effective runtime trace; primary command; and primary request trace. The root checker locks its path, exact `role_*` markers, six shared primary case ids, canonical/backend registration, Rust rollout status, and 29 semantic/topology/inventory/rollout mutations. Focused admission/core/routes/emitter proof passes 1+6+6+6. The complete Rust-local gate passes core 193+4+5+8, runtime 137, oracle 105/215.90s, generated classifier 105/249.47s, integration 197, admission 1/16.89s, emitter 6/49.64s, adjacent suites, formatting, and shared primary 65/65 with `POSIXLY_CORRECT` unset and set. Only `rust` advances, so the ledger is 3 complete / 4 pending; Dart, Julia, Lua, and final admission remain `.3-.6`."
evidence_update_2026_07_18_signoff: "Canonical CI passes all four doctrines, root governance with 29 mutations, Perl root consumers 7+5, cursor admission 288, shared reference primary 65x2, and Phase 0 1,031/1,031 in 627 seconds. Public/book/capability/live records agree at 3 complete / 4 pending; Knowledge Map is 603 facts / 4,328 question keys. Safe cleanup removes 10,626 Cargo dependency/incremental files and reduces rust/target from 2.4 GiB to 99 MiB, plus the generated book/cache/logs."
reverify: "bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py && bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test root_rule_selection_admission --test root_rule_selection_core --test root_rule_selection_routes && bash tools/run_rust_local.sh"
---

# Rust root-selection admission

Rust is the second runtime backend admitted to ADR `0046`, after the Perl reference. Its root-selection semantics
are not inferred from scattered green tests: one contract-declared role map composes every neutral and real Rust
projection, rejects omitted or repeated roles, and runs through the complete runtime package in the Rust backend
gate. The neutral checker independently locks that topology and its canonical optional-driver registration.

The July 18 admission shared command boundary was 65/65 in both option environments. This includes an explicit ordinary rule
over authored markers, first-marker default, markerless first-rule default, unknown selection, `<default>` request
trace, and escaped explicit request trace. The selector remains per-execution state; generated format v2, authored
descriptor `is_top`, and the minimal family plan remain unchanged.

At that July 18 Rust milestone, Dart, Julia, Lua and final public no-drift admission remained pending.
Those later steps are complete; [[root-rule-selection-precedence]] owns the current 7 complete / 0 pending rollout.

Related: [[root-rule-selection-precedence]], [[rust-root-rule-selection-routes]],
[[perl-root-rule-selection-admission]], and [[task-tree-capability-markers-not-frontier]].

## 2026-09-08 complete consumer reading

SESSION-STARTUP-READING.3.3.59 reads the complete 610-line admission consumer, complete core consumer,
and route prefix through line 437, all equal to the startup baseline. The fifteen exact roles compose neutral
selection/failure/strict cases, immutable descriptor identity, loaded/reconstructed/native/generated routes,
effective diagnostics and runtime/request traces. Emitted-labelled roles here inspect source; generated roles invoke generated-plan adapters. Independent
emitted compilation belongs to the separate source_emitter consumer.

Fresh neutral governance passes eight selections, three failures, three strict cases, five backends,
7 complete / 0 pending, 24 public documents, 18 stale-current denials and 54 drift mutations. The current shared
primary inventory is 66 cases; the recorded d6f37492 canonical pass ran both reference CLI environments at 66/66.
This checkpoint does not rerun a Rust primary, native, relocated-binary or emitted parser. All 65-case native,
29-mutation and intermediate rollout counts above remain historical admission evidence.
