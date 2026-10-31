---
id: dart-canonical-set-result-guards
title: Dart canonical set results use current actual-kind source guards
answers:
  - "which Dart owner guards canonical set result methods"
  - "does Dart canonical set already support direct bracket reads"
  - "does Dart selected set Bool already skip incompatible operands"
  - "how does Dart retain assignment alias provenance"
date: 2026-10-31
status: bounded Dart59.3 targeted-checked; Julia/safe Lua/full admission separate
tags: [dart, set, assignment, selection, fluent, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.59.3; set-result-dart-intake.json.gz retains unchanged13 tests11healthy2RED to13GREEN, push12/fatal analysis/new-normal format and actual producers/inputs."
reverify: "From dart/: bash ../tools/run_dart_project_data.sh test test/set_result_composition_test.dart test/push_result_composition_test.dart"
---

Ate1b697720 full12/direct reads/order/functions/with/codeblock/RHS errors and
selected Bool guard already work. Direct Array and selected String Hash consumers
retain values/evaluate KV. _isCanonicalSetResultSource now admits exact two
positional args/plain target/canonical sourceMethod and recognized RHS to current
direct/computed kind guards. Bare/numeric RHS already valid; alias sourceMethod
remains excluded. Original setter/default/push/copy/alias/function/arity/parser/
schema and remaining interpreter exact.

Same13 tests11healthy/2RED to13GREEN native/restored SpecFile/generated-plan;
push12 yields25 non-skipped completions, changed-owner/new-normal fatal analysis/
new-normal format0. Eleven values/error/eight public source shapes retained; nine
healthy values/all errors/shapes exact. Completed read control does not import
Perl/Rust named-default guard policy; wider defaults/free-source scope stays
owned separately. Rebuild apps/runtime; Julia59.4 next, no whole-file SDK-format/
isolated emitted/package/exhaustive excluded-shape/portable-domain/full admission.
