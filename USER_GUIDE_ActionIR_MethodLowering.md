# USER GUIDE - ActionIR `MethodLowering.pm`
This guide covers the value-construction and general method lowering handled by `perl/LinkedSpec/ActionIR/MethodLowering.pm`.

This module is where many of the most important backend-neutral building blocks live.
For exact DSL-to-Perl examples for every constructor, selector, flattening helper, return helper, and compatibility surface mentioned here, also read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

Documentation note:
- nested method composition in arguments is intended to be supported with no fixed depth limit,
- but this guide uses representative examples only rather than enumerating every possible nesting combination.

For a cross-cutting tutorial that focuses specifically on string/integer/float scalars plus array/hash composition with many worked `.spec` examples, also read [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md).

## What this module is responsible for
In practical terms, this is the guide you want when you need to understand:
- `scalar(...)`
- `scalaref(...)`
- `array(...)`
- `hash(...)`
- `trim(...)`
- `lowercase(...)`
- `uppercase(...)`
- `length(...)`
- `replace_substr(...)`
- `rm_prefix(...)`
- `rm_suffix(...)`
- `concat(...)`
- `num_abs(...)`
- `num_floor(...)`
- `num_ceil(...)`
- `num_round(...)`
- `num_sum(...)`
- `num_avg(...)`
- `num_median(...)`
- `num_add(...)`
- `num_sub(...)`
- `num_mul(...)`
- `num_div(...)`
- `num_mod(...)`
- `num_clamp(...)`
- `num_min(...)`
- `num_max(...)`
- `starts_with(...)`
- `ends_with(...)`
- `contains_substr(...)`
- `matches(...)`
- `is_empty(...)`
- `is_nonempty(...)`
- `count(...)`
- `first(...)`
- `last(...)`
- `take(...)`
- `take_last(...)`
- `drop_last(...)`
- `tail(...)`
- `drop_front(...)` as an alias of `tail(...)`
- `drop_back(...)` as an alias of `drop_last(...)`
- `concat_arrays(...)`
- `sorted(...)`
- `reversed(...)`
- `contains(...)`
- `count_keys(...)`
- `sorted_keys(...)`
- `sorted_values(...)`
- `has_key(...)`
- `merge_hash(...)`
- `hash_copy(...)`
- `set_key(...)`
- `rename_key(...)`
- `drop_keys(...)`
- `pick_keys(...)`
- `coalesce_nonempty(...)`
- `coalesce(...)`
- `array_copy(...)`
- `array_values(...)` as a compatibility alias
- `flat(...)`, `flat_array(...)`, `flat_hash(...)` with compatibility alias `flatten(...)`
- `join_values(...)`
- `call(rule)` as a value source
- generalized `return(payload)` payload lowering
- `push_value(...)` value lowering

## `scalar(...)`
`scalar(...)` is the most frequently used value helper.

### Form 1: plain scalar variable access

```text
scalar(name)
scalar(retv)
scalar(flag)
```


Use it when you want the value of an existing scalar variable.

Examples:

```text
assign(scalar(token), scalar(retv))
return(hash("name", scalar(name)))
if(scalar(flag)); print("enabled\n"); endif()
```

### Form 2: capture-list indexing

```text
scalar(IMATCH_LIST, 0)
scalar(IMATCH_LIST, 1)
```

Use it when the current regex produced positional captures.

Examples:

```text
return(hash("kind", scalar(IMATCH_LIST, 0), "name", scalar(IMATCH_LIST, 1)))
assign(scalar(rule_name), scalar(IMATCH_LIST, 0))
```

### Form 3: collection entry access

```text
scalar(container, key_or_index)
scalar(array(items), idx)
scalar(hash(by_name), key)
scalar(sorted_keys(pick_keys(hash(meta), "kind", "source")), 0)
scalar(merge_hash(hash(meta), hash("stage", "normalized")), "stage")
scalar(set_key(hash(meta), "stage", "normalized"), "stage")
scalar(rename_key(hash(meta), "old_stage", "stage"), "stage")
```

This is useful for array/hash entry lookup without falling back to raw Perl indexing syntax.

The supported surface is broader than only direct working variables:
- direct arrays and hashes still work,
- and composed array-valued or hash-valued helper expressions now work too,
- so you do not need one temporary assignment just to read one first item from `sorted_keys(...)`, one field from `merge_hash(...)`, one normalized field from `set_key(...)`, or one renamed field from `rename_key(...)`.

Examples:

```text
assign(scalar(first_item), scalar(items, 0))
assign(scalar(value), scalar(hash(by_name), key))
assign(scalar(first_key), scalar(sorted_keys(pick_keys(hash(meta), "kind", "source")), 0))
assign(scalar(stage), scalar(merge_hash(hash(meta), hash("stage", "normalized")), "stage"))
assign(scalar(stage), scalar(set_key(hash(meta), "stage", "normalized"), "stage"))
assign(scalar(stage), scalar(rename_key(hash(meta), "old_stage", "stage"), "stage"))
if(eq(scalar(items, 0), "?branch:")); ... endif()
if(eq(scalar(sorted_keys(hash(meta)), 0), "kind")); ... endif()
```

## `scalaref(base, path)`
`scalaref(...)` is the canonical helper for nested dereference paths.

Examples:

```text
scalaref(retv, {content})
scalaref(node, [1])
scalaref(tree, [0]{name})
scalaref(cur_object, [1])
```

Use cases:
- extracting `content` from a returned hash payload,
- reading a positional field from an array payload,
- following mixed array/hash paths without writing raw dereference syntax.

Examples in context:

```text
assign(scalar(content), scalaref(retv, {content}))
push_value(array(word), scalaref(retv, {content}))
print("Object ", scalaref(cur_object, [1]), "\n")
```

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on supported nested accessor payload forms built from `scalaref(base, path)` plus indexed/keyed `scalar(...)` reads too,
- on both action-edge and lifecycle surfaces,
- so path-following value composition is part of the same equivalence contract as the rest of the method-like DSL surface.

## `array(...)`
`array(...)` constructs an array payload/value.

Examples:

```text
array(scalar(name), scalar(kind))
array("?node:", scalar(name), scalar(value))
array(undef)
array()
```

Typical uses:
- return payloads,
- push payloads,
- array-target assignment via `assign(array(name), array(...))`.

Examples:

```text
return(array("?pair:", scalar(lhs), scalar(rhs)))
push_value(array(items), array(scalar(tag), scalar(name)))
assign(array(word), array())
```

## `hash(...)`
`hash(...)` constructs a hash/object payload/value.

Examples:

```text
hash("type", "SPACE", "content", scalar(IMATCH))
hash("name", scalar(block_name), "content", array_copy(array(assigns)))
hash("kind", "node", "ok", 1)
```

Use it when you want a structured return object or a temporary hash value without raw Perl hash literal syntax.

## `array_copy(array(name))` and compatibility `array_values(...)`
This helper creates a **snapshot array payload**.

Examples:

```text
return(array_copy(array(items)))
return(hash("content", array_copy(array(assigns))))
push_value(array(nodes), array_copy(array(keyval_pairs)))
```

`array_values(array(...))` remains supported as a compatibility alias and lowers identically.

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on supported `array_copy(...)` and compatibility `array_values(...)` payload forms too,
- on both action-edge and lifecycle surfaces,
- and that same supported snapshot-helper equivalence is now regression-locked inside control-flow branch bodies too,
- so snapshot-array payload construction is part of the same equivalence contract as the rest of the method-like DSL surface.

This is one of the most important distinctions in the DSL.

### Use `array_copy(...)` when you want:
- an array payload,
- a nested arrayref-like value,
- a copy/snapshot of the current array contents.

### Do **not** use it when you want list insertion into a surrounding constructor.
For list insertion, use `flat_array(...)` or `flat(...)` instead.

## `hash_copy(hash_expr)`
This helper creates a **snapshot hash/object payload**.

Examples:

```text
return(hash_copy(hash(meta)))
return(hash("meta", hash_copy(hash(normalized_meta))))
assign(hash(snapshot_meta), hash_copy(pick_keys(hash(meta), "kind", "source")))
```

Use it when you want:
- one nested hash/object payload,
- one copy/snapshot of the current object shape,
- or one pure hash-valued expression that composes with `scalar(...)`, `count_keys(...)`, or `is_nonempty(...)` without mutating the source hash.

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on supported `hash_copy(...)` value forms too,
- on both action-edge and lifecycle surfaces,
- and the helper now composes through hash assignment, nested scalar reads, aggregate emptiness checks, and general `return(payload)` lowering.

## `concat_arrays(array_expr, array_expr, ...)`
Use `concat_arrays(...)` when you want one pure array value that appends multiple array-valued sources together without mutating any working array.

Examples:

```text
concat_arrays(array(parts), array("tail"))
concat_arrays(array(parts), sorted_keys(hash(meta)))
concat_arrays(array(parts), take(sorted_keys(hash(meta)), 2), array("tail"))
concat_arrays(
  coalesce(scalaref(retv, {parts}), array("fallback")),
  take(sorted_values(pick_keys(hash(meta), "kind", "source")), 1)
)
```

Typical contexts:

```text
declare(array, combined=concat_arrays(array(parts), sorted_keys(hash(meta)), array("tail")))
assign(array(combined), concat_arrays(array(parts), take(sorted_keys(hash(meta)), 2), array("tail")))
return(hash("combined", concat_arrays(array(parts), sorted_keys(hash(meta)))))
assign(scalar(combined_count), count(concat_arrays(array(parts), sorted_keys(hash(meta)))))
```

Use it when you want:
- one canonical array value built from several existing array-valued sources,
- projected arrays such as `sorted_keys(...)` or `sorted_values(...)` to feed straight into later array helpers,
- one direct array initializer or assignment source without temporary staging arrays,
- or one parser-oriented equivalent of “append these arrays together” that stays inside the DSL.

