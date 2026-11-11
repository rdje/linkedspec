---
id: array-pipeline-callable-result-selection
title: Registered-function pipeline receivers need guarded and ready composition
answers:
  - "why does supply result trim_each set_key retain authored DSL on Perl"
  - "can a correct callable pipeline value still have an unready descriptor"
  - "which task owns registered-function pipeline receiver result guards"
  - "does Perl computed filter_match pattern execute a DSL block"
  - "which callable pipeline selection fixture is safe for Lua"
  - "how was the original callable pipeline pattern assumption qualified"
date: 2026-11-11
status: qualified selection23.1.40 frozen; callable79.6 owned; no production repair yet
tags: [perl, functions, array, pipeline, guards, readiness, qualification]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.40; docs/checkpoints/array-pipeline-callable-selection-2026-11-11/REVIEW.md retains original39/separate41/shared safe37,16 targets/25 healthy including five readiness-only targets, original37 full records/artifact pairs exact, all39/41 source pairs, first readonly0/empty stderr/thirteen controls and current source/grammar/instrument identity PASS."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-pipeline-callable-selection-2026-11-11/review.py"
---

At clean7955c16c, pure registered fn supply(seed) returns compatible Arrays through
terminal/free-helper pipelines. Seven receiver pipeline Hash consumers nevertheless
retain DSL in actual public handlers and fail compilation. Additional copy/logical/
needed-error paths fail. MethodLowering.pm's ordinary_array_pipeline_result_chain
explicitly excludes registered-function receiver calls before common guards.
The existing function MVP allows compatible receiver composition; this is a
bounded implementation gap, not new syntax or a function-registration failure.

Qualified41 has16 targets: eleven execution/error failures and five matching
value/error cases with unresolved metadata. The latter are trim_later_with,
three initial-kind compositions and invalid_range_receiver_composed. Six selected
action-rewriter fields distinguish readiness from execution. A correct null or
regex error alone is not acceptance. Family79.6 owns both; each peer independently
acquires its own policy, error framing and actual SDK routes before production.

Original39 includes two incorrect eager computed-pattern expectations. Published
filter_match requires a regex operand; the actual Perl handler matches escaped
block source as text, so its terminal returns[] without running that block. The
original sources/observations/assessment remain unchanged and receive no product-
RED credit. Separate41 keeps exact original37 supported questions and adds four
balanced invalid-range literal controls. All37 full observed records/source pairs
are exact after physical artifact path-prefix adjustment. Initial Number/null/
Hash terminal pairs observe[[],[]]; this is current Perl, not a peer source policy.

Safe shared37 excludes every malformed native pattern. Perl-specific41 must not
be run on unsafe Lua; native formatter repair remains LUA-STARTUP-READING.2.3 and
declared5.4 stays separate. No first-class regex value or eager computed-pattern
permission is inferred. Distinct caller/parameter names avoid known caller
shadowing32, still separately owned rather than accepted as a source policy.

All first own source/grammar/instrument inputs and actual module/handler bytes
precede SDK use/loading. Full observed error fields/classes/values/warnings and
absent fresh fields survive; metadata scope is the six named projection fields.
Context-free call_spec_handler_subst lacks the source function registry and is
diagnostic only. Fresh packages share the Perl process. First readonly/thirteen
corruptions and current source/grammar/instrument identity pass. Historical input
recovery is independent of the latest SDK. Full native/cache/transitive/toolchain
custody4.2/SESSION5, source/context/isolation/registration/declared5.4/full23.4
remain open. Perl intake79.6.1.0 now separates P1 arity79.6.1.1 before result79.6.1.2; see [[perl-callable-pipeline-intake-and-arity]].
Related: [[array-pipeline-result-guard-selection]], [[terse-user-defined-functions-mvp-contract]].
