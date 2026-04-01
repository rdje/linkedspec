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

## Concise container aliases
The core container/value wrappers also accept short aliases:
- `s(...)` = `scalar(...)`
- `a(...)` = `array(...)`
- `h(...)` = `hash(...)`

These are concise DSL spellings only. They do not introduce Perl-style sigil syntax.

Examples:

```text
assign(s(name), entry_text())
assign(a(parts), a("A", "B"))
return(h("kind", entry_named(kind), "count", count(a(parts))))
```

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

### `capture_slice()`
Return the captured substring from the current anonymous capture boundary to the same slot-local right boundary that the old raw `$IPOS` / `$LSPOS` / `$LMATCH` pattern used.

Practical reading:
- the left boundary is the current anonymous capture boundary stored in `$IPOS`,
- the right boundary is exactly the same slot-local boundary that raw `substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)` would have used,
- the current local match itself is not included in the returned substring,
- and unlike `capture_from(name)`, this helper does not depend on any named mark.

Examples:

```text
assign(scalar(segment), capture_slice())
```

```text
Top::AND
 I { declare(scalar, first_span) }
 /\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(first_span), capture_slice()) }
 -> Top[1] { return(array("?Top:", scalar(first_span), capture_slice())) }
```

Use it when the rule wants the old raw `$IPOS` capture pattern explicitly, but the left boundary is the current anonymous capture cursor rather than one named checkpoint. `capture_from_rule_start()` remains supported as a compatibility alias for older migration slices.

### `capture_slice_len()`
Return the numeric length of the same anonymous capture-boundary span that `capture_slice()` would read.

Practical reading:
- the left boundary is still the current anonymous capture boundary stored in `$IPOS`,
- the right boundary is exactly the same slot-local boundary that raw `$LSPOS - $IPOS - length $LMATCH` would have used,
- the current local match itself is not included in that span,
- and the helper returns the width of that span instead of materializing the substring.

Examples:

```text
assign(scalar(width), capture_slice_len())
```

```text
Top::AND
 I { declare(scalar, first_width) }
 /\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(first_width), capture_slice_len()) }
 -> Top[1] { return(array("?Top:", scalar(first_width), capture_slice_len())) }
```

Use it when the rule needs that same anonymous-capture-boundary model as `capture_slice()` but only wants length metadata. `capture_slice_length()` remains supported as a longer compatibility alias, and `capture_len_from_rule_start()` remains supported for older migration slices.

### `capture_slice_until_cursor()`
Return the substring from the current anonymous capture boundary through the live parser cursor.

Practical reading:
- the left boundary is still the current anonymous capture boundary stored in `$IPOS`,
- the right boundary is the current parser cursor from `pos $$STRING`,
- unlike `capture_slice()`, this helper includes text that the parser has already consumed through the current slot,
- and unlike `capture_rest()`, it stops at the current parser cursor instead of running through end-of-input.

Examples:

```text
assign(scalar(segment), capture_slice_until_cursor())
```

```text
Top::AND
 /\(/
 -> Top[0] { start_capture_slice() }
 /\w+/
 -> Top[1] { return(array("?Top:", capture_slice_until_cursor(), capture_slice_until_cursor_len())) }
```

Use it when the rule wants the current anonymous slice through the live parser cursor explicitly, instead of stopping at the current match edge or extending all the way through end-of-input.

### `capture_slice_until_cursor_len()`
Return the numeric length of the same anonymous capture-boundary through-cursor span that `capture_slice_until_cursor()` would read.

Practical reading:
- the left boundary is still the current anonymous capture boundary stored in `$IPOS`,
- the right boundary is still the live parser cursor,
- the helper returns the through-cursor width instead of materializing the substring,
- and unlike `capture_slice_len()`, it measures through the current parser cursor rather than stopping at the current match edge.

Examples:

```text
assign(scalar(width), capture_slice_until_cursor_len())
```

```text
Top::AND
 /\(/
 -> Top[0] { start_capture_slice() }
 /\w+/
 -> Top[1] { return(array("?Top:", capture_slice_until_cursor_len())) }
```

Use it when the rule needs the width of that same anonymous through-cursor span but does not need the span text itself.

### `capture_slice_pos()`
Return the numeric position of the current anonymous capture boundary.

Practical reading:
- the returned value is the current anonymous capture boundary stored in `$IPOS`,
- unlike `cursor_pos()`, it does not follow the live parser cursor after that boundary is established,
- unlike `mark_pos(name)`, it does not depend on any named checkpoint being present,
- and it pairs naturally with `@capture_slice` or `start_capture_slice()` when the rule wants to expose the remembered slice start directly as data.

Examples:

```text
assign(scalar(slice_begin), capture_slice_pos())
```

```text
Top::AND
 /prefix/
 -> Top[0] { start_capture_slice() }
 /\(/
 /\w+/
 -> Top[1] { return(array("?Top:", capture_slice_pos(), cursor_pos())) }
```

Use it when the rule wants to report or store where the current anonymous capture slice began numerically, instead of spelling raw `$IPOS` reads inline.

### `capture_slice_line()`
Return the 1-based line number of the current anonymous capture boundary.

Practical reading:
- the left boundary is still the current anonymous capture boundary stored in `$IPOS`,
- the helper counts line breaks from the beginning of the current input through that stored boundary,
- it reports where the current anonymous capture slice starts,
- and unlike `cursor_line()`, it does not follow the live parser cursor after that boundary is established.

Examples:

```text
print("starting on line ", capture_slice_line(), "\n")
```

```text
Top::AND
 /prefix\n/
 -> Top[0] { start_capture_slice() }
 /\(/
 /\w+/
 -> Top[1] { return(array("?Top:", capture_slice_line())) }
```

Use it when the rule wants diagnostics or metadata about where the current anonymous capture slice began, especially in later `LX` or action-edge code that used to count newlines from `$IPOS` by hand.

### `capture_slice_col()`
Return the 1-based column number of the current anonymous capture boundary.

Practical reading:
- the left boundary is still the current anonymous capture boundary stored in `$IPOS`,
- the helper computes a 1-based column from that stored boundary relative to the most recent preceding newline,
- it reports where the current anonymous capture slice starts on its line,
- and unlike `cursor_col()`, it does not follow the live parser cursor after that boundary is established.

Examples:

```text
print("starting in column ", capture_slice_col(), "\n")
```

```text
Top::AND
 /foo /
 -> Top[0] { start_capture_slice() }
 /\(/
 /\w+/
 -> Top[1] { return(array("?Top:", capture_slice_col())) }
```

Use it when the rule wants diagnostics or metadata about where the current anonymous capture slice began horizontally, especially in later same-rule code that used to carry raw `$IPOS`-based column math inline.

### `start_capture_slice()`
Move the current anonymous capture boundary to the current parser position.

Practical reading:
- this is the explicit code-block form of the same anonymous-boundary move that `@capture_slice` expresses at the paragraph level,
- it writes the current parser position into the anonymous capture-boundary slot,
- it does not return captured text by itself,
- and later `capture_slice()`, `capture_slice_len()`, `capture_rest()`, and `capture_rest_len()` reads start from that new boundary.

Examples:

```text
start_capture_slice()
```

```text
Top::AND
 I { declare(scalar, tail) }
 /\(/
 -> Top[0] { start_capture_slice() }
 /\w+/
 -> Top[1] { assign(scalar(tail), capture_rest()) }
 /\)/
 -> Top[2] { return(array("?Top:", scalar(tail), capture_rest_len())) }
```

Use it when the rule should begin a new anonymous capture slice explicitly from inside a lifecycle or action block, instead of spelling `assign(s(IPOS), cursor_pos())` directly. `capture_slice_here()` remains supported as a compatibility alias.

### `start_capture_slice_from(name)`
Reset the current anonymous capture boundary from a stored rule-local named mark.

