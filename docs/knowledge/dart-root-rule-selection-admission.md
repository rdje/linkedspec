---
id: dart-root-rule-selection-admission
title: "Dart root-rule selection is admitted through one exact 15-role consumer"
answers:
  - "is Dart root rule selection admitted"
  - "which root rule selection variants have parity"
  - "which variant parity has been achieved so far"
  - "what is the current root selection rollout count"
  - "what remains after Dart root selection admission"
  - "how many roles are in Dart root rule selection admission"
  - "where is the Dart root rule selection admission consumer"
  - "which Dart root selection routes are topology checked"
  - "which primary CLI cases admit Dart root selection"
  - "how many root selection drift mutations are checked"
  - "how many Dart package tests pass after root selection admission"
date: 2026-07-18
status: Dart admitted; neutral, Perl, Rust, and Dart complete at 4/7
tags: [dart, root-rule, top-rule, admission, topology, primary-cli, backend-parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.3.3 adds `dart/test/root_rule_selection_admission_test.dart`, one omission-sensitive consumer whose 15 contract-declared roles execute exactly once: neutral selection/failure/strict rows; native; loaded; reconstructed; generated direct/traced; emitted-source direct/traced; descriptor; diagnostic; runtime trace; primary CLI; and primary request trace. The root checker locks exact source role order/inventory, consumer path, six shared primary case ids, package-wide Dart driver, canonical registration, Dart-only rollout promotion, and 34 total semantic/topology/inventory/rollout mutations. Focused admission/core/routes/emitter proof passes 1+14. The complete Dart gate passes format 60/0, analyzer, package 270/270, shared primary 65/65 with `POSIXLY_CORRECT` unset and set, and corpus 105/105. Only Dart advances, so root-selection rollout is 4 complete / 3 pending: neutral, Perl, Rust, and Dart complete; Julia, Lua/LuaJIT, and final composed no-drift remain `.4-.6`."
evidence_update_2026_07_18_signoff: "Canonical CI passes all four doctrines, root governance with 34 mutations, Perl root consumers 7+5, cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 656 seconds. The mdBook passes and Knowledge Map closes at 607 facts / 4,371 question keys."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/root_rule_selection_admission_test[.]dart test/root_rule_selection_core_test[.]dart test/root_rule_selection_routes_test[.]dart test/source_emitter_test.dart && cd .. && bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py && bash tools/run_dart_local.sh"
---

# Dart root-selection admission

Dart is the third admitted backend for `linkedspec-root-rule-selection-v1`, after the Perl reference and Rust.
Together with the neutral contract, that makes the rollout 4 complete / 3 pending. Julia, Lua/LuaJIT, and final
five-backend public no-drift remain dependency-ordered under `.9.1.1.2.4-.6`.

The admission test composes existing semantic owners rather than adding another resolver. Its contract-declared
role map covers neutral selection/failure/strict rows and every native, loaded/reconstructed, generated/emitted,
descriptor, diagnostic, runtime-trace, primary, and request-trace projection exactly once. The checker compares
the complete ordered `role_*` source inventory with the contract, so missing, duplicate, reordered, and invented
roles cannot silently pass.

Emitted-source admission deliberately inspects the generated public entrypoints and selector plumbing. Fresh
isolated-package compilation and direct/traced execution remain deeply owned by the route/source-emitter suite,
which the same focused and package-wide gates execute. This mirrors the admitted Rust topology: admission proves
that all semantic owners remain present and registered without duplicating their expensive mechanism tests.

Related: [[dart-root-rule-selection-routes]], [[dart-root-rule-selection-core]],
[[root-rule-selection-precedence]], and [[rust-root-rule-selection-admission]].
