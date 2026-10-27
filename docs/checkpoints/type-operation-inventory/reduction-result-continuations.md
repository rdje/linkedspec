# Reduction accumulator result continuations

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.1; implementation23.3.21.1-.5.
Feature addition to the existing receiver-only reduce_leaves(initial) { body }.
Current traversal is explicitly terminal; its producer/callback contract stays.
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
