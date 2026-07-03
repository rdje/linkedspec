# Declaration Helper Reference

This chapter records the legacy declaration helper family and the terse-format replacement policy.

> **Current policy.** New `.spec` files should not use `declare(...)`. Working variables auto-exist through the
> terse format, and kind is inferred from wrappers, helper argument positions, assignment targets, and direct RHS
> shape values. Use `name = value`, `items = []`, `meta = { ... }`, `items += value`, `meta[key] = value`,
> `set(...)`, and existing terse read positions instead.

Read [Action Model and Helper Surface](action-model-and-helper-surface.md) first if the helper-DSL direction is still new. Read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) after this chapter when you want the value expressions that can feed declaration initializers.

## Why declarations matter

Declarations are where a rule names its working state.

Older `.spec` action code often used raw Perl declarations:

```text
my @items;
my $retv;
my %meta;
```

The old helper-oriented form was:

```text
declare(array, items);
declare(scalar, retv);
declare(hash, meta);
```

That form replaced raw host-language declarations, but it is no longer the preferred authoring surface. The terse
format now gives the parser the same kind information through first use, assignment shape, and type-implying helper
positions. Avoid both raw declaration code and `declare(...)` in new examples.

## Declarations are optional: working variables auto-exist

You do **not** have to `declare(...)` a working variable before using it. A variable referenced through a typed wrapper — `scalar(NAME)` / `array(NAME)` / `hash(NAME)` — **auto-exists**: the engine supplies its declaration automatically, taking the kind from the wrapper (`scalar` → scalar, `array` → array, `hash` → hash). Both of these behave the same:

```text
# explicit declaration (still fully supported)
I { declare(scalar, count) }
-> Item[0] { set(scalar(count), num_add(coalesce(scalar(count), 0), 1)) }

# auto-existing — no declare needed
-> Item[0] { set(scalar(count), num_add(coalesce(scalar(count), 0), 1)) }
```

An auto-existing variable is a fresh **per-invocation** working value — one for each time the rule's handler runs — exactly like an explicit `declare(...)`. It is scoped to the rule and visible to every action edge and lifecycle block of that rule, and it does **not** carry state over from a previous parse or a previous recursive entry of the rule.

For aggregate wrappers, the single argument is a working-variable name token only when it is **bare**:

```text
array(items)
```

That reads the array/list working variable `items`. Likewise:

```text
hash(meta)
```

reads the hash/associative-array working variable `meta`. Quoted strings remain literal constructor payloads,
not working-variable aliases or scalar-indirect lookup. For example, `array("items")` constructs an array
payload containing `"items"`, and `hash("key", value)` constructs a hash field. Prefer direct shape literals
such as `["items"]`, `{ "key" => value }`, `[]`, and `{}` as the terse constructor forms in new examples.

### The wrapper is optional in a type-implying position

A working variable also auto-exists when it appears **bare** (without a `scalar()` / `array()` / `hash()` wrapper) in a helper position that already implies its kind. In those positions the wrapper is optional — each pair below is equivalent:

```text
# scalar target of set(...), legacy assign(...), and scalar operator assignment — the bare name is a scalar
set(scalar(count), match_group(0))
set(count, match_group(0))
count = match_group(0)

# array target of push_value(...) / push_nonempty(...) — the bare name is an array
push_value(array(items), match_group(0))
push_value(items, match_group(0))
items += match_group(0)

# hash target of set_key(...) and hash-index assignment — the bare name is a hash
set_key(meta, "text", match_group(0))
meta["text"] = match_group(0)
meta[cat("source", "_kind")] = scalar(kind)

# aggregate snapshot reads — the bare name is the aggregate being copied
return(array_copy(array(items)))
return(array_copy(items))
return(hash_copy(hash(meta)))
return(hash_copy(meta))
return(copy(items))

# scalar source-slot reads — the bare name is a scalar value
return(scalar(count))
return(count)
set(out, count)
name = value

# mutation key/RHS scalar reads — targets keep their array/hash kind
items += value
set_key(meta, key, value)
meta[key] = value

# direct-access path scalar reads — the bare path atom is a scalar array index
return(payload["children"][index]["name"])
```

