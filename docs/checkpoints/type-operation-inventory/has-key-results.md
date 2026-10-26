# Has_key results in ordinary receiver chains

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.7`; implementation family `.23.3.8`.
This bounded target precedes implementation; full fluent/portable admission stays23.4.

## Existing authority

The helper catalog declares `has_key(hash, String key)` as truth-valued key
presence. A stored false or null value is still present. Preserve the actual
producer kind, existing source/key domain and copy policy; do not normalize
Boolean/numeric output or add logical methods. The scalar-text contract renders
false/true as0/1, and numeric0/1 likewise. Existing compatible Scalar/String
consumers receive that result; Array/Hash-only consumers return undef/null until
an explicit helper produces the appropriate container.

Receiver form takes exactly one key; malformed shapes return undef/null before
receiver/key effects under existing ordinary fluent shape policy. Free-helper
signatures remain unchanged. Evaluate/snapshot the source once, then key once,
then consumer operands once in existing order. Preserve the source snapshot when
key/consumer blocks mutate the working Hash; no new deep-copy promise is made.

Implementation targets (not current portable support claims):

| Expression | Result |
| --- | --- |
| `meta.has_key("present").cat("!")` | `"1!"` |
| `meta.has_key("missing").cat("!")` | `"0!"` |
| `meta.has_key("false_valued").cat("!")` | `"1!"` |
| `meta.has_key("null_valued").cat("!")` | `"1!"` |
| `meta.has_key("missing").coalesce_nonempty("late").cat("!")` | `"0!"` |
| `meta.has_key("present").cat(",x").split(",").last().uppercase()` | `"X"` |
| `meta.has_key("present").sorted_values()` | undef/null |

## Public Perl findings

Retained probe_has_key_results.pl and probe_has_key_results_fresh.pl use public
Get/substitution and independently loaded emitted source. Producer presence is
[1,0,1,1] for present/missing/false/null entries; literal, variable and helper-
produced String keys work. Nested cat returns"1!". Direct fluent cat reaches raw
host has_key and fails; selected/pipeline forms also stop. MethodLowering's
_hash_receiver_value_chain_return_family currently labels has_key terminal.

A separate P1 defect blocks valid key blocks even without chaining: raw authored
DSL survives inside exists ->{{DSL}}, failing native/fresh compilation. The legacy
has_key branch delegates it to lower_scalar_access_key_expr without completing
current-context key lowering. Thus source/key/consumer effect controls currently
fail compilation; they are not passing snapshot/once-only evidence.

## Sequence and limits

Commit assessment first. Perl23.3.8.1.1 repairs key-block producer compilation and
establishes source/key snapshots/once-only native/fresh controls;1.2 then repairs
result handoff and whole fluent shape preflight. Rust2/Dart3/Julia4/Lua5 each begin
with independent public assessment, repair only confirmed gaps and preserve the
actual producer kind. Use compile/small direct checks/docs/commit; no broad suite,
contains calibration change, new predicate vocabulary or portable admission.

## Bounded Perl key-block repair

23.3.8.1.1 completes key expressions in the current MethodLowering context before
the existing scalar-key fallback. Native/fresh regression passes after compilation
RED: literal/variable/helper keys, key once-only, false/null-valued presence and
named/computed/free source snapshots with K/SK order. A key added while computing
the key stays absent from the captured source. Direct index compatibility passes.
Result continuation/shape repair1.2 and independent backends remain separate.

## Bounded Perl result handoff

23.3.8.1.2 uses scalar_result and exact-one-key preflight. Typed has_key operands,
typed nested has_key arguments and preserved authored root calls keep completed
function Hash output out of the DSL compatibility parser. Classifier-only repair
left function sources null; public Get/function/free/single-step/chained controls
and generated unsupported-has_key output isolated that additional flow gap.
Native/fresh shared result and direct producer tests pass after RED, covering
presence/false retention, selected/pipeline/literal/function/default sources,
String keys/Array bridge, scalar nulls, no malformed effects and K/SK/SKA snapshots.
Rust assessment follows; full domain/portable admission remains separate.

## Bounded Rust result handoff

23.3.8.2 adds has_key to existing scalar-result classification and exact-one-key
preflight. Public native RED shows fluent null versus nested1!, SK-only order
and four malformed effects. Native/restored/generated-plan shared result and
direct index tests pass after repair with presence/false retention, String keys,
source families, explicit bridge/scalar nulls, zero malformed effects and K/SK/SKA
snapshots. Numeric1/0 presence helper/source/copy policy stays unchanged. Dart
assessment/full admission remain separate.

## Bounded Dart scalar/shape guards

23.3.8.3 retains already correct flow and snapshots. Native RED shows incompatible
container[], missing0!, extra1! and four malformed effects. Include has_key in
existing one-key preflight and source-independent scalar tracking; actual List/Map
output releases the guard. Native/restored/generated-plan shared result and direct
index tests plus fatal selected-file analysis pass after repair. Number0/1 presence
helper, String keys/source/copy policies stay unchanged. Julia/full admission separate.

## Bounded Julia scalar/shape guards

23.3.8.4 retains correct flow/snapshots and adds has_key to existing one-key
preflight/source-independent scalar tracking. Native JSON exposes container[],
missing0!, extra1! and four effects; native/plan/fresh all fail before repair.
Strict native/generated-plan/fresh-emitted has_key and direct index tests plus
package compilation pass after repair, retaining presence integer0/1, String
keys, source families, false retention/explicit bridges and K/SK/SKA snapshots.
Helper/domain/source/copy stay unchanged; Lua/full admission remain separate.

## Bounded Lua result handoff

23.3.8.5 replaces the explicit has_key terminal fence with scalar-result tracking
and adds one-key preflight. Both available native hosts show fluent null versus
nested1!, SK-only order and four malformed effects before repair. Native/generated-
plan/fresh-emitted shared result/direct index and interpreter/runner loadfile pass
after repair on PUC5.5.1/LuaJIT with matching products, preserving numeric0/1
presence, String keys/source families, false retention, explicit bridges/scalar
nulls, no malformed effects and K/SK/SKA snapshots. Bounded rollout is targeted-
checked on recorded hosts; declared5.4/full admission separate. Next assessment
is is_empty/is_nonempty result continuation23.2.8.
