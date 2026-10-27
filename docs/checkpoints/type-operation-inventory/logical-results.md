# Ordinary logical Boolean result continuations

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.17; implementation23.3.17.1-.5.
Authority: ADR0043 and capability_conformance/logical_helper_contract.json.
and/or/not remain ordinary eager free helpers, returning real Boolean values.
No .and/.or/.not counterpart, new truthiness, numeric Bool conversion or lazy
logical method is introduced. Existing receiver and typed-error promises stay
in force; full domain/context/portable admission is separately owned23.4.

## Frozen bounded flow

Actual Boolean results feed compatible existing scalar/text/generic methods.
and(true).cat("!")->1!,and(false).cat("!")->0!; or and not follow the same rule.
False stays selected by coalesce_nonempty and renders0!, not a late fallback.
Typed truthiness keeps nonempty "0"/"false" true, empty aggregates false and
nonempty aggregates true; testing callable values must not invoke them.
Numeric helpers still reject Bool: or(false).add(1) is null and may explicitly
recover to a Number or container with existing defaults. Example:
or(false).add(1).coalesce_nonempty(["a","b"]).last().uppercase()->B.
Container-only consumers reject until an explicit bridge/default returns a
container. and(true).cat(",x").split(",").last().uppercase()->X;
not(false).sorted() and and(true).cat("x").sorted_values() should be null
without evaluating incompatible consumer operands or raising an accidental
container-binding error; this bounded scalar-result rule matches other result
families, and does not change free container-helper policies.
Preserve named/selected/Hash/block/function/literal Boolean source kinds and
captured values. No implicit numeric conversion or Boolean Array-index claim.

Valid logical operands run once, left to right, including decisive and-false
and or-true operands; consumer operands follow the computed Boolean. With
order markers L/R/C, a false-and chain yields0!/LRC with both inputs evaluated.
Lazy controls and lazy defaults keep their separate existing behavior.
Invalid logical source arity reports helper_arity_mismatch before its operands,
even when an operand contains an unknown helper and the result has a compatible
consumer. Do not replace that typed error with an unsupported-helper/null
sentinel. Known consumer-shape policies remain unchanged; no blanket error
precedence for unknown later consumers or new receiver vocabulary is frozen.

## Independent public Perl intake

Retained probe_logical_results.pl uses Get/substitution/dump/native and fresh
emitted routes. Raw producers retain[true,false,true,false,true,false]; direct
fluent/nested text yield[1!,0!,1!,0!,1!,0!]. Named/first/named-Hash/block/literal
sources all produce correct text. False/true defaults retain0!/1!, numeric-null
Array recovery givesB and definedness gives1!. Valid direct/nested eager effects
yield[0!,LRC,2,false]; truthiness String/aggregate controls pass.

The longer text->split->last bridge instead returnsnull. AST preserves the
logical call and four links; substitution emits unsupported-helper:cat where
the captured logical input should be. Fully nested equivalent returnsX. String
chain composition chooses its first consumer family and rebuilds aggregate DSL
without a typed logical-result boundary; explicit actual scalar dispatch is the
repair seam, not a change to RuntimeLogical producers.

Logical->text->Hash-only boundary leaves raw and(true).cat syntax: the
standalone form silently returnsnull, while the compound form fails handler
compilation. Direct not(false).sorted() returnsnull with binding_kind_mismatch
instead of clean scalar rejection; native context and fresh error identify
BindingRuntime::array_transform on the emitted Boolean. Malformed not(two).cat with
unknown fail operands returnsnull/unsupported-helper:fail; direct/nested forms
raise the typed arity error. Known valid-helper effect operands still raise the
correct error. MethodLowering's first_unknown_value_call_name scans source
operands before lower_ast_logical_call_node validates the source arity. Preserve
that typed validation before traversing invalid operands. No normalization of
existing valid eager input/producer/default behavior is needed.

Direct logical contract fixture passes eight top-level subtests, including
existing neutral values/effects/with receiver/lazy contrast and typed errors.
Backend implementations must assess their own public producers before changing
confirmed result/scalar/diagnostic gaps; no backend failure inferred from Perl.

## Bounded Perl implementation

23.3.17.1 validates malformed logical source arity before unknown-operand
scanning, then materializes valid logical sources through existing typed
RuntimeLogical lowering. Their ordinary chains use scalar actual-result
classification and existing selected/Array dispatch; each emitted helper is
finished through the established host-expression compatibility bridge before
the next link. Dedicated with/traversal normalization stays on its prior route.
No generic authored raw fallback or helper vocabulary is widened.

