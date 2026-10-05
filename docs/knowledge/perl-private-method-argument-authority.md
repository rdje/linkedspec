---
id: perl-private-method-argument-authority
title: MethodExpr retains exact CSV returns but publishes no argument occurrence frames
answers:
  - "how does MethodExpr preserve original CSV argument object identity"
  - "where must MethodExpr argument occurrence coordinates be recorded"
  - "does MethodExpr currently publish private argument source frames"
  - "how are dropped empty CSV arguments mapped to original source"
  - "can copied or foreign parser results borrow argument source authority"
date: 2026-10-05
status: private CSV/parser bridge verified; recursive Flow consumption owned
tags: [perl, actionir, methodexpr, csv, source-provenance, identity]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0 retains4141 regular immutable Git inputs/two exact runtime overlays, four guarded commands, ten literal cases/23 arguments/three seeds,14 controlled callback records, seven suites124 groups and23 distinguishing RED evidence controls."
reverify:
  - "After final bridge acceptance: bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1-review.py"
  - "At frozen2fd4e499e68f19d6a481662f46c4e24a1c0896a1 replay original .1.3.2.0-review.py; do not refresh its unchanged-producer guard after bridge changes."
---

# Argument authority begins at original producer boundaries

At clean 6ce479842be85219990be889914f354f1a4aaa44, MethodExpr's parser trims
the expression, obtains a length-preserving helper-pattern view, and extracts
the original parenthesized payload. It calls its actual CSV splitter once with
that payload and method context; receiver context adds a leading dot. The
returned hash retains the exact CSV-returned object as `args`, even if a
controlled callback supplies a copied array, changed values, foreign-source
array or opaque hash. Success preserves caller `$@`; callback exceptions and
nested callback order remain unchanged. There is no private argument frame
publication at this boundary.

CSV tracks original piece boundaries, trims original slices, and omits empty
trimmed pieces. A returned argument index therefore differs from its original
CSV slot index. Repeated equal arguments remain distinct occurrences. Helper
pattern masking preserves original coordinates; argument values come from the
original payload, including regex punctuation, Unicode and CRLF. Existing
numeric slash interpretation and receiver context must remain intact.

The diagnosis uses independent cumulative literal intervals. Its23 authored
argument positions are expectations for the next implementation, not frames
already published by the current parser. Full ordinary and observed parser
results, exact callback inputs/results and actual returned references agree
across three hash seeds. Flow retains marker-first traversal followed by inline
arguments; copied parser results preserve ordinary events, while changed and
foreign callbacks preserve their existing different values and event population.

Implementation child `.1.3.2.0.1` now implements invocation-local CSV and parser sidecars.
CSV must publish at actual flush boundaries; parser must translate through its
original leading trim and payload base. Collectors select the actual returned
array/hash and exact source by identity and value, align by retained occurrence,
and decline copied/foreign/opaque or changed entries without altering their
ordinary returns. Nested collection restores the outer invocation. No long-lived
cache, equal-text search, new dependency callback or public result field is
authorized. `.1.3.2.1` then consumes verified frames for recursive Flow scans.


The bounded bridge implementation under `.1.3.2.0.1` now publishes CSV frames
at its original flush boundaries and translates them through the parser's
original leading trim/payload base. Both wrappers retain the actual callback
return and reject copied/foreign/opaque authority. Parser source/method fields
and original argument-array identity must remain exact; a changed argument
entry declines individually. Nested collection restores the outer recorder and
OwnerDispatch preserves successful caller error state. Final immutable nine-suite consumer/Phase0 proof passes1173 groups, with138
actual parser/CSV frames under three seeds,23 evidence controls and18 rendered
book examples; the diagnosis above is historical at
6ce4798 and is not an unchanged-current-production replay after this change.
