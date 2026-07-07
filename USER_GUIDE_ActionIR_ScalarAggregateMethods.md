# USER GUIDE - Scalar and Aggregate Method Composition
This guide is the long-form cookbook for working with scalar values and aggregate values in LinkedSpec `.spec` files.

Post-`SPEC-FORMAT-TERSE.8.3` / `.8.4` status:
- this root cookbook predates helper hard-retirement and is retained as migration/reference material,
- current examples should prefer `copy(...)`, `cat(...)`, `push(...)`, `set(...)`, direct assignment, aggregate wrappers, and bare scalar reads,
- old `declare(...)`, `assign(...)`, `array_copy(...)`, `hash_copy(...)`, source-spelled `concat(...)`, `push_value(...)`, `push_nonempty(...)`, scalar-slot wrapper, and short wrapper examples below are historical unless explicitly marked current.

Read this guide when you want one place that teaches:
- string, integer, and float-like scalar handling,
- arrays and hashes,
- nested value construction,
- and how those value expressions compose inside declarations, assignments, returns, `if(...)`, and `switch(...)`.

For the exact lowering details behind each helper family, also read:
- [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md)
- [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
- [`USER_GUIDE_ActionIR_DeclareMethod.md`](USER_GUIDE_ActionIR_DeclareMethod.md)
- [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md)

Documentation note:
- scalar and aggregate helper expressions are intended to support unlimited nested composition with no DSL-fixed depth limit,
- practical limits come only from ordinary runtime/resource ceilings rather than an explicit language-level composition cap,
- this guide uses many examples on purpose,
- and those examples are representative teaching shapes, not a claim that the language is limited to only the exact combinations shown here.

## The core rule: methods compose like values
LinkedSpec method arguments are meant to compose the way Lisp expressions compose: one method call can feed another method call, and that second call can feed a third, without an explicit semantic nesting cap in the DSL.

Small examples:

```text
join_values("", array(word))
retv["content"]
copy(array(items))
hash("type", retv["type"], "content", retv["content"])
```

Larger examples:

```text
set(array(parts), filter_match(uniq(uppercase_each(array(IMATCH_LIST))), /^A/))
```

```text
return(hash(
  "kind", "NODE",
  "head", scalar(items, 0),
  "content", retv["content"],
  "parts", copy(array(parts))
))
```

```text
return(array(
  hash("name", join_values("", array(word)), "tags", copy(array(tags))),
  hash("meta", hash("depth", depth, "confidence", confidence))
))
```

Those are all the same idea:
- produce a scalar value,
- produce an aggregate value,
- feed it into another helper,
- keep nesting until the result says what you mean clearly.

## What counts as a scalar here
In LinkedSpec user-facing docs, "scalar" is the broad bucket for values such as:
- strings,
- integers,
- floats,
- booleans or flag-like values,
- captures and match text,
- and one scalar slot holding a child result or one field read from a returned payload.

The important point is not the host language's exact runtime type rules. The important point is that you author these through canonical helper forms instead of raw Perl expressions.

## String scalar methods
String-like scalar work is the most common value flow in `.spec` files.

### Direct scalar reads

```text
name
IMATCH
LMATCH
IMATCH_LIST[0]
```

Typical uses:
- keep the current match text,
- keep a named working variable,
- read one positional capture,
- compare or return that value later.

Examples:

```text
token = IMATCH
opening = IMATCH_LIST[0]
return(hash("type", "TOKEN", "content", token))
```

### Captured substring as a scalar

```text
content = CAPTURE
```

This is the canonical helper way to keep a captured substring without dropping back to raw Perl substring code.

Example:

```text
-> block[1] {
  content = CAPTURE
  return(hash("type", "BLOCK", "content", content))
}
```

### Joined-string scalar values

```text
join_values("", array(word))
join_values(", ", array(parts))
join_values(", ", sorted_keys(hash(meta)))
join_values(" | ", sorted_values(pick_keys(hash(meta), "kind", "source")))
```

Use `join_values(...)` when the source material already lives in an array, or can be projected into one array value, and the result you need is one final string scalar.

Examples:

```text
assign(scalar(word_text), join_values("", array(word)))
assign(scalar(csv_text), join_values(", ", array(parts)))
assign(scalar(public_fields), join_values(", ", sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(scalar(public_values), join_values(" | ", sorted_values(pick_keys(hash(meta), "kind", "source", "stage"))))
return(hash("text", join_values("", array(chars))))
return(join_values(", ", sorted_keys(drop_keys(hash(meta), "debug"))))
```

That broader shape matters because `join_values(...)` is not just “join one named array variable” anymore. It can now sit on top of the same array-valued helper expressions the rest of the DSL already uses:

```text
join_values(", ", sorted_keys(hash(meta)))
join_values(" | ", sorted_values(pick_keys(hash(meta), "kind", "source")))
join_values(", ", coalesce(retv["parts"], array("fallback")))
```

So the usual parser-oriented pattern can stay compact:
- project or normalize one aggregate,
- reduce it to one scalar,
- keep the whole chain inside one composable value expression.

### Middle-array extraction with `slice(...)`
`slice(...)` is the parser-oriented helper for “start at this array position, and optionally keep only this many items”.

Examples:

```text
slice(array(parts), 1)
slice(array(parts), 1, 2)
slice(sorted_keys(hash(meta)), 1)
slice(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), scalar(slice_start), scalar(slice_count))
slice(coalesce(retv["parts"], array("fallback")), scalar(slice_start))
```

Use `slice(...)` when:
- `drop_front(...)` is too coarse because you need one later starting point rather than only “drop the first one or first `N`,”
- `take(...)` is too coarse because you need one middle window rather than a prefix,
- one rule wants to keep processing one canonical middle subarray without temporary staging arrays,
- or one later reducer / nested read still needs to compose directly on that kept middle array.

Examples in context:

```text
assign(array(middle_parts), slice(array(parts), 1))
assign(array(middle_parts), slice(array(parts), 1, 2))
assign(array(middle_keys), slice(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(slice_start), scalar(slice_count)))
assign(scalar(middle_count), count(slice(sorted_keys(hash(meta)), 1, 2)))
assign(scalar(first_middle_key), scalar(slice(sorted_keys(hash(meta)), 1, 1), 0))
return(hash(
  "middle_keys", slice(sorted_keys(hash(meta)), 1, 2),
  "middle_count", count(slice(sorted_keys(hash(meta)), 1, 2))
))
```

Important semantic note:
- `slice(array_expr, start_index)` keeps everything from `start_index` through the end,
- `slice(array_expr, start_index, take_count)` keeps at most `take_count` items starting there,
- negative or invalid `start_index` / `take_count` values clamp to `0`,
- if the source is undefined, the start is already out of range, or the count is non-positive, the result is `[]`,
- and `slice(...)` stays array-valued, so it composes naturally with `count(...)`, `join_values(...)`, `concat_arrays(...)`, `take(...)`, `drop_front(...)`, and nested `scalar(container, index)` reads.

### Scalar text normalization
These helpers keep common string cleanup inside the canonical value-expression layer:
- `trim(value)`
- `lowercase(value)`
- `uppercase(value)`

Examples:

```text
trim(scalar(IMATCH))
lowercase(trim(retv["content"]))
uppercase(coalesce(retv["type"], "word"))
```

Use cases:
- strip outer whitespace from captures,
- normalize case before comparisons,
- store canonical lower-case or upper-case payload fields,
- keep scalar cleanup expression-oriented instead of expanding it into a branch ladder.

Examples in context:

```text
assign(scalar(clean_name), trim(scalar(IMATCH)))
assign(scalar(norm_type), lowercase(trim(coalesce(retv["type"], " WORD "))))
return(hash("kind", uppercase(trim(coalesce(retv["kind"], "unknown")))))
```

Important semantic note:
- these helpers preserve `undef`,
- so they do not quietly invent an empty string where no value existed.

### Scalar string assembly with `concat(...)`
`concat(...)` is the parser-oriented helper for “take these scalar fragments and build one canonical scalar string”.

Examples:

```text
concat(scalar(name), "_", scalar(stage))
concat(lowercase(trim(scalar(first_name))), "_", replace_substr(lowercase(trim(scalar(last_name))), " ", "_"))
concat(coalesce_nonempty(trim(retv["type"]), scalar(IMATCH), "word"), "::", uppercase(trim(scalar(kind))))
```

Use cases:
- build one canonical key, label, or normalized identifier from several scalar fragments,
- keep string assembly inside the same composable expression layer as `trim(...)`, `lowercase(...)`, `replace_substr(...)`, and `coalesce_nonempty(...)`,
- avoid staging through `array(...)` plus `join_values(...)` when the rule already knows the exact scalar pieces it wants,
- and keep direct `return(payload)` fields expression-oriented instead of falling back to host-language string interpolation.

Examples in context:

```text
assign(scalar(full_name), concat(lowercase(trim(scalar(first_name))), "_", replace_substr(lowercase(trim(scalar(last_name))), " ", "_")))
assign(scalar(stage_key), concat(scalar(full_name), "::", scalar(stage)))
return(hash(
  "full_name", concat(lowercase(trim(scalar(first_name))), "_", replace_substr(lowercase(trim(scalar(last_name))), " ", "_")),
  "stage_key", concat(scalar(full_name), "::", scalar(stage))
))
if(eq(concat(lowercase(trim(scalar(name))), "_", scalar(stage)), "node_init"))
```

Important semantic note:
- `concat(...)` is variadic and currently requires two or more operands,
- all operands must resolve to defined non-reference scalar values or the result stays `undef`,
- numeric-looking scalar operands are accepted and stringified naturally,
- and aggregate references are rejected instead of being silently stringified into host-language ref text.

### Scalar text length with `length(...)`
`length(...)` is the parser-oriented helper for “how long is this scalar text value?”

Examples:

```text
length(scalar(name))
length(trim(retv["content"]))
length(coalesce(retv["content"], scalar(IMATCH), "UNKNOWN"))
```

Use cases:
- store one text-length metadata field in a scalar,
- branch on whether normalized text is longer than one threshold,
- keep string-length logic inside the same composable value-expression layer as normalization and defaulting.

Examples in context:

```text
assign(scalar(clean_length), length(trim(scalar(IMATCH))))
assign(scalar(content_length), length(coalesce(retv["content"], scalar(IMATCH), "UNKNOWN")))
return(hash("content_length", length(trim(coalesce(retv["content"], scalar(IMATCH), "UNKNOWN")))))
if(num_gt(coalesce(length(trim(scalar(name))), 0), 3))
```

Important semantic note:
- `length(...)` is about scalar/string length,
- not about array size,
- and if the scalar expression is still undefined, `length(...)` preserves `undef`.

That last point matters. If the rule wants “missing text counts as zero length,” write that explicitly:

```text
coalesce(length(trim(scalar(name))), 0)
```

### Defaulting and coalescing scalar values

```text
coalesce(retv["content"], scalar(IMATCH), "UNKNOWN")
coalesce(scalar(explicit_name), scalar(fallback_name), "unnamed")
```

Use `coalesce(...)` when you want the first **defined** value in a fallback chain.

This is an important semantic detail:
- `coalesce(...)` does **not** skip `0`,
- it does **not** skip `""`,
- and it does **not** skip a defined empty aggregate reference.

So it behaves like a parser-oriented "first defined value wins" helper, not a generic truthiness filter.

Examples:

```text
assign(scalar(chosen_name), coalesce(retv["content"], scalar(IMATCH), "UNKNOWN"))
return(hash("name", coalesce(scalar(explicit_name), scalar(fallback_name), "unnamed")))
if(eq(coalesce(retv["type"], "UNKNOWN"), "WORD"))
```

### Defaulting nonempty scalar values with `coalesce_nonempty(...)`

```text
coalesce_nonempty(trim(retv["content"]), scalar(IMATCH), "UNKNOWN")
coalesce_nonempty(trim(scalar(explicit_name)), trim(scalar(fallback_name)), "unnamed")
coalesce_nonempty(trim(retv["type"]), scalar(kind), "WORD")
```

Use `coalesce_nonempty(...)` when you want the first **defined nonempty scalar** value in a fallback chain.

This is the important semantic difference from `coalesce(...)`:
- `coalesce_nonempty(...)` skips `undef`,
- it also skips `""`,
- but it still does **not** skip `0`,
- and it will only treat whitespace-only strings as empty if you explicitly normalize them with `trim(...)`.

So `coalesce_nonempty(...)` is the parser-oriented helper for “first real text wins” rather than “first defined value wins”.

Examples:

```text
assign(scalar(chosen_name), coalesce_nonempty(trim(retv["content"]), scalar(IMATCH), "UNKNOWN"))
return(hash("chosen_type", coalesce_nonempty(trim(retv["type"]), scalar(kind), "WORD")))
if(eq(coalesce_nonempty(trim(retv["type"]), scalar(kind), "WORD"), "WORD"))
```

### Presence checks versus emptiness checks
Once you start composing scalar helpers deeply, it becomes important to distinguish:
- "is a value present at all?"
- from "is a value nonempty?"

That is the difference between:

```text
is_defined(retv["content"])
is_undefined(retv["content"])
is_empty(retv["content"])
is_nonempty(retv["content"])
```

Use `is_defined(...)` / `is_undefined(...)` when presence matters.
Use `is_empty(...)` / `is_nonempty(...)` when content size matters.

Examples:

```text
if(is_defined(retv["content"]))
if(is_undefined(coalesce(retv["type"], scalar(IMATCH))))
if(is_empty(retv["content"]))
if(is_nonempty(join_values("", array(word))))
if(is_empty(sorted_values(pick_keys(hash(meta), "kind", "source"))))
if(is_nonempty(pick_keys(drop_keys(hash(meta), "debug"), "kind", "source")))
assign(scalar(content_empty), is_empty(retv["content"]))
assign(scalar(meta_nonempty), is_nonempty(pick_keys(drop_keys(hash(meta), "debug"), "kind", "source")))
return(hash("content_empty", is_empty(retv["content"]), "meta_nonempty", is_nonempty(pick_keys(drop_keys(hash(meta), "debug"), "kind", "source"))))
```

Important semantic difference:
- `""` is still **defined**,
- `0` is still **defined**,
- an empty array/hash ref is still **defined**,
- but those may still be empty for the purposes of `is_empty(...)`,
- so projected arrays from helpers like `sorted_values(...)` and projected hashes from helpers like `pick_keys(...)` should still be tested with `is_empty(...)` / `is_nonempty(...)`, not raw truthiness.

One more practical point now matters too:
- `is_empty(...)` / `is_nonempty(...)` are no longer only “branch helpers,”
- they can also be carried as explicit scalar flags inside `assign(...)` and `return(payload)`,
- which makes metadata like `"content_empty"`, `"has_projected_values"`, or `"meta_nonempty"` stay inside the same parser-oriented value layer instead of forcing users to branch only to recover a boolean.

### String scalars read from returned payloads

```text
retv["content"]
retv["type"]
tree[0]["name"]
```

This is the canonical way to say "read one field from a nested returned payload."

Examples:

```text
assign(scalar(kind), retv["type"])
assign(scalar(content), retv["content"])
return(hash("head_name", tree[0]["name"]))
```

## Integer scalar methods
Integer-like scalars are already part of the supported surface when you want to carry numeric literals, keep numeric-looking fields, branch with numeric comparison helpers, or compose simple parser-oriented arithmetic values.

Examples:

```text
declare(scalar, count=0, depth=1, max_depth=8)
if(num_eq(scalar(count), 0))
if(num_lt(scalar(depth), scalar(max_depth)))
assign(scalar(next_depth), num_add(scalar(depth), 1))
assign(scalar(weighted_count), num_mul(scalar(count), 2))
return(hash("depth", scalar(depth), "limit", scalar(max_depth)))
```

Typical uses:
- counts,
- depths,
- indices,
- numeric state flags such as `0` and `1`,
- numeric metadata returned in hash payloads.

Worked example:

```text
I {
  declare(scalar, depth=0, max_depth=8)
}

-> node[1] {
  if(num_lt(scalar(depth), scalar(max_depth)))
    return(hash("kind", "OPEN", "depth", scalar(depth), "limit", scalar(max_depth)))
  else
    return(hash("kind", "CAPPED", "depth", scalar(depth), "limit", scalar(max_depth)))
  endif
}
```

Important clarification:
- this guide is documenting integer-valued storage, comparison, and the first standardized arithmetic helpers,
- not claiming a broad general-purpose arithmetic language.

So this is in scope today:

```text
declare(scalar, count=0)
if(num_gt(scalar(count), 3))
assign(scalar(next_depth), num_add(scalar(depth), 1))
assign(scalar(remaining), num_sub(count(array(parts)), 1))
```

The current arithmetic surface is still intentionally disciplined rather than broad: `num_abs(...)`, `num_floor(...)`, `num_ceil(...)`, `num_round(...)`, `num_sum(...)`, `num_avg(...)`, `num_median(...)`, `num_range(...)`, `num_add(...)`, `num_sub(...)`, `num_mul(...)`, `num_div(...)`, `num_mod(...)`, `num_clamp(...)`, `num_min(...)`, and `num_max(...)` are supported, but the DSL is still not trying to become a general-purpose math language.
That broader arithmetic family still follows the same narrow parser-oriented contract rather than opening the door to arbitrary host-language numeric code.

## Float scalar methods
Float-like scalars follow the same rule as integer-like scalars: carry them through canonical helpers, compare them with `num_*`, compose them with the standardized arithmetic helpers, and return or store them in canonical payload constructors.

Examples:

```text
declare(scalar, threshold=0.75, confidence=0.98)
if(num_ge(scalar(confidence), 0.95))
assign(scalar(next_threshold), num_add(scalar(threshold), 0.05))
assign(scalar(weighted_confidence), num_mul(scalar(confidence), 1.5))
return(hash("threshold", scalar(threshold), "confidence", scalar(confidence)))
```

Worked example:

```text
I {
  declare(scalar, threshold=0.75, confidence=0.98)
}

-> score[1] {
  if(num_ge(scalar(confidence), scalar(threshold)))
    return(hash("grade", "PASS", "confidence", scalar(confidence), "threshold", scalar(threshold)))
  else
    return(hash("grade", "HOLD", "confidence", scalar(confidence), "threshold", scalar(threshold)))
  endif
}
```

Again, the current contract is:
- float literals can participate as scalar values,
- numeric comparisons on those scalars are part of the supported expression family,
- and the standardized arithmetic helpers `num_abs(...)`, `num_floor(...)`, `num_ceil(...)`, `num_round(...)`, `num_sum(...)`, `num_avg(...)`, `num_median(...)`, `num_range(...)`, `num_add(...)`, `num_sub(...)`, `num_mul(...)`, `num_div(...)`, `num_min(...)`, `num_max(...)`, and `num_clamp(...)` can compose with numeric-looking float values too, while `num_mod(...)` stays intentionally integer-oriented.

## Numeric arithmetic with `num_abs(...)`, `num_floor(...)`, `num_ceil(...)`, `num_round(...)`, `num_sum(...)`, `num_avg(...)`, `num_median(...)`, `num_range(...)`, `num_add(...)`, `num_sub(...)`, `num_mul(...)`, `num_div(...)`, `num_mod(...)`, `num_clamp(...)`, `num_min(...)`, and `num_max(...)`
These are the standardized numeric value helpers in the method DSL today.

Examples:

```text
num_abs(num_sub(scalar(depth), scalar(limit)))
num_abs(num_sub(num_add(count(array(parts)), scalar(offset)), scalar(upper_limit)))
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
num_add(scalar(depth), 1, scalar(offset))
num_add(coalesce(length(trim(scalar(name))), 0), 2, scalar(offset))
num_sub(count(array(parts)), 1)
num_sub(num_add(count(array(parts)), scalar(offset)), 1)
num_sub(scalar(confidence), scalar(threshold))
num_mul(count(array(parts)), scalar(factor))
num_mul(scalar(confidence), 1.5)
num_div(num_mul(count(array(parts)), scalar(factor)), 2)
num_div(scalar(confidence), scalar(threshold))
num_mod(num_add(count(array(parts)), scalar(offset)), 3)
num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10)
num_min(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10)
num_max(array(scores))
num_max(take(concat_arrays(array(scores), array(extra_scores)), 4))
num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(upper_limit))
```

Use cases:
- increment one depth or count without dropping into raw Perl,
- reduce one numeric-looking array into one scalar total without dropping into raw Perl,
- reduce one numeric-looking array into one scalar average without dropping into raw Perl,
- reduce one numeric-looking array into one scalar median without dropping into raw Perl,
- reduce one numeric-looking array into one scalar max-minus-min span without dropping into raw Perl,
- reduce one numeric-looking array into one scalar minimum/maximum without dropping into raw Perl,
- derive one remaining-item count from an array reducer,
- carry one adjusted threshold or confidence value,
- keep numeric metadata inside the same composable value-expression layer as `count(...)`, `length(...)`, and `coalesce(...)`.

Examples in context:

```text
assign(scalar(distance), num_abs(num_sub(num_add(count(array(parts)), scalar(offset)), scalar(upper_limit))))
assign(scalar(floored_depth), num_floor(num_sub(scalar(depth), scalar(offset))))
assign(scalar(ceiled_average), num_ceil(num_div(num_mul(count(array(parts)), scalar(factor)), 2)))
assign(scalar(rounded_name_length), num_round(num_add(coalesce(length(trim(scalar(name))), 0), 0.5)))
assign(scalar(total_score), num_sum(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(average_score), num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(median_score), num_median(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(score_range), num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(lowest_score), num_min(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(next_depth), num_add(scalar(depth), 1))
assign(scalar(total_length), num_add(coalesce(length(trim(scalar(name))), 0), 2, scalar(offset)))
assign(scalar(window_size), num_sub(count(array(parts)), 1))
assign(scalar(adjusted_confidence), num_sub(scalar(confidence), 0.05))
assign(scalar(weighted_count), num_mul(count(array(parts)), scalar(factor)))
assign(scalar(average_count), num_div(num_mul(count(array(parts)), scalar(factor)), 2))
assign(scalar(bucket), num_mod(num_add(count(array(parts)), scalar(offset)), 3))
assign(scalar(clamped_total), num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10))
assign(scalar(floor_value), num_min(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10))
assign(scalar(highest_score), num_max(take(concat_arrays(array(scores), array(extra_scores)), 4)))
assign(scalar(ceiling_value), num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(upper_limit)))
return(hash(
  "distance", num_abs(num_sub(num_add(count(array(parts)), scalar(offset)), scalar(upper_limit))),
  "floored_depth", num_floor(num_sub(scalar(depth), scalar(offset))),
  "ceiled_average", num_ceil(num_div(num_mul(count(array(parts)), scalar(factor)), 2)),
  "rounded_name_length", num_round(num_add(coalesce(length(trim(scalar(name))), 0), 0.5)),
  "total_score", num_sum(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "average_score", num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "median_score", num_median(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "score_range", num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "lowest_score", num_min(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "next_depth", num_add(scalar(depth), 1),
  "remaining", num_sub(num_add(count(array(parts)), scalar(offset)), 1),
  "adjusted_confidence", num_sub(scalar(confidence), scalar(threshold)),
  "average_count", num_div(num_mul(count(array(parts)), scalar(factor)), 2),
  "bucket", num_mod(num_add(count(array(parts)), scalar(offset)), 3),
  "clamped_total", num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10),
  "floor_value", num_min(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10),
  "highest_score", num_max(take(concat_arrays(array(scores), array(extra_scores)), 4)),
  "ceiling_value", num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(upper_limit))
))
if(num_gt(num_abs(num_sub(num_add(count(array(parts)), scalar(offset)), scalar(upper_limit))), 1))
if(num_ge(num_floor(num_sub(scalar(depth), scalar(offset))), 1))
if(num_ge(num_ceil(num_div(num_mul(count(array(parts)), scalar(factor)), 2)), 2))
if(num_eq(num_round(num_add(coalesce(length(trim(scalar(name))), 0), 0.5)), 6))
if(num_gt(num_sum(take(concat_arrays(array(scores), array(extra_scores)), 4)), 10))
if(num_ge(num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4)), 5))
if(num_ge(num_median(take(concat_arrays(array(scores), array(extra_scores)), 4)), 5))
if(num_eq(num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)), 6))
if(num_ge(num_min(take(concat_arrays(array(scores), array(extra_scores)), 4)), 2))
if(num_gt(num_add(count(array(parts)), scalar(offset)), 3))
if(num_ge(num_sub(scalar(confidence), scalar(threshold)), 0))
if(num_gt(num_mul(count(array(parts)), scalar(factor)), 3))
if(num_ge(num_div(num_mul(count(array(parts)), scalar(factor)), 2), 1))
if(num_eq(num_mod(num_add(count(array(parts)), scalar(offset)), 3), 1))
if(num_eq(num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), scalar(upper_limit)), 5))
if(num_le(num_min(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10), 4))
if(num_ge(num_max(take(concat_arrays(array(scores), array(extra_scores)), 4)), 8))
if(num_ge(num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(upper_limit)), 6))
```

Worked example:

```text
I {
  declare(array, scores=array(1, 2.5, 3), extra_scores=array(4, 5), parts=array("A", "B", "C"))
  declare(scalar, raw_name="  score  ", depth=1.25, offset=3, factor=1.5, divisor=2, lower_limit=3, upper_limit=6, distance, floored_depth, ceiled_average, rounded_name_length, total_score, average_score, median_score, score_range, lowest_score, next_depth, remaining, average_count, bucket, clamped_total, floor_value, highest_score, ceiling_value)
}

-> node[1] {
  assign(scalar(distance), num_abs(num_sub(num_add(count(array(parts)), scalar(offset)), scalar(upper_limit))))
  assign(scalar(floored_depth), num_floor(num_sub(scalar(depth), scalar(offset))))
  assign(scalar(ceiled_average), num_ceil(num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor))))
  assign(scalar(rounded_name_length), num_round(num_add(coalesce(length(trim(scalar(raw_name))), 0), scalar(offset))))
  assign(scalar(total_score), num_sum(take(concat_arrays(array(scores), array(extra_scores)), 4)))
  assign(scalar(average_score), num_avg(take(concat_arrays(array(scores), array(extra_scores)), 4)))
  assign(scalar(median_score), num_median(take(concat_arrays(array(scores), array(extra_scores)), 4)))
  assign(scalar(score_range), num_range(take(concat_arrays(array(scores), array(extra_scores)), 4)))
  assign(scalar(lowest_score), num_min(take(concat_arrays(array(scores), array(extra_scores)), 4)))
  assign(scalar(next_depth), num_add(scalar(depth), 1, scalar(offset)))
  assign(scalar(remaining), num_sub(num_add(count(array(parts)), scalar(offset)), 1))
  assign(scalar(average_count), num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor)))
  assign(scalar(bucket), num_mod(num_add(count(array(parts)), scalar(offset)), 3))
  assign(scalar(clamped_total), num_clamp(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), scalar(upper_limit)))
  assign(scalar(floor_value), num_min(num_add(count(array(parts)), scalar(offset)), scalar(lower_limit), 10))
  assign(scalar(highest_score), num_max(take(concat_arrays(array(scores), array(extra_scores)), 4)))
  assign(scalar(ceiling_value), num_max(num_add(count(array(parts)), scalar(offset)), 2, scalar(upper_limit)))

  return(hash(
    "distance", scalar(distance),
    "floored_depth", scalar(floored_depth),
    "ceiled_average", scalar(ceiled_average),
    "rounded_name_length", scalar(rounded_name_length),
    "total_score", scalar(total_score),
    "average_score", scalar(average_score),
    "median_score", scalar(median_score),
    "score_range", scalar(score_range),
    "lowest_score", scalar(lowest_score),
    "next_depth", scalar(next_depth),
    "remaining", scalar(remaining),
    "average_count", scalar(average_count),
    "bucket", scalar(bucket),
    "clamped_total", scalar(clamped_total),
    "floor_value", scalar(floor_value),
    "highest_score", scalar(highest_score),
    "ceiling_value", scalar(ceiling_value),
    "enough_parts", num_gt(scalar(remaining), 1)
  ))
}
```

Important semantic notes:
- `num_abs(...)` is currently unary,
- `num_floor(...)` is currently unary,
- `num_ceil(...)` is currently unary,
- `num_round(...)` is currently unary,
- `num_sum(...)` is currently unary over one array-valued source,
- `num_avg(...)` is currently unary over one array-valued source,
- `num_median(...)` is currently unary over one array-valued source,
- `num_range(...)` is currently unary over one array-valued source,
- `num_add(...)` accepts two or more operands,
- `num_sub(...)` is currently binary,
- `num_mul(...)` accepts two or more operands,
- `num_div(...)` is currently binary,
- `num_mod(...)` is currently binary,
- `num_clamp(...)` is currently ternary,
- `num_min(...)` accepts either one array-valued source or two or more operands,
- `num_max(...)` accepts either one array-valued source or two or more operands,
- `num_sum(...)` returns `0` for an empty array but `undef` when the source is not array-valued or when any element is missing/non-numeric-looking,
- `num_avg(...)` returns `undef` for an empty array, for a non-array source, or when any element is missing/non-numeric-looking,
- `num_median(...)` returns `undef` for an empty array, for a non-array source, or when any element is missing/non-numeric-looking,
- `num_range(...)` returns `undef` for an empty array, for a non-array source, or when any element is missing/non-numeric-looking,
- `num_min(array_expr)` and `num_max(array_expr)` return `undef` for an empty array, for a non-array source, or when any element is missing/non-numeric-looking,
- `num_sum(array_expr)` is the array-to-scalar numeric reducer, while `num_add(...)` remains the scalar-to-scalar combiner for already scalar numeric terms,
- `num_avg(array_expr)` is the array-to-scalar numeric average reducer when the rule wants “mean-like summary of this array,” not just “sum these already scalar terms,”
- `num_median(array_expr)` is the array-to-scalar numeric median reducer when the rule wants “middle value after numeric ordering of this array,” not just “sum/average these items,”
- `num_range(array_expr)` is the array-to-scalar numeric span reducer when the rule wants “largest minus smallest numeric-looking item in this array,” not just “choose one boundary item,”
- `num_min(array_expr)` and `num_max(array_expr)` are the array-to-scalar boundary reducers when the rule wants “smallest numeric-looking item in this array” or “largest numeric-looking item in this array,” not just a scalar floor/ceiling composition,
- `num_median(...)` returns the single middle item for odd-length arrays and the average of the two middle items for even-length arrays,
- `num_range(...)` returns the numeric maximum minus the numeric minimum, so a one-item array yields `0`,
- operands must be defined numeric-looking scalars,
- supported numeric-looking forms are simple integers/decimals such as `0`, `-3`, `0.75`, and `12.5`,
- `num_mod(...)` is intentionally stricter and currently expects integer-looking operands such as `0`, `3`, or `-7`,
- if any operand is undefined or not numeric-looking, the arithmetic helper returns `undef`,
- `num_round(...)` rounds halves away from zero so one `.spec` file does not depend on backend-specific rounding defaults,
- `num_clamp(...)` returns `undef` when the lower bound is greater than the upper bound instead of silently swapping them,
- and both `num_div(...)` and `num_mod(...)` also return `undef` when the divisor is `0`.
- Callers that want “missing means zero” should say that explicitly with `coalesce(...)`.

Examples:

```text
num_abs(coalesce(num_sub(scalar(depth), scalar(upper_limit)), 0))
num_floor(coalesce(num_sub(scalar(depth), scalar(offset)), 0))
num_ceil(coalesce(num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor)), 0))
num_round(coalesce(num_add(length(trim(scalar(name))), 0.5), 0))
num_sum(coalesce(retv["scores"], array()))
coalesce(num_avg(coalesce(retv["scores"], array())), 0)
coalesce(num_median(coalesce(retv["scores"], array())), 0)
coalesce(num_range(coalesce(retv["scores"], array())), 0)
coalesce(num_min(coalesce(retv["scores"], array())), 0)
num_add(coalesce(scalar(depth), 0), 1)
num_sub(coalesce(length(trim(scalar(name))), 0), 1)
num_mul(coalesce(count(array(parts)), 0), scalar(factor))
coalesce(num_div(num_mul(count(array(parts)), scalar(factor)), scalar(divisor)), 0)
num_mod(coalesce(num_add(count(array(parts)), scalar(offset)), 0), 3)
num_clamp(coalesce(num_add(count(array(parts)), scalar(offset)), 0), scalar(lower_limit), 10)
num_min(coalesce(num_add(count(array(parts)), scalar(offset)), 0), scalar(lower_limit), 10)
coalesce(num_max(coalesce(retv["scores"], array())), 0)
num_max(coalesce(num_add(count(array(parts)), scalar(offset)), 0), 2, scalar(upper_limit))
num_gt(coalesce(num_add(scalar(depth), scalar(offset)), 0), 3)
```

## Flag-like scalar methods
Many practical rules keep one or more scalar flags that record readiness, emptiness, or branch decisions.

Examples:

```text
declare(scalar, has_head=0)
assign(scalar(ready), and(is_nonempty(array(parts)), not(is_empty(scalar(name)))))
if(or(scalar(force), scalar(ready)))
```

Worked example:

```text
I {
  declare(array, parts)
  declare(scalar, ready=0, force=0)
}

-> item {
  assign(scalar(ready), and(is_nonempty(array(parts)), not(is_empty(scalar(IMATCH)))))
  if(or(scalar(force), scalar(ready)))
    return(hash("kind", "READY", "parts", array_copy(array(parts))))
  else
    return(hash("kind", "WAITING", "parts", array_copy(array(parts))))
  endif
}
```

## Reading one scalar out of an aggregate
There are two important helper families here.

### One-step array/hash entry reads with `scalar(...)`

```text
scalar(array(items), 0)
scalar(hash(by_name), key)
scalar(items, 0)
scalar(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), 0)
scalar(merge_hash(hash(meta), hash("kind", "NODE")), "kind")
scalar(set_key(hash(meta), "stage", "normalized"), "stage")
scalar(rename_key(hash(meta), "old_stage", "stage"), "stage")
```

Use this when the read is conceptually one step:
- one array index,
- or one hash entry.

That one step can now start from:
- one direct working array,
- one direct working hash,
- one composed array-valued helper expression such as `sorted_keys(...)`,
- or one composed hash-valued helper expression such as `merge_hash(...)`, `set_key(...)`, `rename_key(...)`, `pick_keys(...)`, `drop_keys(...)`, or hash-valued `coalesce(...)`.

Examples:

```text
assign(scalar(head), scalar(array(items), 0))
assign(scalar(found), scalar(hash(by_name), key))
assign(scalar(first_key), scalar(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), 0))
assign(scalar(chosen_kind), scalar(merge_hash(hash(meta), hash("kind", "NODE")), "kind"))
assign(scalar(chosen_stage), scalar(set_key(hash(meta), "stage", "normalized"), "stage"))
assign(scalar(stage_after_rename), scalar(rename_key(hash(meta), "old_stage", "stage"), "stage"))
assign(scalar(fallback_part), scalar(coalesce(retv["parts"], array("fallback")), 0))
assign(scalar(fallback_kind), scalar(coalesce(retv["meta"], hash("kind", "fallback")), "kind"))
return(hash("head", scalar(items, 0)))
```

### Multi-step Nested Reads With Direct Access

```text
retv["content"]
tree[0]["kind"]
report["stats"]["count"]
```

Use this when the value lives inside a returned object or another nested aggregate.

Examples:

```text
assign(scalar(kind), retv["type"])
assign(scalar(count), report["stats"]["count"])
if(eq(retv["type"], "SPACE"))
```

## Array methods
Arrays are the main aggregate surface for:
- token lists,
- child-node accumulators,
- ordered payloads,
- normalized working buffers.

### Array constructors

```text
array()
array(scalar(name), scalar(kind))
array(hash("type", "WORD", "content", scalar(name)))
```

Examples:

```text
assign(array(parts), array())
assign(array(pair), array(scalar(lhs), scalar(rhs)))
return(array("?node:", scalar(name), scalar(kind)))
```

### Array snapshots

```text
array_copy(array(items))
```

Use this when you want one nested array payload that contains the current contents of an array variable. `array_values(array(items))` remains supported as the older compatibility spelling, but new examples should use `array_copy(...)`.

Examples:

```text
return(array_copy(array(items)))
return(hash("items", array_copy(array(items))))
push_value(array(nodes), array_copy(array(keyval_pairs)))
```

### Pure array layering with `concat_arrays(...)`
`concat_arrays(...)` is the pure array-valued helper for “take these array sources and build one combined array value from them”.

Examples:

```text
concat_arrays(array(parts), array("tail"))
concat_arrays(array(parts), sorted_keys(hash(meta)))
concat_arrays(array(parts), take(sorted_keys(hash(meta)), 2), array("tail"))
concat_arrays(
  coalesce(retv["parts"], array("fallback")),
  take(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 1),
  array("done")
)
```

Use cases:
- add one literal suffix array onto one working array,
- combine one working array with one projected array like `sorted_keys(...)`,
- keep array construction/update pure instead of mutating one staging array with repeated `push_value(...)`,
- or build one canonical array for `declare(...)`, `assign(...)`, `return(...)`, `count(...)`, `contains(...)`, and later slicing helpers.

Examples in context:

```text
declare(array, combined=concat_arrays(array(parts), sorted_keys(hash(meta)), array("tail")))
assign(array(combined), concat_arrays(array(parts), take(sorted_keys(hash(meta)), 2), array("tail")))
return(hash("combined", concat_arrays(array(parts), sorted_keys(hash(meta)))))
assign(scalar(combined_count), count(concat_arrays(array(parts), sorted_keys(hash(meta)))))
assign(scalar(first_combined), scalar(concat_arrays(array(parts), take(sorted_keys(hash(meta)), 2)), 0))
```

Important semantic notes:
- `concat_arrays(...)` always returns one array value,
- it accepts one or more array-valued operands,
- supported operands include direct working arrays, `array(...)`, `sorted_keys(...)`, `sorted_values(...)`, array slicing helpers such as `take(...)` / `take_last(...)` / `drop_front(...)` / `drop_back(...)`, and array-valued `coalesce(...)`,
- items are appended from left to right,
- undefined array-valued operands contribute nothing,
- and if you want one nested array snapshot of one working array rather than a layered concatenation, `array_copy(...)` is usually the better tool.

### Defaulting aggregate values with `coalesce(...)`
`coalesce(...)` also works when the values are aggregate refs rather than plain scalars.

Examples:

```text
coalesce(retv["parts"], array("empty"))
coalesce(retv["meta"], hash("kind", "fallback"))
```

That is useful when:
- a child payload may or may not provide one structured field,
- but the current rule still wants a canonical array/hash value to return downstream.

When you need to branch on presence rather than build a fallback value immediately, pair that with `is_defined(...)` or `is_undefined(...)`:

```text
if(is_defined(retv["parts"]))
if(is_undefined(retv["meta"]))
```

### Aggregate size as a scalar with `count(...)`
`count(...)` is the parser-oriented reducer for “how many items does this array currently have?”

Examples:

```text
count(array(parts))
count(coalesce(retv["parts"], array("empty")))
count(array("a", "b", "c"))
```

Use cases:
- store one working array size in a scalar,
- branch on array size with `num_*` helpers,
- return size metadata in one canonical payload field.

Examples in context:

```text
assign(scalar(part_count), count(array(parts)))
assign(scalar(part_count), count(coalesce(retv["parts"], array("empty"))))
return(hash("part_count", count(array(parts))))
if(num_gt(count(array(parts)), 0))
```

Important semantic note:
- `count(...)` is about array size,
- not about string length,
- and if an array-valued expression is still undefined, `count(...)` falls back to `0`.

### Array boundary values as scalars with `first(...)` and `last(...)`
`first(...)` and `last(...)` are the parser-oriented reducers for “what is the first item?” and “what is the last item?” when the source is one array or one array-valued helper expression.

Examples:

```text
first(array(parts))
last(array(parts))
first(sorted_keys(hash(meta)))
last(sorted_values(pick_keys(hash(meta), "kind", "source")))
first(coalesce(retv["parts"], array("fallback")))
```

Use cases:
- store one boundary item from a working array in a scalar,
- branch on the first normalized key or the last normalized value of a projected aggregate,
- return one canonical summary payload without introducing temporary loop logic.

Examples in context:

```text
assign(scalar(first_part), first(array(parts)))
assign(scalar(first_key), first(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(scalar(last_value), last(sorted_values(pick_keys(hash(meta), "kind", "source", "stage"))))
return(hash("first_key", first(sorted_keys(hash(meta))), "last_value", last(sorted_values(hash(meta)))))
if(eq(first(sorted_keys(drop_keys(hash(meta), "debug"))), "kind"))
```

Important semantic note:
- `first(...)` and `last(...)` preserve the array-oriented meaning of boundary access,
- they work on both working arrays and composed array-valued helper expressions,
- and if an array-valued expression is still undefined or empty, both helpers return `undef`.

### First-match scalar indices with `index_of(...)`
`index_of(...)` is the parser-oriented helper for “where is the first matching item in this array-shaped value?” when the source is one array or one array-valued helper expression.

Examples:

```text
index_of(array(parts), "kind")
index_of(sorted_keys(hash(meta)), "kind")
index_of(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), "normalized")
index_of(concat_arrays(array(parts), array("tail")), "tail")
index_of(coalesce(retv["parts"], array("fallback")), scalar(IMATCH))
```

Use cases:
- store one first-match location from a working array in a scalar,
- branch on whether one projected key list starts with `kind` at index `0`,
- derive one canonical location from one normalized array before later slicing or boundary extraction,
- and keep first-match lookup in the DSL instead of dropping into host-language loops or `for` scans.

Examples in context:

```text
assign(scalar(kind_index), index_of(array(parts), "kind"))
assign(scalar(kind_index), index_of(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), "kind"))
assign(scalar(stage_index), index_of(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), "normalized"))
return(hash(
  "kind_index", index_of(sorted_keys(hash(meta)), "kind"),
  "stage_index", index_of(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), "normalized")
))
if(is_defined(index_of(sorted_keys(hash(meta)), "kind")))
if(num_eq(index_of(sorted_keys(hash(meta)), "kind"), 0))
```

Important semantic notes:
- `index_of(...)` returns one scalar index using the same zero-based model as `scalar(array_expr, 0)`,
- if the first match is at the first position, the result is `0`,
- when no match exists, the result is `undef`,
- when the source expression is undefined or not array-valued, the result is `undef`,
- when the needle is `undef`, `index_of(...)` looks for the first undefined array item,
- and `index_of(...)` complements `contains(...)`: use `contains(...)` for yes/no membership, use `index_of(...)` when you need the actual location.

### Drop the front array prefix with `drop_front(...)`
`drop_front(...)` is the parser-oriented helper for “give me the rest of this array after the first element”, and `drop_front(array_expr, drop_count)` extends that to “give me the rest after the first `N` elements”. `tail(...)` remains supported as a compatibility alias for the same lowering contract, but new specs should prefer `drop_front(...)` because the name says exactly which edge is being removed.

Examples:

```text
drop_front(array(parts))
drop_front(array(parts), 2)
drop_front(sorted_keys(hash(meta)))
drop_front(sorted_keys(hash(meta)), scalar(skip_count))
drop_front(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")))
drop_front(coalesce(retv["parts"], array("fallback")))
```

Use cases:
- keep one leading item in one scalar while carrying the remaining items as one canonical array value,
- express recursive leading-item/rest decomposition in `.spec` without raw Perl slicing,
- skip the first `N` projected keys or values after some earlier parse step has already consumed them,
- skip one projected key/value and keep processing the remainder through the same aggregate helper family.

Examples in context:

```text
assign(array(rest_parts), drop_front(array(parts)))
assign(array(rest_parts), drop_front(array(parts), 2))
assign(array(rest_keys), drop_front(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(array(rest_keys), drop_front(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(skip_count)))
assign(scalar(rest_count), count(drop_front(sorted_keys(hash(meta)))))
return(hash("rest_parts", drop_front(array(parts)), "rest_keys", drop_front(sorted_keys(hash(meta)))))
if(num_gt(count(drop_front(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0))
```

Worked example:

```text
I {
  declare(array, keys, rest_keys)
  declare(scalar, first_key, skip_count=2, rest_count=0)
}

-> header[1] {
  assign(array(keys), sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")))
  assign(scalar(first_key), first(array(keys)))
  assign(array(rest_keys), drop_front(array(keys), scalar(skip_count)))
  assign(scalar(rest_count), count(array(rest_keys)))
  return(
    hash(
      "first_key", scalar(first_key),
      "rest_keys", array_copy(array(rest_keys)),
      "rest_count", scalar(rest_count)
    )
  )
}
```

Important semantic note:
- `drop_front(array_expr)` defaults to dropping `1` entry when no explicit count is supplied,
- `drop_front(...)` returns one array value, not one scalar,
- it works on both direct working arrays and composed array-valued helper expressions,
- an explicit `drop_count` can be a literal like `2` or one scalar-valued expression such as `scalar(skip_count)`,
- `tail(array_expr)` and `tail(array_expr, drop_count)` are compatibility aliases for the same lowering contract,
- a one-element source becomes one empty array,
- an empty source becomes one empty array,
- a source shorter than the requested drop count also becomes one empty array,
- and an undefined array-valued expression also becomes one empty array rather than `undef`.

### Array prefix as an array with `take(...)`
`take(...)` is the parser-oriented helper for “give me the first part of this array”, and `take(array_expr, take_count)` extends that to “give me the first `N` elements as one canonical array value”.

Examples:

```text
take(array(parts))
take(array(parts), 2)
take(sorted_keys(hash(meta)))
take(sorted_keys(hash(meta)), scalar(take_count))
take(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")))
take(coalesce(retv["parts"], array("fallback")))
```

Use cases:
- keep one bounded prefix array while another part of the rule handles the remainder,
- preserve the first few normalized keys or values as one summary array in a return payload,
- express “take the first `N` tokens/items” without raw Perl slicing,
- and keep array-prefix work composable with `count(...)`, `scalar(container, index)`, `join_values(...)`, `if(...)`, and `switch(...)`.

Examples in context:

```text
assign(array(first_parts), take(array(parts)))
assign(array(first_parts), take(array(parts), 2))
assign(array(first_keys), take(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(array(first_keys), take(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(take_count)))
assign(scalar(first_count), count(take(sorted_keys(hash(meta)), 2)))
return(hash("first_parts", take(array(parts)), "first_keys", take(sorted_keys(hash(meta)), 2)))
if(num_gt(count(take(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0))
```

Worked example:

```text
I {
  declare(array, keys, first_keys)
  declare(scalar, take_count=2, first_count=0)
}

-> header[1] {
  assign(array(keys), sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")))
  assign(array(first_keys), take(array(keys), scalar(take_count)))
  assign(scalar(first_count), count(array(first_keys)))
  return(
    hash(
      "first_keys", array_copy(array(first_keys)),
      "first_count", scalar(first_count),
      "first_key", scalar(array(first_keys), 0)
    )
  )
}
```

Important semantic note:
- `take(array_expr)` defaults to keeping `1` entry when no explicit count is supplied,
- `take(...)` returns one array value, not one scalar,
- it works on both direct working arrays and composed array-valued helper expressions,
- an explicit `take_count` can be a literal like `2` or one scalar-valued expression such as `scalar(take_count)`,
- a source shorter than the requested take count returns the whole source as one array,
- a non-positive take count returns one empty array,
- and an undefined array-valued expression also becomes one empty array rather than `undef`.

### Keep the trailing array suffix with `take_last(...)`
`take_last(...)` is the parser-oriented helper for “give me the last part of this array”, and `take_last(array_expr, take_last_count)` extends that to “keep the last `N` elements as one canonical array value”.

Examples:

```text
take_last(array(parts))
take_last(array(parts), 2)
take_last(sorted_keys(hash(meta)))
take_last(sorted_keys(hash(meta)), scalar(take_last_count))
take_last(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")))
take_last(coalesce(retv["parts"], array("fallback")))
```

Use cases:
- keep a trailing suffix array while earlier parsing logic has already consumed or summarized the leading part,
- preserve the final few normalized keys or values as one summary array in a return payload,
- express “take the last `N` tokens/items” without raw Perl slicing,
- and keep array-suffix work composable with `count(...)`, `scalar(container, index)`, `join_values(...)`, `if(...)`, and `switch(...)`.

Examples in context:

```text
assign(array(last_parts), take_last(array(parts)))
assign(array(last_parts), take_last(array(parts), 2))
assign(array(last_keys), take_last(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(array(last_keys), take_last(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(take_last_count)))
assign(scalar(last_count), count(take_last(sorted_keys(hash(meta)), 2)))
return(hash("last_parts", take_last(array(parts)), "last_keys", take_last(sorted_keys(hash(meta)), 2)))
if(num_gt(count(take_last(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0))
```

Worked example:

```text
I {
  declare(array, keys, last_keys)
  declare(scalar, take_last_count=2, last_count=0)
}

-> header[1] {
  assign(array(keys), sorted_keys(pick_keys(hash(meta), "kind", "source", "stage", "owner")))
  assign(array(last_keys), take_last(array(keys), scalar(take_last_count)))
  assign(scalar(last_count), count(array(last_keys)))
  return(
    hash(
      "last_keys", array_copy(array(last_keys)),
      "last_count", scalar(last_count),
      "first_suffix_key", scalar(array(last_keys), 0)
    )
  )
}
```

Important semantic note:
- `take_last(array_expr)` defaults to keeping `1` trailing entry when no explicit count is supplied,
- `take_last(...)` returns one array value, not one scalar,
- it works on both direct working arrays and composed array-valued helper expressions,
- an explicit `take_last_count` can be a literal like `2` or one scalar-valued expression such as `scalar(take_last_count)`,
- a source shorter than the requested count returns the whole source as one array,
- a non-positive count returns one empty array,
- and an undefined array-valued expression also becomes one empty array rather than `undef`.

### Literal string rewrite with `replace_substr(...)`
`replace_substr(...)` is the parser-oriented helper for “take this scalar-like value and replace every literal occurrence of one substring with another substring”.

Examples:

```text
replace_substr(scalar(name), "-", "_")
replace_substr(lowercase(trim(scalar(name))), " ", "_")
replace_substr(coalesce(retv["kind"], scalar(IMATCH)), "::", ".")
replace_substr(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "-", "_")
```

Use it when:
- one rule wants canonical separator cleanup without raw host-language `s///` code,
- one rule wants to normalize parser-facing names like `Node-Item` into `node_item`,
- one rule wants to make one fallback payload field more machine-friendly before comparing or returning it,
- or you want to keep one literal rewrite inside the same composable value-expression layer as `trim(...)`, `lowercase(...)`, `coalesce(...)`, `starts_with(...)`, and `contains_substr(...)`.

Worked example:

```text
normalized_name:
 -> /\w+(?:[- ]\w+)*/
 => Top {
      declare(scalar, raw_name, normalized_name, normalized_kind)

      assign(scalar(raw_name), coalesce(retv["name"], scalar(IMATCH), ""))
      assign(scalar(normalized_name), replace_substr(lowercase(trim(scalar(raw_name))), "-", "_"))
      assign(scalar(normalized_kind), replace_substr(lowercase(trim(coalesce(retv["kind"], "node type"))), " ", "_"))

      return(hash(
        "raw_name", scalar(raw_name),
        "normalized_name", scalar(normalized_name),
        "normalized_kind", scalar(normalized_kind)
      ))
    }
```

Representative shorter patterns:

```text
assign(scalar(normalized_name), replace_substr(lowercase(trim(scalar(name))), "-", "_"))
assign(scalar(normalized_kind), replace_substr(lowercase(trim(coalesce(retv["kind"], scalar(IMATCH)))), " ", "_"))
return(hash("normalized_name", replace_substr(lowercase(trim(scalar(name))), "-", "_")))
if(eq(replace_substr(lowercase(trim(scalar(name))), "-", "_"), "node_item"))
if(starts_with(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "node_"))
if(contains_substr(replace_substr(lowercase(trim(scalar(name))), "-", "_"), "item"))
```

Semantic notes:
- `replace_substr(...)` is a literal substring rewrite helper, not a regex helper,
- all three operands must be defined or the result stays `undef`,
- an empty needle leaves the source value unchanged,
- and the helper stays pure, so you can nest it as deeply as needed inside other scalar helpers and flow comparisons.

### Literal boundary cleanup with `rm_prefix(...)` and `rm_suffix(...)`
`rm_prefix(...)` and `rm_suffix(...)` are the parser-oriented helpers for “remove this literal prefix if present” and “remove this literal suffix if present”.

Examples:

```text
rm_prefix(lowercase(trim(scalar(name))), "node_")
rm_suffix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "_end")
rm_prefix(coalesce_nonempty(trim(retv["type"]), scalar(IMATCH), "raw_word"), "raw_")
rm_suffix(concat(lowercase(trim(scalar(name))), "_", scalar(stage)), "_draft")
```

Useful when:
- one rule wants to strip a known parser-facing marker such as `node_`, `raw_`, or `tmp_`,
- one rule wants to strip a known trailing marker such as `_end`, `_draft`, or `_tail`,
- you want to keep boundary cleanup inside the same composable value-expression layer as `trim(...)`, `replace_substr(...)`, `concat(...)`, and `coalesce_nonempty(...)`,
- you want the cleanup to be pure rather than mutation-oriented,
- or you want the same cleanup logic to feed assignments, returned metadata, and comparisons without branching.

Worked example:

```text
normalized_boundary_name:
 -> /\w+(?: \w+)*/
 => Top {
      declare(scalar, raw_name, underscored_name, core_name, base_name)

      assign(scalar(raw_name), coalesce(retv["name"], scalar(IMATCH), ""))
      assign(scalar(underscored_name), replace_substr(lowercase(trim(scalar(raw_name))), " ", "_"))
      assign(scalar(core_name), rm_prefix(scalar(underscored_name), "node_"))
      assign(scalar(base_name), rm_suffix(scalar(underscored_name), "_end"))

      return(hash(
        "raw_name", scalar(raw_name),
        "underscored_name", scalar(underscored_name),
        "core_name", scalar(core_name),
        "base_name", scalar(base_name)
      ))
    }
```

Representative shorter patterns:

```text
assign(scalar(core_name), rm_prefix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "node_"))
assign(scalar(base_name), rm_suffix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "_end"))
return(hash("core_name", rm_prefix(lowercase(trim(scalar(name))), "node_")))
if(eq(rm_prefix(lowercase(trim(scalar(name))), "node_"), "item_end"))
if(eq(rm_suffix(replace_substr(lowercase(trim(scalar(name))), " ", "_"), "_end"), "node_item"))
```

Semantic notes:
- both helpers are literal boundary transforms, not regex helpers,
- both operands must be defined or the result stays `undef`,
- an empty prefix or suffix leaves the source value unchanged,
- if the requested boundary is not present, the source value is returned unchanged,
- and the helpers stay pure, so you can nest them as deeply as needed inside other scalar helpers and flow comparisons.

### String boundary checks with `starts_with(...)`, `ends_with(...)`, `contains_substr(...)`, and `matches(...)`
These are the parser-oriented scalar helpers for “does this value begin with this prefix?”, “does it end with this suffix?”, “does it contain this substring anywhere?”, and “does it match this regex?”

Examples:

```text
starts_with(scalar(name), "pre")
ends_with(scalar(name), "fix")
contains_substr(scalar(name), "efi")
starts_with(lowercase(trim(scalar(name))), "node_")
ends_with(lowercase(trim(coalesce(retv["kind"], scalar(IMATCH)))), "_end")
contains_substr(lowercase(trim(coalesce(retv["kind"], scalar(IMATCH)))), "node")
matches(lowercase(trim(scalar(name))), /^node_/)
matches(uppercase(trim(coalesce(retv["kind"], scalar(IMATCH)))), /^[A-Z_]+$/)
```

Useful when:
- one rule wants a clear prefix/suffix decision without raw host-language string code,
- one rule wants a clear substring-membership decision without raw host-language `index(...) >= 0` code,
- one rule wants a regex-membership flag without dropping to ad hoc host-language `=~` code in assignments or return payloads,
- you want to keep normalization and boundary checking inside one nested value expression,
- you want to assign one reusable flag and return it later,
- or you want to branch on a prefix/suffix rule while staying inside the same method-like expression vocabulary.

Worked example:

```text
token_shape:
 -> /\w+/
 => Top {
      declare(scalar, raw_name, lowered_name, has_node_prefix, has_end_suffix, has_mid_node, is_wordish)

      assign(scalar(raw_name), coalesce(retv["name"], scalar(IMATCH), ""))
      assign(scalar(lowered_name), lowercase(trim(scalar(raw_name))))
      assign(scalar(has_node_prefix), starts_with(scalar(lowered_name), "node_"))
      assign(scalar(has_end_suffix), ends_with(scalar(lowered_name), "_end"))
      assign(scalar(has_mid_node), contains_substr(scalar(lowered_name), "node"))
      assign(scalar(is_wordish), matches(uppercase(trim(coalesce(retv["kind"], scalar(IMATCH)))), /^[A-Z_]+$/))

      return(hash(
        "name", scalar(lowered_name),
        "has_node_prefix", scalar(has_node_prefix),
        "has_end_suffix", scalar(has_end_suffix),
        "has_mid_node", scalar(has_mid_node),
        "is_wordish", scalar(is_wordish)
      ))
    }
```

Representative shorter patterns:

```text
assign(scalar(has_node_prefix), starts_with(lowercase(trim(scalar(name))), "node_"))
assign(scalar(has_end_suffix), ends_with(lowercase(trim(scalar(name))), "_end"))
assign(scalar(has_mid_node), contains_substr(lowercase(trim(scalar(name))), "node"))
assign(scalar(is_wordish), matches(uppercase(trim(coalesce(retv["kind"], scalar(IMATCH)))), /^[A-Z_]+$/))
return(hash(
  "has_node_prefix", starts_with(lowercase(trim(scalar(name))), "node_"),
  "has_end_suffix", ends_with(lowercase(trim(scalar(name))), "_end"),
  "has_mid_node", contains_substr(lowercase(trim(scalar(name))), "node"),
  "is_wordish", matches(uppercase(trim(coalesce(retv["kind"], scalar(IMATCH)))), /^[A-Z_]+$/)
))
if(and(starts_with(lowercase(trim(scalar(name))), "node_"), contains_substr(lowercase(trim(scalar(name))), "node")))
if(matches(lowercase(trim(scalar(name))), /^node_/))
```

Semantic notes:
- all four helpers return scalar `1` or `0`,
- they compose directly with `trim(...)`, `lowercase(...)`, `uppercase(...)`, `coalesce(...)`, `scalar(...)`, and direct nested access,
- undefined main values return `0`,
- undefined prefix/suffix expressions return `0`,
- undefined substring needles return `0`,
- `matches(...)` is designed around the same regex literal surface already used by flow predicates, so `/.../flags` remains the standard spelling there too,
- and empty string prefixes/suffixes/substrings therefore still behave consistently once both sides are defined.

### Drop the trailing array suffix with `drop_back(...)`
`drop_back(...)` is the parser-oriented helper for “give me everything except the last part of this array”, and `drop_back(array_expr, drop_count)` extends that to “drop the last `N` elements as one canonical array transformation”. `drop_last(...)` remains supported as a compatibility alias for the same lowering contract, but new specs should prefer `drop_back(...)` because it mirrors `drop_front(...)`.

Examples:

```text
drop_back(array(parts))
drop_back(array(parts), 2)
drop_back(sorted_keys(hash(meta)))
drop_back(sorted_keys(hash(meta)), scalar(drop_count))
drop_back(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")))
drop_back(coalesce(retv["parts"], array("fallback")))
```

Use cases:
- strip one trailing delimiter, suffix token, or terminator from one array without raw Perl slicing,
- preserve the stable leading part of one projected key/value list while ignoring one trailing field,
- keep one normalized leading array summary in a return payload,
- and keep suffix-dropping fully composable with `count(...)`, `scalar(container, index)`, `join_values(...)`, `if(...)`, and `switch(...)`.

Examples in context:

```text
assign(array(leading_parts), drop_back(array(parts)))
assign(array(leading_parts), drop_back(array(parts), 2))
assign(array(leading_keys), drop_back(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage"))))
assign(array(leading_keys), drop_back(sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")), scalar(drop_count)))
assign(scalar(kept_count), count(drop_back(sorted_keys(hash(meta)), 2)))
return(hash("leading_parts", drop_back(array(parts)), "leading_keys", drop_back(sorted_keys(hash(meta)), 2)))
if(num_gt(count(drop_back(sorted_values(pick_keys(hash(meta), "kind", "source", "stage")), 2)), 0))
```

Worked example:

```text
I {
  declare(array, keys, leading_keys)
  declare(scalar, drop_count=1, kept_count=0)
}

-> header[1] {
  assign(array(keys), sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")))
  assign(array(leading_keys), drop_back(array(keys), scalar(drop_count)))
  assign(scalar(kept_count), count(array(leading_keys)))
  return(
    hash(
      "leading_keys", array_copy(array(leading_keys)),
      "kept_count", scalar(kept_count),
      "first_kept_key", scalar(array(leading_keys), 0)
    )
  )
}
```

Important semantic note:
- `drop_back(array_expr)` defaults to dropping `1` trailing entry when no explicit count is supplied,
- `drop_back(...)` returns one array value, not one scalar,
- it works on both direct working arrays and composed array-valued helper expressions,
- an explicit `drop_count` can be a literal like `2` or one scalar-valued expression such as `scalar(drop_count)`,
- `drop_last(array_expr)` and `drop_last(array_expr, drop_count)` are compatibility aliases for the same lowering contract,
- a source shorter than the requested drop count returns one empty array,
- a non-positive drop count keeps the whole source array,
- and an undefined array-valued expression also becomes one empty array rather than `undef`.

### Array membership as a scalar flag with `contains(...)`
`contains(...)` is the parser-oriented helper for “does this array currently contain this scalar value?”

Examples:

```text
contains(array(parts), "foo")
contains(sorted_keys(hash(meta)), "kind")
contains(coalesce(retv["parts"], array("empty")), scalar(IMATCH))
```

Use cases:
- store one working membership flag in a scalar,
- branch on whether one projected key/value list already contains a required item,
- return one canonical boolean-like metadata field about an array or projected array expression.

Examples in context:

```text
assign(scalar(has_kind), contains(sorted_keys(hash(meta)), "kind"))
assign(scalar(has_node_value), contains(sorted_values(pick_keys(hash(meta), "kind", "source")), "NODE"))
return(hash("has_match", contains(coalesce(retv["parts"], array("empty")), scalar(IMATCH))))
if(contains(sorted_keys(drop_keys(hash(meta), "debug")), "kind"))
```

Important semantic note:
- `contains(...)` is about exact array membership,
- it returns `1` or `0`,
- it works on both working arrays and array-valued helper expressions,
- and if an array-valued expression is still undefined, `contains(...)` falls back to `0`.

### Hash/object size as a scalar with `count_keys(...)`
`count_keys(...)` is the parser-oriented reducer for “how many keys does this hash/object currently have?”

Examples:

```text
count_keys(hash(meta))
count_keys(coalesce(retv["meta"], hash("kind", "fallback")))
count_keys(hash("kind", "NODE", "source", "Top"))
```

Use cases:
- store one working hash/object size in a scalar,
- branch on metadata richness with `num_*` helpers,
- return object-field count metadata in one canonical payload field.

Examples in context:

```text
assign(scalar(meta_key_count), count_keys(hash(meta)))
assign(scalar(meta_key_count), count_keys(coalesce(retv["meta"], hash("kind", "fallback"))))
return(hash("meta_key_count", count_keys(hash(meta))))
if(num_gt(count_keys(coalesce(retv["meta"], hash("kind", "fallback"))), 1))
```

Important semantic note:
- `count_keys(...)` is about hash/object key count,
- not about array size,
- and if a hash-valued expression is still undefined, `count_keys(...)` falls back to `0`.

### Hash/object key presence as a scalar flag with `has_key(...)`
`has_key(...)` is the parser-oriented helper for “does this object contain this key at all?”

Examples:

```text
has_key(hash(meta), "kind")
has_key(coalesce(retv["meta"], hash("kind", "fallback")), "kind")
has_key(hash("kind", "NODE", "source", "Top"), "source")
```

Use cases:
- store one working “has this field” flag in a scalar,
- branch on object shape instead of on one field value,
- return one canonical boolean-like metadata field about object structure.

Examples in context:

```text
assign(scalar(has_kind), has_key(hash(meta), "kind"))
assign(scalar(has_kind), has_key(coalesce(retv["meta"], hash("kind", "fallback")), "kind"))
return(hash("has_kind", has_key(hash(meta), "kind")))
if(has_key(coalesce(retv["meta"], hash("kind", "fallback")), "kind"))
```

Important semantic note:
- `has_key(...)` is about key existence,
- not about whether the current value stored at that key is defined,
- so it complements rather than replaces `is_defined(...)`.

That means:
- use `has_key(...)` when the parser is asking “does this shape include this field?”,
- use `is_defined(payload["field"])` when the parser is asking “is the resolved field value defined?”.

### Hash/object layering with `merge_hash(...)`
`merge_hash(...)` is the parser-oriented helper for “build one new object from several object layers.”

Examples:

```text
merge_hash(hash(meta), hash("stage", "normalized"))
merge_hash(coalesce(retv["meta"], hash("kind", "fallback")), hash("source", scalar(rule_name)))
merge_hash(hash(base_meta), hash(overrides), hash("kind", "NODE"))
```

Use cases:
- keep one original working hash untouched while building one normalized view,
- overlay canonical metadata fields after a fallback object has been chosen,
- compose hash/object construction the same way we already compose scalar and array expressions.

Examples in context:

```text
assign(hash(merged_meta), merge_hash(hash(base_meta), hash("stage", "normalized")))
assign(hash(merged_meta), merge_hash(coalesce(retv["meta"], hash("kind", "fallback")), hash("source", scalar(rule_name))))
return(merge_hash(hash(merged_meta), hash("meta_key_count", count_keys(hash(merged_meta)))))
if(has_key(merge_hash(hash(meta), hash("stage", "normalized")), "kind"))
```

Important semantic note:
- `merge_hash(...)` returns one new hash/object value,
- later arguments override earlier keys,
- undefined hash-valued expressions simply contribute no pairs,
- and the helper itself does not mutate the source hashes.

### Hash/object snapshotting with `hash_copy(...)`
`hash_copy(...)` is the parser-oriented helper for “take one hash/object snapshot right now as one nested value.”

Examples:

```text
hash_copy(hash(meta))
hash_copy(pick_keys(hash(meta), "kind", "source"))
hash_copy(merge_hash(hash(meta), hash("stage", "normalized")))
```

Use cases:
- keep one nested object snapshot inside one larger return payload,
- copy one normalized or projected object before later helper composition,
- and feed one copied object directly into `scalar(hash_expr, key)`, `count_keys(...)`, `has_key(...)`, or `is_nonempty(...)` without mutating the source hash.

Examples in context:

```text
assign(hash(snapshot_meta), hash_copy(hash(meta)))
assign(hash(snapshot_meta), hash_copy(pick_keys(hash(meta), "kind", "source")))
assign(scalar(kind_seen), scalar(hash_copy(hash(meta)), "kind"))
return(hash("meta", hash_copy(merge_hash(hash(meta), hash("stage", "normalized")))))
if(is_nonempty(hash_copy(hash(meta))))
```

Important semantic note:
- `hash_copy(...)` returns one new hash/object value,
- the source hash stays untouched unless you explicitly assign the result back,
- direct working hashes lower to one immediate snapshot,
- and composed hash-valued expressions are copied too so later helper composition sees one stable nested object value instead of a live working hash alias.

### Hash/object single-field updates with `set_key(...)`
`set_key(...)` is the parser-oriented helper for “build one new object by setting one field on top of one existing object value.”

Examples:

```text
set_key(hash(meta), "stage", "normalized")
set_key(merge_hash(hash(meta), hash("kind", "NODE")), "stage", uppercase(trim(coalesce(scalar(IMATCH), "normalized"))))
set_key(coalesce(retv["meta"], hash("kind", "fallback")), "source", scalar(rule_name))
```

Use cases:
- add one canonical metadata field after one base object has already been chosen,
- overwrite one specific field without wrapping that tiny change in one one-key `merge_hash(...)`,
- and feed one updated object directly into `has_key(...)`, `count_keys(...)`, `sorted_keys(...)`, or `scalar(hash_expr, key)`.

Examples in context:

```text
assign(hash(normalized_meta), set_key(hash(meta), "stage", "normalized"))
assign(hash(normalized_meta), set_key(merge_hash(hash(meta), hash("kind", "NODE")), "owner", scalar(rule_name)))
assign(scalar(chosen_stage), scalar(set_key(hash(meta), "stage", "normalized"), "stage"))
return(set_key(coalesce(retv["meta"], hash("kind", "fallback")), "source", scalar(rule_name)))
if(has_key(set_key(hash(meta), "stage", "normalized"), "stage"))
```

Important semantic note:
- `set_key(...)` returns one new hash/object value,
- the source hash stays untouched unless you explicitly assign the result back,
- undefined incoming hash-valued expressions behave like one empty base object,
- and the named key is always present on the returned object even when the assigned value resolves to `undef`.

### Hash/object single-field renames with `rename_key(...)`
`rename_key(...)` is the parser-oriented helper for “build one new object by moving one existing key to one new name.”

Examples:

```text
rename_key(hash(meta), "old_stage", "stage")
rename_key(set_key(hash(meta), "owner", scalar(rule_name)), "old_stage", "stage")
rename_key(merge_hash(hash(meta), hash("old_stage", "normalized")), "old_stage", "stage")
```

Use cases:
- normalize one incoming field name to one canonical field name before returning or branching,
- move one field without spelling one manual delete-plus-set sequence,
- and feed one renamed object directly into `has_key(...)`, `count_keys(...)`, `sorted_keys(...)`, or `scalar(hash_expr, key)`.

Examples in context:

```text
assign(hash(normalized_meta), rename_key(hash(meta), "old_stage", "stage"))
assign(hash(normalized_meta), rename_key(set_key(hash(meta), "owner", scalar(rule_name)), "old_stage", "stage"))
assign(scalar(stage_after_rename), scalar(rename_key(hash(meta), "old_stage", "stage"), "stage"))
return(rename_key(merge_hash(hash(meta), hash("old_stage", "normalized")), "old_stage", "stage"))
if(has_key(rename_key(hash(meta), "old_stage", "stage"), "stage"))
```

Important semantic note:
- `rename_key(...)` returns one new hash/object value,
- the source hash stays untouched unless you explicitly assign the result back,
- undefined incoming hash-valued expressions behave like one empty returned object,
- the rename happens only when the old key exists,
- and when the old key exists its value is moved to the new key while the old key is removed.

### Hash/object omission with `drop_keys(...)`
`drop_keys(...)` is the parser-oriented helper for “build one cleaned object by removing selected fields.”

Examples:

```text
drop_keys(hash(meta), "debug")
drop_keys(merge_hash(hash(meta), hash("stage", "normalized")), "debug", "span")
drop_keys(coalesce(retv["meta"], hash("kind", "fallback")), "raw_text")
```

Use cases:
- strip debug-only or transport-only fields before one canonical return,
- branch on one cleaned object shape without mutating the working hash,
- compose omission directly after one `merge_hash(...)` layer instead of allocating manual temporary hashes.

Examples in context:

```text
assign(hash(cleaned_meta), drop_keys(hash(meta), "debug", "span"))
assign(hash(cleaned_meta), drop_keys(merge_hash(hash(meta), hash("stage", "normalized")), "debug"))
return(drop_keys(merge_hash(hash(cleaned_meta), hash("meta_key_count", count_keys(hash(cleaned_meta)))), "debug"))
if(has_key(drop_keys(hash(meta), "debug"), "kind"))
```

Important semantic note:
- `drop_keys(...)` returns one new hash/object value,
- the source hash stays untouched unless you explicitly assign the result back,
- each listed key is removed if present,
- and if the incoming hash-valued expression is undefined, the helper returns one empty object.

### Array flattening and list-context insertion

```text
flat_array(IMATCH_LIST)
flat_array(items)
```

Use flattening when you want to splice array elements into a surrounding constructor rather than create one nested array payload.

Examples:

```text
return(array("?node:", flat_array(IMATCH_LIST)))
return(array("?pair:", scalar(lhs), flat_array(extra_items)))
```

### Array-processing pipelines
Array helpers are also composable, so an array often goes through several normalization stages before the final return.

Examples:

```text
split(array(parts), scalar(text), /,\s*/)
split_each(array(parts), /:/)
trim_each(array(parts))
filter_nonempty(array(parts))
```

Nested functional example:

```text
assign(array(parts), filter_match(uniq(uppercase_each(array(IMATCH_LIST))), /^A/))
```

That is a good example of aggregate composition feeding aggregate composition:
- `array(IMATCH_LIST)` is the starting collection,
- `uppercase_each(...)` transforms it,
- `uniq(...)` deduplicates it,
- `filter_match(...)` keeps the desired subset,
- and `assign(...)` stores the final array result.

## Hash methods
Hashes are the main aggregate surface for structured return objects and structured temporary state.

### Hash constructors

```text
hash("type", "IDENT", "content", scalar(name))
hash("kind", "node", "count", scalar(count))
hash("threshold", scalar(threshold), "confidence", scalar(confidence))
```

Examples:

```text
assign(hash(meta), hash("kind", "TOKEN", "content", scalar(IMATCH)))
return(hash("type", "SPACE", "content", scalar(IMATCH)))
return(hash("depth", scalar(depth), "limit", scalar(max_depth)))
```

### Hashes containing arrays

```text
hash("type", "LIST", "items", array_copy(array(items)))
hash("type", "NODE", "captures", array(scalar(a), scalar(b)))
```

Examples:

```text
return(hash("type", "ARGS", "parts", array_copy(array(parts))))
return(hash("type", "MATCH", "groups", array(flat_array(IMATCH_LIST))))
```

### Hashes containing nested hashes

```text
hash(
  "kind", "NODE",
  "meta", hash("depth", scalar(depth), "confidence", scalar(confidence))
)
```

Examples:

```text
return(hash(
  "type", "RESULT",
  "meta", hash("threshold", scalar(threshold), "confidence", scalar(confidence)),
  "content", retv["content"]
))
```

## Where scalar and aggregate composition may appear
The same value-building rules apply across several user-facing helper surfaces.

### In declarations

```text
declare(scalar, joined=join_values("", array(parts)))
declare(array, normalized=array(scalar(head), scalar(tail_head)))
declare(hash, meta=hash("kind", "node", "depth", scalar(depth)))
```

### In assignments

```text
assign(scalar(token), retv["content"])
assign(scalar(chosen_name), coalesce(retv["content"], scalar(IMATCH), "UNKNOWN"))
assign(array(parts), filter_match(uniq(uppercase_each(array(IMATCH_LIST))), /^A/))
assign(hash(meta), hash("head", scalar(items, 0), "content", retv["content"]))
```

### In `push_value(...)`

```text
push_value(array(nodes), hash("type", retv["type"], "content", retv["content"]))
push_value(array(words), join_values("", array(word)))
push_value(array(payloads), array_copy(array(parts)))
```

### In `return(payload)`

```text
return(hash("type", "NODE", "content", scalar(name)))
return(hash("type", "NODE", "content", coalesce(retv["content"], scalar(IMATCH), "UNKNOWN")))
return(array("?node:", scalar(name), array_copy(array(parts))))
return(hash("meta", hash("depth", scalar(depth)), "items", array_copy(array(items))))
```

### In conditions and control flow

```text
if(and(is_nonempty(array(parts)), eq(retv["type"], "WORD")))
switch(retv["type"])
```

Examples:

```text
if(and(is_nonempty(array(parts)), num_ge(scalar(confidence), 0.95)))
  return(hash("kind", "CONFIRMED", "parts", array_copy(array(parts))))
else
  return(hash("kind", "PENDING", "parts", array_copy(array(parts))))
endif
```

```text
switch(retv["type"])
  case("SPACE") {
    return_undef()
  }
  default {
    return(hash(
      "type", retv["type"],
      "content", retv["content"],
      "parts", array_copy(array(parts))
    ))
  }
endswitch
```

## Worked example: normalize a captured comma-separated field list
This is a good "string scalar plus array pipeline plus structured hash return" example.

```text
I {
  declare(array, parts)
  declare(scalar, raw, joined)
}

-> field_list[1] {
  assign(scalar(raw), CAPTURE)
  split(array(parts), scalar(raw), /,\s*/)
  trim_each(array(parts))
  filter_nonempty(array(parts))
  assign(scalar(joined), join_values(" | ", array(parts)))
  return(hash(
    "type", "FIELD_LIST",
    "raw", scalar(raw),
    "joined", scalar(joined),
    "parts", array_copy(array(parts))
  ))
}
```

What this example teaches:
- `CAPTURE` gives one string scalar,
- `split(...)`, `trim_each(...)`, and `filter_nonempty(...)` turn that scalar into an array,
- `join_values(...)` turns the normalized array back into one scalar summary,
- `return(hash(...))` combines both the scalar and aggregate views of the same data.

## Worked example: carry integer and float metadata without raw Perl
This is a good "numeric literals live happily inside the helper DSL" example.

```text
I {
  declare(scalar, depth=0, max_depth=8, threshold=0.75, confidence=0.98)
}

-> score[1] {
  if(and(num_lt(scalar(depth), scalar(max_depth)), num_ge(scalar(confidence), scalar(threshold))))
    return(hash(
      "kind", "PASS",
      "depth", scalar(depth),
      "limit", scalar(max_depth),
      "threshold", scalar(threshold),
      "confidence", scalar(confidence)
    ))
  else
    return(hash(
      "kind", "HOLD",
      "depth", scalar(depth),
      "limit", scalar(max_depth),
      "threshold", scalar(threshold),
      "confidence", scalar(confidence)
    ))
  endif
}
```

This is intentionally about:
- storing numeric values,
- comparing numeric values,
- and returning numeric values in structured payloads.

It is not trying to imply extra arithmetic helpers that the project has not standardized yet.

## Worked example: build nested arrays and hashes from child payloads
This is a good "array of hashes plus hash-with-array" example.

```text
I {
  declare(array, nodes, names)
  declare(scalar, retv)
}

-> child {
  assign(scalar(retv), call(child))
  push_value(array(nodes), hash(
    "type", retv["type"],
    "content", retv["content"]
  ))
  if(is_nonempty(retv["content"]))
    push_value(array(names), retv["content"])
  endif
}

-> Top[1] {
  return(hash(
    "type", "CHILDREN",
    "nodes", array_copy(array(nodes)),
    "names", array_copy(array(names))
  ))
}
```

What this example teaches:
- child results are captured canonically with `assign(scalar(retv), call(child))`,
- fields are read out of the child payload with direct nested access,
- hashes are pushed into one accumulator array,
- strings are pushed into another accumulator array,
- the final return wraps both arrays in one object payload.

## Worked example: parser-oriented defaulting with `coalesce(...)`
This example shows the most common coalescing pattern:
- prefer a returned field,
- then prefer the immediate match,
- then fall back to one explicit literal.

```text
I {
  declare(scalar, chosen_type, chosen_content)
}

-> child {
  assign(scalar(chosen_type), coalesce(retv["type"], "UNKNOWN"))
  assign(scalar(chosen_content), coalesce(retv["content"], scalar(IMATCH), "UNKNOWN"))
  return(hash(
    "type", scalar(chosen_type),
    "content", scalar(chosen_content),
    "parts", coalesce(retv["parts"], array("empty"))
  ))
}
```

What this example teaches:
- `coalesce(...)` keeps the rule expression-oriented,
- it avoids an extra ladder of marker-style fallback branches when the logic is just “pick the first defined value,”
- and it works for both scalar payload fields and aggregate payload fields.

## Worked example: normalize type/content text before returning
This is the common parser shape where one rule wants to:
- pick the best available source,
- trim it,
- normalize its casing,
- and return the normalized result.

```text
I {
  declare(scalar, chosen_type, chosen_content)
}

-> child[1] {
  assign(scalar(chosen_type), uppercase(trim(coalesce(retv["type"], "word"))))
  assign(scalar(chosen_content), lowercase(trim(coalesce(retv["content"], scalar(IMATCH), " UNKNOWN "))))
  return(hash(
    "type", scalar(chosen_type),
    "content", scalar(chosen_content)
  ))
}
```

What this example teaches:
- scalar normalization helpers compose directly with `coalesce(...)`,
- they stay inside the canonical value-expression surface,
- and they work naturally in assignment sources and returned payloads.

## Worked example: count fallback parts before returning
This is the common parser shape where one rule wants:
- one canonical array payload,
- one scalar count derived from it,
- and one size-based branch without raw host-language code.

```text
I {
  declare(scalar, part_count)
}

-> child[1] {
  assign(scalar(part_count), count(coalesce(retv["parts"], array("empty"))))
  if(num_gt(scalar(part_count), 1))
    return(hash(
      "kind", "MULTI_PART",
      "part_count", scalar(part_count),
      "parts", coalesce(retv["parts"], array("empty"))
    ))
  else
    return(hash(
      "kind", "SINGLE_PART",
      "part_count", scalar(part_count),
      "parts", coalesce(retv["parts"], array("empty"))
    ))
  endif
}
```

What this example teaches:
- `count(...)` turns an aggregate into one scalar metadata value,
- it composes directly with `coalesce(...)`,
- and it keeps array-size logic inside the same canonical method-expression layer.

## Worked example: hash/object fallback plus key-count metadata
This is the common parser shape where one rule wants:
- one canonical hash/object payload,
- one scalar key count derived from it,
- and one richness-based branch without raw host-language counting.

```text
-> metadata_summary[1] {
  declare(scalar, meta_key_count)
  assign(
    scalar(meta_key_count),
    count_keys(coalesce(retv["meta"], hash("kind", "fallback")))
  )

  if(num_gt(scalar(meta_key_count), 1))
    return(hash(
      "kind", "RICH_META",
      "meta_key_count", scalar(meta_key_count),
      "meta", coalesce(retv["meta"], hash("kind", "fallback"))
    ))
  else
    return(hash(
      "kind", "MIN_META",
      "meta_key_count", scalar(meta_key_count),
      "meta", coalesce(retv["meta"], hash("kind", "fallback"))
    ))
  endif
}
```

What this example teaches:
- `coalesce(...)` can default one missing hash/object payload to a canonical fallback object,
- `count_keys(...)` can reduce that whole hash/object to one scalar metadata value,
- the reduced scalar can drive the branch,
- and the original fallback object can still be returned unchanged alongside the metadata.

That is a good example of the LinkedSpec direction:
- keep the expression layer functional and composable,
- keep the semantics parser-oriented,
- and avoid dropping out to raw host-language counting just to ask one simple question about a returned object.

## Worked example: layer object metadata with `merge_hash(...)`
This is the pattern to use when a parser wants one canonical metadata object built from:
- a stable base layer,
- a possibly missing returned metadata layer,
- and one final normalization layer.

```text
-> metadata_layering[1] {
  declare(hash, base_meta=hash("kind", "NODE", "source", "rule"))
  declare(hash, merged_meta)

  assign(
    hash(merged_meta),
    merge_hash(
      hash(base_meta),
      coalesce(retv["meta"], hash("kind", "fallback")),
      hash("stage", "normalized")
    )
  )

  if(has_key(hash(merged_meta), "kind"))
    return(merge_hash(
      hash(merged_meta),
      hash("meta_key_count", count_keys(hash(merged_meta)))
    ))
  else
    return(hash("kind", "BROKEN_META"))
  endif
}
```

What this example teaches:
- `merge_hash(...)` layers whole object values the same way `coalesce(...)` layers scalar or aggregate fallbacks,
- the result can be stored in one working hash and reused later in the rule,
- `has_key(...)` can branch on the merged object shape,
- and `count_keys(...)` can derive summary metadata from that merged object without leaving the DSL.

## Worked example: drop noisy object fields before returning
This is the pattern to use when a parser wants to preserve one rich working object internally but expose one cleaner external payload.

```text
-> metadata_cleanup[1] {
  declare(hash, meta=hash("kind", "NODE", "debug", 1, "source", "rule", "span", "12:14"))
  declare(hash, cleaned_meta)

  assign(
    hash(cleaned_meta),
    drop_keys(
      merge_hash(hash(meta), hash("stage", "normalized")),
      "debug",
      "span"
    )
  )

  if(has_key(hash(cleaned_meta), "kind"))
    return(merge_hash(
      hash(cleaned_meta),
      hash("meta_key_count", count_keys(hash(cleaned_meta)))
    ))
  else
    return(hash("kind", "BROKEN_META"))
  endif
}
```

What this example teaches:
- `merge_hash(...)` can add canonical fields before cleanup,
- `drop_keys(...)` can remove transport/debug noise without mutating the original working hash,
- the cleaned object can still drive `has_key(...)` and `count_keys(...)`,
- and the whole normalization story stays inside the same parser-oriented expression layer.

## Worked example: project one canonical object shape with `pick_keys(...)`
This is the pattern to use when the parser keeps one richer working object internally but wants to expose only one small, stable public shape.

```text
-> metadata_projection[1] {
  declare(hash, meta=hash("kind", "NODE", "debug", 1, "source", "rule", "span", "12:14"))
  declare(hash, projected_meta)

  assign(
    hash(projected_meta),
    pick_keys(
      merge_hash(hash(meta), hash("stage", "normalized")),
      "kind",
      "source",
      "stage"
    )
  )

  if(has_key(hash(projected_meta), "kind"))
    return(merge_hash(
      hash(projected_meta),
      hash("meta_key_count", count_keys(hash(projected_meta)))
    ))
  else
    return(hash("kind", "BROKEN_META"))
  endif
}
```

What this example teaches:
- `pick_keys(...)` is the positive-selection companion to `drop_keys(...)`,
- it keeps one explicit field set instead of removing one blacklist of fields,
- the projected object can still feed `has_key(...)` and `count_keys(...)`,
- and whole-object projection stays inside the same parser-oriented expression layer without ad hoc host-language field copying.

## Worked example: derive one stable key list from a normalized object
This is the pattern to use when the parser wants one deterministic array summary of object shape instead of returning or inspecting the whole object directly.

```text
-> metadata_key_summary[1] {
  declare(hash, meta=hash("kind", "NODE", "debug", 1, "source", "rule", "span", "12:14"))
  declare(array, projected_keys)
  declare(scalar, key_count)

  assign(
    array(projected_keys),
    sorted_keys(
      pick_keys(
        merge_hash(hash(meta), hash("stage", "normalized")),
        "kind",
        "source",
        "stage"
      )
    )
  )

  assign(scalar(key_count), count(array(projected_keys)))

  if(num_gt(scalar(key_count), 0))
    return(hash(
      "kind", "KEY_SUMMARY",
      "key_count", scalar(key_count),
      "keys", array_copy(array(projected_keys))
    ))
  else
    return(hash("kind", "NO_KEYS"))
  endif
}
```

What this example teaches:
- `sorted_keys(...)` is the stable hash/object-to-array bridge,
- it pairs naturally with `pick_keys(...)` when only a public subset of fields matters,
- the returned order is deterministic lexical order rather than host hash iteration order,
- and the resulting array can immediately feed `count(...)`, `array_copy(...)`, or later array pipelines without leaving the DSL.

## Worked example: derive one stable value list from a normalized object
This is the pattern to use when the parser wants one deterministic array summary of object content rather than of object keys.

```text
-> metadata_value_summary[1] {
  declare(hash, meta=hash("kind", "NODE", "debug", 1, "source", "rule", "stage", "raw"))
  declare(array, projected_values)
  declare(scalar, value_count)

  assign(
    array(projected_values),
    sorted_values(
      pick_keys(
        merge_hash(hash(meta), hash("stage", "normalized")),
        "kind",
        "source",
        "stage"
      )
    )
  )

  assign(scalar(value_count), count(array(projected_values)))

  if(num_gt(scalar(value_count), 0))
    return(hash(
      "kind", "VALUE_SUMMARY",
      "value_count", scalar(value_count),
      "values", array_copy(array(projected_values))
    ))
  else
    return(hash("kind", "NO_VALUES"))
  endif
}
```

What this example teaches:
- `sorted_values(...)` is the stable value-list companion to `sorted_keys(...)`,
- it keeps deterministic ordering by sorting keys first and then projecting values,
- it pairs naturally with `pick_keys(...)` when only a public subset of fields should participate,
- and the resulting array can immediately feed `count(...)`, `array_copy(...)`, or later array pipelines without leaving the DSL.

## Worked example: canonicalize one composed array into lexical order
This is the pattern to use when the parser wants one deterministic array summary of already-array-shaped data rather than one deterministic projection out of a hash/object.

```text
-> ordered_name_parts[1] {
  declare(array, parts=array("beta", "alpha", "gamma"))
  declare(array, ordered_parts)
  declare(scalar, first_part, joined_parts)

  assign(
    array(ordered_parts),
    sorted(
      concat_arrays(
        array(parts),
        take(sorted_keys(hash("kind", "NODE", "source", "rule", "stage", "top")), 2),
        array("delta")
      )
    )
  )

  assign(scalar(first_part), scalar(array(ordered_parts), 0))
  assign(scalar(joined_parts), join_values("|", array(ordered_parts)))

  return(hash(
    "kind", "ORDERED_PARTS",
    "ordered_parts", array_copy(array(ordered_parts)),
    "first_part", scalar(first_part),
    "joined_parts", scalar(joined_parts)
  ))
}
```

What this example teaches:
- `sorted(...)` is the array-side deterministic ordering helper,
- it pairs naturally with `concat_arrays(...)` when one rule builds a list from several array-valued sources first,
- it works just as well on direct working arrays as on composed array-valued expressions,
- and the resulting array can immediately feed `scalar(array_expr, idx)`, `count(...)`, `join_values(...)`, `array_copy(...)`, or later array slices without leaving the DSL.

## Worked example: flip one composed array so the newest items come first
This is the pattern to use when the parser wants one pure “last-added-first” view without mutating the original array.

```text
-> newest_parts_first[1] {
  declare(array, parts=array("alpha", "beta", "gamma"))
  declare(array, newest_first)
  declare(scalar, first_visible, joined_view)

  assign(
    array(newest_first),
    reversed(
      concat_arrays(
        array(parts),
        take(sorted_keys(hash("kind", "NODE", "source", "rule", "stage", "top")), 2),
        array("tail")
      )
    )
  )

  assign(scalar(first_visible), scalar(array(newest_first), 0))
  assign(scalar(joined_view), join_values("|", array(newest_first)))

  return(hash(
    "kind", "NEWEST_FIRST",
    "newest_first", array_copy(array(newest_first)),
    "first_visible", scalar(first_visible),
    "joined_view", scalar(joined_view)
  ))
}
```

What this example teaches:
- `reversed(...)` is the pure array-side order-flip helper,
- it pairs naturally with `concat_arrays(...)` when one rule first assembles one larger list from several array-valued sources,
- it works on direct working arrays and composed array-valued expressions the same way,
- and the resulting array can immediately feed `scalar(array_expr, idx)`, `count(...)`, `join_values(...)`, `array_copy(...)`, or later `take(...)` / `drop_front(...)` slices without leaving the DSL.

## Worked example: key existence versus defined value
This is the pattern to use when the parser cares about object shape first and value definedness second.

```text
-> metadata_shape_check[1] {
  if(has_key(coalesce(retv["meta"], hash("kind", "fallback")), "kind"))
    return(hash(
      "kind", "HAS_KIND_KEY",
      "has_kind", has_key(coalesce(retv["meta"], hash("kind", "fallback")), "kind")
    ))
  elseif(is_defined(retv["kind"]))
    return(hash(
      "kind", "DEFINED_KIND_VALUE",
      "value", retv["kind"]
    ))
  else
    return(hash("kind", "NO_KIND_INFORMATION"))
  endif
}
```

What this example teaches:
- `has_key(...)` asks about the object’s field layout,
- `is_defined(...)` asks about the resolved field value,
- and the two questions should stay separate when the parser’s semantics care about both.

## Worked example: presence versus emptiness
This is the pattern to use when the parser needs to keep three states distinct:
- field is missing,
- field is present but empty,
- field is present and nonempty.

```text
-> child[1] {
  if(is_undefined(retv["content"]))
    return(hash("kind", "MISSING_CONTENT"))
  elseif(is_empty(retv["content"]))
    return(hash("kind", "EMPTY_CONTENT", "content", retv["content"]))
  else
    return(hash("kind", "HAS_CONTENT", "content", retv["content"]))
  endif
}
```

What this example teaches:
- `is_undefined(...)` is for true absence,
- `is_empty(...)` is for present-but-empty values,
- and the two should not be collapsed into one truthiness check.

## Worked example: array snapshot versus flatten
This distinction matters enough to show side by side.

### Snapshot form

```text
return(hash(
  "type", "GROUP",
  "items", array_copy(array(items))
))
```

Meaning:
- one hash payload,
- containing one nested array payload.

### Flatten form

```text
return(array(
  "?group:",
  flat_array(IMATCH_LIST)
))
```

Meaning:
- one array constructor,
- with the current list elements spliced directly into that constructor.

Use `array_copy(...)` when you want one nested aggregate value.
Use `flat_array(...)` or `flat_hash(...)` when you want list-context insertion into a surrounding constructor.

## Worked example: recursive list closeout with scalar head plus array tail
This is a classic mixed scalar-and-aggregate example.

```text
I {
  declare(array, word, tail)
  declare(scalar, retv, head, has_head)
}

-> parenthesis {
  if(is_nonempty(array(word)))
    if(is_empty(scalar(has_head)))
      assign(scalar(head), join_values("", array(word)))
      assign(scalar(has_head), 1)
    else
      push_value(array(tail), join_values("", array(word)))
    endif
    assign(array(word), array())
  endif

  assign(scalar(retv), call(parenthesis))
  if(is_empty(scalar(has_head)))
    assign(scalar(head), scalar(retv))
    assign(scalar(has_head), 1)
  else
    push_value(array(tail), scalar(retv))
  endif
}

-> parenthesis[1] {
  if(scalar(has_head))
    if(is_nonempty(array(tail)))
      return(array(scalar(head), array_copy(array(tail))))
    else
      return(array(scalar(head), undef))
    endif
  else
    return(array(undef))
  endif
}
```

What this example teaches:
- one scalar can remember the head,
- one array can accumulate the tail,
- `join_values(...)` turns the current word buffer into one scalar item,
- `array_copy(array(tail))` snapshots the tail into the final nested return payload.

## Worked example: switch on payload type and return structured aggregates
This shows scalar reads, hash payload reads, array snapshots, and branch-local composition all living together.

```text
I {
  declare(array, words)
  declare(scalar, retv)
}

-> child {
  assign(scalar(retv), call(child))
  switch(retv["type"]) {
    case("SPACE") {
      return_undef()
    }
    case("WORD") {
      push_value(array(words), retv["content"])
    }
    default {
      return(hash(
        "type", retv["type"],
        "content", retv["content"],
        "words", array_copy(array(words))
      ))
    }
  }
}
```

This is the same composition rule again:
- `switch(...)` branches on one scalar read,
- branch bodies build or append aggregate values,
- the default branch returns a structured hash containing both scalar fields and one nested array snapshot.

## Worked example: a deliberately deep Lisp-style composition
The point of this example is not that every rule should be this dense.
The point is that the DSL should not impose an explicit cap on this kind of composition.

```text
return(hash(
  "kind", "SUMMARY",
  "primary", hash(
    "name", join_values("", array(word)),
    "head", scalar(items, 0),
    "content", retv["content"]
  ),
  "normalized_preview", array(
    flat_array(IMATCH_LIST),
    join_values("", array(word))
  ),
  "detail", hash(
    "depth", scalar(depth),
    "confidence", scalar(confidence),
    "node", hash(
      "type", tree[0]["type"],
      "name", tree[0]["name"]
    )
  )
))
```

Whether you would keep a real rule this dense is a readability choice.
But semantically, this is exactly the kind of unrestricted helper composition the LinkedSpec project wants to allow.

If the expression becomes hard to read, prefer splitting it:
- declare a temporary scalar, array, or hash,
- assign one intermediate value,
- then return the final payload.

The language goal is "no explicit DSL composition ceiling," not "always write the deepest possible one-liner."

## Practical guidance
- Use `scalar(...)` when the thing you need next is one scalar value.
- Use direct nested access when you are following a nested path through a returned payload or nested aggregate.
- Use `array(...)` when you are constructing one array value.
- Use `hash(...)` when you are constructing one object/hash value.
- Use `array_copy(...)` when you want one nested array snapshot.
- Use `flat_array(...)` or `flat_hash(...)` when you want list-context insertion into a surrounding constructor.
- Use `join_values(...)` when an array becomes one scalar string.
- Use `num_*` helpers when you mean numeric comparison semantics rather than string comparison semantics.
- Keep dense compositions readable by introducing named temporary state with `declare(...)` and `assign(...)`.

## Related guides
- Value constructors and payload lowering: [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md)
- Assignment semantics: [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
- Declarations and initialized state: [`USER_GUIDE_ActionIR_DeclareMethod.md`](USER_GUIDE_ActionIR_DeclareMethod.md)
- Conditions and comparisons: [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md)
- Array-processing helper families: [`USER_GUIDE_ActionIR_ArrayPipeline.md`](USER_GUIDE_ActionIR_ArrayPipeline.md)
- Control-flow surfaces: [`USER_GUIDE_ActionIR_ControlFlow.md`](USER_GUIDE_ActionIR_ControlFlow.md)
