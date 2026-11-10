# Ordinary pure Array-pipeline result guards

Selection: TYPE-REFERENCE-BOOK.1.2.23.1.39. Implementation family79.
Unchanged source/target fixture: tests/fixtures/array_pipeline_result_guard_cases.json.

Existing split_each, trim_each, filter_nonempty, lowercase_each, uppercase_each,
uniq and filter_match produce Arrays in value/receiver positions. Canonical forms
are free-two/receiver-one for split_each/filter_match and free-one/receiver-zero
for the other five. Their Array results must retain actual-kind guards through
current consumers, copy, logical helpers and immediate with. Wrong Hash consumers
return null before operands, and later bodies stay skipped. Legitimate empty Arrays
still enter with; selected String/Number bridges remain useful.

Examples of the existing target behavior:

```text
trim_each([" tail "]).last().uppercase()        # "TAIL"
split_each(["head:tail"],":").join_values(",")   # "head,tail"
uniq(["head","head"]).set_key("k",1)           # null; no host exception
[" tail "].trim_each().set_key("k",1)          # null; compiles cleanly
filter_nonempty([""]).with(){return(value.count())} # 0; body runs
```

Preserve pure values/receiver source containers and separate named standalone
writeback. Each backend independently acquires initial Number/null/Hash producer
policies, canonical/excluded arities and required source/delimiter/pattern errors
before edits. Earlier produced/selected/copied guards stay independent. Source
once/snapshots/order, nested actual kinds, scalar text/Unicode/regex/coercion,
deduplication, empty behavior, copy depth and statement/operator/end mutation keep
their existing contracts. A source-isolation defect is an owned prerequisite, not
an accepted producer policy; split before production if needed.

No other transforms, list-splice/constructor-context changes, aliases, keywords,
traversal, non-with trailing/deferred/callback or unassessed registered-function
receiver authority. Preserve neutral formats/parser/arity and backend differences.
Do not import a peer's original failure, source policy or error framing.

Original Perl36 exposes17 failures/19 healthy controls. Seven literal receivers
have ready0/unresolved1 and compile failures; ten free/later results have runtime
Hash-copy errors. All four needed errors already propagate. Actual module/handler
bytes and full first source/grammar/instrument/channel inputs survive; first
readonly0/empty stderr/eleven effective controls passes. Evidence:
docs/checkpoints/array-pipeline-result-selection-2026-11-10/REVIEW.md.

Each backend completes focused checks/docs/normal commit before the next owner.
Full source/context/portable/registration/native-cache-transitive-toolchain
custody4.2/SESSION5/declared5.4/full23.4 admission remains separate after feature
coverage. Historical recovery is not a latest-runtime or peer verdict.
