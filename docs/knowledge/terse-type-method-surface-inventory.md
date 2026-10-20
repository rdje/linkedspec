---
id: terse-type-method-surface-inventory
title: "Value kinds and Perl evaluated-value boundaries; dated method inventory"
answers:
  - "what receiver methods already exist in the terse type method surface"
  - "does string substr already work as a method"
  - "which helpers should remain function only or statement only"
  - "what did SPEC-FORMAT-TERSE.7.1 inventory"
  - "which method backfill leaf follows SPEC-FORMAT-TERSE.7.1"
  - "do block yielded values and user function returns have their own method table"
  - "why did a later callback change an earlier Perl array element"
  - "do Perl hash keys and callable arguments retain evaluated values"
  - "can Perl num_add run inside a deferred codeblock"
  - "does Perl drop_keys warn for a single literal key"
  - "why can a later numeric operand change an earlier value"
  - "can Perl numeric comparison receivers continue into cat"
date: 2026-10-20
status: current bounded Perl value/numeric repairs; full operation inventory pending
tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]
evidence: "TYPE-REFERENCE-BOOK.1.2.3-.5 retain accepted-source public routes, saved-slot controls and exact producer/input records. Numeric5 owns dispatch, operand snapshots and receiver validation; its checkpoint discloses preparation epochs, original test-context qualification and separate repair owners."
reverify: "bash tools/project_data_run.sh prove -q -Iperl t/scalar_numeric_contract.t"
---

# Current value model and bounded Perl numeric execution

Bindings hold scalar, array, harray or codeblock. Integer/real notation does not
create namespaces. String, number, boolean and null remain distinct values;
numeric comparisons yield numeric1/0 and logical helpers yield booleans. False
normalizes to text "0" and can pass through generic with as false. The July4
terminal-boolean statement is dated.

Deferred codeblocks use current caller slots; eager blocks run immediately.
An array yielded by a callable can feed sorted(), without creating a distinct
codeblock method table. Scoped callable with is repaired by .1.2.4;
[[perl-generic-final-codeblock-normalization]] owns its vocabulary/frame mechanism.

Covered Perl constructors, dynamic hash keys, callable arguments and the four
variadic scalar numeric producers materialize operands before later siblings
run. MethodLowering::_materialize_list_operand_expr preserves explicit flat
splices and scalar kinds. This does not add arbitrary deep copying. The earlier
push question wrongly conflated late reads with reference mutation; saved-slot
controls and [[perl-uniform-binding-runtime]] establish copy-on-write binding
updates. Original rejected oracles/candidates and their limits remain retained.

CodeblockRuntime delegates the admitted scalar numeric names and word/symbol
aliases to Numeric::scalar_helper_name/arity_is_valid/evaluate. Typed arguments
retain their kinds; known invalid arity skips operand evaluation. Numeric receiver
shapes and comparison terminals validate before receiver evaluation, including
mixed chains. A separately saved comparison result may start another expression.
MethodLowering rejects the same numeric shapes as complete undef expressions,
preventing literal Perl fallthrough. Ordinary numeric lists snapshot each term.

Deferred aggregate reducers and array min/max remain unknown_helper, owned by
TYPE-REFERENCE-BOOK.1.2.7 after generated-drop .1.2.6. Boolean body literals still
lose their kind under [[perl-codeblock-boolean-literal-kind-drift]] / startup35;
typed callback parameters preserve it. Unicode numeric coercion remains startup20.
No all-helper or cross-backend admission follows from this scalar repair.

Single-key drop_keys is quiet through descriptor/Get but generated loading warns
for delete @__ls_drop{"debug"}; a fatal syntax-warning caller rejects it. .1.2.6
owns that producer. Numeric5 qualifies the prior scoped-with retained test-log
context and adds a distinct complete-input accepted-source replay. No original
observation is silently refreshed and no warning discipline is weakened.

The complete old card is recoverable at accepted203cde315 and in the numeric
doc proposal. Earlier detailed value/Phase0 adjudications stay under
docs/checkpoints/type-evaluated-values/. The July4 method table, including later
retired spellings, survives at c053c9dcf and its proposal capsule. It already
listed substr and scalar/array/hash/number receiver families; use it as dated
navigation. Full current enumeration remains .1.2.1 after scalar5/drop6/aggregate7,
before book mapping/layout. Complete per-type reference coverage is not admitted.
