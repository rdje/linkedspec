---
id: perl-generic-flat-runtime-values
title: Perl generic flat evaluates typed container arguments once before list splicing
answers:
  - "why does generic flat meta fail while flat_hash meta works in Perl"
  - "does flat support a function parameter or nested container read"
  - "why did flat copy items leak a host copy call"
  - "how does Perl flat preserve runtime array and harray kinds"
  - "which tests cover generic flat in native and generated parsers"
date: 2026-09-27
status: verified Perl repair; native and fresh emitted routes
tags: [perl, actionir, flat, arrays, harray, typed-bindings, generated-source]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6 follows clean constructor commit 0b0cccf52 at the director's request. Fifteen public Get/substitution probes distinguish failing runtime-held containers from working literal and explicit-helper controls. The repair makes every probe match its expected result. The expanded native/fresh emitted constructor subtest covers bound and computed arrays/harrays, pure function parameters/locals, empty containers, nested reads, repeated calls, typed elements, single evaluation, detachment and ordinary nesting; six direct-dependent suites pass 120 top-level tests. Complete Phase0 passes 1033/1033 in 1040 seconds; final regression is 164 assertions and old-module preload fails 31. Exact commands and hashes are in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6-verification.json."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t t/uniform_binding_contract.t t/variadic_user_function_contract.t t/actionir_ast_parser.t t/trace_actionir_method_lowering.t t/trace_emit_context_bridge.t; env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/phase0_regression.t"
---

Before repair, `meta = {"existing":1}; return(hash(flat(meta), "added", 7))`
returned null through public Get. Replacing `flat` with `flat_hash` returned the
expected object. Bound arrays similarly leaked an unresolved host `flat(items)`
call into `array(...)` and `[...]`; `flat(copy(items))` leaked a host `copy` call,
and nested reads left authored indexing in host source. Literal array/harray
arguments and explicit helper controls worked.

The source owner is `perl/LinkedSpec/ActionIR/MethodLowering.pm`:
`lower_flat_list_value_expr` selected array/harray lowering from source shape.
It had no general runtime-kind dispatch for scalar-held or computed values.
`lower_ast_aggregate_call_node` now lowers the typed argument AST once, stores its
value in one host temporary, then exposes array elements or harray key/value
pairs in the enclosing list context. Known legacy aggregate slots retain their
compatibility route. The additional baseline-confirmed capture-slot defect is corrected by routing
IMATCH_LIST/LMATCH_LIST and IMATCH_HASH/LMATCH_HASH through existing explicit
helper lowering; these are private compatibility names, not new authoring syntax.
Plain primitive source forms retain their old handling;
runtime non-container/undefined bindings contribute no members, matching the
explicit helper guard and the previous absent-binding control.

Hash constructors route their generic flat argument through that same typed AST
path. They must not reconstruct a computed flat argument with already-lowered
host code and feed it back into a DSL parser. Explicit flat_array/flat_hash
compatibility remains unchanged.

`t/generated_source_contract.t` executes the regression in native Get and fresh
emitted parsers, twice per input sequence. The matrix includes assignment-valued
arguments with a counter proving single evaluation, a later nested source write
proving independence for DSL mutation, and ordinary/copy values remaining nested.
The exact book source `examples/flat-bound-values.spec` runs with LF and CRLF.
Public entry_groups/entry_named_map containers also run natively and freshly
emitted; public substitution verifies all four private capture slots against
explicit helpers. The original Phase0 attempt was stopped after that extra
baseline finding and does not count as proof.
`t/actionir_ast_parser.t` gives flat deliberately false source fields and checks
that the typed binding and runtime harray dispatch survive.

Related: [[perl-uniform-binding-runtime]], [[perl-hash-constructor-nested-values]],
[[spec-language-readiness-grammar-foundations]]. This is a Perl correctness repair,
not a new helper, whole-format claim, or activation of the structured-text campaign.
