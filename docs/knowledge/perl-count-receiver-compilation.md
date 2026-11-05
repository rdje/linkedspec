---
id: perl-count-receiver-compilation
title: Count copy dispatch already avoids the retained long receiver compiler path
answers:
  - "why did the long Count repeated-copy receiver source compile slowly"
  - "does the original long Count receiver regression now compile and execute"
  - "why can a short cold Get probe stop before a minimal source compiles"
  - "which compiler path does retaining Count copy dispatch avoid"
date: 2026-11-05
status: Count-specific causal diagnosis and original-source regression focused-checked; general scaling unassessed
tags: [perl, count, copy, compiler, compatibility, bootstrap, provenance]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.7; docs/checkpoints/count-compiler-scaling-2026-11-05/ retains original sources, bounded cold/warm stages, single-condition counterfactual, entry-path observations, actual archives and native/fresh normal proof. Activation e7b9197ae006e85ea5a306573f257d7933c04c12."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl t/count_copy_source_composition.t long_receiver_repeated_copy_rejection"
  - "bash tools/run_python_project_data.sh docs/checkpoints/count-compiler-scaling-2026-11-05/review.py; historical capture writers are one-shot and must not overwrite retained outputs."
---

The exact original interrupted long receiver source from73.6.1 now completes
public parse-only/substitution/native stages after a separately qualified warmup.
The maintained normal restores it as `long_receiver_repeated_copy_rejection`,
alongside the unchanged shorter receiver control. Native/fresh values are
`[null,"S"]`; skipped operands/defaults/with retain rejection. Ready metadata,
cursors, warnings and needed source errors are preserved in selected controls.

The causal repair is already in73.6.1: MethodLowering's `guarded_copy_chain`
includes `ordinary_count_result_chain`. A private single-condition reversion
routes Count back through generic copy-prefix folding. Both long forms then
hit the bounded stop, while no-copy and minimal controls complete. Entry-path
capture observes generated `do { ... $__ls_copy_value ... }` Perl re-entering
`_lower_method_value_expr` with its compatibility flag via
`legacy_method_value_expr` (line4017 at activation). Retaining Count in the
existing emitted dispatcher avoids this round trip as well as preserving its
separate rejection state. This leaf changes no production compiler bytes.

Initial six-second cold Get/parse-only stops also occur for minimal controls;
they cannot establish source-dependent scaling. The bootstrap/function-parser
allowance already noted in [[cursor-rewind-default-loop-progress-gap]] matters.
All retained warm stages complete. These are finite branch/source controls,
not a wall-time, asymptotic or whole-compiler performance claim.

Actual declared warm/path-census/normal inputs and emitted modules survive in
the capsule. BSD tar AppleDouble entries are separately validated by magic and
paired archive entry, retained as packaging metadata, and never treated as Perl
source. Initial review failures and acquisition boundaries remain explicit.
Full transitive/native custody23.4.2, registration23.4.1, general compatibility
scaling/isolation and full23.4 admission are separate. P3 Dart formatting73.8 is
next before full23.4; [[perl-count-copy-rejection]] retains the earlier repair.
