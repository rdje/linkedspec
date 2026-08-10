---
id: perl-recognition-transaction-private-authority
title: Perl has an opaque private recognition-transaction authority that no authored route can reach
answers:
  - "where is the private Perl recognition transaction authority"
  - "how are Perl recognition transaction tokens stored"
  - "how does Perl isolate same-label recursive transaction marks"
  - "how does the private Perl transaction authority preserve falsey payloads"
  - "what state does private Perl transaction rollback restore"
  - "how does Perl invalidate escaped or reused recognition tokens"
  - "which test proves the private Perl recognition transaction authority"
  - "is the private Perl transaction authority in canonical CI"
  - "does the private Perl transaction authority make recognition syntax available"
  - "is the dormant Perl transaction RED unchanged after private authority"
date: 2026-08-10
status: private foundation retained; internal integration landed under .14.3.2.2 while admission/public routes remain RED
tags: [perl, recognition, transaction, invocation, marks, token, snapshot, private, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.2.1 adds perl/LinkedSpec/RecognitionTransaction.pm as an inside-out authority with opaque scalar authority/frame/token handles. One source authority owns monotonic non-reused invocation ids, mark generations, transaction ids, fresh same-label recursive mark tables, cursor/boundary/mark snapshots, separately staged match/payload state, one-attempt/one-terminal enforcement, restore-before-report misuse handling, and terminal invalidation. t/recognition_transaction_perl_authority.t derives diagnostics and fixtures from the neutral JSON and passes 293 nested TAP assertions over opacity, eight positive cases, eight escape classes, recursion, stale generations, attempt/terminal/nesting/boolean misuse, cross-invocation/source restoration, and compatibility isolation. Canonical CI tracks, syntax-checks, and runs only this private unit test; definitive signoff passes both CLI environments at 66/66 and Phase 0 at 1,031/1,031 in 688 seconds. LinkedSpec.pm, Compiler, SpecEntry, RuntimeContext, ActionIR, GeneratedSource, the final-path dormant consumer, and rollout remain unchanged/RED."
evidence_update_2026_08_10_integration: "FUTURE-PARITY-BACKLOG.14.3.2.2 now routes authored Perl execution through this unchanged private authority via RecognitionTransactionRuntime. The foundation's ownership, lifecycle, and 293-assertion direct proof remain canonical; the separate final-path integration consumer is GREEN but unadmitted."
reverify: "perl -Iperl -c perl/LinkedSpec/RecognitionTransaction.pm && prove -Iperl t/recognition_transaction_perl_authority.t && prove -Iperl t/recognition_transaction_perl_contract.t && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && ! rg -q 'recognition_transaction_perl_contract[.]t' tools/run_ci_local.sh"
---

# Private Perl recognition-transaction authority

`perl/LinkedSpec/RecognitionTransaction.pm` is the private state foundation for
the later Perl integration leaf. It follows the same inside-out shape as typed
source-location values: callers receive scalar handles while mutable authority,
frame, and token records remain module-owned.

Each rule entry receives a monotonic invocation id and mark generation plus a
fresh mark table, so recursive entries with the same label cannot alias. A
checkpoint token binds the exact source authority, invocation, generation, rule,
origin, and transaction id. Its snapshot owns only cursor, anonymous boundary,
and invocation marks. Match presence and staged payload use separate fields, so
false, zero, empty, undef, and miss remain distinguishable through commit.

Rollback, escape, cross-authority misuse, repeated attempts, missing terminals,
and frame/token destruction restore before invalidation. Commit invalidates
before returning the staged payload. Typed errors expose exactly the neutral
portable scalar fields; detached frame snapshots cannot mutate owner state.

The module remains absent from the public facade. `.14.3.2.2` now reaches it
through internal compiler/runtime integration, while `tools/run_ci_local.sh`
continues to track and run its direct private unit test but not the final-path
integration consumer. Perl rollout admission and public support remain owned by
`.14.3.2.3` and later cross-runtime leaves.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Authored/static policy: [[cursor-transaction-authored-contract]].
- Dormant end-to-end RED: [[perl-recognition-transaction-dormant-red]].
- Internal integration: [[perl-recognition-transaction-integration]].
- Typed source owner pattern: [[typed-source-location-runtime-rollout-plan]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.2.1`.
