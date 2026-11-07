---
id: perl-array-transform-result-guards
title: Perl Array-transform results retain kind guards and original first-producer permission
answers:
  - "how do Perl take slice sorted reversed concat results reject Hash consumers"
  - "why must Array transform source permission run before result-kind guards"
  - "does rejected Array result copy logical with work stay skipped on Perl"
  - "which Perl Array result arities are guarded without variadic promotion"
date: 2026-11-07
status: bounded Perl78.1.1 repaired and focused-checked; independent peers/full23.4 separate
tags: [perl, array, transforms, results, guards, source, composition]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1; docs/checkpoints/array-transform-composition-perl-2026-11-07/REVIEW.md retains unchanged37/original123/own52,19RED to212PASS, direct3files490PASS, exact private19RED/restored212PASS and first readonly0/seven effective corruptions. All193 healthy projections/175 policies and matching212 module-handler pairs agree; source78.0 fences remain."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-composition-perl-2026-11-07/review.py"
---

The missing ordinary Array-result role previously reached unguarded Hash copying
or retained literal DSL despite ready metadata. Selected canonical free/receiver
forms now retain actual-kind dispatch and rejection through later copy, logical
and immediate with links in `perl/LinkedSpec/ActionIR/MethodLowering.pm`.

Only take/take_last/drop_front/drop_back source[,n], slice source/start[,n],
sorted/reversed free-one/zero-extra and concat_arrays free-two/receiver-one join
this role. Direct list-splice arguments and unsupported contexts stay outside it.
An initial receiver producer runs its original terminal lowering first; a prior
constructor/copy/view/size/Hash-result owner retains its existing guard instead.
Free Array results also block initial Hash-helper permission, preventing a later
set_key from readmitting unguarded copying. No first-source policy is normalized.

Own175 source/prefix/host/arity/error profiles and193 before-healthy observations
stay exact. Source78.0's Number fences, producer once/snapshots, nested kinds,
needed errors and valid empty with survive. The original source/target37 fixture
is unchanged. Direct source and Hash artifacts occupy new explicitly owned
folders beside their original fixture families; all older proof files remain
unchanged. Exact old/current private images reproduce19RED/212PASS.

The original Python edit producer emitted a literal-escape warning. Its source
and SDK epochs remain unchanged; a separate raw-string spelling has identical
Python AST and zero compile warnings. This qualification does not rerun the
mutation or claim complete mutation-command outer channels. Full native/cache/
transitive/toolchain custody4.2/SESSION5 and context/portable/registration/full23.4
remain separate. No peer input policy or defect verdict follows.
