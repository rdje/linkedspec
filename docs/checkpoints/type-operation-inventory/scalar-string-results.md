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
