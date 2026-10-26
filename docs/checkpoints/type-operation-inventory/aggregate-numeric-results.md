# Aggregate numeric results in ordinary receiver chains

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.3`; implementation family `.23.3.4`.
This freezes a bounded target before production edits, not current portable support
or complete fluent-family admission.

## Existing authority and scope

The helper catalog defines array `sum`, `avg`, `median`, `range`, `min` and `max`,
backed by `num_sum`, `num_avg`, `num_median`, `num_range` and array-form
`num_min`/`num_max`. The scalar numeric contract defines compatible numeric
consumers. The first/last and Count/Length contracts establish actual-value
continuation through existing pure helper families.

This feature lets a successful ordinary array reducer result become the current
value for the next compatible existing scalar/number method. For example,
`values.sum().add(1)` means `num_add(num_sum(values),1)`. Do not retain the source
array family or stop merely because the producer is a reducer. A subsequent
string-producing consumer may continue through its existing compatible methods.

## Producer, overload and effect boundaries

Array reducer receivers take zero extra operands. Preserve existing invalid-shape
null/effect rules, including pre-effect rejection for unambiguous sum/avg/median/
range. Do not globally reject min/max operands: an actual scalar receiver with
one or more method operands uses the existing scalar min/max contract, while
zero-extra array min/max selects an aggregate. Overloaded invalid-source/arity
behavior remains the existing helper behavior. Do not admit Number.sum() or
other meaningless scalar reducer operations.

Evaluate the source once, compute the result once, then evaluate needed consumer
operands once in existing helper order. A later operand may mutate the source;
it must not cause the reducer to run again. Preserve source/result snapshots,
consumer laziness, errors, nulls and existing helper domains. Empty sum is zero;
other empty reductions follow their existing null policy. A null result follows
the next helper's ordinary null behavior.

Retain actual selected result kinds. This is not a normalization or input-domain
repair: Perl selected numeric-string min/max/odd median and Boolean admission
remain owned by `SESSION-STARTUP-READING.95`; Rust's wider filtering differences
stay explicit. A compatible numeric consumer still applies its normal validation
and conversion. No new deep-copy or addressable mutation promise is introduced.

## Normative examples

Targets below use valid numeric arrays; they do not claim all backends pass now.

| Expression | Expected |
| --- | --- |
| `[2,4,6].sum().add(1)` | `13` |
| `[2,4,6].avg().add(1)` | `5` |
| `[2,4,6].median().add(1)` | `5` |
| `[2,4,6].range().add(1)` | `5` |
| `[2,4,6].min().add(1)` | `3` |
| `[2,4,6].max().add(1)` | `7` |
| `[4,1,3,2].median().mul(2)` | `5` |
| `[1,2].sum().cat(" total").uppercase()` | `"3 TOTAL"` |
| `[].sum().add(1)` | `1` |
| `[].avg().add(1)` | undef/null |
| `[[2,4]].first().sum().mul(2)` | `12` |
| `[3,1,2].sorted().take(2).sum().add(1)` | `4` |
| `[2,4].sum().min(3).add(1)` | `4` |

Retain direct, selected, pipeline and ordinary function sources, empty/invalid
producer controls, scalar/array min/max distinction, once-only source/consumer
effects and source mutation in a later operand in small backend fixtures.

## Earlier terminal policy and exclusions

The previous blanket reducer-terminal policy is superseded for these ordinary
compatible pure result continuations. Invalid array consumers on a scalar result
still follow their helper's domain policy; no implicit revival of the source.
Do not update old incompatible-array-consumer negatives to successful values.

Separate callable/deferred evaluators, callback/reduce_leaves results, membership/
predicate/control outputs, new methods/types, serialized/generated formats,
complete signatures/transitions and portable admission remain separately owned.
Existing callable vocabularies need no artificial restriction or new admission.

## Activation findings and implementation order

The retained public diagnostic `probe_reducer_results.pl` reports
`[null,13,null,5,null,5,null,5,null,3,null,7]` without last_error on Perl before
implementation. Public substitution emits `return undef` for the sum chain.
MethodLowering's ordinary preflight rejects nonfinal reducers, and its array
return-family callback marks reducer results terminal. This is result flow,
not a missing arithmetic implementation.

Implement Perl first; publicly assess each later backend independently and
preserve correct existing behavior. Commit each bounded backend slice after
compilation and small direct checks. Full method/context/portable admission stays
`.23.4`, and existing reducer-kind repair95 remains separately owned.

## Current implementation

Perl `.23.3.4.1` implements ordinary pure result continuation through existing
selected-value machinery with scalar_result flow metadata. Scalar results reject
array-only consumers until an explicit string-to-array bridge; old incompatible
consumer negatives remain null. Zero-extra initial min/max uses Array dispatch,
while scalar overloads retain their numeric operands. Native/fresh and direct
Count/Length checks pass after RED, including six producers, empty/null/shape,
selected/pipeline/function values, scalar overloads, even median, text/Array bridge,
order and mutation snapshots. Helper domains/kind95 and the separate deferred
evaluator remain unchanged. Rust and later backends require individual assessment.

Rust `.23.3.4.2` implements result handoff and scalar consumer boundaries through
existing static/dynamic paths, with early unambiguous aggregate shape guards.
It also repairs documented zero for actually empty Array sum; nonempty filtering
and other helper domains stay unchanged. Native/restored/generated-plan and
direct Count/Length fixtures pass after RED, including explicit Array bridge,
overloads, empty helper controls, order and snapshots. Existing callable vocabulary
is reused; no complete context/portable admission. Dart and later backends require
individual assessment.

Dart `.23.3.4.3` preserves already-correct numeric flow/empty identity and adds
unambiguous producer arity plus scalar-result boundaries in shared ordinary/
mutating-source iteration. Native/restored/generated-plan and direct Count/Length
checks pass after shape/domain RED; changed-file fatal analysis passes. The small
fixture also retains named-mutation sources and pre-effect invalid-shape rejection.
Julia/Lua remain unassessed; full context/portable admission stays separate.

Julia `.23.3.4.4` likewise preserves correct result flow/empty identity and adds
unambiguous producer shape checks plus scalar-result boundaries in its existing
loop. Native/generated-plan/fresh-emitted and direct Count/Length checks pass after
RED under strict Julia1.12 harness execution, including named mutations, explicit
Array bridge, order and snapshots. Shared Lua remains individually unassessed.

Shared Lua `.23.3.4.5` removes the reducer endpoint stop, retains scalar boundaries
(including case maps routed through String dispatch) and rejects unambiguous
producer extras before effects. Small native/generated-plan/fresh-emitted and
direct Count/Length checks pass after RED on available PUC5.5.1/LuaJIT with matching
native products, retaining empty helpers, min/max overloads, named mutations,
Array bridge, order and snapshots. Declared5.4 proof remains separately owned.
Bounded implementations are targeted-checked; full context/portable admission
stays23.4. Next feature assessment is ordinary join_values result flow23.2.4.
