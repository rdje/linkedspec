---
id: perl-callable-value-conditional-execution
title: Perl callable value if preserves lazy selected payloads
answers:
  - "why did deferred return if fail unknown helper else"
  - "how does Perl callable value if evaluate elseif and fallback"
  - "does callable value if preserve JSON false and null payloads"
  - "why do marker and attached tests no longer expect value if failure"
  - "how are raw value conditional TAP bytes preserved through whitespace checks"
date: 2026-10-03
status: current value executor; null-return while and literal kind remain separately owned
tags: [perl, callable, actionir, value, lazy, conditional]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3 native/fresh RED-GREEN, canonical substitution/AST and published PUC CLI comparisons."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3-review.py"
---

`CodeblockRuntime::_eval_call` previously evaluated all operands before resolving `if`,
so an unselected `else`/`elseif` wrapper or payload raised an unknown-helper error.
The private value dispatcher now validates typed branch order and wrapper arity first,
then uses governed truthiness to evaluate conditions once until selection. It evaluates
only the selected payload and returns its actual value, including typed false or null.
A no-match/no-fallback value is null. No source field is reparsed.

Canonical `MethodLowering::_lower_inline_if_value_expr` accepts one condition/payload,
ordered `elseif(condition,payload)` arms, and at most one final wrapped or plain fallback.
Existing optional leading bare scope labels on wrapper operands are mirrored. The
public `i`/`elif` value probe does not yield the canonical payload; this repair admits
only `if`/`elseif`/`else`. Statement-shaped malformed expressions remain unsupported.
Eager logical operands and attached/marker local-return boundaries stay unchanged.

The prior attached/marker matrices retain their exact value_excluded sources. Current
tests load the source-identical .5.3 success oracle; all older captures and producers
remain unchanged. The marker claim is historical at d0ab1140, attached at fd022815.
Use their current focused tests or this successor review, not old full reviewers on a
later runtime. Actual original x/rest slot/array/error identities and equal-value controls,
source-poisoned typed execution, selected effects and typed false distinguish the proof.
Six public PUC CLI comparisons agree on selected values/null; no backend admission follows.
Null-return spellings, while, boolean literal kind (startup35), function statement MVP,
metadata/readiness and dispatcher/full execution remain separate owners.

Raw prove output contains meaningful trailing whitespace. Six JSON envelopes retain its
exact bytes, lengths and pre-envelope proof hashes; the current read-only envelope checker
rejects eighteen corruptions. The raw output is preserved rather than trimmed.
