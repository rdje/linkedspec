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
- numeric comparisons: `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, `num_le`
- regex predicates: `matches(lhs, /regex/)`
- nested composition of those helpers

## Why this expression family matters
A large part of backend-neutral authoring is replacing raw Perl branch conditions such as:

```text
if ($flag && $name ne "")
```

with explicit DSL expressions such as:

```text
if(and(scalar(flag), is_nonempty(scalar(name))))
```

That is easier to analyze, easier to lower, and easier to port.

## Boolean composition
### `or(...)`

```text
or(scalar(on), scalar(off))
or(eq(scalar(kind), "A"), eq(scalar(kind), "B"))
```

Use it when any one of the conditions should pass.

### `and(...)`

```text
and(scalar(enabled), is_nonempty(scalar(name)))
and(not(is_empty(array(items))), matches(scalar(token), /^[A-Z_]+$/))
```

Use it when all conditions must pass.

### `not(...)`

```text
not(is_empty(scalar(name)))
not(eq(scalar(kind), "ignore"))
```

Use it to invert one condition.

## Definedness helpers
### `is_defined(...)`
Use this when the rule needs to distinguish "missing/undefined" from "defined but empty".

Examples:

```text
is_defined(scalar(name))
is_defined(scalaref(retv, {content}))
is_defined(coalesce(scalaref(retv, {type}), scalar(IMATCH)))
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
is_undefined(scalaref(retv, {type}))
is_undefined(coalesce(scalaref(retv, {content}), scalar(IMATCH)))
```

Use it when the rule should take a missing-value branch only if no defined value is available yet.

## Emptiness helpers
### `is_empty(...)`
Use it for scalars, arrays, or general expressions.

Examples:

```text
is_empty(scalar(name))
is_empty(array(items))
is_empty(join_values("", array(word)))
```

Typical meanings:
- scalar is undefined or empty string,
- array has no elements,
- general expression evaluates false/empty.

This is intentionally different from `is_defined(...)`:
- `is_empty(scalar(name))` treats both `undef` and `""` as empty,
- `is_defined(scalar(name))` treats `""` as already present.

### `is_nonempty(...)`
This is the inverse convenience helper.

Examples:

```text
is_nonempty(array(word))
is_nonempty(array(tail))
is_nonempty(scalar(content))
is_nonempty(join_values("", array(word)))
```

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
eq(scalar(kind), "SPACE")
ne(scalar(block_namee), scalar(block_namei))
gt(scalar(name), "M")
```

Use these when you mean Perl-style string comparison semantics.

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
num_eq(scalar(count), 0)
num_gt(scalar(index), 3)
num_le(scalar(depth), 8)
```

Use these when the values are numeric and you want numeric ordering/comparison, not string ordering.

## Regex predicate
### `matches(lhs, /regex/)`

Examples:

```text
matches(scalar(token), /^[A-Z_]+$/)
matches(scalar(name), /foo/i)
```

Use this when a branch depends on regex membership rather than equality.

## Nested examples
This expression language is designed for nesting.

### Example: field must exist, even if it is empty

```text
is_defined(scalaref(retv, {content}))
```

### Example: child type is still missing after fallback

```text
is_undefined(coalesce(scalaref(retv, {type}), scalar(IMATCH)))
```

### Example: nonempty and not disabled

```text
and(is_nonempty(array(items)), not(scalar(disabled)))
```

### Example: either explicit enable or a nonempty fallback name

```text
or(scalar(enabled), is_nonempty(scalar(name)))
```

### Example: check an entry inside a working array

```text
eq(scalar(array(capt), 0), "?branch:")
```

### Example: compound rule guard

```text
and(
  is_nonempty(array(capt)),
  matches(scalar(token), /^[A-Z_]+$/),
  not(eq(scalar(mode), "skip"))
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
declare(scalar, flag=or(scalar(on), scalar(off)))
assign(scalar(flag), and(is_nonempty(array(items)), scalar(enabled)))
assign(scalar(has_type), is_defined(scalaref(retv, {type})))
if(not(is_empty(scalar(name)))); ... endif()
```

## Scalar and nested-access expressions inside conditions
You can combine `scalar(...)` and `scalaref(...)` with the flow-expression helpers.

Examples:

```text
eq(scalaref(retv, {type}), "SPACE")
ne(scalaref(retv, {type}), "COMMENTS")
is_defined(scalaref(retv, {content}))
is_undefined(scalaref(retv, {type}))
is_nonempty(scalaref(retv, {content}))
has_key(hash(meta), "kind")
has_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "kind")
has_key(merge_hash(hash(meta), hash("stage", "normalized")), "kind")
has_key(drop_keys(hash(meta), "debug"), "kind")
has_key(pick_keys(hash(meta), "kind", "source"), "kind")
num_gt(count(sorted_keys(pick_keys(hash(meta), "kind", "source"))), 1)
num_gt(count(array(parts)), 0)
num_gt(count_keys(hash(meta)), 1)
eq(lowercase(trim(scalaref(retv, {type}))), "word")
eq(coalesce(scalaref(retv, {type}), "UNKNOWN"), "WORD")
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
if(ne(scalar(block_namee), scalar(block_namei)));
  print("error\n");
  exit;