Important semantics:
- `concat_arrays(...)` accepts one or more operands,
- operands must be supported array-valued expressions such as direct working arrays, `array(...)`, projected arrays like `sorted_keys(...)` / `sorted_values(...)`, array slicing helpers like `take(...)` / `tail(...)`, or array-valued `coalesce(...)`,
- operands contribute their items in order from left to right,
- undefined array-valued operands contribute nothing rather than crashing or inventing a fallback,
- and clearly non-array helper forms are rejected at lowering time instead of being guessed.

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on representative `concat_arrays(...)` declaration, assignment, `return(payload)`, and reducer-composition forms too,
- on both action-edge and lifecycle surfaces,
- so pure array layering is now part of the same explicit method-like DSL contract as `sorted_keys(...)`, `take(...)`, `tail(...)`, and the other parser-oriented array helpers.

## `flat(...)`, `flat_array(...)`, `flat_hash(...)`
These helpers mean “splice this collection into the surrounding constructor.”

Examples:

```text
array("?subprogram_declaration:", flat_array(IMATCH_LIST))
hash(flat_hash(extra_pairs), "kind", "node")
array(flat_array(semantic_annotations))
array("keys", flat_array(sorted_keys(hash(meta))))
hash(flat_hash(pick_keys(hash(meta), "kind", "source")), "stage", "normalized")
```

Equivalent generic forms:

```text
array("?subprogram_declaration:", flat(array(IMATCH_LIST)))
hash(flat(hash(extra_pairs)), "kind", "node")
array(flat(array(semantic_annotations)))
```

`flatten(...)` remains supported as a compatibility alias for `flat(...)`, but new examples should use `flat(...)`. The helper is a list-context splice, not a recursive deep-tree flatten operation.

Use cases:
- inserting `@IMATCH_LIST` into a surrounding `array(...)`,
- inserting an existing hash's key/value pairs into a larger `hash(...)`,
- inserting the items from a composed array-valued helper such as `sorted_keys(...)` into a surrounding `array(...)`,
- inserting the pairs from a composed hash-valued helper such as `pick_keys(...)` or `hash_copy(...)` into a surrounding `hash(...)`,
- rebuilding list-shaped payloads without raw Perl `@array` / `%hash` insertion syntax.

The shorter `flat_array(...)` / `flat_hash(...)` spellings are just more direct aliases for the same idea.
They are no longer limited to one named working aggregate either: supported composed array-valued and hash-valued helper expressions can now flatten directly into surrounding constructors and direct `return(payload)` forms too.

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on supported `flat_array(...)` / `flat_hash(...)` payload forms too,
- on both action-edge and lifecycle surfaces,
- and that same supported flat-list equivalence is now regression-locked inside control-flow branch bodies too,
- while the supported source side now also includes composed aggregate helpers such as `sorted_keys(...)`, `sorted_values(...)`, `pick_keys(...)`, and `hash_copy(...)`,
- so list-context insertion is part of the same equivalence contract as the rest of the method-like DSL surface.

### Snapshot versus flatten
This distinction is easy to get wrong, so it is worth repeating.

#### Snapshot

```text
array_copy(array(items))
```

Meaning: “produce one array payload containing the current contents.”

#### Flatten/splice

```text
flat_array(items)
```

Meaning: “inject the array elements directly into the surrounding constructor.”

Composed example:

```text
flat_array(sorted_keys(hash(meta)))
```

Meaning: “compute one array value first, then inject its items directly into the surrounding constructor.”

Example:

```text
return(array("?node:", flat_array(IMATCH_LIST)))
```

This becomes the semantic equivalent of a constructor that directly inserts the match-list elements.

## `join_values(delimiter, array_expr)`
Use `join_values(...)` when you want to combine array elements into a single scalar string.

Examples:

```text
join_values("", array(word))
join_values(", ", array(parts))
join_values(", ", sorted_keys(hash(meta)))
join_values(" | ", sorted_values(pick_keys(hash(meta), "kind", "source")))
join_values(", ", coalesce(scalaref(retv, {parts}), array("fallback")))
```

Typical uses:
- flushing a temporary character/token array into a final word,
- turning token arrays into diagnostics or normalized text fragments,
- converting projected key/value arrays into one canonical summary string,
- and reducing fallback array expressions without leaving the value-expression layer.

Examples in context:

```text
assign(scalar(word_text), join_values("", array(word)))
assign(scalar(public_fields), join_values(", ", sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(scalar(public_values), join_values(" | ", sorted_values(pick_keys(hash(meta), "kind", "source", "stage"))))
push_value(array(tail), join_values("", array(word)))
return(join_values(", ", sorted_keys(drop_keys(hash(meta), "debug"))))
```

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on supported `join_values(delimiter, array_expr)` payload forms too,
- on both action-edge and lifecycle surfaces,
- direct working arrays and composed array-valued helper expressions now share the same lowering contract,
- and that same supported `join_values(...)` equivalence is now regression-locked inside control-flow branch bodies too,
- so string-join payload construction is part of the same equivalence contract as the rest of the method-like DSL surface.

Important semantic note:
- if the source is one normal working array, `join_values(...)` behaves like ordinary join over that array,
- if the source is one composed array-valued helper expression, the helper result is joined directly,
- stable projections like `sorted_keys(...)` and `sorted_values(...)` therefore join cleanly without temporary array variables,
- and if an outer array-valued expression is still undefined, `join_values(...)` preserves that undefined result instead of silently inventing one fallback string.

## Scalar normalization helpers
These are parser-oriented scalar transforms:
- `trim(value)`
- `lowercase(value)`
- `uppercase(value)`
- `replace_substr(value, needle, replacement)`

They are meant for scalar text normalization inside value composition, not as standalone raw-string escape hatches.

### `trim(value)`
Use `trim(...)` when you want leading/trailing whitespace removed while keeping the expression inside the canonical method-like DSL surface.

Examples:

```text
trim(scalar(IMATCH))
trim(scalaref(retv, {content}))
trim(coalesce(scalaref(retv, {type}), " UNKNOWN "))
```

### `lowercase(value)`
Use `lowercase(...)` when the rule needs a normalized lower-case scalar.

Examples:

```text
lowercase(scalar(name))
lowercase(trim(scalar(IMATCH)))
lowercase(coalesce(scalaref(retv, {type}), "WORD"))
```

### `uppercase(value)`
Use `uppercase(...)` when the rule needs a normalized upper-case scalar.

Examples:

```text
uppercase(scalar(name))
uppercase(trim(scalaref(retv, {type})))
uppercase(coalesce(scalaref(retv, {kind}), "unknown"))
```

Important semantic note:
- these helpers preserve `undef` rather than silently turning it into `""`,
- so `lowercase(undef)` stays undefined,
- `uppercase(undef)` stays undefined,
- and `trim(undef)` stays undefined too.

Typical uses:
- normalize a child payload field before comparison,
- clean captured text before storing it,
- build canonical return payloads with normalized casing,
- keep string normalization expression-oriented rather than expanding it into marker-style branch ladders.

Examples in context:

```text
assign(scalar(chosen_name), lowercase(trim(coalesce(scalaref(retv, {content}), scalar(IMATCH), " UNKNOWN "))))
return(hash("type", uppercase(trim(coalesce(scalaref(retv, {type}), "word")))))
if(eq(lowercase(trim(scalaref(retv, {type}))), "word")); ... endif()
```

## `replace_substr(value_expr, needle_expr, replacement_expr)`
Use `replace_substr(...)` when you want one pure literal substring rewrite inside the canonical method-like DSL surface.

Examples:

```text
replace_substr(scalar(name), "-", "_")
replace_substr(lowercase(trim(scalar(name))), " ", "_")
replace_substr(coalesce(scalaref(retv, {kind}), scalar(IMATCH)), "::", ".")
```

Typical uses:
- normalize one parser-facing name without dropping into raw host-language `s///` code,
- rewrite separators like `-`, space, `/`, or `::` inside one nested value expression,
- keep string cleanup pure and composable inside assignments, direct `return(payload)` expressions, and comparisons,
- and avoid using statement-style `regex_subst(...)` when the intent is “produce one new normalized scalar value” rather than “mutate one existing scalar slot”.

Important semantic note:
- `replace_substr(...)` is a literal substring rewrite helper, not a regex helper,
- all three operands must be defined or the result stays `undef`,
- an empty needle returns the original value unchanged instead of doing between-character insertion,
- and the helper stays pure, so it can be nested inside `eq(...)`, `starts_with(...)`, `contains_substr(...)`, `hash(...)`, `coalesce(...)`, and other value helpers.

Examples in context:

```text
assign(scalar(normalized_name), replace_substr(lowercase(trim(scalar(name))), "-", "_"))
assign(scalar(normalized_kind), replace_substr(lowercase(trim(coalesce(scalaref(retv, {kind}), scalar(IMATCH)))), " ", "_"))
if(eq(replace_substr(lowercase(trim(scalar(name))), "-", "_"), "node_item")); ... endif()
return(hash(
  "normalized_name", replace_substr(lowercase(trim(scalar(name))), "-", "_"),
  "normalized_kind", replace_substr(lowercase(trim(coalesce(scalaref(retv, {kind}), scalar(IMATCH)))), " ", "_")
))
```

## `rm_prefix(value_expr, prefix_expr)` and `rm_suffix(value_expr, suffix_expr)`
Use these when you want one pure literal boundary trim inside the canonical method-like DSL surface.

Examples:

```text
rm_prefix(lowercase(trim(scalar(name))), "node_")
rm_suffix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "_end")
rm_prefix(coalesce_nonempty(trim(scalaref(retv, {type})), scalar(IMATCH), "word"), "raw_")
rm_suffix(concat(lowercase(trim(scalar(name))), "_", scalar(stage)), "_draft")
```

Typical uses:
- strip one leading parser marker such as `node_`, `raw_`, or `tmp_` after normalization,
- strip one trailing marker such as `_end`, `_draft`, or `_tail` without dropping into regexes,
- keep one boundary cleanup step pure and composable inside assignments, direct `return(payload)` expressions, and comparisons,
- and avoid expanding common prefix/suffix cleanup into branch ladders or raw host-language string code.

