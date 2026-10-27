# Ordinary eager logical receiver methods

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.3; implementation23.3.23.1-.5.
This is a new ordinary receiver counterpart family. The earlier logical result
family17 deliberately excluded these spellings; its free-helper contract remains.
Authority for truth/evaluation/Boolean results is ADR0043 and unchanged
capability_conformance/logical_helper_contract.json. New method shapes below are
owned by this bounded comprehensive-method feature, with full admission23.4 later.

## Frozen target

- value.and(rhs, ...) and value.or(rhs, ...) require at least one authored positional RHS.
  They express binary/variadic composition. The existing free and(value)/or(value)
  one-argument Boolean projection stays unchanged; no empty receiver projection.
- value.not() has zero authored operands and negates the receiver's typed truth.
- These methods accept the same existing value kinds/truthiness as their free
  counterparts. They are generic truth operations, not String/Array input methods
  merely because a resolver or dispatch loop stores their names there.
- Source then every valid RHS evaluates once left-to-right, including after a
  decisive false-and or true-or value. Preserve earlier snapshots against later
  rebinding and existing value-copy bounds. Consumer operands follow the computed
  Boolean; testing an already-admitted callable value never invokes it.
- Every valid result is real Boolean. Preserve false through defined/nonempty
  defaults and existing scalar text rendering. Numeric helpers/indices do not
  gain implicit Boolean conversion. Compatible scalar/generic/default/explicit
  container-result chains use the actual returned kind.
- Incompatible Array/Hash-only consumers reject before their operands while
  retaining permitted valid prefix effects, following current result-family rules.
- Reject malformed new method shapes before source/RHS/consumer effects under
  each backend's existing ordinary-method shape policy. Keep free-helper typed
  helper_arity_mismatch and valid-method source failures unchanged; do not invent
  a global error-precedence rule for unrelated invalid/unknown later consumers.
- Operand { ... } expressions remain ordinary eager values, not callbacks.
  No new free helper, lazy operator/control, callable literal, context/deferred
  vocabulary, mutation/bang form, truth policy or serialization format is added.

```text
false.not().and(true).cat("!")                         # "1!"
false.or(true).not().coalesce("late").cat("!")          # "0!"
[].not().cat(",x").split(",").last().uppercase()        # "X"
"0".not()                                               # false (nonempty text)
zero=0;zero.not()                                        # true (numeric zero)
```

Assess named/literal/selected/block/function/prior-result inputs, actual Bool/
null/Number/String/Array/Hash kinds, multi-method logical chains, empty/zero/false,
eager SRTC/SDC order and snapshots, unchanged bindings/copies, malformed shapes
and direct free helper/typed error/lazy-control preservation. Codeblock truth is
existing model/backend-unit authority; do not use this feature to admit separately
owned explicit literals, callbacks or deferred receiver methods.

## Public Perl intake, October27

probe_logical_receivers.pl uses public Get/runtime context/substitution and
independent fresh emitted execution. Free producer gives real Booleans
[false,true,true,false,true,true,false,true,false] on both routes, covering ordinary
composition, String zero, numeric zero and empty/nonempty containers.

Method forms instead leak raw authored .and/.or/.not to host code. Basic and typed
controls fail handler compilation/fresh loading; eager source/RHS/shape bodies also
leak raw DSL. A longer not/coalesce chain loads but calls an undefined host coalesce
because its logical prefix never received value lowering. This is failure evidence,
not a coalesce producer/domain change. Substitution shows the exact unlowered input
methods while current free logical ownership remains healthy.

Perl23.1 first adds the new method role by reusing typed logical producers, then
Rust23.2, Dart23.3, Julia23.4 and safe Lua23.5 independently assess before changes.
Only ordinary feature checks/compile/docs/commit per child; full signature/context/
portable admission, canonical registration/error parity/pressure repair and declared
Lua5.4 remain separate. Do not infer other backend failures from this Perl intake.

## Bounded Perl implementation

23.3.23.1 validates ordinary shapes before effects and folds new logical links
into existing typed call AST, preserving source/prefix/RHS nodes. Generic kinds
reach RuntimeLogical directly; Boolean result consumers reuse existing lowering.
Shared/local native/fresh PASS20 top-level tests including typed source-error
subtests, after observed raw-DSL RED. Existing logical result/rejected-prefix
checks PASS24 and source syntax passes. SRTC snapshots, real Bool/false/default,
numeric rejection/explicit Array recovery, source containers and malformed
no-effects remain. Free invalid sources retain typed helper/count/zero-evaluation
errors through the new methods. Rust23.2 independently assesses next; full new
method/domain/context/portable admission/canonical registration remains separate.

## Bounded Rust implementation

23.3.23.2 admits generic receiver/scalar-result roles and method shape preflight,
reusing eager receiver_call_args and typed producers. Producer/source errors are
healthy before changes. After those roles, an existing-with prefix yields the
correct Bool/restored scope but its Array consumer still runs; the scoped loop
now guards logical-prefix actual kinds and scalar copy while permitting recovered
Array/Hash copies. Existing reduction-only copy policy remains. Seven new native/
restored/plan plus four direct logical-result tests pass, with exact generated
helper/count error tokens and rustfmt/offline compilation. No serialized model,
free truth/error/lazy or callback admission changes; Dart23.3 independently follows.

## Bounded Dart implementation

23.3.23.3 preflights ordinary positional shapes, stages copied source then eager
RHS and shares evaluated-value logical composition with unchanged free helpers.
Existing actual-Bool/result/scope guards already suffice. New tests PASS9 native/
restored/plan plus direct logical-result PASS9; format/fatal analysis pass. Preserve
Dart Bool/value copies: pre-change and(true).copy()/true.copy()/copy(false) gives
true/true/false; its with/logical copy result stays true while Rust's guarded scalar
copy gives null. Current domains/depths are already backend-qualified in copy facts.
This family does not silently choose a universal scalar-copy domain: P2
TYPE1.2.1.4.2 must resolve authority and own required repairs immediately after
family23, before coverage/admission closure. Julia23.4 independently follows.

## Bounded Julia implementation

23.3.23.4 independently finds valid receiver/pure dispatch, eager typed snapshots,
Bool/result guards, source errors and with/value-copy behavior already healthy.
Only malformed shapes run effects/unknown operands. Add positional one-plus RHS
and/or and zero-RHS not preflight. Registered native/plan/fresh strict test PASS109
plus direct logical-result PASS100 and strict compilation; no producer/free/copy/
callback/model change. Julia retains Bool copies like Dart. Safe Lua23.5 next;
copy-domain owner1.2.1.4.2 follows this family before coverage/admission closes.

## Bounded safe Lua implementation

23.3.23.5 finds healthy free producer/copy/error controls but fluent calls drop
the receiver. The existing eager logical evaluator now stages a false-safe copied
receiver and counts all operands; fluent dispatch reuses it and ordinary logical
shapes preflight before effects. Both safe PUC5.5.1/LuaJIT hosts pass eight strict
JSON native/plan/fresh groups plus two source-error cases and direct logical-result
checks. Source/runner load checks pass without new module locals or unsafe native
patterns/full runner. Existing scalar copies remain value-preserving. All five
bounded logical backend children are targeted-checked; scalar-copy1.2.1.4.2 follows,
with full method/domain/context/portable admission/canonical/parity/pressure and
declared Lua5.4 prerequisites separate.
