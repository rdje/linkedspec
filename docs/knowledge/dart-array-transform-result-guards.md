---
id: dart-array-transform-result-guards
title: Dart ordinary Array-transform results retain guards without changing initial source policy
answers:
  - "why does Dart take result set_key run its operands"
  - "which Dart dispatcher guards take take_last drop_front drop_back slice sorted reversed concat_arrays results"
  - "what are Dart initial Array-transform Number null Hash and optional arity policies"
  - "does Dart concat_arrays preserve a scalar or Hash first source"
  - "do Dart Array-transform guards preserve needed errors and earlier result owners"
  - "how does the Dart Array-transform private old current source inverse work"
date: 2026-11-10
status: Dart78.3 bounded guards focused-checked; independent Julia and Lua/full admission remain
tags: [dart, array, transform, results, guards, source, arity]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.78.3; docs/checkpoints/array-transform-result-guard-dart-2026-11-10/REVIEW.md retains unchanged37 plus104 own controls,19 original failures/122 healthy,141/four routes PASS, private19RED/141PASS, direct292,108 exact profiles/141 parsed-module pairs, first readonly0/empty stderr/eight corruptions PASS."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-result-guard-dart-2026-11-10/review.py"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded --concurrency=1 test/array_transform_result_guard_composition_test.dart test/with_hash_results_test.dart test/hash_value_result_guard_composition_test.dart test/hash_view_result_guard_composition_test.dart test/constructor_result_composition_test.dart"
---

At clean155f5f644, independent four-route acquisition exposes nineteen selected
failures: both free and receiver transform results reach set_key, retain the
Array and run KV; three later tails run KVW/KVDW. Constructor rejection already
works. ActionFluentChain's kindGuardedSource classifications omit these ordinary
transform roles before _evaluateFluentCallsWithValue's persistent actual-kind
guard. This is Dart's own outcome, not the Perl or Rust failure shape.

Only canonical positional take/take_last/drop_front/drop_back source[,n], slice
source/start[,n], sorted/reversed free-one/receiver-zero and concat_arrays free-two/
receiver-one qualify. An initial receiver permission preserves its source fallback
only without an earlier retained/constructor/copy/size/view/Hash/Array-result owner.
The resulting Array owns later guards; incompatible Hash consumers reject before
operands and skip copy/logical/with tails. Source producer bodies, scalar Boolean
boundary and emitted/serialized formats are unchanged; the complete source diff
contains only119 inserted lines.

Own104 controls precede production: seventy-two initial Number/null/Hash profiles,
ten optional forms, sixteen excluded extra-arity profiles and six earlier owners.
Seven source families yield empty Array, with count0/W; concat_arrays preserves
the original source as an element, with count2/W. Optional take/drop defaults1;
slice keeps its remaining tail. Free sorted/reversed extras stay unevaluated;
the other observed extras keep their effects. Earlier owners retain their own
skips/effects. All four shared needed source/count errors already propagate with
complete native/restored diagnostics and generated-plan/fresh framing. These are
finite source-preservation fences, not new portable source/arity authority.

Unchanged141 and final formatted four-route replay pass. Every122 healthy result,
108 full profiles and141 actual parsed/module pairs remain exact. Same-path private
SDK old/current images reproduce19RED/141PASS with resolved routing checked before
use and exact original/repaired frames. Direct292/scoped fatal analysis/format,
first readonly recovery0/empty stderr and eight effective corruptions pass.

Own source/grammar/instrument bytes precede SDK use; emitted/parsed artifacts
precede fresh loading, with complete channels retained. Rebuild Dart applications.
Full native/cache/transitive/toolchain custody4.2/SESSION5, general isolation,
broader source/context/registration and full23.4 remain separate. Julia78.4 owns
its own independent next assessment. Related: [[array-transform-result-guard-selection]],
[[dart-hash-value-result-guards]], [[rust-array-transform-result-guards]].
