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