Important semantic note:
- both helpers are literal boundary transforms, not regex helpers,
- both require defined scalar operands or the result stays `undef`,
- an empty prefix/suffix leaves the source value unchanged,
- if the requested boundary is not present, the original value is returned unchanged,
- and the helpers stay pure, so they can be nested inside `eq(...)`, `concat(...)`, `hash(...)`, `coalesce_nonempty(...)`, `starts_with(...)`, and other value helpers.

Examples in context:

```text
assign(scalar(core_name), rm_prefix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "node_"))
assign(scalar(base_name), rm_suffix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "_end"))
if(eq(rm_prefix(lowercase(trim(scalar(name))), "node_"), "item_end")); ... endif()
if(eq(rm_suffix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "_end"), "node_item")); ... endif()
return(hash(
  "core_name", rm_prefix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "node_"),
  "base_name", rm_suffix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "_end")
))
```

## `concat(value_expr, value_expr, ...)`
Use `concat(...)` when you want to build one scalar string value from multiple scalar fragments without staging through an array helper first.

Examples:

```text
concat(scalar(name), "_", scalar(stage))
concat(lowercase(trim(scalar(first_name))), "_", replace_substr(lowercase(trim(scalar(last_name))), " ", "_"))
concat(coalesce_nonempty(trim(scalaref(retv, {type})), scalar(IMATCH), "word"), "::", uppercase(trim(scalar(kind))))
```

Typical uses:
- build one canonical key or normalized identifier from multiple parser-facing scalar fragments,
- keep string assembly pure and composable inside assignments, direct `return(payload)` expressions, and comparisons,
- avoid temporary array staging when the rule already knows the exact scalar pieces it wants to join,
- and keep string construction inside the same parser-oriented expression layer as `trim(...)`, `replace_substr(...)`, `coalesce_nonempty(...)`, and `scalar(...)`.

Important semantic note:
- `concat(...)` is variadic and currently requires two or more operands,
- all operands must resolve to defined non-reference scalar values or the result stays `undef`,
- numeric-looking scalar values are accepted and stringified naturally,
- and aggregate references are rejected instead of being silently stringified into host-language ref text.

Examples in context:

```text
assign(scalar(full_name), concat(lowercase(trim(scalar(first_name))), "_", replace_substr(lowercase(trim(scalar(last_name))), " ", "_")))
assign(scalar(stage_key), concat(scalar(full_name), "::", scalar(stage)))
if(eq(concat(lowercase(trim(scalar(name))), "_", scalar(stage)), "node_init")); ... endif()
return(hash(
  "full_name", concat(lowercase(trim(scalar(first_name))), "_", replace_substr(lowercase(trim(scalar(last_name))), " ", "_")),
  "stage_key", concat(scalar(full_name), "::", scalar(stage))
))
```

## `length(scalar_expr)`
Use `length(...)` when you want one scalar length value from a scalar expression without leaving the canonical method-like DSL surface.

Examples:

```text
length(scalar(name))
length(trim(scalaref(retv, {content})))
length(coalesce(scalaref(retv, {content}), scalar(IMATCH), "UNKNOWN"))
```

Typical uses:
- branch on whether normalized text is longer than one threshold,
- store one canonical text-length field in a scalar slot,
- return string-length metadata without dropping into raw host-language code.

Important semantic note:
- `length(...)` is about scalar/string length,
- not about array size,
- and if the scalar expression is still undefined, `length(...)` preserves `undef` rather than collapsing it to `0`.

Examples in context:

```text
assign(scalar(clean_length), length(trim(scalar(raw_name))))
assign(scalar(content_length), length(coalesce(scalaref(retv, {content}), scalar(IMATCH), "UNKNOWN")))
if(num_gt(coalesce(length(trim(scalar(name))), 0), 3)); ... endif()
return(hash("content_length", length(trim(coalesce(scalaref(retv, {content}), scalar(IMATCH), "UNKNOWN")))))
```

Use `coalesce(length(...), 0)` when the rule explicitly wants “missing text counts as zero length” rather than “missing text stays undefined”.

## `num_abs(value_expr)`, `num_floor(value_expr)`, `num_ceil(value_expr)`, `num_round(value_expr)`, `num_sum(array_expr)`, `num_avg(array_expr)`, `num_median(array_expr)`, `num_range(array_expr)`, `num_add(value_expr, value_expr, ...)`, `num_sub(lhs, rhs)`, `num_mul(value_expr, value_expr, ...)`, `num_div(lhs, rhs)`, `num_mod(lhs, rhs)`, `num_clamp(value_expr, lower_bound, upper_bound)`, `num_min(...)`, and `num_max(...)`
Use these when you want parser-oriented numeric composition without leaving the canonical method-like DSL surface.

Examples:

```text
num_abs(num_sub(scalar(depth), scalar(limit)))
num_abs(num_sub(num_add(count(array(parts)), scalar(offset)), scalar(limit)))
num_floor(num_sub(scalar(depth), scalar(offset)))
num_ceil(num_div(num_mul(count(array(parts)), scalar(factor)), 2))
num_round(num_add(coalesce(length(trim(scalar(name))), 0), 0.5))
num_sum(array(scores))
num_sum(take(concat_arrays(array(scores), array(extra_scores)), 4))
num_avg(array(scores))
num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4))
num_median(array(scores))
num_median(take(concat_arrays(array(scores), array(extra_scores)), 4))
num_range(array(scores))
num_range(take(concat_arrays(array(scores), array(extra_scores)), 4))
num_min(array(scores))
num_min(take(concat_arrays(array(scores), array(extra_scores)), 4))
num_add(scalar(depth), 1)
num_add(coalesce(length(trim(scalar(name))), 0), 2, scalar(offset))
num_sub(count(array(parts)), 1)
num_sub(num_add(count(array(parts)), scalar(offset)), 1)
num_mul(count(array(parts)), scalar(factor))
num_div(num_mul(count(array(parts)), scalar(factor)), 2)
num_mod(num_add(count(array(parts)), scalar(offset)), 3)
num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10)
num_min(num_add(count(array(parts)), scalar(offset)), scalar(limit), 10)
num_max(array(scores))
num_max(take(concat_arrays(array(scores), array(extra_scores)), 4))
num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(limit))
```

These helpers are intentionally narrow:
- `num_abs(...)` is the canonical numeric “absolute value of this operand” helper and is currently unary,
- `num_floor(...)` is the canonical numeric “round down to the nearest integer” helper and is currently unary,
- `num_ceil(...)` is the canonical numeric “round up to the nearest integer” helper and is currently unary,
- `num_round(...)` is the canonical numeric “round to the nearest integer” helper and is currently unary,
- `num_sum(...)` is the canonical numeric “sum the numeric-looking items in this array-valued expression” helper and is currently unary on one array source,
- `num_avg(...)` is the canonical numeric “average the numeric-looking items in this array-valued expression” helper and is currently unary on one array source,
- `num_median(...)` is the canonical numeric “median of the numeric-looking items in this array-valued expression” helper and is currently unary on one array source,
- `num_range(...)` is the canonical numeric “max minus min across the numeric-looking items in this array-valued expression” helper and is currently unary on one array source,
- `num_add(...)` is the canonical numeric “sum these operands” helper and accepts two or more operands,
- `num_sub(...)` is the canonical numeric “subtract rhs from lhs” helper and is currently binary,
- `num_mul(...)` is the canonical numeric “multiply these operands” helper and accepts two or more operands,
- `num_div(...)` is the canonical numeric “divide lhs by rhs” helper and is currently binary,
- `num_mod(...)` is the canonical numeric “integer remainder after dividing lhs by rhs” helper and is currently binary,
- `num_clamp(...)` is the canonical numeric “keep this value inside the provided lower/upper bounds” helper and is currently ternary,
- `num_min(...)` is the canonical numeric “pick the smallest item” helper and accepts either one array-valued source or two or more operands,
- `num_max(...)` is the canonical numeric “pick the largest item” helper and accepts either one array-valued source or two or more operands,
- both helpers return one scalar numeric value,
- and both stay pure value helpers, so they compose inside `assign(...)`, `return(payload)`, and `num_*` flow comparisons.

Examples in context:

```text
assign(scalar(distance), num_abs(num_sub(num_add(count(array(parts)), scalar(offset)), scalar(limit))))
assign(scalar(floored_depth), num_floor(num_sub(scalar(depth), scalar(offset))))
assign(scalar(ceiled_average), num_ceil(num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor))))
assign(scalar(rounded_name_length), num_round(num_add(coalesce(length(trim(scalar(name))), 0), 0.5)))
assign(scalar(total_score), num_sum(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(average_score), num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(median_score), num_median(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(score_range), num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(lowest_score), num_min(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(next_depth), num_add(scalar(depth), 1))
assign(scalar(window_size), num_sub(count(array(parts)), 1))
assign(scalar(scaled_count), num_mul(count(array(parts)), scalar(factor)))
assign(scalar(average_count), num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor)))
assign(scalar(bucket), num_mod(num_add(count(array(parts)), scalar(offset)), 3))
assign(scalar(clamped_total), num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10))
assign(scalar(floor_value), num_min(num_add(count(array(parts)), scalar(offset)), scalar(limit), 10))
assign(scalar(ceiling_value), num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(limit)))
assign(scalar(total), num_add(coalesce(length(trim(scalar(name))), 0), 2, scalar(offset)))
if(num_gt(num_add(count(array(parts)), scalar(offset)), 3)); ... endif()
if(num_gt(num_abs(num_sub(coalesce(length(trim(scalar(name))), 0), scalar(offset))), 3)); ... endif()
if(num_ge(num_floor(num_sub(scalar(depth), scalar(offset))), 2)); ... endif()
if(num_ge(num_ceil(num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor))), 3)); ... endif()
if(num_eq(num_round(num_add(coalesce(length(trim(scalar(name))), 0), 0.5)), 6)); ... endif()
if(num_ge(num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4)), 5)); ... endif()
if(num_ge(num_median(take(concat_arrays(array(scores), array(extra_scores)), 4)), 5)); ... endif()
if(num_eq(num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)), 6)); ... endif()
if(num_ge(num_min(take(concat_arrays(array(scores), array(extra_scores)), 4)), 2)); ... endif()
if(num_gt(num_mul(count(array(parts)), scalar(factor)), 3)); ... endif()
if(num_eq(num_mod(num_add(count(array(parts)), scalar(offset)), 3), 1)); ... endif()
if(num_eq(num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), scalar(limit)), 5)); ... endif()
if(num_ge(num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(limit)), 6)); ... endif()
return(hash(
  "next_depth", num_add(scalar(depth), 1),
  "distance", num_abs(num_sub(num_add(count(array(parts)), scalar(offset)), scalar(limit))),
  "floored_depth", num_floor(num_sub(scalar(depth), scalar(offset))),
  "ceiled_average", num_ceil(num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor))),
  "rounded_name_length", num_round(num_add(coalesce(length(trim(scalar(name))), 0), 0.5)),
  "average_score", num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "median_score", num_median(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "score_range", num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "lowest_score", num_min(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "remaining", num_sub(num_add(count(array(parts)), scalar(offset)), 1),
  "average_count", num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor)),
  "bucket", num_mod(num_add(count(array(parts)), scalar(offset)), 3),
  "clamped_total", num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), scalar(limit)),
  "floor_value", num_min(num_add(count(array(parts)), scalar(offset)), scalar(limit), 10),
  "ceiling_value", num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(limit))
)))
```

