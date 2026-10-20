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
  - "why does Perl drop_keys ignore flat_array keys"
  - "why can a later drop key callback change an earlier key"
  - "why can a later numeric operand change an earlier value"
  - "can Perl numeric comparison receivers continue into cat"
date: 2026-10-20
status: bounded Perl value/numeric/drop repairs; full inventory pending
tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]
evidence: "TYPE-REFERENCE-BOOK.1.2.3-.6 retain accepted public epochs and producer/input custody. Drop6 owns list evaluation, warning/FATAL loading and exact historical recurrence; numeric5 owns scalar dispatch/snapshots."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-drop-generated/publish_final.py"
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

CodeblockRuntime uses Numeric::scalar_helper_name/arity_is_valid/evaluate for
scalar names/aliases, preserving kinds and skipping invalid-arity effects. Numeric
receiver shapes/terminals validate before effects, including mixed chains. A saved
comparison may start a new expression. MethodLowering emits complete undef for
invalid shapes instead of Perl fallthrough; numeric lists snapshot each term.

Deferred aggregate reducers and array min/max remain unknown_helper, owned by
TYPE-REFERENCE-BOOK.1.2.7 after generated-drop .1.2.6. Boolean body literals still
lose their kind under [[perl-codeblock-boolean-literal-kind-drift]] / startup35;
typed callback parameters preserve it. Unicode numeric coercion remains startup20.
No all-helper or cross-backend admission follows from this scalar repair.

Perl drop_keys materializes each key operand, lowers explicit flat splices and
typed shapes, then deletes a private key list from a copied harray. Scalar keys
load without the old slice advisory under normal/FATAL syntax profiles; a later
callback cannot change an earlier key. Source-kind execution errors and null-key
uninitialized diagnostics remain. No portable reference-key coercion is admitted.
The accepted failure, rejected shape/review preparations and actual fault controls
survive in docs/checkpoints/type-drop-generated/.

Numeric5 separately qualifies prior4's original retained-log context and adds a
complete-input accepted-source replay; observations are never refreshed silently.
Earlier value/Phase0 adjudications remain under type-evaluated-values/. Full old
card bytes survive at accepted203cde315; the July4 inventory at c053c9dcf and its
proposal capsule already listed substr and scalar/array/hash/number receivers.
Those dated, partly retired spellings guide navigation; current enumeration .1.2.1
follows aggregate7, before book mapping/layout. No complete per-type admission.
