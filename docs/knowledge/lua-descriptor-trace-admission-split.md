---
id: lua-descriptor-trace-admission-split
title: Lua descriptor and full-trace admission has two unresolved neutral-policy dependencies
answers:
  - what blocks Lua outward descriptor admission
  - does the neutral contract define final codeblock outward descriptors
  - when should Lua enter the capability census
  - why was LUA-BACKEND-PARITY 5.3 split before implementation
  - which Lua parser phases accept a caller owned trace emitter
date: 2026-07-15
status: current
tags: [lua, descriptors, callable-signature, codeblock, trace, capability-census, task-tree, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.3.0 audits the executable contracts, Lua fences, trace APIs, capability policy, and git history: fixed-v1 and variadic-v2 have exact outward schemas; final-codeblock metadata has no exact outward record schema; runtime alone accepts a trace emitter; and older .5.3 census wording conflicts with the later full-backend admission policy. Both Lua ABIs remain 153/153 and canonical CI passes CLI 61x2 plus Phase 0 1..1031 in 605 seconds."
reverify: "python3 tools/check_callable_signature_contract.py && python3 tools/check_callable_codeblock_contract.py && perl tools/check_capability_conformance.pl && rg -n 'descriptor_pending|parameter_kinds|options.trace|Lua remains outside|expand the capability census' lua capability_conformance README.md docs/tasks/LUA-BACKEND-PARITY.md"
---

`LUA-BACKEND-PARITY.5.3.0` found that Lua implementation work is mechanically understood but depends on two
backend-neutral policy decisions.

The outward descriptor union is exact for two variants:

- `capability_conformance/outward_descriptor_contract.json` defines the fixed-v1 function record with
  `params` plus `arity`;
- `capability_conformance/callable_signature_contract.json` defines the variadic-v2 record, which replaces those
  fields with the exact six-field `signature` object.

The final-codeblock declaration contract preserves `parameter_kinds` through definition, payload, parse job,
typed AST, registry, and compiled state. ADR `0032` says descriptors must preserve that intent, but neither of the
two outward record schemas defines where `parameter_kinds` belongs or which function-record version represents
it. The other admitted backend projections do not establish a neutral codeblock record shape. Lua therefore
fails closed with `codeblock_user_function_descriptor_pending`; inventing a Lua-only field would violate the
single-contract rule. The generic callable-codeblock capability remains future work under
`FUTURE-PARITY-BACKLOG.11`, with the manifest pointing at its next Rust closeout owner `.11.4.3`.

Capability timing also contains a historical conflict. The initial Lua `.5.3` text required immediate census
expansion. Later commit `4a2adda9` established the current 16-capability/four-backend census and explicitly kept
Lua outside until its dedicated parity tree completes. The Lua root acceptance and `.8.4` likewise require Lua to
reach an all-pass expanded census before the backend is called complete. Adding Lua during `.5.3` would therefore
supersede the newer admission policy and necessarily introduce non-pass generated/corpus/CLI rows; deferring it
requires correcting the stale `.5.3` sentence.

The trace dependency is not ambiguous. `linkedspec.trace` already owns caller-created emitters and the runtime
accepts one as `options.trace`. Source parsing, validation, compilation, the spec-owned function parser,
function-shell projection, staged body dispatch, and native resolution/loading currently accept no emitter. The
completed Dart/Julia model is to pass one emitter identity through those APIs, preserve quiet defaults and results,
and emit balanced stage events without constructing hidden emitters. Lua `.5.3.2` owns that propagation after
descriptor policy is settled.

The planning split is:

- `.5.3.0.1`: settle final-codeblock descriptor scope and census timing;
- `.5.3.1`: implement the selected exact outward descriptor union;
- `.5.3.2`: propagate one emitter through the complete native pipeline;
- `.5.3.3`: close no-drift and apply the selected capability-admission boundary.

No source, behavior, public status, descriptor shape, capability row, or test expectation changes in `.5.3.0`.

Related facts: [[lua-diagnostics-trace-boundary]], [[lua-variadic-v2-signature-state]],
[[outward-function-descriptor-record-shape-drift]], [[trace-cross-variant-capability-contract]],
[[backend-capability-census]].