Practical reading:
- use it when the rule already has a meaningful named checkpoint and wants the anonymous rolling capture model to resume from that exact stored boundary,
- treat it as the named-to-anonymous bridge companion to `mark_capture_slice(name)`,
- compare it with `start_capture_slice()` when the new anonymous boundary should come from the live parser cursor instead of a stored mark,
- and expect `undef` when the named mark is absent.

Examples:

```text
start_capture_slice_from(body_start)
```

```text
Top::AND
 I { declare(scalar, first, second) }
 /foo\(/
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /,\s*(?=gamma)/
 /gamma/
 /\)/
 -> Top[0] { start_capture_slice() }
 -> Top[2] { mark_capture_slice(body_start); assign(scalar(first), capture_take()) }
 -> Top[4] { assign(scalar(second), capture_take()); start_capture_slice_from(body_start) }
 -> Top[6] { return(array("?Top:", scalar(first), scalar(second), capture_slice())) }
```

On input `foo(alpha, beta, gamma)`:
- `start_capture_slice()` establishes the anonymous boundary just after `(`,
- `mark_capture_slice(body_start)` snapshots that anonymous boundary under the stable named mark `body_start`,
- the two `capture_take()` calls roll the anonymous boundary forward across `alpha` and `beta`,
- `start_capture_slice_from(body_start)` restores the anonymous boundary back to the original stored `body_start`,
- and the final `capture_slice()` returns `alpha, beta, gamma`.

Use it when the rule wants one stable named checkpoint for later recovery, but also wants to keep using the concise anonymous rolling-boundary helpers after restoring that remembered left edge.

### `capture_rest()`
Return the substring from the current anonymous capture boundary through end-of-input.

Practical reading:
- the left boundary is the current anonymous capture boundary stored in `$IPOS`,
- the right boundary is the end of the current input string,
- the current local match is included if it lies to the right of that anonymous boundary,
- and unlike `capture_from(name)`, this helper does not depend on any named mark.

Examples:

```text
assign(scalar(tail), capture_rest())
```

```text
Top::AND
 I { declare(scalar, tail) }
 /\(/
 -> Top[0] { start_capture_slice() }
 /\w+/
 -> Top[1] { assign(scalar(tail), capture_rest()) }
 /\)/
 -> Top[2] { return(array("?Top:", scalar(tail), capture_rest())) }
```

Use it when the rule wants the current anonymous capture-boundary tail directly, rather than a current-slot slice. This is the explicit helper form of the old raw `substr($$STRING, $IPOS, length($$STRING) - $IPOS)` pattern.

### `capture_rest_len()`
Return the numeric length of the same anonymous capture-boundary tail that `capture_rest()` would read.

Practical reading:
- the left boundary is still the current anonymous capture boundary stored in `$IPOS`,
- the right boundary is the end of the current input string,
- the helper returns the remaining width from that anonymous boundary instead of materializing the substring,
- and `capture_rest_length()` remains supported as a longer compatibility alias.

Examples:

```text
assign(scalar(width), capture_rest_len())
```

```text
Top::AND
 I { declare(scalar, width) }
 /\(/
 -> Top[0] { start_capture_slice() }
 /\w+/
 -> Top[1] { assign(scalar(width), capture_rest_len()) }
 /\)/
 -> Top[2] { return(array("?Top:", scalar(width), capture_rest_len())) }
```

Use it when the rule needs the width of that same anonymous-boundary tail but does not need the tail text itself.

### `capture_take()`
Return the same anonymous capture-boundary span that `capture_slice()` would read, then advance that anonymous boundary to the current parser position.

Practical reading:
- use it when one anonymous capture boundary is enough, but later same-rule reads should continue from the current parser position,
- treat it as the anonymous advancing-read companion to stable `capture_slice()`,
- compare it with `capture_take(name)` on the named-checkpoint side when the rule does need more than one stable remembered boundary,
- and prefer it over hand-spelling `capture_slice()` plus a separate `start_capture_slice()` or raw `$IPOS = pos $$STRING` update when the rule really wants “read and advance” as one step.

Example:

```text
capture_take()
```

```text
Top::AND
 I { declare(scalar, first, second) }
 /foo\(/
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /,\s*(?=gamma)/
 /gamma/
 /\)/
 -> Top[0] { start_capture_slice() }
 -> Top[2] { assign(scalar(first), capture_take()) }
 -> Top[4] { assign(scalar(second), capture_take()) }
 -> Top[6] { return(array("?Top:", scalar(first), scalar(second), capture_slice())) }
```

On input:

```text
foo(alpha, beta, gamma)
```

the practical reading is:
- `start_capture_slice()` establishes the anonymous left boundary just after `(`,
- the first `capture_take()` returns `alpha` and advances that anonymous boundary to just after the first comma,
- the second `capture_take()` returns `beta` and advances that anonymous boundary to just after the second comma,
- the final `capture_slice()` then returns `gamma` from the advanced anonymous boundary through the left edge of `)`,
- and no named checkpoint is needed because the rule only needs one rolling anonymous boundary.

Use it when the rule wants split-cursor-style advancing capture semantics without introducing a named checkpoint just to move a single rolling boundary forward.

### `capture_from(name)`
Return the captured substring from a named `@mark(name)` checkpoint to the left edge of the current match.

Practical reading:
- the earlier `@mark(name)` establishes the left boundary,
- a later regex slot in that same rule establishes the right boundary,
- the current local match itself is not included in the returned substring.

If the mark is absent, the helper returns `undef`.

The mark name is scoped to the current rule label:
- different rules can reuse the same mark name safely,
- child rules do not inherit a parent rule's named marks automatically.

One timing rule matters:
- `@mark(name)` becomes visible after the slot that carries it completes,
- so `capture_from(name)` is meant for later slots in that same rule, not the same slot that just established the mark.

Examples:

```text
assign(scalar(body), capture_from(body_start))
```

```text
Top::AND
 I { declare(scalar, stage) }
 /foo\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body") }
 -> Top[2] { return(array("?Top:", capture_from(body_start))) }
```

```text
Left::AND
 I { declare(scalar, stage) }
 /\(/
 @mark(left_start)
 /[^,]+/
 /,/
 -> Left[0] { assign(scalar(stage), "open") }
 -> Left[1] { assign(scalar(stage), "content") }
 -> Left[2] { return(array("?left:", capture_from(left_start))) }
```

```text
-> rule[0] {
     return(array("?body:", capture_from(body_start)))
   }
```

Use it when one anonymous split cursor is not enough and you want a later action block in that same rule to refer back to a specific named checkpoint.

### `capture_len_from(name)`
Return the numeric length of the same current-edge span that `capture_from(name)` would read.

Practical reading:
- the earlier `@mark(name)` establishes the left boundary,
- a later regex slot in that same rule still establishes the right boundary,
- the current local match itself is not included in that span,
- and the helper returns the width of that span instead of materializing the substring.

If the mark is absent, the helper returns `undef`.

The mark name is scoped to the current rule label:
- different rules can reuse the same mark name safely,
- child rules do not inherit a parent rule's named marks automatically.

Examples:

```text
assign(scalar(width), capture_len_from(body_start))
```

```text
Top::AND
 I { declare(scalar, stage) }
 /foo\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body") }
 -> Top[2] { return(array("?Top:", capture_len_from(body_start), capture_len_from(missing_mark))) }
```

```text
-> rule[2] {
     return(array("?meta:", capture_len_from(body_start)))
   }
```

Use it when the rule needs the same current-edge boundary semantics as `capture_from(name)` but only wants length metadata, not the substring itself.

### `capture_until_cursor_from(name)`
Return the substring from a named `@mark(name)` checkpoint through the live parser cursor.

Practical reading:
- the earlier `@mark(name)` establishes the left boundary,
- the right boundary is the current parser cursor from `pos $$STRING`,
- unlike `capture_from(name)`, this helper does not stop at the left edge of the current match,
- and unlike `capture_rest_from(name)`, it stops at the live parser cursor instead of extending through end-of-input.

