---
id: perl-pipeline-source-provenance-diagnosis
title: Pipeline scanner diagnosis preserves original plans and owns null split source metadata
answers:
  - "which pipeline scanner contracts still lack original source origins"
  - "why does split_array report a null source while lowering reads input"
  - "where are the independent pipeline argument and source position oracles"
  - "which pipeline statement contracts have two event constructor branches"
date: 2026-10-05
status: historical original diagnosis; regex and metadata correction verified with statement hooks separate
tags: [perl, actionir, scanner, source-provenance, pipeline]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0 probe/reviewer bind all nineteen original public/private contracts, exact arguments, scalar frames and default callback plan inputs/results. Only set_value supplies private origins. split planner source_expr and scanner source_symbol diverge; complete Toolbox channels reproduce null metadata and correct lowering."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1-review.py"
---

PrimitivePipelineRules dispatches eleven full-input regex contracts and eight statement
contracts. At the original a2f6d6 boundary, set_value supplies origins; the other eighteen
do not. The current eleven regex channels are recorded under .1.2.1.0; see
perl-pipeline-regex-source-provenance. Eight statement contracts remain .1.2.2-owned. The literal oracle supplies a quoted regex row and forward/reversed real forms;
its cumulative scalar intervals do not search returned raw text. The nested hash-index
assignment and value-drop contracts exercise both original constructor branches. The
value-drop contract also selects standalone array pipeline calls. Public/private event
values and five dependency callback argument/result logs remain equal.

For split(items, input, ','), the public planner returns source_expr=$input. The scanner
reads last_op.source_symbol, which the plan does not publish, and reports args.source=null.
Toolbox return_descriptor repeats that null; call_spec_handler_subst and generated source
keep the input expression. ArrayPipeline.pm also reads op.source_expr in both its
binding split_value construction and legacy array split construction; the scanner does
not supply the lowering expression. This source-owner relationship limits the planned
metadata repair without admitting the removed aggregate selector. This is a diagnosed
introspection defect, not source-language admission. Metadata repair .1.2.1.1 follows .1.2.1.0's ten regex hooks and is focused-verified
behind exact canonical landing; see perl-pipeline-split-source-metadata. It precedes .1.2.2's eight
statement hooks; .1.2.3 closes the family only after canonical acceptance. Original null
observations must survive the repair. The initial array(items) exploratory probe is retained
separately: the current public compiler rejects that removed selector; it is not the accepted
bare-binding case.

The capture supplies every regular parent Git input at immutable a2f6d61815a551bf578dbce0e4b453f0f8ce8513,
plus four explicit authored oracle/case/probe overlays. This is a conservative supplied-input
superset, not a minimal observed IO graph. All command channels and before/after content,
mode and population guards remain retained. Gitlinks and nonregular metadata are excluded
without payload inspection. Host tools are read-only; project scratch stays on the repository
volume. Original runtime/event arguments, callback plans, complete TAP and distinguishing
RED evidence corruptions are checked independently. No production, spec, standard-test,
CI, hook, dependency, native execution, executable-membership or global audit closure occurs.
