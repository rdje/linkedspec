# Working Variables and Setup

Working variables auto-exist when a rule uses them through a typed or type-implying position. New `.spec` files
initialize state with direct assignment, bare `set(...)`, and mutation helpers.

Read [Action Model and Helper Surface](action-model-and-helper-surface.md) first if the helper DSL direction is new. Read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) for the value expressions that feed assignments, returns, appends, and flow helpers.

## Current Setup Forms

Use direct assignment for scalar or typed-value slots:

```text
name = entry_text();
count = num_add(coalesce(count, 0), 1);
payload = { "kind" : "node", "name" : name };
```

Bind an array or harray value directly when later helpers should read or mutate it:

```text
set(items, []);
push(items, value);
return(copy(items));

set(meta, {});
meta[key] = value;
return(copy(meta));
```

`items = []` and `set(items, [])` both bind one array value to `items`; operator and helper spelling do not create
separate namespaces. Later `items` reads and `push(items, ...)` mutations observe that same typed binding.

## Auto-Existing Variables

You do not have to predeclare a working variable. A variable auto-exists when it appears in a typed or type-implying position:

```text
# scalar target/read positions
count = num_add(coalesce(count, 0), 1);
return(count);

# array target/read positions
items += entry_text();
push(items, entry_text());
return(copy(items));

# hash target/read positions
meta["kind"] = "token";
set_key(meta, "line", cursor_line());
return(copy(meta));
```

The working value is fresh for the rule invocation. It does not carry state across parser runs or recursive
re-entry. For recursive accumulators, bind a fresh container in the lifecycle setup path:

```text
Node::AND
 I { set(items, []) }
 -> Atom { items += entry_text() }
 LX { return(copy(items)) }
```

## Worked Example

```text
List::
 I {
   set(items, []);
   retv = undef;
 }
 -> Item {
   retv = call(Item);
   push(items, retv);
 }
 LX {
   return(hash(
     "kind", "list",
     "items", copy(items),
     "item_count", count(items)
   ));
 }

Item: /\s*[A-Za-z_]+/
 I { return(hash("text", trim(entry_text()))) }
```

On input `alpha beta`, this returns `{"kind":"list","items":[{"text":"alpha"},{"text":"beta"}],"item_count":2}`.

The state choices are explicit:

- `set(items, [])` binds a fresh array accumulator for this rule invocation.
- `retv = undef` makes the scratch scalar visible before action edges use it.
- `push(items, retv)` appends one computed child result.
