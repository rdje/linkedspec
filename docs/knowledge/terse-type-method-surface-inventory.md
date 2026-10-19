---
id: terse-type-method-surface-inventory
title: SPEC-FORMAT-TERSE.7.1 type-method surface inventory
answers:
  - "what receiver methods already exist in the terse type method surface"
  - "does string substr already work as a method"
  - "which helpers should remain function only or statement only"
  - "what did SPEC-FORMAT-TERSE.7.1 inventory"
  - "which method backfill leaf follows SPEC-FORMAT-TERSE.7.1"
  - "do block yielded values and user function returns have their own method table"
date: 2026-07-04
status: historical July4 inventory; current model qualified below
tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]
evidence: "SPEC-FORMAT-TERSE.7.1 inventoried the current receiver/value families before implementation. Perl ActionIR::MethodLowering and Rust engine.rs already carry receiver dispatch tables for string/scalar, array/list, hash, and number values. String/scalar methods include substr, so the user's substr() method directive starts as verification/backfill rather than assumed missing implementation. Booleans and flow results are terminal today. Expression-valued blocks and user-function returns select a receiver family by yielded runtime type instead of owning separate method tables. Mutation, lifecycle/control, child-dispatch, parser-state reader, declaration, and compatibility-helper surfaces remain function/statement/lifecycle-only unless a future leaf defines safe receiver semantics."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-reference-inventory/publish.py"
---

`SPEC-FORMAT-TERSE.7.1` is the pre-code inventory leaf for the type-method backfill lane.

Dated July4 receiver families (including spellings later retired):

- string/scalar: `trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`,
  `concat`/`cat`, `coalesce_nonempty`; `split` bridges to array; `length`, `starts_with`, `ends_with`,
  `contains_substr`, and `matches` are terminal.
- array/list: `array_copy`/`copy`, `sorted`, `reversed`, `take`, `take_last`, `drop_front`, `drop_back`, `slice`,
  `concat_arrays`, `split_each`, `trim_each`, `filter_nonempty`, `lowercase_each`, `uppercase_each`, `uniq`,
  `filter_match`, `count`, `first`, `last`, `contains`, `index_of`, `is_empty`, `is_nonempty`, and
  `join_values`.
- hash: `hash_copy`, `merge_hash`, pure `set_key`, `rename_key`, `drop_keys`, `pick_keys`, `flat_hash`;
  `sorted_keys` and `sorted_values` bridge to array; `count_keys` and `has_key` are terminal.
- number: `abs`, `floor`, `ceil`, `round`, `add`, `sub`, `mul`, `div`, `mod`, `clamp`, `min`, `max`; `eq`, `ne`,
  `gt`, `ge`, `lt`, and `le` are terminal comparisons.

The July4 inventory described booleans and flow-result values as terminal. Expression-valued blocks and pure user-function returns do not
own separate method tables; the yielded value selects the compatible receiver family.

Most mutation forms, lifecycle/control helpers, child dispatch, capture/entry/match/input/mark readers,
declaration helpers, and compatibility aliases remain explicit non-pure surfaces. Uniform binding later makes
named array end mutations the result-valued exception: they return updated arrays and may feed compatible
continuations. See [[uniform-binding-array-end-result-supersession]].

The next leaf is `SPEC-FORMAT-TERSE.7.2`, which starts by verifying the existing string `substr()` receiver method
and only then backfills any genuinely missing string/scalar method surface.

## October19 current model and repair boundaries

Uniform bindings hold scalar, array, harray or codeblock; integer/real notation does not
create separate binding namespaces. Strings, numbers, boolean and null remain distinct
primitive values. Numeric helpers reject boolean/null; numeric comparisons return 1/0,
while logical helpers preserve boolean kind. Scalar normalization accepts false as "0".
Current Perl probes show false.cat("q") = "0q" and false.with() retaining false: the
July4 terminal statement is historical, not a current blanket restriction.

Deferred codeblocks read current caller slots; eager blocks execute immediately.
A called codeblock's array result can feed sorted(); this does not establish codeblock
dot-methods. Actual emitted source isolates two owned Perl defects: array constructors
and codeblock arguments can read a scalar after a later callback mutates it (.1.2.3);
attached with creates $value but omits its callable-name projection (.1.2.4), silently
yielding null for value(). Explicit callback parameters or copying value to a named
binding work. Both repairs precede complete operation inventory under TYPE-REFERENCE-BOOK.
Full source/model evidence and limits: docs/checkpoints/type-reference-inventory/README.md.
