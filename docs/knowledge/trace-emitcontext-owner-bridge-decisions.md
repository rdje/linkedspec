---
id: trace-emitcontext-owner-bridge-decisions
title: EmitContext owner bridge trace decisions
date: 2026-07-04
status: current
tags:
  - trace
  - observability
  - emitcontext
  - actionir
  - ruleir
answers:
  - are EmitContext owner bridge decisions traced
  - how are EmitContext trace decisions named
  - does EmitContext trace owner package resolution
  - does EmitContext trace rewrite compatibility fallbacks
  - does EmitContext stay Trace-lazy
evidence:
  - docs/tasks/TRACE-OBSERVABILITY.md
  - perl/LinkedSpec/RuleIR/EmitContext.pm
  - t/trace_emit_context_bridge.t
reverify: perl -c -Iperl perl/LinkedSpec/RuleIR/EmitContext.pm && prove -v -Iperl t/trace_emit_context_bridge.t
---

# EmitContext Owner Bridge Trace Decisions

`TRACE-OBSERVABILITY.3.4.2` added debug-level EmitContext trace events under:

```text
emit_context:<phase>:<label>:<decision>
```

The current coverage is the bridge/orchestration layer: ActionIR owner package and callback resolution, default
dependency bundle selection, function-registry and bare-symbol-kind injection, compatibility scalar-slot and
aggregate-wrapper fallbacks, canonical rewrite-pipeline use, canonical raw-Perl fallback status, and
`build_rule_ir_emit_context(...)` boundaries.

The implementation stays lazy for require-only consumers. `LinkedSpec::RuleIR::EmitContext` checks for an already
loaded `LinkedSpec::Trace` owner before emitting trace calls, so simply requiring EmitContext does not load Trace.

Scanner, canonical-event, diagnostic, and rewrite-pipeline internals are not covered by this card; they are owned by
`TRACE-OBSERVABILITY.3.4.3`.
