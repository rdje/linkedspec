# Values, Containers, and Flow Helpers

This chapter gives the public mental model for LinkedSpec’s value and control-flow helpers.

For the method-by-method public reference, read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) after this chapter. This chapter explains how to think about the surface before diving into exact helper choices.

## Containers: `scalar`, `array`, and `hash`

The core container helpers are:

```text
name
array(items)
hash(meta)
```

These are DSL spellings. They are not Perl sigils. Public examples and migrated specs use the canonical
forms above.

For aggregate wrappers, a single **bare** name token names a working variable: `array(items)` reads the
array/list working variable `items`, and `hash(meta)` reads the hash/associative-array working variable
`meta`. Quoted strings are literal values, not variable-name aliases: `array("items")` constructs an array
payload containing the string `"items"`, and `hash("key", value)` constructs a key/value hash. Prefer direct
shape literals (`["literal"]`, `{ "key" : value }`, `[]`, `{}`) as the terse constructor spellings in new
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
push(array(children), child)
child_text = trim(capture_slice())
if(is_nonempty(child_text)) { push(array(children), child_text) }
```

Most helpers do not guess the current rule array. They can still read or mutate it when you name it explicitly, for example `array(Parent)`, `push(array(Parent), value)`, or `return(hash("children", copy(array(Parent))))`.

## Assignment

Use `set(target, source)` or `target = source` to replace a target value. New examples
should prefer the operator form when it is clear at a glance.

Examples:

```text
name = entry_group(0);
items = [];
meta = { "kind" : "token", "line" : entry_line() };
```

Use assignment when you want to set or replace the target. Assignment remains valid as a statement, and assignment
forms are also value expressions. `name = "ok"` and `=(name, "ok")` store the scalar and yield it. Direct shape
assignments such as `items = [value]`, `set(items, [value])`, `=(items, [value])`, and
`meta = { key : value }` bind the array or hash as the current typed value of the bare target and yield that
stored value. Mutation assignments also compose as values: `items += value` mutates the named array and yields the
updated array snapshot, while `meta[key] = value` mutates the named hash and yields the updated hash snapshot.
These forms compose in `return(...)`, helper arguments, expression-valued blocks, user functions, or compatible
receiver chains.

Nested value-path assignment uses the same direct bracket path on the left side:

```text
payload = { "items" : [{ "name" : "old" }] };
payload["items"][0]["name"] = "new";
payload["items"][1] = { "name" : "tail" };
```

Nested writes mutate the array/hash value currently held by the bare variable. Intermediate containers must
already exist and have the required shape; LinkedSpec does not autovivify missing hashes or arrays. A final hash
key may be created or replaced. A final array index may replace an existing element or append exactly at the
current array length. An array gap, missing intermediate key, or wrong intermediate container leaves the root
unchanged and yields `undef` in value positions. Segment index expressions are evaluated before the RHS value
expression; the root path check and mutation happen after both.

## Pushing values

Use `push(array(target), value)` when you want to append.

Example:

```text
child = call(Child);
push(array(items), child);
```

Do not use whole-array assignment when you mean append.

```text
set(array(items), array(child));
```

That replaces the whole array. It does not append to it.

## Returning payloads

Use `return(payload)` for modern structured returns.

Examples:

```text
return(hash("kind", "token", "text", entry_text()));
return(array("?node:", name, copy(array(children))));
return({ "kind" : "token", "text" : entry_text(), "tags" : [tag, true] });
```

Older return helpers still exist and are useful when reading legacy specs, but new public examples should prefer the generalized `return(...)` form when it expresses the intent clearly.

Direct shape literals (`[]` and `{ key : value }`) are value expressions on the Perl reference and Rust backend. Use
them when the literal shape is clearer than the helper form. Shape members still follow DSL value-expression
rules: a bare element such as `tag` reads scalar working variable `tag`, and a direct hash key is any accepted
value expression before the top-level `:`. A bare hash key such as `{ field : value }` reads scalar `field` as
the runtime key; a computed form such as `{ cat(prefix, suffix) : value }` uses the helper result as the key.
Quote fixed object field names:

```text
set(field, "kind");
set(value, "token");
return({ field : value, "seen" : true, "parts" : [value, entry_text()] });
```

That returns an object with a dynamic key from `field`, a fixed `"seen"` field, and a nested array.

Direct shape literals are ordinary RHS values for bare assignment targets on the Perl reference and Rust backend:

```text
items = [value, cat("a", "b")];     # binds an array value to items
meta = { field : value };          # binds a hash value to meta
set(items, []);                     # replaces items with an empty array value
set(meta, {});                      # replaces meta with an empty hash value
```

Use an explicit aggregate target when the intent is aggregate working-variable storage:

```text
set(array(items), [value]);
set(hash(meta), { field : value });
```

Use a bare working variable when the source should visibly read the current value or when the target should bind the
typed RHS value. A bare variable may hold an array or hash value:

```text
set(payload, [value]);
return(payload);
```

`array(name)` and `hash(name)` are typed views/snapshots at use sites. When `name` currently holds an array or hash
value through bare assignment, they read that value. When the name has been populated through explicit aggregate
mutation such as `set(array(name), ...)` or `name += value`, they read the aggregate working storage.

Expression-valued blocks are also value expressions. Use them when a value needs local setup before it is
returned or assigned:

```text
set(payload, { set(kind, "token"); return({ "kind" : kind }); "unused" });
return(payload);
```

The `return(expr)` inside the block is block-local: it yields the block value and skips later statements in
that block. The surrounding rule still returns only because the outer action later calls `return(payload)`.
When a block is used as a receiver, its yielded value enters the same compatible receiver-dot helper family:
`{ [3, 1, 2] }.sorted().join_values(",")`, `{ " a-b " }.trim().split("-").count()`,
`{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)` use the existing
array, string, hash, and number contracts.

Perl and Rust also accept trailing block arguments for helper-form `with(value) { ... }` and receiver-form
`.with() { ... }`:

```text
return(with(entry_group(0)) { return(cat(value, "!")) });
return(with() { return(is_undefined(value)) });
return(entry_group(0).with() { return(cat(value, "!")) });
return(" a-b ".trim().with() { return(value.split("-")) }.count());
```

`with(value) { ... }` evaluates the value, binds a scoped scalar `value` for immediate block execution, and returns
the block result. `with() { ... }` binds that scoped `value` to `undef`. Receiver `.with() { ... }` evaluates its
receiver first, exposes that receiver value through the same scoped `value` binding, and yields the block result;
the yielded result can be the terminal value or can feed later compatible receiver-family links. The binding is
local to the block, so an outer working variable named `value` is visible again after the `with` expression
finishes. The block is not a closure, assignable value, returnable value, or delayed callback. It runs in the
caller's current action/runtime context: captures, `retv`, cursor state, helper/function visibility, and ordinary
working-variable side effects are the same as the call site. Only the scalar binding `value` is portable as the
scoped block parameter in this MVP; mutations to other variable names persist after `with` returns. Bare
`with { ... }`, explicit receiver `.with(value) { ... }`, and delayed callback semantics are not current portable
surfaces.

Hash receiver trailing blocks also support deterministic tree traversal. A hash tree has a hash root. Nested hash
values are interior nodes; all non-hash values, including arrays, are leaves. `walk_leaves() { ... }` visits each
leaf for side effects and returns the original hash tree. `map_leaves() { ... }` returns a new hash tree with each
leaf replaced by the block result. `reduce_leaves(initial) { ... }` folds leaves into an accumulator and returns the
final accumulator. Traversal is stable sorted-key depth-first order. The block gets scoped scalar bindings:
`value` for the current leaf, `key` for the current key, `path` for an array of path segments from the root, `depth`
for the zero-based leaf depth, and `acc` for `reduce_leaves` only. Those scoped bindings are restored after each
callback.

```text
tree = { "a" : "A", "b" : { "y" : "B" }, "arr" : ["u", "v"] };

