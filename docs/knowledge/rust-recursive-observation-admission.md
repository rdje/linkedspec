---
id: rust-recursive-observation-admission
title: Rust privately admits recursive source observation across all four execution carriers
answers:
  - "does Rust support observe_recognition"
  - "where is Rust recursive observation implemented"
  - "what Rust expression node owns observe_recognition"
  - "how does Rust validate recursive observation targets and operands"
  - "how does Rust preserve false observation payloads"
  - "how does Rust record recursive entry selected match and accepted exit"
  - "how does Rust reject direct and mutual recursive observation"
  - "does Rust recursive observation reuse recognition invocation identity"
  - "does Rust retain recursive observation history"
  - "does generated Rust source execute recursive observation"
  - "does serialized Rust reconstruction preserve recursive observation"
  - "is Rust recursive observation admitted in canonical CI"
  - "how does Rust recursive observation preserve repeated action result collection"
date: 2026-09-07
status: Rust admission complete; current public closeout is recorded in the typed-source rollout plan
tags: [rust, source-location, recursion, observation, generated-source, admission, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.4.3 adds dedicated ObserveRecognition parsing/serialization, compiler-wide static and transaction-effect validation, direct-parent and rejected-attempt identity in the existing RecognitionTransactionAuthority, pending-entry-only observation scopes, ephemeral runtime completions, detached typed record construction, action-edge single-dispatch policy, and native/generated execution. rust/linkedspec-runtime/tests/recursive_observation_contract.rs passes seven final-path cases across native, serialized reconstruction, generated-plan, and independently compiled emitted source, including a regression proving nested ordinary self-recursion is not misclassified as an observed edge. Observation-only and existing self-finalizer action edges share the governed execute-and-collect branch; tools/check_repeated_action_result_contract.py locks the resulting collect_or_return_action_value! topology at eight sites, and the Rust repeated-action consumer passes 3/3 after consolidation. The typed-source checker records Perl and Rust on the still-pending recursive_observation row at 8 complete / 6 pending / 72 mutations. Recognition remains 129 current + four dedicated transaction nodes / 246 calls / 58 mutations because observation is an existing binding_write effect rather than another neutral inventory row."
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract --test recursive_observation_contract --test recognition_transaction_contract && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && perl tools/check_language_capability_coverage.pl"
---

Rust recognizes exactly `value = observe_recognition(observation, call(Child))` as one dedicated private
`Expr::ObserveRecognition`. The parser rejects a non-bare target, a dynamic or malformed operand, and a missing
static rule before execution. Compiler-wide effect closure also forbids an observation binding write from any rule
reached by `recognize_once`, including transit through ordinary rule calls and user-function calls.

The engine invokes the ordinary child exactly once and preserves its payload independently from observation
truthiness. Direct invocation invents no entry match; action-edge invocation retains the parent-selected entry
match. The child continues to own its family-derived seek/consume policy and terminal local-match register. Normal,
failed, aborted, and rejected completions bind the detached nine-field observation before returning or propagating
the unchanged failure.

`RecognitionTransactionAuthority` is the only parse-local invocation authority. Frame entry captures the direct
parent, and pre-entry progress rejection reserves the next attempted-child identity without a frame push. An
observation scope intercepts only its one pending child entry and disarms after successful entry; an ordinary
nested self-call inside that child retains the existing recursion-cutoff behavior. A completion exists only inside
the active observation boundary and is consumed immediately. UTF-8-byte
registers remain internal; the existing source authority converts entry, match, and exit to Unicode-scalar typed
records at projection time. No source text, path, parser, live frame, match object, authority, host reference,
second stack, or parse-wide history escapes.

The same implementation is exercised natively, after compiled-spec JSON reconstruction, through generated-plan
execution, and from independently compiled emitted Rust source. At that admission milestone the surface remained grammar-owned and private: it
does not add a public helper or typed value, facade method, schema field/version, semantic/MCP projection, CLI
option, or README claim.

Observation-only action edges and the pre-existing self-finalizer edge both need one block execution followed by
the same repeated-action result collector. They therefore share one engine branch rather than duplicating the
governed collector seam. The neutral repeated-action checker pins eight collector sites, while the runtime consumer
proves per-hit collection and exact once-only execution independently from observation behavior.

Definitive admission passes the exact six-runtime typed-source composition, five-backend repeated-action
composition, all eight doctrines, repository containment and relocation, CLI 66/66 in both option environments,
RAM 46%, and canonical Phase 0 1,031/1,031 in 744 seconds through `[ci] local CI gate passed` with exit 0.

## Links

- Neutral/audit authority: [[recursive-source-observation-audit]].
- Perl predecessor: [[perl-recursive-observation-admission]].
- Typed-source rollout: [[typed-source-location-runtime-rollout-plan]].
- Recognition authority: [[rust-recognition-transaction-private-authority]].
- Decision: ADR `0056`, section 23.
- Task owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.4.3`.

## 2026-09-07 completion adapter reading

`SESSION-STARTUP-READING.3.3.29` reads runtime.rs 822–2318. Recognition and observation
scopes retain a completion-base offset, split off their local completions and select the last matching
callee label. Observation entry disarms its pending-entry flag; rejection reserves an attempted-child identity
without a live frame. The detached nine-field record distinguishes rejected, aborted, accepted and failed,
and supplies an accepted exit position only for acceptance. Entry/match/exit bytes use typed projection.
This is source evidence, not a fresh native observation run. Current neutral typed proof passes six observations,
14 complete/zero pending and 231 mutations, including public guards; the 8/6/72 admission count above is historical.
