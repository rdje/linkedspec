---
id: trace-ruleir-planning-decisions
title: TRACE-OBSERVABILITY.3.4.1 instruments RuleIR planning decisions
answers:
  - "does trace cover RuleIR planning decisions"
  - "what are rule_ir trace decision names"
  - "does trace show handler variant selection"
  - "does trace show RuleIR lifecycle routing"
  - "how do I reverify RuleIR planning trace coverage"
date: 2026-07-04
status: current
tags: [trace, observability, ruleir, actionir, perl, task-tree, mdbook]
evidence: "perl/LinkedSpec/RuleIR.pm; t/trace_ruleir_planning.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md; docs/tasks/TRACE-OBSERVABILITY.md .3.4.1"
reverify: "perl -c -Iperl perl/LinkedSpec/RuleIR.pm && perl -c -Iperl t/trace_ruleir_planning.t && prove -v -Iperl t/trace_ruleir_planning.t && rg -n 'rule_ir:|trace RuleIR planning|RuleIR planning decisions' perl/LinkedSpec/RuleIR.pm t/trace_ruleir_planning.t docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md TOOLBOX.md docs/tasks/TRACE-OBSERVABILITY.md"
---

`TRACE-OBSERVABILITY.3.4.1` adds compile-time RuleIR planning decisions to the Perl reference trace.

Decision names use this shape:

```text
rule_ir:<phase>:<rule_label>:<decision>
```

Current phases are `collect`, `select`, `meta`, and `validate`.

Covered decisions include:

- rule-entry collection and top-rule collection;
- regex, explicit ACODE, blind-call BCODE, standalone lifecycle, and per-regex lifecycle routing;
- `MOVE_POS` and `MARK_POS` lowering into LECODE;
- handler variant selection, action mode, and execution shape planning;
- valid action-mode and rejected mixed-action validation.

The focused regression proves direct RuleIR probes and normal `LinkedSpec::Get(..., return_descriptor => 1,
trace_level => 'debug', ...)` descriptor compilation both expose the decisions without changing metadata or parser
behavior.
