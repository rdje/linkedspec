---
id: lua-generated-source-scaffold-split
title: Lua generated-source scaffold preserves the v1/v2/v3 callable union before isolated execution
answers:
  - why was LUA BACKEND PARITY 8.1 split before code
  - does generated Lua source need final codeblock v3 records
  - what state does the Lua source emitter serialize
  - how should generated Lua source encode Unicode payloads
  - which Lua leaf owns isolated generated source loading
  - when will Lua generated family plans and trace roles land
date: 2026-07-16
status: current
tags: [lua, generated-source, source-emitter, callable-signature, codeblock, isolation, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.8.1.0 root-causes stale v1/v2-only wording: the leaf was drafted on 2026-07-11/12, while ADR 0041 and final_codeblock_v3 landed on 2026-07-15. LUA-BACKEND-PARITY.8.1.1 implements the mapped seam in source_emitter.lua: exact function_registry.entries plus compiled_rule_order reconstruct one typed effective SpecFile, canonical strict-UTF-8 JSON and source identity render as ASCII hex, and generated native Lua exposes metadata plus direct/traced result roles with portable errors. LUA-BACKEND-PARITY.8.1.2 closes fresh-process PUC/LuaJIT valid/corrupt load-run-cleanup. Parent .8.1 closes at 173/173 per ABI; .8.2 adds exact family plan/execution/trace at 176/176; .8.3 adds contract-ordered interpreter-first 8/105 fresh-host proof at 177/177."
reverify: "git blame -L 2781,2787 docs/tasks/LUA-BACKEND-PARITY.md; git log -S'final_codeblock_v3' --oneline -- capability_conformance/outward_descriptor_contract.json; bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py; bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py; perl tools/check_generated_source_contract.pl; rg -n '8.1.0|8.1.1|8.1.2|final-codeblock-v3|ASCII hex' docs/tasks/LUA-BACKEND-PARITY.md docs/linkedspec-book/src/appendix/backend-handoff.md"
---

`LUA-BACKEND-PARITY.8.1` originally named fixed-v1 and variadic-v2 callable
state because it predated ADR `0041`. The later executable outward descriptor
contract adds an exact final-codeblock-v3 record. Generated Lua state must
therefore preserve the full permanent union: fixed `params`/`arity`, variadic
`signature`, or fixed `params`/`arity` plus final-only `parameter_kinds`.

The emitter reconstructs an effective typed `SpecFile`; it does not attempt to
revive Lua's internal compiled-state JSON. Function registry entries already
retain immutable source-ordered definitions with all v1/v2/v3 metadata. The
compiled rule order already identifies the last effective definition of each
rule and each compiled rule retains its typed header/body elements.
`spec_ast.to_json/from_json` is the existing lossless reconstruction boundary.

Lua's dependency-free JSON encoder validates every string as strict UTF-8 and
sorts object keys. The deterministic generated file embeds the
canonical JSON and source identity as ASCII hexadecimal, avoiding host literal
escaping, interpolation, Base64 dependencies, and Unicode normalization.
Generated source is native Lua text and returns a module with exact
metadata plus direct and traced execution roles.

The dependency order is intentionally narrow:

- `.8.1.1`: deterministic compatibility/source-identified emitter, metadata,
  portable errors, exact effective v1/v2/v3 state, and entrypoint roles;
- `.8.1.2`: fresh-process PUC Lua/LuaJIT valid/corrupt load, Unicode result and
  failure proof, caller-owned paths, and complete cleanup;
- `.8.2`: exact plan rows, four rejections, structural-family execution, and
  portable generated trace roles;
- `.8.3`: interpreter-first contract-sourced 8/105 admission;
- `.8.4`: sole all-pass Lua capability-census admission.

Both `.8.1` children are complete: the first owns emitted-state construction,
and the second proves the persisted artifact boundary without adding plan or
family semantics. Parent `.8.1` is closed; `.8.2` has since added exact
authoritative family execution, `.8.3` has closed exact contract-sourced 8/105
fresh-host proof, and final census/handoff `.8.4` closes at five-backend 80/0/0.

Implementation details and exact public roles: [[lua-generated-source-emitter-core]],
[[lua-generated-source-fresh-process-isolation]].
See also [[lua-generated-source-family-plan]],
[[lua-generated-source-accepted-subset]].
[[lua-five-backend-capability-admission]].

Related facts: [[generated-source-contract-v1]],
[[lua-outward-function-descriptor-union]], [[lua-final-codeblock-metadata]],
[[lua-backend-full-parity-plan]], [[julia-generated-source-scaffold]],
[[dart-generated-source-deferred]].
