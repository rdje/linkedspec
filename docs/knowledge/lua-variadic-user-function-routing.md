---
id: lua-variadic-user-function-routing
title: Lua variadic user functions begin at dependency-complete staged runtime execution
answers:
  - "what Lua task owns variadic user functions"
  - "when will Lua support final rest parameters"
  - "why is Lua variadic support not owned by its completed function registry"
  - "what Lua task preserves callable signatures in generated source"
  - "what Lua task admits variadic function descriptors"
date: 2026-07-12
status: current
tags: [lua, functions, variadic, staged-parsing, descriptor, generated-source, routing, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.4.4 audits the completed Lua shell/registry/frame/compiled-state seams and pending runtime/generated lanes. LUA-BACKEND-PARITY.5.1 now owns native fixed-v1/variadic-v2 execution, .5.3 descriptor admission, and .8.1-.4 generated preservation/execution/proof/capability retirement."
evidence_update_2026_07_15_split: "LUA-BACKEND-PARITY.5.1.0 assigns variadic typed shell/staged/registry/compiled state to .5.1.3.1 and native fresh-rest-array execution to .5.1.3.2 after staged dispatch and fixed-v1 runtime."
evidence_update_2026_07_15_staged_registry: "LUA-BACKEND-PARITY.5.1.1 completes minimal body dispatch at 130/130 and activates fixed-v1 runtime .5.1.2; variadic state/runtime remain dependency-correct .5.1.3.1/.2."
evidence_update_2026_07_15_fixed_runtime: "LUA-BACKEND-PARITY.5.1.2 completes fixed-v1 registered execution at 133/133 and activates variadic-v2 typed-state preservation .5.1.3.1; runtime rest-array execution remains .5.1.3.2."
evidence_update_2026_07_15_signature_state: "LUA-BACKEND-PARITY.5.1.3.1 preserves exact v1/v2 shell, AST, staged, registry, contract, and compiled signature state with minimum/unbounded resolution at 136/136; fresh rest-array execution .5.1.3.2 is active while descriptors and generated source remain .5.3/.8."
evidence_update_2026_07_15_native_runtime: "LUA-BACKEND-PARITY.5.1.3.2 executes fresh copied typed rest arrays and the unchanged neutral fixture at 139/139; contextual final-codeblock metadata .5.1.4.1 is active while descriptors and generated source remain .5.3/.8."
evidence_update_2026_07_15_closeout: "LUA-BACKEND-PARITY.5.1.5 closes fixed-v1/variadic-v2/contextual runtime no-drift at 146/146; native loading .5.2 is active, descriptors .5.3 and generated source .8 remain later."
reverify: "rg -n 'LUA-BACKEND-PARITY\\.5\\.1|LUA-BACKEND-PARITY\\.5\\.3|LUA-BACKEND-PARITY\\.8\\.[1-4]|callable-signature|variadic' docs/tasks/LUA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md capability_conformance/manifest.json"
---

Lua already projects spec-owned top-level function nodes (`LUA-BACKEND-PARITY.2.4`) and owns an ordered exact-
arity registry plus isolated invocation-frame copier (`.3.3`). Compiled descriptors carry those records (`.3.4`).
Those completed leaves deliberately do not dispatch staged function bodies or execute user-function calls, and
the invocation frame receives already evaluated values. Retrofitting variadic runtime behavior into them would
cross the pending helper/value/control dependencies and falsely claim executable support.

`LUA-BACKEND-PARITY.5.1` is the first dependency-complete native parent. Planning `.5.1.0` now assigns the exact
fixed-v1/variadic-v2 shell/staged/registry/compiled-state union to `.5.1.3.1` and ordered fresh-rest-array execution,
invalid calls, receiver continuation, and the unchanged neutral fixture to `.5.1.3.2`. This is LinkedSpec typed-
array binding, not Lua `...` dispatch.

The remaining projections have explicit later owners: `.5.3` admits exact outward descriptors; `.8.1` preserves
the union in normalized emitted state; `.8.2` independently executes the neutral fixture; `.8.3` makes the proof
recurring; and `.8.4` removes the future capability entry only after native and generated paths pass. Fixed-v1
registered-call runtime `.5.1.2`, staged action-body dispatch `.5.1.1`, and exact variadic-v2 state/runtime
`.5.1.3.1/.2` are done, contextual final blocks close through `.5.1.4.1/.2`, and `.5.1.5` closes the parent. The
current Lua frontier is portable native loading `.5.2`.

Related facts: [[lua-user-function-registry]], [[lua-function-definition-shell-projection]],
[[variadic-user-function-contract]], [[variadic-callable-signature-seams]],
[[lua-staged-function-execution-split]], [[lua-fixed-v1-user-function-runtime]].
[[lua-variadic-v2-signature-state]], [[lua-variadic-v2-runtime]].