If the mark is absent, the helper returns `undef`.

Examples:

```text
assign(scalar(segment), capture_until_cursor_from(body_start))
```

```text
Top::AND
 /\(/
 @mark(body_start)
 /\w+/
 -> Top[0] { }
 -> Top[1] { return(array("?Top:", capture_until_cursor_from(body_start), capture_until_cursor_len_from(body_start))) }
```

Use it when the rule wants a stable named checkpoint as the left edge but wants the right edge to be the current live parser cursor rather than the current match edge or end-of-input.

### `capture_until_cursor_len_from(name)`
Return the numeric length of the same named-mark through-cursor span that `capture_until_cursor_from(name)` would read.

Practical reading:
- the earlier `@mark(name)` still establishes the left boundary,
- the right boundary is still the live parser cursor,
- the helper returns the through-cursor width instead of materializing the substring,
- and unlike `capture_rest_len_from(name)`, it stops at the current parser cursor instead of extending through end-of-input.

If the mark is absent, the helper returns `undef`.

Examples:

```text
assign(scalar(width), capture_until_cursor_len_from(body_start))
```

```text
Top::AND
 /\(/
 @mark(body_start)
 /\w+/
 -> Top[0] { }
 -> Top[1] { return(array("?Top:", capture_until_cursor_len_from(body_start), capture_until_cursor_len_from(missing_mark))) }
```

Use it when the rule needs the width of that same named-mark through-cursor span but does not need the span text itself.

### `capture_take(name)`
Return the same substring that `capture_from(name)` would return, then advance that named mark to the current parser position.

In high/debug trace mode, that advancing write now also emits a short input excerpt plus a caret under the new stored position.

Practical reading:
- the earlier `@mark(name)` establishes the left boundary,
- the current match still establishes the right boundary,
- the returned substring still excludes the current local match,
- and after the read, the named mark moves forward like a named split cursor.

If the mark is absent, the helper returns `undef` and leaves the mark unchanged.

Examples:

```text
assign(scalar(part), capture_take(body_start))
```

```text
Top::AND
 I { declare(scalar, stage, first, second) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /,\s*(?=gamma)/
 /gamma/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "first_value") }
 -> Top[2] { assign(scalar(first), capture_take(body_start)) }
 -> Top[3] { assign(scalar(stage), "second_value") }
 -> Top[4] { assign(scalar(second), capture_take(body_start)) }
 -> Top[5] { assign(scalar(stage), "third_value") }
 -> Top[6] { return(array("?Top:", scalar(first), scalar(second), capture_from(body_start))) }
```

Use it when the same rule should keep consuming successive named spans instead of reading repeatedly from one stable checkpoint.

### `capture_rest_from(name)`
Return the substring from a named `@mark(name)` checkpoint through end-of-input.

Practical reading:
- the earlier `@mark(name)` establishes the left boundary,
- the right boundary is the end of the current input string rather than the current match edge,
- the current local match is included if it lies to the right of that named checkpoint,
- and unlike `capture_from(name)`, this helper does not stop at the left edge of the current match.

If the mark is absent, the helper returns `undef`.

Examples:

```text
assign(scalar(tail), capture_rest_from(body_start))
```

```text
Top::AND
 I { declare(scalar, stage) }
 /\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body") }
 -> Top[2] { return(array("?Top:", capture_rest_from(body_start))) }
```

Use it when the rule wants a remembered named checkpoint as the left edge but wants the right edge to be the real end of input, not the current match boundary.

### `capture_rest_len_from(name)`
Return the numeric length of the same named-mark tail that `capture_rest_from(name)` would read.

Practical reading:
- the earlier `@mark(name)` still establishes the left boundary,
- the right boundary is still the end of the current input string,
- the helper returns the remaining width from that named checkpoint instead of materializing the substring,
- and unlike `capture_len_from(name)`, it does not stop at the current match edge.

If the mark is absent, the helper returns `undef`.

Examples:

```text
assign(scalar(width), capture_rest_len_from(body_start))
```

```text
Top::AND
 I { declare(scalar, stage) }
 /\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body") }
 -> Top[2] { return(array("?Top:", capture_rest_len_from(body_start), capture_rest_len_from(missing_mark))) }
```

Use it when the rule needs the width of that same named-checkpoint tail through end-of-input but does not need the tail text itself.

### `capture_between(start_mark, end_mark)`
Return the substring between two explicit rule-local named marks.

Practical reading:
- use it when the left edge and right edge should both come from named checkpoints instead of from the current match,
- combine `@mark(name)` or `mark_here(name)` to establish those checkpoints deliberately,
- and treat it as the two-mark companion to `capture_from(name)`.

If either mark is absent, or if the end mark is before the start mark, the helper returns `undef`.

Example:

```text
capture_between(body_start, first_end)
```

```text
Top::AND
 I { declare(scalar, stage, first_segment) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "first_value"); mark_here(first_end) }
 -> Top[2] { assign(scalar(stage), "separator"); assign(scalar(first_segment), capture_between(body_start, first_end)) }
 -> Top[3] { assign(scalar(stage), "second_value") }
 -> Top[4] { return(array("?Top:", scalar(first_segment), capture_from(body_start))) }
```

Use it when the rule wants an explicit two-mark span instead of the usual “named mark to current match edge” capture shape.

### `capture_len_between(start_mark, end_mark)`
Return the numeric length of the same explicit two-mark span that `capture_between(start_mark, end_mark)` would read.

Practical reading:
- use it when the left edge and right edge should both come from named checkpoints instead of from the current match,
- keep the same explicit remembered-boundary model as `capture_between(start_mark, end_mark)`,
- but return the width of that span instead of materializing the substring.

If either mark is absent, or if the end mark is before the start mark, the helper returns `undef`.

Example:

```text
capture_len_between(body_start, first_end)
```

```text
Top::AND
 I { declare(scalar, stage, first_segment) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "first_value"); mark_here(first_end) }
 -> Top[2] { assign(scalar(stage), "separator"); assign(scalar(first_segment), capture_between(body_start, first_end)) }
 -> Top[3] { assign(scalar(stage), "second_value") }
 -> Top[4] { return(array("?Top:", scalar(first_segment), capture_len_between(body_start, first_end), capture_len_between(body_start, missing_end))) }
```

Use it when the rule wants explicit remembered-boundary width metadata instead of the actual two-mark substring.

### `capture_take_between(start_mark, end_mark)`
Return the substring between two explicit rule-local named marks, then advance the start mark to the stored end mark.

Practical reading:
- use it when the rule wants an explicit remembered right boundary,
- but also wants the start mark to roll forward to that boundary after the read,
- and treat it as the advancing two-mark companion to stable `capture_between(start_mark, end_mark)`.

If either mark is absent, or if the end mark is before the start mark, the helper returns `undef` and leaves the start mark unchanged.

Example:

```text
capture_take_between(body_start, first_end)
```

```text
Top::AND
 I { declare(scalar, stage, first_segment) }
 /foo/
 @mark(body_start)
 /alpha/
 /beta/
 /END/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body") }
 -> Top[2] { mark_match_start(first_end); assign(scalar(first_segment), capture_take_between(body_start, first_end)) }
 -> Top[3] { mark_match_start(final_end); return(array("?Top:", scalar(first_segment), capture_between(body_start, final_end))) }
```

Use it when the rule should keep the clarity of explicit remembered boundaries but also wants the left boundary to advance after the read, instead of hand-composing that advance outside the helper.

### `mark_here(name)`
Set or overwrite a named `@mark(name)` checkpoint to the current parser position without reading from it first.

In high/debug trace mode, this explicit write now also emits a short input excerpt plus a caret under the stored checkpoint position.

