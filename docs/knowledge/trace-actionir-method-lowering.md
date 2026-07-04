---
id: trace-actionir-method-lowering
title: TRACE-OBSERVABILITY.3.4.5 instruments MethodLowering decisions
answers:
  - "does trace cover MethodLowering decisions"
  - "what are method_lowering actionir trace names"
  - "does trace show MethodLowering helper families"
  - "does trace show receiver chain decisions"
  - "does trace show assignment mutation decisions"
  - "does trace show unsupported helper exits"
  - "how do I reverify MethodLowering trace coverage"
date: 2026-07-04
status: current
tags: [trace, observability, actionir, method-lowering, perl, task-tree, mdbook]
evidence: "perl/LinkedSpec/ActionIR/MethodLowering.pm; t/trace_actionir_method_lowering.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/tasks/TRACE-OBSERVABILITY.md .3.4.5"
reverify: "perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm && perl -c -Iperl t/trace_actionir_method_lowering.t && prove -v -Iperl t/trace_actionir_method_lowering.t && rg -n 'actionir:method_lowering|trace_actionir_method_lowering|MethodLowering' perl/LinkedSpec/ActionIR/MethodLowering.pm t/trace_actionir_method_lowering.t docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md TOOLBOX.md docs/tasks/TRACE-OBSERVABILITY.md"
---

`TRACE-OBSERVABILITY.3.4.5` adds compile-time MethodLowering decision tracing to the Perl reference backend.

Decision names use this shared ActionIR shape:

```text
actionir:method_lowering:<phase>:<label>:<decision>
```

Covered decisions include:

- helper-family classification for supported and unknown value helpers;
- AST value lowering, AST/raw fallback, compatibility bypass, and unsupported-helper sentinel exits;
- string, number, hash, and array receiver-chain transitions, including AST fluent-chain family lowering;
- scalar assignment, array append, hash-index assignment, set-key, push, push-nonempty, and array end-mutation
  statement routing;
- mutation-slot value classification for bare scalar reads, primitive literals, and nested method values;
- return-payload direct, method, bare-scalar, and legacy raw/rewritten fallback choices;
- scoped `_lower_assign_statement` enter/exit events for assignment helper lowering.

The hooks stay lazy through `LinkedSpec::ActionIR::Trace`. Requiring `MethodLowering.pm` or calling its owner
helpers through `EmitContext` without explicit trace configuration does not load `LinkedSpec::Trace`.
