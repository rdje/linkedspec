---
id: dart-runtime-array-helpers
title: Dart runtime executes array helper family and receiver chains
answers:
  - why do Dart emptiness results need scalar guards while allowing repeated predicates
  - why do Dart has_key results require scalar guarding before container methods
  - why do Dart direct default scalar results reject container consumers
  - how do Dart aggregate results retain scalar boundaries after named array mutations
  - why does Dart count return zero for nonarrays and reject extra receiver operands
  - does Dart receiver copy reject extra arguments before effects
  - do Dart standalone split_each filter_match and uniq update arrays
  - does Dart runtime support array receiver chains
  - does Dart runtime support sorted drop_front first
  - does Dart runtime support split_each trim_each filter_nonempty
  - does Dart runtime support join_values delimiter first and joined String continuations
  - does Dart runtime support push_back statement only
  - does Dart runtime support split_tagged_records
  - does Dart runtime read bare array working variables in receiver chains
date: 2026-10-26
status: scalar/default/index/predicate guards; ordering/slice/admission open
tags: [dart, runtime, helpers, array, receiver-chains, DART-BACKEND-PARITY]
evidence: "Array4.3.3/end12.1.4/transform5.3.2; selected/copy/count/aggregate/join23.3 focused fixtures."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/emptiness_result_receivers_test.dart test/has_key_result_receivers_test.dart"
---

Dart runtime array helper execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` now evaluates bare array working variables as array
snapshots in array-consuming helper slots and compatible receiver chains. This
allows examples such as `items.sorted().drop_front(2).first()`,
`items.uniq().join_values(",")`, `items.filter_match(/^a$/).count()`, and
`phrases.split_each("-").filter_match(/^aa$/).count()`.

Array methods cover count/select/order/membership,
`take`, `take_last`, `drop_front`, `drop_back`, `slice`, `sorted`, `reversed`,
`contains`, `index_of`, `trim_each`, `filter_nonempty`, `lowercase_each`,
`uppercase_each`, `uniq`, `filter_match`, `split_each`, `flat_array`,
`concat_arrays`, `split_tagged_records`, delimiter-first `join_values`, and
terminal array numeric reducers such as `array(2, 4, 6).sum()` / `.avg()`.

`split(target, source, delimiter)` replaces the named array; the old exact array(target) selector is removed.
Regex delimiters and regex filters use Dart `RegExp` over the stored regex
literal pattern. Adjacent delimiters preserve empty fields; `filter_nonempty`
remains the explicit cleanup step.

`items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` mutate named
working arrays and return independent updated array snapshots. Pop discards the removed element. A compatible
continuation such as `.count()` consumes the updated array; an unused result is silently dropped.

Hash helpers: DART-BACKEND-PARITY.4.3.4; controls/tree callbacks: .4.3.5.

Related: [[dart-runtime-hash-helpers]], [[dart-runtime-value-control-tree-helpers]],
[[dart-runtime-string-numeric-helpers]],
[[terse-array-receiver-value-chains]], [[array-helper-return-shape-caveats]],
[[terse-array-numeric-reducer-receiver-methods]], [[terse-type-method-surface-inventory]].

## 2026-09-09 — ordering and slice arithmetic qualifications

sorted's host string comparison puts U+10000 before U+E000, unlike Perl.
[[dart-helper-unicode-order-gap]] and .2.13 own the lexical order repair. Separately,
slice([1,2,3],1,9223372036854775807) overflows start+length before clipping and throws
a wrapped RangeError, while offset zero and small widths succeed. The same mechanism
affects scalar substr; [[dart-slice-end-overflow]] and .2.14 retain six exact paired
controls and own safe bounds/carrier proof. This is not the separately owned negative
count policy.

5.3.2 implements standalone transforms with target validation, pure operands and rebinding; value/receiver forms stay pure. Julia5.3.3 is also implemented; broad5.3.4 remains open.

23.3 ordinary guards retain Count List-only/Length wider; join/index/has_key take one operand, emptiness predicates zero. Defaults/index/has_key/emptiness results stay scalar until actual List/Map output; generic emptiness consumers remain allowed.23.3.9.3 retains Bool flow/source/copy kinds/1!/SA, fixing container[]/bad1!/0!/four effects. Native/restored/plan/direct has_key and fatal analysis pass. Domains/source/copy unchanged; full admission open.
