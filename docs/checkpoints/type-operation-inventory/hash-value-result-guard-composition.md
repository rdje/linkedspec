# Ordinary Hash-valued helper result guards

Selection owner: TYPE-REFERENCE-BOOK.1.2.23.1.37. Independent backend family77.
This freezes existing value-result composition, not new helper authority.

Selected ordinary pure roles:

| Helper | Free positional operands | Receiver positional operands |
| --- | --- | --- |
| merge_hash | source, overlay | overlay |
| set_key | source, key, value | key, value |
| rename_key | source, old key, new key | old key, new key |
| drop_keys | source, one or more keys | one or more keys |
| pick_keys | source, one or more keys | one or more keys |

These existing producers yield Hash values. Preserve their compatible Hash
consumers, explicit Array/selected-kind/String bridges, nested Bool/null/Number
values, source-once evaluation and snapshots, empty Hash with bodies and required
producer errors. An incompatible Array consumer rejects to null before its
operand, and rejection skips later copy/logical/with operands and bodies.

    merge_hash({"a":1},{"b":2}).count_keys()            # 2
    {"a":1}.rename_key("a","b").sorted_keys().join_values(",") # "b"
    pick_keys({"b":"tail","a":"head"},"b").sorted_values().last().uppercase()
                                                       # "TAIL"
    pick_keys({"a":1},"missing").with(){return(value.count_keys())} # 0
    drop_keys({"a":1,"b":2},"a").take(1)             # null; incompatible

Every implementation child first acquires its own unchanged28-source baseline
and the affected helpers' actual initial Number/null/Array policies, needed
errors and excluded-arity/key-list profiles. Keep these producer/source fences
separate from result guards. Earlier Perl view76.1 regressions repaired by76.6
are the reason this prerequisite cannot be inferred from peer results.

Preserve copy depth, source independence, key ordering, splice/key-list handling,
backend collision policy and original source/arity/errors. Rename controls use
an absent destination; existing destination collision normalization stays with
BACKEND-PARITY-BACKLOG.5. set_key value expressions and receivers are pure here;
its bare statement and indexed operator mutations retain their existing owners.
flat_hash returns a list-splice role and is excluded. No keyword, unknown method,
traversal, non-with trailing block, deferred/callback or unassessed registered-
function receiver expansion. Do not promote zero-key drop_keys/pick_keys forms.

Original public Perl32 selection contains28 ready/raw0/fallback0/unresolved0
eligible programs: fifteen actual failures and thirteen healthy preservation
controls. The shared fixture is exactly those28 unchanged sources and authored
targets, including needed-error targets that currently fail during compilation.
Four separate zero-key forms are unready/unresolved-helper profiles, not portable
canonical examples. Each peer assesses independently; no backend verdict follows
from Perl. Original32 actual modules/handlers/full channels and input custody:
docs/checkpoints/hash-value-result-selection-2026-11-07/. Full source/context,
native/cache/transitive custody, broad isolation and full23.4 admission stay open.
