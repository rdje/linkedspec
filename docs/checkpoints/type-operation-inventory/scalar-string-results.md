# Ordinary scalar String-helper result continuations

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.19; implementation23.3.19.1-.5.
Scope: existing trim/lowercase/uppercase/replace_substr/rm_prefix/rm_suffix/
substr/cat ordinary value helpers and receiver methods. These are scalar
operations; they do not invariably produce String. Existing identity branches
can preserve a Number or Boolean. length/predicates/comparisons/defaults/split,
statement regex mutation, callbacks and scoped/deferred admission retain their
separate owners. Full domain/context/portable admission remains23.4.

## Frozen bounded behavior

Preserve existing source/operand domains, null/empty/conversion/Unicode policies
and actual scalar result kinds. trim/case and literal replacement/removal keep
their existing null propagation. cat follows scalar-text-v1: null, Array, Hash
or Codeblock in any operand makes the whole result null; Boolean text is1/0.
Do not treat null as empty text. Preserve eager ordinary helper operands even
when a value makes the eventual result null; lazy defaults remain separate.
No unary free-cat arity reconciliation or large-number spelling repair follows.

Empty-old replacement preserves its original value/kind. Empty/unmatched affix
removal also preserves it: numeric zero remains a valid typed Array index,
String "0" remains text, false remains Boolean. A matching removal can produce
text; do not force every output to Number or String. The existing Perl reducer95
kind defect remains separately owned; this scope repairs affix identity only.
Unicode17 Default case mappings/expansion/context and substring character/index
rules remain unchanged. This is result flow, not a new case/conversion policy.

Evaluate the source once, then valid operands left to right once, then compatible
consumer operands. Capture source/result snapshots before a later operand or
consumer rebinds the source. Actual scalar/null results feed existing compatible
scalar/numeric/generic methods. split explicitly produces an Array, allowing
Array consumers and later selected String methods. Container-only consumers
reject scalar results cleanly, preserving source and valid prefix effects while
skipping incompatible consumer operands. No implicit scalar-to-container cast.

Ordinary receiver arities: trim/lowercase/uppercase zero RHS; replace_substr two;
rm_prefix/rm_suffix one; substr one or two; cat one or more. Malformed ordinary
shapes reject before source/operand/consumer effects. Preserve every free-helper
signature, dedicated mutation overload and existing unsupported/static-error
policy; no blanket error precedence is introduced for unknown consumers.

```text
" a,b ".trim().split(",").last().uppercase() # B
"a-b".replace_substr("-",",").split(",").last().uppercase() # B
"ΟΣ".lowercase()                           # ος
"Straße ﬃ".uppercase()                     # STRASSE FFI
"a🙂b".substr(1,1).cat("!")                 # 🙂!
0.rm_prefix("x").add(1)                    # 1; identity retains Number
false.rm_suffix("x").cat("!")              # 0!; identity retains Boolean
"a".uppercase().sorted_values()            # null, clean rejection
```

Cover all eight helper results, selected/named/Hash-selected/block/function/
canonical-call/pipeline roots as supported by their existing domains, null and
empty String, generic/numeric continuations, explicit Array bridges and invalid
container boundaries. Do not infer complete source-domain or callback admission
from a bounded fixture.

## Public Perl intake before production

Retained probe_scalar_string_results.pl uses public Get/AST/substitution/dump
and independent fresh emitted execution. Eight fluent and nested texts agree:
[a!,ab!,AB!,a_b!,a!,a!,bc!,ab!]. All eight split bridges give B. Direct/nested
replacement effect controls give[a_b!,SONC,1,null], preserving captured a-b
before operand mutation. Existing sources give[A,A,A,A,A,null,null,!]. Unicode
native/fresh controls agree on Greek final sigma, STRASSE FFI and 🙂/🙂!.
Identity JSON gives[0,0,false,1,"0"]. JSON alone does not prove Perl runtime kind.

