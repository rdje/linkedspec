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

Short aliases also exist:

```text
s(name)
a(items)
h(meta)
```

These aliases are DSL spellings. They are not Perl sigils.

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

Use `assign(target, source)` to replace a target value.

Examples:

```text
assign(scalar(name), entry_group(0));
assign(array(items), array());
assign(hash(meta), hash("kind", "token", "line", entry_line()));
```

Use assignment when you want to set or replace the target.

## Pushing values

Use `push_value(array(target), value)` when you want to append.

Example:

```text
assign(scalar(child), call(Child));
push_value(array(items), scalar(child));
```

Do not use whole-array assignment when you mean append.

```text
assign(array(items), array(scalar(child)));
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

Direct shape literals also drive target-kind inference for bare assignment targets on the Perl reference:

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

Rust currently supports the direct shape-literal value forms above, but Rust aggregate target-kind inference is
the next parity step. Until that lands, `name = [value]` on Rust stores the array payload in scalar `name`
rather than replacing array working variable `name`.

## Reading and copying collections

Use explicit helpers when you need a snapshot or derived collection:

```text
array_copy(array(items))
hash_copy(hash(meta))
flat_array(array(parts))
join_values("", array(tokens))
split_tagged_records(scalar(identifier_list), /\s*,\s*/o, "?node:", scalar(type_name))
```

This keeps the action code declarative. A reader can tell whether you are copying, flattening, joining, or shaping repeated tagged rows without unpacking raw Perl syntax.

## Hash shaping

Hash helpers make metadata shaping explicit:

```text
assign(hash(meta), hash("kind", "rule", "name", scalar(name)));
set_key(meta, "line", entry_line());
assign(hash(meta), merge_hash(hash(meta), hash("source", "spec")));
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

Switch-style flow is useful when one expression drives multiple cases:

```text
switch(scalar(kind));
case("word");
  return(hash("kind", "word", "text", entry_text()));
case("space");
  return(hash("kind", "space", "text", entry_text()));
default();
  return(hash("kind", "other", "text", entry_text()));
endswitch();
```

## Practical pattern: token node

Here is a compact token-node pattern:

```text
Token::
 /(\w+)/ {
   declare(scalar, text);
   assign(scalar(text), entry_group(0));
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
