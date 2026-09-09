---
id: dart-recursive-observation-admission
title: Dart privately admits recursive source observation across all four execution carriers
answers:
  - "does Dart support observe_recognition"
  - "where is Dart recursive observation implemented"
  - "what Dart action node owns observe_recognition"
  - "how does Dart validate recursive observation targets and operands"
  - "how does Dart preserve false observation payloads"
  - "how does Dart convert recursive observation UTF-16 offsets"
  - "how does Dart reject direct and mutual recursive observation"
  - "does Dart recursive observation reuse recognition invocation identity"
  - "does Dart retain recursive observation history"
  - "does generated Dart source execute recursive observation"
  - "does reconstructed Dart execution preserve recursive observation"
  - "is Dart recursive observation admitted in canonical CI"
  - "does Dart recursive observation change the public facade"
date: 2026-08-12
status: current private Dart admission; Julia Lua and recurrence current; public closeout pending
tags: [dart, source-location, recursion, observation, generated-source, admission, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.4.4 adds dedicated ActionObserveRecognitionExpr parsing and serialization, compiler-wide static and transaction-effect validation, direct-parent and rejected-attempt identity in the existing RecognitionInvocationAuthority, pending-child observation scopes, ephemeral runtime completions, detached typed record construction, and action-edge single dispatch. dart/test/recursive_observation_contract_test.dart passes seven final-path cases across native, serialized reconstruction, generated-plan, and independently analyzed/executed emitted source. An astral-input case proves UTF-16 code-unit registers become Unicode-scalar positions only through SourceAuthority projection. The typed-source checker records Perl, Rust, and Dart on the still-pending recursive_observation row at 8 complete / 6 pending / 73 mutations. Recognition remains 129 current + four dedicated transaction nodes / 246 calls / 58 mutations because observation closes through the existing binding_write effect rather than widening its public inventory. Definitive signoff passes all eight doctrines, repository containment and relocation, CLI 66/66 in both option environments, RAM 57%, Phase 0 1,031/1,031 in 752 seconds, and the complete six-runtime typed-source opt-in through the exact local-CI success marker with exit 0."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/recursive_observation_contract_test.dart test/recognition_transaction_contract_test.dart test/typed_source_location_contract_test.dart test/repeated_action_result_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && cd .. && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && perl tools/check_language_capability_coverage.pl"
---

Dart recognizes exactly `value = observe_recognition(observation, call(Child))` as one dedicated private
`ActionObserveRecognitionExpr`. The parser rejects a non-bare target, a dynamic or malformed operand, and a
missing static rule before execution. Compiler-wide effect closure also forbids an observation binding write from
any rule reached by `recognize_once`, including transit through ordinary rule calls and user-function calls.

The shared interpreter invokes the ordinary child exactly once and preserves its payload independently from
observation truthiness. Direct invocation invents no entry match; action-edge invocation retains the parent-selected
entry match. The child continues to own its family-derived seek/consume policy and terminal local-match register.
Normal, failed, aborted, and rejected completions bind the detached nine-field observation before returning or
propagating the unchanged typed failure.

`RecognitionInvocationAuthority` is the only parse-local invocation authority. Frame entry captures the direct
parent, and pre-entry progress rejection reserves the next attempted-child identity without a frame push. A scope
intercepts only its pending observed child and disarms after successful entry, so ordinary nested self-recursion
retains the existing cutoff. A completion exists only inside the active observation boundary and is consumed
immediately. No source text, path, parser, live frame, match object, authority, host reference, second stack, or
parse-wide history escapes.

Dart retains UTF-16 code-unit cursor, boundary, match, and mark registers. The existing source authority converts
entry, selected match, and accepted exit to Unicode-scalar detached records only at projection time. Native,
compiled-spec reconstruction, generated-plan execution, and independently analyzed/executed emitted source all
converge on the same engine. The surface remains grammar-owned and package-private: it adds no facade export,
public helper or typed value, schema field/version, semantic/MCP projection, CLI option, or README claim.

## Links

- Neutral/audit authority: [[recursive-source-observation-audit]].
- Rust predecessor: [[rust-recursive-observation-admission]].
- Typed-source rollout: [[typed-source-location-runtime-rollout-plan]].
- Recognition authority: [[dart-recognition-transaction-dormant-red]].
- Decision: ADR `0056`, section 24.
- Task owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.4.4`.

## Reading qualification — 2026-09-09

DART-STARTUP-READING.1.7 confirms a limit to the earlier compiler-wide claim: action/blind transitions are absent from the special observation effect graph. Ordinary call(Observer) is rejected, but both structural routes compile and enter the same Observer lifecycle during recognize_once. The eight native/authority controls in [[dart-recognition-effect-integration-gap]] also show a generic binding write survives rollback. DART-STARTUP-READING.2.4 owns gated repair; no generated/emitted or other-backend result is inferred from this new probe.
