# Ordinary Array transform result guards

Selection owner: TYPE-REFERENCE-BOOK.1.2.23.1.38. Scoped implementation family78.
This freezes existing value-result composition, not new helper authority.

| Selected producer | Existing free positional operands | Receiver operands |
| --- | --- | --- |
| take, take_last | source[, n] | [n] |
| drop_front, drop_back | source[, n] | [n] |
| slice | source, start[, n] | start[, n] |
| sorted, reversed | source | none |
| concat_arrays | source, second Array | second Array |

The shared37 targets use explicit count1 and slice start1/count1. Existing optional
forms retain their published/source policies; acquire them independently before
production rather than normalizing arity from peer output. Other Array transforms,
flat_array/flat list-splice roles, aliases, mutation/statement forms, keywords,
unknown methods, traversal, non-with trailing, deferred/callback and unassessed
registered-function receivers remain outside this selected family.

Selected producers yield Arrays. Preserve compatible Array consumers, selected
String/Hash bridges, nested Bool/null/Number values, source once/snapshots/order,
valid empty Array with bodies and required producer errors. Incompatible Hash
consumers reject to null before operands, and rejection skips later copy/logical/
with work. Constructor rejection is the existing distinguishing oracle.

    take(["head","tail"],1).last().uppercase()          # "HEAD"
    reversed([{"k":"tail"}]).last().pick_keys("k").count_keys() # 1
    sorted(["b","a"]).join_values(",")                # "a,b"
    take(["tail"],0).with(){return(value.count())}       # 0; body runs
    take(["head","tail"],1).set_key("k",1)            # null; incompatible

Every backend first acquires its own unchanged37 on public native/restored/plan/
fresh routes as applicable and its own initial Number/null/Hash and optional/
excluded-arity/needed-error fences before production. Preserve first producer
fallbacks/errors and earlier produced/selected/copied guards separately. Keep
count/start coercion, sorting/copy depth/source independence, Array construction/
splices, statement/operator/end-mutation and established backend differences.
No peer verdict or portable wrong-kind/arity/depth normalization follows.

Original public Perl37 all report ready1/raw0/fallback0/unresolved0. Nineteen
selected targets fail: eleven free/later programs raise Not a HASH reference at
set_key's unguarded copy; eight literal receiver programs retain raw DSL and fail
handler/module compilation. Eighteen healthy controls retain compatible results,
bridges, nested kinds, source once/snapshot, empty with, four required source/count
errors and constructor rejection. Required errors already propagate on Perl.
The shared fixture is the exact unchanged37 source/target projection of that
original intake, never a re-blessed runtime or compilation failure.

Full source/context/domain/portable admission, native/cache/transitive/toolchain
custody4.2/SESSION5, general isolation, canonical registration and full23.4 remain
separate. Each implementation owns focused proof/commit before the next backend.
