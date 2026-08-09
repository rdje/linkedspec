---
id: cursor-transaction-authored-contract
title: Bounded cursor transactions use a linear recognition token, falsey-safe match/result channels, and closed effects
answers:
  - "what is the accepted LinkedSpec cursor transaction syntax"
  - "how do I write a future bounded recognition transaction"
  - "what does recognition_checkpoint do"
  - "what does recognize_once return"
  - "how is a falsey child result distinguished from no match"
  - "what does recognition_commit return"
  - "what does recognition_rollback restore"
  - "can a recognition transaction token be copied or returned"
  - "what ActionIR effects are allowed before transaction commit"
  - "which ActionIR effects fail closed in recognition"
  - "are user functions allowed inside recognition transactions"
  - "how are named marks isolated across recursive invocations"
  - "what is the cursor-only v1 progress rule"
  - "does a rolled back attempt satisfy parser progress"
  - "are recognition transactions executable yet"
date: 2026-08-09
status: accepted future authored/static contract; executable neutral artifact and runtime support pending
tags: [cursor, transactions, recognition, actionir, effects, progress, marks, recursion, diagnostics]
evidence: "FUTURE-PARITY-BACKLOG.14.3.1.0 amends ADR 0056 after the .14.3.0 six-runtime safety audit. It selects four dedicated recognition_* forms, separate match and staged-payload channels, one linear token state machine, a closed 9-allowed/11-rejected base-effect taxonomy, invocation-frame mark migration, and cursor-only progress without changing executable behavior."
reverify: "rg -n 'recognition_checkpoint|recognize_once|recognition_commit|recognition_rollback|pure_value|cursor-only' docs/decisions/0056-typed-source-location-and-cursor-algebra.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md"
---

The accepted future authored shape is:

```text
tx = recognition_checkpoint();
if (recognize_once(tx, call(Child))) {
    child = recognition_commit(tx);
} else {
    recognition_rollback(tx);
}
```

`recognition_checkpoint()` creates one opaque transaction token bound directly to a bare local token slot.
`recognize_once(token, call(Rule))` is a special form, not eager ordinary argument evaluation: the exact named
`call(Rule)` remains visible and runs once inside the snapshot. It returns a strict match boolean only. The child
payload is staged independently, so a successful `false`, `0`, empty string, or `undef` is not confused with no
match. `recognition_commit(token)` invalidates first, retains cursor/boundary/mark state, and yields the staged
payload. `recognition_rollback(token)` restores the owning invocation's cursor, anonymous boundary, and named-mark
snapshot, discards the payload, invalidates the token, and returns no authored value.

The token is linear transaction authority, not a normal language value. It cannot be copied, compared, stored in
an aggregate, passed to a user function or codeblock, returned, captured, serialized, retried, or used by another
rule invocation/source. V1 permits one active transaction per invocation and no nested descendant transaction.
Every path performs exactly one attempt and one terminal operation before ordinary effects. Static rejection is
primary; the runtime restores and invalidates before reporting a dynamic escape/effect violation.

The closed allowed effect atoms are `pure_value`, `source_read`, `structured_control`, `rule_recognition`,
`transaction_state`, matcher-owned `cursor_advance`, `capture_boundary_write`, `invocation_mark_write`, and
`staged_return`. The rejected atoms are `binding_write`, `aggregate_write`, `ast_or_object_write`,
`compatibility_cursor_control`, `output`, `authored_diagnostic`, `exit_or_unbounded_control`, `dynamic_callable`,
`parser_registry_or_staged_dispatch`, `external_or_host`, and `unknown_or_raw`. Rule-call effects are computed to a
call-graph fixed point; unknown nodes fail closed; a runtime barrier enforces the same boundary. Current
`save_cursor`/`restore_cursor`, rewinds, user/callable functions, codeblocks, raw Perl, output, diagnostics, exit,
and registry/staged work are therefore not recognition-safe v1 operations.

Every entered rule will own a fresh invocation-frame mark table. Recursive same-label frames no longer alias one
rule-label bucket; child exit cannot replace its parent's marks. Transaction rollback restores only the owning
frame snapshot, and frame exit invalidates its mark generation.

V1 progress accepts only cursor advance: successful repetition iterations and accepted direct/mutual recursive
cycle edges require `end_offset > start_offset`. One-shot zero-width recognition remains legal outside those
obligations. Rolled-back attempts do not count. Mark, variable, AST, or transaction-state changes cannot substitute
for cursor movement, and v1 exposes no authored decreasing-measure escape hatch.

These spellings and rules are accepted architecture, not current executable syntax. Neutral artifact/checker work
is owned by `.14.3.1.1`; backend behavior follows independently on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.
