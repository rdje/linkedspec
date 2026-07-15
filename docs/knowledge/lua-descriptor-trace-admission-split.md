---
id: lua-descriptor-trace-admission-split
title: Lua descriptor and full-trace admission uses descriptor v3 and completion-time census admission
answers:
  - what blocks Lua outward descriptor admission
  - does the neutral contract define final codeblock outward descriptors
  - when should Lua enter the capability census
  - why was LUA-BACKEND-PARITY 5.3 split before implementation
  - which Lua parser phases accept a caller owned trace emitter
  - what is final codeblock outward descriptor version 3
  - which leaf admits Lua to the capability census
date: 2026-07-15
status: current
tags: [lua, descriptors, callable-signature, codeblock, trace, capability-census, task-tree, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.3.0 audits the contracts/fences/trace APIs/census history; .5.3.0.1/ADR 0041 adopt descriptor v3 and completion-time census admission; .5.3.1 implements the exact three-variant union and Lua emission. Runtime alone currently accepts a trace emitter, so .5.3.2 remains the next propagation owner."
reverify: "python3 tools/check_callable_signature_contract.py && python3 tools/check_callable_codeblock_contract.py && bash tools/run_lua_local.sh && perl tools/check_capability_conformance.pl && rg -n 'function_record_variants|options.trace|Lua remains outside|expand the capability census' lua capability_conformance README.md docs/tasks/LUA-BACKEND-PARITY.md"
---

`LUA-BACKEND-PARITY.5.3.0` found two backend-neutral policy dependencies. The director accepted both recommended
resolutions in `.5.3.0.1`, recorded normatively by ADR `0041`.

The outward descriptor union is exact for three variants in
`capability_conformance/outward_descriptor_contract.json:function_record_variants`:

- fixed-v1 uses `params` plus `arity`;
- variadic-v2 replaces those fields with the exact six-field `signature` object;
- final-codeblock-v3 retains fixed `params`/`arity` and adds exact final-only `parameter_kinds`.

The final-codeblock declaration contract preserves `parameter_kinds` through definition, payload, parse job,
typed AST, registry, and compiled state. ADR `0041` assigns that intent an exact outward version-3 record: fixed
`params` and `arity`, followed by a `parameter_kinds` object whose sole entry maps the final parameter to
`codeblock`, then the unchanged provenance/body fields. `.5.3.1` implements that executable union and Lua now
emits all three exact variants. Generic callable-codeblock capability remains future work under
`FUTURE-PARITY-BACKLOG.11`.

The initial Lua `.5.3` text required immediate census expansion, while later commit `4a2adda9` established the
current four-backend all-pass census and explicitly kept Lua outside until its parity tree completes. ADR `0041`
selects the latter boundary: `.5.3.3` closes descriptor/trace work without changing census membership, and `.8.4`
alone expands the manifest all-pass after native, corpus, CLI, generated, and generated-subset proof is complete.

The trace dependency is not ambiguous. `linkedspec.trace` already owns caller-created emitters and the runtime
accepts one as `options.trace`. Source parsing, validation, compilation, the spec-owned function parser,
function-shell projection, staged body dispatch, and native resolution/loading currently accept no emitter. The
completed Dart/Julia model is to pass one emitter identity through those APIs, preserve quiet defaults and results,
and emit balanced stage events without constructing hidden emitters. Lua `.5.3.2` owns that propagation after
descriptor policy is settled.

The resolved dependency order is:

- `.5.3.0.1`: done; adopt descriptor v3 and completion-time census admission;
- `.5.3.1`: done; executable union/checker plus exact Lua outward descriptors;
- `.5.3.2`: propagate one emitter through the complete native pipeline;
- `.5.3.3`: close no-drift while preserving the four-backend census;
- `.8.4`: expand the census with all-pass Lua rows.

No source, behavior, public status, emitted descriptor, capability row, or test expectation changes in `.5.3.0.1`.

Related facts: [[lua-diagnostics-trace-boundary]], [[lua-variadic-v2-signature-state]],
[[outward-function-descriptor-record-shape-drift]], [[trace-cross-variant-capability-contract]],
[[backend-capability-census]].
