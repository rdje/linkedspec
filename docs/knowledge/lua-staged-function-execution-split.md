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
evidence: "LUA-BACKEND-PARITY.5.1.0 audits Lua function shell/registry/compiled/runtime seams and splits staged dispatch, fixed execution, variadic metadata/runtime, contextual-codeblock metadata/runtime, and no-drift before code. LUA-BACKEND-PARITY.5.1.1 subsequently lands staged dispatch at 130/130 on both ABIs and activates .5.1.2."
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
staged registry; registered calls remain `.5.1.2`.

The implementation order is therefore:

- `.5.1.1` (done): minimal deterministic `actionir-body.spec` provider, queue,
  execution, and immutable `body_ast` stitching;
- `.5.1.2`: fixed-v1 registry-first runtime execution;
- `.5.1.3.1/.2`: variadic-v2 shell/state preservation, then fresh-rest-array
  runtime execution;
- `.5.1.4.1/.2`: final `name: codeblock` metadata/normalization, then contextual
  user-function block execution;
- `.5.1.5`: focused/public/durable/canonical no-drift.

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
[[lua-runtime-block-control-callback-split]].
