---
id: dart-root-rule-selection-preflight
title: "Dart root selection is exactly 64/65 because validation blocks an already-correct fallback"
answers:
  - "why does Dart fail one root selection primary case"
  - "what is Dart root selection parity before implementation"
  - "does Dart already select the first rule when there is no marker"
  - "what blocks markerless Dart specs"
  - "which Dart root selection routes already work"
  - "what Dart root selection diagnostics still differ"
  - "does Dart descriptor publish the root selection contract"
  - "how is Dart root selection implementation split"
date: 2026-07-18
status: current behavior-free causal map; implementation staged
tags: [dart, root-rule, top-rule, markerless, validation, generated-source, descriptor, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.3.0 runs the complete shared primary manifest with `POSIXLY_CORRECT` unset and set: Dart passes 64/65 both times. Only `success_markerless_first_authored_rule` fails with empty stdout, compile exit 1, and `linkedspec: parser compilation failed`; medium trace ends at `compile:error` after recording `top_rule=<default>`. Exact API probing finds `_checkTopRuleExists` is the normal-source blocker. Ordered compiled/AST state preserves authored `is_top`; bypass-only native, normalized-JSON, generated direct, and explicit routes already implement explicit > first marker > first rule. Loaded source validates separately, and emitted v2 reconstruction calls ordinary validating `compileSpec`, so both block markerless state. Unknown explicit selection currently reports untyped `rule_lookup`; zero compiled rules report untyped `top_rule_selection`; root descriptor metadata lacks `entry_rule_contract`. Strict defined-minus-referenced logic and request trace are already independent/correct. Focused owners pass 97/97; complete Dart passes format, analysis, package 260/260, and corpus 105/105. Rollout stays 3 complete / 4 pending. `.3.1` owns core/descriptor, `.3.2` composed routes, and `.3.3` topology/reference admission."
evidence_update_2026_07_18_signoff: "Behavior-free canonical CI passes all four doctrines, root governance with 29 mutations, Perl root consumers 7+5, cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 655 seconds. The mdBook passes; Knowledge Map is 604 facts / 4,336 question keys. Cleanup removes only the generated 11 MiB book and Python cache while retaining Dart's required local package configuration and tracked evidence logs."
reverify: "cd dart && dart test test/spec_validator_test.dart test/runtime_interpreter_test.dart test/source_emitter_test.dart test/rule_local_cursor_descriptor_test.dart test/spec_loader_test.dart test/primary_cli_test.dart && cd .. && env -u POSIXLY_CORRECT PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'dart run bin/linkedspec_dart.dart' -- dart --packages={{REPO_ROOT}}/dart/.dart_tool/package_config.json '{{REPO_ROOT}}/dart/bin/linkedspec_dart.dart'"
---

# Dart root-selection preflight

Dart's missing parity is not a missing fallback algorithm. `LinkedSpecRuntimeEngine` already resolves an explicit
label first, otherwise scans ordered compiled rules for the first authored marker, otherwise returns the first
rule. Normal validation rejects every markerless source before that final branch can run. The same validation is
used by loaded source and by emitted v2 payload reconstruction.

The safe implementation boundary is therefore centralized. Core work replaces marker-required validation with
one-or-more-rule validation, makes the compiled-state resolver own portable zero and unknown failures, preserves
strict graph semantics, and publishes immutable descriptor identity. Route work proves loaded, normalized,
generated direct/traced, and emitted direct/traced execution against that owner. Admission alone may promote Dart.

Related: [[root-rule-selection-precedence]], [[rust-root-rule-selection-admission]], and
[[perl-root-rule-selection-admission]].
