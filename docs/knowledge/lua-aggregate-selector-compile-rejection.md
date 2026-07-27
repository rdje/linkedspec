---
id: lua-aggregate-selector-compile-rejection
title: "Lua rejects exact aggregate selectors across compiled and runtime-engine admission"
answers:
  - "how does Lua reject array name and hash name selectors"
  - "what is the Lua aggregate selector removed diagnostic"
  - "are Lua selectors rejected inside dead code"
  - "are Lua selectors rejected inside unused user functions"
  - "does Lua reject caller mutated selector AST"
  - "which array and hash constructors remain valid on Lua"
  - "where was Lua selector compatibility dispatch removed"
date: 2026-07-12
status: current
tags: [lua, luajit, actionir, compiler, runtime, bindings, retirement, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.8.5 adds recursive ActionIR detection in lua/src/linkedspec/action_ast.lua and whole-compiled-state validation in lua/src/linkedspec/compiled_spec.lua. Normal compilation, dead control bodies, valid deferred fluent calls, unused function bodies, and caller-mutated compiled payloads at runtime-engine admission reject exact selectors with typed fields. Selector-specific runtime reads, set/push/receiver targets, split/transform wrappers, and descriptor branches are deleted. All six neutral invalid cases and all eight retained constructor/literal classes pass. PUC Lua and LuaJIT each pass 88/88; the exact 105-manifest/CLI scaffold passes and the executable scan is zero-positive/19 classified."
reverify: "bash tools/run_lua_local.sh && bash tools/run_python_project_data.sh tools/check_executable_aggregate_selector_sources.py"
---

# Lua aggregate-selector compile rejection

Lua rejects the removed exact one-bare-identifier `array` and `hash` call shapes before execution with
`aggregate_selector_removed surface=<surface> identifier=<name> replacement=<name>` and matching typed fields.

The validator walks every typed ActionIR expression family in compiled rule payloads. It also parses and inspects
every valid deferred user-function body and fluent call while preserving unrelated parse-failure timing. Because
Lua compiled specs are mutable host tables, runtime-engine construction repeats validation so caller mutation after
compilation cannot restore a removed form.

Runtime compatibility is deleted: `array`/`hash` no longer perform one-name reads, targets and receivers no longer
unwrap aggregate calls, and mutable split/collection transforms accept only bare bindings. Empty, multi-argument,
quoted, computed, and direct literal forms remain distinct constructors/values.

Related facts: [[lua-uniform-binding-runtime]], [[uniform-binding-neutral-contract]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[julia-aggregate-selector-compile-rejection]].