The kind comes from the **position**: the target of `set(...)`, legacy `assign(...)`, and `name = value` is a scalar for non-shape RHS values; the target of `push_value(...)`, `push_nonempty(...)`, and `name += value` is an array; the target of `set_key(name, key, value)` and `name[key] = value` is a hash. Aggregate snapshot helpers are type-implying read positions: `array_copy(name)` reads the working array, `hash_copy(name)` reads the working hash, and `copy(name)` follows the current array-first rule. In supported scalar read slots, a bare name reads the working scalar: `return(count)`, `set(out, count)`, `out = count`, `items += value`, `set_key(meta, key, value)`, `meta[key] = value`, and direct path atoms such as `payload["children"][index]` are the terse forms of their explicit `scalar(...)` counterparts. Direct RHS shape assignment is the special case where the value's shape infers the target kind: `name = [value]` / `set(name, [value])` assigns an array working variable, and `name = { key => value }` / `set(name, { key => value })` assigns a hash working variable. The variable is the same fresh per-invocation working value described above. Direct nested access keeps quoted path segments as hash keys; numeric, helper, and non-reserved bare path segments are array indexes.

`declare(...)` is retirement-bound for spec files. Use terse replacements instead:

- `declare(scalar, count=0)` -> `count = 0`;
- `declare(array, items)` -> `items = []` when an explicit reset is needed, or just `items += value` on first use;
- `declare(hash, meta)` -> `meta = {}` when an explicit reset is needed, or just `meta[key] = value` on first use;
- `declare(array, items=[value])` -> `items = [value]`;
- `declare(hash, meta={ key => value })` -> `meta = { key => value }`.

Where a name is wrapped, the wrapper still decides its kind. Where a name is bare in a type-implying position, that
position decides it. Direct RHS shape assignment infers the target kind for array/hash assignment; explicit
`scalar(name)` keeps array/hash payloads in a scalar.

> **Reserved names.** `undef`, `true`, and `false` are literals, so `array(undef)` constructs an array holding the `undef` literal — it does **not** create a variable named `undef`. The engine's own handler locals are likewise never treated as working variables.

## Canonical typed form

The legacy declaration shape is:

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

## Legacy declaration aliases

Aliases exist for compatibility with older specs. Do not use them in new spec files.

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

For new public documentation, use the terse replacements instead of any declaration helper or alias.

## Where state should live

Most shared rule state should be initialized or first used in the rule-entry lifecycle block:

```text
I {
  items = [];
  retv = undef;
  meta = {};
}
```

`I { ... }` runs at rule-handler entry, before the rule's action-edge logic needs the working state. That makes it
the clearest place for accumulators, child-result slots, flags, and metadata objects that multiple action edges
will share.

Action-edge blocks can introduce short-lived scratch values through assignment:

```text
-> Token[0] {
  normalized = lowercase(trim(entry_text()));
  return({ "kind" => "token", "text" => normalized });
}
```

Use action-edge-local assignment only when the variable is local to that action body. If a later action edge or
later lifecycle hook must read the value, initialize or first use it earlier in `I { ... }`.

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

Use initialized declarations when the startup value is obvious. If the initializer becomes dense, declare first and set the value later.

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
  set(scalar(name), coalesce_nonempty(trim(retv["name"]), entry_text(), "anonymous"));
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
declare(scalar, content=retv["content"]);
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

That is readable because both initializers are short. If the second expression grew into a longer fallback chain, split it into `declare(...)` plus `set(...)`.

## Array initializer examples

Array declarations can initialize from array constructors and supported array-valued helpers.

Examples:

```text
declare(array, items=array());
declare(array, pair=array(scalar(lhs), scalar(rhs)));
declare(array, groups=entry_groups());
declare(array, keys=sorted_keys(hash(meta)));
declare(array, public_keys=take(sorted_keys(pick_keys(hash(meta), "kind", "source")), 2));
declare(array, merged=concat_arrays(array(items), array(extra_items), ["tail"]));
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

Use `set(array(name), array())` to clear or reset a live array later. Do not redeclare a variable just to clear it.

```text
set(array(items), array());
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

Use `set(hash(name), hash())` or another hash-valued assignment to reset later:

```text
set(hash(meta), hash("kind", "fallback"));
```

Do not redeclare to reset. Redeclaration is a lifetime decision, not a mutation operation.

## Initializer expression surface

