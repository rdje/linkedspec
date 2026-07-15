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
date: 2026-07-15
status: current
tags: [trace, parity, variants, mdbook, external-contract, rust, perl]
evidence: "User directive 2026-07-04; docs/linkedspec-book/src/public-api/trace-api.md; TRACE-OBSERVABILITY.4.5; JULIA-BACKEND-PARITY.7.3.2.1"
evidence_update_2026_07_15_selective_format_trace: "ADR 0037 and FUTURE-PARITY-BACKLOG.18.2 add future correlated construction/runtime tracing, exact emission-only rule filters, bounded payloads, and shared non-interference proof under STRUCTURED-TEXT-FORMAT-PROGRAM.2.7; current behavior is unchanged."
reverify: "rg -n 'variant-neutral trace contract|Future variant trace parity checklist|trace parity|variant-agnostic|claim trace parity|external contract|backend-specific internals|Perl reference vocabulary|TRACE-OBSERVABILITY\\.4\\.5|rust_runtime:engine|rust_runtime:generated_plan' docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md docs/tasks/TRACE-OBSERVABILITY.md TOOLBOX.md docs/knowledge/trace-cross-variant-capability-contract.md rust/linkedspec-runtime/src"
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

Rust now has the `.4.2` trace control/sink surface, `.4.3` compile/spec-parser/staged-dispatch events, `.4.4`
interpreted/generated-plan runtime branch/mark/capture events, and `.4.5` parity proof. Rust can claim trace parity
for the documented external contract. Future variants must pass the mdBook checklist and record proof before making
the same claim. Julia split that proof through `JULIA-BACKEND-PARITY.4.5.0`; `.4.5.1` added structured runtime
diagnostics and `.4.5.2` added controls/events/sinks plus traced entrypoints. `.4.5.3` / `.4.5.4` separately own
runtime instrumentation and no-drift. `.7.3.2.1` later closes Julia source parser, validation, compiler,
function-shell, and staged-dispatch propagation through the same controls/sinks, with default-quiet and
traced/untraced identity proof.

ADR `0037` adds a stronger future readiness layer for dynamic format parsers: correlated spec/cache/rule/source
identity across construction and runtime, exact rule-label emission filters, bounded diagnostic payloads, and
shared cross-backend non-interference fixtures. Those are owned by
`STRUCTURED-TEXT-FORMAT-PROGRAM.2.7`; they are not retroactive implementation claims for the completed original
trace tree.

Related facts: [[julia-runtime-diagnostics-trace-split]], [[julia-runtime-structured-diagnostics]],
[[julia-trace-controls-sinks]], [[julia-runtime-trace-events]],
[[julia-diagnostics-trace-boundary]],
[[julia-frontend-compiler-staged-trace-events]],
[[trace-backend-parity-split]],
[[dart-runtime-diagnostics-trace-split]],
[[selective-end-to-end-parser-observability]].
