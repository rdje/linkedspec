# Ordinary eager with returned-Hash continuations

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.31; intake31.0; independent backend children31.1-.5.
Status: All bounded non-nested with-result backend children repaired/targeted-checked on recorded hosts. Priority Rust/Dart/Julia nested identity31.6 and full admission remain open.

Existing helper `with(value){body}` and receiver `source.with(){body}` execute
immediately, bind scoped `value`, return the block result and restore the outer
value binding. Existing parenthesized final contextual blocks are equivalent.
Other ordinary working-variable effects persist. A returned Hash must feed its
compatible Hash methods, then Array/String/Number/selected-value methods according
to the actual result. This repairs existing semantics, adding no API/type/signature
or AST/schema field and no callback/deferred/unknown-call permissions.

Shared authored fixture: tests/fixtures/with_hash_result_values.spec/json, input
name=Alpha. Literal String, named String, entry_text and a trimmed String receiver,
plus helper with, return small Hashes. sorted_values yields Arrays, nested false
keeps its Bool kind, signed selected String resumes uppercase, sorted_keys joins
in key order, and count_keys resumes Number add. Effects execute once in ABCDE
order and outer value remains "outer". This finite list is normative for this
slice, not an exhaustive with/method/domain/context coverage measurement.

Preserve current immediate Array/Number/String/Bool/null result composition and
nested scope restoration; evaluate source then body once. Existing actual-result
guards must reject incompatible Array/Hash consumers without evaluating their
operands. Do not normalize legacy literal/named/context first-consumer policies
outside with results. Preserve current copy depths, list-splice, binding mutation,
error/arity/function/parser-state/control and callback/deferred boundaries.
Specifically retain the forbidden helper's diagnostic inside a pure-function with
body; generic unready/with rejection does not establish that preservation.
Explicit delayed/bound callable semantics retain their existing owners and rights.

At clean912c803435 public native/fresh/Value metadata/substitution and AST show
literal/bound/capture/helper/prefixed with-Hash sorted_values continuations become
null, raw0/unresolved sorted_values/unready. Terminal Hash return restores outer
value and executes W; Array/Number/Bool/null continuations pass, so the Hash
producer and general scoped execution are healthy. Original source/AST/channels
are retained in with-hash-intake.json.gz; no other backend failure is inferred.

MethodLowering's normalized receiver with chain retains typed nodes only for the
input/cursor-owned source path; generic receivers rebuild a synthetic helper-with
source before continuation. Helper with is excluded from the ordinary actual-result
chain predicate unless another result-owning operation intervenes. The Hash chain
therefore falls back through source-based helper lowering and advertises the
unsupported sorted_values marker instead of using the yielded Hash. Backend31.1
must repair this exact route with existing typed value/default-result owners,
retaining normalized contextual body/source/function ownership and early shape
checks. Independent backend children first establish actual behavior; already
compatible implementations gain focused regressions without invented runtime RED.
The independently run coalesce(null) twin yields false on native/fresh with
raw0/unresolved0/ready1, distinguishing missing result dispatch from a failing
Hash body or sorted_values primitive. Full source/domain/context/portable/generated
admission stays23.4.

Perl31.1 folds ordinary normalized receiver with through existing helper AST and
includes helper-with in actual default-result dispatch. The first candidate repairs
four new groups and deferred-with11 but signed selection retains unsupported with.
Public method/selected AST twins isolate the nested first-unknown precheck; it now
recognizes only metadata-normalized immediate receiver with, leaving typed body
validation/diagnostics with the existing owner. Frozen/native/fresh/ready and an
indexed specific function fence pass after refinement; input-with-only10 also
passes. Earlier scalar/nested/pure controls are retained; the costly combined run
is not repeated without a changed-route reason. No parser/helper/type/AST/schema
or deferred/callback permission changes. Independent Rust31.2 follows.

Rust31.2 independently already passes frozen Hash/pure-function/fence controls.
Helper/receiver scalar results bypass existing actual-kind guards, yielding3/[]
and evaluating KV/A/J/L/T operands.31.2.1 routes helper-with through current guarded
values and marks returned receiver-with values guarded. Four native/restored/plan
tests and the direct input-with case pass, with no frame/parser/schema changes.
The original nested control separately exposes helper-name recursion collision;
its exact source/first-native error is retained and P1-owned31.6.1 after bounded
backend children, before unrelated selection or parent admission. Known Dart2.10/
Julia2.8 identity owners remain independent. No nested/full with admission follows.

Dart31.3 independently already passes frozen Hash/pure-function/indexed-fence
controls. Its helper/receiver scalar guard source returns3/[]/3/[] and SWKVANJLT at
first native assertion. Existing guarded-source/result flags now include with;
four native/restored-SpecFile/plan tests, direct input-with one case and format/
fatal selected analysis pass. No frame/parser/schema changes. Existing nested
identity DART-STARTUP-READING.2.10 remains priority31.6, not freshly assessed or
called covered here. Independent Julia31.4 follows; parent/full admission stays open.

Julia31.4 independently confirms3 scalar-guard RED/9 healthy frozen Hash/pure/
indexed-fence comparisons on native/plan/fresh. Existing guarded-source/result
flags gain with; new12 and direct input-cursor12 pass with strict Bool/Number
checks, --depwarn=error and normal registration. Source/log retained; known launcher
SESSION7 prelude is distinct from actual successful test execution. No frame/parser/
schema changes. Known Julia2.8 nested identity remains priority31.6, not freshly
assessed or covered; safe Lua31.5 follows before priority identity repairs.

Safe Lua31.5 independently observes3 scalar guard RED/12 healthy frozen Hash/pure/
distinct nested/indexed-state comparisons per available PUC5.5.1/LuaJIT2.1.1788460057
host. Existing guarded-source/result flags gain with; new15 plus direct input18
pass per host. luac/loadfile module/test/full-runner syntax only and normal
registration complete; no persistent chunk locals/frame/parser/schema changes.
Host/source/RED retained. All bounded non-nested result children are targeted-
checked on recorded hosts; priority Rust31.6.1 and existing Dart/Julia identity
owners follow before unrelated selection/parent admission. Declared5.4 separate.
