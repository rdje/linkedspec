---
id: rust-coalesce-evaluation-drift
title: "Lazy defaults and selected result kinds"
answers:
  - "can coalesce_nonempty Array or Hash results continue by actual kind"
  - "why does a valid coalesce_nonempty Hash literal emit hash_literal_use_colon"
  - "why does coalesce_nonempty make numeric array indices fail on Perl"
  - "does Perl coalesce_nonempty return undef when all operands are empty"
  - "does Rust coalesce preserve a defined empty string"
  - "does Rust coalesce short circuit operand evaluation"
  - "does coalesce_nonempty skip later assignment effects"
  - "what does the coalesce_short_circuits native test actually assert"
  - "why do Perl and Rust coalesce disagree on empty aggregates"
date: 2026-10-26
status: bounded defaults repaired; Perl kind/literal repairs23.3.6 pending
tags: [rust, perl, helpers, evaluation, startup-reading]
evidence: "Historical .3.3.22 controls; current .62.1/.62.2.1-.3 public fixtures, Rust regressions and Perl Get/substitution/native/fresh proof. Broad .62.3/.62.4 remains open."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test coalesce_lazy_values --test coalesce_nonempty_values --test coalesce_receiver_values"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/coalesce_nonempty_exhaustion.t"
---

Current62.1/62.2.1-.3: Rust eval_coalesce_args/coalesce_accepts evaluates only
needed operands, preserving actual selected kinds. Native/restored/generated-plan
checks pass. Perl validates every operand and compares a scalar copy, preserving
numeric validity; native/fresh exhaustion/effect/index checks pass after RED.
See [[action-regex-operands-and-runtime-kinds]]. Compatibility observations do not
broaden the scalar signature; broad62.3/.62.4 remains open.

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

## Current selected-result findings

TYPE23.2.5 Get/substitution/fresh probes distinguish joined Array/Hash consumers
(undef) from nested A-B/X:Y. Direct String Array continuation reaches a raw host
helper. String/scalar_result metadata blocks actual containers;23.3.6.1.1 owns
flow/retained-scalar guards. Valid colon Hash default emits hash_literal_use_colon:
the value-only AST/legacy bridge reparses host fat arrows as DSL. Named Hash works;
P1 repair1.2 follows1.1. Scope/producers: docs/checkpoints/type-operation-inventory/default-selection-results.md.

Original assertion/carrier detail is exact at Git949790b510f8ad29b744730ac379a8952d987d9f for this path; not replayed here.

## Retained historical provenance

Exact September7 CLI identity, scratch manifest (40 files/158,215 bytes), file
hash table and original commands remain byte-recoverable at Git
04c9d093fdeded96771cd803de3eba3fb3fb7703 for this path. Those historical capture
commands are not current startup/feature commands; use the focused reverify above.

Current repair ownership is SESSION-STARTUP-READING.62 in its indexed task tree.
The October26 feature-first phase selects bounded implementations now; broader
reading/policy/admission stays separately owned.
