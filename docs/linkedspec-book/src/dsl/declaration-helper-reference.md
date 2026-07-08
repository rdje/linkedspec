# Declaration Helper Reference

This chapter records the retired declaration helper family and the current terse-format replacement policy.

> **Current policy.** New `.spec` files must not use `declare(...)` or declaration aliases. The Perl reference and
> Rust runtime now emit `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics for declaration helpers instead of
> executing them successfully. Working variables auto-exist through the terse format, and kind is inferred from typed
> wrappers, type-implying helper positions, and explicit assignment/mutation targets.

Read [Action Model and Helper Surface](action-model-and-helper-surface.md) first if the helper-DSL direction is still new. Read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) after this chapter for the value expressions that feed assignments, returns, appends, and flow helpers.

## Replacement Summary

Use the current surface directly:

| Retired declaration form | Current replacement |
| --- | --- |
| `declare(scalar, retv)` | `retv = undef` when an explicit initializer helps readability, or first scalar assignment/use. |
| `declare(scalar, count=0)` | `count = 0` |
| `declare(array, items)` | `set(array(items), [])` when the rule must reset named aggregate storage, or `items += value` on first append. |
| `declare(array, items=array(value))` | `set(array(items), [value])` |
| `declare(hash, meta)` | `set(hash(meta), {})` when the rule must reset named aggregate storage, or `meta[key] = value` on first mutation. |
| `declare(hash, meta=hash("kind", "node"))` | `set(hash(meta), { "kind" : "node" })` |

Bare assignment binds the evaluated typed value:

```text
items = [value];              # scalar working value `items` now holds an array payload
meta = { "kind" : kind };    # scalar working value `meta` now holds a hash payload
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

That distinction matters. `items = []` stores one array value in the scalar slot named `items`; `set(array(items), [])`
resets the named array storage that `array(items)` and `push(array(items), ...)` use.

## Auto-Existing Working Variables

You do not have to declare a working variable before using it. A variable auto-exists when it appears in a typed or
type-implying position:

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

The working value is fresh for the rule invocation. It does not carry state across parser runs or recursive re-entry.
For recursive accumulators, the current aggregate reset form participates in the same rule-local snapshot/restore
boundary:

```text
Node::AND
 I { set(array(items), []) }
 -> Atom { items += entry_text() }
 LX { return(copy(array(items))) }
```

This is the current replacement for legacy recursive `declare(array, items)` initializers.

## Retired Declaration Shapes

The retired function forms are:

```text
declare(scalar, name);
declare(scalar, name=value);
declare(array, items);
declare(array, items=array(value));
declare(hash, meta);
declare(hash, meta=hash("kind", "node"));
```

The retired aliases are:

| Alias | Former meaning |
| --- | --- |
| `declare_s(name, ...)` | `declare(scalar, name, ...)` |
| `declare_scalar(name, ...)` | `declare(scalar, name, ...)` |
| `declare_a(name, ...)` | `declare(array, name, ...)` |
| `declare_array(name, ...)` | `declare(array, name, ...)` |
| `declare_h(name, ...)` | `declare(hash, name, ...)` |
| `declare_hash(name, ...)` | `declare(hash, name, ...)` |

These names are retained in documentation only so old specs and diagnostics are recognizable. They are not current
authoring surface.

## Worked Example: Accumulator State

Current form:

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
- `Item:` owns the regex and returns one item record; `List::` owns the accumulator.

## Worked Example: Metadata Baseline

```text
Top::
 -> Token .push
 LX { return(copy(array(Top))) }

Token: /[A-Za-z_]+/
 I {
   set(hash(meta), { "kind" : "token", "source" : "Token" });
   text = lowercase(trim(entry_text()));
   meta["text"] = text;
   meta["text_length"] = length(text);
   return(copy(hash(meta)));
 }
```

On input `Alpha`, this returns `[{"kind":"token","source":"Token","text":"alpha","text_length":5}]`.

The hash reset states the always-present metadata. Later hash-index assignments state the branch-local updates and are
equivalent to `set_key(meta, key, value)` for explicit key/value expressions.

## Common Mistakes

Do not use retired declaration helpers:

```text
declare(array, items);
declare(scalar, retv);
declare(hash, meta);
```

Prefer:

```text
set(array(items), []);
retv = undef;
set(hash(meta), {});
```

Do not use direct shape assignment when the rule needs named aggregate storage:

```text
items = [];
push(array(items), value);
```

Prefer:

```text
set(array(items), []);
push(array(items), value);
```

Do not use retired wrapper aliases:

```text
a(items);
h(meta);
```

Prefer:

```text
array(items);
hash(meta);
```

## Practical Guidance

- Use `I { ... }` for rule-owned working state that multiple action edges need.
- Use action-edge assignment for short-lived scratch values local to that action body.
- Use `set(array(name), [])` and `set(hash(name), {})` for explicit aggregate resets.
- Use `name = []` or `name = { ... }` only when the variable should hold a scalar-typed array/hash payload.
- Use `items += value`, `push(array(items), value)`, `meta[key] = value`, and `set_key(meta, key, value)` for first-use auto-existence.
- Keep setup near the top of the rule so the reader sees working values before transformations.

## Related Chapters

- [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) documents the expression helpers that feed assignments and returns.
- [Source Boundary Helper Reference](source-boundary-helper-reference.md) documents source readers such as `entry_text()`, `entry_group(...)`, `capture_slice()`, and `cursor_pos()`.
- [ActionIR Lowering Mental Model](actionir-lowering-mental-model.md) explains why helper forms are preferable to raw host-language code.