Important semantic notes:
- these helpers expect defined numeric-looking operands,
- supported numeric-looking forms are simple integer/decimal values such as `0`, `-3`, `0.75`, and `12.5`,
- if any operand is still undefined or not numeric-looking, the arithmetic helper returns `undef`,
- `num_abs(...)` evaluates its single operand under that same numeric-looking contract,
- `num_floor(...)`, `num_ceil(...)`, and `num_round(...)` also evaluate one numeric-looking operand under that same contract,
- `num_round(...)` rounds halves away from zero so the intent stays explicit and host-portable,
- `num_sum(...)` reduces one array-valued expression and returns `0` for an empty array but `undef` when the source is not array-valued or when any element is missing/non-numeric-looking,
- `num_avg(...)` reduces one array-valued expression and returns `undef` for an empty array, for a non-array source, or when any element is missing/non-numeric-looking,
- `num_median(...)` reduces one array-valued expression and returns `undef` for an empty array, for a non-array source, or when any element is missing/non-numeric-looking,
- `num_median(...)` sorts the numeric-looking items numerically before choosing the middle,
- for odd-length arrays `num_median(...)` returns the single middle item, and for even-length arrays it returns the average of the two middle items,
- `num_range(...)` reduces one array-valued expression and returns `undef` for an empty array, for a non-array source, or when any item is missing/non-numeric-looking,
- `num_range(...)` returns the numeric maximum minus the numeric minimum after one validation pass over the array, so a one-item array yields `0`,
- `num_div(...)` also returns `undef` when the divisor is `0`,
- `num_mod(...)` is intentionally stricter than the other arithmetic helpers and currently expects integer-looking operands such as `0`, `3`, or `-7`,
- `num_mod(...)` also returns `undef` when the divisor is `0`,
- `num_clamp(...)` accepts numeric-looking scalar value/bound operands and returns `undef` when the lower bound is greater than the upper bound instead of silently swapping them,
- `num_min(array_expr)` and `num_max(array_expr)` reduce one array-valued expression and return `undef` for an empty array, for a non-array source, or when any item is missing/non-numeric-looking,
- `num_min(value1, value2, ...)` and `num_max(value1, value2, ...)` still evaluate all provided operands under that same numeric-looking contract,
- the one-argument reducer mode of `num_min(...)` / `num_max(...)` is reserved for array-valued sources rather than one standalone scalar term,
- and when the rule wants “missing means zero,” that should be stated explicitly with `coalesce(...)`.

Examples:

```text
num_abs(coalesce(num_sub(scalar(depth), scalar(limit)), 0))
num_floor(coalesce(num_sub(scalar(depth), scalar(offset)), 0))
num_ceil(coalesce(num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor)), 0))
num_round(coalesce(num_add(length(trim(scalar(name))), 0.5), 0))
num_sum(coalesce(scalaref(retv, {scores}), array()))
coalesce(num_avg(coalesce(scalaref(retv, {scores}), array())), 0)
coalesce(num_median(coalesce(scalaref(retv, {scores}), array())), 0)
coalesce(num_range(coalesce(scalaref(retv, {scores}), array())), 0)
coalesce(num_min(coalesce(scalaref(retv, {scores}), array())), 0)
num_add(coalesce(scalar(depth), 0), 1)
num_sub(coalesce(length(trim(scalar(name))), 0), 1)
num_mul(coalesce(count(array(parts)), 0), scalar(factor))
coalesce(num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor)), 0)
num_mod(coalesce(num_add(count(array(parts)), scalar(offset)), 0), 3)
num_clamp(coalesce(num_add(count(array(parts)), scalar(offset)), 0), scalar(lower_limit), 10)
num_min(coalesce(num_add(count(array(parts)), scalar(offset)), 0), scalar(limit), 10)
coalesce(num_max(coalesce(scalaref(retv, {scores}), array())), 0)
num_max(coalesce(num_add(count(array(parts)), scalar(offset)), 0), 2, scalar(limit))
num_gt(coalesce(num_add(scalar(depth), scalar(offset)), 0), 3)
```

This is deliberate. The arithmetic surface is now standardized, including the array-to-scalar reducers `num_sum(...)`, `num_avg(...)`, `num_median(...)`, and `num_range(...)`, the float-friendly unary rounding helpers, and the integer-oriented remainder helper `num_mod(...)`, but it is still parser-oriented and small rather than a full general-purpose math language.

## `starts_with(value_expr, prefix_expr)`, `ends_with(value_expr, suffix_expr)`, `contains_substr(value_expr, needle_expr)`, and `matches(value_expr, /regex/)`
Use these when you want one scalar flag answering “does this normalized string begin with this prefix?”, “does it end with this suffix?”, “does it contain this substring anywhere?”, or “does it match this regex?”

Examples:

```text
starts_with(scalar(name), "pre")
ends_with(scalar(name), "fix")
contains_substr(scalar(name), "efi")
starts_with(lowercase(trim(scalar(name))), "node_")
ends_with(lowercase(trim(coalesce(scalaref(retv, {kind}), scalar(IMATCH)))), "_end")
contains_substr(lowercase(trim(coalesce(scalaref(retv, {kind}), scalar(IMATCH)))), "node")
matches(lowercase(trim(scalar(name))), /^node_/)
matches(coalesce(scalaref(retv, {type}), scalar(IMATCH)), /^[A-Z_]+$/)
```

Typical uses:
- keep one parser-oriented prefix/suffix check inside value lowering instead of dropping to host-language `index(...)` or `substr(...)`,
- keep one parser-oriented substring-membership check inside value lowering instead of dropping to host-language `index(...) >= 0` tests,
- keep one parser-oriented regex-membership check inside value lowering instead of dropping to host-language regex conditionals in assignment or return code,
- assign one canonical boolean-ish scalar flag into the working state,
- return one boundary-check flag in payload metadata,
- and branch on the same helper inside `if(...)`, `elseif(...)`, or `switch(...)` expressions.

Important semantic note:
- all three helpers return `1` or `0`,
- all four helpers return `1` or `0`,
- they preserve composability with `trim(...)`, `lowercase(...)`, `uppercase(...)`, `coalesce(...)`, `scalar(...)`, and `scalaref(...)`,
- if the main value is undefined, the result is `0`,
- if the prefix/suffix expression is undefined, the result is `0`,
- if the substring needle expression is undefined, the result is `0`,
- `matches(...)` is designed around the same regex surface already used in flow predicates such as `matches(lhs, /regex/)`,
- and empty string prefixes/suffixes/substrings therefore still behave consistently once both sides are defined.

Examples in context:

```text
assign(scalar(has_node_prefix), starts_with(lowercase(trim(scalar(name))), "node_"))
assign(scalar(has_end_suffix), ends_with(lowercase(trim(scalar(name))), "_end"))
assign(scalar(has_mid_node), contains_substr(lowercase(trim(coalesce(scalaref(retv, {kind}), scalar(IMATCH)))), "node"))
assign(scalar(is_wordish), matches(uppercase(trim(coalesce(scalaref(retv, {type}), scalar(IMATCH)))), /^[A-Z_]+$/))
if(starts_with(lowercase(trim(scalar(name))), "node_")); ... endif()
if(contains_substr(lowercase(trim(scalar(name))), "node")); ... endif()
if(matches(lowercase(trim(scalar(name))), /^node_/)); ... endif()
if(and(starts_with(lowercase(trim(scalar(name))), "node_"), contains_substr(lowercase(trim(scalar(name))), "node"))); ... endif()
return(hash(
  "has_node_prefix", starts_with(lowercase(trim(scalar(name))), "node_"),
  "has_end_suffix", ends_with(lowercase(trim(scalar(name))), "_end"),
  "has_mid_node", contains_substr(lowercase(trim(coalesce(scalaref(retv, {kind}), scalar(IMATCH)))), "node"),
  "is_wordish", matches(uppercase(trim(coalesce(scalaref(retv, {type}), scalar(IMATCH)))), /^[A-Z_]+$/)
))
```

## `is_empty(value_expr)` and `is_nonempty(value_expr)`
Use these when you want one scalar emptiness flag inside the value layer, not only inside `if(...)` / `elseif(...)` / `switch(...)` conditions.

Examples:

```text
is_empty(sorted_values(pick_keys(hash(meta), "kind", "source")))
is_nonempty(pick_keys(drop_keys(hash(meta), "debug"), "kind", "source"))
is_empty(join_values("", array(word)))
is_nonempty(coalesce(scalaref(retv, {parts}), array("fallback")))
```

This is the value-layer companion to the already-supported flow-predicate surface:
- you can assign these flags into scalars,
- return them inside `hash(...)` payloads,
- and keep the same aggregate-aware emptiness semantics when the argument is a projected array/hash expression rather than one direct working variable.

Examples in context:

