# String-predicate source and prefix guards

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.31; independent implementations70.1-.5.

Preserve the existing starts_with/ends_with/contains_substr/matches producers and
their source/operand domains. Only canonical two-operand positional free calls
and ordinary one-operand prefixes join current actual-kind/rejection guards.
Keep regex literal operands and flags on their existing typed representation;
this adds no regex operation, dynamic pattern promise, context or serialized field.
The three text predicates return numeric1/0 on the checked backends. matches
returns numeric1/0 on Perl and Boolean on the native peers. Preserve that difference.

Required examples:

```text
starts_with("abc","z").take(1)                       # undef
"abc".ends_with("z").take(1).with(){return("ran")}    # undef; body skipped
"abc".matches(/^z/).cat("x").split(",").set_key("k",1).with(){return("ran")} # undef
starts_with("abc","z").cat(",x").split(",").last().uppercase() # X; already healthy
```

Source then operand then consumer evaluation/snapshots remain once/ordered.
Required SO prefix effects stay before a rejected consumer; rejected operands and
later bodies skip. Legitimate false/null/empty with inputs and actual returned
Array values remain valid. Keep copy/default/generic/strict arithmetic and needed
source errors. Do not normalize producer flags, free signatures, unknown names,
aliases, traversal/deferred/callable/context rights or full text/regex domains.

Shared22: tests/fixtures/string_predicate_result_guard_cases.json. Four existing
expected_nonperl profiles preserve numeric/Boolean kinds and repeated-definedness
false text; three are directly qualified by a public producer profile on all
backends, the fourth follows existing28.0/native-peer authority. Every backend
independently baselines guard behavior before production. Excluded18 public syntax/
lowering snapshots are source fences, not exhaustive excluded-runtime proof.

## Selection evidence

Selection31 freezes existing String-predicate result source/prefix guards70 for starts_with/ends_with/contains_substr/matches, canonical free-two/ordinary one-operand only. One public Perl22 Get/descriptor/substitution/full-emission/native-fresh intake yields thirteen ready healthy values/seven ready wrong groups/one matching-null unsupported-with unready/one qualified needed source error, raw0/fallback0/warnings[]. Free guards yield[]/Hash{k:1}/KV, free-with SOW, receiver-with drops SO/runs W, variants WWWW/function WX; receiver bridge is unsupported-with while free cat-split bridge already works. Actual substitution exposes Array fallback, Hash dispatch on predicate scalar, with(undef) normalization and unsupported with; current pure String transform/free/prefix source lists exclude predicates, despite scalar_result method metadata. Public canonical4/excluded18 syntax/lowering observations retain regex operand kind=regex/flags=i. Freeze selected helpers through current emitted/scoped-with/intermediate actual-kind guards, preserving source then operand then consumer SOC snapshots, domains/arity/copies/defaults/strict numeric/generic/valid null-empty with/returned Array/errors/function caller state. One additional finite public producer profile independently qualifies all five backends on available native/restored/plan/fresh routes and both Lua hosts: three text predicates retain numeric1-0, matches retains Perl numeric versus native Boolean, strict arithmetic/null-empty/literal i remain. Three kind profiles directly checked; fourth repeated-definedness false-text profile adopts existing28.0/native-peer authority. All observer exits0 establish transport, not feature acceptance. Exact declared source/authority/producer/case identities before-after, not complete transitive closure; actual temporary Cargo-consumed example is bound, retained then removed. Shared22/four profiles/excluded18/target/card/book/map/task/roadmap/live/resume/history and actual instruments/source/raw channels retained in string-predicate-guard-selection-intake.json.gz. Create independent Perl70.1/Rust70.2/Dart70.3/Julia70.4/safe Lua70.5 before production. No runtime production change, peer guard failure inference, producer or regex/domain normalization, deferred/context/alias/unknown/traversal/schema/full23.4 admission.
