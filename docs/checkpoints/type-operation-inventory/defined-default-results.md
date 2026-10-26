# Defined-only default receivers and selected results

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.18; implementation23.3.18.1-.5.
This is a separate bounded counterpart to the existing free coalesce helper.
The old default-selection-results.md scope explicitly excluded it. Existing
free helper signatures, compatibility and lazy behavior remain unchanged;
complete operand-domain/context/portable admission remains23.4/62.3/.62.4.

## Frozen bounded counterpart

value.coalesce(fallback, ...) requires at least one fallback. Evaluate the
receiver once, then fallback expressions left to right only until the first
defined value. Empty String, numeric zero, false, empty Array and empty Hash are
defined. Only null/undef advances selection; exhaustion returns null/undef.
Preserve the selected actual String/Number/Boolean/Array/Hash kind and ordinary
copy/snapshot behavior. No implicit numeric Bool conversion, truthiness test,
new Regex/callable/deferred/scoped receiver domain or Codeblock table follows.

Compatible scalar/generic consumers and explicit bridges continue from the
actual result. Array/Hash consumers work after a container selection; a retained
scalar followed by a container-only consumer returns null without evaluating
that incompatible consumer's operands. Preserve the source and all valid prefix
effects once. A known malformed zero-fallback receiver returns null before
source or later-consumer effects; do not infer a free zero/one-argument policy.
Existing malformed consumer and static unsupported-expression validation stay
unchanged. Skipping an unused supported expression's runtime failure does not
authorize unknown helper syntax in a fallback.

```text
undef.coalesce(" chosen ").trim().uppercase() # CHOSEN
"".coalesce("late").cat("!")                 # !
0.coalesce(7).add(1)                          # 1
false.coalesce(true).cat("!")                 # 0!
undef.coalesce(undef)                         # null
undef.coalesce(["a","b"]).last().uppercase() # B
undef.coalesce({"b":"b","a":"a"}).sorted_values().first().uppercase() # A
[].coalesce(["late"]).count()                 # 0
{}.coalesce({"late":1}).count_keys()           # 0
"kept".coalesce(["late"]).sorted()            # null
```

Cover ordinary named/selected/Hash-selected/block/function/helper/prefix roots,
including null produced by invalid numeric operations. A selected Number must
remain usable as an Array index. Capture a selected Array/Hash before a later
consumer mutates its original binding. Source-S, chosen-default-D, consumer-C
must yield SDC with one source evaluation and no unused late-L. Unused fallback
side effects and runtime failures remain skipped for defined empty/zero/false.

## Public Perl intake before production

Retained probe_defined_default_results.pl uses public Get, AST/substitution/
dump and independent fresh emitted execution. Free producers return
[fallback,"",0,false,null,[2,3],{a:a,b:b}]; nested scalar consumers give
[CHOSEN,!,1,0!,CHOSEN]. Nested Array/Hash selections give B/A; defined retained
empty/nonempty aggregates give[0,0,B,A]. Free numeric selector writes preserve
the selected Number kind. Copy controls retain selected original[a,b]/{a:a,b:b}
after original bindings mutate to[z,b]/{a:z,b:b}.

The explicit nested captured-selection control gives[A:B,SDC,1,1,[z]];
consumer mutation cannot change the earlier selected snapshot. Use an explicit
chosen variable here: free join_values takes delimiter before items, so a
delimiter-first nested spelling would not be a source-first receiver oracle.
Lazy nested controls return["",false,0,safe,0], skipping unused effects and a
real supported typed write failure. Free coalesce("kept") currently returns
null on Perl, matching its minimum-two operand metadata; no zero-RHS identity
receiver is inferred from it.

New receiver spellings remain raw DSL and produce host compile/eval failures,
including missing host coalesce in numeric selector/exhaustion controls. AST
retains coalesce/trim/uppercase and numeric/selected source links. MethodLowering
has complete lazy typed lowering for both free defaults, but only nonempty
default receiver-family metadata. This is missing useful receiver scope, not
retroactive breach of the old explicit exclusion. Initial combined output had
an interleaved failing JSON record; only intact records and isolated reruns are
credited. The producer now autoflushes and retains structured fresh errors.

## Implementation order and limits