Known scalar container tails remain raw DSL. Plain trim->sorted fails at runtime
with undefined host trim; compound effect/malformed chains fail compilation.
AST preserves source/calls; substitution retains authored .trim/.sorted links.
MethodLowering still classifies ordinary transforms as string, so String-first
composition lacks a scalar actual-result rejection boundary. Use existing typed
actual-result/host finishing rather than adding authored raw fallback.

A pre-existing P1 identity defect affects free/fluent/named rm_prefix(0,"x")
and rm_suffix(0,"x") Array-index writes. They report nested_write_kind_conflict,
expected harray, actual array. Empty-old replace_substr and literal0 controls
update the Array. Before JSON encoding, native/fresh returned prefix/suffix
values retain both integer and string flags, replacement/literal0 only integer,
and String"0" only string. Public substitution inspects the original affix
source with index/length/substr, contaminating the scalar that identity returns.
BindingRuntime::_runtime_kind correctly prioritizes SVf_POK. Inspect a copy while
preserving the selected original; do not weaken typed selectors or coerce String
"0" into Number. Perl19.1 owns this repair alongside result flow, before Rust.

The catalog's cat undef-as-empty prose is stale, already intake-owned SESSION28.5.
scalar-text-v1, public native/fresh cat(undef,"x")->null and direct scalar-text7
checks agree. Correct that exact prose in this assessment; no producer change.
Unary free cat and large-number spelling stay with51/55.2. Broader scalar-null
admission61.3 remains open; the new affix-kind defect qualifies old JSON-based
claims of identity kind preservation.

The first identity diagnostic stopped on a nested blessed error during JSON
encoding. Recursive diagnostic-only snapshots now retain structured error data;
isolated reruns establish all credited selector/Unicode/source results. Do not
credit missing records or an incomplete initial run.

## Schedule and limits

Commit this freeze, then independently assess/implement Perl, Rust, Dart, Julia
and safe available Lua. Retain producer-first public controls per backend; no
failure inferred from another backend. Quick native/generated changed/direct
checks, syntax/book/continuity and a commit per leaf; no full matrix/replay.
New Perl tests require explicit23.4.1 canonical registration. Lua full runner/
malformed native patterns stay excluded; declared5.4 has its separate owner.

## Bounded Perl implementation

19.1 marks eight helper results scalar and checks their ordinary shapes through
existing arity metadata. Ordinary transform chains reuse existing typed actual-
result/host composition; dedicated mutation/traversal dispatch stays separate.
Affix inspection uses a copy, preserving the original on identity and returning
text on match. The typed selector itself stays unchanged. Public pre-JSON flags
now show IOK-only prefix/suffix/replacement/literal0 and POK-only String0 on
native/fresh, matching successful free/fluent/named Array writes and Hash text
keys. No numeric coercion is added to the preserved identity.

New7/direct scalar-text7/nonempty-default5 checks pass,19 focused top-level
checks plus module/test/probe syntax. Shared native/fresh data covers eight
texts/nested/bridges/boundaries/empty/null, Unicode final-sigma/expansion/emoji,
eight roots, Number/Bool/String identities/matched text keys and numeric/generic
consumers. SONC/SC/selected-S snapshots, eager null operands, rejection preserving
prefix effects/skipping consumer operands and12 malformed no-effects hold.
Authored retired Hash arrows still reject. Current book identity limitations are
removed after this fix; new Perl test registration23.4.1 remains required. No
full matrix/portable admission or reducer95/unary-cat/large-number/callback
repair. Rust19.2 independently assesses its producers before changing them.

## Bounded Rust implementation

19.2 independently confirms producer values/Unicode/identity indices/order.
Shared RED exposes SCA/selected-SA and selected[] plus malformed values/effects;
plain container boundaries already return null. Mark the eight methods scalar
in existing result dispatch and add precise common receiver shapes. Producers,
identity/free/domain/Unicode/callback/format policies remain unchanged.

