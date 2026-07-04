# USER GUIDE - ActionIR `FlowExpr.pm`
This guide covers the expression-lowering surface implemented by `perl/LinkedSpec/ActionIR/FlowExpr.pm`.

This is the guide to read when you need conditions, boolean composition, comparisons, definedness checks, emptiness checks, and expression nesting.
For exact DSL-to-Perl examples for every boolean/comparison helper discussed here, also read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).
For a cross-cutting tutorial that focuses specifically on string/integer/float scalars plus array/hash composition with many worked `.spec` examples, also read [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md).

## What this module is responsible for
`FlowExpr.pm` is the shared expression language used by helper control-flow and some value contexts.

In practice, it covers:
- `or(...)`
- `and(...)`
- `not(...)`
- `is_defined(...)`
- `is_undefined(...)`
- `is_empty(...)`
- `is_nonempty(...)`
- string comparisons: `eq`, `ne`, `gt`, `ge`, `lt`, `le`
- scalar substring/pattern predicates: `starts_with(...)`, `ends_with(...)`, `contains_substr(...)`, `matches(...)`
- numeric comparisons: `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, `num_le`
- nested composition of those helpers

## Why this expression family matters
A large part of backend-neutral authoring is replacing raw Perl branch conditions such as:

```text
if ($flag && $name ne "")
```

with explicit DSL expressions such as:

```text
if(and(:flag, is_nonempty(:name)))
```

That is easier to analyze, easier to lower, and easier to port.

## Boolean composition
### `or(...)`

```text
or(:on, :off)
or(eq(:kind, "A"), eq(:kind, "B"))
```

Use it when any one of the conditions should pass.

### `and(...)`

```text
and(:enabled, is_nonempty(:name))
and(not(is_empty(array(items))), matches(:token, /^[A-Z_]+$/))
and(contains_substr(lowercase(trim(:name)), "node"), ends_with(lowercase(trim(:name)), "_end"))
```

Use it when all conditions must pass.

### `not(...)`

```text
not(is_empty(:name))
not(eq(:kind, "ignore"))
```

Use it to invert one condition.

## Definedness helpers
### `is_defined(...)`
Use this when the rule needs to distinguish "missing/undefined" from "defined but empty".

Examples:

```text
is_defined(:name)
is_defined(retv["content"])
is_defined(coalesce(retv["type"], :IMATCH))
```

Typical meanings:
- scalar slot currently has a defined value,
- child payload field is present,
- fallback chain has produced a defined result.

Important distinction:
- `is_defined(...)` is about presence,
- not about nonempty text or nonempty arrays.

So these still count as defined:
- `0`
- `""`
- `[]`
- `{}`

### `is_undefined(...)`
This is the direct inverse convenience helper.

Examples:

```text
is_undefined(retv["type"])
is_undefined(coalesce(retv["content"], :IMATCH))
```

Use it when the rule should take a missing-value branch only if no defined value is available yet.

## Emptiness helpers
### `is_empty(...)`
Use it for scalars, arrays, hashes/objects, or composed aggregate expressions.

Examples:

```text
is_empty(:name)
is_empty(array(items))
is_empty(join_values("", array(word)))
is_empty(sorted_values(pick_keys(hash(meta), "kind", "source")))
is_empty(drop_keys(hash(meta), "kind", "source", "debug"))
```

Typical meanings:
- scalar is undefined or empty string,
- array has no elements,
- projected array expression has no elements,
- projected hash/object expression has no keys,
- and only the remaining non-aggregate fallback expressions use plain truthiness.

This is intentionally different from `is_defined(...)`:
- `is_empty(:name)` treats both `undef` and `""` as empty,
- `is_defined(:name)` treats `""` as already present,
- and `is_empty(pick_keys(hash(meta), "kind"))` can still be true even though that projected hash ref is defined.

This same helper family now also has value-layer support, so the identical `is_empty(...)` spelling can be used in assignment values and `return(payload)`, not only directly in `if(...)` / `elseif(...)` / `switch(...)` conditions.

### `is_nonempty(...)`
This is the inverse convenience helper.

Examples:

```text
is_nonempty(array(word))
is_nonempty(array(tail))
is_nonempty(:content)
is_nonempty(join_values("", array(word)))
is_nonempty(sorted_values(pick_keys(hash(meta), "kind", "source")))
is_nonempty(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "stage"))
```

This same helper family now also has value-layer support, so the identical `is_nonempty(...)` spelling can be used in assignment values and `return(payload)`, not only directly in branch conditions.

## String comparisons
Supported helpers:
- `eq(lhs, rhs)`
- `ne(lhs, rhs)`
- `gt(lhs, rhs)`
- `ge(lhs, rhs)`
- `lt(lhs, rhs)`
- `le(lhs, rhs)`

Examples:

```text
eq(:kind, "SPACE")
ne(:block_namee, :block_namei)
gt(:name, "M")
```

Use these when you mean Perl-style string comparison semantics.

## Scalar substring/pattern predicates
Supported helpers:
- `starts_with(lhs, prefix)`
- `ends_with(lhs, suffix)`
- `contains_substr(lhs, needle)`
- `matches(lhs, /regex/)`

Examples:

```text
starts_with(lowercase(trim(:name)), "node_")
ends_with(lowercase(trim(:name)), "_end")
contains_substr(lowercase(trim(:name)), "node")
contains_substr(uppercase(trim(coalesce(retv["kind"], :IMATCH))), "NODE")
matches(:token, /^[A-Z_]+$/)
```

Use these when a branch depends on string shape or string membership rather than exact equality.

This same scalar-predicate family now also exists in value lowering, so the identical helper spellings can be used in assignment values and `return(payload)`, not only directly in `if(...)` / `elseif(...)` / `switch(...)` conditions.

Closely related value helpers such as `replace_substr(...)`, `rm_prefix(...)`, and `rm_suffix(...)` are not themselves predicates, but they are meant to feed comparisons and predicates directly:

```text
eq(replace_substr(lowercase(trim(:name)), "-", "_"), "node_item")
starts_with(replace_substr(lowercase(trim(:name)), " ", "_"), "node_")
contains_substr(replace_substr(lowercase(trim(:name)), "-", "_"), "item")
eq(rm_prefix(replace_substr(lowercase(trim(:name)), " ", "_"), "node_"), "item_end")
eq(rm_suffix(replace_substr(lowercase(trim(:name)), " ", "_"), "_end"), "node_item")
```

That keeps literal string rewrites and boundary cleanup in the same expression layer as the later branch decision.

## Numeric comparisons
Supported helpers:
- `num_eq(lhs, rhs)`
- `num_ne(lhs, rhs)`
- `num_gt(lhs, rhs)`
- `num_ge(lhs, rhs)`
- `num_lt(lhs, rhs)`
- `num_le(lhs, rhs)`

Examples:

```text
num_eq(:count, 0)
num_gt(:index, 3)
num_le(:depth, 8)
num_ge(num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4)), 5)
num_gt(num_sum(take(concat_arrays(array(scores), array(extra_scores)), 4)), 10)
num_eq(num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)), 6)
num_eq(index_of(sorted_keys(hash(meta)), "kind"), 0)
num_gt(num_add(count(array(parts)), :offset), 3)
num_eq(num_sub(num_add(count(array(parts)), :offset), 1), 4)
num_gt(num_mul(count(array(parts)), :factor), 3)

