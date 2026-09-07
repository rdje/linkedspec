---
id: rust-coalesce-evaluation-drift
title: "Rust coalesce skips defined empty values and both default helpers evaluate later operands"
answers:
  - "does Rust coalesce preserve a defined empty string"
  - "does Rust coalesce short circuit operand evaluation"
  - "does coalesce_nonempty skip later assignment effects"
  - "what does the coalesce_short_circuits native test actually assert"
  - "why do Perl and Rust coalesce disagree on empty aggregates"
date: 2026-09-07
status: confirmed bounded discrepancy; repair pending
tags: [rust, perl, helpers, evaluation, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.22: five paired existing-primary Rust/live Perl Get controls, five ready descriptors and inspected lowered/generated sources; .62.1-.62.4 own repair and carrier/public closure."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- rust/linkedspec-runtime/src/engine.rs perl/LinkedSpec/ActionIR/MethodLowering.pm"
  - "sed -n '5557,5562p;5624,5644p;8223,8231p;9510,9519p;10869,10880p' rust/linkedspec-runtime/src/engine.rs"
  - "sed -n '6396,6446p' perl/LinkedSpec/ActionIR/MethodLowering.pm"
---

# Default selection and later operand effects

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

## Exact paired observations

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

## Assertion and carrier limits

`helpers_5_2_coalesce_short_circuits` only checks that coalesce returns `"hello"` when
a plain fallback string is available. It has no operand effect/error and cannot detect this
eager-evaluation gap. Permanent value/effect/skipped-failure tests and supported native,
serialized, generated, emitted and standalone consumers belong to `.62.3`. Other backends,
receiver/value-block routes, all-undef and invalid argument cases were not executed here.
No repair or whole-project signoff is claimed.

The existing Rust CLI identity is SHA-256
`ad45555750489b78f7835457a09ecfa174d56b7ebf6242a4db5850570797c81a`;
the current source is unchanged from the reading baseline. No compiler ran in this slice.

## Retained evidence

All paths derive from `.linkedspec-data/scratch/startup81-coalesce-boundaries/`.
The manifest covers 40 files / 158,215 bytes excluding itself, including the exact specs,
probe scripts, result streams, lowered/generated source, descriptors and empty execution logs.
The manifest is 8,659 bytes, SHA-256
`af5a1031717134cb9872f1d98b9f1f55c6efb5c4e3a7c12ca53b84dd6170d927`.

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `rust-cli.jsonl` | 339 | `3fcab59812d41ad9fd86e13b100a60e0c05da85e64a54a22238fcc130694a35e` |
| `rust-cli-nonempty.jsonl` | 196 | `99b32df485ad3c76c09c8b513a3f75851d790ad680b8d0319f09424c28254d1a` |
| `perl-typed-results.jsonl` | 467 | `c290981158f09e90b74fdb65525195b778a5d7bc72e98b03b56601a0cacddcdd` |
| `perl-nonempty-results.jsonl` | 303 | `558427a45f98dfd2af1369723d4e47f89f840490962cb36bfa83ec291b0d1ff8` |

The task-tree is the current repair authority: `SESSION-STARTUP-READING.62.1-.62.4`
in `docs/tasks/SESSION-STARTUP-READING.md`. Prerequisite reading/alignment/policy work still
precedes runtime repairs.