A separate ordinary substr defect textifies null and truncates fractional
start/width. Retained public Perl native/fresh substring_bounds confirms
[null,null,abc,a,empty,empty,bc,null] for source/start/fraction/negative/Boolean/
provided-null-width controls. Guard explicit null operands only in ordinary
arity2/3 after dedicated regex mutation; normalize whole nonnegative offsets
locally. Omitted width/free unary-extra arities/Boolean compatibility stay.
New4/direct null-predicate-default3 native/restored/in-process plan tests pass,
seven focused tests plus offline compile/rustfmt/probe syntax. Independent SIL
and both named-target mutation controls pass; no standalone/full admission.
Dart19.3 independently assesses results and these concrete slice boundaries.

## Bounded Dart implementation

19.3 independently confirms healthy String/Unicode/strict-null/SON producers,
then isolates original-kind failures: replacement/affix identities return text,
explicit null operands become empty, and typed Number indices fail. Receiver
RED has[]/SCA/malformed SAC; fractional Number offsets truncate. Preserve source
Number/Boolean identities while retaining text for other scalarized carriers,
guard explicit null operands, add eight-method scalar/shape metadata and local
fractional normalization. Non-null scalarization admission/global numeric/int/
selector/Unicode/callback/named-context/format policies stay unchanged.

Dart already treats provided-null width as omitted and Boolean offsets as
invalid0, unlike recorded Perl/Rust compatibility. Preserve these intentional
conventions here; P2 assessment20 independently reconciles domains immediately
after19.5 and before portable admission. No universal width/Bool promise follows.
Seven new plus three direct default tests, native/restored/plan, format and fatal
selected analysis pass. Shared exact kinds/indices/Unicode/SONC-SC-selectedS/
eager null operands/rejection/skipped operands/12 malformed controls, independent
SIL/fraction/negative/current domains and both mutation aliases pass. Existing
large-slice end overflow2.14 remains separate, with no broad/standalone admission.
Julia19.4 independently assesses next.

## Bounded Julia implementation

19.4's independent public native/plan/fresh probe isolates textified identities,
null-as-empty operands, typed index failures and[]/SCA/malformed SAC. Healthy
basic String/Unicode/strict-null/SON controls pass before production. Preserve
Number/Boolean originals on identity (other converted carriers stay text), guard
explicit null operands and add eight-method scalar/shape tuples. No global int/
numeric/selector/Unicode/free/regex/callback/named-context/schema normalization.

Fractional/null source/start slicing already works; Julia provided-null width
means omitted and Bool offset remains1. Preserve these conventions under20,
which now records Julia separately from Dart and Perl/Rust before admission.
Registered new54/direct defaults9 native/plan/fresh assertions pass with strict
compilation, Number-not-Bool/false identity, exact shared kinds/indices/Unicode/
SONC-SC-selectedS/eager null/rejection/12 malformed controls, qualified SIL and
both mutation aliases. Retained diagnostic basic source loads/executes on all
three routes. No full matrix/portable admission or callback2.8/large-number2.9/
unsafe large-slice2.10 repair. Safe available Lua19.5 independently assesses next.

## Bounded Lua implementation

19.5 independently confirms healthy producers on safe PUC5.5.1/LuaJIT, then
isolates textified identities/null operands/typed index errors and[]/SCA/SAC on
all native/plan/fresh routes. Preserve primitive Number/Boolean identities with
explicit false-safe returns, guard explicit null operands and extend existing
scalar/shape lists without new module locals. Other scalarization/free/Unicode/
selector/regex/callback/format policy remains unchanged.

The same slice body has a concrete PUC arithmetic defect: large_end returns
[abc,empty,empty], while LuaJIT returns[abc,bc,bc]. Clip width to remaining
characters before addition and early-return for an out-of-range start. Strict
canonical JSON across eight retained groups plus direct default/source loads
passes both hosts/native-plan-fresh, including the new free/receiver large-end
control, exact shared kinds/indices/Unicode/SONC-SC-selectedS/eager null/rejection/
12 malformed effects and both mutation aliases. No full runner/malformed native
patterns/declared5.4/magnitude matrix or complete portable admission. Both hosts
preserve null-width-as-omitted/Bool-invalid0 under20. All five bounded String
implementations are targeted-checked; input-domain reconciliation20 is next.
