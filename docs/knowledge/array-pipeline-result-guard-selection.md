---
id: array-pipeline-result-guard-selection
title: Pure Array-pipeline results need retained-kind consumer ownership
answers:
  - "why does Perl trim_each result set_key raise Not a HASH reference"
  - "why do literal Array pipeline receiver chains retain DSL and unresolved helpers"
  - "which task owns split_each trim_each filter_nonempty lowercase_each uppercase_each uniq filter_match result guards"
  - "do needed Array pipeline source and delimiter errors already propagate on Perl"
  - "are direct pure pipeline values and standalone named writeback already implemented"
date: 2026-11-10
status: original36 frozen; Perl source79.0 focused-checked; result79.1.1 next and peers independent
tags: [array, pipelines, results, guards, perl, selection, recovery]
evidence: "Historical selection TYPE-REFERENCE-BOOK.1.2.23.1.39; docs/checkpoints/array-pipeline-result-selection-2026-11-10/REVIEW.md retains original36/17 failures/19 healthy,29 ready and7 unresolved receivers,36 module-handler pairs, first readonly0/empty stderr/eleven effective controls. No production or peer verdict."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-pipeline-result-selection-2026-11-10/review.py"
---

Original public Get/descriptor/substitution/native/full emitted-fresh36 exposes
seventeen Perl gaps: seven free plus three later-tail pipeline Arrays reach an
unguarded nonempty-reference Hash copy and raise Not a HASH reference; seven
literal receiver chains retain DSL and fail handler/module compilation. Those
seven descriptors are ready0/unresolved1 naming their own helper. Other29 are
ready1/raw0/fallback0/unresolved0; eligibility is not execution or compilation.

The constructor oracle has a HASH-kind check and persistent rejection flag; actual
pipeline substitutions do not. MethodLowering.pm ordinary Array-transform roles
at _ordinary_array_transform_result_call and retained/copy/logical/with routes
cover family78 but omit these seven pipelines. Existing pipeline producers/private
value helpers already work. Family79 owns only canonical ordinary result guards;
no producer rewrite or new source policy follows from this selection.

Nineteen healthy controls retain compatible free/receiver results, selected String/
Number kinds, source-once/snapshot order, empty-with, pure-value source preservation,
standalone writeback and all four source/delimiter error frames. The old catalog
warning against every direct pipeline value is stale; ordinary values are already
implemented. Compact I.return split and implicit child-push caveats remain separate.
See [[array-helper-return-shape-caveats]] for those historical distinctions.

First readonly0/empty stderr/eleven corruptions recovers exact original own source/
grammar/instrument bytes/modes/Git, full metadata/values/errors/warnings and absent
fresh fields after failed load, all36 actual module/handler pairs and unchanged
authored targets. Modules precede fresh loading; public Get constructs native
handlers internally, captured before execution. Every peer must independently
acquire own source/arity/errors/earlier-owner policies before production. Full
native/cache/transitive/toolchain custody4.2/SESSION5, general isolation/source/
context/registration/declared5.4/full23.4 admission remain separate.

Independent Perl79.1.0 later acquires184 programs/148 full profiles/180 actual
artifact pairs and reproduces the shared17 failures. Fourteen literal Number3
free/receiver cases additionally read localized main::3; computed {3} under the
same seed stays empty. P1 source79.0 precedes result79.1.1. A composed receiver
needed-delimiter error also fails compilation while its terminal producer works;
that eighteenth composition target stays separate from source isolation. First
readonly0/ten controls passes. See [[perl-array-pipeline-source-preflight]]. This
original selection's error whitelist is an explicit projection; omitted older
public fields remain unknown rather than receiving retrospective credit.

Source79.0 is now bounded/focused-checked: shared Number fence,166PASS/private14RED-qualified166PASS/direct195 and first qualified readonly0/twelve controls. All original36 records/artifacts and the extra receiver-error target remain unchanged; result79.1.1 is next. Four original preparation failures stay preserved and receive no passing credit. See docs/checkpoints/array-pipeline-source-perl-2026-11-10/REVIEW.md.