return(tree.map_leaves() {
  leaf_text = if(count(array(value)), join_values("", array(value)), else(value));
  return(cat(join_values("/", array(path)), "=", leaf_text))
});

set(array(paths), []);
tree.walk_leaves() {
  paths += join_values("/", array(path))
};
return(copy(array(paths)));  # ["a", "arr", "b/y"]

return(tree.reduce_leaves(0) {
  return(acc.add(1))
});
```

Calling one of these traversal methods on a non-hash receiver yields `undef` and does not execute the callback.
`walk_leaves()` and `map_leaves()` take no parenthesized arguments; `reduce_leaves(initial)` requires exactly one
initial accumulator argument. `walk_leaves()` and `map_leaves()` return hash values and can continue into later
hash receiver methods such as `.count_keys()`. `reduce_leaves(...)` returns the accumulator as a terminal value.

The same receiver block methods also work on array trees. Array roots and nested arrays are traversal nodes. Scalar
and hash values are leaves, and hash leaves are not traversed recursively. Traversal is depth-first by zero-based
index. Callback blocks get scoped `value`, `index`, `path`, `depth`, and reduction-only `acc`.

```text
items = ["a", ["b", "c"], { "h" : "H" }];

return(items.map_leaves() {
  return(cat(join_values("/", array(path)), "=", value))
});

items.walk_leaves() {
  paths += join_values("/", array(path))
};

return(items.reduce_leaves(0) {
  return(acc.add(1))
});
```

## Reading and copying collections

Use explicit helpers when you need a snapshot or derived collection:

```text
copy(array(items))
copy(hash(meta))
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
split_tagged_records(identifier_list, /\s*,\s*/o, "?node:", type_name)
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
set(hash(meta), hash("kind", "rule", "name", name));
set_key(meta, "line", entry_line());
set(hash(meta), merge_hash(hash(meta), hash("source", "spec")));
public_fields = meta.drop_keys("debug").sorted_keys().join_values(",");
```

These are especially useful when building AST nodes or diagnostics payloads.

## Flow helpers

LinkedSpec supports structured control-flow helpers so rules do not have to fall back to raw Perl for common branching.

Typical shape:

```text
if(is_nonempty(name));
  return(hash("kind", "named", "name", name));
else();
  return(hash("kind", "anonymous"));
endif();
```

Attached switch flow is useful when one value drives multiple cases:

```text
switch(kind) {
  case("word") { return(hash("kind", "word", "text", entry_text())) }
  case("space") { return(hash("kind", "space", "text", entry_text())) }
  default { return(hash("kind", "other", "text", entry_text())) }
}
```

## Practical pattern: token node

Here is a compact token-node pattern:

```text
Top::
 -> Token .push
 LX { return(copy(array(Top))) }

Token: /(\w+)/
 I {
   text = entry_group(0);
   return(hash(
     "kind", "token",
     "text", text,
     "line", entry_line(),
     "col", entry_col()
   ));
 }
```

The rule:

- assigns one working scalar from `entry_group(0)`
- returns a structured hash
- includes human-readable source location data

That is the style LinkedSpec should increasingly teach: explicit parser intent, not host-language cleverness.
