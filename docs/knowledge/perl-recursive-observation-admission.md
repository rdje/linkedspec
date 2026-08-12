---
id: perl-recursive-observation-admission
title: Perl privately admits recursive source observation across live and generated execution
answers:
  - "does Perl support observe_recognition"
  - "where is Perl recursive observation implemented"
  - "what ActionIR node owns observe_recognition"
  - "how does Perl validate recursive observation targets and operands"
  - "how does Perl preserve false zero empty and undef observation payloads"
  - "how does Perl record recursive entry selected match and accepted exit"
  - "how does Perl reject direct and mutual recursive observation"
  - "does Perl recursive observation add another invocation stack"
  - "does Perl retain recursive observation history"
  - "does generated Perl source execute recursive observation"
  - "is recursive observation a public helper"
  - "is Perl recursive observation admitted in canonical CI"
date: 2026-08-12
status: current private Perl admission; all runtime successors and recurrence current; public closeout pending
tags: [perl, source-location, recursion, observation, ActionIR, generated-source, admission, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.4.2 adds dedicated OBSERVE_RECOGNITION scanning/lowering, RecursiveObservationPolicy static validation, direct-parent and rejected-attempt identity in the existing RecognitionTransaction authority, detached SourceLocation record builders, live/generated runtime observation, and unchanged typed recursion errors. t/recursive_observation_perl_contract.t passes seven top-level groups covering exact event/lowering, static failures, falsey/failure outcomes, entry/match/exit/cursor/detach behavior, abort/reject identity, direct/mutual guards, and independently loaded emitted source. The typed-source checker records Perl on the still-pending recursive_observation row at 8 complete / 6 pending / 71 mutations. The recognition checker remains complete at 129 current + four dedicated transaction nodes, 246 calls, and 58 mutations because OBSERVE_RECOGNITION is a rejected binding_write effect. Language coverage classifies observe_recognition as grammar-owned/non-public outside the 246 helper inventory."
canonical_update_2026_08_12: "Canonical proof exposed admitted recognition consumers that snapshot the live and aggregate ActionIR counts. Neutral metadata assertions now expect 129 live in Rust, Dart, Julia, and Lua and 133 aggregate in Dart, Julia, and Lua; backend transaction behavior and the 9/9 rollout are unchanged."
rust_successor_update_2026_08_12: "Rust successor .14.4.3 is now admitted across native, reconstructed, generated-plan, and independently compiled emitted carriers. The pending recursive_observation row contains Perl and Rust at unchanged 8/6 rollout and 72 mutations; Dart, Julia, and shared Lua remain pending."
signoff_update_2026_08_12: "Definitive signoff passes the rendered book at 79 files / 14508 KiB, Knowledge Map at 822 facts / 6843 question keys, all eight doctrines, exact six-runtime typed-source composition, repository containment and relocation, primary CLI 66/66 in both option environments, RAM 50%, and Phase 0 1031/1031 in 723 seconds through exact local-CI success with exit 0."
reverify: "perl -c -Iperl perl/LinkedSpec/RecursiveObservationPolicy.pm && perl -c -Iperl perl/LinkedSpec/RecognitionTransactionRuntime.pm && prove -Iperl t/recursive_observation_perl_contract.t t/recognition_transaction_perl_authority.t t/recognition_transaction_perl_contract.t t/generated_source_contract.t && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && perl tools/check_language_capability_coverage.pl"
---

Perl recognizes exactly `value = observe_recognition(observation, call(Child))` as a dedicated
`OBSERVE_RECOGNITION` ActionIR event. Generic assignment and nested-call scanners skip the special form. The
compiler policy requires one bare observation target, exact arity, and one static existing `call(Rule)` operand;
invalid forms produce the neutral target or operand diagnostic before execution.

The private runtime invokes the ordinary generated child handler once. A direct observation creates source state
without an invented match; an action edge forwards the selected parent match. The child retains its generated
handler family and seek/consume policy. Entry is captured before child lifecycle/matching, every local selection
replaces the selected-match candidate, and accepted exit is emitted only on accepted completion. The ordinary
payload channel preserves false, zero, empty text, undef, and failures independently of observation outcome.

`RecognitionTransaction` remains the sole parse-local invocation authority. Frame entry captures a nullable
direct-parent id; pre-entry direct or mutual rejection reserves the next attempted-child id under the active frame
without pushing a frame. Observation completion is ephemeral and immediately converted to a recursively detached
nine-field harray. No source text, path, parser, live frame, match object, authority, host reference, second stack,
or parse-wide history escapes.

Canonical CI requires, syntax-checks, and executes the exact final-path consumer with the existing Perl typed-
source consumers. The form is grammar-owned and private: it is not a public helper, a new authored value kind, a
descriptor/generated schema revision, a semantic/MCP field, or a CLI/README surface. Rust is now independently
admitted by `.14.4.3`; Dart, Julia, shared Lua, recurring composition, and public
closeout remain owned by `.14.4.4-.8`.

## Links

- Neutral/audit authority: [[recursive-source-observation-audit]].
- Typed-source rollout: [[typed-source-location-runtime-rollout-plan]].
- Recognition authority: [[perl-recognition-transaction-private-authority]].
- Decision: ADR `0056`, section 22.
- Task owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.4.2`.
