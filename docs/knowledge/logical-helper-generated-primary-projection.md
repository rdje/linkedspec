---
id: logical-helper-generated-primary-projection
title: Logical helpers preserve their contract through every generated role and the shared primary matrix
answers:
  - "which generated entrypoints prove LinkedSpec logical helpers"
  - "do generated and or not helpers preserve eager effects"
  - "do traced generated logical helpers return the same value"
  - "why does Rust generated compatibility return an array"
  - "what is the shared logical helper CLI case"
  - "which primary CLI case proves logical helpers on all five backends"
  - "do generated logical arity failures preserve source identity"
date: 2026-07-18
status: current
tags: [logical, generated-source, primary-cli, trace, diagnostics, perl, rust, dart, julia, lua, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.7 expands the unchanged linkedspec-logical-helper-v1 fixtures over every supported generated direct/traced role. Perl covers emitted Execute, ExecuteWithTrace, and Get; Rust covers typed generated-source v2 plus compatibility direct/traced pairs; Dart, Julia, and Lua cover generated-plan plus independently emitted direct/traced functions. Exact values, eager effects, pre-effect arity diagnostics, source/rule/family attribution where exposed, and trace/direct identity pass. Rust typed v2 returns the direct top-rule value while its compatibility pair intentionally retains the historical parse-output array. Shared manifest case success_logical_helpers_eager uses a portable action edge and passes all five commands in default and POSIX environments. FUTURE-PARITY-BACKLOG.5.2.8 makes those exact generated and primary roles recurring; .5.2.9 closes public no-drift at 8 complete / 0 pending; .9.1.4.5 and .9.1.5.4 migrate the exact recurring Rust and Dart role names and markers from generated v1 to v2."
evidence_update_2026_07_18_julia_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.6.4 migrates the exact Julia generated_plan_direct/generated_plan_traced and emitted roles to v2 names and modules; the recurring checker remains 8 complete / 0 pending with 26 mutations."
reverify: "prove -lv t/logical_helper_perl_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test logical_helper_contract && (cd dart && dart test test/logical_helper_contract_test.dart) && JULIA_DEPOT_PATH=/tmp/linkedspec-julia-writable:$HOME/.julia julia --project=julia --startup-file=no --history-file=no --compiled-modules=no julia/test/logical_helper_contract_test.jl && bash tools/run_primary_cli_matrix.sh --case success_logical_helpers_eager"
---

Generated role families retain their established public signatures while sharing logical semantics:

| Backend | Generated roles under proof | Value shape |
| --- | --- | --- |
| Perl | emitted `Execute`, `ExecuteWithTrace`, `Get` | direct value |
| Rust | typed-v2 direct/traced | direct value |
| Rust | compatibility direct/traced | historical parse-output array |
| Dart | generated-plan and emitted direct/traced | direct value |
| Julia | generated-plan and emitted direct/traced | direct value |
| Lua | generated-plan and emitted direct/traced | direct value |

The Rust array is not helper drift: the compatibility API calls the parse-output executor, while typed v2 calls
the direct-value executor. Compare trace to direct within the same signature family. Typed generated failures on
Rust, Dart, Julia, and Lua preserve `execute_generated`, `generated_execution_failed`, source identity, `Top`,
`default`, and the causal helper/arity tokens. Perl preserves the typed control diagnostic itself across all three
roles and publishes source identity through generated metadata.

The shared `success_logical_helpers_eager` case executes decisive-false `and`, decisive-true `or`, and one-operand
`not` with recorded effects. Its action-edge form is portable across the five commands and both option
environments. The full manifest has 63 cases after this admission.

Related facts: [[logical-helper-neutral-contract]], [[logical-helper-five-backend-audit]],
[[generated-source-contract-v1]], [[cross-backend-diagnostic-output-drift]],
[[logical-helper-recurring-five-backend-gate]], [[logical-helper-public-no-drift]].
