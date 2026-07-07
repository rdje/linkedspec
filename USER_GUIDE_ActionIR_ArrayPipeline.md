# USER GUIDE - ActionIR `ArrayPipeline.pm`
This guide covers the composable array/string pipeline helpers lowered by `perl/LinkedSpec/ActionIR/ArrayPipeline.pm`.

Post-`SPEC-FORMAT-TERSE.8.3` / `.8.4` status:
- pipeline helper names remain current, but many examples in this root guide predate scalar-slot retirement,
- read `:name`, `assign(...)`, `declare(...)`, `array_copy(...)`, and short wrapper examples here as historical migration evidence,
- current authoring uses bare scalar reads such as `text`, `set(array(parts), [])` for aggregate resets, and `copy(array(parts))` for snapshots.

This is the guide to read when you want to tokenize, normalize, filter, or deduplicate array content without falling back to raw Perl `split`, `map`, or `grep` chains.
For exact DSL-to-Perl examples for every pipeline helper and its preferred/raw counterpart, also read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

## What this module is responsible for
The array pipeline surface currently includes:
- `split(array_target, scalar_source, delimiter?)`
- `split_each(array_target, delimiter)`
- `trim_each(array_target)`
- `filter_nonempty(array_target)`
- `lowercase_each(array_target)`
- `uppercase_each(array_target)`
- `uniq(array_target)`
- `filter_match(array_target, regex)`
- related array-valued `split_tagged_records(scalar_source, delimiter, tag, extra...)`

These helpers can be used in:
- direct method statements,
- method chains,
- nested functional composition.

Documentation note:
- nested method composition that uses these pipeline helpers is intended to work with no fixed depth limit,
- but this guide shows representative compositions only rather than an exhaustive nesting inventory.

## `split(array_target, scalar_source, delimiter?)`
Use `split(...)` to populate an array from a scalar source string.

Examples:

```text
split(array(parts), text, /\s*,\s*/)
split(array(tokens), subprogram_statement_part, /((?:\s*--.*\s*)+|\s*;\s*)/)
```

If you omit the delimiter, the default is a comma-ish splitter.

Typical use cases:
- comma-separated identifiers,
- block body tokenization,
- coarse initial chopping before a second normalization pass.

## `split_each(array_target, delimiter)`
Use `split_each(...)` when the array already exists and you want to split each element, flattening the results.

Examples:

```text
split_each(array(subprogram_statement_tokens), /^(\s+)/)
split_each(array(parts), /:/)
```

This is especially useful when one `split(...)` is not enough and you want a second tokenization stage without dropping into raw `map { split ... }` Perl.

## `trim_each(array_target)`
Use it to remove leading and trailing whitespace from every element.

Example:

```text
trim_each(array(parts))
```

Typical use case:
- you split a scalar into rough pieces and now want a normalized token list.

## `filter_nonempty(array_target)`
Use it to drop empty strings from the array.

Example:

```text
filter_nonempty(array(parts))
```

Common companion pattern:

```text
split(array(parts), text, /,/);
trim_each(array(parts));
filter_nonempty(array(parts))
```

## `lowercase_each(array_target)` and `uppercase_each(array_target)`
These normalize every element case-wise.

Examples:

```text
lowercase_each(array(parts))
uppercase_each(array(parts))
```

Typical use cases:
- case-insensitive normalization,
- building canonical keyword lists,
- preparing tokens before `uniq(...)` or `filter_match(...)`.

## `uniq(array_target)`
Use it to deduplicate array elements while preserving first-seen order.

Example:

```text
uniq(array(parts))
```

Typical use case:
- collect many keywords or identifiers, then reduce them to the unique set.

## `filter_match(array_target, regex)`
Use it to keep only elements matching a regex.

Examples:

```text
filter_match(array(parts), /^[A-Z_]+$/)
filter_match(array(items), /^\w+$/)
```

Typical use case:
- keep only identifiers,
- drop comments/noise fragments,
- constrain a normalized list to a category.

## `split_tagged_records(scalar_source, delimiter, tag, extra...)`
Use it when a scalar list should become repeated tagged payload rows.

Example:

```text
return(split_tagged_records(
  identifier_list,
  /\s*,\s*/o,
  "?constant_declaration:",
  subtype_indication,
  expression
))
```

This lowers to the traditional `map { [tag, item, extra...] } split ...` shape while keeping the source `.spec` in helper form. It is array-valued, so it can be returned directly, assigned into an array declaration, or composed anywhere an array-valued helper is accepted.

## Chained style
You can apply these helpers in chained form.

Example:

```text
I.split(array(parts), :text, /,/).trim_each(array(parts)).filter_nonempty(array(parts))
```

## Method-like DSL equivalence note
The representative normalization pipeline below is now part of the explicit method-like DSL support contract on both action-edge and lifecycle surfaces:

```text
split(array(parts), :args, /,\s*/)
split_each(array(parts), /:/)
trim_each(array(parts))
filter_nonempty(array(parts))
return(array_copy(array(parts)))
```

