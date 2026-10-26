---
id: rust-coalesce-evaluation-drift
title: "Lazy default-selection boundaries on Rust and Perl"
answers:
  - "does Perl coalesce_nonempty return undef when all operands are empty"
  - "does Rust coalesce preserve a defined empty string"
  - "does Rust coalesce short circuit operand evaluation"
  - "does coalesce_nonempty skip later assignment effects"
  - "what does the coalesce_short_circuits native test actually assert"
  - "why do Perl and Rust coalesce disagree on empty aggregates"
date: 2026-10-26
status: bounded Rust defaults62.1/62.2.1-.2 repaired; Perl exhaustion62.2.3 and broad admission open
tags: [rust, perl, helpers, evaluation, startup-reading]
evidence: "Historical .3.3.22 paired controls; current .62.1/.62.2.1-.2 public fixtures and retained Rust regressions; Perl empty-tail root isolated through Get/substitution and owned by .62.2.3. Broad .62.3/.62.4 remains open."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test coalesce_lazy_values --test coalesce_nonempty_values --test coalesce_receiver_values"
---

Current62.1/62.2.1-.2: ordinary defaults and documented Rust nonempty receivers
share eval_coalesce_args/coalesce_accepts and evaluate only the needed prefix.
Reject undef, plus empty Scalar text for nonempty mode; preserve actual values.
Native/restored/generated-plan value/order/skipped-error fixtures pass. Aggregate
compatibility controls do not broaden the scalar signature; broad62.3/.62.4 stays open.

Perl exhaustion62.2.3 is immediate next: public helper/receiver controls ending in
empty text return "" instead of undef. call_spec_handler_subst confirms an
unconditional final operand in build_coalesce_nonempty_expr. The Rust all-empty
null oracle is retained; the book qualifies the current Perl defect.

# Historical September7 default-selection findings

At reading baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`, Rust's ordinary
call path eagerly collects operand values. Its lazy selector includes if/switch/while
and branch helpers, but omits both coalesce families. The `coalesce` helper additionally
requires `is_defined() && to_str() != ""`, so it skips defined empty text. Perl lowering
recursively nests ternaries: coalesce checks definedness; coalesce_nonempty adds `ne ''`.
Each evaluates only the needed prefix.

The public helper catalog explicitly promises first-defined, left-to-right short-circuit
coalesce selection. Its signature is scalar arguments. Aggregate results below are bounded
reference observations; repair `.62.1` must reconcile that boundary explicitly before
claiming normative aggregate admission.

## Historical September7 paired observations

Each body below uses this scaffold and input `xhello`:

```text
Top::
 I { BODY }
 /x/ -> Done
Done:
 /[a-z]+/
```

The value body is:

```text
return([coalesce(undef, "fallback"), coalesce("", "fallback"),
        coalesce([], "fallback"), coalesce({}, "fallback"),
        coalesce(0, "fallback"), coalesce(false, "fallback"),
        coalesce_nonempty("", "fallback")])
```

Rust returns `["fallback","fallback","fallback","fallback",0,false,"fallback"]`.
Perl returns `["fallback","",[],{},0,false,"fallback"]`.

The four effect bodies use `H` equal to either `coalesce` or `coalesce_nonempty`:

```text
audit = "unset"; result = H("first", audit = "late"); return([result, audit])
audit = "unset"; result = H(undef, audit = "selected", audit = "late"); return([result, audit])
```

For both helpers Rust returns `["first","late"]` then `["selected","late"]`;
Perl returns `["first","unset"]` then `["selected","selected"]`.
All five Rust executions exit 0 with empty stderr. All Perl parsers are created,
build/call errors are empty, warnings are empty and last_error is null. The corrected
collector preserves JSON booleans; its original stringified-false output is an observer
artifact documented in [[perl-typed-error-json-observation-boundary]].

Five descriptors report ready=1/unresolved=0. Actual lowered and generated source retains
the conditional structure, including the nested selected assignment before any late operand.
These generated captures were inspected, not independently executed.

## Historical assertion and carrier limits

`helpers_5_2_coalesce_short_circuits` only checks that coalesce returns `"hello"` when
a plain fallback string is available. It has no operand effect/error and cannot detect this
eager-evaluation gap. Permanent value/effect/skipped-failure tests and supported native,
serialized, generated, emitted and standalone consumers belong to `.62.3`. Other backends,
receiver/value-block routes, all-undef and invalid argument cases were not executed here.
That reading slice claimed no repair or whole-project signoff; current bounded repair is recorded above.

## Retained historical provenance

Exact September7 CLI identity, scratch manifest (40 files/158,215 bytes), file
hash table and original commands remain byte-recoverable at Git
04c9d093fdeded96771cd803de3eba3fb3fb7703 for this path. Those historical capture
commands are not current startup/feature commands; use the focused reverify above.

Current repair ownership is SESSION-STARTUP-READING.62 in its indexed task tree.
The October26 feature-first phase selects bounded implementations now; broader
reading/policy/admission stays separately owned.
