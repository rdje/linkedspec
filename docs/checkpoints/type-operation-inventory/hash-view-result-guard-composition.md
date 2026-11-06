# Ordinary Hash-view Array result guards

Selection owner: TYPE-REFERENCE-BOOK.1.2.23.1.36. Implementation family76;
P1 independent Perl copy rejection76.0 precedes Perl view guards76.1 and peers.

Existing sorted_keys and sorted_values yield Arrays. Canonical ordinary free-one
and zero-extra receiver forms should feed current Array/selected-kind/scalar
bridges and reject incompatible Hash consumers before operands and later bodies.
Keep key ordering, nested actual kinds, source-once snapshots, errors, valid
empty Arrays/with, copy depth, and each producer's original input policy. No
alias/traversal/deferred/callback/context/signature/schema or unassessed registered-
function receiver authority. Numeric/scalar host isolation retains SESSION17.

Healthy original examples:
    sorted_keys({"b":2,"a":1}).join_values(",")        # "a,b"
    sorted_values({"b":"tail","a":"head"}).last()  # "tail"
    sorted_keys({}).with(){return(value.count())}    # 0; body runs

Required repair target:
    sorted_keys({"a":1}).set_key("k",1)              # null; no host exception
    {"a":1}.sorted_values().set_key("k",1)           # null; compiles cleanly
    sorted_values({"a":1}).set_key("k",1).copy().with(){return("ran")}
                                                     # null; body skipped

Original16 full-source public programs retain seven view failures, a separate
copy-oracle failure and one nonadmitted arity profile. Minimal copy6 distinguishes
three own failures from three healthy controls, including legitimate null that
must still run with. Frozen shared15 projects original14 unchanged sources plus
one qualified constructor control; it was not executed as one original15 baseline.
Frozen copy6 is separate. Each implementation runs its actual unchanged baseline
and freezes independent native/generated errors and excluded profiles first.

Evidence and qualified readonly reader:
docs/checkpoints/hash-view-selection-2026-11-06/REVIEW.md. Original and qualified
review source/channels stay separate; eight evidence corruptions reject. No
production change, peer verdict, full domain/context/portable admission or native/
cache/transitive custody follows. Full23.4 is deferred until feature coverage.
