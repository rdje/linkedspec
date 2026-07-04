---
id: trace-actionir-pipeline-decisions
title: TRACE-OBSERVABILITY.3.4.3 instruments ActionIR pipeline decisions
answers:
  - "does trace cover ActionIR pipeline decisions"
  - "what are actionir trace decision names"
  - "does trace show scanner helper event discovery"
  - "does trace show canonical RAW_PERL fallback"
  - "does trace show unresolved helper diagnostics"
  - "does trace show implicit if closure handling"
  - "how do I reverify ActionIR pipeline trace coverage"
date: 2026-07-04
status: current
tags: [trace, observability, actionir, scanner, canonical-events, diagnostics, rewrite-pipeline, perl, task-tree, mdbook]
evidence: "perl/LinkedSpec/ActionIR/Trace.pm; perl/LinkedSpec/ActionIR/{Scanner.pm,ScannerCore.pm,CanonicalEvents.pm,Diagnostics.pm,RewritePipeline.pm}; t/trace_actionir_pipeline.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md; TOOLBOX.md; docs/tasks/TRACE-OBSERVABILITY.md .3.4.3"
reverify: "perl -c -Iperl perl/LinkedSpec/ActionIR/Trace.pm && perl -c -Iperl t/trace_actionir_pipeline.t && prove -v -Iperl t/trace_actionir_pipeline.t && rg -n 'actionir:|trace_actionir_pipeline|ActionIR pipeline' perl/LinkedSpec/ActionIR t/trace_actionir_pipeline.t docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md TOOLBOX.md docs/tasks/TRACE-OBSERVABILITY.md"
---

`TRACE-OBSERVABILITY.3.4.3` adds compile-time ActionIR pipeline decision tracing to the Perl reference backend.

Decision names use this shape:

```text
actionir:<owner>:<phase>:<label>:<decision>
```

Current owners covered by this card are `scanner`, `scanner_core`, `canonical_events`, `diagnostics`, and
`rewrite_pipeline`.

Covered decisions include:

- scanner and scanner-core helper-event discovery;
- canonical helper queueing, statement queue matches, registered value-drop handling, RAW_PERL fallback creation,
  and unmatched helper scan events;
- diagnostic unresolved-pattern, unsupported AST helper call, and helper-node collection handoffs;
- rewrite-rule construction, helper-event collection summaries, canonical fallback summaries, missing contracts,
  missing source spans, no-op lowering, normal statement rewriting, unmatched helper event rewriting, ambiguous
  unmatched event skips, and unresolved-helper summaries;
- implicit attached-if flow continuation, closure insertion before the next statement, closure append at the end,
  and unbalanced flow-stack fallback.

`LinkedSpec::ActionIR::Trace` centralizes formatting and remains lazy. Requiring the ActionIR owners and running
compatibility rewrite paths does not load `LinkedSpec::Trace` unless trace was already explicitly loaded or
configured.

Scanner trace intentionally reports event-producing matches rather than every no-match probe. Diagnostics replay all
rewrite contracts, so per-contract no-match lines would add volume without improving the root-cause signal.
