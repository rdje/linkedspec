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
- `count(...)`
- `contains(...)`
- `count_keys(...)`
- `sorted_keys(...)`
- `sorted_values(...)`
- `has_key(...)`
- `merge_hash(...)`
- `drop_keys(...)`
- `pick_keys(...)`
- `coalesce(...)`
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
- and that same supported flat-list equivalence is now regression-locked inside control-flow branch bodies too,
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

Method-DSL migration note:
- fluent and structured authoring are now regression-locked on supported `join_values(delimiter, array(...))` payload forms too,
- on both action-edge and lifecycle surfaces,
- and that same supported `join_values(...)` equivalence is now regression-locked inside control-flow branch bodies too,
- so string-join payload construction is part of the same equivalence contract as the rest of the method-like DSL surface.

## Scalar normalization helpers
These are parser-oriented scalar transforms:
- `trim(value)`
- `lowercase(value)`
- `uppercase(value)`

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
