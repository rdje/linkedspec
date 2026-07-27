---
id: dart-root-rule-selection-routes
title: "Dart loaded, normalized, generated, emitted, and traced routes reuse one root resolver"
answers:
  - "do Dart loaded specs use the root rule resolver"
  - "does Dart normalized JSON preserve root rule selection"
  - "do Dart generated parsers support markerless default selection"
  - "does emitted Dart source support an explicit top rule"
  - "what does Dart root selection trace record"
  - "what trace level records Dart entry rule selection"
  - "what generated Dart diagnostic reports an unknown top rule"
  - "what generated Dart diagnostic reports zero rules"
  - "does Dart generated root selection change the v2 artifact format"
  - "does Dart root selection widen the generated family plan"
  - "does stale Dart generated contract validation run before root selection"
  - "is Dart root rule selection admitted after route convergence"
date: 2026-07-18
status: superseded by completed Dart admission
tags: [dart, root-rule, top-rule, loader, normalized-json, generated-source, emitted-source, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.3.2 adds `dart/test/root_rule_selection_routes_test.dart` and expands loader/emitter tests. File-loaded and normalized-JSON reconstructed `CompiledSpec` state preserves definition order, authored `is_top`, and descriptor JSON while default and explicit execution call `CompiledSpec.resolveEntryRule`. Generated direct/traced and a fresh isolated emitted package apply explicit selector > first authored marker > first authored rule through the same runtime. `dart_runtime:entry_rule_selection` is a low-level decision with requested/effective/basis; failure records requested identity plus portable stage/code. Loader zero-rule validation projects `no_rules_defined` / `validate_spec`. Generated zero and unknown selection project `no_rules_defined` / `validate_spec` and `entry_rule_not_found` / `select_entry_rule` with requested `entry_rule`, while unrelated execution failures retain the generic wrapper. Contract/plan validation remains before selection. Generated artifacts stay `linkedspec-generated-source-v2` / format 2 with the unchanged minimal ordered label/family plan and existing optional-`topRule` API signatures. Focused proof passes 86+14; full Dart format 59/0, analyzer, package 269/269, primary 65x2, and corpus 105/105 pass. No Dart admission object or rollout row changes; `.3.3` remains required and rollout stays 3/7."
evidence_update_2026_07_18_signoff: "Canonical CI passes all four doctrines, root governance with 29 mutations, Perl root consumers 7+5, cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 628 seconds. The mdBook passes and Knowledge Map closes at 606 facts / 4,360 question keys. Cleanup removes the generated 11 MiB book and Python bytecode cache while retaining required backend state."
evidence_update_2026_07_18_admission: "Superseded for current rollout status by [[dart-root-rule-selection-admission]]. Leaf `.9.1.1.2.3.3` composes every contract-declared Dart projection once, locks source role inventory, driver/case registration, and five additional mutations, and advances Dart to complete at 4/7 after package 270, primary 65x2, and corpus 105 proof."
reverify: "cd dart && dart test test/root_rule_selection_routes_test.dart test/source_emitter_test.dart test/spec_loader_test.dart test/trace_test.dart test/runtime_interpreter_test.dart && cd .. && bash tools/run_dart_local.sh && bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
---

# Dart root-selection routes

Dart route adapters do not implement their own precedence. Loaded source and normalized JSON both produce the
same ordered `CompiledSpec`, and generated direct/traced plus freshly emitted direct/traced execution pass their
invocation-local `topRule` into the ordinary runtime. `CompiledSpec.resolveEntryRule` remains the only semantic
decision owner.

Generated identity is deliberately unchanged. The artifact stays v2/format 2 and its plan remains ordered
`{label, family}` rows; authored marker bits live in reconstructed compiled state, while an explicit selector is
one call's execution state. Existing generated functions already expose optional `topRule`, so route convergence
does not add a parallel API family.

Trace and diagnostic wrappers now preserve the decision rather than hiding it. Every enabled trace can observe
the low-level selection record with requested, effective, and basis fields. Zero-rule and unknown-selection
failures retain their neutral codes/stages at loader and generated boundaries, but unrelated runtime failures keep
the established generic generated-execution classification. Generated contract/plan rejection still occurs
first, preventing stale artifacts from being mistaken for selection failures.

This mechanism proof is now composed by [[dart-root-rule-selection-admission]]. Leaf `.9.1.1.2.3.3` declares and
topology-checks the exact Dart role consumer, runs the full Dart/reference boundary, and advances only Dart. The
neutral root-selection rollout is therefore 4 complete / 3 pending.

Related: [[dart-root-rule-selection-core]], [[root-rule-selection-precedence]], and
[[rust-root-rule-selection-routes]].
