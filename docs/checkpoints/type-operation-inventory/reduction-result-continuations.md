# Reduction accumulator result continuations

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.1; implementation23.3.21.1-.5.
Feature addition to the existing receiver-only reduce_leaves(initial) { body }.
At freeze traversal is explicitly terminal; its producer/callback contract stays.
This bounded result feature is not full signature/context/portable admission23.4.

## Frozen bounded feature

After a valid reduction finishes, its actual final accumulator may feed existing
compatible scalar/numeric/String/generic/Array/Hash methods. Empty valid roots
return the initial accumulator with its kind intact. Null and false remain real
values; use existing lazy defaults/strict numeric or text rules, never truthy
fallback or implicit scalar-to-container conversion. Array/Hash results keep
independent copied values and may feed selection followed by scalar methods.

Keep current root-kind traversal: Array roots recurse through Arrays in index
order with Hash leaves; Hash roots recurse through Hashes in sorted-key order
with Array leaves. Scalar/null roots return null and skip initial/callback.
Preserve callbacks, scoped value/index/key/path/depth/acc restoration, block-local
return, copied source/paths/accumulators, ordinary outer effects and errors.
Restore callback bindings before evaluating continuation operands.

Capture a source once, evaluate the initial once only for a valid root, run the
existing callbacks in order, capture the actual result, then evaluate compatible
consumer operands. Later initialization/callback/consumer source rebinding must
not change the captured tree or result. Wrong-family container consumers retain
permitted source/initial/callback/prefix effects and skip incompatible operands.

Exactly one parenthesized initial plus immediate trailing block is required;
preserve malformed-shape rejection before source/initial/callback/consumer effects.
No free reduce_leaves helper, deferred callback/context expansion, new Codeblock
method table, traversal policy, mutation bang method or global conversion change.
Other traversal/mutation paths keep their dedicated implementations.

```text
[1,[2,3]].reduce_leaves(0) { return(acc.add(value)) }.add(1) # 7
[1,[2,3]].reduce_leaves([]) { return(concat_arrays(acc,[value])) }.last().add(1) # 4
[1].reduce_leaves({}) { return({"key":"B"}) }.sorted_values().first().lowercase() # b
[].reduce_leaves(false) { return(true) }.cat("!") # 0!
[1].reduce_leaves(0) { return(undef) }.coalesce("fallback").uppercase() # FALLBACK
```

## Public pre-feature Perl distinctions, October27

Retained probe_reduction_results.pl uses public Get/runtime context/dump, AST and
call_spec_handler_subst plus independently loaded fresh emitted source. Producer
results match native/fresh: [6,ab,[1,2,3],{key:B},false,null,[empty],3]. Nested
num_add(reduction,1) gives7. Appended numeric/Array/Hash consumers instead give
null. The AST retains the reduce callback and add link; substitution is exactly
return undef. MethodLowering tree return classification/returned pair and Hash
method metadata explicitly say terminal; this is a selected feature gap.

Healthy source/initial/callback control gives[3,SILL,1,[9]], proving source capture
before initial rebinding. The appended cat version gives[null,empty,0,[1,2]]:
terminal rejection skips the complete chain. Invalid scalar-root control gives
[null,S], skipping initial/callback. Its appended coalesce variant retains raw
DSL and fails compilation; the existing emitted-default chain bypasses dedicated
traversal. Own that boundary when implementing compatible reduction dispatch.
Malformed zero/two-initial controls give[null,null,empty] without effects.

These are deterministic authored distinctions, not measured coverage. Backend
children independently establish producers and RED/GREEN on their public routes;
no backend result follows from another's implementation. Perl21.1 first, then
Rust21.2, Dart21.3, Julia21.4 and safe Lua21.5. Preserve declared Lua5.4/malformed
native pattern exclusions and full context/standalone admission ownership.

## Perl21.1 bounded implementation

Use the existing actual-kind default_result bridge for reduction results and a
separate first-step tree_source state. Keep reduce chains on dedicated traversal
rather than the generic emitted-default path. Callback/root/initial code remains
unchanged. A first implementation preserves every shared value except scalar
rejection prefix effects; public rejection_prefix shows return undef and no
effects. Bind the valid emitted prefix before returning null, skipping operand A.

