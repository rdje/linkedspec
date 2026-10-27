# Scalar/null value-preserving copy target

Owner: TYPE-REFERENCE-BOOK.1.2.1.4.2.2; authority ADR0138 and the director's
October27 choice. Status: approved implementation target; current backend
qualification remains until each implementation is checked.

## Required values and continuations

For one valid source value, copy(expr) and expr.copy() preserve its existing kind:
Bool false/true, accepted Number values, exact String payload and null/undef.
Copying a missing binding's value remains null and creates no container. Function
copy() with no operand is a different shape; this target does not normalize
existing malformed free calls. Receiver copy takes zero operands; retain existing
pre-effect malformed-method rejection.

Source evaluates once, then compatible consumer operands evaluate in their normal
order. Capture the source before a later consumer rebinds it. Copy is not a truth,
text or numeric conversion: false and0 are retained; String0 retains its String kind; copying never coerces it to Number. Existing
selector policies stay unchanged. Numeric helpers keep rejecting Boolean inputs. Defaults retain
copied false/zero, and explicit Array/Hash defaults may produce container results.

A copy result uses its actual kind for later methods. Incompatible Array/Hash-only
consumers skip their operands after permitted source/copy-prefix effects. Repeated
copy, named/literal/selected/block/function/free-helper/prior scalar-result sources
must follow the same approved primitive-value behavior in already supported roles.
Preserve source exceptions/typed helper diagnostics and existing binding semantics.

## Container, callable and context boundaries

Retain current container-copy depth/detachment/aliasing for each backend/context.
The existing ordinary Perl proof is outer-container copying with shared nested
references; Rust/Dart/Julia/Lua copy their existing runtime containers recursively.
Do not generalize that ordinary Perl proof to every interpreted helper path.
No new callable-copy domain, invocation, captured binding or provenance permission
is granted. Preserve existing opaque/callable behavior and identity guards.

This adds no helper name, alias, new type, mutation operation, generic conversion
or wire format. Scalar-domain extension applies where copy is already available.
Explicit deferred literals retain the grammar boundary repaired by24.1.2.0;
interpreted copy availability/values and existing origin/depth bounds get their
own producer-first check. Do not silently add unsupported context vocabulary.
Computed direct-call selection24.1.2 remains queued and is not part of copying.

## Illustrative target examples (rollout still required)

```text
copy(false)                               # false
copy(0)                                   # numeric0
copy("0")                                 # String0
copy(undef)                               # undef
false.copy().coalesce("late").cat("!")    # "0!"
num_add(1,2).copy().add(1)                  # 4
" A ".trim().copy().uppercase()            # "A"
[].first().copy().coalesce([7]).first()     # 7
```

## Bounded rollout

1. Perl producer1.1 implemented/targeted-checked: typed function copy preserves primitive values without
   weakening Array/Hash snapshots, legacy rule storage, argument/source errors or
   actual-kind result consumers. Keep old observations; new target distinguishes
   primitive identity from old[]/null. Receiver rollout follows separately.
2. Perl receiver1.2 implemented/targeted-checked: generic copy role across primitive/result/scoped continuations;
   malformed-method preflight remains. Existing container consumers/depths stay.
3. Perl context1.3 preserved/targeted-checked: independently assess already-supported interpreted copy helper
   and method paths; fix only actual scalar/result drift without vocabulary or
   callable-origin/depth changes. Close as preserved if already healthy.
4. Rust2/Dart3/Julia4/safe Lua5 implemented/targeted-checked after independently assessing function/method/scalar-result
   and scope/shape/snapshot controls before changes. Lua uses only safe named
   PUC5.5.1/LuaJIT fixtures; declared5.4/full runner remain separate.

Each bounded child compiles and runs the new finite strict-kind/value/effect tests
plus direct copy/result checks, updates the book/current facts and commits. Full
signature/source/context/portable admission, explicit Perl canonical registration,
pressure repair and clean-push canonical CI remain separate under23.4.

Perl context1.3 public native/fresh preservation checks pass without runtime changes.
Existing deferred free copy preserves primitives/null and snapshots; receiver copy
remains unknown_helper/copy there. Invalid free signatures retain their existing
unknown_helper/copy error; logical source errors and copied-callable recursion
origin guards remain. Its wrong-kind take returns[] and skips its count operand,
retaining that executor's prior method policy. Recursive container copying remains
source-observed at CodeblockRuntime::_copy_value; returned equal JSON alone is not
used as depth/identity evidence because invocation/container boundaries also copy.

Rust2 preserves primitive values by cloning the captured RuntimeValue for valid
one-source calls; old empty/extra free-call behavior and Codeblock fallback remain.
Copy uses generic typed receiver dispatch; copied-result continuations guard the
actual kind before every incompatible Array/Hash operand, including subsequent
bridges and with/logical prefixes. Named rule accumulator copying and recursive
container cloning remain. value_copy.rs uses the shared value_copy_values fixtures
plus finite source/shape/selector/legacy controls on native/restored/generated-plan
routes. Only the old scalar/missing/with-copy expectations advance under ADR0138.
No AST/type/wire-format, new callable-copy domain or complete context admission.

Dart3 retains its existing primitive-preserving producer and recursive copying.
Native/restored/plan intake agrees on primitive values/kinds and only exposes
copied-result guard gaps: Number0 runs KV and yields0; copied Hash/Array wrong
consumers yield[]/[1]/AKV. A copied-result flag now initializes for direct free
copy receivers and persists from receiver copy links; the existing guard checks
actual kind before later container-only operands. Shared values/shape/legacy
controls and direct arity/logical/selected tests pass without old oracle changes.
No producer, malformed free-call, container depth, callable or wire-format change.

Julia4 retains healthy primitive-copy production and recursive copying. Native,
plan and fresh-source intake exposes the same copied Number/Hash/Array consumer
guard failures (null/0/SRKV;[]/[1]/AKV) with a recursive oracle that distinguishes
Bool from Number. Direct free-copy receivers initialize copied_result, and method
copy links retain it; existing actual-kind guards now skip incompatible operands.
Shared values/shape/legacy and direct arity/logical/selected controls pass without
old oracle changes. Register value_copy_test.jl in the normal runner; full runner
and complete source/context/portable admission remain deferred.

Safe Lua5 retains healthy primitive/null copy producers and recursive copies.
Both named PUC5.5.1/LuaJIT hosts independently reproduce the copied Number/Hash/
Array guard failures on native/plan/fresh routes, preserving shape/legacy controls.
A local copied_result flag initializes from direct free-copy receivers and persists
from method copy links; the existing actual-kind guard now skips incompatible
operands. Four new strict JSON groups plus direct copy/logical/selected controls
pass on both hosts; module/runner loadfile compiles without new module locals.
The new test is registered; no unsafe patterns/full runner/declared5.4 claim.
All bounded backend children are complete. Full source/context/portable/canonical
admission23.4, declared Lua5.4 and required Perl registration remain separate.
