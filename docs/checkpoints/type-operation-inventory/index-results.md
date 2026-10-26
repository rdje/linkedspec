# Index results in ordinary receiver chains

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.6`; implementation family `.23.3.7`.
This bounded target precedes production changes. It is not portable or complete
fluent-family admission.

## Existing authority and result

The helper catalog defines `index_of(array, needle)` as the zero-based index of
the first match, including numeric zero, or undef for missing/non-array/no-match.
Preserve existing scalar needle/equality and source-kind policies. There is no
new -1 sentinel, helper spelling, type or serialized format.

An ordinary `array_expr.index_of(needle)` result becomes the current value for
the next compatible existing pure Scalar/Number method. Reuse existing numeric,
scalar-text, selected/default and explicit String-to-Array contracts. Do not
retain the source Array family or revive it through Array-only consumers.
Additional Boolean/predicate outputs, addressable mutation and callable/deferred
admission remain separate.

## Shapes, order and examples

The receiver takes exactly one needle operand. Missing/extra shapes return
undef/null before receiver or operand effects, following existing ordinary
fluent shape policy; free-helper signatures remain unchanged.

Evaluate/snapshot the source once before its needle, compute the index once,
then evaluate required consumer operands once in existing helper order. Preserve
null/empty/error, equality, scalar kind and copy policies; this adds no deep-copy
promise and no new accepted needle kind. Later mutations must not recompute the
index or change an earlier source snapshot.

These are implementation targets, not current cross-backend support claims:

| Expression | Result |
| --- | --- |
| `["a","b"].index_of("b").add(1)` | `2` |
| `["a","b"].index_of("a").add(1)` | `1` |
| `["a","b"].index_of("b").cat("!")` | `"1!"` |
| `[["a","b"]].first().index_of("b").add(1)` | `2` |
| `"a,b".split(",").index_of("b").add(1)` | `2` |
| `[].index_of("a").add(1)` | undef/null |
| `["a"].index_of("z").add(1)` | undef/null |
| `["a"].index_of("z").coalesce_nonempty(7).add(1)` | `8` |
| `["a","b"].index_of("b").sorted()` | undef/null |

Retain named/literal/selected/pipeline/hash-view/String/default/function Array
sources, numeric zero, no-match/empty/null, malformed-shape effects and actual
numeric use in a later selector. Preserve existing producer and snapshot behavior.

## Public Perl findings and concrete preservation controls

`probe_index_results.pl` uses public Get and call_spec_handler_subst. Ordinary
fluent add returns null while the nested `num_add(index_of(...),1)` returns2.
Selected/pipeline/String forms stop too; a Hash-view form remains raw DSL and
raises a host sorted_values error. This is lowering fallback, not a missing
free sorted_values helper. append_array_chain_call leaves index_of terminal.

Native and independently loaded fresh emitted probes agree on direct null versus
nested2. The producer is already correct: a named source [a] with needle appending
b still returns null/orderN/source[a,b]; the computed-source twin returns
null/orderSN/source[a,b]. A later consumer snapshot control has nested result
[2,SNA,[a,b,c,d]], while the stopped fluent chain runs no effects. Preserve these
controls while implementing continuation; do not rewrite the correct producer.

## Schedule and limits

Commit this assessment/freeze, then separate Perl/Rust/Dart/Julia/Lua children.
Assess each backend publicly; no failure is inferred from Perl. Use compile and
small native/generated/direct checks, docs and one commit each. Full signatures,
complete family/domain/portable admission remain `.23.4`; Lua declared5.4 remains
separately owned. Existing source/copy differences are not normalized here.
