# Values, Containers, and Flow Helpers

This chapter gives the public mental model for LinkedSpec’s value and control-flow helpers.

For the method-by-method public reference, read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) after this chapter. This chapter explains how to think about the surface before diving into exact helper choices.

## Containers: `scalar`, `array`, and `hash`

The core container helpers are:

```text
scalar(name)
array(items)
hash(meta)
```

These are DSL spellings. They are not Perl sigils. Older short wrapper aliases `s(...)`,
`a(...)`, and `h(...)` are retired; public examples and migrated specs use the canonical
forms above.

For aggregate wrappers, a single **bare** name token names a working variable: `array(items)` reads the
array/list working variable `items`, and `hash(meta)` reads the hash/associative-array working variable
`meta`. Quoted strings are literal values, not variable-name aliases: `array("items")` constructs an array
payload containing the string `"items"`, and `hash("key", value)` constructs a key/value hash. Prefer direct
shape literals (`["literal"]`, `{ "key" => value }`, `[]`, `{}`) as the terse constructor spellings in new
examples.

## Per-rule default accumulator

Every generated rule handler has a local array named after the rule. In a rule named `Parent`, the conventional accumulator is `@Parent`; in a rule named `sub_gui_list`, it is `@sub_gui_list`.

The compact shorthand that uses this convention is:

```text
push(Child)
```

Inside `Parent`, that means "call `Child` and append the child result into `@Parent`."

If `Child` returns an array-like payload and only one element should be appended, use:

```text
push(Child, 1)
```

That appends `call(Child)->[1]` into the current rule accumulator.

Use this convention when the rule name is the best name for the collection. If a domain name is clearer, keep the target explicit:

```text
push(Child, children)
push_value(array(children), scalar(child))
push_nonempty(array(children), trim(capture_slice()))
```

Most helpers do not guess the current rule array. They can still read or mutate it when you name it explicitly, for example `array(Parent)`, `push_value(array(Parent), value)`, or `return(hash("children", array_copy(array(Parent))))`.

## Assignment

Use `set(target, source)` or `target = source` to replace a target value. `assign(target, source)` remains a
supported legacy alias, but new examples should prefer the terse spelling.

Examples:

```text
set(scalar(name), entry_group(0));
items = [];
meta = { "kind" => "token", "line" => entry_line() };
```

Use assignment when you want to set or replace the target. Assignment remains valid as a statement, and assignment
forms are also value expressions. `name = "ok"` and `=(name, "ok")` store the scalar and yield it. Direct shape
assignments such as `items = [value]`, `set(items, [value])`, `=(items, [value])`, and
`meta = { key => value }` store the inferred aggregate target and yield the assigned array or hash value. Mutation
assignments also compose as values: `items += value` mutates the named array and yields the updated array snapshot,
while `meta[key] = value` mutates the named hash and yields the updated hash snapshot. These forms compose in
`return(...)`, helper arguments, expression-valued blocks, user functions, or compatible receiver chains.

## Pushing values

Use `push_value(array(target), value)` when you want to append.

Example:

```text
set(scalar(child), call(Child));
push_value(array(items), scalar(child));
```

Do not use whole-array assignment when you mean append.

```text
set(array(items), array(scalar(child)));
```

That replaces the whole array. It does not append to it.

## Returning payloads

Use `return(payload)` for modern structured returns.

Examples:

```text
return(hash("kind", "token", "text", entry_text()));
return(array("?node:", scalar(name), array_copy(array(children))));
return({ "kind" => "token", "text" => entry_text(), "tags" => [tag, true] });
```

Older return helpers still exist and are useful when reading legacy specs, but new public examples should prefer the generalized `return(...)` form when it expresses the intent clearly.

Direct shape literals (`[]` and `{ key => value }`) are value expressions on the Perl reference and Rust backend. Use
them when the literal shape is clearer than the helper form. Shape members still follow DSL value-expression
rules: a bare element such as `tag` reads scalar working variable `tag`, and a bare hash key such as
`{ field => value }` reads scalar `field` as the runtime key. Quote fixed object field names:

```text
set(field, "kind");
set(value, "token");
return({ field => value, "seen" => true, "parts" => [value, entry_text()] });
```

That returns an object with a dynamic key from `field`, a fixed `"seen"` field, and a nested array.

Direct shape literals also drive target-kind inference for bare assignment targets on the Perl reference and
Rust backend:

