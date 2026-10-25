---
id: dart-runtime-array-helpers
title: Dart runtime executes array helper family and receiver chains
answers:
  - do Dart standalone split_each filter_match and uniq update arrays
  - does Dart runtime support array receiver chains
  - does Dart runtime support sorted drop_front first
  - does Dart runtime support split_each trim_each filter_nonempty
  - does Dart runtime support join_values delimiter first
  - does Dart runtime support push_back statement only
  - does Dart runtime support split_tagged_records
  - does Dart runtime read bare array working variables in receiver chains
date: 2026-10-25
status: transforms5.3.2 implemented; ordering/slice owners remain open
tags: [dart, runtime, helpers, array, receiver-chains, DART-BACKEND-PARITY]
evidence: "Dart array4.3.3; end results12.1.4; transform regression5.3.2."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/array_transform_writeback_test.dart"
---

Dart runtime array helper execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` now evaluates bare array working variables as array
snapshots in array-consuming helper slots and compatible receiver chains. This
allows examples such as `items.sorted().drop_front(2).first()`,
`items.uniq().join_values(",")`, `items.filter_match(/^a$/).count()`, and
`phrases.split_each("-").filter_match(/^aa$/).count()`.

The supported array helper slice includes count/select/order/membership helpers,
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

`DART-BACKEND-PARITY.4.3.4` has since landed hash helper breadth and hash
receiver/mutation behavior. `DART-BACKEND-PARITY.4.3.5` has since landed value
blocks, structured controls, with-blocks, and tree traversal callback helpers.

Related facts: [[dart-runtime-hash-helpers]], [[dart-runtime-value-control-tree-helpers]],
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
count policy. Reading .1.20 changes no executable behavior.

5.3.2 enables standalone transforms in _executeArrayStringTransformStatement: validate target kind, evaluate operands with pure helpers, replace the array. Focused native/restored/generated-plan and analysis pass; value/receiver forms stay pure. Julia5.3.3/broad5.3.4 remain open.
