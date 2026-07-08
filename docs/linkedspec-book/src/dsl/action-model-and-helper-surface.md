# Action Model and Helper Surface

LinkedSpec is in the middle of a long-term shift from older raw-Perl-shaped action habits toward a cleaner helper-driven DSL and canonical ActionIR lowering.

## The direction

The direction is:

- less raw embedded Perl
- more explicit helper contracts
- clearer lowering semantics
- better backend portability

The short version:

```text
old direction:  write parser actions as convenient embedded Perl
new direction:  write parser actions as explicit LinkedSpec helper DSL
```

The helper DSL still emits Perl today, but the intent is bigger than Perl. The helper surface describes parser intent in a way that can be lowered through ActionIR and eventually carried to other backends.

## Why this matters

The action surface is where a lot of parser power lives, but it is also where accidental complexity can creep in fast.

Treating the helper DSL as a real language surface, with explicit semantics and documentation, makes LinkedSpec easier to trust and easier to evolve.

## A tiny before/after

Older specs often needed raw Perl-shaped code to name a child result, push data, or return a structured node.

A helper-oriented rule should make the intent visible:

```text
Top::
 -> Value .push
 LX { return(copy(array(Top))) }

Value: /name=(\w+)/
 I {
   name = entry_group(0);
   return(hash("kind", "assignment", "name", name));
 }
```

That reads as:

- assign a fresh working scalar from the entry match capture group
- return a structured hash payload

The important part is not the exact emitted Perl. The important part is that the parser action expresses a portable semantic operation.

## Main helper families

The current helper surface is broad, but it is easier to learn in families. Each family serves a distinct purpose in the parser action lifecycle.

### Value and container helpers

Construct and transform values during parsing:

- `name` — read the named scalar working variable
- `array(name)` — read a named array value
- `hash(name)` — read a named hash value
- `flat_array(...)` — flatten arguments into an array
- `flat_hash(...)` — flatten key/value arguments into a hash
- `copy(...)` — shallow-copy a container
- `join_values(...)` — join array elements into a string
- `split_tagged_records(...)` — split a string into tagged records

Detailed reference: [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md).

### Working variables

Working variables auto-exist when they are first used through a typed position:

- `name = value` — bind the typed RHS value to `name`
- `items = []` — bind an array value to `items`
- `meta = { "kind" : value }` — bind a hash value to `meta`
- `items += value` or `push(array(items), value)` — append to an array
- `meta[key] = value` — mutate a hash

`declare(...)` is a retired legacy helper on current runtimes. The replacement policy is documented in
[Declaration Helper Reference](declaration-helper-reference.md). New examples should use the terse forms above.

### Assignment and mutation helpers

Write values into declared variables or containers:

- `set(target, value)` — write a value; `target = value` is the preferred operator form. Bare assignments bind the evaluated typed value and yield it in value positions.
- `name = value` — terse assignment operator; scalar, array, and hash RHS values all bind as the current typed value of `name`
- `=(name, value)` — operator-call spelling for the same assignment value expression
- `items += value` — terse array append operator; a bare RHS reads the scalar working variable `value`, while all-bare `push(A,B)` remains child-call syntax; in value positions it yields the updated array snapshot
- `push(container, value)` — append to an array
- `push(array(name), value)` — named-array push
- `if(is_nonempty(value)) { push(array(name), value) }` — named-array push with an explicit non-empty filter
- `set_key(name, key, value)` — set one key in a named working hash
- `name[key] = value` — terse hash-index assignment operator, equivalent to `set_key(name, key, value)` when the key and value are explicit expressions; in value positions it yields the updated hash snapshot
- `payload["items"][0]["name"] = value` — nested value-path assignment into a scalar-held array/hash payload; intermediate containers must already exist, final hash keys may be created, and final array indexes may replace or append at len

### Capture and mark helpers

Control parser cursor boundaries and capture text spans:

- `capture_slice()` — capture from last boundary to current position
- `capture_take()` — capture and advance the boundary
- `mark_here(name)` — place a named durable mark at the current position
- `capture_from(name)` — capture from a named mark to current position
- `capture_between(start_mark, end_mark)` — capture between two named marks
- `capture_rest_from(name)` — capture from a named mark to end of input

Detailed reference: [Capture, Marks, and Source Locations](capture-marks-and-source-locations.md) and [Source Boundary Helper Reference](source-boundary-helper-reference.md).

### Source-location helpers

Read the parser's current position in the input:

- `cursor_line()` — current line number
- `cursor_col()` — current column
- `cursor_pos()` — current cursor position (an offset into the input)
- `entry_start_pos()` — start position of the entry match
- `match_end_col()` — end column of the current match

### Input and match readers

Access the input text and match data:

- `input_text()` — the full input string
- `entry_text()` — the text of the match that entered this rule
- `entry_group(index)` — a specific capture group from the entry match
- `match_text()` — the text of the current local match

### Control-flow helpers

Structured branching within action bodies:

- `if(condition) { ... }` / `elseif(condition) { ... }` / `else { ... }` / `endif`
- `when(condition) { ... }` / `otherwise { ... }` as attached-block aliases for `if` / `else`
- `switch(value) { case("x") { ... } default { ... } }`
- `coalesce(...)` — return the first defined, non-empty value
- `is_defined(...)` / `has_key(...)` — existence checks

### Flow and method-chain helpers

Chain operations fluently on values:

- `.trim()`, `.lowercase()`, `.uppercase()` — string transforms
- `.coalesce()` — fluent fallback chaining
- `.length()` — string or array length
- Method chains use `.method(args)` syntax on action-edge targets and values.

Detailed reference: [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md).

### Output helpers

Emit debug or informational output during parsing:

- `say(...)` — print with newline
- `print(...)` — print without newline
- `print_each(...)` — print each element of an array

### Rule-dispatch helpers

Invoke child rules and handle results:

- `call(RuleName)` — call a child rule and capture its return value
- Combined with `retv = call(Child)` to store child results

## How helpers reach emitted code

Every helper call passes through the ActionIR lowering pipeline (see [ActionIR Lowering Mental Model](actionir-lowering-mental-model.md)):

1. `Scanner` discovers which contracts are present
2. `StatementSplit` splits compound action text into individual statements
3. `CanonicalEvents` normalizes each helper call into a canonical ActionIR event
4. The appropriate lowering owner (`MethodExpr`, `FlowExpr`, `ValueExpr`, `ControlFlow`, `MethodLowering`, `DeclareMethod`, `ArrayPipeline`, `Diagnostics`) lowers the event to emitted code
5. The final emitted Perl is generated — but the lowering pipeline is designed so that other backends can substitute their own final stage

This is why writing `name = entry_group(0)` is fundamentally different from writing raw Perl: the helper form is inspectable, validatable, and retargetable. Raw Perl is opaque to the lowering pipeline.

The linked chapters below introduce these families in public-facing terms. The repo-root ActionIR guides remain the exhaustive working references while the book continues growing.

## What to pair with this chapter

The repo’s ActionIR-focused guides remain the deeper working references while this book grows:

- `USER_GUIDE_ActionIR_Contracts.md`
- `USER_GUIDE_ActionIR_MethodLowering.md`
- `USER_GUIDE_ActionIR_EmittedPerlReference.md`

The long-term goal is for this book to absorb that surface in progressively clearer public-facing chapters.
