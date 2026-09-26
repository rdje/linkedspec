---
id: perl-numeric-reducer-direct-read-rejection
title: "Perl sum and avg consume array values after source-shape rejection repair"
answers:
  - "why does sum(document[items]) return null on Perl"
  - "does Perl sum accept a direct-access array receiver"
  - "which task repairs numeric reducer direct-read composition"
  - "why does sum of a Perl function array parameter return null"
  - "which numeric reducers rejected direct reads and function parameters"
  - "why did sum of a scalar integer return zero on Perl"
date: 2026-09-26
status: verified repair SESSION-STARTUP-READING.91
tags: [perl, numeric, arrays, direct-access, lowering, SESSION-STARTUP-READING]
evidence: "Startup91 final native/fresh generated matrix covers152 cases and passes focused128 across seven suites. Exact clean49678 lowering fails only the new top-level group10. Public substitution verifies all six selectors once; sixty baseline/candidate Get rows isolate sum/avg spelling rejection. Numeric primitive fast paths now reject digit-only names. Complete Phase0 passes1033/1033; docs/checkpoints/SESSION-STARTUP-READING.91-verification.json owns final acceptance."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t t/scalar_numeric_contract.t t/uniform_binding_contract.t t/variadic_user_function_contract.t t/actionir_ast_parser.t t/trace_actionir_method_lowering.t t/trace_emit_context_bridge.t; env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/phase0_regression.t"
---

## Historical intake before .91

With `document = {"items":[3,1,2]}`, all three measured spellings return null:
`sum(document["items"])`, `num_sum(document["items"])` and
`document["items"].sum()`. The literal twin `sum([3,1,2])` returns6.
Assigning the direct read to `selected` before `sum(selected)` also returns null.
The explicit `document["items"].sorted().sum()` control returns6 on both versions.
This failure predates the read-purity repair; it is not a guarded-read regression.

MethodLowering's AST aggregate bridge eventually reaches its compatibility
`num_sum` arm. That arm accepts only sources which the array-spelling classifier
or internal pipeline lowerer recognizes, before attempting normal value lowering.
FlowExpr's classifier accepts named arrays and known array-producing calls but
rejects direct-access syntax. The resulting unsupported-helper sentinel evaluates
to undef without a runtime context error. Static source spelling prevents the
runtime reducer from seeing a valid array value.

Startup `.91` owns the bounded correction after function constructors `.90` and
before `.51`, including fresh emitted execution and single-evaluation controls.
Audit other reducer arms at activation instead of assuming the whole family fails.
No `.91` implementation or full-family acceptance is claimed in `.89`.

On 2026-09-25, `.90` also verifies `fn total(items) { return(sum(items)) }`
called with `[3,1,2]`: both clean `83ab2ff44` MethodLowering loaded explicitly
from a repository-local shadow and the constructor candidate return null with
the same `num_sum` unsupported-helper sentinel and no handler error. This is an
existing function-parameter case for `.91`, not a constructor regression.
The exact source, loaded owner identity and observations are retained in
`docs/checkpoints/SESSION-STARTUP-READING.90-verification.json`.

## Repair in .91 (2026-09-26)

The sixty-case clean49678 Get/dump audit narrows source-shape rejection to
`sum` and `avg`. `median`, `range`, `min` and `max` already accept the same
array literal, direct-read, bound-value, function-parameter and function-result
sources. The two repaired compatibility arms now lower the argument before
the existing runtime ARRAY check. FlowExpr and all six arithmetic algorithms
are unchanged, as are the neutral and generated formats.

The wrong-kind audit also finds `sum(3)` ->0, with `@3` visible in public
`call_spec_handler_subst` output. All six reducer binding fast paths used the
legacy word regex, which admits digit-only names. Their fast path now requires
an ASCII identifier, leaving primitives on ordinary value lowering.
The runtime ARRAY check produces null for a scalar primitive. Actual named
aggregate bindings retain their existing optimized behavior.

The final fixture exercises all six reducers through native and independently
loaded emitted parsers twice: aliases, direct/receiver reads, literal and derived
bindings, function parameters/locals/results, array chains and scalar composition,
empty/missing/null/wrong-kind/nonnumeric/numeric-string inputs, booleans and single
array literals. A numeric selector increment and public tied-selector substitution
verify single evaluation and unchanged source containers. The initial selector
fixture incorrectly used an array-index expression against a hash; actual emitted
ARRAY guards identified the mistake, and the fixture now uses an array receiver.

`examples/numeric-array-values.spec` is the exact mdBook include, tested with LF
and CRLF. `array(3)` itself remains an independent constructor defect: `.94` owns
its repair after `.93` and `.92`, before `.51`; use `[3]` meanwhile. The constructor
failure is not a reducer acceptance result or a consequence of this patch.

Strict result-kind evidence is separate: [[perl-numeric-reducer-string-result-kinds]]
owns the array min/max and odd-median numeric-string defect under `.95`. The
constructor cause and required `.94` repair are indexed by
[[perl-single-numeric-array-constructor]].

Capture compatibility guard: `ValueExpr` deliberately excludes `IMATCH_LIST` and
`LMATCH_LIST` from reserved ARRAY names. The numeric binding guard must enforce
identifier syntax only and leave that authority to the existing name extractor.
An earlier91 candidate's additional general reserved-value check regressed all six
`IMATCH_LIST` reducers despite a complete Phase0 pass; that candidate was rejected.
Final proof includes public `entry_groups()` and raw capture-array native/fresh
controls plus both capture arrays through public substitution. The corrected
candidate requires its own complete Phase0 pass; earlier passing evidence does not
transfer to a changed source hash.