Twelve native/fresh shared/direct traversal checks and source syntax pass after
RED. Shared exact kinds/typed indices, numeric/text/container/generic/default
consumers, named/reversed roots, source/initial/callback/consumer snapshots, scoped
restoration, invalid-root skipping, shape no-effects, copies and SIL/SILC rejection
are retained. Admitted Array/Hash walk/map/plain reduce and path order pass. New
Perl test registration is owned by23.4.1 before full admission/push. Rust21.2 is
independent next; no full context/deferred/standalone/portable admission follows.

Immediate traversal consumers also reuse the dedicated lowerer from dynamic
results. A public pre-route Array reduction/map case fails native/fresh callback
brace compilation; the bridge had excluded traversal blocks. The shared field
[3,B,b,4,4] now passes Array/Hash accumulator mapping, another reduction after a
pipeline, and reduction from a coalesced container. The final twelve-assertion
fixture passes native/fresh with those added transitions; no deferred/bang policy
change or independent backend admission is inferred.

## Rust21.2 bounded implementation and shared fixture boundary

Existing producer/direct traversal controls pass native/restored/in-process plan.
Core compile rejects malformed zero/two initials as callable_contract_arity_mismatch
before execution; preserve that admitted signature behavior. Shared fixture now
contains valid shapes only. Local permanent malformed controls retain both Rust
compiler rejection and Perl null/no-effects; reference Perl eighteen checks pass.
Their phase/diagnostic parity discrepancy is owned1.2.1.4.1 after ordinary feature
coverage and before signature/23.4 admission, not normalized in this result feature.

Valid continuation RED is terminal null/binding-kind failure; a small effect case
gives[null,SILL,1,[9]]. Remove the terminal fence, keeping dedicated callback and
dynamic dispatch, then check actual reduction-derived kind before container-only
consumer operands. The shared fixture then isolates an older producer defect:
invalid scalar-root initial still runs (SIC); independent scalar/null controls
give SII instead of S. A reduce-only invalid-root guard after shape validation
and before initial/callback evaluation fixes that existing contract violation.

Six focused Rust tests pass native/restored/in-process plan after RED, including
exact shared results/kinds/typed index0/copies, immediate traversals/coalesced and
repeated reductions, snapshots/scope/effect rejection, direct root/path controls
and preserved compile-time malformed errors. Offline compile/selected rustfmt pass.
No serialized-schema/global conversion/callback body, standalone/deferred/context/
bang policy or full admission change; Dart21.3 independently follows.

## Dart21.3 bounded implementation

Producer/value/immediate traversal/copy/scope/source-order and invalid-root tests
already work independently on native/restored/plan. Shared RED is direct scalar
rejection []/SILA; independent Array-to-Hash and Hash-to-Array consumers give
[]/SILKV and []/SILA. The dynamic loop omits reduction scalar-result metadata and
knows scalar status without reduction-derived container-family guards. Add that
metadata and actual kind checks before incompatible operands, preserving all
existing traversal/root/initial/callback/copy/global conversion bodies.

Seven focused tests plus format/fatal selected analysis pass after RED, retaining
shared exact kinds/typed indices/immediate/repeated/coalesced traversals/copies/
scoped SI(L*)C; rejected scalar/prefix/opposite-family cases retain SIL/SILC and
skip operands. Valid root/path/direct producer controls stay passing. Dart static
malformed errors match Rust's phase and remain within1.2.1.4.1 parity scheduling.
No full context/deferred/bang/signature/portable admission; Julia21.4 follows.

## Julia21.4 bounded implementation

Independent strict producer/scope/source-order/root-skipping/traversal and static
malformed controls already work native/plan/fresh. Shared RED is scalar take
Any[]/SILA; opposite container kinds give []/SILKV and []/SILA. Add reduction
may-produce-scalar metadata and actual Array/Hash-only consumer admission before
operands, including existing Array-only numeric reducers. Keep dedicated traversal
and callback/root/initial/copy/global conversion bodies unchanged.

Registered forty-three strict assertions pass after RED, retaining Number-not-
Bool/false/counter identity, typed indices/copies, immediate/repeated/coalesced
reductions, scoped SI(L*)C and clean SIL/SILC/opposite-family rejection. Direct
Array/Hash root/path controls and strict compilation pass. Julia's compile-time
malformed errors join1.2.1.4.1 scheduling. Full signature/context/portable and
deferred/bang admission remain separate; safe Lua21.5 independently follows.
