# String predicate results in ordinary receiver chains

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.9`; implementation family `.23.3.10`.
Existing helpers only; full regex/domain/fluent/portable admission stays23.4.

## Authority and preservation

This bounded family comprises starts_with, ends_with, contains_substr and matches.
The first three consume scalar text operands; undefined source/operand is false,
while an empty needle/prefix/suffix matches every defined source, including empty
text. Matches consumes its existing literal regex/flag surface: undefined source
is false, empty text can match /^$/, and regex policies remain unchanged. Existing
Rust61.2 owns its prior null/empty boundary repair; no replay or new domain
normalization is inferred here.

Each ordinary receiver takes one operand. Missing/extra shapes return null before
source/operand effects under the established fluent shape policy; free-helper
signatures remain unchanged. Preserve each backend's actual producer kind. The
existing scalar-text contract renders numeric/Boolean truth as0/1; result flow
must not normalize the producer or retain the source String's identity.

A valid chain evaluates source once, then operand once where its existing domain
permits computed operands, computes the predicate once, then consumer operands
in helper order. Preserve source/operand/result snapshots across later mutations.
No new deep-copy or dynamic-regex/interpolation promise is made.

Implementation targets, not portable support claims:

| Expression | Result |
| --- | --- |
| `"abc".starts_with("a").cat("!")` | `"1!"` |
| `"abc".ends_with("z").cat("!")` | `"0!"` |
| `"abc".contains_substr("z").coalesce_nonempty("late").cat("!")` | `"0!"` |
| `"abc".matches(/^a/).cat(",x").split(",").last().uppercase()` | `"X"` |
| `["abc"].first().starts_with("a").cat("!")` | `"1!"` |
| `"abc".matches(/^a/).sorted()` | undef/null |

Source families include named/literal/selected/pipeline/default/function Strings,
actual null values, literal/computed text operands, true/false/empty boundaries,
false retention, explicit String/Array bridges and scalar/container boundaries.
String comparison receiver additions, definedness predicates, contains missing-
needle calibration, callable/deferred contexts and full admission stay separate.

## Public Perl findings

probe_string_predicate_results.pl retains Get/substitution and independent fresh
emitted comparisons. Native/fresh producers return[1,1,1,1,0,0]. The selected
null/empty boundaries render[0!,1!,0!,1!,0!,1!]. All four fluent cat chains stop at
null while nested controls give1!; substitution for starts_with is return undef.
_string_receiver_value_chain_return_family marks these producers terminal.

The producer/order control is already correct: nested source/operand/consumer
blocks yield[1!,SOC,zzztail], agreeing on native/fresh routes after operand and
consumer mutate the working String. Fluent gives[null,"",abc] and runs no effects.
Preserve the producer; do not invent a snapshot repair. Missing/extra ordinary
fluent controls currently give[null,""] without effects on the public native probe.

## Sequence

Commit assessment/freeze, then separate Perl/Rust/Dart/Julia/Lua children with
independent native/generated assessment before classification. Compile and small
changed-surface/direct checks/docs/commit; no broad suite. Preserve actual result
kinds, source/operand domains and correct producer behavior. Declared Lua5.4 and
complete regex/context/domain/portable admission remain separate.

## Bounded Perl result handoff

23.3.10.1 marks these four String predicate results scalar_result and preflights
exactly one operand. Native/fresh shared result/direct emptiness fixtures pass
after fluent-null RED, retaining producer kinds/domains/regex policies, true/
false/null/empty/regex-i boundaries, source families, false retention/repeated
generic predicates, explicit bridges/scalar nulls, eight malformed no-effect
controls and SOC/SC/once-only source/operand/result snapshots. Rust assessment
follows; complete regex/domain/context/portable admission remains separate.

Canonical selection is a separate admission prerequisite23.4.1: the runner selects
Perl suites explicitly, and adding these new t files alone does not register them.
The named predicate/emptiness/has_key no-match controls are owned there; inventory
and actual canonical registration/receipt must land before admission/final push.
Current focused direct runs are not relabeled as canonical coverage.

## Bounded Rust handoff and literal flag repair

23.3.10.2 adds the four methods to scalar-result and one-operand preflight lists.
Native RED gives fluent null, SO/S-only order and12 effects. Dispatch then exposes
regex-i0!: Core parse_regex discards suffix letters, storing /^a/i and /^a/ as
identical ^a. Public inline imsx controls work; this is first-party flag loss.
Encode supported modes in the existing pattern string, ignore go, and fail unknown
flags through each helper's existing invalid-pattern path. No new regex value type
or serialized field is introduced; numeric substring/Boolean regex results stay
unchanged. Native/restored/plan result and literal-flag controls (including split/
filter), direct boundary tests and18 focused Core regex tests pass after RED.
Regenerate previously compiled/emitted Rust artifacts from original source to pick
up the corrected modes; old regex nodes retain their recorded pattern data. Do not
rewrite immutable historical evidence. Dart/full regex/domain/admission separate.
