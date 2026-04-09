# Values, Containers, and Flow Helpers

This chapter gives the public mental model for LinkedSpec’s value and control-flow helpers.

The exhaustive reference still lives in the repo-root ActionIR guides while the book continues growing. This chapter explains how to think about the surface.

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
```

Older return helpers still exist and are useful when reading legacy specs, but new public examples should prefer the generalized `return(...)` form when it expresses the intent clearly.

## Reading and copying collections

Use explicit helpers when you need a snapshot or derived collection:

```text
array_copy(array(items))
hash_copy(hash(meta))
flat_array(array(parts))
join_values("", array(tokens))
```

This keeps the action code declarative. A reader can tell whether you are copying, flattening, or joining without unpacking raw Perl syntax.

## Hash shaping

Hash helpers make metadata shaping explicit:

```text
assign(hash(meta), hash("kind", "rule", "name", scalar(name)));
assign(hash(meta), set_key(hash(meta), "line", entry_line()));
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
