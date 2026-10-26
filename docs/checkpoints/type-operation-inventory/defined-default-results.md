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
