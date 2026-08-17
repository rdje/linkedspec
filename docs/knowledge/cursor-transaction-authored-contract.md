---
id: cursor-transaction-authored-contract
title: Bounded cursor transactions use a linear recognition token, falsey-safe match/result channels, and closed effects
answers:
  - "what is the accepted LinkedSpec cursor transaction syntax"
  - "how do I write a current bounded recognition transaction"
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
date: 2026-08-10
status: current on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; recurring and public no-drift complete
tags: [cursor, transactions, recognition, actionir, effects, progress, marks, recursion, diagnostics]
evidence: "FUTURE-PARITY-BACKLOG.14.3.1.0 amends ADR 0056 after the .14.3.0 six-runtime safety audit. It selects four dedicated recognition_* forms, separate match and staged-payload channels, one linear token state machine, a closed 9-allowed/11-rejected base-effect taxonomy, invocation-frame mark migration, and cursor-only progress. .14.3.1.1 then makes that target independently executable at 128 current + 4 future node rows, 246 call rows, and 40 mutations without backend behavior."
evidence_update_2026_08_10_perl_admission: "FUTURE-PARITY-BACKLOG.14.3.2.3 requires, syntax-checks, and canonically executes the exact 51-test Perl consumer, promotes only Perl, and advances governance to 2/9 rollout, 41 semantic mutations, and 3/8/14 public sequence. The same authored form is current on Perl and remains future on Rust, Dart, Julia, PUC Lua, and LuaJIT."
evidence_update_2026_08_10_rust_admission: "FUTURE-PARITY-BACKLOG.14.3.3.3 removes both Rust custom cfgs, executes the unchanged exact 12-test consumer ordinarily and canonically, and promotes only Rust. The same forms are now current on Perl and Rust; Dart, Julia, PUC Lua, LuaJIT, recurring composition, and public no-drift remain future. Governance is 3/9 rollout, 42 semantic mutations, public 3/11/25, guide 1/4/8, and Rust admission 8 mutations."
evidence_update_2026_08_17_composition: "FUTURE-PARITY-BACKLOG.14.6.0.1 binds the already complete recognition authority (9/9 rollout, 58 mutations, five sources/six runtime routes, 9 allowed and 11 rejected effects, eight progress cases, public 3/26/45, and guide 1/14/18) into the typed transaction_safety row without runtime or public movement."
reverify: "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && rg -n 'recognition_checkpoint|recognize_once|recognition_commit|recognition_rollback|pure_value|cursor-only' docs/decisions/0056-typed-source-location-and-cursor-algebra.md docs/tasks/FUTURE-PARITY-BACKLOG.14.md docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md"
---

The current portable authored shape is:

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

Every entered transaction rule on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT owns a fresh invocation-frame mark table. Recursive same-label frames do
not alias one rule-label bucket; child exit cannot replace its parent's marks. Transaction rollback restores only
the owning frame snapshot, and frame exit invalidates its mark generation.

V1 progress accepts only cursor advance: successful repetition iterations and accepted direct/mutual recursive
cycle edges require `end_offset > start_offset`. One-shot zero-width recognition remains legal outside those
obligations. Rolled-back attempts do not count. Mark, variable, AST, or transaction-state changes cannot substitute
for cursor movement, and v1 exposes no authored decreasing-measure escape hatch.

Recognition transactions are current on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; the exact recurring and public no-drift rollout is 9/9 complete.
The neutral artifact/checker remains the shared authority under `.14.3.1.1`; each backend admission remains
independently proven, and the repository-routed recurring driver composes the five source groups over six routes.