```text
items = [value, cat("a", "b")];     # initializes array working variable items
meta = { field => value };          # initializes hash working variable meta
set(items, []);                     # replaces array working variable items with an empty array
set(meta, {});                      # replaces hash working variable meta with an empty hash
```

Use an explicit scalar wrapper when the intent is to store the whole array/hash payload in a scalar:

```text
set(scalar(payload), [value]);
return(scalar(payload));
```

This target-kind inference is intentionally tied to direct RHS shape literals. Use an explicit scalar wrapper
when the goal is a scalar-held shape payload; use `array(name)` / `hash(name)` when the goal is an explicit
aggregate target.

Expression-valued blocks are also value expressions. Use them when a value needs local setup before it is
returned or assigned:

```text
set(payload, { set(kind, "token"); return({ "kind" => kind }); "unused" });
return(payload);
```

The `return(expr)` inside the block is block-local: it yields the block value and skips later statements in
that block. The surrounding rule still returns only because the outer action later calls `return(payload)`.
When a block is used as a receiver, its yielded value enters the same compatible receiver-dot helper family:
`{ [3, 1, 2] }.sorted().join_values(",")`, `{ " a-b " }.trim().split("-").count()`,
`{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)` use the existing
array, string, hash, and number contracts.

## Reading and copying collections

Use explicit helpers when you need a snapshot or derived collection:

```text
array_copy(array(items))
hash_copy(hash(meta))
flat_array(array(parts))
join_values("", array(tokens))
tokens.uniq().join_values("")
items.sorted().drop_front(2).first()
meta.set_key("stage", "normalized").sorted_keys().join_values(",")
meta.merge_hash(hash("kind", "fallback"))
raw.trim().lowercase().replace_substr("-", "_")
raw.trim().split("-").trim_each().filter_nonempty()
raw.trim().split("-").lowercase_each().join_values("_")
score.abs().ceil().add(2).clamp(0, 10)
count(array(parts)).gt(0)
split_tagged_records(scalar(identifier_list), /\s*,\s*/o, "?node:", scalar(type_name))
```

This keeps the action code declarative. A reader can tell whether you are copying, flattening, joining, or shaping repeated tagged rows without unpacking raw Perl syntax.

Receiver-dot value chains are pure helper composition. Array receivers can flow through array helpers, hash
receivers can flow through hash helpers and then array helpers through `sorted_keys()` / `sorted_values()`,
string receivers can flow through scalar string helpers, and number receivers can flow through numeric helpers.
`split(delim)` is the explicit string-to-array bridge: after `raw.trim().split("-")`, the chain continues with
array helpers such as `trim_each()`, `filter_nonempty()`, `lowercase_each()`, `count()`, or
`join_values(delim)`. Numeric comparisons such as `count(array(parts)).gt(0)` are terminal values; they do not
continue into later number methods.
Expression-valued block receivers do not add a separate dispatch rule: the block evaluates first, then the
selected helper family consumes the yielded value.

## Hash shaping

Hash helpers make metadata shaping explicit:

```text
set(hash(meta), hash("kind", "rule", "name", scalar(name)));
set_key(meta, "line", entry_line());
set(hash(meta), merge_hash(hash(meta), hash("source", "spec")));
set(scalar(public_fields), meta.drop_keys("debug").sorted_keys().join_values(","));
```

These are especially useful when building AST nodes or diagnostics payloads.

## Flow helpers

LinkedSpec supports structured control-flow helpers so rules do not have to fall back to raw Perl for common branching.

Typical shape:

```text
if(is_nonempty(scalar(name)));
  return(hash("kind", "named", "name", scalar(name)));
else();
  return(hash("kind", "anonymous"));
endif();
```

Attached switch flow is useful when one value drives multiple cases:

```text
switch(scalar(kind)) {
  case("word") { return(hash("kind", "word", "text", entry_text())) }
  case("space") { return(hash("kind", "space", "text", entry_text())) }
  default { return(hash("kind", "other", "text", entry_text())) }
}
```

## Practical pattern: token node

Here is a compact token-node pattern:

```text
Token::
 /(\w+)/ {
   declare(scalar, text);
   set(scalar(text), entry_group(0));
   return(hash(
     "kind", "token",
     "text", scalar(text),
     "line", entry_line(),
     "col", entry_col()
   ));
 }
```

The rule:

- declares one working scalar
- reads the capture group through `entry_group(0)`
- returns a structured hash
- includes human-readable source location data

That is the style LinkedSpec should increasingly teach: explicit parser intent, not host-language cleverness.
