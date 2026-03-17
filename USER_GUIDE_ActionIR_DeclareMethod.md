# USER GUIDE - ActionIR `DeclareMethod.pm`
This guide covers the declaration surface lowered by `perl/LinkedSpec/ActionIR/DeclareMethod.pm`.

The declaration surface is where you define working state inside action/lifecycle code without dropping back to raw Perl declarations.
For exact DSL-to-Perl examples for every declaration form and alias discussed here, read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md) alongside this guide.

Documentation note:
- declaration initializer arguments may use nested method composition with no fixed depth limit,
- but this guide keeps examples representative instead of attempting a full nesting catalog.

For a cross-cutting tutorial that focuses specifically on string/integer/float scalars plus array/hash composition with many worked `.spec` examples, also read [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md).

## Why declarations matter
A lot of backend-neutral migration work starts by replacing raw Perl declarations such as:

```text
my @items;
my $retv;
my %by_name;
```

with canonical helper forms:

```text
declare(array, items)
declare(scalar, retv)
declare(hash, by_name)
```

That seems small, but it matters because `declare(...)` becomes a typed ActionIR node instead of an opaque raw statement.

## Canonical syntax
### Typed declaration form

```text
declare(type, entry1, entry2, ...)
```

Supported `type` values:
- `array`
- `scalar`
- `hash`

Examples:

```text
declare(array, items)
declare(scalar, retv)
declare(hash, by_name)
declare(array, items, captures)
declare(scalar, flag, name, pos_begin)
```

Lowering intent:
- `declare(array, items)` -> conceptually `my @items`
- `declare(scalar, retv)` -> conceptually `my $retv`
- `declare(hash, by_name)` -> conceptually `my %by_name`

## Declaration aliases
Aliases exist for convenience and compatibility.

### Short aliases

```text
declare_a(items, captures)
declare_s(flag, name)
declare_h(by_name)
```

### Long aliases

```text
declare_array(items, captures)
declare_scalar(flag, name)
declare_hash(by_name)
```

These aliases map to the same typed declaration IR. They are syntax sugar, not a separate semantic feature.

## Initialized declarations
You can initialize each declaration entry by writing `name=expr`.

### Scalar initializer examples

```text
declare(scalar, flag=or(scalar(on), scalar(off)))
declare(scalar, token=scalaref(retv, {content}))
declare(scalar, joined=join_values("", array(parts)))
```

Typical uses:
- setting a flag from boolean helper expressions,
- extracting a nested field from a returned hash payload,
- capturing a temporary joined string before post-processing.

### Array initializer examples

```text
declare(array, parts=array(scalar(a), scalar(b)))
declare(array, items=array())
declare(array, work=array(flat_array(IMATCH_LIST)))
```

Use cases:
- seeding an array with one or more values,
- explicitly starting with an empty array,
- copying or re-constructing list content in a canonical constructor shape.

### Hash initializer examples

```text
declare(hash, by_name=hash("k", scalar(v)))
declare(hash, meta=hash("kind", "node", "ok", 1))
```

Use cases:
- working dictionaries,
- metadata caches,
- structured temporary objects before a final return.

## Mixed declaration examples
You can mix multiple names in a single declaration statement.

```text
declare(array, items, captures)
declare(scalar, head, retv, has_head)
declare(hash, by_name, seen)
```

You can also mix initialized and uninitialized entries in the same call.

```text
declare(scalar, flag=1, name, token=scalaref(retv, {content}))
```

That is often useful when a rule has some variables with obvious startup values and others that are filled later.

## Practical examples
### Example: simple accumulator state

```text
I {declare(array, items); declare(scalar, retv)}
```

Use this when a rule repeatedly calls child rules and stores the results.

### Example: captured block payload

```text
I {declare(scalar, content)}
-> curlyb[1] {
  assign(scalar(content), CAPTURE);
  return(hash("type", "CBRACE", "content", scalar(content)))
}
```

The declaration makes the working variable explicit and typed.

### Example: recursive list builder state

```text
I {declare(array, word, tail); declare(scalar, retv, head, has_head)}
```

This pattern is useful when:
- `word` is a temporary array of token fragments,
- `tail` accumulates finalized list items,
- `head` remembers the first list item,
- `has_head` distinguishes an empty list from a list whose head might be falsey,
- `retv` holds a child-rule result.

## What initializer expressions may contain
Initializer expressions reuse the broader value-expression lowering surface. In practice that means you can initialize from:
- helper value expressions such as `scalar(...)`, `array(...)`, `hash(...)`, `scalaref(...)`, `join_values(...)`, and ActionIR boolean/value helpers,
- array/list constructors,
- hash constructors,
- simple raw literals.

Examples:

```text
declare(scalar, flag=not(is_empty(scalar(name))))
declare(array, nodes=array(scalar(seed), scalar(other)))
declare(hash, meta=hash("kind", "node", "count", scalar(count)))
```

## Preferred patterns
### Prefer this

```text
I {declare(array, items); declare(scalar, retv)}
```

### Over this

```text
I {my @items; my $retv}
```

### Prefer this

```text
declare(scalar, token=scalaref(retv, {content}))
```

### Over this

```text
my $token = $retv->{content}
```

The second form may still work in Perl, but the first form is much easier to migrate across backends.

## Nuances and tips
- Use one `declare(...)` block early in the rule when possible so the working state is obvious.
- If a variable is logically of a different kind, declare it that way; do not treat arrays, hashes, and scalars as interchangeable.
- For array resets later in the rule, use `assign(array(name), array())` rather than redeclaring.
- Prefer initialized declarations only when the initialization is easy to read. If the initializer becomes dense, declare first and assign later.

## Related guides
- Cross-cutting scalar/aggregate cookbook: [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md)
- Value access, constructors, and payloads: [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md)
- Assignment behavior: [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
