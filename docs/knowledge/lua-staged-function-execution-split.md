---
id: lua-staged-function-execution-split
title: Lua staged function execution is split by typed-state and runtime dependencies
answers:
  - how is LUA-BACKEND-PARITY 5.1 split
  - what is next after Lua diagnostics trace
  - which Lua leaf dispatches function body parse jobs
  - which Lua leaf executes fixed user functions
  - which Lua leaves implement variadic user functions
  - which Lua leaves implement contextual final codeblock parameters
  - why are callable codeblock literals not in Lua 5.1
date: 2026-07-15
status: current
tags: [lua, staged-parsing, user-functions, variadic, codeblock, task-tree, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.1.0 splits staged dispatch, fixed execution, variadic metadata/runtime, contextual-codeblock metadata/runtime, and no-drift. .5.1.1-.5.1.4.2 land in order at 130/133/136/139/142/146 dual-ABI tests; .5.1.5 closes the parent and activates native loading .5.2."
reverify: "rg -n 'LUA-BACKEND-PARITY\\.5\\.1(\\.|`)|staged action-body|fixed-v1|variadic-v2|contextual-codeblock|callable literals' docs/tasks/LUA-BACKEND-PARITY.md docs/TASK_TREE.md README.md ROADMAP.md ROADMAP_V2.md lua/README.md docs/linkedspec-book/src docs/knowledge"
---

`LUA-BACKEND-PARITY.5.1.0` splits the broad staged-function work along existing
typed-state and execution dependencies.

The pre-implementation audit finds that Lua already owns spec-defined exact-v1
function projection, staged payload/job sidecars, registry-first ActionIR
contract resolution, isolated pre-execution invocation frames, compiled
function records, generic trailing-block AST parsing, and built-in contextual
block execution. At that boundary it did not dispatch body parse jobs or execute
registered functions from the runtime. `.5.1.1` has since added the minimal
staged registry; `.5.1.2` has since added registered fixed-v1 execution.

The implementation order is therefore:

- `.5.1.1` (done): minimal deterministic `actionir-body.spec` provider, queue,
  execution, and immutable `body_ast` stitching;
- `.5.1.2` (done): fixed-v1 registry-first runtime execution;
- `.5.1.3.1` (done): exact variadic-v2 shell/AST/staged/registry/compiled-state preservation and
  minimum/unbounded resolution;
- `.5.1.3.2` (done): fresh-rest-array runtime execution and exact neutral fixture;
- `.5.1.4.1` / `.5.1.4.2` (done): final `name: codeblock` metadata/normalization, then contextual
  user-function block execution;
- `.5.1.5` (done): focused/public/durable/canonical no-drift.

Outward descriptors and full-pipeline trace stay `.5.3`; generated
preservation/execution stays `.8`. Explicit `{|params| ...}` literals and bound
codeblock-variable invocation remain `FUTURE-PARITY-BACKLOG.11.7` because they
need a general dynamic callable runtime, not merely a contextual final argument.

Related facts: [[lua-user-function-registry]],
[[lua-function-definition-shell-projection]],
[[function-body-staged-registry-dispatch]],
[[lua-staged-function-body-registry]],
[[lua-variadic-user-function-routing]],
[[final-codeblock-parameter-declaration]],
[[lua-runtime-block-control-callback-split]],
[[lua-fixed-v1-user-function-runtime]].
[[lua-variadic-v2-signature-state]], [[lua-variadic-v2-runtime]].
