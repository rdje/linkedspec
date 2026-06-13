# Declaration Helper Reference

This chapter is the public reference for LinkedSpec's declaration helper family.

Read [Action Model and Helper Surface](action-model-and-helper-surface.md) first if the helper-DSL direction is still new. Read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) after this chapter when you want the value expressions that can feed declaration initializers.

## Why declarations matter

Declarations are where a rule names its working state.

Older `.spec` action code often used raw Perl declarations:

```text
my @items;
my $retv;
my %meta;
```

The helper-oriented form is:

```text
declare(array, items);
declare(scalar, retv);
declare(hash, meta);
```

That looks small, but it is an important architectural boundary. `declare(...)` is a typed ActionIR node. Raw `my` is host-language code. The helper form tells LinkedSpec and future backends what kind of working value the rule is creating.

Use declaration helpers when the state is part of the parser action. Avoid raw declaration code in new examples.

## Canonical typed form

The preferred declaration shape is:

```text
declare(type, entry1, entry2, ...)
```

Supported `type` values:

| Type | Working value | Use it when |
| --- | --- | --- |
| `scalar` | one scalar slot | the rule needs one text value, number, flag, child return, or object reference. |
| `array` | one array slot | the rule needs to append, collect, sort, filter, or return a list. |
| `hash` | one hash/object slot | the rule needs named metadata, field lookup, or shaped object state. |

Examples:

```text
declare(scalar, retv);
declare(scalar, name, kind, has_head);
declare(array, items);
declare(array, word, tail);
declare(hash, meta);
declare(hash, by_name, seen);
```

Each entry must be a plain symbol name or an initialized entry of the form `name=expr`.

## Declaration aliases

Aliases exist for convenience and compatibility. They lower to the same typed declaration model.

| Alias | Equivalent canonical form |
| --- | --- |
| `declare_s(name, ...)` | `declare(scalar, name, ...)` |
| `declare_scalar(name, ...)` | `declare(scalar, name, ...)` |
| `declare_a(name, ...)` | `declare(array, name, ...)` |
| `declare_array(name, ...)` | `declare(array, name, ...)` |
| `declare_h(name, ...)` | `declare(hash, name, ...)` |
| `declare_hash(name, ...)` | `declare(hash, name, ...)` |

Examples:

```text
declare_s(retv, name);
declare_scalar(retv, name);
declare_a(items, captures);
declare_array(items, captures);
declare_h(meta, seen);
declare_hash(meta, seen);
```

For new public documentation, prefer the canonical `declare(type, ...)` form unless the example is explicitly teaching aliases or fluent chain compactness.

## Where declarations should live

Most shared rule state should be declared in the rule-entry lifecycle block:

```text
I {
  declare(array, items);
  declare(scalar, retv);
  declare(hash, meta);
}
```

`I { ... }` runs at rule-handler entry, before the rule's action-edge logic needs the working state. That makes it the clearest place for accumulators, child-result slots, flags, and metadata objects that multiple action edges will share.

Action-edge declarations are useful for short-lived scratch values:

```text
-> Token[0] {
  declare(scalar, normalized);
  assign(scalar(normalized), lowercase(trim(entry_text())));
  return(hash("kind", "token", "text", scalar(normalized)));
}
```

Use action-edge declarations only when the variable is local to that action body. If a later action edge or later lifecycle hook must read the value, declare it earlier in `I { ... }`.

Other lifecycle blocks such as `LS { ... }`, `LE { ... }`, `E { ... }`, `EX { ... }`, `IT { ... }`, and `LX { ... }` can contain helper statements too, but they are not the default home for shared declaration state. Use them only when the state truly belongs to that lifecycle moment. The exact firing point depends on the rule's handler shape, so `I { ... }` is the stable default for "this rule owns these working variables."

## Multiple declarations in one statement

You can declare several variables of the same type in one call:

```text
declare(array, items, captures);
declare(scalar, head, retv, has_head);
declare(hash, by_name, seen);
```

