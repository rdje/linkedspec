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
evidence: "LUA-BACKEND-PARITY.8.1.0 root-causes stale v1/v2-only wording: the leaf was drafted on 2026-07-11/12, while ADR 0041 and final_codeblock_v3 landed on 2026-07-15. The audit maps exact effective state through function_registry.entries, compiled_rule_order, spec_ast to_json/from_json, canonical strict-UTF-8 json.encode, and direct/traced runtime APIs. It splits deterministic v1/v2/v3 Lua emission .8.1.1 from fresh-process PUC/LuaJIT valid/corrupt load-run-cleanup .8.1.2; plan/family/portable generated trace remains .8.2. Focused Lua proof is 169/169 per ABI, primary 61x2, corpus 105/105; canonical Phase 0 is 1031/1031 in 609 seconds."
reverify: "git blame -L 2781,2787 docs/tasks/LUA-BACKEND-PARITY.md; git log -S'final_codeblock_v3' --oneline -- capability_conformance/outward_descriptor_contract.json; python3 tools/check_callable_signature_contract.py; python3 tools/check_callable_codeblock_contract.py; perl tools/check_generated_source_contract.pl; rg -n '8.1.0|8.1.1|8.1.2|final-codeblock-v3|ASCII hex' docs/tasks/LUA-BACKEND-PARITY.md docs/linkedspec-book/src/appendix/backend-handoff.md"
---

`LUA-BACKEND-PARITY.8.1` originally named fixed-v1 and variadic-v2 callable
state because it predated ADR `0041`. The later executable outward descriptor
contract adds an exact final-codeblock-v3 record. Generated Lua state must
therefore preserve the full permanent union: fixed `params`/`arity`, variadic
`signature`, or fixed `params`/`arity` plus final-only `parameter_kinds`.

The emitter should reconstruct an effective typed `SpecFile`, not attempt to
revive Lua's internal compiled-state JSON. Function registry entries already
retain immutable source-ordered definitions with all v1/v2/v3 metadata. The
compiled rule order already identifies the last effective definition of each
rule and each compiled rule retains its typed header/body elements.
`spec_ast.to_json/from_json` is the existing lossless reconstruction boundary.

Lua's dependency-free JSON encoder validates every string as strict UTF-8 and
sorts object keys. The deterministic generated file can therefore embed the
canonical JSON and source identity as ASCII hexadecimal, avoiding host literal
escaping, interpolation, Base64 dependencies, and Unicode normalization.
Generated source remains native Lua text and returns a module with exact
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

Related facts: [[generated-source-contract-v1]],
[[lua-outward-function-descriptor-union]], [[lua-final-codeblock-metadata]],
[[lua-backend-full-parity-plan]], [[julia-generated-source-scaffold]],
[[dart-generated-source-deferred]].
