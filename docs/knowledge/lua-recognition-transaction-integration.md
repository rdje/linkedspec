---
id: lua-recognition-transaction-integration
title: Lua recognition transactions are privately integrated across both ABIs and all four carriers
answers:
  - "where are Lua recognition transactions integrated"
  - "which Lua ActionIR nodes represent recognition transactions"
  - "how does Lua preserve a false recognition payload"
  - "how does Lua bind transactions to cursor boundary and marks"
  - "which Lua recognition transaction carriers pass"
  - "does emitted Lua source execute recognition transactions"
  - "why is the Lua transaction adapter a separate module"
  - "are Lua recognition transactions admitted or public"
  - "how many Lua transaction integration mutations are rejected"
date: 2026-08-11
status: private integration retained under current dual-ABI admission
tags: [lua, PUC-Lua, LuaJIT, recognition, transaction, ActionIR, effects, progress, generated-source, private]
evidence: "FUTURE-PARITY-BACKLOG.14.3.6.2 lowers recognition_checkpoint, recognize_once, recognition_commit, and recognition_rollback to exact dedicated nodes after static argument parsing. The authority implements the neutral six-graph recursive effect fixed point and eight-case cursor-progress policy. Private recognition_transaction_runtime.lua shares the typed-source authority, enters one frame per rule invocation, and synchronizes real UTF-8-byte cursor, nullable anonymous boundary, and isolated same-label marks. The unchanged dormant consumer passes 243 assertions on PUC Lua and 243 on LuaJIT across native, reconstructed, generated-plan, and independently loaded emitted source while preserving false. Authority remains 187/187; ordinary/canonical discovery, facade, neutral 132/246/44, and rollout 5/9 remain unchanged. The checker rejects 19 integration mutations separately from 22 authority and 12 dormancy mutations. Signoff passes the 79-file/14,412-KiB book, Knowledge Map 817/6,781, all eight doctrines, containment/relocation, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 736 seconds through exact canonical success."
evidence_update_2026_08_11_admission: "Admission removes selector dormancy without changing any integration module. The same consumer passes 243/243 per ABI under ordinary and canonical registration; rollout advances to 7/9 and 22 admission mutations join the retained 22 authority and 19 integration mutations."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
---

# Private shared Lua recognition-transaction integration

The action parser replaces only the four exact static forms with dedicated
nodes. `recognize_once` stores an opaque token-slot name and a static child-rule
label, so its `call(Rule)` operand never enters generic helper evaluation or the
ordinary 246-name callable inventory.

The private authority evaluates the neutral effect graphs to a recursive fixed
point over nine allowed and eleven rejected effects. Progress is independent:
accepted repetition and recursive-cycle edges must advance the UTF-8-byte
cursor; one-shot zero-width recognition remains valid, and changes to bindings,
marks, boundaries, or transaction state do not count.

`recognition_transaction_runtime.lua` is the single adapter for both ABIs. Its
separate module keeps `interpreter.lua` below Lua 5.1's 200-local main-chunk
limit. Every rule invocation gets one authority frame and a fresh same-label
mark bucket. Checkpoint, attempt, commit, rollback, and unwind synchronize the
live cursor, anonymous capture boundary, and marks. Match presence is stored
separately from payload, so a successful `false` survives commit.

Native and reconstructed specs compile the same action source. Generated plans
use the effective interpreter, and emitted modules reconstruct and compile the
same effective spec in memory before invoking that plan. No carrier-specific
transaction implementation or filesystem workspace exists.

The admitted full consumer passes 243 assertions on each ABI. Neither private
module is exported; ordinary discovery and canonical CI each execute the exact
source once per ABI.

## Links

- Neutral contract: [[recognition-transaction-neutral-contract]].
- Dormant boundary: [[lua-recognition-transaction-dormant-red]].
- Private authority: [[lua-recognition-transaction-private-authority]].
- Admission: [[lua-recognition-transaction-admission]].
- Runtime seams: [[lua-runtime-rule-interpreter]] and [[lua-runtime-matching-state]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.6.2`.
