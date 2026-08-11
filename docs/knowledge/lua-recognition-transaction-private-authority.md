---
id: lua-recognition-transaction-private-authority
title: Lua recognition transactions share one private Lua-5.1 authority across PUC Lua and LuaJIT
answers:
  - "where is the private Lua recognition transaction authority"
  - "how do Lua recognition transaction tokens stay opaque"
  - "how does Lua isolate transaction marks by invocation"
  - "how does Lua preserve false recognition payloads"
  - "what does Lua transaction rollback restore"
  - "how does Lua reject reused or escaped recognition tokens"
  - "does PUC Lua use the same transaction authority as LuaJIT"
  - "is the Lua transaction authority exported"
  - "is the Lua transaction consumer in ordinary discovery"
  - "what is the next Lua transaction integration failure"
  - "how many Lua transaction authority mutations are rejected"
date: 2026-08-11
status: private authority retained under current dual-ABI admission
tags: [lua, PUC-Lua, LuaJIT, recognition, transaction, invocation, marks, token, snapshot, private]
evidence: "FUTURE-PARITY-BACKLOG.14.3.6.1 adds lua/src/linkedspec/recognition_transaction.lua as a Lua-5.1-compatible direct module absent from lua/src/linkedspec/init.lua. One module-local weak-key store backs opaque source authority, invocation, frame-state, snapshot, linear-token, and exception handles. Monotonic authority/invocation/mark/transaction ids, detached JSON projections, restore-before-invalidate lifecycle, and separate match/payload storage preserve false, zero, empty string, and json.null. The same final-path authority mode passes 187 assertions on PUC Lua and 187 on LuaJIT. Integration exits 1 only at missing dedicated ActionIR nodes; ordinary/canonical discovery and rollout 5/9 remain unchanged. The independent checker rejects 22 private-authority mutations separately from 12 dormant-RED and 44 neutral semantic mutations."
evidence_update_2026_08_11_signoff: "The complete Lua gate remains 177/177 per ABI, CLI 66x2, corpus 105, and storage 18/3. Sole-facing book 79/14,412 KiB, Knowledge Map 816/6,772, all eight doctrines, repository containment/relocation, CLI 66x2, RAM 82%, and canonical Phase 0 1,031/1,031 in 753 seconds pass through the exact local-CI success marker. Atomic 202 is commit-ready from clean activation 6a8ec091."
evidence_update_2026_08_11_integration: "FUTURE-PARITY-BACKLOG.14.3.6.2 adds policy/state accessors to this authority and binds it through a separate private Lua-5.1 runtime adapter. Authority remains 187/187 per ABI; integration passes 243/243 per ABI across all four carriers, while facade/discovery and rollout remain unchanged."
evidence_update_2026_08_11_admission: "FUTURE-PARITY-BACKLOG.14.3.6.3 retains this unexported authority unchanged while registering the full 243-assertion consumer once per ABI in ordinary and canonical proof. Rollout is now 7/9; 22 admission mutations guard registration/privacy beside 22 authority mutations."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
---

# Private shared Lua recognition-transaction authority

`lua/src/linkedspec/recognition_transaction.lua` is the private state
foundation for current Lua transaction execution. The public facade does not
export it, while the final-path consumer now runs ordinarily and canonically.
PUC Lua and LuaJIT execute the same Lua-5.1-compatible source unchanged.

One weak-key module store owns opaque handles for the source authority,
invocation frame, copied frame state, detached snapshot, linear transaction
token, and structured exception. Monotonic ids bind each token to one source,
invocation, and mark generation; cross-owner, cross-invocation, wrong-generation,
nested, retried, escaped, and reused operations fail deterministically.

Checkpoint copies cursor, nullable anonymous boundary, and invocation-local
named marks. Commit retains the staged state. Rollback, discard, invalid use,
and invocation unwind restore the copy before invalidating the token. Attempt
presence and payload are stored separately, so `false`, zero, empty string, and
`json.null` survive successful commit without becoming misses.

Authority mode passes 187 assertions on each ABI. The module now also owns the
neutral effect/progress policy and state accessors consumed by private adapter
`recognition_transaction_runtime.lua`; the parser/interpreter own the dedicated
nodes and carrier execution. Lua transaction syntax is current on both ABIs;
recurring composition and final public no-drift remain later owners.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Dormant final-path boundary: [[lua-recognition-transaction-dormant-red]].
- Integration: [[lua-recognition-transaction-integration]].
- Admission: [[lua-recognition-transaction-admission]].
- Source authority precedent: [[lua-typed-source-location-dormant-red]].
- Runtime seams: [[lua-runtime-rule-interpreter]] and [[lua-runtime-matching-state]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.6.1`.
