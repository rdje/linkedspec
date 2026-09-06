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
  - "where are Perl canonical event kinds normalized"
  - "how do canonical helper events align with action statements"
date: 2026-09-06
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

The 2026-09-06 `.3.2.17` reading checkpoint confirms the current owner split. CanonicalEvents.pm queues helper
events by trimmed raw statement, consumes each matched queue in statement order, classifies registered function,
bound codeblock, and receiver-mutation value drops, records RAW_PERL fallbacks, and appends leftover scan events.
Leftovers are appended by hash-key traversal; this record makes no stable order claim for those unmatched keys.
CanonicalEvents/Core.pm maps contract IDs to canonical kinds and normalizes argument context/target modes.
The private mapping is not an authoring-admission registry: retained internal contract IDs do not restore retired
public spellings. This is source-level reconciliation, not a new execution or backend-conformance result.

The 2026-09-06 `.3.2.30` checkpoint re-reads RewritePipeline, Scanner, and FlowRules at
the unchanged baseline. The managed `t/trace_actionir_pipeline.t` suite passes five
top-level tests. RewritePipeline finds original statement spans for separator bookkeeping,
but searches the evolving rewritten text from offset zero for replacement; flexible call
matching preserves quoted characters while relaxing external whitespace. This is not
lexical ownership of the surrounding text: [[perl-quoted-primitive-rewrite-event-drift]]
records the known quoted-text corruption and false-event repair under `.18`. Unbalanced
if/switch stacks return the original code after trace reporting.