Use this for a compact rule-state preamble when the names are easy to scan.

Prefer separate statements when different groups have different purposes:

```text
I {
  declare(array, children);
  declare(array, diagnostics);
  declare(scalar, retv, child_kind);
  declare(hash, meta);
}
```

That reads better than one long list whose intent is hard to remember.

## Initialized declarations

You can initialize any declaration entry with:

```text
name=expr
```

Examples:

```text
declare(scalar, kind="node");
declare(scalar, active=1);
declare(scalar, normalized=lowercase(trim(entry_text())));
declare(array, items=array());
declare(array, parts=array(scalar(first), scalar(second)));
declare(hash, meta=hash("kind", "node", "source", "Node"));
```

Mixed initialized and uninitialized entries are supported:

```text
declare(scalar, has_head=0, head, retv);
declare(array, items=array(), diagnostics);
declare(hash, meta=hash("kind", "node"), seen);
```

Use initialized declarations when the startup value is obvious. If the initializer becomes dense, declare first and assign later.

Preferred for simple startup:

```text
I {
  declare(scalar, has_head=0);
}
```

Preferred for dense startup:

```text
I {
  declare(scalar, name);
  assign(scalar(name), coalesce_nonempty(trim(scalaref(retv, {name})), entry_text(), "anonymous"));
}
```

The second form gives the normalization policy its own line.

## Scalar initializer examples

Scalar declarations can initialize from literals, helper expressions, child payload fields, source-boundary helpers, and predicates.

Examples:

```text
declare(scalar, kind="word");
declare(scalar, text=trim(entry_text()));
declare(scalar, normalized=replace_substr(lowercase(trim(entry_text())), "-", "_"));
declare(scalar, content=scalaref(retv, {content}));
declare(scalar, has_kind=has_key(hash(meta), "kind"));
declare(scalar, item_count=count(array(items)));
declare(scalar, body_width=capture_slice_len());
```

Use scalar initializers for values that are naturally one slot:

- one child result such as `retv`
- one normalized string
- one numeric width or count
- one boolean-like flag
- one hash or array reference returned by a child rule

Example:

```text
I {
  declare(scalar, raw=entry_text());
  declare(scalar, normalized=lowercase(trim(scalar(raw))));
}
```

That is readable because both initializers are short. If the second expression grew into a longer fallback chain, split it into `declare(...)` plus `assign(...)`.

## Array initializer examples

Array declarations can initialize from array constructors and supported array-valued helpers.

Examples:

```text
declare(array, items=array());
declare(array, pair=array(scalar(lhs), scalar(rhs)));
declare(array, groups=entry_groups());
declare(array, keys=sorted_keys(hash(meta)));
declare(array, public_keys=take(sorted_keys(pick_keys(hash(meta), "kind", "source")), 2));
declare(array, merged=concat_arrays(array(items), array(extra_items), array("tail")));
declare(array, snapshot=array_copy(array(items)));
```

Use an array initializer when the rule should start with a known list.

Use `array()` for an explicit empty list:

```text
declare(array, items=array());
```

Use `array_copy(...)` when the initializer should snapshot an existing array-valued expression:

```text
declare(array, saved_items=array_copy(array(items)));
```

Use `assign(array(name), array())` to clear or reset a live array later. Do not redeclare a variable just to clear it.

```text
assign(array(items), array());
```

## Hash initializer examples

Hash declarations can initialize from hash constructors and supported hash-valued helpers.

Examples:

```text
declare(hash, meta=hash("kind", "node"));
declare(hash, meta=hash("kind", "node", "source", "Node", "line", entry_line()));
declare(hash, public_meta=pick_keys(hash(meta), "kind", "source"));
declare(hash, cleaned_meta=drop_keys(hash(meta), "debug", "span"));
declare(hash, normalized_meta=set_key(hash(meta), "stage", "normalized"));
declare(hash, merged_meta=merge_hash(hash(meta), hash("stage", "normalized")));
declare(hash, snapshot=hash_copy(hash(meta)));
```

