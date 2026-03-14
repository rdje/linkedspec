# USER GUIDE - ActionIR `MethodLowering.pm`
This guide covers the value-construction and general method lowering handled by `perl/LinkedSpec/ActionIR/MethodLowering.pm`.

This module is where many of the most important backend-neutral building blocks live.
For exact DSL-to-Perl examples for every constructor, selector, flattening helper, return helper, and compatibility surface mentioned here, also read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

Documentation note:
- nested method composition in arguments is intended to be supported with no fixed depth limit,
- but this guide uses representative examples only rather than enumerating every possible nesting combination.

## What this module is responsible for
In practical terms, this is the guide you want when you need to understand:
- `scalar(...)`
- `scalaref(...)`
- `array(...)`
- `hash(...)`
- `array_copy(...)`
- `array_values(...)` as a compatibility alias
- `flat(...)`, `flatten(...)`, `flat_array(...)`, `flat_hash(...)`
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
```

This is useful for array/hash entry lookup without falling back to raw Perl indexing syntax.

Examples:

```text
assign(scalar(first_item), scalar(items, 0))
assign(scalar(value), scalar(hash(by_name), key))
if(eq(scalar(items, 0), "?branch:")); ... endif()
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

This is one of the most important distinctions in the DSL.

### Use `array_copy(...)` when you want:
- an array payload,
- a nested arrayref-like value,
- a copy/snapshot of the current array contents.

### Do **not** use it when you want list insertion into a surrounding constructor.
For list insertion, use `flat_array(...)` or `flat(...)` instead.

## `flat(...)`, `flatten(...)`, `flat_array(...)`, `flat_hash(...)`
These helpers mean “splice this collection into the surrounding constructor.”

Examples:

```text
array("?subprogram_declaration:", flat_array(IMATCH_LIST))
hash(flat_hash(extra_pairs), "kind", "node")
array(flat_array(semantic_annotations))
```

Equivalent generic forms:

```text
array("?subprogram_declaration:", flat(array(IMATCH_LIST)))
hash(flat(hash(extra_pairs)), "kind", "node")
hash(flatten(hash(extra_pairs)), "kind", "node")
array(flatten(array(semantic_annotations)))
```

Use cases:
- inserting `@IMATCH_LIST` into a surrounding `array(...)`,
- inserting an existing hash's key/value pairs into a larger `hash(...)`,
- rebuilding list-shaped payloads without raw Perl `@array` / `%hash` insertion syntax.

The shorter `flat_array(...)` / `flat_hash(...)` spellings are just more direct aliases for the same idea.

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on supported `flat_array(...)` / `flat_hash(...)` payload forms too,
- on both action-edge and lifecycle surfaces,
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

Example:

```text
return(array("?node:", flat_array(IMATCH_LIST)))
```

This becomes the semantic equivalent of a constructor that directly inserts the match-list elements.

## `join_values(delimiter, array(name))`
Use `join_values(...)` when you want to combine array elements into a single scalar string.

Examples:

```text
join_values("", array(word))
join_values(", ", array(parts))
```

Typical uses:
- flushing a temporary character/token array into a final word,
- turning token arrays into diagnostics or normalized text fragments.

Examples in context:

```text
assign(scalar(word_text), join_values("", array(word)))
push_value(array(tail), join_values("", array(word)))
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
- Declarations: [`USER_GUIDE_ActionIR_DeclareMethod.md`](USER_GUIDE_ActionIR_DeclareMethod.md)
- Assignment and sources: [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
- Legacy/compatibility helpers: [`USER_GUIDE_ActionIR_Contracts.md`](USER_GUIDE_ActionIR_Contracts.md)
