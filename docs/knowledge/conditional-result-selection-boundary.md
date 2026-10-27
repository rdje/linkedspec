---
id: conditional-result-selection-boundary
title: Inline conditional brackets need source composition and eager conditions need lowering repair
answers:
  - can an inline if or switch result be indexed directly
  - do inline conditional results already support direct methods on Perl
  - why does an eager block in an inline if condition fail compilation
  - why is an inline condition ready when generated Perl is invalid
  - does a switch subject block have the same failure as an if condition
  - which task owns conditional result bracket composition
date: 2026-10-27
status: target26 frozen; P1 producer26.0 precedes Perl26.1
tags: [perl, actionir, control, selection, fluent, laziness]
evidence: "TYPE23.1.6 finite public native/fresh/descriptor/substitution and AST intake at fcfb7dcdc; ADR0007/current inline-value authority."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_conditional_result_composition.pl"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_conditional_result_composition.pl --condition-controls"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_conditional_result_composition.pl --ast-controls"
---

Existing inline if/switch producers and named reads work on native/fresh Perl,
as do direct Array-to-String and scalar method chains. They retain raw0,
unresolved0 and ready1. Direct bracket suffixes instead remain raw AST and fail
handler/fresh-source compilation, raw2/unready. The static computed-source owner
excludes these names. Family26 admits only existing inline value-control results,
preserving lazy selection, actual kinds, ordered reads and other control roles.

The laziness probe also exposes a distinct P1 producer defect: an eager first or
elseif condition block is typed/ready1/raw0 but remains authored DSL inside
RuntimeLogical::truthy in emitted Perl. _lower_inline_if_value_expr sends these
conditions through lower_flow_composite_expr, while branch payloads and switch
subjects use value/block lowering. The named-condition counterfactual returns
[[a,b],CT]; direct branch-only and switch-subject blocks return T and ST. Actual
native/fresh compile errors, substitution and exact programs are retained in the
conditional intake packets.26.0 repairs that producer before26.1 read expansion;
readiness must describe working lowering rather than being waived.

The frozen target and future shared fixture live under
docs/checkpoints/type-operation-inventory/conditional-result-selection.md.
Independent backend children follow Perl; full source/context/portable/generated
admission remains23.4. No new helper/type/schema or callback vocabulary is selected.