Use a hash initializer when the rule's metadata shape is known at entry:

```text
I {
  declare(hash, meta=hash(
    "kind", "token",
    "source", "Token",
    "line", entry_line()
  ));
}
```

That is useful when every return path should include the same baseline metadata.

Use `assign(hash(name), hash())` or another hash-valued assignment to reset later:

```text
assign(hash(meta), hash("kind", "fallback"));
```

Do not redeclare to reset. Redeclaration is a lifetime decision, not a mutation operation.

## Initializer expression surface

Declaration initializers reuse the same expression language as `assign(...)`, `push_value(...)`, `return(...)`, and flow helpers.

Common initializer sources include:

| Source | Examples |
| --- | --- |
| Literals | `"node"`, `1`, `0` |
| Working values | `scalar(name)`, `array(items)`, `hash(meta)` |
| Source readers | `entry_text()`, `entry_group(0)`, `capture_slice()`, `cursor_pos()` |
| Child payload access | `scalaref(retv, {content})`, `scalaref(retv, {children}[0]{name})` |
| Constructors | `array(...)`, `hash(...)` |
| Aggregate helpers | `array_copy(...)`, `hash_copy(...)`, `sorted_keys(...)`, `pick_keys(...)`, `split_tagged_records(...)` |
| String helpers | `trim(...)`, `lowercase(...)`, `replace_substr(...)`, `concat(...)` |
| Numeric helpers | `count(...)`, `length(...)`, `num_add(...)`, `num_clamp(...)` |
| Predicate helpers | `is_nonempty(...)`, `has_key(...)`, `matches(...)` |
| Fallback helpers | `coalesce(...)`, `coalesce_nonempty(...)` |

Example:

```text
I {
  declare(scalar, clean_name=coalesce_nonempty(trim(entry_group(0)), "anonymous"));
  declare(array, clean_parts=entry_groups());
  lowercase_each(array(clean_parts));
  uniq(array(clean_parts));
  filter_match(array(clean_parts), /^[a-z_]+$/);
  declare(hash, meta=hash(
    "kind", "field_list",
    "name", scalar(clean_name),
    "part_count", count(array(clean_parts))
  ));
}
```

Use this power carefully. Nested initializers are useful, but a rule preamble should still be easy to scan.

## Fluent and structured forms

Declarations work in structured blocks:

```text
I {
  declare(array, parts);
  declare(scalar, raw);
}
```

They also work in method-chain style:

```text
/[A-Za-z_, ]+/ -> FieldList
  .declare(array, parts)
  .declare(scalar, raw)
  .assign(scalar(raw), entry_text())
  .split(array(parts), scalar(raw), /,/)
  .trim_each(array(parts))
  .filter_nonempty(array(parts))
  .return(hash("kind", "field_list", "fields", array_copy(array(parts))));
```

Structured blocks are usually better for substantial logic. Fluent chains are useful for compact helper-only sequences that stay readable.

Many helper calls also accept an optional leading scope token in chained forms. For declarations, that means a scoped chain can lower the same as an unscoped helper call:

```text
declare_a(Top, items)
declare_a(items)
```

Those forms are equivalent for lowering. Prefer the simplest form unless the surrounding method-chain style benefits from the scope token.

For the full story on fluent vs block equivalence across all constructs — including if/switch control flow in marker-style, inline-composite, and attached-block forms — see the [Fluent and Block Forms](fluent-and-block-forms.md) guide.

## Worked example: accumulator state

This rule declares shared state in `I { ... }`, fills it from child results, and returns one structured payload.

```text
List::AND
 I {
   declare(array, items);
   declare(scalar, retv);
 }
 Item
 Item
 -> List[0] {
   assign(scalar(retv), call(Item));
   push_value(array(items), scalar(retv));
 }
 -> List[1] {
   assign(scalar(retv), call(Item));
   push_value(array(items), scalar(retv));
   return(hash(
     "kind", "list",
     "items", array_copy(array(items)),
     "item_count", count(array(items))
   ));
 }
```

