---
id: trace-cross-variant-capability-contract
title: Trace capabilities are a variant-agnostic external parity contract
answers:
  - "is trace parity required across variants"
  - "can Rust claim parity without trace capabilities"
  - "are trace capabilities variant agnostic"
  - "are Perl trace internals the external contract"
  - "what must variants implement to claim trace parity"
  - "does the common LinkedSpec book define trace behavior for all variants"
date: 2026-07-04
status: current
tags: [trace, parity, variants, mdbook, external-contract, rust, perl]
evidence: "User directive 2026-07-04; docs/linkedspec-book/src/public-api/trace-api.md; docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md; docs/tasks/TRACE-OBSERVABILITY.md"
reverify: "rg -n 'variant-neutral trace contract|trace parity|variant-agnostic|claim trace parity|external contract|backend-specific internals|Perl reference vocabulary|TRACE-OBSERVABILITY\\.4\\.1' docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md docs/tasks/TRACE-OBSERVABILITY.md TOOLBOX.md docs/knowledge/trace-cross-variant-capability-contract.md"
---

The documented trace capabilities are an external contract for every LinkedSpec variant.

Perl-specific function names, package variables, file handles, environment variables, helper names, and internal
decision namespaces are implementation mechanics. They are not the portable contract by themselves.

A variant may claim trace parity only when its user-visible behavior supports equivalent documented capabilities:

- ordered trace verbosity levels equivalent to `none`, `low`, `medium`, `high`, `full`, and `debug`;
- controls usable through the variant's normal entrypoints without changing parse results;
- structured enter/exit scope events;
- decision and branch events;
- mark/capture position events where applicable;
- dump/log output;
- stdout, routed-file, and mirror-style sink behavior or an equivalent backend-native routing model;
- routed-file reset/truncate behavior;
- default quiet behavior when tracing is disabled.

The Perl backend is the reference implementation currently covered under `TRACE-OBSERVABILITY.3.*`. Perl reference
event names such as `rule_ir:...`, `emit_context:...`, `actionir:...`, and `generated_handler_branch:...` are
reference vocabulary, not mandatory package names for every backend.

Rust currently has no analogous trace API/sink surface outside corpus fixture text. `TRACE-OBSERVABILITY.4.1` is
the active frontier to map this contract onto Rust entrypoints and owner boundaries before Rust trace code.