```text
assign(scalar(values_empty), is_empty(sorted_values(pick_keys(hash(meta), "kind", "source"))))
assign(scalar(meta_nonempty), is_nonempty(pick_keys(drop_keys(hash(meta), "debug"), "kind", "source")))
return(hash(
  "values_empty", is_empty(sorted_values(pick_keys(hash(meta), "kind", "source"))),
  "meta_nonempty", is_nonempty(pick_keys(drop_keys(hash(meta), "debug"), "kind", "source")))
))
return(hash(
  "content_empty", is_empty(join_values("", array(word))),
  "fallback_nonempty", is_nonempty(coalesce(scalaref(retv, {parts}), array("fallback")))
))
```

Important semantic note:
- this slice does not replace the existing flow lowering,
- it extends the same emptiness family into general value lowering,
- so `is_empty(...)` / `is_nonempty(...)` can now be used consistently in assignments, direct `return(payload)` expressions, and flow conditions.

## `count(array_or_array_expr)`
Use `count(...)` when you want one scalar size/count result from an array variable or array-valued expression.

Examples:

```text
count(array(parts))
count(coalesce(scalaref(retv, {parts}), array("empty")))
count(array("a", "b", "c"))
```

Typical uses:
- branch on whether one working array has elements,
- store one canonical item count in a scalar slot,
- return array size metadata without dropping into raw host-language code.

Important semantic note:
- `count(array(name))` lowers to the live array-variable size,
- `count(array-valued expression)` lowers by counting the referenced array payload,
- and when an array-valued expression is still undefined, `count(...)` returns `0`.

Examples in context:

```text
assign(scalar(part_count), count(array(parts)))
assign(scalar(part_count), count(coalesce(scalaref(retv, {parts}), array("empty"))))
if(num_gt(count(array(parts)), 0)); ... endif()
return(hash("part_count", count(coalesce(scalaref(retv, {parts}), array("empty")))))
```

## `first(array_or_array_expr)` and `last(array_or_array_expr)`
Use `first(...)` and `last(...)` when you want one scalar boundary value from an array variable or array-valued expression.

Examples:

```text
first(array(parts))
last(array(parts))
first(sorted_keys(hash(meta)))
last(sorted_values(pick_keys(hash(meta), "kind", "source")))
first(coalesce(scalaref(retv, {parts}), array("fallback")))
```

Important semantic note:
- `first(array(name))` reads the first live array element,
- `last(array(name))` reads the last live array element,
- `first(projected_array_expr)` and `last(projected_array_expr)` work directly on composed array-valued helpers like `sorted_keys(...)`, `sorted_values(...)`, and array-valued `coalesce(...)` chains,
- and if the array-valued expression is undefined or empty, both helpers return `undef`.

Examples in context:

```text
assign(scalar(first_part), first(array(parts)))
assign(scalar(first_key), first(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(scalar(last_value), last(sorted_values(pick_keys(hash(meta), "kind", "source", "stage"))))
if(eq(first(sorted_keys(hash(meta))), "kind")); ... endif()
return(hash("first_key", first(sorted_keys(hash(meta))), "last_value", last(sorted_values(hash(meta)))))
```

## `index_of(array_or_array_expr, needle_expr)`
Use `index_of(...)` when you want one scalar first-match index from an array variable or one composed array-valued expression.

Examples:

```text
index_of(array(parts), "kind")
index_of(sorted_keys(hash(meta)), "kind")
index_of(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), "normalized")
index_of(coalesce(scalaref(retv, {parts}), array("fallback")), scalar(IMATCH))
index_of(concat_arrays(array(parts), array("tail")), "tail")
```

Important semantic note:
- `index_of(array(name), needle)` searches the live working array from left to right,
- `index_of(projected_array_expr, needle)` works directly on composed array-valued helpers like `sorted_keys(...)`, `sorted_values(...)`, `concat_arrays(...)`, and array-valued `coalesce(...)`,
- the result is one scalar index, using the same zero-based indexing model as `scalar(array_expr, 0)`,
- if the first match is at the first position, the result is `0`,
- if there is no matching item, the result is `undef`,
- if the source expression is undefined or not array-valued, the result is `undef`,
- and when the needle itself is `undef`, `index_of(...)` searches for the first undefined array item rather than coercing everything to strings.

Examples in context:

```text
assign(scalar(kind_index), index_of(array(parts), "kind"))
assign(scalar(kind_index), index_of(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), "kind"))
assign(scalar(stage_index), index_of(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), "normalized"))
if(is_defined(index_of(sorted_keys(hash(meta)), "kind"))); ... endif()
if(num_eq(index_of(sorted_keys(hash(meta)), "kind"), 0)); ... endif()
return(hash(
  "kind_index", index_of(sorted_keys(hash(meta)), "kind"),
  "stage_index", index_of(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), "normalized")
))
```

## `tail(array_or_array_expr)` / `drop_front(array_or_array_expr)`
## `tail(array_or_array_expr, drop_count)` / `drop_front(array_or_array_expr, drop_count)`
Use `tail(...)` when you want one array value that contains everything after the first element, or after the first `N` elements when an explicit drop count is supplied. `drop_front(...)` is the exact alias for the same lowering contract.

Examples:

```text
tail(array(parts))
tail(array(parts), 2)
drop_front(array(parts))
drop_front(array(parts), 2)
tail(sorted_keys(hash(meta)))
tail(sorted_keys(hash(meta)), scalar(skip_count))
tail(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")))
tail(coalesce(scalaref(retv, {parts}), array("fallback")))
```

Typical uses:
- implement head/tail style recursive parsing without dropping into host-language slicing,
- keep one leading token separate while carrying the remainder as a canonical array value,
- skip the first few stable projected keys or values when the rule has already consumed them elsewhere,
- skip one normalized projected key and continue working on the rest of the projected array.

Important semantic note:
- `tail(array_expr)` is shorthand for `tail(array_expr, 1)`,
- `drop_front(array_expr)` is the exact alias of `tail(array_expr)`,
- `tail(array(name))` returns one new array value containing every live element after index `0`,
- `tail(array_expr, drop_count)` drops the first `drop_count` entries when that count is one explicit integer-like scalar expression,
- `drop_front(array_expr, drop_count)` is the exact alias of `tail(array_expr, drop_count)`,
- `tail(projected_array_expr)` works directly on composed array-valued helpers like `sorted_keys(...)`, `sorted_values(...)`, `pick_keys(...)`, `tail(...)`, and array-valued `coalesce(...)` chains,
- `tail(...)` always returns an array value rather than one scalar boundary element,
- and if the source array is empty, too short for the requested drop count, or the array-valued expression is still undefined, `tail(...)` returns one empty array instead of `undef`.

Examples in context:

```text
assign(array(rest_parts), tail(array(parts)))
assign(array(rest_parts), tail(array(parts), 2))
assign(array(rest_parts), drop_front(array(parts), 2))
assign(array(rest_keys), tail(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(array(rest_keys), tail(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(skip_count)))
assign(scalar(rest_count), count(tail(sorted_keys(hash(meta)))))
if(num_gt(count(tail(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0)); ... endif()
return(hash("rest_keys", tail(sorted_keys(hash(meta))), "rest_count", count(tail(sorted_keys(hash(meta))))))
```

## `take(array_or_array_expr)` and `take(array_or_array_expr, take_count)`
Use `take(...)` when you want one array value containing the first element, or the first `N` elements when an explicit take count is supplied.

Examples:

```text
take(array(parts))
take(array(parts), 2)
take(sorted_keys(hash(meta)))
take(sorted_keys(hash(meta)), scalar(take_count))
take(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")))
take(coalesce(scalaref(retv, {parts}), array("fallback")))
```

Typical uses:
- keep a canonical prefix array while the rule keeps processing the remaining structure elsewhere,
- preserve the first few stable projected keys or values as one explicit summary payload,
- express “take the first `N` tokens/items” without raw Perl slicing,
- and feed one bounded prefix array directly into reducers like `count(...)` or nested reads like `scalar(take(...), 0)`.

Important semantic note:
- `take(array_expr)` is shorthand for `take(array_expr, 1)`,
- `take(array(name))` returns one new array value containing the first live element when present,
- `take(array_expr, take_count)` keeps the first `take_count` entries when that count is one explicit integer-like scalar expression,
- `take(projected_array_expr)` works directly on composed array-valued helpers like `sorted_keys(...)`, `sorted_values(...)`, `take(...)`, `tail(...)`, and array-valued `coalesce(...)` chains,
- `take(...)` always returns an array value rather than one scalar boundary element,
- and if the source array is empty, the requested take count is non-positive, or the array-valued expression is still undefined, `take(...)` returns one empty array instead of `undef`.

Examples in context:

```text
assign(array(first_parts), take(array(parts)))
assign(array(first_parts), take(array(parts), 2))
assign(array(first_keys), take(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(array(first_keys), take(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(take_count)))
assign(scalar(first_count), count(take(sorted_keys(hash(meta)), 2)))
if(num_gt(count(take(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0)); ... endif()
return(hash("first_keys", take(sorted_keys(hash(meta))), "first_count", count(take(sorted_keys(hash(meta)), 2))))
```

## `slice(array_or_array_expr, start_index)` and `slice(array_or_array_expr, start_index, take_count)`
Use `slice(...)` when you want one middle array value that starts at one explicit zero-based position, optionally bounded to one explicit item count.

Examples:

```text
slice(array(parts), 1)
slice(array(parts), 1, 2)
slice(sorted_keys(hash(meta)), 1)
slice(sorted_keys(hash(meta)), scalar(slice_start), scalar(slice_count))
slice(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 1, 2)
slice(coalesce(scalaref(retv, {parts}), array("fallback")), scalar(slice_start))
```

Typical uses:
- keep one middle window of tokens/items without spelling raw Perl slicing,
- preserve one stable interior subset of projected keys or values as one explicit summary payload,
- derive one bounded subarray that still composes with reducers like `count(...)`,
- and feed one middle array directly into nested reads like `scalar(slice(...), 0)` when one later step needs the first kept item.

