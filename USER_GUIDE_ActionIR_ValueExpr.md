# USER GUIDE - ActionIR `ValueExpr.pm`
This guide covers the assignment/value-expression behavior handled by `perl/LinkedSpec/ActionIR/ValueExpr.pm`.

If `MethodLowering.pm` gives you the building blocks, `ValueExpr.pm` explains how those building blocks are consumed by assignments and related value-based helper statements.
For exact DSL-to-Perl examples for every assignment shape, source form, and substitution helper discussed here, also read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

## What this module is responsible for
This is the guide you want when you need to understand:
- `assign(target, source)`
- special assignment sources such as `CAPTURE`, `IMATCH`, and `LMATCH`
- scalar/array/hash target resolution
- collection-entry access forms used in assignments
- raw pass-through expressions inside helper shells

Documentation note:
- assignment/value expressions may consume arbitrarily nested method composition in arguments,
- but this guide documents that capability with representative shapes rather than listing every nesting permutation.

## `assign(target, source)`
This is the canonical assignment helper.

### Scalar target

```text
assign(scalar(name), scalar(retv))
assign(scalar(content), CAPTURE)
assign(scalar(flag), or(scalar(on), scalar(off)))
assign(scalar(retv), call(child))
```

Use scalar assignment when you are storing:
- a child result,
- a capture substring,
- a boolean/computed expression,
- a joined string,
- a host expression such as `pos $$STRING`.

### Array target

```text
assign(array(items), array(scalar(retv)))
assign(array(word), array())
assign(array(rule), array(flat_array(semantic_annotations)))
```

Use array-target assignment when you want to replace the whole working array, not append one element.

Typical uses:
- reset an array to empty,
- seed it with a new one-element array,
- rebuild it from another list source.

### Hash target

```text
assign(hash(by_name), hash("kind", scalar(kind), "name", scalar(name)))
```

Use hash-target assignment when you want to replace a whole working hash.

## Special assignment sources
### `CAPTURE`

```text
assign(scalar(content), CAPTURE)
```

Use it when you want the substring between the parser's current boundary markers.
This is one of the most common structured replacements for raw capture code.

### `IMATCH`

```text
assign(scalar(token), IMATCH)
```

Use it when the current immediate regex match itself is the value you want.

### `LMATCH`

```text
assign(scalar(closing_token), LMATCH)
```

Use it when the closing-side/latest match is what you care about.

## Regex substitution helpers: `substr(...)` and `regex_subst(...)`
The lowering surface also supports canonical regex substitution helpers for scalar targets.

Supported aliases:
- `substr(target, pattern, replacement, flags)`
- `regex_subst(target, pattern, replacement, flags)`

These two forms lower through the same substitution path.

### Quoted-pattern example

```text
substr(scalar(c), "\\s*$", "", o)
```

Typical use:
- trim trailing whitespace,
- strip a prefix or suffix,
- normalize one scalar variable in place.

### Slash-pattern example

```text
substr(scalar(c), /^\"|\"$/, //, go)
```

This is useful when the regex is easier to read as a slash-delimited pattern/replacement pair.

### Alias form

```text
regex_subst(scalar(name), /\\s+/, "_", go)
```

Use whichever spelling reads more naturally in the rule. The semantic intent is the same: mutate one scalar target by applying a regex substitution.

### Practical examples

```text
assign(scalar(msi_lsi), join_values("", array(capt)));
substr(scalar(msi_lsi), /^\\s+|\\n\\s*|\\s+$/, //, goi)
```

```text
assign(scalar(variable_name), scalar(IMATCH));
substr(scalar(variable_name), /^\\$/, "", o)
```

This pattern is common when you first capture or assign a raw match value and then normalize it in place.

## Assignment from helper value expressions
Assignments can take the same value-expression family used elsewhere.

Examples:

```text
assign(scalar(flag), not(is_empty(scalar(name))))
assign(scalar(msi_lsi), join_values("", array(capt)))
assign(scalar(first_capt), scalar(array(capt), 0))
assign(scalar(token), scalaref(retv, {content}))
assign(scalar(retv), call(Leaf))
```

This is important because it means you do not need different assignment syntax for different source kinds. One `assign(...)` surface covers many cases.

## Assignment from raw pass-through expressions
Today, helper assignment shells can still carry raw host expressions when no dedicated helper exists yet.

Examples:

```text
assign(scalar(pos_begin), pos $$STRING)
assign(scalar(subprogram_statement_part), substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH))
```

This is practical and currently used, but it is **less backend-neutral** than a pure helper-only expression.

Use these forms when:
- there is no good helper yet,
- the expression is stable and easy to understand,
- you still want the outer assignment statement to remain canonical.

## Collection access in assignments
You can assign from collection entries without raw indexing syntax.

Examples:

```text
assign(scalar(head), scalar(submatchs, 0))
assign(scalar(first_capture), scalar(array(capt), 0))
assign(scalar(name), scalar(hash(by_name), key))
assign(scalar(object_name), scalaref(cur_object, [1]))
```

Use cases:
- read the first element of a working array,
- read a keyed value from a working hash,
- read from a nested structure returned by another rule.

## When to use `assign(...)` versus `push_value(...)`
### Use `assign(...)` when:
- you are replacing a scalar, array, or hash variable,
- you are resetting an array,
- you are keeping a child result in a named variable,
- you need a value later in the same block.

### Use `push_value(...)` when:
- you already have a final value,
- you want to append it to an array variable,
- you do not need to overwrite the whole target collection.

Example contrast:

```text
assign(scalar(retv), call(child));
push_value(array(items), scalar(retv))
```

The first line stores the result; the second appends it.

## Worked examples
### Example: canonical replacement for raw call-wrapper assignment
Old style:

```text
$retv = call(parenthesis)
```

Preferred style:

```text
assign(scalar(retv), call(parenthesis))
```

Why prefer the second form:
- it is explicit about the target kind,
- it stays inside the canonical helper surface,
- it is easier to map across backends.

### Example: reset a temporary word buffer

```text
assign(array(word), array())
```

This is the canonical way to replace raw Perl `@word = ()`.

### Example: keep the beginning position for a later substring capture

```text
assign(scalar(pos_begin), pos $$STRING)
```

This is a good example of a helper shell carrying a host expression. The outer assignment is canonical even though the inner expression is still Perl-flavored.

### Example: build a finalized scalar from token fragments

```text
assign(scalar(msi_lsi), join_values("", array(capt)))
```

This is preferable to raw `join("", @capt)` inside a raw assignment statement.

## Common mistakes
### Mistake: using `assign(array(items), scalar(retv))`
That is not the right shape for an array-target assignment.

Use this instead:

```text
assign(array(items), array(scalar(retv)))
```

### Mistake: using raw `$retv = call(rule)` in new helper flow
Prefer:

```text
assign(scalar(retv), call(rule))
```

### Mistake: using `array_copy(...)` or legacy `array_values(...)` when you only want to clear an array
For clearing, use:

```text
assign(array(items), array())
```

## Related guides
- Constructors and payload helpers: [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md)
- Boolean/comparison expressions: [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md)
