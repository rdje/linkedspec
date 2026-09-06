---
id: trace-actionir-compact-lowerers
title: TRACE-OBSERVABILITY.3.4.4 instruments compact ActionIR lowerer decisions
answers:
  - "does trace cover compact ActionIR lowerers"
  - "what are compact lowerer actionir trace names"
  - "does trace show FlowExpr decisions"
  - "does trace show ValueExpr direct access decisions"
  - "does trace show ArrayPipeline plan decisions"
  - "does trace show DeclareMethod initializer decisions"
  - "does trace show ControlFlow if switch decisions"
  - "how do I reverify compact lowerer trace coverage"
  - "where are Perl array pipeline plans lowered"
  - "which array pipeline path guards a receiver mutation target"
  - "how does a rejected Perl branch rewrite preserve control context"
  - "where are ControlFlow candidate rewrite contexts copied and committed"
date: 2026-09-06
status: current
tags: [trace, observability, actionir, flow-expr, value-expr, array-pipeline, declare-method, control-flow, perl, task-tree, mdbook]
evidence: "perl/LinkedSpec/ActionIR/{FlowExpr.pm,ValueExpr.pm,ArrayPipeline.pm,DeclareMethod.pm,ControlFlow.pm}; t/trace_actionir_compact_lowerers.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/tasks/TRACE-OBSERVABILITY.md .3.4.4"
evidence_update_2026_08_17: "FUTURE-PARITY-BACKLOG.14.6.2.2 focused ActionIR proof exposed three assertions that still expected pre-ADR-0043 raw Perl truthiness and logical-and text. The tests now assert RuntimeLogical::truthy, eager RuntimeLogical::evaluate('and', ...), preserved defined($name), and typed_logical_and trace naming. Production lowering was already correct and did not change."
reverify: "perl -c -Iperl perl/LinkedSpec/ActionIR/FlowExpr.pm && perl -c -Iperl perl/LinkedSpec/ActionIR/ValueExpr.pm && perl -c -Iperl perl/LinkedSpec/ActionIR/ArrayPipeline.pm && perl -c -Iperl perl/LinkedSpec/ActionIR/DeclareMethod.pm && perl -c -Iperl perl/LinkedSpec/ActionIR/ControlFlow.pm && perl -c -Iperl t/trace_actionir_compact_lowerers.t && prove -v -Iperl t/trace_actionir_compact_lowerers.t && rg -n 'actionir:(flow_expr|value_expr|array_pipeline|declare_method|control_flow)|trace_actionir_compact_lowerers|compact ActionIR lowerer' perl/LinkedSpec/ActionIR t/trace_actionir_compact_lowerers.t docs/linkedspec-book/src/public-api/trace-api.md TOOLBOX.md docs/tasks/TRACE-OBSERVABILITY.md"
---

`TRACE-OBSERVABILITY.3.4.4` adds debug-level trace decisions for compact ActionIR lowering owners outside
`ActionIR::MethodLowering`.

Decision names use the shared ActionIR shape:

```text
actionir:<owner>:<phase>:<label>:<decision>
```

Owners covered by this card are `flow_expr`, `value_expr`, `array_pipeline`, `declare_method`, and
`control_flow`.

Covered decisions include:

- flow-expression booleans, scalar slots, literals, logical operators, comparisons, definedness, emptiness, regex
  matches, method-value delegation, and passthroughs;
- value-expression primitive literals, direct nested access segments, assignment-source reads, and literal
  delimiter stripping;
- array-pipeline target discovery, split/filter/unary op append decisions, per-op lowering, and unsupported plan
  fallbacks;
- declaration extraction, array/hash/scalar initializer routing, typed declaration lowering, and AST/legacy set
  assignment lowering;
- compact control-flow attached/inline/marker `if` and `switch` decisions, branch-statement direct control,
  rewrite-rule, and passthrough handling, plus attached `while` support.

`ActionIR::MethodLowering` is intentionally not included here. It has since been covered by the separate
`TRACE-OBSERVABILITY.3.4.5` MethodLowering trace leaf and card.

The trace hooks stay lazy through `LinkedSpec::ActionIR::Trace`: requiring compact lowerer modules or calling them
through `EmitContext` without explicit trace configuration does not load `LinkedSpec::Trace`.

The 2026-09-06 `.3.2.17` reading checkpoint confirms ArrayPipeline.pm's two emission paths without changing
them: `_build_array_pipeline_plan_from_expr` collects operations recursively, and `_lower_array_pipeline_expr`
emits them in order. A uniform-binding target uses scalar-held values through BindingRuntime; an active receiver
target gets `assert_receiver_writable` with its authored source span before any operation. The legacy internal
array path builds list expressions over `@target`. This is source-level ownership evidence, not new runtime proof;
[[perl-uniform-binding-runtime]] and [[map-leaves-mutation-neutral-contract]] retain the behavior contracts.

The 2026-09-06 `.3.2.20` checkpoint reads ControlFlow.pm 1–1485 and confirms branch-rule isolation:
`_lower_flow_branch_single_statement` gives each rewrite rule a candidate from
`_clone_flow_branch_rewrite_ctx`, which copies stack-entry hashes and counter values while sharing the rules.
Only a defined, nonempty result different from the input commits that candidate to the branch context.
A controlled rejected-rule probe changed its candidate stack/counter; the next rule still saw the original
values, and its accepted counter update committed. The compact-lowerer trace suite passes four top-level tests.
This bounds the claim to candidate state; the clone is not a general deep copy or a rollback of external effects.