Important semantic note:
- `slice(array_expr, start_index)` keeps every entry from `start_index` through the end of the source array,
- `slice(array_expr, start_index, take_count)` keeps at most `take_count` entries starting at `start_index`,
- `start_index` and `take_count` must be integer-like scalar expressions when supplied,
- negative or otherwise invalid `start_index` / `take_count` values clamp to `0`,
- `slice(projected_array_expr, ...)` works directly on composed array-valued helpers like `sorted_keys(...)`, `sorted_values(...)`, `take(...)`, `tail(...)`, `concat_arrays(...)`, and array-valued `coalesce(...)` chains,
- `slice(...)` always returns an array value rather than one scalar boundary element,
- and if the source array is empty, the start position is already beyond the end, or the requested count is non-positive, `slice(...)` returns one empty array instead of `undef`.

Examples in context:

```text
assign(array(middle_parts), slice(array(parts), 1))
assign(array(middle_parts), slice(array(parts), 1, 2))
assign(array(middle_keys), slice(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(slice_start), scalar(slice_count)))
assign(scalar(middle_count), count(slice(sorted_keys(hash(meta)), 1, 2)))
assign(scalar(first_middle_key), scalar(slice(sorted_keys(hash(meta)), 1, 1), 0))
return(hash("middle_keys", slice(sorted_keys(hash(meta)), 1, 2), "middle_count", count(slice(sorted_keys(hash(meta)), 1, 2))))
```

## `take_last(array_or_array_expr)` and `take_last(array_or_array_expr, take_last_count)`
Use `take_last(...)` when you want one array value containing the last element, or the last `N` elements when an explicit count is supplied.

Examples:

```text
take_last(array(parts))
take_last(array(parts), 2)
take_last(sorted_keys(hash(meta)))
take_last(sorted_keys(hash(meta)), scalar(take_last_count))
take_last(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")))
take_last(coalesce(scalaref(retv, {parts}), array("fallback")))
```

Typical uses:
- keep a canonical suffix array while earlier parsing logic has already consumed or summarized the leading part,
- preserve the final few stable projected keys or values as one explicit summary payload,
- express “take the last `N` tokens/items” without raw Perl slicing,
- and feed one bounded suffix array directly into reducers like `count(...)` or nested reads like `scalar(take_last(...), 0)`.

Important semantic note:
- `take_last(array_expr)` is shorthand for `take_last(array_expr, 1)`,
- `take_last(array(name))` returns one new array value containing the last live element when present,
- `take_last(array_expr, take_last_count)` keeps the last `take_last_count` entries when that count is one explicit integer-like scalar expression,
- `take_last(projected_array_expr)` works directly on composed array-valued helpers like `sorted_keys(...)`, `sorted_values(...)`, `take(...)`, `take_last(...)`, `drop_last(...)`, `tail(...)`, and array-valued `coalesce(...)` chains,
- `take_last(...)` always returns an array value rather than one scalar boundary element,
- and if the source array is empty, the requested count is non-positive, or the array-valued expression is still undefined, `take_last(...)` returns one empty array instead of `undef`.

Examples in context:

```text
assign(array(last_parts), take_last(array(parts)))
assign(array(last_parts), take_last(array(parts), 2))
assign(array(last_keys), take_last(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(array(last_keys), take_last(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(take_last_count)))
assign(scalar(last_count), count(take_last(sorted_keys(hash(meta)), 2)))
if(num_gt(count(take_last(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0)); ... endif()
return(hash("last_keys", take_last(sorted_keys(hash(meta))), "last_count", count(take_last(sorted_keys(hash(meta)), 2))))
```

## `drop_last(array_or_array_expr)` / `drop_back(array_or_array_expr)`
## `drop_last(array_or_array_expr, drop_count)` / `drop_back(array_or_array_expr, drop_count)`
Use `drop_last(...)` when you want one array value that contains everything except the last element, or except the last `N` elements when an explicit drop count is supplied. `drop_back(...)` is the exact alias for the same lowering contract.

Examples:

```text
drop_last(array(parts))
drop_last(array(parts), 2)
drop_back(array(parts))
drop_back(array(parts), 2)
drop_last(sorted_keys(hash(meta)))
drop_last(sorted_keys(hash(meta)), scalar(drop_count))
drop_last(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")))
drop_last(coalesce(scalaref(retv, {parts}), array("fallback")))
```

Typical uses:
- strip one trailing delimiter or terminator from one token array without raw Perl slicing,
- keep the stable leading part of one projected key/value list while discarding one trailing suffix,
- express “drop the last `N` items” without temporary arrays,
- and feed the resulting leading array directly into reducers like `count(...)` or nested reads like `scalar(drop_last(...), 0)`.

Important semantic note:
- `drop_last(array_expr)` is shorthand for `drop_last(array_expr, 1)`,
- `drop_back(array_expr)` is the exact alias of `drop_last(array_expr)`,
- `drop_last(array(name))` returns one new array value containing every live element before the last one,
- `drop_last(array_expr, drop_count)` drops the final `drop_count` entries when that count is one explicit integer-like scalar expression,
- `drop_back(array_expr, drop_count)` is the exact alias of `drop_last(array_expr, drop_count)`,
- `drop_last(projected_array_expr)` works directly on composed array-valued helpers like `sorted_keys(...)`, `sorted_values(...)`, `take(...)`, `tail(...)`, `drop_last(...)`, and array-valued `coalesce(...)` chains,
- `drop_last(...)` always returns an array value rather than one scalar boundary element,
- and if the source array is empty, too short for the requested drop count, or the array-valued expression is still undefined, `drop_last(...)` returns one empty array instead of `undef`.

Examples in context:

```text
assign(array(leading_parts), drop_last(array(parts)))
assign(array(leading_parts), drop_last(array(parts), 2))
assign(array(leading_parts), drop_back(array(parts), 2))
assign(array(leading_keys), drop_last(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(array(leading_keys), drop_last(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(drop_count)))
assign(scalar(kept_count), count(drop_last(sorted_keys(hash(meta)), 2)))
if(num_gt(count(drop_last(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0)); ... endif()
return(hash("leading_keys", drop_last(sorted_keys(hash(meta))), "kept_count", count(drop_last(sorted_keys(hash(meta)), 2))))
```

## `contains(array_or_array_expr, value_expr)`
Use `contains(...)` when you want one scalar flag answering “does this array currently contain this value?”

Examples:

```text
contains(array(parts), "foo")
contains(sorted_keys(hash(meta)), "kind")
contains(coalesce(scalaref(retv, {parts}), array("empty")), scalar(IMATCH))
```

Typical uses:
- branch on whether one token list already contains a marker,
- store one canonical membership flag in a scalar slot,
- return “has this projected field/value” metadata without dropping into raw host-language loops.

Important semantic note:
- `contains(...)` is about exact scalar membership in an array,
- it works on working arrays and array-valued helper expressions,
- it returns `1` or `0`,
- and when an array-valued expression is still undefined, `contains(...)` returns `0`.

Examples in context:

```text
assign(scalar(has_kind), contains(sorted_keys(hash(meta)), "kind"))
assign(scalar(has_node_value), contains(sorted_values(pick_keys(hash(meta), "kind", "source")), "NODE"))
if(contains(coalesce(scalaref(retv, {parts}), array("empty")), scalar(IMATCH))); ... endif()
return(hash("has_kind", contains(sorted_keys(hash(meta)), "kind")))
```

## `count_keys(hash_or_hash_expr)`
Use `count_keys(...)` when you want one scalar key-count result from a hash/object variable or hash-valued expression.

Examples:

```text
count_keys(hash(meta))
count_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")))
count_keys(hash("kind", "NODE", "source", "Top"))
```

Typical uses:
- branch on whether one returned metadata object is richer than a minimal fallback,
- store one canonical object-field count in a scalar slot,
- return hash/object size metadata without dropping into raw host-language code.

Important semantic note:
- `count_keys(hash(name))` lowers to the live hash-variable key count,
- `count_keys(hash-valued expression)` lowers by counting keys from the referenced hash payload,
- and when a hash-valued expression is still undefined, `count_keys(...)` returns `0`.

Examples in context:

```text
assign(scalar(meta_key_count), count_keys(hash(meta)))
assign(scalar(meta_key_count), count_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback"))))
if(num_gt(count_keys(hash(meta)), 1)); ... endif()
return(hash("meta_key_count", count_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")))))
```

## `sorted_keys(hash_or_hash_expr)`
Use `sorted_keys(...)` when you want one new array value containing the keys from a hash/object value in stable lexical order.

Examples:

```text
sorted_keys(hash(meta))
sorted_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")))
sorted_keys(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "source", "stage"))
```

Typical uses:
- derive one deterministic key list from a richer object before returning it,
- project one stable field-order summary for debugging or downstream normalization,
- bridge from hash/object helpers into array helpers like `count(...)`, `array_copy(...)`, and array pipelines.

Important semantic note:
- `sorted_keys(...)` returns one new array value,
- it does **not** mutate the source hash on its own,
- key order is lexical and stable,
- and undefined hash-valued expressions simply turn into one empty returned array.

That means:
- `sorted_keys(hash(meta))` gives one deterministic key list instead of relying on host hash iteration order,
- `sorted_keys(pick_keys(...))` works well after one projection step when only a few public fields matter,
- and `count(sorted_keys(...))` is a valid way to ask how many projected keys survived one normalization path.

Examples in context:

```text
assign(array(projected_keys), sorted_keys(hash(meta)))
assign(array(projected_keys), sorted_keys(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "source", "stage")))
assign(scalar(key_count), count(sorted_keys(hash(meta))))
return(hash("keys", sorted_keys(pick_keys(hash(meta), "kind", "source"))))
```

## `sorted_values(hash_or_hash_expr)`
Use `sorted_values(...)` when you want one new array value containing the values from a hash/object value in the stable lexical order of that object’s keys.

Examples:

```text
sorted_values(hash(meta))
sorted_values(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")))
sorted_values(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "source", "stage"))
```

Typical uses:
- derive one deterministic value-list summary from a projected object,
- feed stable object values into array reducers like `count(...)`,
- return one canonical ordered value list without depending on host hash iteration order.