That matters because `split_each(...)` is often the point where a pipeline stops feeling like a trivial one-step cleanup and starts looking like real staged token normalization. The current contract is that fluent and structured authoring for that kind of multi-stage cleanup pipeline lower through the same canonical ActionIR path, with the same zero-fallback and zero-unresolved-helper expectations.

Worked fluent action-edge example:

```text
/a/ -> Top .declare(array, parts)
           .declare(scalar, args)
           .set(:args, "left:1, right:2")
           .split(array(parts), :args, /,\s*/)
           .split_each(array(parts), /:/)
           .trim_each(array(parts))
           .filter_nonempty(array(parts))
           .return(array_copy(array(parts)))
```

Equivalent structured action-edge example:

```text
/a/ -> Top {
  declare(array, parts)
  declare(scalar, args)
  args = "left:1, right:2"
  split(array(parts), :args, /,\s*/)
  split_each(array(parts), /:/)
  trim_each(array(parts))
  filter_nonempty(array(parts))
  return(array_copy(array(parts)))
}
```

Equivalent lifecycle example:

```text
LX {
  declare(array, parts)
  declare(scalar, args)
  args = "left:1, right:2"
  split(array(parts), :args, /,\s*/)
  split_each(array(parts), /:/)
  trim_each(array(parts))
  filter_nonempty(array(parts))
  return(array_copy(array(parts)))
}
```

Read that pipeline in order:
1. split the original scalar into coarse pieces,
2. split each surviving piece again,
3. trim whitespace from the flattened result,
4. remove empty entries,
5. return a snapshot array payload of the normalized list.

## Method-like DSL case-normalization/filter contract
The representative case-normalization/filter pipeline below is also part of the explicit method-like DSL support contract on both action-edge and lifecycle surfaces:

```text
parts = filter_match(uniq(uppercase_each(array(IMATCH_LIST))), /^A/)
lowercase_each(array(parts))
return(array_copy(array(parts)))
```

This matters because it exercises the “functional composition inside an assignment source, then continue with ordinary statements” shape that users tend to reach for in real cleanup flows. The current contract is that fluent and structured authoring for this pipeline lower through the same canonical ActionIR path, with the same zero-fallback and zero-unresolved-helper expectations.

Worked fluent action-edge example:

```text
/a/ -> Top .declare(array, parts)
           .set(array(parts), filter_match(uniq(uppercase_each(array(IMATCH_LIST))), /^A/))
           .lowercase_each(array(parts))
           .return(array_copy(array(parts)))
```

Equivalent structured action-edge example:

```text
/a/ -> Top {
  declare(array, parts)
  parts = filter_match(uniq(uppercase_each(array(IMATCH_LIST))), /^A/)
  lowercase_each(array(parts))
  return(array_copy(array(parts)))
}
```

Equivalent lifecycle example:

```text
LX {
  declare(array, parts)
  parts = filter_match(uniq(uppercase_each(array(IMATCH_LIST))), /^A/)
  lowercase_each(array(parts))
  return(array_copy(array(parts)))
}
```

Read that pipeline in order:
1. uppercase the incoming values so matching and deduplication happen on a normalized case surface,
2. remove duplicates,
3. keep only entries that match the target pattern,
4. lowercase the surviving values into the final canonical form,
5. return a snapshot array payload of the normalized result.

## Nested functional composition
You can also compose them functionally.

Example:

```text
filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)
```

This is useful when the logical pipeline reads better as a nested value.

## Worked examples
### Example: canonical token cleanup pipeline

```text
split(array(parts), :text, /,/);
trim_each(array(parts));
filter_nonempty(array(parts));
uniq(array(parts))
```

Meaning:
1. split the source text,
2. trim whitespace,
3. discard empty pieces,
4. deduplicate the survivors.

### Example: `vhdl::subprogram_body` style tokenization

```text
subprogram_statement_part = substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH);
split(array(subprogram_statement_tokens), :subprogram_statement_part, /((?:\s*--.*\s*)+|\s*;\s*)/);
split_each(array(subprogram_statement_tokens), /^(\s+)/);
filter_nonempty(array(subprogram_statement_tokens));
return(array("?subprogram_body:", flat_array(IMATCH_LIST), array_copy(array(subprogram_statement_tokens))))
```

Why this matters:
- it replaces a raw Perl tokenization pipeline,
- it keeps the transformation visible at the DSL level,
- it preserves the original semantics while moving closer to backend neutrality.

### Example: nested functional composition

```text
filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)
```

Read it inside-out:
1. take `array(parts)`,
2. uppercase each element,
3. remove duplicates,
4. keep only all-caps identifier-like strings.

## Recommendations
- Prefer the pipeline helpers over raw `split/map/grep` chains when a supported helper exists.
- Use stepwise statements when readability matters more than compactness.
- Use nested functional composition when you want one concise expression and the transform order is still obvious.
- Remember that pipeline helpers mutate the target array conceptually; they are not just passive value expressions.

## Related guides
- Value constructors and snapshots: [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md)
- Assignments and source expressions: [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