Retained logical_result_receiver_values source/JSON and native/fresh test pass
raw Bool/false defaults, six text/nested results, strict truthiness/numeric-null,
all source families, all three split bridges, Number/Array/Hash defaults and
clean incompatible boundaries. Eager and/or LRC and not SC/call counters/source
snapshots hold. Five malformed source cases preserve typed helper/arity/zero-
evaluated fields, including unknown fail and known print operands. Public
retired Hash fat-arrow validation still rejects in the new composition route.
26 top-level checks across new logical results, existing logical contract and
literal-default fixtures plus module/test syntax pass after retained RED. New
Perl test requires explicit23.4.1 canonical registration; full admission open.

## Bounded Rust implementation and rejected-effect follow-up

23.3.17.2 independently confirms raw Bool/typed truth/strict numeric-null,
nested/LRC and source arity diagnostics; shared valid bridges already work.
Only direct logical->sorted returns[] rather than scalar null. Known logical
call receivers now evaluate once into shared selected scalar-result dispatch,
after existing trailing-block handling. Six focused tests across new producer/
shared/error/rejected-effects and direct default/named neutral consumers pass
native/restored/in-process plan with offline compilation/rustfmt; no fresh
standalone emitted Rust claim.

A direct-dependent check finds Perl17.1's new terminal return drops its current
source expression: effectful and(...).sorted() yields[null,0] versus nested free
[[],1]. The difference concerns source evaluation, not a new free-helper result
normalization. Retained probe_logical_rejection_effects.pl/public substitution
and logical_rejected_consumer_effects spec/JSON show the mechanism and expected
LR/LRC/S/null/no-consumer-operand controls, already passing Rust. Immediate P1
Perl17.1.1 repairs this newly introduced regression before Dart17.3. Existing
valid-chain fixture remains passing; it omitted effects before rejected tails.

## Perl rejected-effect repair

17.1.1 fixes the new17.1 regression: when a known incompatible consumer yields
terminal rejection, bind the previous emitted logical/prefix expression once
in scalar context before returningnull. Consumer operands remain untouched.
Shared native/fresh rejection-effect RED loses LR/LRC/S; GREEN retains all three
and skips take's A operand. Perl-only malformed sorted(1) still rejects before
source effects.24 focused checks across rejected effects/current logical result
and error regression plus module/test syntax pass; no truthiness/free/container
helper normalization. Both new Perl logical tests require23.4.1 registration.
The temporary rejected-effect limitation is repaired; Dart17.3 is next.

## Bounded Dart implementation

17.3 confirms producer/eager truth/numeric-null and typed source errors before
production. Valid bridges/defaults already work; actual Boolean container
fallthrough yields[] and executes an incompatible take operand (SA). Selected/
block/literal Boolean controls also yield[] on sorted. Mark actual Bool scalar
at fluent entry and after every result; existing container outputs release the
boundary. Preserve free/named-context normalization and every logical adapter.
Fifteen focused native/restored/plan/new/direct/default tests, format and fatal
selected analysis pass. Shared source effects retain LR/LRC/S and skip consumer
operands; five malformed logical calls keep typed errors. No standalone or
complete domain/context/portable admission. Julia17.4 is next.

## Bounded Julia implementation

17.4 independently confirms real Bool/typed truth/strict numeric-null producers,
valid source/default/bridge flow and all typed source errors. Shared/rejected-
effect/actual selected-block-literal controls expose[] boundaries andSA on
native/plan/fresh. Initial and post-result Bool scalar tracking repairs these,
retaining actual-container release and existing free/named-context policies.
214 focused assertions (new100/direct defaults9/three neutral fixtures105) pass
with strict compilation and explicit Bool identity/Number-not-Bool counters.
LR/LRC/S effects and skipped consumer operands hold; no full suite/portable
admission or callback-identity repair is claimed. Safe Lua17.5 next.

## Bounded Lua implementation

17.5 independently confirms canonical Bool/nested/eager LRC/numeric-null and
five typed source errors native/plan/fresh on PUC5.5.1/LuaJIT before code. Shared
RED has container[] at scalar boundaries; valid flow/snapshots already work.
Actual Boolean tracking at entry/after results repairs this with no new module
locals, preserving container release and free/named-context/truth/error policy.
Strict canonical JSON/shared/default/bridge/rejected LR-LRC-S/no-consumer-
operand/actual selected-block-literal controls and three exact neutral fixtures,
direct defaults and source loads pass both hosts. All five bounded logical
implementations are targeted-checked; no full runner/malformed native patterns,
declared5.4 or complete domain/context/portable admission. Next helper-spine
assessment23.2.18 owns defined-only coalesce receiver/result breadth, retaining
this contract and older nonempty-default exclusions until a separate freeze.

October27 selection23.1.3 separately freezes logical-receiver-methods.md and owns
new .and/.or/.not counterparts under23.3.23. This does not retroactively expand
family17 or change free truth/eager/arity/error/result rules; new method/full
context/portable admission stays separately scheduled.