Important semantic note:
- `sorted_values(...)` returns one new array value,
- it does **not** mutate the source hash on its own,
- ordering is derived from lexical sort of keys first and then mapped to values,
- and undefined hash-valued expressions simply turn into one empty returned array.

That means:
- `sorted_values(hash(meta))` gives one deterministic value list for the current object shape,
- `sorted_values(pick_keys(...))` works well after one projection step when only a few public fields matter,
- and `count(sorted_values(...))` is a valid way to ask how many projected values survived one normalization path.

Examples in context:

```text
assign(array(projected_values), sorted_values(hash(meta)))
assign(array(projected_values), sorted_values(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "source", "stage")))
assign(scalar(value_count), count(sorted_values(hash(meta))))
return(hash("values", sorted_values(pick_keys(hash(meta), "kind", "source"))))
```

## `sorted(array_expr)`
Use `sorted(...)` when you want one new array value containing the items from an array-valued expression in deterministic lexical order.

Examples:

```text
sorted(array(parts))
sorted(concat_arrays(array(parts), array("delta"), array("alpha")))
sorted(coalesce(scalaref(retv, {parts}), array("fallback")))
sorted(take(sorted_keys(hash(meta)), 3))
```

Typical uses:
- canonicalize one token list before counting or joining it,
- stabilize one composed array value before returning it,
- feed one deterministic lexical array into `first(...)`, `scalar(array_expr, idx)`, `count(...)`, or `join_values(...)`.

Important semantic note:
- `sorted(...)` returns one new array value,
- it does **not** mutate the source array on its own,
- ordering is lexical ascending order,
- and undefined array-valued expressions simply turn into one empty returned array.

That means:
- `sorted(array(parts))` gives one deterministic lexical ordering of the current working array,
- `sorted(concat_arrays(...))` works well after one array-layering step when the rule wants one canonical merged list,
- and `count(sorted(...))` is a valid way to ask how many items remain after one canonical sort step.

Examples in context:

```text
assign(array(ordered_parts), sorted(array(parts)))
assign(array(ordered_parts), sorted(concat_arrays(array(parts), take(sorted_keys(hash(meta)), 2), array("delta"))))
assign(scalar(first_item), scalar(sorted(array(parts)), 0))
assign(scalar(ordered_count), count(sorted(concat_arrays(array(parts), array("delta")))))
return(hash("ordered_parts", sorted(concat_arrays(array(parts), array("delta")))))
```

## `reversed(array_expr)`
Use `reversed(...)` when you want one new array value containing the items from an array-valued expression in the opposite order from the incoming array.

Examples:

```text
reversed(array(parts))
reversed(concat_arrays(array(parts), array("delta"), array("tail")))
reversed(coalesce(scalaref(retv, {parts}), array("fallback")))
reversed(take(sorted_keys(hash(meta)), 3))
```

Typical uses:
- keep one parser-visible “last item wins first” view without mutating the source array,
- inspect the newest or trailing entries first after one composed array build step,
- feed one reversed array into `scalar(array_expr, idx)`, `first(...)`, `count(...)`, or `join_values(...)`.

Important semantic note:
- `reversed(...)` returns one new array value,
- it does **not** mutate the source array on its own,
- it preserves the existing values and only flips the order,
- and undefined array-valued expressions simply turn into one empty returned array.

That means:
- `reversed(array(parts))` gives one pure opposite-order snapshot of the current working array,
- `reversed(concat_arrays(...))` works well after one array-layering step when later logic wants the newest or last-added items first,
- and `scalar(reversed(...), 0)` is a valid way to read the last source item through one pure array transformation.

Examples in context:

```text
assign(array(reversed_parts), reversed(array(parts)))
assign(array(reversed_parts), reversed(concat_arrays(array(parts), take(sorted_keys(hash(meta)), 2), array("tail"))))
assign(scalar(last_source_item), scalar(reversed(array(parts)), 0))
assign(scalar(reversed_count), count(reversed(concat_arrays(array(parts), array("tail")))))
return(hash("reversed_parts", reversed(concat_arrays(array(parts), array("tail")))))
```

## `has_key(hash_or_hash_expr, key_expr)`
Use `has_key(...)` when you want one boolean-like scalar result for “does this hash/object currently contain this key?”

Examples:

```text
has_key(hash(meta), "kind")
has_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "kind")
has_key(hash("kind", "NODE", "source", "Top"), "source")
```

Typical uses:
- branch on object shape rather than on one field’s definedness,
- store one canonical “has this key” flag in a scalar slot,
- return one presence flag inside a canonical payload without dropping into raw host-language `exists(...)`.

Important semantic note:
- `has_key(...)` is about key existence,
- not about whether the key’s value is defined,
- so it answers a different question from `is_defined(scalaref(...))`.

That distinction matters:
- `has_key(hash(meta), "kind")` asks whether the object has a `kind` field at all,
- while `is_defined(scalaref(retv, {kind}))` asks whether the retrieved `kind` value is defined.

Examples in context:

```text
assign(scalar(has_kind), has_key(hash(meta), "kind"))
assign(scalar(has_kind), has_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "kind"))
if(has_key(hash(meta), "kind")); ... endif()
return(hash("has_kind", has_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "kind")))
```

## `merge_hash(hash_or_hash_expr1, hash_or_hash_expr2, ..., hash_or_hash_exprN)`
Use `merge_hash(...)` when you want one new layered hash/object value built from working hashes, constructor hashes, and other hash-valued expressions.

Examples:

```text
merge_hash(hash(meta), hash("stage", "normalized"))
merge_hash(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), hash("source", scalar(rule_name)))
merge_hash(hash(base_meta), hash(overrides), hash("kind", "NODE"))
```

Typical uses:
- layer parser-owned metadata over one base object without mutating the inputs,
- add canonical fields like `"stage"` or `"kind"` after one fallback chain has chosen the base object,
- return one merged object directly from `return(...)` instead of allocating several temporary hashes first.

Important semantic note:
- `merge_hash(...)` returns one new hash/object value,
- it does **not** mutate any source hash on its own,
- later arguments override earlier keys when the same key appears more than once,
- and undefined hash-valued expressions contribute nothing rather than throwing one error.

That means:
- `merge_hash(hash(meta), hash("kind", "NODE"))` keeps all existing `meta` keys but forces `kind` to `NODE`,
- `merge_hash(hash(base_meta), hash(overrides))` lets `overrides` win for overlapping keys,
- and `merge_hash(coalesce(...), hash("stage", "normalized"))` works well when one base object may be missing entirely.

Examples in context:

```text
assign(hash(merged_meta), merge_hash(hash(base_meta), coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), hash("stage", "normalized")))
if(has_key(merge_hash(hash(meta), hash("stage", "normalized")), "kind")); ... endif()
return(merge_hash(hash(merged_meta), hash("meta_key_count", count_keys(hash(merged_meta)))))
```

## `set_key(hash_or_hash_expr, key_expr, value_expr)`
Use `set_key(...)` when you want one new hash/object value that is just like the incoming one except for one explicitly assigned key.

Examples:

```text
set_key(hash(meta), "stage", "normalized")
set_key(merge_hash(hash(meta), hash("kind", "NODE")), "stage", uppercase(trim(coalesce(scalar(IMATCH), "normalized"))))
set_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "source", scalar(rule_name))
```

Typical uses:
- add or overwrite one canonical field without wrapping that small update in one one-key `merge_hash(...)`,
- normalize one field after a fallback object has already been chosen,
- and feed one updated object straight into `has_key(...)`, `count_keys(...)`, or `scalar(hash_expr, key)` without staging a temporary working hash first.

Important semantic note:
- `set_key(...)` returns one new hash/object value,
- it does **not** mutate the source hash on its own,
- the named key is always written on the returned object,
- undefined incoming hash-valued expressions behave like one empty base object,
- and if the assigned value resolves to `undef`, the key still exists on the returned object with an undefined value.

That means:
- `set_key(hash(meta), "stage", "normalized")` preserves the rest of `meta` while forcing `stage`,
- `set_key(coalesce(...), "source", scalar(rule_name))` works even when the chosen base object was missing,
- and `has_key(set_key(hash(meta), "stage", "normalized"), "stage")` is always a valid way to branch on the updated shape directly.

Examples in context:

```text
assign(hash(normalized_meta), set_key(hash(meta), "stage", "normalized"))
assign(hash(normalized_meta), set_key(merge_hash(hash(meta), hash("kind", "NODE")), "owner", scalar(rule_name)))
assign(scalar(chosen_stage), scalar(set_key(hash(meta), "stage", "normalized"), "stage"))
if(has_key(set_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "stage", "normalized"), "stage")); ... endif()
return(set_key(merge_hash(hash(meta), hash("kind", "NODE")), "stage", uppercase(trim(coalesce(scalar(IMATCH), "normalized")))))
```

## `rename_key(hash_or_hash_expr, old_key_expr, new_key_expr)`
Use `rename_key(...)` when you want one new hash/object value where one existing key is moved to a new name.

Examples:

```text
rename_key(hash(meta), "old_stage", "stage")
rename_key(set_key(hash(meta), "owner", scalar(rule_name)), "old_stage", "stage")
rename_key(merge_hash(hash(meta), hash("old_stage", "normalized")), "old_stage", "stage")
```

Typical uses:
- normalize one incoming field name to one canonical exported field name,
- move one value to a new public name without writing a manual delete-plus-set sequence,
- and feed one renamed object straight into `has_key(...)`, `count_keys(...)`, `sorted_keys(...)`, or `scalar(hash_expr, key)` without staging a temporary working hash first.

Important semantic note:
- `rename_key(...)` returns one new hash/object value,
- it does **not** mutate the source hash on its own,
- undefined incoming hash-valued expressions behave like one empty returned object,
- the rename happens only when the old key exists,
- and when the old key exists its value is moved to the new key while the old key is removed.

That means:
- `rename_key(hash(meta), "old_stage", "stage")` preserves the rest of `meta` while moving `old_stage` to `stage`,
- `rename_key(set_key(...), "old_stage", "stage")` works naturally after one small shape update,
- and `has_key(rename_key(hash(meta), "old_stage", "stage"), "stage")` is a valid way to branch on the renamed shape directly.

