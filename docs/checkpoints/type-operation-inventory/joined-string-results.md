# Joined String results in ordinary receiver chains

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.4`; implementation family `.23.3.5`.
This freezes a bounded target before production edits, not portable support or
complete fluent-family admission.

## Existing authority and target

The helper catalog defines `join_values(delimiter, array)` and the receiver form
`array_expr.join_values(delimiter)`. The free helper keeps its delimiter-first
argument roles. A join result is a String/scalar or the existing helper's null
result; it becomes the current value for the next compatible existing pure
String/Number method. For example, `parts.join_values(",").uppercase()` means
`uppercase(join_values(",",parts))`. Do not retain the source Array family or
stop merely because join used to be terminal.

Existing selected-value, Count/Length and aggregate-result contracts retain
actual-value dispatch and explicit String-to-Array bridges. A joined String may
therefore feed `split`, then Array methods and selected-value continuations. It
may also feed `length`, then existing numeric methods. Array-only consumers
remain incompatible until a helper explicitly returns a container; no implicit
revival of the joined source is allowed.

## Shape, effects and snapshots

The receiver takes exactly one delimiter operand. Missing/extra delimiter shapes
return undef/null before receiver or operand effects, following the ordinary
fluent invalid-shape policy. No optional delimiter or new free-helper signature
is introduced.

For a valid Array source, evaluate/snapshot the receiver once before its delimiter
operand, compute the joined result once, then evaluate required consumer operands
once in existing helper order. A delimiter may mutate the original source; it
must not change the earlier receiver snapshot. A later consumer mutation must
not recompute the join. Preserve existing scalar-text conversion, Unicode,
source/argument kinds, null/empty/lazy/error and copy policies. Delimiter-first
free-helper argument roles do not reorder receiver evaluation.

The public Perl single-step control already retains source-first snapshots:

```text
items=["a","b"]; order="";
joined={order=cat(order,"S");items}.join_values({order=cat(order,"D");items+="c";","});
bare=["x","y"]; named=bare.join_values({order=cat(order,"N");bare+="z";"-"});
return([joined,order,items,named,bare]);
```

It yields `["a,b","SDN",["a","b","c"],"x-y",["x","y","z"]]` at activation.
Preserve this correct producer behavior while adding result flow.

## Normative examples

Targets below do not claim current cross-backend support.

| Expression | Expected |
| --- | --- |
| `["a","b"].join_values(",").uppercase()` | `"A,B"` |
| `[" a ","b "].join_values("-").trim().uppercase()` | `"A -B"` |
| `[].join_values(",").cat("!")` | `"!"` |
| `[["a","b"]].first().join_values("-").uppercase()` | `"A-B"` |
| `["b","a"].sorted().join_values(":").uppercase()` | `"A:B"` |
| `{"b":"y","a":"x"}.sorted_values().join_values(":").uppercase()` | `"X:Y"` |
| `["a","b"].join_values(":").split(":").last().uppercase()` | `"B"` |
| `["a","b"].join_values(":").length().add(1)` | `4` |

Retain named/literal/function/computed/selected/pipeline sources, consumer order,
mutations, empty Arrays, incompatible Array consumers and shape/effect controls
in small backend fixtures. Reuse existing helper implementations.

## Previous boundaries and exclusions

The ordinary blanket join-terminal policy is superseded only for compatible
existing pure result continuations. Other predicates/control outputs, additional
callback/deferred admission, addressable mutation, new methods/types and public
serialized/generated formats remain separate. Existing callable vocabularies
need no artificial restriction or new admission.

Source-domain normalization remains `FUTURE-PARITY-BACKLOG.5`: current backends
differ for non-Array/missing sources. This result-flow feature neither introduces
new accepted source kinds nor silently changes null/empty policy. The dated Lua
false-delimiter join/split issue remains owned by `LUA-STARTUP-READING.2.9`;
reverify the relevant route at Lua activation. Full signatures/transitions/context/
portable admission remains `.23.4`.

## Activation findings and implementation order

Public Perl isolated controls return null for direct/selected fluent journeys,
beside nested `"A,B"`/`"A-B"`. The hash-view fluent journey also returns null with
an undefined host sorted_values error; its nested equivalent returns `"X:Y"`.
Public substitution retains the entire failed hash chain as DSL but fully lowers
the nested equivalent. This is join continuation lowering/fallthrough, not a free
sorted_values defect. Invalid delimiter shapes also leave DSL and cause handler
compile errors instead of clean pre-effect null values.

`append_array_chain_call` marks join terminal; later loops stop or fail to lower
its consumer. The retained public diagnostic scripts reproduce pairs, source
snapshots, isolation and invalid shapes. Implement Perl first, then assess each
backend individually; compile, quick-check, docs and commit per bounded slice.

## Current implementation

Perl `.23.3.5.1` uses existing scalar_result continuation and exact one-delimiter
preflight. Native/fresh and direct aggregate checks pass after RED, covering
named/literal/function/selected/pipeline/hash/String sources, empty/Unicode,
String/length/split bridges, SDAN effects, later mutations, invalid arity and
incompatible Array nulls. The join helper, source domains/null/copy behavior and
separate deferred evaluator are unchanged. Rust and later backends require
individual assessment; no complete context/portable admission is claimed.

Rust `.23.3.5.2` extends existing scalar-result handoff/guards to join and adds
exact one-delimiter rejection. Named Array-end tails now use the shared loop;
a distinguishing candidate RED prevents wrong-kind empty-Array fallback there.
Native/restored/generated-plan and direct aggregate checks pass, including
named mutations, Unicode, split/length bridges, SDAN order, snapshots and shapes.
Helper/source/null/copy behavior and callable vocabulary stay unchanged; Dart and
later backends require individual assessment, with full admission separate.

Dart `.23.3.5.3` preserves already-correct joined-result/snapshot behavior, adds
one-delimiter preflight and includes joins in shared scalar-producer tracking.
Native/restored/generated-plan and direct aggregate checks pass after RED,
including named mutation boundaries, Unicode, split/length bridges, SDAN order,
snapshots and shapes; changed-file fatal analysis passes. Julia/Lua require
individual assessment. Container-default transitions are separately scheduled23.2.5.
