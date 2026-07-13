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
reverify: "rg -n 'LUA-BACKEND-PARITY\\.5\\.1|LUA-BACKEND-PARITY\\.5\\.3|LUA-BACKEND-PARITY\\.8\\.[1-4]|callable-signature|variadic' docs/tasks/LUA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md capability_conformance/manifest.json"
---

Lua already projects spec-owned top-level function nodes (`LUA-BACKEND-PARITY.2.4`) and owns an ordered exact-
arity registry plus isolated invocation-frame copier (`.3.3`). Compiled descriptors carry those records (`.3.4`).
Those completed leaves deliberately do not dispatch staged function bodies or execute user-function calls, and
the invocation frame receives already evaluated values. Retrofitting variadic runtime behavior into them would
cross the pending helper/value/control dependencies and falsely claim executable support.

`LUA-BACKEND-PARITY.5.1` is the first dependency-complete native owner. It must consume the exact fixed-v1 /
variadic-v2 union through shell projection, staged jobs, registry-first ActionIR resolution, ordered evaluation,
fresh rest-array frames, invalid signatures, keyword rejection, diagnostics, receiver continuation, and the
unchanged neutral fixture on PUC Lua and LuaJIT. This is LinkedSpec typed-array binding, not Lua `...` dispatch.

The remaining projections have explicit later owners: `.5.3` admits exact outward descriptors; `.8.1` preserves
the union in normalized emitted state; `.8.2` independently executes the neutral fixture; `.8.3` makes the proof
recurring; and `.8.4` removes the future capability entry only after native and generated paths pass. The current
Lua execution frontier is numeric alias/symbol/number-receiver admission `.4.3.3.2`.

Related facts: [[lua-user-function-registry]], [[lua-function-definition-shell-projection]],
[[variadic-user-function-contract]], [[variadic-callable-signature-seams]].