endif()
```

The branch body there may still be legacy/raw, but the condition itself is canonical.

### Example: classify token kinds

```text
if(eq(scalaref(retv, {type}), "SPACE"));
  ...
elseif(ne(scalaref(retv, {type}), "COMMENTS"));
  ...
endif()
```

### Example: separate "missing" from "empty"

```text
if(is_undefined(scalaref(retv, {content})));
  return(hash("kind", "MISSING_CONTENT"));
elseif(is_empty(scalaref(retv, {content})));
  return(hash("kind", "EMPTY_CONTENT"));
else;
  return(hash("kind", "HAS_CONTENT", "content", scalaref(retv, {content})));
endif()
```

### Example: fallback branch only when no defined value survives

```text
if(is_defined(coalesce(scalaref(retv, {type}), scalar(IMATCH))));
  return(hash("kind", "CLASSIFIED", "type", coalesce(scalaref(retv, {type}), scalar(IMATCH))));
else;
  return(hash("kind", "UNCLASSIFIED"));
endif()
```

### Example: normalize before comparing

```text
if(eq(lowercase(trim(coalesce(scalaref(retv, {type}), " WORD "))), "word"));
  return(hash("kind", "WORD"));
else;
  return(hash("kind", "OTHER"));
endif()
```

### Example: branch on array size

```text
if(num_gt(count(coalesce(scalaref(retv, {parts}), array("empty"))), 1));
  return(hash("kind", "MULTI_PART"));
else;
  return(hash("kind", "SINGLE_PART"));
endif()
```

### Example: branch on hash/object richness

```text
if(num_gt(count_keys(coalesce(scalaref(retv, {meta}), hash("kind", "fallback"))), 1));
  return(hash("kind", "RICH_META"));
else;
  return(hash("kind", "MIN_META"));
endif()
```

### Example: branch on key existence rather than value definedness

```text
if(has_key(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), "kind"));
  return(hash("kind", "HAS_KIND_KEY"));
else;
  return(hash("kind", "NO_KIND_KEY"));
endif()
```

### Example: branch on one normalized merged object shape

```text
if(has_key(merge_hash(coalesce(scalaref(retv, {meta}), hash("kind", "fallback")), hash("stage", "normalized")), "kind"));
  return(hash("kind", "HAS_NORMALIZED_KIND"));
else;
  return(hash("kind", "NO_NORMALIZED_KIND"));
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
- Prefer `drop_keys(...)` inside a flow condition when you need to ignore debug or transport-only fields before asking one object-shape question.
- Prefer `pick_keys(...)` inside a flow condition when you need to branch on one small, stable projected object shape instead of a larger working object.
- Prefer `sorted_keys(...)` when you need one deterministic key-list view of object shape before using array reducers or returning a key summary.
- Prefer `sorted_values(...)` when you need one deterministic value-list view derived from one projected object shape before using array reducers or returning value summaries.
- Prefer `is_empty(...)` / `is_nonempty(...)` over raw truthiness checks when the intent is emptiness.
- Do not use `is_defined(...)` as a substitute for `is_nonempty(...)`; an empty string is still defined.
- Do not use `is_defined(scalaref(...))` as a substitute for `has_key(...)` when you specifically need key existence semantics.
- Prefer `eq(...)` / `ne(...)` over raw string comparisons when the logic is part of canonical helper flow.
- Prefer `num_*` helpers over string comparisons for counters, indices, and numeric depths.
- Keep nested expressions readable; if one condition becomes too large, split the logic by first assigning a temporary flag.

## Related guides
- Cross-cutting scalar/aggregate cookbook: [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md)
- Control-flow markers: [`USER_GUIDE_ActionIR_ControlFlow.md`](USER_GUIDE_ActionIR_ControlFlow.md)
- Assignments and value sources: [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