Practical reading:
- use `@mark(name)` when a rule paragraph member should establish the mark,
- use `mark_here(name)` when a later action block in that same rule should move that mark explicitly,
- and combine it with `capture_from(name)` when you want stable read first, explicit advance second.

Example:

```text
mark_here(body_start)
```

```text
Top::AND
 I { declare(scalar, stage, first) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "first_value") }
 -> Top[2] { assign(scalar(first), capture_from(body_start)); mark_here(body_start) }
 -> Top[3] { assign(scalar(stage), "second_value") }
 -> Top[4] { return(array("?Top:", scalar(first), capture_from(body_start))) }
```

Use it when the rule should decide explicitly when the named checkpoint moves, instead of tying that movement to `capture_take(name)`.

### `mark_match_start(name)`
Set or overwrite a named `@mark(name)` checkpoint to the left edge of the current match.

In high/debug trace mode, this explicit left-edge write now also emits a short input excerpt plus a caret under the stored checkpoint position.

Practical reading:
- use it when the rule should remember where the current match begins rather than where it ends,
- combine it with `capture_between(start_mark, end_mark)` when an end marker should exclude the current closing token or delimiter,
- and treat it as the left-edge companion to post-match `mark_here(name)`.

Example:

```text
mark_match_start(end_mark)
```

```text
Top::AND
 I { declare(scalar, stage) }
 /foo\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body") }
 -> Top[2] { mark_match_start(end_mark); mark_here(after_end); return(array("?Top:", capture_between(body_start, end_mark), capture_between(body_start, after_end))) }
```

Use it when the rule wants a left-edge checkpoint for the current match instead of the usual post-match parser position stored by `@mark(name)` or `mark_here(name)`.

### `mark_copy(target_mark, source_mark)`
Copy one explicit rule-local named mark position into another named mark.

In high/debug trace mode, this explicit write also emits a short input excerpt plus a caret under the copied target position.

Practical reading:
- use it when the rule already remembered a boundary under one mark name,
- and a later action block should move or duplicate another named checkpoint to that remembered boundary,
- especially after a pure numeric span read like `capture_len_between(...)` that should not mutate marks on its own.

If the source mark is absent, the helper clears the target mark and returns `undef`.

Example:

```text
mark_copy(body_start, first_end)
```

```text
Top::AND
 I { declare(scalar, stage, first_len) }
 /foo/
 @mark(body_start)
 /alpha/
 /beta/
 /END/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body") }
 -> Top[2] { mark_match_start(first_end); assign(scalar(first_len), capture_len_between(body_start, first_end)); mark_copy(body_start, first_end) }
 -> Top[3] { mark_match_start(final_end); return(array("?Top:", scalar(first_len), capture_between(body_start, final_end), mark_copy(after_end, missing_end), mark_pos(after_end))) }
```

Use it when the rule needs an explicit “target becomes source” checkpoint operation instead of bundling that state move into another capture helper.

### `mark_capture_slice(name)`
Copy the current anonymous capture boundary into a rule-local named mark.

In high/debug trace mode, this explicit write also emits a short input excerpt plus a caret under the stored checkpoint position.

Practical reading:
- use it when one anonymous rolling boundary is still the convenient active model,
- but a later same-rule action will need to recover that anonymous boundary under a stable explicit name,
- treat it as the anonymous-to-named bridge companion to `start_capture_slice_from(name)`,
- and compare it with `mark_here(name)` when the stored boundary should come from the live parser cursor rather than the current anonymous capture slice.

Example:

```text
mark_capture_slice(body_start)
```

```text
Top::AND
 I { declare(scalar, first, second) }
 /foo\(/
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /,\s*(?=gamma)/
 /gamma/
 /\)/
 -> Top[0] { start_capture_slice() }
 -> Top[2] { mark_capture_slice(body_start); assign(scalar(first), capture_take()) }
 -> Top[4] { assign(scalar(second), capture_take()); start_capture_slice_from(body_start) }
 -> Top[6] { return(array("?Top:", scalar(first), scalar(second), capture_slice())) }
```

On input `foo(alpha, beta, gamma)`:
- `mark_capture_slice(body_start)` stores the current anonymous capture-boundary position, not the live parser cursor,
- so the named mark keeps the original left edge even after later `capture_take()` calls advance the anonymous boundary,
- and `start_capture_slice_from(body_start)` can later restore that original boundary for one more anonymous `capture_slice()` read.

Use it when the rule starts in the anonymous rolling-boundary model but later discovers that one of those anonymous boundaries deserves a stable explicit name.

### `clear_mark(name)`
Delete a rule-local named mark explicitly.

Practical reading:
- use it when a named checkpoint should no longer be visible to later reads in the same rule,
- combine it with `capture_from(name)` when you want one stable read and then an explicit drop,
- and treat it as the clear/reset companion to `mark_here(name)`.

Example:

```text
clear_mark(body_start)
```

```text
Top::AND
 I { declare(scalar, stage, first) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "first_value") }
 -> Top[2] { assign(scalar(first), capture_from(body_start)); clear_mark(body_start) }
 -> Top[3] { assign(scalar(stage), "second_value") }
 -> Top[4] { return(array("?Top:", scalar(first), capture_from(body_start))) }
```

Use it when the rule should make a named checkpoint unavailable to later same-rule reads instead of merely moving it.

### `mark_exists(name)`
Check whether a rule-local named mark is currently present.

Practical reading:
- use it when a rule should branch on whether a checkpoint still exists,
- combine it with `clear_mark(name)` when one action should both drop a checkpoint and later report that it is gone,
- and treat it as the presence-check companion to `capture_from(name)`.

Example:

```text
mark_exists(body_start)
```

```text
Top::AND
 I { declare(scalar, stage, before_clear) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "first_value") }
 -> Top[2] { assign(scalar(before_clear), mark_exists(body_start)); clear_mark(body_start) }
 -> Top[3] { assign(scalar(stage), "second_value") }
 -> Top[4] { return(array("?Top:", scalar(before_clear), mark_exists(body_start))) }
```

Use it when the rule should expose whether a named checkpoint is present without reading or mutating the captured span itself.

It is also supported inside backend-neutral flow conditions, for example:

```text
if(mark_exists(body_start)); assign(scalar(state), "present"); else; assign(scalar(state), "missing"); endif
```

### `mark_pos(name)`
Return the stored numeric position of a rule-local named mark.

Practical reading:
- use it when the rule wants the checkpoint itself as data,
- combine it with `mark_match_start(name)` or `mark_here(name)` when the rule wants to report or compare stored boundaries explicitly,
- and treat it as the position-read companion to `mark_exists(name)`.

If the named mark is absent, the helper returns `undef`.

Example:

```text
mark_pos(body_start)
```

```text
Top::AND
 I { declare(scalar, stage, begin_pos, end_pos) }
 /foo\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body"); assign(scalar(begin_pos), mark_pos(body_start)) }
 -> Top[2] { mark_match_start(end_mark); assign(scalar(end_pos), mark_pos(end_mark)); return(array("?Top:", scalar(begin_pos), scalar(end_pos), capture_between(body_start, end_mark), mark_pos(missing_mark))) }
```

Use it when the rule should expose explicit numeric checkpoint metadata without mutating the mark bucket.

### `mark_line(name)`
Return the 1-based line number of a rule-local named mark.

Practical reading:
- use it when the rule wants checkpoint line metadata rather than only the raw numeric position,
- combine it with `@mark(name)`, `mark_here(name)`, or `mark_match_start(name)` when the rule wants to report where a remembered boundary landed,
- and treat it as the line-read companion to `mark_pos(name)`.

If the named mark is absent, the helper returns `undef`.

Example:

```text
mark_line(body_start)
```

