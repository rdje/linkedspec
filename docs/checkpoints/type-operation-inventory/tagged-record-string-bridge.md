# Tagged-record text-to-Array bridge

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.2; implementation23.3.22.1.1/.1.2 and22.2-.5.
Existing helper: split_tagged_records(source, delimiter, tag, fields...).
Existing documented scalar receiver: source.split_tagged_records(delimiter,tag,fields...).
This fixes useful ordinary value behavior; it creates no helper name, type,
callback surface, serialization format or portable split-domain decision.

## Authorities and frozen bounded target

The helper reference already teaches one record per split item, [tag,item,fields...],
once-only argument evaluation, copied carried values and scalar receiver/count
composition. The helper has ordinary eager arguments, with no registered final
callback/lazy role. Source spelling/resolver category is not an input type:
this is a text-consuming Array producer even where stored in an Array dispatcher.
Normal scalar-text/numeric/value/copy contracts and existing pure split remain.

Repair the Perl producer prerequisite: evaluate source, dynamic delimiter, tag and
carried fields once from left to right, retaining earlier argument snapshots when
later expressions rebind their sources. Do this even when splitting produces no
items. Use its already-admitted pure split behavior for tagged item construction;
do not maintain a second trailing-item policy. Preserve constant regex literal
flags, variable/literal delimiter behavior, current tag/value conversions and
actual carried kinds. Record/carry copying keeps existing documented value bounds.

Receiver shape is two-or-more ordinary RHS operands (delimiter, tag, optional
fields). Reject malformed method shapes before source/operand/consumer effects
under the backend's current ordinary-method error policy. Free signatures and
existing invalid-input/error behavior stay; do not invent a global invalid-domain
or callback policy. Eager expression blocks are ordinary operands, not callbacks.

Admit named/literal/computed String sources and preceding compatible String-result
helpers; the actual result is an Array of fresh record Arrays. Existing Array
consumers/first-last selection may then reach compatible scalar or carried-container
methods. Input role guards must not mistake an Array result for an Array source.
Preserve source snapshots, valid consumer effects, actual scalar/Boolean/null/
Array/Hash fields, independent carried values and no mutation of input bindings.

```text
" a,b ".trim().split_tagged_records(",","row").last().last().uppercase() # B
"a,b".split_tagged_records(",","row").count().add(1) # 3
"a,b".split_tagged_records(",","row",["x","y"]).last().last().last().uppercase() # Y
```

Portable authored targets use ordinary String sources/tags and existing nonempty
literal or supported regex delimiters. Preserve each backend's current pure-split
empty-source/empty-delimiter/zero-width/Unicode behavior; SESSION33 still owns the
broader cross-runtime reconciliation/admission. No silent oracle re-blessing or
claim that those historical differences are resolved by this bridge.

## Public Perl intake, October27

probe_tagged_record_results.pl uses public Get/runtime context/dump/substitution
and independent fresh emitted execution. Basic helper returns two records with
Number7 and Array[x] fields; later DSL mutation of one carried row preserves the
other and source, so retain that healthy copying behavior.

Literal/named scalar receiver tails fail with undefined host split_tagged_records;
substitution leaves raw authored dot DSL. A preceding trim instead gives null.
The helper is recognized for value construction but not composed through the
actual String-to-Array receiver route.

The older SESSION33 producer defect remains current on native/fresh: source a,b,
with a carried increment gives only rows a/1,b/2 and counter2, while pure split
retains the final empty item. Empty source produces zero rows and counter0.
Substitution places the carried expression inside map and uses split without
its pure-helper -1 trailing limit. Eager source/delimiter/tag/field blocks also
leak raw tag/delimiter DSL and fail compilation. Materialize ordinary arguments
and reuse the existing splitter before adding receiver flow.

Perl22.1.1 first repairs that bounded prerequisite, then22.1.2 adds/repairs receiver
composition. Rust22.2, Dart22.3, Julia22.4 and safe Lua22.5 independently probe
producers/receivers before changes. SESSION33.1/.2 remain open for full six-runtime
empty/zero-width/variable-regex/domain/admission work under the director's
post-feature broad-validation cadence. Error-phase1.2.1.4.1, document pressure20.1,
full context/portable admission and declared Lua5.4 also stay separately owned.

## Perl producer22.1.1 partial completion

The producer now stages lowered source/dynamic delimiter/tag/fields before mapping;
ordinary split and tagged construction share _emit_split_value_expr. Authored
native/fresh producer regression PASS36 after RED, preserving regex flags, dynamic
literal quoting, legacy tag atoms, kinds/DSL copy bounds and earlier snapshots.
Empty source still gives zero records under Perl pure split but fields run once;
a,b, now has three records with the same captured field. No global split policy
or SDK deep-copy promise changes. Scalar receiver22.1.2 remains the next unit.

## Perl receiver22.1.2 partial completion

The String receiver return-family map includes tagged records beside split; its
input is text and its output is Array. AST/compatibility chains reject fewer than
two RHS operands before effects. Native/fresh shared valid/local shape PASS12:
named/literal/trim source, regex/trailing item, selected Number/Bool/null/Array/Hash
continuation, numeric selector and SDTFCE snapshots. Direct producer/String PASS43.
Independent Rust22.2 follows; this is not full SESSION33 split-domain admission.

## Rust22.2 partial completion

Public intake reveals the ordinary helper was missing (unknown-helper warning/null)
while eager argument effects already work. The producer now constructs fresh rows
from existing split_string_for_arg, text tag and cloned captured typed fields;
String-to-Array classification and min-two-RHS preflight enable receiver chains.
Five native/restored/in-process-plan tests and four direct scalar String tests pass:
shared valid chains, SDTFCE, copied/prior carried values, empty/trailing/regex and
short free eager null controls. Existing Rust pure-split boundaries remain; no
standalone generated crate or full SESSION33 matrix/admission claim. Dart22.3 next.

## Dart22.3 partial completion

Producer/eager/copy/short-free native/restored/plan controls already pass. Fix
receiver Array-input role confusion (result dispatcher membership is insufficient),
regex pattern evaluation and min-two-RHS no-effects preflight. Five new tagged
and seven direct String tests pass plus format/fatal analysis. Preserve existing
split/conversion/copy/free short-call behavior; Julia22.4 next, full33 admission open.