That same numeric comparison family also accepts the newer arithmetic reducer/value helpers directly. In practice that means array-to-scalar reducers such as `num_sum(...)`, `num_avg(...)`, and `num_median(...)`, plus scalar-normalization helpers such as `num_round(...)`, can feed `num_gt(...)`, `num_eq(...)`, and the other `num_*` comparisons without staging one temporary scalar first.
num_eq(num_div(num_mul(count(array(parts)), :factor), 2), 3)
num_eq(num_mod(num_add(count(array(parts)), :offset), 3), 1)
num_eq(num_clamp(num_add(count(array(parts)), :offset), :lower_limit, :upper_limit), 5)
num_gt(num_abs(num_sub(coalesce(length(trim(:name)), 0), :offset)), 3)
num_ge(num_floor(num_sub(:depth, :offset)), 1)
num_ge(num_ceil(num_div(num_mul(count(array(parts)), :factor), 2)), 2)
num_eq(num_round(num_add(coalesce(length(trim(:name)), 0), 0.5)), 6)
num_ge(num_median(take(concat_arrays(array(scores), array(extra_scores)), 4)), 5)
num_eq(num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)), 6)
num_ge(num_min(take(concat_arrays(array(scores), array(extra_scores)), 4)), 2)
num_eq(num_min(num_add(count(array(parts)), :offset), :limit, 10), 4)
num_ge(num_max(take(concat_arrays(array(scores), array(extra_scores)), 4)), 8)
num_ge(num_max(num_add(count(array(parts)), :offset), 2, :limit), 6)
eq(concat(lowercase(trim(:name)), "_", :stage), "node_init")
eq(rm_prefix(replace_substr(lowercase(trim(:name)), " ", "_"), "node_"), "item_end")
eq(rm_suffix(replace_substr(lowercase(trim(:name)), " ", "_"), "_end"), "node_item")
starts_with(lowercase(trim(:name)), "node_")
ends_with(lowercase(trim(:name)), "_end")
contains_substr(lowercase(trim(:name)), "node")
num_gt(count(take_last(sorted_keys(hash(meta)), 2)), 0)
num_gt(count(drop_back(sorted_keys(hash(meta)), 2)), 0)
num_gt(count(take(sorted_keys(hash(meta)), 2)), 0)
num_gt(count(slice(sorted_keys(hash(meta)), 1, 2)), 0)
num_gt(count(drop_front(sorted_keys(hash(meta)))), 0)
num_gt(count(drop_front(sorted_keys(hash(meta)), 2)), 0)
num_gt(count(concat_arrays(array(parts), take(sorted_keys(hash(meta)), 2), array("tail"))), 3)
num_gt(count(sorted(concat_arrays(array(parts), array("delta"), array("alpha")))), 2)
num_gt(count(reversed(concat_arrays(array(parts), array("delta"), array("tail")))), 2)
```

Use these when the values are numeric and you want numeric ordering/comparison, not string ordering.

Arithmetic helpers such as `num_abs(...)`, `num_floor(...)`, `num_ceil(...)`, `num_round(...)`, `num_sum(...)`, `num_avg(...)`, `num_median(...)`, `num_range(...)`, `num_add(...)`, `num_sub(...)`, `num_mul(...)`, `num_div(...)`, `num_mod(...)`, `num_clamp(...)`, `num_min(...)`, and `num_max(...)` can feed these comparisons directly, so numeric reducer chains can stay inside one expression layer instead of being expanded into temporary scalar staging. `num_min(...)` and `num_max(...)` now cover both variadic scalar floor/ceiling-style composition and unary array-reducer mode, `num_range(...)` is the “max minus min span of this array” member of the reducer family, `num_mod(...)` is the intentionally integer-oriented member of that family, and `num_clamp(...)` is the “bounded result” member for rules that want one explicit numeric ceiling/floor without spelling nested `num_min(num_max(...))`.

Pure scalar helpers such as `concat(...)`, `replace_substr(...)`, `rm_prefix(...)`, `rm_suffix(...)`, `trim(...)`, `lowercase(...)`, `uppercase(...)`, and `coalesce_nonempty(...)` can feed `eq(...)`, `ne(...)`, prefix/suffix checks, and regex predicates the same way, so canonical string assembly, boundary cleanup, and normalization can stay inside one expression layer too.

Array-valued helpers such as `concat_arrays(...)`, `sorted(...)`, and `reversed(...)` can feed reducers like `count(...)` the same way, so layered aggregate construction, deterministic ordering, and last-added-first views can stay inside one expression layer before the final numeric comparison.

## Nested examples
This expression language is designed for nesting.

### Example: field must exist, even if it is empty

```text
is_defined(retv["content"])
```

### Example: child type is still missing after fallback

```text
is_undefined(coalesce(retv["type"], :IMATCH))
```

### Example: nonempty and not disabled

```text
and(is_nonempty(array(items)), not(:disabled))
```

### Example: either explicit enable or a nonempty fallback name

```text
or(:enabled, is_nonempty(:name))
```

### Example: normalized name starts with a known parser prefix

```text
starts_with(lowercase(trim(:name)), "node_")
```

### Example: normalized name ends with a known parser suffix

```text
ends_with(lowercase(trim(:name)), "_end")
```

### Example: normalized name contains one known parser substring

```text
contains_substr(lowercase(trim(:name)), "node")
```

### Example: projected object still has keys after skipping the first stable key

```text
num_gt(count(drop_front(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")))), 0)
```

### Example: projected object still has keys after skipping the first two stable keys

```text
num_gt(count(drop_front(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0)
```

### Example: projected object still has at least two stable keys in its prefix view

```text
num_gt(count(take(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 1)
```

### Example: projected object still has any stable keys in one middle slice view

```text
num_gt(count(slice(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), 1, 2)), 0)
```

### Example: projected object still has any stable keys in its suffix view

```text
num_gt(count(take_last(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0)
```

### Example: projected object still has any leading keys after dropping the last two stable keys

```text
num_gt(count(drop_back(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0)
```

### Practical guidance
- reducers like `count(...)` can wrap composed array helpers such as `drop_back(sorted_keys(...), 2)` directly,
- reducers like `count(...)` can wrap composed array helpers such as `take_last(sorted_keys(...), 2)` directly,
- reducers like `count(...)` can wrap composed array helpers such as `take(sorted_keys(...), 2)` directly,
- reducers like `count(...)` can wrap composed array helpers such as `slice(sorted_keys(...), 1, 2)` directly,
- reducers like `count(...)` can wrap composed array helpers such as `drop_front(sorted_keys(...))` directly,
- scalar predicate helpers like `starts_with(...)`, `ends_with(...)`, `contains_substr(...)`, and `matches(...)` can wrap normalized values such as `lowercase(trim(:name))` directly,
- the same pattern works when you want one trimmed leading array via `count(drop_back(sorted_keys(...), :drop_count))`,
- the same pattern works when you want one bounded suffix via `count(take_last(sorted_keys(...), :take_last_count))`,
- the same pattern works when you want one bounded prefix via `count(take(sorted_keys(...), :take_count))`,
- the same pattern works when you want one bounded middle window via `count(slice(sorted_keys(...), :slice_start, :slice_count))`,
- the same pattern works with explicit counts like `count(drop_front(sorted_keys(...), :skip_count))`,
- so flow conditions can stay inside one parser-oriented expression instead of splitting into temporary variables first,
- and the same no-fixed-depth composition rule applies here just as it does in `return(...)`, assignment RHS, `if(...)`, and `switch(...)` arguments.

### Example: check an entry inside a working array

```text
eq(array(capt).first(), "?branch:")
```

### Example: compound rule guard

```text
and(
  is_nonempty(array(capt)),
  matches(:token, /^[A-Z_]+$/),
  not(eq(:mode, "skip"))
)
```

## Where these expressions are used
These helpers are most often used in:
- `if(...)`
- `elseif(...)`
- `switch(...)`
- declaration initializers,
- assignment sources.

Examples:

```text
declare(scalar, flag=or(:on, :off))
flag = and(is_nonempty(array(items)), :enabled)
has_type = is_defined(retv["type"])
if(not(is_empty(:name))); ... endif()
```

## Scalar and Nested-Access Expressions Inside Conditions
You can combine `...` and direct nested access with the flow-expression helpers.

Examples:

```text
eq(retv["type"], "SPACE")
ne(retv["type"], "COMMENTS")
is_defined(retv["content"])
is_undefined(retv["type"])
is_nonempty(retv["content"])
has_key(hash(meta), "kind")
has_key(coalesce(retv["meta"], hash("kind", "fallback")), "kind")
has_key(merge_hash(hash(meta), hash("stage", "normalized")), "kind")
has_key(set_key(hash(meta), "stage", "normalized"), "stage")
has_key(rename_key(hash(meta), "old_stage", "stage"), "stage")
has_key(drop_keys(hash(meta), "debug"), "kind")
has_key(pick_keys(hash(meta), "kind", "source"), "kind")
contains(sorted_keys(hash(meta)), "kind")
contains(sorted_values(pick_keys(hash(meta), "kind", "source")), "NODE")
num_eq(index_of(sorted_keys(hash(meta)), "kind"), 0)
num_gt(count(sorted_keys(pick_keys(hash(meta), "kind", "source"))), 1)
num_gt(coalesce(length(trim(retv["content"])), 0), 3)
eq(first(sorted_keys(pick_keys(hash(meta), "kind", "source"))), "kind")
eq(sorted_keys(pick_keys(hash(meta), "kind", "source"))[0], "kind")
eq(merge_hash(hash(meta), hash("kind", "NODE"))["kind"], "NODE")
eq(last(sorted_values(pick_keys(hash(meta), "kind", "source"))), "rule")
eq(join_values(", ", sorted_keys(pick_keys(hash(meta), "kind", "source"))), "kind, source")
is_empty(sorted_values(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "source")))
is_nonempty(pick_keys(drop_keys(hash(meta), "debug"), "kind", "source"))
num_gt(count(array(parts)), 0)
num_gt(count_keys(hash(meta)), 1)
eq(lowercase(trim(retv["type"])), "word")
eq(coalesce(retv["type"], "UNKNOWN"), "WORD")
eq(coalesce_nonempty(trim(retv["type"]), :kind, "WORD"), "WORD")
```

This is very useful when a child rule returns a structured hash payload and the current rule wants to branch on one field.
It is also useful when the rule wants one parser-oriented defaulting or normalization step before the comparison.

## Worked examples
### Example: flush a pending word only if it exists

```text
if(is_nonempty(array(word)));
  push_value(array(tail), join_values("", array(word)));
endif()
```

### Example: detect mismatched begin/end names

```text
if(ne(:block_namee, :block_namei));
  print("error\n");
  exit;
endif()
```

The branch body there may still be legacy/raw, but the condition itself is canonical.

### Example: classify token kinds

```text
if(eq(retv["type"], "SPACE"));
  ...
elseif(ne(retv["type"], "COMMENTS"));
  ...
endif()
```

### Example: separate "missing" from "empty"

```text
if(is_undefined(retv["content"]));
  return(hash("kind", "MISSING_CONTENT"));
elseif(is_empty(retv["content"]));
  return(hash("kind", "EMPTY_CONTENT"));
else;
  return(hash("kind", "HAS_CONTENT", "content", retv["content"]));
endif()
```

### Example: fallback branch only when no defined value survives

```text
if(is_defined(coalesce(retv["type"], :IMATCH)));
  return(hash("kind", "CLASSIFIED", "type", coalesce(retv["type"], :IMATCH)));
else;
  return(hash("kind", "UNCLASSIFIED"));
endif()
```

### Example: fallback branch only when no nonempty scalar survives

```text
if(eq(coalesce_nonempty(trim(retv["type"]), :kind, "WORD"), "WORD"));
  return(hash("kind", "WORDISH"));
else;
  return(hash("kind", "OTHER"));
endif()
```

### Example: normalize before comparing

```text
if(eq(lowercase(trim(coalesce(retv["type"], " WORD "))), "word"));
  return(hash("kind", "WORD"));
else;
  return(hash("kind", "OTHER"));
endif()
```

### Example: branch on array size

```text
if(num_gt(count(coalesce(retv["parts"], array("empty"))), 1));
  return(hash("kind", "MULTI_PART"));
else;
  return(hash("kind", "SINGLE_PART"));
endif()
```

### Example: branch on hash/object richness

```text
if(num_gt(count_keys(coalesce(retv["meta"], hash("kind", "fallback"))), 1));
  return(hash("kind", "RICH_META"));
else;
  return(hash("kind", "MIN_META"));
endif()
```

### Example: branch on key existence rather than value definedness

```text
if(has_key(coalesce(retv["meta"], hash("kind", "fallback")), "kind"));
  return(hash("kind", "HAS_KIND_KEY"));
else;
  return(hash("kind", "NO_KIND_KEY"));
endif()
```

### Example: branch on one normalized merged object shape

```text
if(has_key(merge_hash(coalesce(retv["meta"], hash("kind", "fallback")), hash("stage", "normalized")), "kind"));
  return(hash("kind", "HAS_NORMALIZED_KIND"));
else;
  return(hash("kind", "NO_NORMALIZED_KIND"));
endif()
```

### Example: branch on one renamed object shape

```text
if(has_key(rename_key(merge_hash(hash(meta), hash("old_stage", "normalized")), "old_stage", "stage"), "stage"));
  return(hash("kind", "HAS_STAGE_KEY"));
else;
  return(hash("kind", "NO_STAGE_KEY"));
endif()
```

### Example: branch on one cleaned object shape

```text
if(has_key(drop_keys(merge_hash(hash(meta), hash("stage", "normalized"), hash("debug", 1)), "debug"), "kind"));
  return(hash("kind", "HAS_CLEAN_KIND"));
else;
  return(hash("kind", "NO_CLEAN_KIND"));
endif()
```

### Example: branch on one projected object shape

```text
if(has_key(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "stage"), "kind"));
  return(hash("kind", "HAS_PROJECTED_KIND"));
else;
  return(hash("kind", "NO_PROJECTED_KIND"));
endif()
```

### Example: branch on one stable projected key list

```text
if(num_gt(count(sorted_keys(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "source", "stage"))), 1));
  return(hash("kind", "RICH_PROJECTED_META"));
else;
  return(hash("kind", "MIN_PROJECTED_META"));
endif()
```

### Example: branch on one stable projected value list

```text
if(num_gt(count(sorted_values(pick_keys(merge_hash(hash(meta), hash("stage", "normalized")), "kind", "source", "stage"))), 1));
  return(hash("kind", "RICH_PROJECTED_VALUES"));
else;
  return(hash("kind", "MIN_PROJECTED_VALUES"));
endif()
```

## Recommendations
- Prefer `is_defined(...)` / `is_undefined(...)` when the real question is presence versus absence.
- Prefer `has_key(...)` when the real question is object shape: “does this key exist at all?”
- Prefer `merge_hash(...)` inside a flow condition when you need to branch on one normalized or layered object shape without mutating the original working hash first.
- Prefer `set_key(...)` inside a flow condition when you need to branch on one targeted field update without spelling a whole one-key merge wrapper first.
- Prefer `rename_key(...)` inside a flow condition when you need to branch on one field-name normalization without spelling a manual delete-plus-set sequence first.
- Prefer `drop_keys(...)` inside a flow condition when you need to ignore debug or transport-only fields before asking one object-shape question.
- Prefer `pick_keys(...)` inside a flow condition when you need to branch on one small, stable projected object shape instead of a larger working object.
- Prefer `sorted_keys(...)` when you need one deterministic key-list view of object shape before using array reducers or returning a key summary.
- Prefer `sorted_values(...)` when you need one deterministic value-list view derived from one projected object shape before using array reducers or returning value summaries.
- Prefer `length(...)` when the real question is “how long is this scalar after normalization/defaulting?” rather than “is it empty?” or “is it defined?”.
- Prefer `coalesce_nonempty(...)` when the real question is “what is the first defined nonblank scalar value after normalization?” rather than “what is the first merely defined value?”.
- Prefer `array_expr[index]` or `hash_expr[key]` on top of composed aggregate helpers when the real question is “read one canonical item from this normalized aggregate” rather than “materialize a temporary aggregate variable first”.
- Prefer `first(...)` / `last(...)` when the real question is “what is the boundary item of this array or projected array?” rather than “how many?” or “does it contain?”.
- Prefer `index_of(...)` when the real question is “where is the first matching item in this array or projected array?” rather than only “does it contain?” or “what is the boundary item?”.
- Prefer `take(...)` when the real question is “what is the first bounded prefix array I want to keep and keep composing?” rather than “what is the first single item?” or “what is the remainder?”.
- Prefer `take_last(...)` when the real question is “what is the final bounded suffix array I want to keep and keep composing?” rather than “what is the last single item?” or “what is the leading array after discarding a suffix?”.
- Prefer `drop_back(...)` when the real question is “what is the leading array after I discard one trailing delimiter or suffix?” rather than “what is the first bounded prefix?” or “what is the remainder after the front edge?”.
- Prefer `join_values(...)` on top of `sorted_keys(...)`, `sorted_values(...)`, or other array-valued helpers when the real question is “does this projected aggregate reduce to one exact scalar string?”
- Prefer `contains(...)` when the real question is “does this array or projected array contain one exact scalar value?”
- Prefer `is_empty(...)` / `is_nonempty(...)` over raw truthiness checks when the intent is emptiness, especially after `sorted_values(...)`, `pick_keys(...)`, `drop_keys(...)`, or aggregate `coalesce(...)` have already built one value for you.
- Do not use `is_defined(...)` as a substitute for `is_nonempty(...)`; an empty string is still defined.
- Do not use `is_defined(payload["field"])` as a substitute for `has_key(...)` when you specifically need key existence semantics.
- Prefer `eq(...)` / `ne(...)` over raw string comparisons when the logic is part of canonical helper flow.
- Prefer `num_*` helpers over string comparisons for counters, indices, and numeric depths.
- Keep nested expressions readable; if one condition becomes too large, split the logic by first assigning a temporary flag.

## Related guides
- Cross-cutting scalar/aggregate cookbook: [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md)
- Control-flow markers: [`USER_GUIDE_ActionIR_ControlFlow.md`](USER_GUIDE_ActionIR_ControlFlow.md)
- Assignments and value sources: [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