```text
Top::AND
 I { declare(scalar, stage, begin_line, end_line) }
 /foo\n/
 @mark(body_start)
 /bar\n/
 /baz/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body"); assign(scalar(begin_line), mark_line(body_start)) }
 -> Top[2] { mark_match_start(end_mark); assign(scalar(end_line), mark_line(end_mark)); return(array("?Top:", scalar(begin_line), scalar(end_line), mark_line(missing_mark))) }
```

Use it when the rule should expose explicit checkpoint line metadata without mutating the mark bucket.

### `mark_col(name)`
Return the 1-based column number of a rule-local named mark.

Practical reading:
- use it when the rule wants checkpoint column metadata rather than only the raw numeric position,
- combine it with `@mark(name)`, `mark_here(name)`, or `mark_match_start(name)` when the rule wants to report where a remembered boundary landed on its line,
- and treat it as the column-read companion to `mark_pos(name)` and `mark_line(name)`.

If the named mark is absent, the helper returns `undef`.

Example:

```text
mark_col(body_start)
```

```text
Top::AND
 I { declare(scalar, stage, begin_col, end_col) }
 /foo /
 @mark(body_start)
 /bar /
 /baz/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body"); assign(scalar(begin_col), mark_col(body_start)) }
 -> Top[2] { mark_match_start(end_mark); assign(scalar(end_col), mark_col(end_mark)); return(array("?Top:", scalar(begin_col), scalar(end_col), mark_col(missing_mark))) }
```

Use it when the rule should expose explicit checkpoint column metadata without mutating the mark bucket.

### `cursor_pos()`
Return the current parser cursor position directly.

Practical reading:
- use it when the rule wants the current parser-position offset as data,
- prefer it over spelling raw `pos $$STRING` inline in normal user-facing `.spec` examples,
- prefer it over `mark_pos(name)` when there is no reason to store a checkpoint first,
- and treat it as the direct cursor-side position helper paired with `cursor_line()`.

Example:

```text
cursor_pos()
```

```text
Top::AND
 I { declare(scalar, open_end, body_end, close_end) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(open_end), cursor_pos()) }
 -> Top[1] { assign(scalar(body_end), cursor_pos()) }
 -> Top[2] { assign(scalar(close_end), cursor_pos()); return(array("?Top:", scalar(open_end), scalar(body_end), scalar(close_end), cursor_pos(), entry_end_pos())) }
```

Use it when the rule should expose the current parser position directly without storing a named checkpoint first.

### `cursor_line()`
Return the 1-based line number at the current parser cursor directly.

Practical reading:
- use it when the rule wants the current parser-position line as data,
- prefer it over manual `substr($$STRING, 0, $IPOS) =~ /\n/g` counting in normal user-facing `.spec` examples,
- expect it to track the live parser cursor as same-rule slots advance, not just the rule-entry snapshot,
- and treat it as the direct cursor-side line helper when no checkpoint or match-boundary helper is needed first.

Example:

```text
cursor_line()
```

```text
Top::AND
 I { declare(scalar, open_line, close_line) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(open_line), cursor_line()) }
 -> Top[1] { assign(scalar(close_line), match_line()) }
 -> Top[2] { return(array("?Top:", scalar(open_line), scalar(close_line), cursor_line(), match_line())) }
```

Use it when the rule wants the live current parser cursor line directly instead of spelling raw prefix-newline counting inline.

### `cursor_col()`
Return the 1-based column number at the current parser cursor directly.

Practical reading:
- use it when the rule wants the current parser-position column as data,
- prefer it over manual `pos $$STRING` plus newline math in normal user-facing `.spec` examples,
- expect it to track the live parser cursor as same-rule slots advance, not just the rule-entry snapshot,
- and treat it as the direct cursor-side column helper when no checkpoint or match-boundary helper is needed first.

Example:

```text
cursor_col()
```

```text
Top::AND
 I { declare(scalar, first_col, second_col, third_col) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(first_col), cursor_col()) }
 -> Top[1] { assign(scalar(second_col), cursor_col()) }
 -> Top[2] { assign(scalar(third_col), cursor_col()); return(array("?Top:", scalar(first_col), scalar(second_col), scalar(third_col), cursor_col(), match_col())) }
```

Use it when the rule wants the live current parser cursor column directly instead of spelling raw same-line position math inline.

### `cursor_rest()`
Return the remaining input from the live parser cursor through end-of-input.

Practical reading:
- use it when the rule wants “what remains right now?” as text,
- prefer it over raw `substr($$STRING, pos $$STRING, ...)` in normal user-facing `.spec` examples,
- prefer it over `capture_rest()` when the left edge should be the live parser cursor rather than the anonymous capture boundary,
- prefer it over `capture_rest_from(name)` when there is no reason to store a named checkpoint first,
- and treat it as the direct live-cursor tail helper paired with `cursor_rest_len()`.

Simple form:

```text
cursor_rest()
```

Worked same-rule example:

```text
Top::AND
 I { declare(scalar, after_open_tail, after_body_tail) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(after_open_tail), cursor_rest()) }
 -> Top[1] { assign(scalar(after_body_tail), cursor_rest()) }
 -> Top[2] { return(array("?Top:", scalar(after_open_tail), scalar(after_body_tail), cursor_rest())) }
```

On input:

```text
foo(bar)
```

the practical reading is:
- after `/foo\(/`, the live parser cursor is just after `(`, so `cursor_rest()` returns `bar)`,
- after `/\w+/`, the live parser cursor is just after `bar`, so `cursor_rest()` returns `)`,
- after `/\)/`, the live parser cursor is at end-of-input, so `cursor_rest()` returns the empty string,
- and no anonymous or named checkpoint needs to be stored first because the helper reads directly from the live parser cursor.

Use it when the rule wants the live parser-cursor tail text directly without first storing a named or anonymous checkpoint.

### `cursor_rest_len()`
Return the numeric width of the remaining input from the live parser cursor through end-of-input.

Practical reading:
- use it when the rule wants “how much input remains right now?” as a number,
- prefer it over raw `length($$STRING) - pos $$STRING` in normal user-facing `.spec` examples,
- treat it as the width-only companion to `cursor_rest()`,
- prefer it over `capture_rest_len()` when the left edge should be the live parser cursor rather than the anonymous capture boundary,
- and prefer it over `capture_rest_len_from(name)` when there is no reason to store a named checkpoint first.

Simple form:

```text
cursor_rest_len()
```

Worked same-rule example:

```text
Top::AND
 I { declare(scalar, after_open_width, after_body_width) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(after_open_width), cursor_rest_len()) }
 -> Top[1] { assign(scalar(after_body_width), cursor_rest_len()) }
 -> Top[2] { return(array("?Top:", scalar(after_open_width), scalar(after_body_width), cursor_rest_len())) }
```

On input:

```text
foo(bar)
```

the practical reading is:
- after `/foo\(/`, `cursor_rest_len()` returns `4` for `bar)`,
- after `/\w+/`, it returns `1` for `)`,
- after `/\)/`, it returns `0` because the parser cursor is already at end-of-input,
- and the helper tracks the live cursor directly rather than a remembered mark or anonymous capture boundary.

Use it when the rule wants the live parser-cursor tail width directly instead of materializing that tail as text.

### `entry_text()`
Return the current immediate match text directly.

Practical reading:
- use it when the rule wants the entry/immediate match that led into the current rule,
- prefer it over raw `$IMATCH` in normal user-facing `.spec` examples when an explicit helper spelling is clearer,
- and treat it as the direct-immediate-text companion to `entry_len()` / `entry_start_pos()` / `entry_end_pos()`.

Example:

```text
entry_text()
```

