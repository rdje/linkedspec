---
id: julia-recursive-observation-admission
title: Julia privately admits recursive source observation across all four execution carriers
answers:
  - "does Julia support observe_recognition"
  - "where is Julia recursive observation implemented"
  - "what Julia action node owns observe_recognition"
  - "how does Julia validate recursive observation targets and operands"
  - "how does Julia preserve false observation payloads"
  - "how does Julia convert recursive observation UTF-8 code-unit offsets"
  - "how does Julia reject direct and mutual recursive observation"
  - "does Julia recursive observation reuse recognition invocation identity"
  - "does Julia retain recursive observation history"
  - "does generated Julia source execute recursive observation"
  - "does reconstructed Julia execution preserve recursive observation"
  - "is Julia recursive observation admitted in canonical CI"
  - "does Julia recursive observation change the public facade"
date: 2026-08-12
status: current private Julia and shared-Lua admission; recurrence current and public closeout pending
tags: [julia, source-location, recursion, observation, generated-source, admission, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.4.5 adds dedicated ActionObserveRecognitionExpr parsing and serialization, compiler-wide static and transaction-effect validation, direct-parent and rejected-attempt identity in the existing RecognitionInvocationAuthority, pending-entry observation scopes, ephemeral runtime completions, detached typed record construction, and action-edge single dispatch. julia/test/recursive_observation_contract_test.jl passes seven final-path groups and 30 assertions across native, reconstructed, generated-plan, and independently loaded emitted-module execution. A multibyte-input case proves zero-based UTF-8 code-unit registers become Unicode-scalar positions only through SourceLocation projection. The typed-source checker records Perl, Rust, Dart, and Julia on the still-pending recursive_observation row at 8 complete / 6 pending / 74 mutations. Recognition remains 129 current + four dedicated transaction nodes / 246 calls / 58 mutations because observation closes through the existing binding_write effect rather than widening its public inventory."
evidence_update_2026_08_12_signoff: "Exact Julia composition passes transaction 207, recursive observation 30, typed source 127, and repeated action 162; full ordinary discovery and storage 19/5 are clean. Canonical typed-source signoff passes all eight doctrines, repository containment and relocation, CLI 66/66 in default and POSIX environments, RAM 60%, Phase 0 1,031/1,031 in 725 seconds, and all six typed-source runtime routes through exact local CI success. The first staged run also caught and repaired the already-known bounded-memory historical next-owner coupling without changing runtime behavior or weakening its checker."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/recognition_transaction_contract_test.jl\"); include(\"julia/test/recursive_observation_contract_test.jl\"); include(\"julia/test/typed_source_location_contract_test.jl\"); include(\"julia/test/repeated_action_result_contract_test.jl\")' && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && perl tools/check_language_capability_coverage.pl"
---

Julia recognizes exactly `value = observe_recognition(observation, call(Child))` as one dedicated private
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

Julia retains zero-based UTF-8 code-unit cursor, boundary, match, and mark registers. The existing `SourceLocation`
authority converts entry, selected match, and accepted exit to Unicode-scalar detached records only at projection
time. Native, compiled-spec reconstruction, generated-plan execution, and independently loaded emitted-module
execution all converge on the same engine. The surface remains grammar-owned and private: it adds no facade export,
public helper or typed value, schema field/version, semantic/MCP projection, CLI option, or README claim.

Canonical admission is exact rather than inferred: the repository typed-source opt-in executes Perl, Rust, Dart,
Julia, PUC Lua, and LuaJIT in order, then checks generated-source, capability, and language ledgers. The same run
passes process containment, moved-root execution, both 66-case CLI environments, and Phase 0 before its success
marker. Shared Lua recursive observation is now independently admitted on PUC Lua and LuaJIT; recurrence and public
values remain future.

## Links

- Neutral/audit authority: [[recursive-source-observation-audit]].
- Dart predecessor: [[dart-recursive-observation-admission]].
- Shared Lua successor: [[lua-recursive-observation-admission]].
- Typed-source rollout: [[typed-source-location-runtime-rollout-plan]].
- Recognition authority: [[julia-recognition-transaction-admission]].
- Decision: ADR `0056`, section 25.
- Task owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.4.5`.
