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
date: 2026-10-20
status: current value model and bounded Perl repair; full method inventory pending
tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]
evidence: "TYPE-REFERENCE-BOOK.1.2.3 retains the accepted-runtime RED and native/generated23 GREEN, complete test-input supplement and six effective source inverses. The first oracle, candidate and incomplete supplied test context remain retained; a saved-binding control and existing copy-on-write contract justify the corrected expectation."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-scoped-with/publish.py"
---

# Current value model and evaluated-value boundary

Uniform bindings hold scalar, array, harray or codeblock. Integer/real notation
does not create separate binding namespaces. String, number, boolean and null
remain distinct primitive values. Scalar numeric comparisons yield numeric 1/0;
logical helpers yield booleans. False normalizes to "0" for scalar text and can
pass through generic with as false. The July4 terminal-boolean statement is dated.

Deferred codeblocks use current caller slots; eager blocks execute immediately.
A called codeblock's array result may feed sorted(). That establishes an array
operation on the result, not a separate codeblock method table.

Perl now materializes each emitted list operand before later operands execute.
Array/harray literals and constructors, dynamic hash keys and callable arguments
retain earlier reads across later assignments or calls. A private list temporary
preserves explicit flat splices and scalar kinds without adding a deep copy.
The source owner is MethodLowering::_materialize_list_operand_expr; AST-to-DSL
source rendering and deferred-body interpretation remain unchanged.

The first push question wrongly treated late slot observation as shared-reference
mutation. Independent saved-binding controls and [[perl-uniform-binding-runtime]]
show copy-on-write: push produces an updated binding while the earlier value
stays old. The rejected oracle and first candidate remain intact; the corrected
accepted-runtime baseline rejects19 cases, the candidate matches all23, and six
actual source inverses reject and restore. Host identity controls are separate
and do not establish general DSL alias/deep-copy parity.

Scoped callable with is repaired under .1.2.4; [[perl-generic-final-codeblock-normalization]] owns its local vocabulary/frame mechanism.
Remaining Perl limit: num_add inside a deferred body reaches unknown_helper (.1.2.5).
[[perl-codeblock-boolean-literal-kind-drift]] remains owned by startup .35;
explicit boolean arguments avoid that separate literal defect in this repair.

The complete original Phase0 run retains140 source-spelling assertion failures
and one wrong-invocation volume failure; the temporary fixture cleanup passes.
Separate source-bound historical/manual fixtures retain130 value goldens and
two explicitly attributed compiler advisories. Their values are independent
of the candidate lowering producer. Public descriptor/Get succeed quietly for
single-key drop_keys; generated loading warns, and a caller fatal syntax
profile rejects it. Actual emitted delete @__ls_drop{"debug"} maps to the
MethodLowering drop_keys producer. TYPE-REFERENCE-BOOK.1.2.6 owns the separate
repair after .1.2.4/.1.2.5 and before full enumeration. No warning gate changes.

The complete July4 table, including later-retired spellings, is retained in the
accepted c053c9dcf Git version and the inventory docs-proposals capsule. It already
listed substr and the scalar/array/hash/number receiver families. Treat it as
dated navigation. Current full operation/spelling enumeration is still owned by
TYPE-REFERENCE-BOOK.1.2.1; no exhaustive method, backend or reference admission
follows from this bounded repair. Full evidence/limits are under
docs/checkpoints/type-evaluated-values/.
