# USER GUIDE - ActionIR `Contracts.pm`
This guide covers the helper-contract and compatibility surfaces cataloged by `perl/LinkedSpec/ActionIR/Contracts.pm`.
For exact DSL-to-Perl examples for every compatibility helper, wrapper, capture/backtrack form, and classified pass-through idiom, also read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

This is where many legacy helpers and compatibility-preserving wrappers are normalized into canonical lowering behavior.

## Why this guide matters
Not every user-facing construct looks like a modern method DSL call. LinkedSpec still supports several older helper forms that are important because:
- existing specs use them,
- they are part of the migration path,
- you will encounter them while reading older rules.

For new backend-neutral authoring, many of these are still valid, but some are better treated as compatibility forms rather than defaults.

## `call(rule)`
This is the core dispatch helper.

### Standalone use

```text
call(child)
```

Use it when a child rule should run at the current location.

### As part of legacy wrappers
You may still see:

```text
return call(child)
$retv = call(child)
my $retv = call(child)
push @items, call(child)
```

These forms are recognized for compatibility. However, in new helper-centric code, prefer:

```text
assign(scalar(retv), call(child))
push_value(array(items), scalar(retv))
```

## `push(rule)` and push variants
### Single-argument push

```text
push(child)
```

Meaning: call `child` and push its result into the current rule's array.

### Explicit target push

```text
push(child, items)
```

Meaning: call `child` and push its result into `@items`.

### Scope-injected compatibility form

```text
push(Top, child, items)
```

This is mainly useful as an emitted/internal compatibility shape for method-chain lowering.

## Return helper family
### `return_a(label[, arg])`
Return the label tag plus the current rule array.

Example:

```text
return_a(Top)
return_a(Top, scalar(name))
```

### `return_m(label)`
Return the label tag plus `IMATCH_LIST`.

Example:

```text
return_m(Top)
```

### `return_ma(label)`
Return the label tag plus `IMATCH_LIST` plus the current rule array.

Example:

```text
return_ma(Top)
```

### `return(label, arg)`
Legacy tagged return form.

Example:

```text
return(Top, scalar(name))
```

### `return_imatch(tag)` / `return_im(tag)`
Return a tagged immediate-match payload.

Examples:

```text
return_imatch(group_open)
return_im(group_open)
```

### `return_array(tag, payload)`
Return a tagged array payload.

Examples:

```text
return_array(semantic_annotation, array(scalar(IMATCH_LIST, 0), scalar(c)))
return_array(node, array(scalar(name), scalar(kind)))
```

### Preferred modern form
When you are writing new backend-neutral code, prefer the general `return(payload)` form whenever it expresses the intent clearly.

Examples:

```text
return(array("?node:", scalar(name), scalar(kind)))
return(hash("type", "SPACE", "content", scalar(IMATCH)))
```

The older return helpers are still important, but they are no longer the only practical way to express structured returns.

## Capture helpers
### `$CAPTURE`
Legacy capture macro.

Example:

```text
my $content = $CAPTURE
```

In new code, prefer helper assignment:

```text
assign(scalar(content), CAPTURE)
```

### `capture(label)`
Push a captured substring into the current rule array.

Example:

```text
capture(Top)
```

Use it when you want the current capture substring appended directly to the active rule payload without first binding it to a temporary scalar.

### `capture_if(label)` and `CAPTURE_IF()`
Conditionally capture and push the trimmed captured substring if it is nonempty.

Examples:

```text
capture_if(Top)
CAPTURE_IF()
```

These remain useful when migrating older capture-heavy specs.

### `capture_from(name)`
Return the captured substring from a named `@mark(name)` checkpoint to the left edge of the current match.

Practical reading:
- the earlier `@mark(name)` establishes the left boundary,
- the current regex or current child rule establishes the right boundary,
- the current local match itself is not included in the returned substring.

If the mark is absent, the helper returns `undef`.

One timing rule matters:
- `@mark(name)` becomes visible after the slot that carries it completes,
- so `capture_from(name)` is meant for later slots or later child calls, not the same slot that just established the mark.

Examples:

```text
assign(scalar(body), capture_from(body_start))
```

```text
Top::AND
 /foo\(/ @mark(body_start)
 -> Top[0] { return(call(Inner)) }

Inner::AND
 /\w+/
 -> Inner[0] { return(call(Child)) }

Child:
 /\)/
 -> Child[0] { return(array("?Child:", capture_from(body_start))) }
```

```text
Left::AND
 /\(/ @mark(left_start)
 -> Left[0] { return(call(LeftContent)) }

LeftContent::AND
 /[^,]+/
 -> LeftContent[0] { return(call(LeftSeparator)) }

LeftSeparator:
 /,/
 -> LeftSeparator[0] { return(array("?left:", capture_from(left_start))) }
```

```text
-> rule[0] {
     return(array("?body:", capture_from(body_start)))
   }
```

Use it when one anonymous split cursor is not enough and you want a later action block or child rule to refer back to a specific named checkpoint.

Documentation note:
- this guide prefers backend-neutral helper forms such as `return(payload)`, `assign(...)`, and `call(rule)` inside code blocks,
- while [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md) is where the Perl lowering is shown explicitly.

## Backtrack helpers
### `IBACKTRACK()` / `ibacktrack(label)`
Backtrack to the immediate-match side.

Examples:

```text
IBACKTRACK()
ibacktrack(Top)
```

### `BACKTRACK()` / `backtrack(label)`
Backtrack to the latest/closing-side match boundary.

Examples:

```text
BACKTRACK()
backtrack(Top)
```

These helpers are compatibility-important when reading older extraction-oriented specs.

## Compatibility wrapper patterns you will still see
The canonical rewriter still recognizes several raw-looking wrapper idioms.

Examples:

```text
my $retv = call(child)
$retv = call(child)
push @items, call(child)
push @items, call(child)->[0]
return call(child)
```

These are significant because older specs use them and they can still lower canonically. But if you are authoring new portable helper flow, prefer the explicit DSL shapes instead.

## Worked examples
### Example: old style versus preferred style
Old style:

```text
$retv = call(parenthesis)
```

Preferred style:

```text
assign(scalar(retv), call(parenthesis))
```

### Example: tagged immediate-match return

```text
return_imatch(group_open)
```

Useful when the semantic payload is simply “this tagged match happened.”

### Example: legacy push helper

```text
push(pipe_operator, rule)
```

Useful when you want “call rule and append result” in one helper surface.

## Recommendations
- Keep using compatibility helpers when maintaining existing specs that already depend on them.
- Prefer the newer canonical helper surface in freshly migrated rules.
- If you need a child result for later logic, prefer `assign(scalar(retv), call(rule))` over raw wrapper assignments.
- If you are returning a general structured object, prefer `return(payload)` over inventing a new tagged helper unless the tagged form already communicates the intent clearly.

## Related guides
- Value constructors and `return(payload)`: [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md)
- Control flow and branch statements: [`USER_GUIDE_ActionIR_ControlFlow.md`](USER_GUIDE_ActionIR_ControlFlow.md)