The declaration choices are deliberate:

- `items` is an array because it accumulates multiple child results.
- `retv` is a scalar because each child call returns one value at a time.
- Both are declared in `I { ... }` because both action edges need the same working state.

## Worked example: metadata baseline

This rule creates a baseline object and then updates it after reading a match.

```text
Token::AND
 I {
   declare(hash, meta=hash("kind", "token", "source", "Token"));
   declare(scalar, text);
 }
 /[A-Za-z_]+/
 -> Token[0] {
   assign(scalar(text), lowercase(trim(entry_text())));
   assign(hash(meta), set_key(hash(meta), "text", scalar(text)));
   assign(hash(meta), set_key(hash(meta), "text_length", length(scalar(text))));
   return(hash_copy(hash(meta)));
 }
```

The hash initializer states the always-present metadata. The later `assign(hash(meta), set_key(...))` statements state the branch-local updates.

## Worked example: dense initializer moved to assignment

This version is legal but harder to read:

```text
I {
  declare(scalar, name=coalesce_nonempty(trim(scalaref(retv, {name})), trim(entry_group(0)), "anonymous"));
}
```

For public examples, prefer:

```text
I {
  declare(scalar, name);
  assign(scalar(name), coalesce_nonempty(
    trim(scalaref(retv, {name})),
    trim(entry_group(0)),
    "anonymous"
  ));
}
```

The second version makes the fallback policy visible without hiding it inside the declaration line.

## Common mistakes

Avoid raw host-language declarations in new helper-first code:

```text
my @items;
my $retv;
my %meta;
```

Prefer:

```text
declare(array, items);
declare(scalar, retv);
declare(hash, meta);
```

Do not use a scalar declaration for a value you later treat as an array:

```text
declare(scalar, items);
push_value(array(items), scalar(retv));
```

Prefer:

```text
declare(array, items);
push_value(array(items), scalar(retv));
```

Do not redeclare to reset:

```text
declare(array, items);
```

Prefer:

```text
assign(array(items), array());
```

Do not pack unrelated state into one unreadable declaration line:

```text
declare(scalar, retv, head, has_head, raw, normalized, count, stage, message);
```

Prefer grouped declarations:

```text
declare(scalar, retv, head, has_head);
declare(scalar, raw, normalized);
declare(scalar, count, stage, message);
```

## Practical guidance

- Use `I { declare(...) }` for rule-owned working state that multiple action edges need.
- Use action-edge `declare(...)` for short-lived scratch values local to that action body.
- Use `scalar`, `array`, and `hash` types according to how the value will be used, not according to how it happens to be emitted today.
- Prefer `declare(type, ...)` in public docs; mention aliases when documenting compatibility or compact chains.
- Prefer initialized declarations when the initializer is short and obvious.
- Prefer `declare(...)` plus `assign(...)` when initialization has a long fallback or normalization chain.
- Reset live containers with `assign(array(name), array())` or `assign(hash(name), hash(...))`; do not redeclare for mutation.
- Keep declarations near the top of the rule or local action body so the reader sees the rule's working state before the transformations.

## Related chapters

- [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) documents the expression helpers that can feed declaration initializers.
- [Source Boundary Helper Reference](source-boundary-helper-reference.md) documents source readers such as `entry_text()`, `entry_group(...)`, `capture_slice()`, and `cursor_pos()`.
- [ActionIR Lowering Mental Model](actionir-lowering-mental-model.md) explains why helper declarations are preferable to raw host-language code.

## Deeper reference

For the full `declare`/`declare_s`/`declare_a`/`declare_h` contract catalog with type-system details and emitted-Perl lowering, see `USER_GUIDE_ActionIR_DeclareMethod.md` in the repo root.
