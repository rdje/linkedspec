---
id: perl-recognition-transaction-dormant-red
title: Perl recognition transactions parse but stop at four missing dedicated ActionIR nodes
answers:
  - "where is the dormant Perl recognition transaction RED consumer"
  - "what is the first Perl recognition transaction RED failure"
  - "does Perl parse recognition_checkpoint yet"
  - "why are Perl recognition transactions unavailable"
  - "which recognition transaction forms are unresolved in Perl"
  - "does recognition_rollback lower to ActionIR in Perl"
  - "is the Perl recognition transaction consumer in canonical CI"
  - "how many tests pass before the Perl transaction RED boundary"
  - "what neutral transaction fixtures does the Perl RED consumer freeze"
  - "does the Perl transaction RED change production behavior"
date: 2026-08-10
status: historical dormant RED boundary at .14.3.2.0; superseded by internal integration .14.3.2.2
tags: [perl, recognition, transaction, ActionIR, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.2.0 adds t/recognition_transaction_perl_contract.t at its final path without ordinary or canonical registration. The exact four-form specimen reaches return_descriptor successfully. Top action metadata remains language_agnostic_action_ir_ready=0 because recognition_checkpoint, recognize_once, and recognition_commit become unsupported-helper sentinels while recognition_rollback remains one RAW_PERL dependency; all four dedicated RECOGNITION_* node kinds are absent. The consumer loads every neutral family (8 positive tokens, 17 violations, 6 effect graphs, 6 mark cases, 8 progress cases, 9 allowed/11 rejected effects, and 15 diagnostics), passes 49 assertions, fails one exact dedicated-ActionIR assertion, then skips one complete future live/generated-source subtest. Production grammar/compiler/runtime/generated source, the neutral artifact/checker, canonical discovery, public claims, and compatibility controls remain unchanged."
evidence_update_2026_08_10_signoff: "With the consumer staged and tracked, definitive canonical CI still passes all eight doctrines, repository-contained six-family process I/O, moved-root Rust plus four outside-CWD runtime anchors, both primary CLI option environments at 66/66, RAM 69%, and Phase 0 1,031/1,031 in 672 seconds. The consumer has zero ordinary/canonical registry references and retains its deterministic 49-pass / one-fail / one-skip dormant RED boundary."
evidence_update_2026_08_10_supersession: "FUTURE-PARITY-BACKLOG.14.3.2.2 makes the same final-path consumer GREEN after adding all four nodes and live/generated integration. The test stays unregistered, so this card remains the canonical historical explanation of the pre-implementation boundary rather than current status."
evidence_update_2026_08_10_admission: "FUTURE-PARITY-BACKLOG.14.3.2.3 subsequently registers the now-GREEN consumer exactly once. Historical RED reconstruction therefore uses the frozen commit, while current reverify requires the canonical registration rather than asserting its absence."
reverify: "git show 59306f372e742a9e815c9b409d4502a8533b0fbd:t/recognition_transaction_perl_contract.t | rg -n 'expected RED: missing nodes|future Perl recognition-transaction ActionIR is unavailable' && prove -Iperl t/recognition_transaction_perl_contract.t && test \"$(rg -c 'require_tracked_file t/recognition_transaction_perl_contract[.]t|perl -c -Iperl t/recognition_transaction_perl_contract[.]t|PERL5LIB= prove -Iperl t/recognition_transaction_perl_contract[.]t' tools/run_ci_local.sh)\" = 3"
---

# Perl recognition-transaction dormant RED

The final-path consumer is `t/recognition_transaction_perl_contract.t`. At the
dormant boundary it was tracked but deliberately absent from canonical commands;
admission `.14.3.2.3` later registered and executed the now-GREEN consumer.

This is not a grammar-parse failure. The exact accepted-future specimen
constructs a descriptor and records its nested static call(Child). Current
Perl lowering then exposes the precise implementation boundary:

- recognition_checkpoint, recognize_once, and recognition_commit lower
  through three LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER sentinels;
- statement-only recognition_rollback remains one RAW_PERL dependency;
- none of RECOGNITION_CHECKPOINT, RECOGNIZE_ONCE,
  RECOGNITION_COMMIT, or RECOGNITION_ROLLBACK is present; and
- the top rule therefore remains language-agnostic ActionIR blocked.

Everything before that boundary is GREEN. The test derives the complete token,
effect-closure, mark-generation, cursor-progress, and structured-diagnostic
inventory directly from
capability_conformance/recognition_transaction_contract.json. Its sole
failing assertion requires the four dedicated nodes with zero unresolved or
raw dependencies. A following skipped subtest freezes live falsey/miss,
commit/rollback, unchanged compatibility-stack, and independently emitted
source behavior for the integration leaf.

This was the exact dormant boundary before implementation. Private
invocation/token authority landed in `.14.3.2.1`; authored/compiler/runtime/
generated-source integration passes under `.14.3.2.2`; explicit ordinary/
canonical execution and Perl rollout promotion were completed by `.14.3.2.3`.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Authored/static policy: [[cursor-transaction-authored-contract]].
- Safety seam audit: [[cursor-transaction-safety-audit-plan]].
- Generated-source carrier: [[perl-generated-source-contract-v2]].
- Current internal integration: [[perl-recognition-transaction-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] .14.3.2.0.
