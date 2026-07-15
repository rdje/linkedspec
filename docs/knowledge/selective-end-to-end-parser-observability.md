---
id: selective-end-to-end-parser-observability
title: Dynamic format parsers require correlated compile/runtime trace and exact rule filtering
answers:
  - do dynamically constructed spec parsers require compile-time trace
  - do structured text parsers require runtime trace
  - can LinkedSpec trace one specific rule
  - does rule trace filtering change parser behavior
  - which trace levels do LinkedSpec variants use
  - is off an alias for no tracing
  - what does STRUCTURED-TEXT-FORMAT-PROGRAM 2.7 own
  - what is FUTURE-PARITY-BACKLOG 18.2
  - does Lua already have full pipeline trace
date: 2026-07-15
status: current
tags: [trace, observability, compiler, runtime, parser, staged-parsing, formats, parity, FUTURE-PARITY-BACKLOG]
evidence: "Director/engineer agreement 2026-07-15; ADR 0037; FUTURE-PARITY-BACKLOG.18.2; STRUCTURED-TEXT-FORMAT-PROGRAM.2.7; trace-api and structured-format-program mdBook chapters. Planning only: no trace/parser/compiler/runtime behavior changed."
reverify: "rg -n '0037|rule-label allowlist|construction/runtime|STRUCTURED-TEXT-FORMAT-PROGRAM.2.7|Lua.*full.*pipeline|full frontend' docs/decisions/0037-selective-end-to-end-parser-observability.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/architecture/structured-format-program.md"
---

ADR `0037` makes observability part of the post-parity format-parser readiness contract. A format parser built
dynamically from a composed `.spec` graph must expose one correlated native trace across graph resolution/imports,
validation, function/staged parsing, contract/dependency planning, cache fingerprint/hit/miss decisions,
compilation, and document execution. Runtime coverage includes rule scopes, parsing and branch decisions,
cursor/capture transitions, AST/value emission, recovery, diagnostics, and result boundaries where applicable.

The base ordered levels remain `none`, `low`, `medium`, `high`, `full`, and `debug`, with existing documented
aliases. `off` is adopted as a future neutral alias for `none`, but this planning decision does not change any
current CLI/API parser. `STRUCTURED-TEXT-FORMAT-PROGRAM.2.7` must implement the alias and exact control contract
across all current backends before it becomes a current behavior claim.

The same future contract adds an ordered exact rule-label allowlist. Global pipeline scopes remain visible;
rule-owned events are emitted only for selected labels; and dispatch decisions owned by a selected rule remain
visible even if the callee is filtered out. Filtering changes event emission only. It may not skip or alter
resolution, compilation, validation, execution, recovery, diagnostics, cache identity, ASTs, or values. Unknown
selected labels diagnose before parser work. Shared fixtures must prove deterministic order and traced/untraced
semantic identity on Perl, Rust, Dart, Julia, Lua, and LuaJIT.

Current state is intentionally precise: the existing trace contract and compile/runtime coverage are established
across the mature variants; Dart and Julia have caller-emitter full native-pipeline propagation; Lua has complete
runtime tracing but retains frontend/compiler/function/staged propagation under `LUA-BACKEND-PARITY.5.3` before
the post-parity format program may start.

Related facts: [[trace-cross-variant-capability-contract]], [[post-parity-structured-text-program]],
[[lua-diagnostics-trace-boundary]], [[dart-full-pipeline-trace-gap]],
[[julia-frontend-compiler-staged-trace-events]].
