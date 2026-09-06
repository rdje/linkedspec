---
id: perl-emptiness-expression-and-host-slot-drift
title: "Perl emptiness lowering treats quoted zero differently from a bound value and reads host slots for literals"
answers:
  - "why does is_empty quoted zero differ from a variable holding zero"
  - "why does is_empty numeric zero depend on the Perl program name"
  - "which repair owns Perl emptiness expression and host slot drift"
  - "why does a numeric literal lower to a Perl capture variable in emptiness checks"
date: 2026-09-06
status: confirmed defect; repair SESSION-STARTUP-READING.16 follows required reading
tags: [perl, actionir, emptiness, literals, host-state, diagnostics]
evidence: "SESSION-STARTUP-READING.3.2.21 public Get/call_spec_handler_subst controls; FlowExpr.pm _lower_is_empty_expr and ValueExpr.pm _extract_scalar_symbol_name; value-container-flow-helper-reference.md explicitly preserves quoted zero as data."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -e 'for my $e (q{is_empty(}.chr(34).q{0}.chr(34).q{)},q{is_empty(value)},q{is_empty(0)}) { print LinkedSpec::call_spec_handler_subst(q{Top}, q{if(}.$e.q{) { return(1) } else { return(2) }}), chr(10); }'"
---

Two related defects were confirmed without changing production code. The public parser source was:

```text
Top:
 /x/ -> Top { value = "0"; if(is_empty("0")) { return("empty") } else { return("nonempty") } }
```

On input `x`, literal `is_empty("0")` returns `empty`; replacing only the argument with `value` returns
`nonempty`. Literal empty string returns `empty` as a control. All four tested public parsers construct and run
without `last_error`. The book's value/container/flow reference at the explicit nonempty guard says to preserve
string `"0"` as data, and the binding path does so.

`FlowExpr::_lower_is_empty_expr` handles scalar symbols with explicit undefined/string/array/hash checks, but
its general-expression fallback emits Perl `!($lowered)`. Quoted `"0"` therefore takes host falsehood instead
of the documented emptiness predicate; `is_nonempty` negates that same result.

Numeric `is_empty(0)` has a separate cause: `ValueExpr::_extract_scalar_symbol_name` accepts any `\w+` token.
The emptiness lowerer asks it before lowering literal values, so generated code reads `$0`. The **same compiled
public parser** returns `empty` with process-local `local $0 = ''`, then `nonempty` with `local $0 = 'program'`.
This proves a runtime dependency on host program-name state. Source controls also emit `$1`, `$true`, and `$undef`
for literal tokens `1`, `true`, and `undef`; only the numeric-zero program-name dependency was runtime-seeded.

Repair `SESSION-STARTUP-READING.16.1` owns a single evaluated-value emptiness predicate and expression-shape
equivalence. `.16.2` owns typed literal classification/scalar-name recognition and direct-consumer regression
coverage. Both follow full codebase/mdBook/policy reading and precede mutation setup. Acceptance includes exact
once-only evaluation, inverse helper behavior, generated/loaded routes, host-state independence, and mdBook sync.
No other-backend failure or completed repair is claimed.
