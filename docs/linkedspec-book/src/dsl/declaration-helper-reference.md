# Working Variables and Setup

Working variables auto-exist when a rule uses them through a typed or type-implying position. New `.spec` files should initialize state with direct assignment, aggregate reset forms, and mutation helpers.

Read [Action Model and Helper Surface](action-model-and-helper-surface.md) first if the helper DSL direction is new. Read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) for the value expressions that feed assignments, returns, appends, and flow helpers.

## Current Setup Forms

Use direct assignment for scalar or typed-value slots:

```text
name = entry_text();
count = num_add(coalesce(count, 0), 1);
payload = { "kind" : "node", "name" : name };
```

Use explicit aggregate targets when later helpers should read or mutate named aggregate storage:

```text
set(array(items), []);
push(array(items), value);
return(copy(array(items)));

set(hash(meta), {});
meta[key] = value;
return(copy(hash(meta)));
```

That distinction matters. `items = []` stores one array value in the scalar slot named `items`; `set(array(items), [])` resets the named array storage that `array(items)` and `push(array(items), ...)` use.

## Auto-Existing Variables

You do not have to predeclare a working variable. A variable auto-exists when it appears in a typed or type-implying position:

```text
# scalar target/read positions
count = num_add(coalesce(count, 0), 1);
return(count);

# array target/read positions
items += entry_text();
push(array(items), entry_text());
return(copy(array(items)));

# hash target/read positions
meta["kind"] = "token";
set_key(meta, "line", cursor_line());
return(copy(hash(meta)));
```

The working value is fresh for the rule invocation. It does not carry state across parser runs or recursive re-entry. For recursive accumulators, reset aggregate storage in the lifecycle setup path:

```text
Node::AND
 I { set(array(items), []) }
 -> Atom { items += entry_text() }
 LX { return(copy(array(items))) }
```

## Worked Example

```text
List::
 I {
   set(array(items), []);
   retv = undef;
 }
 -> Item {
   retv = call(Item);
   push(array(items), retv);
 }
 LX {
   return(hash(
     "kind", "list",
     "items", copy(array(items)),
     "item_count", count(array(items))
   ));
 }

Item: /\s*[A-Za-z_]+/
 I { return(hash("text", trim(entry_text()))) }
```

On input `alpha beta`, this returns `{"kind":"list","items":[{"text":"alpha"},{"text":"beta"}],"item_count":2}`.

The state choices are explicit:

- `set(array(items), [])` resets the named array accumulator for this rule invocation.
- `retv = undef` makes the scratch scalar visible before action edges use it.
- `push(array(items), retv)` appends one computed child result.
