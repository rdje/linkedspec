# Default selections keep the selected value's kind

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.5`; implementation family `.23.3.6`.
This bounded transition target precedes production changes. It does not claim
portable admission or complete helper argument-domain coverage.

## Existing authority and scope

The catalog documents lazy `coalesce_nonempty`: evaluate only the needed prefix,
reject undef and empty Scalar text, and preserve zero/false and selected kinds.
Its published signature is scalar operands. Public Perl also selects Array and
named Harray operands unchanged; those existing compatibility observations motivate
this bounded ordinary result-flow target. They do not make all helper forms or
all container operands portable. The separate literal-lowering defect below is
owned before any broad domain claim.

An ordinary documented `coalesce_nonempty` receiver continuation uses its actual
selected value. A selected Array feeds existing Array methods; a selected Harray
feeds existing Harray methods; a retained String/Number keeps scalar behavior.
The producer's original String family must not block an actual container or
revive a previous Array. Ordinary free `coalesce` and any undocumented receiver
spelling are outside this target; preserve their existing domains and behavior.

## Examples and effects

These are implementation targets, not current cross-backend support claims:

```text
"".coalesce_nonempty(["a","b"]).join_values("-").uppercase() # "A-B"
[].join_values(",").coalesce_nonempty(["a","b"]).join_values("-").uppercase() # "A-B"
meta={"b":"y","a":"x"};
[].join_values(",").coalesce_nonempty(meta).sorted_values().join_values(":").uppercase() # "X:Y"
["kept"].join_values(",").coalesce_nonempty(["a"]).uppercase() # "KEPT"
["kept"].join_values(",").coalesce_nonempty(["a"]).sorted() # undef/null
[].join_values(",").coalesce_nonempty(undef,"").uppercase() # undef/null
```

Evaluate receiver/source once, required fallback operands once and only through
selection, then consumer operands once. A source-S / selected-default-D /
consumer-J fixture must produce SDJ, omit late-L and preserve snapshots against
later mutation. Keep existing null/empty/zero/false, copy/identity and helper error
policies. Do not add implicit scalar-to-container conversion. Empty containers
are values, not empty Scalar text; assess current per-backend behavior explicitly.
Keep malformed producer/consumer shape behavior from existing contracts.

## Public Perl findings at activation

`probe_default_results.pl` and `probe_default_results_isolated.pl` use public Get
and call_spec_handler_subst. `probe_default_results_fresh.pl` independently loads
emitted Perl. The joined Array/Hash continuations lower to undef while nested
helpers yield A-B/X:Y. A direct empty-String Array continuation falls through to
raw host coalesce_nonempty and raises a runtime_handler error. Retained String
and selected-null Array controls already work; do not infer that all defaults fail.

MethodLowering's `_string_receiver_value_chain_return_family` classifies
coalesce_nonempty as String. `append_selected_value_chain_call` additionally
retains scalar_result after it, preventing compatible Array/Hash consumers.
Repair both ordinary routes while preserving incompatible retained-Scalar nulls.

The first source-block effect probe had a compile error in a compound failed
chain; it is diagnostic, not passing proof. The isolated joined-S/default-D/
consumer-J form returns null with no effects, while its nested equivalent gives
[A-B,SDJ,[a,b]]. Retain that independently valid distinction for implementation.

A separate actual defect: direct `coalesce_nonempty("",{"b":"y","a":"x"})`
returns null and emits hash_literal_use_colon despite valid colon source. A named
Hash succeeds, and a nested sorted_values wrapper also succeeds. The value-only
AST call lowerer feeds lowered host arguments back through legacy_method_value_expr;
a valid Hash has already acquired host fat arrows and is then mistaken for
removed authored DSL syntax. `.23.3.6.1.2` owns this P1 repair immediately after
ordinary continuation `.1.1`; do not treat the failed literal as a domain decision.

## Schedule and limits

Commit this assessment/freeze, then separate Perl flow and literal repair leaves,
then assess/implement Rust, Dart, Julia and Lua with small native/generated checks.
Do not infer their failures from Perl. Preserve deferred/callback vocabulary,
serialized formats, free-helper argument roles and source-kind differences.
Full signature reconciliation remains `.1.2.1.4`; complete fluent/public/portable
admission remains `.23.4`, with Lua declared5.4 separately owned.

## Bounded Perl implementation

`.23.3.6.1.1` adds default_result handoff and guards container consumers by the
once-bound selection's actual kind. Scalar helpers retain scalar boundaries.
Source/consumer DSL helpers lower before entering host do/guard expressions.
The native/fresh focused fixture passes after RED, including the named targets,
empty containers, zero/false, exhaustion, lazy SDJ order and source snapshots.
Direct joined/default-exhaustion checks pass. `.1.2` additionally preserves valid
direct Hash operands for both coalesce helpers through complete typed lowering
and a shared lazy host builder. Native/fresh literal and direct default/exhaustion
checks pass after RED, preserving kinds, lazy SDK order and genuine retired syntax
rejection. Generic value-only intermediates are not fully lowered operands; do not
emit their authored bindings/calls directly. Other backends and complete domain/
admission remain unassessed here.

## Bounded Rust implementation

`.23.3.6.2` preserves already-correct joined selections and repairs direct String
selection: its local String loop now hands the actual result to the existing
shared dynamic continuation, with scalar guarding until a container is returned.
Native/restored/generated-plan default and direct joined/default-receiver checks
pass after direct Array/Hash RED. The shared authored fixture retains lazy SDJ
order, snapshots, empty/null/zero/false and incompatible retained-scalar nulls.
Dart/Julia/Lua assessment and full domain/portable admission remain separate.

## Bounded Dart implementation

`.23.3.6.3` retains already-correct Array/Hash flow and lazy copy behavior. Direct
String selections had no scalar-result flag and incorrectly let sorted/sorted_values
return empty Arrays. Nonempty defaults now keep the scalar guard unless their
actual result is List/Map. Native/restored/generated-plan controls pass after that
RED, with shared SDJ snapshots, empty/null/zero/false and existing default/join
compatibility; fatal selected-file analysis passes. Full admission stays open.

## Bounded Julia implementation

`.23.3.6.4` preserves correct container selection and lazy copies. Nonempty
defaults now activate scalar guarding until actual AbstractVector/AbstractDict
output releases it; direct Scalar sorted/sorted_values returns null after the
empty-Array RED. Strict native/generated-plan/fresh-emitted shared/default/join
controls pass, retaining SDJ snapshots and empty/null/zero/false. Full admission
and Lua assessment remain separate.

## Bounded Lua implementation

`.23.3.6.5` preserves correct container selections and activates scalar_result
for nonempty defaults. Actual array/harray output releases it; direct Scalar
container-only consumers now return null after the [] RED. Small native/generated-
plan/fresh-emitted default and direct joined checks pass on available PUC5.5.1/
LuaJIT, preserving lazy copies, SDJ snapshots and empty/null/zero/false. Interpreter/
runner loadfile checks pass; declared5.4 and full domain/admission stay open.
The bounded rollout is targeted-checked on recorded hosts; no exhaustive family
or portable support claim follows. Next bounded producer assessment is index_of.
