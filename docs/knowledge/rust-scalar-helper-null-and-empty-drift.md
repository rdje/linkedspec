---
id: rust-scalar-helper-null-and-empty-drift
title: "Rust scalar null and empty-input boundaries"
answers:
  - "does Rust substr preserve null source start and provided length"
  - "why does Rust substr truncate fractional offsets instead of normalizing zero"
  - "does Rust length preserve undef"
  - "why does Rust trim undef return an empty string"
  - "do lowercase uppercase replace_substr rm_prefix and rm_suffix preserve null"
  - "does replace_substr with an empty old string leave the input unchanged"
  - "do string predicates and matches reject undefined input"
  - "is null an undefined literal in the LinkedSpec DSL"
  - "which task owns scalar helper null and empty semantics"
date: 2026-10-27
status: bounded null/empty61.1/.61.2 and slice19.2 repairs targeted-checked; broad61.3 admission open
tags: [rust, perl, scalar, string, undef, null, helpers, parity]
evidence: "SESSION-STARTUP-READING.3.3.21 at 19e943a4b7cbe68a5f538ff3f0ef17c54fc549f3 compares five scalar vectors on primary Rust and public Perl Get, captures all lowering/generated text and descriptors, and independently checks exact result kinds and error absence. Literal undef and unbound name null reproduce the same differences; the empty-string transformation control agrees."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test scalar_string_results --test scalar_null_propagation --test scalar_predicate_boundaries"
---

Current:61.1 guards seven transformation sources before text coercion (trim first landed under23.3.1.2).61.2 guards null predicate/replacement/removal operands and preserves observed values for empty old/prefix/suffix and unmatched affixes; TYPE23.2.19 distinguishes a Perl affix identity kind defect from that JSON projection, now repaired by Perl19.1 copy inspection. Retained scalar_null_propagation and scalar_predicate_boundaries tests cover native/restored/generated-plan execution, defined/null distinctions, Unicode/array counts and eager order. Public Perl Get confirms the shared boundary fixture, with Rust matches retaining JSON boolean results. Broad61.3 remains open; historical vectors below are unchanged.

# Historical September 7 inputs and outputs

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

`null` is an identifier, not the null literal `undef`. The historical unbound-name twins nullable_transforms/scalar_predicate_boundaries agree with the undef vectors; see [[terse-primitive-literal-parity]].

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

Rust `Engine::call_helper` historically used `RuntimeValue::to_str` before these
operations. Undefined became empty text and length zero; empty-prefix,
empty-suffix, empty-substring and `/^$/` predicates then succeed.
The old replacement arm called host `str::replace` with an empty old string,
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
in that historical campaign. The three neutral checks (logical, scalar numeric, typed source)
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

The current reverify checks source-null transformations; it does not refresh the historical five-vector comparison or close broader admission.

TYPE23.2.19 confirms Perl unmatched numeric affix identities serialize0 but
retain POK alongside IOK and fail typed Array-index writes in free/fluent/named
forms. Empty-old replacement passes the same consumer. MethodLowering inspects
the original source with index/length/substr; Perl19.1 owns inspecting a copy
while retaining original identity kinds. This qualifies broad kind wording from
JSON-only controls; it does not reopen Rust null repairs or close61.3/reducer95.
Canonical result contract/diagnostics: [[terse-string-receiver-value-chains]].

Perl19.1 now preserves numeric affix identities by inspecting text copies;
public flags/typed Array writes and Hash String-key controls pass native/fresh.
String scalar/shape/default/text direct19 checks and syntax pass. This resolves
the bounded affix defect; broad61.3 and reducer95 remain open, with no Rust/null
or frozen scalar-text policy change.

TYPE23.3.19.2 independently finds ordinary Rust substr null source/start return
empty/abc and fractional offsets truncate, despite published normalization.
Retained primary probe substring_bounds gives native/fresh Perl[null,null,abc,a,
empty,empty,bc,null], including provided-null width and existing Boolean offset
compatibility. After the dedicated named-target regex mutation exits, ordinary
arity2/3 now rejects explicit null operands before conversion and normalizes
nonnegative whole offsets locally. Missing optional width/free unary-extra
arity behavior stays; no global numeric/domain/Unicode policy change. New4/
direct3 native/restored/in-process plan tests pass with offline compile/rustfmt,
including eager SIL, null/fraction/negative/Boolean controls and both named-
target mutation aliases. Other backend/full61.3 admission remains separate.

Dart19.3 independently fixes identity-kind/explicit null replacement-affix
operands and fractional offsets; source/start null already worked. Its deliberate
null-width-as-omitted/Bool-invalid0 conventions remain qualified, owned by P2
TYPE23.2.20 before portable admission. Ten focused native/restored/plan tests/
format/fatal analysis pass; [[dart-runtime-string-numeric-helpers]] has current
implementation detail. This does not close broad61.3 or large-slice2.14.

Julia19.4 independently repairs textified scalar identities and explicit null
replacement/affix operands, retaining healthy source/start/fraction slices.
Its null-width-as-omitted/Bool1 conventions join the qualified20 inventory;
[[julia-runtime-string-numeric-helpers]] records63 strict native/plan/fresh/direct
assertions. Broad61.3 and Julia large-slice2.10 remain separate.

Lua19.5 independently fixes identity/null operand/scalar/shape gaps on both safe
hosts, and a PUC large-end substring wrap by clipping before addition. Strict
native/plan/fresh/shared/direct checks pass; qualified width-omitted/Bool0 stays
under20. [[lua-string-helper-parity-closeout]] retains current details without
closing full61.3, declared5.4 or other backends' large-slice owners.