Declaration initializers reuse the same expression language as `set(...)`, `push_value(...)`, `return(...)`, and flow helpers.

> **Terse spellings.** The same terse helper renames apply here: `set(...)` for legacy `assign(...)`,
> scalar `name = value` and `=(name, value)` for scalar assignment, array append `items += expr` for explicit append values, hash-index assignment `meta["key"] = expr` for `set_key(meta, "key", expr)`, `cat(...)` for `concat(...)`, and a unified `copy(...)` for `array_copy(...)` / `hash_copy(...)`
> (it resolves array-vs-hash by the wrapped symbol kind). They lower identically to the original
> names in initializer and assignment sources, so `declare(array, saved=copy(array(items)))` is
> equivalent to `declare(array, saved=array_copy(array(items)))`. See the
> [Helper Contract Catalog](../appendix/helper-contract-catalog.md#terse-helper-renames-canonical-going-forward).

Common initializer sources include:

| Source | Examples |
| --- | --- |
| Literals | `"node"`, `1`, `0` |
| Working values | `scalar(name)`, `array(items)`, `hash(meta)` |
| Source readers | `entry_text()`, `entry_group(0)`, `capture_slice()`, `cursor_pos()` |
| Child payload access | `retv["content"]`, `retv["children"][0]["name"]` |
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
  .set(scalar(raw), entry_text())
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

For the current portable fluent/block contract — including attached `if`/`when` blocks, attached
`switch/case/default` blocks, and marker-style `if` — see the
[Fluent and Block Forms](fluent-and-block-forms.md) guide.

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
   set(scalar(retv), call(Item));
   push_value(array(items), scalar(retv));
 }
 -> List[1] {
   set(scalar(retv), call(Item));
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
   set(scalar(text), lowercase(trim(entry_text())));
   meta["text"] = scalar(text);
   meta["text_length"] = length(scalar(text));
   return(hash_copy(hash(meta)));
 }
```

The hash initializer states the always-present metadata. The later `meta["field"] = ...` statements state the branch-local updates; they are equivalent to `set_key(meta, "field", ...)` for explicit key and value expressions.

## Worked example: dense initializer moved to assignment

This version is legal but harder to read:

```text
I {
  declare(scalar, name=coalesce_nonempty(trim(retv["name"]), trim(entry_group(0)), "anonymous"));
}
```

For public examples, prefer:

```text
I {
  declare(scalar, name);
  set(scalar(name), coalesce_nonempty(
    trim(retv["name"]),
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

Do not use legacy declaration syntax to reset:

```text
declare(array, items);
```

Prefer terse assignment:

```text
items = [];
```

Do not pack unrelated state into one unreadable legacy declaration line:

```text
declare(scalar, retv, head, has_head, raw, normalized, count, stage, message);
```

Prefer grouped terse initialization only when explicit initialization helps readability:

```text
retv = undef;
head = undef;
has_head = false;
raw = undef;
normalized = undef;
count = 0;
stage = undef;
message = undef;
```

## Practical guidance

- Use `I { ... }` for rule-owned working state that multiple action edges need.
- Use action-edge assignment for short-lived scratch values local to that action body.
- Use `scalar`, `array`, and `hash` types according to how the value will be used, not according to how it happens to be emitted today.
- Prefer assignment and direct shapes in public docs; mention declaration helpers only as legacy compatibility.
- Prefer direct initialization when the initializer is short and obvious.
- Prefer a separate assignment sequence when initialization has a long fallback or normalization chain.
- Reset live containers with `name = []` or `name = { ... }`; do not redeclare for mutation.
- Keep state setup near the top of the rule or local action body so the reader sees the working values before the transformations.

## Related chapters

- [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) documents the expression helpers that can feed declaration initializers.
- [Source Boundary Helper Reference](source-boundary-helper-reference.md) documents source readers such as `entry_text()`, `entry_group(...)`, `capture_slice()`, and `cursor_pos()`.
- [ActionIR Lowering Mental Model](actionir-lowering-mental-model.md) explains why helper declarations are preferable to raw host-language code.

## Deeper reference

For the full `declare`/`declare_s`/`declare_a`/`declare_h` contract catalog with type-system details and emitted-Perl lowering, see `USER_GUIDE_ActionIR_DeclareMethod.md` in the repo root.
