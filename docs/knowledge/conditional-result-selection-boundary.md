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
  - why did is_defined false select the wrong inline condition branch
  - why did a named early-return block work while an inline payload failed
date: 2026-10-27
status: producer26.0 repaired; conditional bracket selection Perl26.1 next
tags: [perl, actionir, control, selection, fluent, laziness]
evidence: "TYPE23.1.6 finite public native/fresh/descriptor/substitution and AST intake at fcfb7dcdc; ADR0007/current inline-value authority."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/inline_condition_value_blocks.t"
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


Producer26.0 now lowers first/elseif conditions through the existing value-payload
owner before RuntimeLogical truthiness. The old route also treated the Bool literal
in is_defined(false) as $false: standalone [1,bad] versus a successful named
predicate counterfactual distinguishes the mislowering; the extra predicate packet
retains actual native/fresh observations at92da37128 before production changes.
No predicate or truthiness contract changes.

The first two-site candidate repairs basic blocks/predicates, but early-return
condition and payload blocks still fail while an identical named block succeeds.
Its exact source delta is inline-condition-two-site-candidate.patch.gz against92da37128;
inline-condition-return-candidate-intake.json records that candidate epoch, not a
clean-base execution. The parent's same-expression AST compatibility fence leaked
to child operands, suppressing typed blocks/terminal assignments. The inline value
operand wrapper now copies dependencies and removes only that fence, allowing the
smaller child to use existing AST lowering without mutating its parent or siblings.
No new AST/schema/executor or deferred operation is introduced. Retained regression
covers native/fresh working lowering/ready metadata, lazy ordered conditions,
local early returns, function-local slots, existing direct methods, typed predicates
and nested conditionals. Conditional bracket expansion26.1 follows separately.