Commit this freeze, then independently assess/implement Perl, Rust, Dart, Julia
and safe available Lua. Retain source-first public producer controls before
changing a backend; do not infer its failure from Perl. Use shared authored
native/generated cases plus quick direct defaults, strict kinds, lazy effects,
copy/selector and malformed-shape checks. Preserve authored Hash colon checks,
emitted-host compatibility boundaries and helper/free/callback policies.
Full matrices/canonical proof follow feature coverage; Perl test registration
23.4.1 precedes later admission/push. Lua malformed native patterns/full runner
remain excluded; declared5.4 restoration is independently owned.

## Bounded Perl implementation

18.1 admits the receiver as default_result and guards zero fallbacks before
source effects. Its new chains compose through existing actual-value/host
compatibility dispatch, preserving Hash/Array transitions and valid prefix
effects before rejection. A scalar-bound initial source protects lowered Hash
literals from host-arrow reparsing and bare-block ambiguity. The shared Hash
consumer also exposes pre-existing free pick_keys block-key staging: the legacy
key path now invokes the existing typed block lowerer only for actual key blocks.
Direct native/fresh free-key controls confirm once-only C/captured original Hash
before mutation; other key forms and free signatures remain unchanged.

New13 native/fresh assertions plus existing selected-default5/logical-rejection12
checks pass across retained runs, with module/test/probe syntax. Strict shared
JSON preserves empty/zero/false/exhaustion, eight source families, actual scalar/
container bridges, Number indices, independent copies, SDC/SC snapshots, skipped
supported runtime failure and incompatible-consumer operands, valid rejected
prefix effects and malformed zero-RHS no-effects. Authored retired Hash syntax
still rejects. Rust18.2 independently assesses next; no full admission or new
portable aggregate domain. Explicit Perl test registration23.4.1 stays required.

## Bounded Rust implementation

18.2 independently confirms free/nested defined kinds, lazy skipped runtime
failure/effects, copies and Number indices before production. The new receiver
instead reaches an unused typed write failure: missing String admission falls
through generic eager helper dispatch without a receiver operand. Add the
counterpart to existing String/dynamic lazy selection and actual-result handoff;
mark its scalar results until an actual container releases the boundary. Guard
zero fallbacks before source/consumer effects. Existing free/producer/context/
numeric/callback/compiled-format contracts remain unchanged.

New producer/shared/selected three tests plus direct selected/nonempty three
pass native/restored/in-process plan, offline compilation and rustfmt. Shared
strict kinds/SDC-SC-HashC/copies/indices/skipped failures and selected/malformed
no-effects hold; no standalone emitted Rust or complete portable admission.
Dart18.3 independently assesses next.

## Bounded Dart implementation

18.3 independently confirms free/nested producers before production. Existing
receiver selection, snapshots, SDC/SC/HashC, copies/indices and skipped runtime
failures already work. Shared RED has[] at scalar boundaries andSA from an
incompatible take operand; zero-RHS source/consumer SC also runs. Track coalesce
in mayProduceScalar and common pre-effect one-or-more preflight, preserving
actual List/Map release and existing free/named-context/format/callback policy.
New3/direct defaults3 native/restored/plan tests, format and fatal selected
analysis pass. Extra selected/malformed controls retain fournull/emptyorder.
No full matrix/standalone/portable admission; Julia18.4 independently assesses.

## Bounded Julia implementation

18.4 independently confirms producer-first strict native/plan/fresh controls.
All three shared routes preserve valid selection/snapshots/copies/indices/lazy
errors, but expose scalar[]/SA and malformed SC. Add coalesce to common
one-or-more preflight and may_produce_scalar, preserving existing actual
container release/free/named-context/format/callback policy. Registered new36
and direct defaults9 assertions pass under strict compilation, including false
identity and Number-not-Bool results/counters, shared SDC-SC-HashC/skipped errors
and selected/malformed fournull/emptyorder. No full matrix/portable admission or
callback identity repair; safe available Lua18.5 independently assesses next.

## Bounded Lua implementation

18.5 independently confirms canonical JSON producers on PUC5.5.1/LuaJIT before
code. Shared native RED has scalar[]/SA and malformed SC, while valid selection/
snapshots/copies/indices/skipped runtime errors already hold. Mark both default
selections scalar until actual containers release the boundary; add zero-RHS
preflight. No new module locals/free/lazy/context/callback/format policy change.
Safe registered native/plan/fresh producer/shared/selected controls, direct
selected/nonempty defaults and interpreter/runner source loads pass both hosts.
No full runner/malformed native patterns/declared5.4 or complete portable
admission. All five bounded defined-only implementations are targeted-checked;
next assessment23.2.19 owns ordinary pure String-producing result breadth.