Examples in context:

```text
assign(hash(normalized_meta), rename_key(hash(meta), "old_stage", "stage"))
assign(hash(normalized_meta), rename_key(set_key(hash(meta), "owner", scalar(rule_name)), "old_stage", "stage"))
assign(scalar(stage), scalar(rename_key(hash(meta), "old_stage", "stage"), "stage"))
if(has_key(rename_key(merge_hash(hash(meta), hash("old_stage", "normalized")), "old_stage", "stage"), "stage")); ... endif()
return(rename_key(set_key(hash(meta), "owner", scalar(rule_name)), "old_stage", "stage"))
```

## `drop_keys(hash_or_hash_expr, key_expr1, key_expr2, ..., key_exprN)`
Use `drop_keys(...)` when you want one new hash/object value with selected keys removed from an existing working hash or hash-valued expression.

Examples:

```text
drop_keys(hash(meta), "debug")
drop_keys(merge_hash(hash(meta), hash("stage", "normalized")), "debug", "span")
drop_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "raw_text")
```

Typical uses:
- strip debug-only or span-only fields before returning one canonical object,
- build one branch-local normalized view without mutating the original working hash,
- combine omission with `merge_hash(...)`, `count_keys(...)`, and `has_key(...)` in one composed expression tree.

Important semantic note:
- `drop_keys(...)` returns one new hash/object value,
- it does **not** mutate the source hash on its own,
- each named key is removed from the returned value if present,
- and undefined hash-valued expressions simply turn into one empty returned object.

That means:
- `drop_keys(hash(meta), "debug")` preserves all of `meta` except `debug`,
- `drop_keys(merge_hash(...), "span", "raw_text")` works well after one normalization merge,
- and `has_key(drop_keys(hash(meta), "debug"), "kind")` lets a flow condition branch on the cleaned object shape directly.

Examples in context:

```text
assign(hash(cleaned_meta), drop_keys(hash(meta), "debug", "span"))
assign(hash(cleaned_meta), drop_keys(merge_hash(hash(meta), hash("stage", "normalized")), "debug"))
if(has_key(drop_keys(hash(meta), "debug"), "kind")); ... endif()
return(drop_keys(merge_hash(hash(meta), hash("stage", "normalized")), "debug"))
```

## `pick_keys(hash_or_hash_expr, key_expr1, key_expr2, ..., key_exprN)`
Use `pick_keys(...)` when you want one new hash/object value that keeps only the selected keys from an existing working hash or hash-valued expression.

Examples:

```text
pick_keys(hash(meta), "kind", "source")
pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "stage")
pick_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "kind")
```

Typical uses:
- project one larger working object down to one stable external payload shape,
- keep only parser-owned keys before branching or returning,
- combine positive field selection with `merge_hash(...)`, `count_keys(...)`, and `has_key(...)` in one composed expression tree.

Important semantic note:
- `pick_keys(...)` returns one new hash/object value,
- it does **not** mutate the source hash on its own,
- keys are copied into the returned value only if they exist in the source object,
- and undefined hash-valued expressions simply turn into one empty returned object.

That means:
- `pick_keys(hash(meta), "kind", "source")` keeps only those two fields when present,
- `pick_keys(merge_hash(...), "kind", "stage")` works well after one normalization merge,
- and `has_key(pick_keys(hash(meta), "kind"), "kind")` lets a flow condition branch on the projected object shape directly.

Examples in context:

```text
assign(hash(projected_meta), pick_keys(hash(meta), "kind", "source"))
assign(hash(projected_meta), pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "source", "stage"))
if(has_key(pick_keys(hash(meta), "kind"), "kind")); ... endif()
return(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "stage"))
```

## `coalesce(value1, value2, ..., valueN)`
Use `coalesce(...)` when you want the first **defined** value from a fallback chain.

Examples:

```text
coalesce(scalaref(retv, {content}), scalar(IMATCH), "UNKNOWN")
coalesce(scalaref(retv, {parts}), array("empty"))
coalesce(scalar(explicit_name), scalar(fallback_name), "unnamed")
```

Important semantic note:
- `coalesce(...)` is about the first **defined** value,
- not the first truthy value,
- and not the first nonempty string.

So these values still count as already chosen if they are defined:
- `0`
- `""`
- `[]`
- `{}`

That makes `coalesce(...)` a good parser-oriented defaulting helper for explicit values without quietly discarding valid empty-or-zero payloads.

Typical uses:
- prefer a returned field, but fall back to the current match,
- prefer a child payload array, but fall back to a constructed default array,
- keep one canonical "chosen name" or "chosen content" variable without nested marker flow.

Examples in context:

```text
assign(scalar(name), coalesce(scalaref(retv, {content}), scalar(IMATCH), "UNKNOWN"))
return(hash("parts", coalesce(scalaref(retv, {parts}), array("empty"))))
if(eq(coalesce(scalaref(retv, {type}), "WORD"), "WORD")); ... endif()
```

## `coalesce_nonempty(value1, value2, ..., valueN)`
Use `coalesce_nonempty(...)` when you want the first **defined nonempty scalar** value from a fallback chain.

Examples:

```text
coalesce_nonempty(trim(scalaref(retv, {content})), scalar(IMATCH), "UNKNOWN")
coalesce_nonempty(trim(scalar(explicit_name)), trim(scalar(fallback_name)), "unnamed")
coalesce_nonempty(trim(scalaref(retv, {type})), scalar(kind), "WORD")
```

Important semantic note:
- `coalesce_nonempty(...)` skips `undef`,
- it also skips `""`,
- but it does **not** skip `0`,
- and if you want whitespace-only strings treated as empty, say that explicitly with `trim(...)` around the candidate values.

That makes `coalesce_nonempty(...)` the parser-oriented fallback helper for “first real text wins” rather than “first defined value wins”.

Typical uses:
- prefer a returned text field, but ignore it when it is blank after normalization,
- prefer one explicit name variable, then one fallback variable, then one literal default,
- keep “blank means keep searching” logic inside one composable value expression instead of opening a small marker `if`.

Examples in context:

```text
assign(scalar(name), coalesce_nonempty(trim(scalaref(retv, {content})), scalar(IMATCH), "UNKNOWN"))
return(hash("chosen_type", coalesce_nonempty(trim(scalaref(retv, {type})), scalar(kind), "WORD")))
if(eq(coalesce_nonempty(trim(scalaref(retv, {type})), scalar(kind), "WORD"), "WORD")); ... endif()
```

## `call(rule)` as a value source
This is one of the most important newer canonical patterns.

### Standalone call

```text
call(child)
```

Meaning: dispatch to another rule for its side effects/result, without directly storing the result here.

### Canonical value-capture form

```text
assign(scalar(retv), call(child))
```

This is the preferred backend-neutral replacement for older raw wrappers like:

```text
$retv = call(child)
my $retv = call(child)
```

Practical example:

```text
-> parenthesis {
  assign(scalar(retv), call(parenthesis));
  if(is_empty(scalar(has_head)));
    assign(scalar(head), scalar(retv));
  else();
    push_value(array(tail), scalar(retv));
  endif()
}
```

Use this when:
- you need to inspect the child result,
- you may assign it to a head/tail slot,
- you want canonical helper flow rather than raw assignment wrappers.

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on supported `assign(scalar(retv), call(rule))` capture forms too,
- on both action-edge and lifecycle surfaces,
- and that same supported canonical call-value equivalence is now regression-locked inside control-flow branch bodies too,
- so canonical child-result capture is part of the same equivalence contract as the rest of the method-like DSL surface.

## `push_value(array(target), value)`
`push_value(...)` lowers a value expression and appends it into an array variable.

Examples:

```text
push_value(array(items), scalar(retv))
push_value(array(items), array(scalar(tag), scalar(name)))
push_value(array(word), scalaref(retv, {content}))
push_value(array(tail), join_values("", array(word)))
```

Use it when you already have a value expression and simply want to append it.

If you want “call this rule and push its return into an array,” there are two styles:
- legacy: `push(rule)` or `push(rule, target)`
- canonical explicit style: `assign(scalar(retv), call(rule)); push_value(array(target), scalar(retv))`

The second style is usually easier to reason about in larger rules.

## `return(payload)`
`return(payload)` is the preferred general structured-return form.

Examples:

```text
return(array("?node:", scalar(name), scalar(kind)))
return(hash("type", "OTHERS", "content", scalar(IMATCH)))
return(array_copy(array(items)))
return(array(scalar(head), array_copy(array(tail))))
```

You can nest constructor helpers freely.

Examples:

```text
return(hash(
  "name", scalar(block_name),
  "content", array_copy(array(assigns)),
  "meta", hash("kind", "block")
))
```

## Raw payloads inside `return(payload)`
`return(payload)` is flexible enough to accept helper-rich payloads **and** some raw expressions/literals.

Examples:

```text
return("ok")
return(0)
return(["semantic", { key => scalar(name) }, [123, scalar(items, 0)]])
return($value)
```

But for backend-neutral authoring, prefer helper-based constructors when possible.

## Worked examples
### Example: structured token rule

```text
dquotes: /"(.*?)(?<!\\)"/ I.return(hash("type", "DQUOTES", "content", scalar(IMATCH_LIST, 0)))
```

This is concise, structured, and backend-friendly.

### Example: recursive list closeout

```text
-> parenthesis[1] {
  if(scalar(has_head));
    if(is_nonempty(array(tail)));
      return(array(scalar(head), array_copy(array(tail))));
    else();
      return(array(scalar(head), undef));
    endif();
  else();
    return(array(undef));
  endif()
}
```

This shows multiple important surfaces in one place:
- scalar state variables,
- array snapshots,
- generalized structured returns,
- helper-only control flow.

## Related guides
- Cross-cutting scalar/aggregate cookbook: [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md)
- Declarations: [`USER_GUIDE_ActionIR_DeclareMethod.md`](USER_GUIDE_ActionIR_DeclareMethod.md)
- Assignment and sources: [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
- Legacy/compatibility helpers: [`USER_GUIDE_ActionIR_Contracts.md`](USER_GUIDE_ActionIR_Contracts.md)
