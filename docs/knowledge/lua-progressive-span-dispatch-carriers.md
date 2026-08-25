---
id: lua-progressive-span-dispatch-carriers
title: Lua privately carries progressive span dispatch through four dormant dual-ABI routes
answers:
  - "does Lua progressive span dispatch use a dedicated node"
  - "how does Lua compile dispatch_span"
  - "which Lua routes execute progressive span dispatch"
  - "how does Lua seed progressive dispatch authority"
  - "does generated Lua source serialize progressive callbacks"
  - "does Lua reject progressive dispatch in recognition transactions"
  - "why does Lua discard live recognition tokens during progressive error unwind"
  - "is the Lua progressive dispatch consumer admitted in CI"
  - "how do I run the dormant Lua progressive carriers on both ABIs"
date: 2026-08-25
status: private dormant carriers current on PUC Lua and LuaJIT; dual-ABI admission next
tags: [lua, PUC-Lua, LuaJIT, progressive-parsing, actionir, generated-source, recognition-transaction, private]
evidence: "FUTURE-PARITY-BACKLOG.14.6.6.2 replaces only the exact literal-id/literal-top/bare-span assignment with one progressive_dispatch_span node carrying target/parser_id/top_rule/span. Malformed assignments and residual generic calls reject; compile-time rule/function closure forbids recognize_once targets that can reach parser_registry_or_staged_dispatch. A live-token defense discards the unfinished private token during unwind so progressive_transaction_forbidden remains primary while authority state restores. ProgressiveExecutionSeed owns a copied decoded-source recipe and starts fresh invocation budget/call state for every execution while retaining shared cancellation/deadline/steps. Native, normalized SpecFile-JSON reconstructed, generated-plan, and independently loaded emitted-module routes return the same detached payload without advancing the parent cursor. Serialized/emitted data contain no callback, registry entry, fingerprint, decoded input snapshot, cancellation token, or mutable execution state. The same dormant Lua-5.1 consumer passes 178/178 on PUC Lua and LuaJIT; the separate authority stays 273/273. Neutral governance records 9 dormant Lua carrier paths, zero backend guards, rollout 5/9, and 106 mutations. Ordinary/canonical discovery, rollout rows, generated-v2 format, typed recurrence, package facade, and outward surfaces do not move."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test_dormant/progressive_span_dispatch_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test_dormant/progressive_span_dispatch_contract_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test_dormant/progressive_span_dispatch_authority_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test_dormant/progressive_span_dispatch_authority_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "test ! -e lua/test/progressive_span_dispatch_contract_test.lua && ! rg -q 'lua/test_dormant/progressive_span_dispatch_contract_test[.]lua' tools/run_lua_local.sh tools/run_ci_local.sh"
---

# Private dormant Lua progressive carriers

The exact assignment is one whole-statement logical node:

```text
value = dispatch_span("expr-v1", "Expr", span)
```

The node stores only its target, two normalized static identities, and the bare
span-binding name. The host supplies an opaque unexported execution seed. Each
top-level native or generated parse starts fresh budget and call accounting;
nested dispatch retains the seed's narrowing capabilities, source view,
cancellation identity, deadline, and remaining-step authority.

Static effect closure rejects recognition of any rule that reaches the node
through rule or user-function calls. Runtime live-token defense handles a
defensively reconstructed path and preserves the progressive denial while the
recognition authority restores and invalidates the unfinished token.

Native, normalized-JSON reconstructed, generated-plan, and independently
loaded emitted-module routes all delegate to the same private carrier. The
generated adapter accepts a live seed only as an execution option and never
serializes it. Both ABIs run the same Lua-5.1-compatible consumer, which remains
dormant until `.14.6.6.3` owns ordinary and canonical dual-ABI admission.

Related facts: [[lua-progressive-span-dispatch-private-authority]],
[[lua-progressive-span-dispatch-dormant-red]],
[[lua-recognition-transaction-integration]], and
[[progressive-span-dispatch-audit-plan]].
