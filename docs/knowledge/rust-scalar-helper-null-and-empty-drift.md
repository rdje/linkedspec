---
id: rust-scalar-helper-null-and-empty-drift
title: "Rust scalar helpers lose undefined values and apply host empty-string behavior"
answers:
  - "does Rust length preserve undef"
  - "why does Rust trim undef return an empty string"
  - "do lowercase uppercase replace_substr rm_prefix and rm_suffix preserve null"
  - "does replace_substr with an empty old string leave the input unchanged"
  - "do string predicates and matches reject undefined input"
  - "is null an undefined literal in the LinkedSpec DSL"
  - "which task owns scalar helper null and empty semantics"
date: 2026-09-07
status: confirmed bounded discrepancies; SESSION-STARTUP-READING.61.1-.61.3 pending
tags: [rust, perl, scalar, string, undef, null, helpers, parity]
evidence: "SESSION-STARTUP-READING.3.3.21 at 19e943a4b7cbe68a5f538ff3f0ef17c54fc549f3 compares five scalar vectors on primary Rust and public Perl Get, captures all lowering/generated text and descriptors, and independently checks exact result kinds and error absence. Literal undef and unbound name null reproduce the same differences; the empty-string transformation control agrees."
reverify: "bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py && rg -n '__ls_length|__ls_replace_substr_value|__ls_starts_with' perl/LinkedSpec/ActionIR/MethodLowering.pm"
---

# Exact inputs and outputs

Use the same `Top::` I-block / `/x/ -> Done` / `Done: /[a-z]+/` scaffold
and `xhello` input as [[rust-array-slice-boundary-panics]], returning each
expression below.

For `U` equal to literal `undef`:

```text
[length(U), trim(U), lowercase(U), uppercase(U),
 replace_substr(U, "a", "b"), rm_prefix(U, "a"), rm_suffix(U, "a")]
```

Rust returns `[0,"","","","","",""]`. Perl returns seven JSON nulls. The exact
fixture name is `undefined_transforms`. Replacing every `U` with `""` gives
`scalar_empty_controls`: both return `[0,"","","","","",""]`.

The second vector, `undefined_predicate_boundaries`, is:

```text
[replace_substr("ab", "", "X"), starts_with(undef, ""), ends_with(undef, ""),
 contains_substr(undef, ""), matches(undef, /^$/)]
```

Rust returns `["XaXbX",1,1,1,true]`; Perl returns `["ab",0,0,0,0]`.
The Rust regex result is a JSON boolean and the three substring predicates
are numeric flags; assertions preserve that observed distinction.

Two initial twins use unbound identifier `null` instead of `undef`:
`nullable_transforms` and `scalar_predicate_boundaries`. They reproduce the
same results because the unbound variable evaluates to undefined. **The DSL
undefined literal is `undef`; `null` is an identifier.** Perl's lowered initial
text contains `$null`, while literal-undef text does not.
See [[terse-primitive-literal-parity]].

All five Rust commands exit 0 with empty stderr. Perl creates all five parsers,
has empty build/call exception strings and warning lists, returns without
last_error, and emits no execution stdout/stderr. The collector's plain
projection represents parser-created truth as `"1"`. All five descriptors are
ready with zero unresolved helpers.

# Root cause and authority

The current public catalog explicitly promises undef propagation for these seven
transformations, false `matches` for undefined input, and an unchanged value when
`replace_substr` receives an empty old string. The public Perl controls establish
the other three predicates' undefined-input behavior.

Rust `engine.rs:9371` onward uses `RuntimeValue::to_str` before string
operations. Undefined becomes empty text; length becomes zero; empty-prefix,
empty-suffix, empty-substring and `/^$/` predicates then succeed.
The replacement arm calls host `str::replace` with an empty old string,
which inserts the replacement at character boundaries. This helper behavior is
separate from the strict `cat` scalar-to-text authority.

LinkedSpec's `call_spec_handler_subst` and generated source show the Perl
`defined(...)` guards, array-aware length, and explicit empty-needle branch.
Relevant owners are `MethodLowering.pm:5260` (length), `5300` (replacement),
`5701` (prefix predicate), and their adjacent scalar arms. This is valid,
ready lowering, unlike the unsupported callback markers in startup `.59`.

`SESSION-STARTUP-READING.61.1` owns seven-helper propagation and typed/Unicode/
array controls. `.61.2` owns predicates and empty-old replacement.
`.61.3` owns supported carriers, remaining-backend probes, permanent recurrence
and rendered public/canonical closure after prerequisites. Other argument
positions, nonempty Unicode inputs and generated execution were not remeasured
here. The three passing neutral checks (logical, scalar numeric, typed source)
do not close these string-helper discrepancies.

# Retained evidence

The shared directory/manifest, executable identity and exact execution method
are recorded in [[rust-array-slice-boundary-panics]]. Initial scalar data lives
in that card's rust-cli/perl-results files. Additional data is:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| rust-cli-extra.jsonl | 211 | 767af8c9353fa8f2332477c91fae6ac37b13c05257e0568b666e1645359ce9d0 |
| rust-cli-undefined.jsonl | 213 | 353000dcce856c9c5bffb5abeb51b9c4623aca0b5bbd4034fcb505b60ff80ddb |
| perl-extra-results.jsonl | 299 | bff6d510b6133e64ce5c4e15f576a16657fa557b2c51aa94a38f59ea4f42ce8f |
| perl-undefined-results.jsonl | 316 | 24cd8eecc3a09993cd2bc4200defbc846a3c5c0fd1898e4d8758c7f29b51a07f |

The reverify field checks the separate numeric invariant and retrieves Perl
guards; it does not rerun this five-vector native comparison.
