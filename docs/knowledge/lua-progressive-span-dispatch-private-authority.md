---
id: lua-progressive-span-dispatch-private-authority
title: Lua progressive span dispatch has one private shared dual-ABI authority
answers:
  - "where is the private Lua progressive span dispatch authority"
  - "how does Lua progressive dispatch rebase child source positions"
  - "how does Lua progressive dispatch share cancellation and budgets"
  - "how does Lua progressive dispatch prevent non-decreasing cycles"
  - "how do Lua progressive callback views expire"
  - "how are Lua progressive child results detached"
  - "is Lua progressive authority exported from linkedspec"
  - "how do I run the Lua progressive authority proof on PUC Lua and LuaJIT"
  - "does the private Lua progressive authority enable dispatch_span carriers"
date: 2026-08-25
status: private authority current and carriers admitted on both ABIs; authority proof remains dormant
tags: [lua, PUC-Lua, LuaJIT, progressive-parsing, authority, source-location, cancellation, detachment, private]
evidence: "FUTURE-PARITY-BACKLOG.14.6.6.1 adds lua/src/linkedspec/bounded_child_parse_authority.lua as one Lua-5.1-compatible direct module absent from linkedspec/init.lua, ActionIR, interpreter/generated carriers, ordinary discovery, and canonical CI. Module-private weak-key state backs opaque ceilings, already-compiled registry entries, registries, active-chain frames, fresh invocations, identity-bearing cancellation tokens, effective authority, callback-scoped source views/requests, and typed errors. Each invocation copies decoded sources into the existing private source_location authority. Local child Unicode-scalar positions/spans/diagnostics rebase globally; capability/policy intersections and ceiling minima narrow; cancellation/deadline/remaining steps plus chain/depth/calls are shared; retained views/requests expire; results are deeply copied, finite, JSON-shaped, cycle/live-field-free, and node-bounded. The same dormant consumer passes 273/273 on PUC Lua and LuaJIT across every neutral row/all 26 diagnostic contexts plus nested, expiry, isolation, bound, and UTF-8 adversaries. The final path remains 85-pass/one-RED and rollout remains 5/9/106."
evidence_update_2026_08_25_carriers: "FUTURE-PARITY-BACKLOG.14.6.6.2 retains the same authority semantics while adding opaque ProgressiveExecutionSeed/State recipes and interpreter/generated delegation. The final path is now GREEN at 178/178 per ABI across four dormant routes; the separate authority remains 273/273. The module remains absent from linkedspec/init.lua and every serialized/generated artifact."
evidence_update_2026_08_25_admission: "FUTURE-PARITY-BACKLOG.14.6.6.3 admits only the shared carrier consumer once per ABI in ordinary and canonical discovery. The authority matrix stays outside both at 273/273 per host, the module stays unexported, and generated artifacts still contain no live authority."
reverify: "bash tools/run_lua_project_data.sh puc lua/test_dormant/progressive_span_dispatch_authority_test.lua; bash tools/run_lua_project_data.sh luajit lua/test_dormant/progressive_span_dispatch_authority_test.lua; bash tools/run_lua_project_data.sh puc lua/test/progressive_span_dispatch_contract_test.lua; bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py; test \"$(rg -c 'progressive_span_dispatch_authority_test[.]lua' tools/run_lua_local.sh tools/run_ci_local.sh)\" = 0"
---

# Private shared Lua bounded-child authority

The direct module `lua/src/linkedspec/bounded_child_parse_authority.lua` is the
single authority implementation used unchanged by PUC Lua and LuaJIT. It is
Lua-5.1-compatible, unexported, and ActionIR-independent. Execution carriers
receive only its opaque live seed; no authority is serialized or emitted.

Trusted host code may construct immutable logical entries only from
already-compiled callbacks. A fresh invocation copies decoded sources into the
existing private typed-source authority. Each callback receives an opaque
bounded view whose local scalar coordinates rebase to the original source;
effective capabilities, policies, detail, and numeric ceilings can only narrow.
Cancellation identity, absolute deadline, remaining steps, active decreasing
global-span chain, depth, and call count are shared across nested dispatch.

Callback views and retained nested requests expire after return or failure.
Only deeply copied finite JSON-shaped results within the effective node ceiling
can cross back; cycles, live-looking fields, nonfinite values, and other handles
fail with typed diagnostics. The dormant consumer covers the full neutral
matrix, all 26 diagnostic schemas, rebasing, nested shared limits, expiry,
detachment, and UTF-8 diagnostic truncation on both hosts.

Carrier leaf `FUTURE-PARITY-BACKLOG.14.6.6.2` starts fresh execution state from
this core for every native and generated top-level run. Admission `.14.6.6.3`
routes only the carrier consumer; the exhaustive authority proof remains
dormant, and the module remains private and unexported.

Related facts: [[lua-progressive-span-dispatch-carriers]],
[[lua-progressive-span-dispatch-admission]],
[[lua-progressive-span-dispatch-dormant-red]],
[[lua-typed-source-location-dormant-red]],
[[lua-recognition-transaction-private-authority]], and
[[progressive-span-dispatch-audit-plan]].
