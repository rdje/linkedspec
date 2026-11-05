# Ordinary Length result guards

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.35; implementation family23.3.74.
Existing count-length-results.md3, catalog Length and typed result/copy/eager-logical
contracts retain authority. Status: Perl74.1 implemented with focused checks; independent peers74.2-.5 pending.

Canonical ordinary length(value), one positional recognized value, and receiver.length()
with zero extra operands keep current Number/null results. Length of a scalar is its
existing character length; Length of an Array is its cardinality. Preserve null, empty
String0, Number0, Bool/text conversion domains and existing source-kind policies per backend.
Do not normalize producer domains, add methods/signatures/aliases or change parsers/schema.

Actual Number/null results compose through compatible numeric/scalar methods, direct reads
and explicit String/Array bridges. Wrong-kind Array/Hash consumers reject with null before
their operands; later copy/logical/default/with links must not turn rejection into a valid
null value. Legitimate null/zero still feed current copy/eager-logical/with semantics.
Preserve source once, ordered snapshots, local return/function scope, needed source errors,
preflight arity and explicit bridge admission. Keep existing copy depths and eager truthiness.

```text
length("tail").add(1)                         # 5
"tail".length().add(1)                        # 5
length("").coalesce(7).add(1)                  # 1
length(undef).with(){return("recovered")}      # recovered
length("tail").take(1).copy().with(){return(9)} # null, body skipped
length("tail").set_key("k",1)                 # null; never consult host Hash4
length("tail").cat(",tail").split(",").last() # tail
```

Frozen tests/fixtures/length_result_guard_cases.json has16 authored programs: nine healthy
Perl preservation controls/seven target gaps on native/fresh routes. The scalar_array_sources
row is explicitly Perl-domain observation; each peer freezes its own current source-domain
profile before any repair. No failure is inferred for a peer. Malformed receiver preflight
skips source/operand/body; needed source errors cannot be masked by coalesce. Count([]) and
compatible Length prefixes distinguish missing source admission from a generic consumer bug.

Perl74.1 repairs actual-kind source roles and persistent rejection through copy/logical links,
including exact emitted main::4 empty/seeded host controls. Rust74.2, Dart74.3, Julia74.4,
safe installed Lua74.5 independently assess, preserve producer domains and repair only actual
gaps. No new Lua chunk locals/unsafe runner/formatter/declared5.4 inference. Actual inputs
must precede compiled proofs; full native/transitive custody23.4.2 remains separate.

Initial key-count source guard defects are owned P1 family75 assessment75.0 after74.5,
before unrelated selection/full admission. Length does not silently absorb count_keys.
Actual observations, source snapshots, recovery qualifications and seed root cause:
docs/checkpoints/length-selection-2026-11-05/REVIEW.md. No complete-family/admission claim.

## Bounded Perl74.1 repair

The unchanged new normal has19 groups: nine original healthy programs and ten failing
groups (seven authored target gaps/three explicit host seeds). All19 now pass native/fresh;
the nine healthy observations remain exact. Canonical free-one/zero-extra receiver Length
sources join current emitted actual-kind/with dispatch. Ordinary copy and eager logical
links retain the existing rejection flag; rename the shared Count/Length logical role for
clarity. Existing Length producer, Count fallback, domains/signatures/copy depths and
function/parser/schema policies stay. Empty/outer/main::4 seeds all reject with null,
no warning/error and unchanged host Hashes. Actual normal modules persist before fresh eval.
Direct Count/length/source/logical preservation and syntax pass; original/source/normal/
fixture identities, modules, raw phases and readonly corruptions survive under
length-guard-perl-2026-11-06. Regenerate emitted Perl. Rust74.2 independently next; no peer,
complete native/transitive custody, general isolation, registration or full admission claim.