```text
Top::AND
 I { declare(scalar, stage) }
 /foo\(/
 -> Top[0] { assign(scalar(stage), "open"); return(call(Child)) }

Child::AND
 I { declare(scalar, entry_token, body_token) }
 /\w+/
 /\)/
 -> Child[0] { assign(scalar(entry_token), entry_text()); assign(scalar(body_token), match_text()) }
 -> Child[1] { return(array("?Child:", scalar(entry_token), scalar(body_token), match_text())) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the immediate entry match that led into the current rule instead of the currently active local match or a previously stored checkpoint.

### `entry_line()`
Return the 1-based line number of the current immediate match directly.

Practical reading:
- use it when the rule wants the line where the immediate entry match started,
- prefer it over manual newline counting around `$IMATCH`,
- and treat it as the direct line-number companion to `entry_text()` / `entry_len()` / `entry_start_pos()` / `entry_end_pos()`.

Example:

```text
entry_line()
```

```text
Top::AND
 /foo\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_line_num, body_line_num) }
 /\w+/
 /\)/
 -> Child[0] { assign(scalar(entry_line_num), entry_line()); assign(scalar(body_line_num), match_line()) }
 -> Child[1] { return(array("?Child:", scalar(entry_line_num), scalar(body_line_num), entry_line(), match_line())) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the line where the immediate entry match began instead of the line of the currently active local match.

### `entry_col()`
Return the 1-based column number of the current immediate match directly.

Practical reading:
- use it when the rule wants the column where the immediate entry match started,
- prefer it over manual column math around `$IPOS - length($IMATCH)`,
- and treat it as the direct column-number companion to `entry_text()` / `entry_line()` / `entry_len()` / `entry_start_pos()` / `entry_end_pos()`.

Example:

```text
entry_col()
```

```text
Top::AND
 /foo\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_col_num, body_col_num) }
 /\w+/
 /\)/
 -> Child[0] { assign(scalar(entry_col_num), entry_col()); assign(scalar(body_col_num), match_col()) }
 -> Child[1] { return(array("?Child:", scalar(entry_col_num), scalar(body_col_num), entry_col(), match_col())) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the column where the immediate entry match began instead of the column of the currently active local match.

### `entry_group(index)`
Return one capture group from the current immediate match directly.

Practical reading:
- use it when the rule wants one capture group from the entry/immediate match that led into the current rule,
- prefer it over raw `scalar(IMATCH_LIST, index)` in normal user-facing `.spec` examples when an explicit helper spelling is clearer,
- and treat it as the direct capture-group companion to `entry_text()` / `entry_len()` / `entry_start_pos()` / `entry_end_pos()`.

Example:

```text
entry_group(0)
```

```text
Top::AND
 /(foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_group_0, body_group_0, body_group_1) }
 /(\w)(\w+)/
 /(\))/
 -> Child[0] { assign(scalar(entry_group_0), entry_group(0)); assign(scalar(body_group_0), match_group(0)); assign(scalar(body_group_1), match_group(1)) }
 -> Child[1] { return(array("?Child:", scalar(entry_group_0), scalar(body_group_0), scalar(body_group_1), match_group(0), entry_group(0), entry_group(1), match_group(1))) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants one capture group from the immediate entry match that led into the current rule instead of the capture groups of the currently active local match.

### `entry_groups()`
Return a snapshot of the whole current immediate-match capture-group list directly.

Practical reading:
- use it when the rule wants the whole positional capture-group list from the entry/immediate match that led into the current rule,
- prefer it over spelling `array(IMATCH_LIST)` directly in normal user-facing `.spec` examples when an explicit helper name is clearer,
- and treat it as the list-level companion to `entry_group(index)`.

Example:

```text
entry_groups()
```

```text
Top::AND
 /(foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(array, entry_groups_seen, body_groups_seen) }
 /(\w)(\w+)/
 /(\))/
 -> Child[0] { assign(array(entry_groups_seen), entry_groups()); assign(array(body_groups_seen), match_groups()) }
 -> Child[1] { return(array("?Child:", array_values(array(entry_groups_seen)), array_values(array(body_groups_seen)), match_groups())) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the whole immediate entry capture-group list that led into the current rule instead of only one indexed group or the currently active local match groups.

### `entry_named(name)`
Return one named capture from the current immediate match directly.

Practical reading:
- use it when the rule wants one named capture from the entry/immediate match that led into the current rule,
- prefer it over raw `%IMATCH_HASH` access in normal user-facing `.spec` examples when an explicit helper spelling is clearer,
- and treat it as the direct named-capture companion to `entry_text()` / `entry_group(index)` / `entry_len()` / `entry_start_pos()` / `entry_end_pos()`.

Example:

```text
entry_named(prefix)
```

```text
Top::AND
 /(?<prefix>foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_prefix, body_first, body_rest) }
 /(?<first>\w)(?<rest>\w+)/
 /(?<close>\))/
 -> Child[0] { assign(scalar(entry_prefix), entry_named(prefix)); assign(scalar(body_first), match_named(first)); assign(scalar(body_rest), match_named(rest)) }
 -> Child[1] { return(array("?Child:", scalar(entry_prefix), scalar(body_first), scalar(body_rest), match_named(close), entry_named(prefix), entry_named(missing_name), match_named(rest))) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants one named capture from the immediate entry match that led into the current rule instead of the named captures of the currently active local match.

### `entry_has(name)`
Return `1` when that named capture is present in the current immediate match and `0` when it is absent.

Practical reading:
- use it when the rule wants immediate-match named-capture presence metadata rather than the captured value itself,
- prefer it over spelling `has_key(entry_map(), "name")` directly in normal user-facing `.spec` examples when the simpler intent is “does this named entry capture exist?”,
- and treat it as the presence-check companion to `entry_named(name)` / `entry_map()`.

Example:

```text
entry_has(prefix)
```

```text
Top::AND
 /(?<prefix>foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_has_prefix, entry_has_missing, body_has_first, body_has_close) }
 /(?<first>\w)(?<rest>\w+)/
 /(?<close>\))/
 -> Child[0] { assign(scalar(entry_has_prefix), entry_has(prefix)); assign(scalar(entry_has_missing), entry_has(missing_name)); assign(scalar(body_has_first), match_has(first)); assign(scalar(body_has_close), match_has(close)) }
 -> Child[1] { return(array("?Child:", scalar(entry_has_prefix), scalar(entry_has_missing), scalar(body_has_first), scalar(body_has_close), entry_has(prefix), entry_has(missing_name), match_has(close), match_has(rest))) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule needs to know whether a named capture exists on the immediate entry match without first snapshotting the whole named-capture hash.

### `entry_map()`
Return the whole named-capture hash from the current immediate match directly.

Practical reading:
- use it when the rule wants the whole immediate entry named-capture hash that led into the current rule,
- prefer it over raw `%IMATCH_HASH` access in normal user-facing `.spec` examples when an explicit helper spelling is clearer,
- treat it as the hash-snapshot companion to `entry_named(name)`,
- and keep `entry_named_map()` only as a compatibility alias when older examples already use the longer name.

Example:

```text
entry_map()
```

```text
Top::AND
 /(?<prefix>foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(hash, entry_named_seen, body_named_seen) }
 /(?<first>\w)(?<rest>\w+)/
 -> Child[0] { assign(hash(entry_named_seen), entry_map()); assign(hash(body_named_seen), match_map()) }
 /(?<close>\))/
 -> Child[1] { return(array("?Child:", scalar(hash(entry_named_seen), "prefix"), scalar(hash(body_named_seen), "first"), scalar(hash(body_named_seen), "rest"), scalar(match_map(), "close"), join_values(",", sorted_keys(entry_map())), join_values(",", sorted_keys(match_map())))) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the whole immediate entry named-capture hash that led into the current rule instead of just one named key.

Compatibility alias:

```text
entry_named_map()
```

### `entry_len()`
Return the width of the current immediate match directly.

Practical reading:
- use it when the rule wants the entry/immediate match width as data,
- prefer it over raw `length($IMATCH)` in normal user-facing `.spec` examples,
- and treat it as the direct-width companion to `entry_text()` / `entry_start_pos()` / `entry_end_pos()`.

Example:

```text
entry_len()
```

```text
Top::AND
 I { declare(scalar, stage) }
 /foo\(/
 -> Top[0] { assign(scalar(stage), "open"); return(call(Child)) }

Child::AND
 I { declare(scalar, entry_len_value, body_len_value) }
 /\w+/
 /\)/
 -> Child[0] { assign(scalar(entry_len_value), entry_len()); assign(scalar(body_len_value), length(match_text())) }
 -> Child[1] { return(array("?Child:", scalar(entry_len_value), scalar(body_len_value), entry_len(), length(match_text()))) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the width of the immediate entry match that led into the current rule instead of the width of the currently active local match.

### `entry_start_pos()`
Return the left edge of the current immediate match directly.

Practical reading:
- use it when the rule wants the entry/immediate match start as data,
- prefer it over raw `$IPOS - length($IMATCH)` in normal user-facing `.spec` examples,
- and treat it as the direct-boundary companion to `entry_text()` / `entry_len()`.

Example:

```text
entry_start_pos()
```

```text
Top::AND
 I { declare(scalar, stage) }
 /foo\(/
 -> Top[0] { assign(scalar(stage), "open"); return(call(Child)) }

Child::AND
 I { declare(scalar, entry_start, entry_end, body_start, body_end) }
 /\w+/
 /\)/
 -> Child[0] { assign(scalar(entry_start), entry_start_pos()); assign(scalar(entry_end), entry_end_pos()); assign(scalar(body_start), match_start_pos()); assign(scalar(body_end), match_end_pos()) }
 -> Child[1] { return(array("?Child:", scalar(entry_start), scalar(entry_end), scalar(body_start), scalar(body_end), entry_start_pos(), entry_end_pos(), match_start_pos(), match_end_pos())) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the left boundary of the immediate entry match that led into the current rule instead of the left boundary of the currently active local match.

### `entry_end_pos()`
Return the right edge of the current immediate match directly.

Practical reading:
- use it when the rule wants the entry/immediate match end as data,
- prefer it over raw `$IPOS` in normal user-facing `.spec` examples,
- and treat it as the direct-boundary companion to `entry_text()` / `entry_len()` / `entry_start_pos()`.

If the immediate entry match is `foo(` inside `foo(bar)`, then `entry_end_pos()` returns `4`.

Use it when the rule wants the right boundary of the immediate entry match that led into the current rule instead of the right boundary of the currently active local match.

### `entry_end_line()`
Return the 1-based line number of the right edge of the current immediate match directly.

Practical reading:
- use it when the rule wants the line where the immediate entry match ended,
- prefer it over manual newline counting around `entry_end_pos()`,
- and treat it as the direct right-edge line companion to `entry_start_pos()` / `entry_end_pos()`.

If the immediate entry match is `foo\n` inside `foo\nbar\nbaz`, then `entry_end_line()` returns `2`.

Example:

```text
entry_end_line()
```

```text
Top::AND
 /foo\n/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_end_line_seen, body_end_line_seen) }
 /\w+\n/
 /\w+/
 -> Child[0] { assign(scalar(entry_end_line_seen), entry_end_line()); assign(scalar(body_end_line_seen), match_end_line()) }
 -> Child[1] { return(array("?Child:", scalar(entry_end_line_seen), scalar(body_end_line_seen), entry_end_line(), match_end_line())) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the line containing the parser position just after the immediate entry match that led into the current rule.

### `entry_end_col()`
Return the 1-based column number of the right edge of the current immediate match directly.

Practical reading:
- use it when the rule wants the column where the immediate entry match ended,
- prefer it over manual same-line arithmetic around `entry_end_pos()`,
- and treat it as the direct right-edge column companion to `entry_start_pos()` / `entry_end_pos()`.

If the immediate entry match is `foo(` inside `foo(bar)`, then `entry_end_col()` returns `5`.

Example:

```text
entry_end_col()
```

```text
Top::AND
 /foo\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_end_col_seen, body_end_col_seen) }
 /\w+/
 /\)/
 -> Child[0] { assign(scalar(entry_end_col_seen), entry_end_col()); assign(scalar(body_end_col_seen), match_end_col()) }
 -> Child[1] { return(array("?Child:", scalar(entry_end_col_seen), scalar(body_end_col_seen), entry_end_col(), match_end_col())) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the column containing the parser position just after the immediate entry match that led into the current rule.

### `match_text()`
Return the current local match text directly.

Practical reading:
- use it when the rule wants the current local match content as data,
- prefer it over raw `$LMATCH` in normal user-facing `.spec` examples,
- and treat it as the direct-text companion to `match_len()` / `match_start_pos()` / `match_end_pos()`.

Example:

```text
match_text()
```

```text
Top::AND
 I { declare(scalar, stage, body_token) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body"); assign(scalar(body_token), match_text()) }
 -> Top[2] { return(array("?Top:", scalar(body_token), match_text())) }
```

Use it when the rule wants the current local match text immediately instead of reading a previously stored checkpoint or a larger remembered span.

### `match_line()`
Return the 1-based line number of the current local match directly.

Practical reading:
- use it when the rule wants the line where the current local match started,
- prefer it over manual newline counting around `$LMATCH`,
- and treat it as the direct line-number companion to `match_text()` / `match_len()` / `match_start_pos()` / `match_end_pos()`.

Example:

```text
match_line()
```

```text
Top::AND
 I { declare(scalar, open_line, body_line) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(open_line), cursor_line()) }
 -> Top[1] { assign(scalar(body_line), match_line()) }
 -> Top[2] { return(array("?Top:", scalar(open_line), scalar(body_line), match_line())) }
```

Use it when the rule wants the line where the current local match began instead of the current parser cursor line or a previously stored checkpoint position.

### `match_col()`
Return the 1-based column number of the current local match directly.

Practical reading:
- use it when the rule wants the column where the current local match started,
- prefer it over manual column math around `$LSPOS - length($LMATCH)`,
- and treat it as the direct column-number companion to `match_text()` / `match_line()` / `match_len()` / `match_start_pos()` / `match_end_pos()`.

Example:

```text
match_col()
```

```text
Top::AND
 I { declare(scalar, open_col, body_col) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(open_col), cursor_col()) }
 -> Top[1] { assign(scalar(body_col), match_col()) }
 -> Top[2] { return(array("?Top:", scalar(open_col), scalar(body_col), match_col())) }
```

Use it when the rule wants the column where the current local match began instead of the current parser cursor column or a previously stored checkpoint.

### `match_group(index)`
Return one capture group from the current local match directly.

Practical reading:
- use it when the rule wants one capture group from the current local match as data,
- prefer it over raw `scalar(LMATCH_LIST, index)` in normal user-facing `.spec` examples when an explicit helper spelling is clearer,
- and treat it as the direct capture-group companion to `match_text()` / `match_len()` / `match_start_pos()` / `match_end_pos()`.

Example:

```text
match_group(0)
```

```text
Top::AND
 /(\w)(\w+)/
 /(\))/
 -> Top[0] { assign(scalar(first_piece), match_group(0)); assign(scalar(second_piece), match_group(1)) }
 -> Top[1] { return(array("?Top:", scalar(first_piece), scalar(second_piece), match_group(0), match_group(1))) }
```

Use it when the rule wants capture-group data from the currently active local match immediately instead of from the immediate entry match or from a previously stored checkpoint span.

### `match_groups()`
Return a snapshot of the whole current local-match capture-group list directly.

Practical reading:
- use it when the rule wants the whole positional capture-group list from the current local match as data,
- prefer it over spelling `array(LMATCH_LIST)` directly in normal user-facing `.spec` examples when an explicit helper name is clearer,
- and treat it as the list-level companion to `match_group(index)`.

Example:

```text
match_groups()
```

```text
Top::AND
 /(foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(array, entry_groups_seen, body_groups_seen) }
 /(\w)(\w+)/
 /(\))/
 -> Child[0] { assign(array(entry_groups_seen), entry_groups()); assign(array(body_groups_seen), match_groups()) }
 -> Child[1] { return(array("?Child:", array_values(array(entry_groups_seen)), array_values(array(body_groups_seen)), match_groups())) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the whole current local capture-group list immediately instead of only one indexed group or the earlier immediate entry capture groups.

### `match_named(name)`
Return one named capture from the current local match directly.

Practical reading:
- use it when the rule wants one named capture from the current local match itself,
- prefer it over raw `%LMATCH_HASH` access in normal user-facing `.spec` examples when an explicit helper spelling is clearer,
- and treat it as the direct named-capture companion to `match_text()` / `match_group(index)` / `match_len()` / `match_start_pos()` / `match_end_pos()`.

Example:

```text
match_named(rest)
```

```text
Top::AND
 /(?<prefix>foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_prefix, body_first, body_rest) }
 /(?<first>\w)(?<rest>\w+)/
 /(?<close>\))/
 -> Child[0] { assign(scalar(entry_prefix), entry_named(prefix)); assign(scalar(body_first), match_named(first)); assign(scalar(body_rest), match_named(rest)) }
 -> Child[1] { return(array("?Child:", scalar(entry_prefix), scalar(body_first), scalar(body_rest), match_named(close), entry_named(prefix), entry_named(missing_name), match_named(rest))) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants one named capture from the current local match itself instead of the immediate entry match that led into the current rule.

### `match_has(name)`
Return `1` when that named capture is present in the current local match and `0` when it is absent.

Practical reading:
- use it when the rule wants current-local named-capture presence metadata rather than the captured value itself,
- prefer it over spelling `has_key(match_map(), "name")` directly in normal user-facing `.spec` examples when the simpler intent is “does this local named capture exist right now?”,
- and treat it as the presence-check companion to `match_named(name)` / `match_map()`.

Example:

```text
match_has(rest)
```

```text
Top::AND
 /(?<prefix>foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(scalar, entry_has_prefix, entry_has_missing, body_has_first, body_has_close) }
 /(?<first>\w)(?<rest>\w+)/
 /(?<close>\))/
 -> Child[0] { assign(scalar(entry_has_prefix), entry_has(prefix)); assign(scalar(entry_has_missing), entry_has(missing_name)); assign(scalar(body_has_first), match_has(first)); assign(scalar(body_has_close), match_has(close)) }
 -> Child[1] { return(array("?Child:", scalar(entry_has_prefix), scalar(entry_has_missing), scalar(body_has_first), scalar(body_has_close), entry_has(prefix), entry_has(missing_name), match_has(close), match_has(rest))) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule needs to know whether a named capture exists on the current local match without first snapshotting the whole named-capture hash.

### `match_map()`
Return the whole named-capture hash from the current local match directly.

Practical reading:
- use it when the rule wants the whole current local named-capture hash itself,
- prefer it over raw `%LMATCH_HASH` access in normal user-facing `.spec` examples when an explicit helper spelling is clearer,
- treat it as the hash-snapshot companion to `match_named(name)`,
- and keep `match_named_map()` only as a compatibility alias when older examples already use the longer name.

Example:

```text
match_map()
```

```text
Top::AND
 /(?<prefix>foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 I { declare(hash, entry_named_seen, body_named_seen) }
 /(?<first>\w)(?<rest>\w+)/
 -> Child[0] { assign(hash(entry_named_seen), entry_map()); assign(hash(body_named_seen), match_map()) }
 /(?<close>\))/
 -> Child[1] { return(array("?Child:", scalar(hash(entry_named_seen), "prefix"), scalar(hash(body_named_seen), "first"), scalar(hash(body_named_seen), "rest"), scalar(match_map(), "close"), join_values(",", sorted_keys(entry_map())), join_values(",", sorted_keys(match_map())))) }
```

When building this exact inline example directly, select `top_rule => Top` so the entry rule is explicit.

Use it when the rule wants the whole current local named-capture hash itself instead of just one named key from that active local match.

Compatibility alias:

```text
match_named_map()
```

### `match_len()`
Return the width of the current local match directly.

Practical reading:
- use it when the rule wants the current local match width as data,
- prefer it over raw `length($LMATCH)` in normal user-facing `.spec` examples,
- and treat it as the direct-width companion to `match_text()` / `match_start_pos()` / `match_end_pos()`.

Example:

```text
match_len()
```

```text
Top::AND
 I { declare(scalar, stage, body_width) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body"); assign(scalar(body_width), match_len()) }
 -> Top[2] { return(array("?Top:", scalar(body_width), match_len())) }
```

Use it when the rule wants the current local match width immediately instead of the width of a previously stored checkpoint span.

### `match_start_pos()`
Return the left edge of the current local match directly.

Practical reading:
- use it when the rule wants the current match start as data,
- prefer it over `mark_pos(name)` when there is no reason to store a checkpoint first,
- and treat it as the direct-boundary companion to `match_text()` / `match_len()` / `mark_match_start(name)`.

Example:

```text
match_start_pos()
```

```text
Top::AND
 I { declare(scalar, stage, body_start_pos, body_end_pos) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[0] { assign(scalar(stage), "open") }
 -> Top[1] { assign(scalar(stage), "body"); assign(scalar(body_start_pos), match_start_pos()); assign(scalar(body_end_pos), match_end_pos()) }
 -> Top[2] { return(array("?Top:", scalar(body_start_pos), scalar(body_end_pos), match_start_pos(), match_end_pos())) }
```

Use it when the rule wants the current local match left edge immediately instead of reading a previously stored checkpoint.

### `match_end_pos()`
Return the right edge of the current local match directly.

Practical reading:
- use it when the rule wants the current match end as data,
- prefer it over `mark_pos(name)` when there is no reason to store a checkpoint first,
- and treat it as the direct-boundary companion to `mark_here(name)` for post-match positions.

If the current local match is `bar` inside `foo(bar)`, then `match_end_pos()` returns the position just after `bar`.

Use it when the rule wants the current local match right edge immediately instead of reading a previously stored checkpoint.

### `match_end_line()`
Return the 1-based line number of the right edge of the current local match directly.

Practical reading:
- use it when the rule wants the line where the current local match ended,
- prefer it over manual newline counting around `match_end_pos()`,
- and treat it as the direct right-edge line companion to `match_start_pos()` / `match_end_pos()`.

If the current local match is `bar\n` inside `foo\nbar\nbaz`, then `match_end_line()` returns `3`.

Example:

```text
match_end_line()
```

```text
Top::AND
 I { declare(scalar, open_end_line, body_end_line) }
 /foo\n/
 /\w+\n/
 /\w+/
 -> Top[0] { assign(scalar(open_end_line), match_end_line()) }
 -> Top[1] { assign(scalar(body_end_line), match_end_line()) }
 -> Top[2] { return(array("?Top:", scalar(open_end_line), scalar(body_end_line), match_end_line())) }
```

Use it when the rule wants the line containing the parser position just after the current local match.

### `match_end_col()`
Return the 1-based column number of the right edge of the current local match directly.

Practical reading:
- use it when the rule wants the column where the current local match ended,
- prefer it over manual same-line arithmetic around `match_end_pos()`,
- and treat it as the direct right-edge column companion to `match_start_pos()` / `match_end_pos()`.

If the current local match is `bar` inside `foo(bar)`, then `match_end_col()` returns `8`.

Example:

```text
match_end_col()
```

```text
Top::AND
 I { declare(scalar, body_end_col) }
 /foo\(/
 /\w+/
 /\)/
 -> Top[1] { assign(scalar(body_end_col), match_end_col()) }
 -> Top[2] { return(array("?Top:", scalar(body_end_col), match_end_col())) }
```

Use it when the rule wants the column containing the parser position just after the current local match.

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
