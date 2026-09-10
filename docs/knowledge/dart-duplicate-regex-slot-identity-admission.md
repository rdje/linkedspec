---
id: dart-duplicate-regex-slot-identity-admission
title: "Dart ordered execution preserves the required authored regex alternative directly"
answers:
  - "how did Dart implement duplicate regex slot identity"
  - "what does RuntimeRegexAlternation matchAlternative do"
  - "how does Dart preserve duplicate regex slots in generated execution"
  - "where does Dart validate compiled regex slot identity"
  - "what Dart diagnostics report regex slot identity corruption"
  - "how are duplicate regex slot selections traced in Dart"
  - "does Dart duplicate slot identity widen generated source v2 plans"
date: 2026-07-20
status: confirmed; Dart admitted by FUTURE-PARITY-BACKLOG.9.1.8.1.4
tags: [dart, regex, slot-identity, and, repetition, generated-source, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "RuntimeRegexAlternation.matchAlternative matches the required authored regex and constructs RuntimeRegexMatch with that alternative's original index; AND/repeated execution uses it while OR/default retains full-alternation earliest-start/first-authored choice. Compiled action edges map parent slots to structural target_rule/regex_index identities. Compiler, runtime, descriptor, source emitter, and generated-plan validation reject malformed slots with regex_slot_identity_invalid/validate_compiled_rule. Runtime/generated trace emits dart_runtime:regex_slot_selected. Descriptors and emitted source publish linkedspec-duplicate-regex-slot-identity-v1. Generated v2 embeds normalized SpecFile JSON and keeps exact {label,family} plans. The contract-declared 15-role consumer passes all five fixtures plus loaded/reconstructed, descriptor, emitted/generated, native/generated trace, primary, and diagnostic routes; the complete Dart gate passes 272 tests, primary 65x2, and corpus 105/105."
reverify: "bash tools/run_dart_local.sh && bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py"
---

Dart keeps required-slot and choice matching as separate operations. The
required-slot primitive addresses an authored alternative in the already-
compiled `RuntimeRegexAlternation` and returns that authored index directly.
The ordinary full-alternation matcher remains the owner of earliest-position
and first-authored choice. Repeated AND restarts its expected slot loop on every
accepted iteration.

Action edges translate a parent alternative into structural target-rule plus
child-regex-index identity. This preserves cross-target sequences such as
`First#0`, `Second#0` instead of exposing only parent indices. Native and
generated execution use the same `dart_runtime:regex_slot_selected` event and
the same ordered identity assertion.

Generated source does not widen its v2 plan. The emitted module publishes
`linkedspecRegexSlotIdentityContract`, embeds normalized `SpecFile` JSON, and
reconstructs compiled identities through `compileSpec`. Public validator calls
also protect caller-constructed compiled state before runtime, descriptor,
emission, and generated-plan routes.

Related: [[duplicate-regex-slot-identity-contract]],
[[duplicate-regex-slot-identity-cross-backend-audit]],
[[rust-duplicate-regex-slot-identity-admission]], and
[[FUTURE-PARITY-BACKLOG]].

## September 10 complete duplicate-slot consumer reading

`DART-STARTUP-READING.1.38` finishes lines 124-477 of the Dart consumer after .1.37's
prefix. All fifteen declared roles pass within the selected 15-test suite. The emitted
source role asserts v2/identity/payload markers and absence of text-identity spelling;
it does not independently compile emitted Dart. Direct/generated trace roles execute
the existing runtime and compare structural target/index sequences. Invalid-state tests
cover source validation, compiled validation, runtime, generated-plan and emitter rejection,
plus explicit ordered cross-target mismatch. The neutral checker remains 7 complete/0
pending with 59 drift mutations; no capability or generated-format change occurs.
