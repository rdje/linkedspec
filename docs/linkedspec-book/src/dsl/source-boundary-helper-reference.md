# Source Boundary Helper Reference

This chapter is the public reference for LinkedSpec's source-boundary helper family.

Read [Capture, Marks, and Source Locations](capture-marks-and-source-locations.md) first if the anchor model is still new. That chapter explains the mental model. This chapter is for authors who are already writing `.spec` action blocks and need exact helper choices.

## Core vocabulary

Most helpers in this chapter answer one of four questions:

- Where does the span start?
- Where does the span end?
- Should the helper return text, width, or a position?
- Should the helper leave the boundary stable or advance it after reading?

The important anchors are:

| Anchor | Meaning |
| --- | --- |
| Anonymous capture boundary | The rule-local rolling boundary used by `capture_slice()` and friends. It is moved by `@capture_slice`, `start_capture_slice()`, `capture_take*()`, and `start_capture_slice_from(name)`. |
| Named mark | A rule-local named checkpoint, written by helpers such as `@mark(name)`, `mark_here(name)`, `mark_entry_start(name)`, and `mark_match_end(name)`. |
| Cursor | The live parser cursor, read by `cursor_pos()`, `cursor_line()`, `cursor_col()`, `cursor_rest()`, and `cursor_rest_len()`. |
| Entry match | The immediate match that brought the current action or called rule into this context, read by `entry_*` helpers. |
| Local match | The current local match being processed, read by `match_*` helpers. |
| Whole input | The full current input string, read by `input_*` helpers. |

Positions are absolute string offsets. Lines and columns are human-readable, 1-based values for diagnostics.

## Right-edge choices

Capture helpers with similar names differ mostly by their right edge:

| Right edge | Anonymous helper | Named-mark helper |
| --- | --- | --- |
| Current local-match left edge | `capture_slice()` | `capture_from(name)` |
| Live parser cursor | `capture_slice_until_cursor()` | `capture_until_cursor_from(name)` |
| End of input | `capture_rest()` | `capture_rest_from(name)` |
| Explicit stored mark | Not applicable | `capture_between(start_mark, end_mark)` |

Use the current-edge helpers when a delimiter match should be excluded from the returned text. Use the cursor helpers when consumed text through the live parser cursor should be included. Use the end-of-input helpers for tail captures. Use the two-mark helpers when both boundaries are already named.

## Stable Read Versus Advancing Read

Helpers containing `take` read a span and then advance the relevant boundary.

| Stable read | Advancing read | Boundary advanced |
| --- | --- | --- |
| `capture_slice()` | `capture_take()` | anonymous capture boundary |
| `capture_slice_len()` | `capture_take_len()` | anonymous capture boundary |
| `capture_slice_until_cursor()` | `capture_take_until_cursor()` | anonymous capture boundary |
| `capture_slice_until_cursor_len()` | `capture_take_until_cursor_len()` | anonymous capture boundary |
| `capture_rest()` | `capture_take_rest()` | anonymous capture boundary |
| `capture_rest_len()` | `capture_take_rest_len()` | anonymous capture boundary |
| `capture_from(name)` | `capture_take(name)` | named mark `name` |
| `capture_len_from(name)` | `capture_take_len_from(name)` | named mark `name` |
| `capture_until_cursor_from(name)` | `capture_take_until_cursor_from(name)` | named mark `name` |
| `capture_until_cursor_len_from(name)` | `capture_take_until_cursor_len_from(name)` | named mark `name` |
| `capture_rest_from(name)` | `capture_take_rest_from(name)` | named mark `name` |
| `capture_rest_len_from(name)` | `capture_take_rest_len_from(name)` | named mark `name` |
| `capture_between(start_mark, end_mark)` | `capture_take_between(start_mark, end_mark)` | `start_mark` |
| `capture_len_between(start_mark, end_mark)` | `capture_take_between_len(start_mark, end_mark)` | `start_mark` |

If the rule only needs to inspect text or width, use the stable form. If the rule is splitting a sequence into consecutive segments, use the advancing form so the next segment starts at the new boundary.

## Anonymous capture-boundary helpers

The anonymous capture boundary is the simplest stateful capture tool: one rolling left edge per rule context.

| Helper | Result | Boundary movement | Use it when |
| --- | --- | --- | --- |
| `@capture_slice` | no returned value | moves the anonymous boundary at a rule slot marker | a grammar slot should become the new anonymous slice start. |
| `start_capture_slice()` | stored boundary position expression | moves the anonymous boundary to the live cursor | an action block should begin a new anonymous slice now. |
| `capture_slice()` | text | none | read from the anonymous boundary to the current local-match left edge. |
| `capture_slice_len()` | width | none | read that same span width without materializing text. |
| `capture_slice_pos()` | position | none | expose or compare the current anonymous boundary. |
| `capture_slice_line()` | line | none | report where the current anonymous slice started. |
| `capture_slice_col()` | column | none | report the column where the current anonymous slice started. |
| `capture_slice_until_cursor()` | text or `undef` | none | read from the anonymous boundary through the live cursor. |
| `capture_slice_until_cursor_len()` | width or `undef` | none | read that through-cursor span width. |
| `capture_take_until_cursor()` | text or `undef` | advances anonymous boundary to the live cursor | read through cursor and roll the anonymous boundary forward. |
| `capture_take_until_cursor_len()` | width or `undef` | advances anonymous boundary to the live cursor | record through-cursor width and roll forward. |
| `capture_rest()` | text | none | read from the anonymous boundary through end-of-input. |
| `capture_rest_len()` | width | none | read that end-of-input tail width. |
| `capture_take_rest()` | text or `undef` | advances anonymous boundary to end-of-input | consume the remaining anonymous tail. |
| `capture_take_rest_len()` | width or `undef` | advances anonymous boundary to end-of-input | consume the remaining tail as width metadata. |
| `capture_take()` | text | advances anonymous boundary to the live cursor | read to the current local-match left edge, then roll the boundary forward. |
| `capture_take_len()` | width | advances anonymous boundary to the live cursor | record that current-edge width and roll forward. |

Anonymous capture readers can be returned directly. For example, `return(capture_slice_len())` and fluent `.return(capture_slice_len())` both return the current anonymous capture span width without materializing the text.

Compatibility aliases:

| Compatibility helper | Preferred helper |
| --- | --- |
| `capture_slice_here()` | `start_capture_slice()` |
| `capture_slice_length()` | `capture_slice_len()` |
| `capture_rest_length()` | `capture_rest_len()` |
| `capture_from_rule_start()` | `capture_slice()` |
| `capture_len_from_rule_start()` | `capture_slice_len()` |

Prefer the explicit names in new public examples.

The delimiter-body examples below use seek-mode matching. In consume mode, model the
intervening body tokens explicitly so the closer is reached contiguously.

### Example: split a comma-separated body

```text
Top::AND
 => Tuple

Tuple:AND
 I { set(array(parts), []); }
 /\(/
 /[^,]+/
 /,/
 /[^)]+/
 /\)/
 -> Tuple[0] { start_capture_slice() }
 -> Tuple[2] { push(array(parts), capture_take()) }
 -> Tuple[4] { push(array(parts), capture_slice()); return(array("?Tuple:", copy(array(parts)))) }
```

Reading this example:

- `start_capture_slice()` begins the anonymous slice after the opening `(`.
- The first `capture_take()` returns the text before the first comma and advances the slice boundary past that comma.
- The final `capture_slice()` reads the last segment before the closing `)`.

Use this pattern when one rolling boundary is enough. If multiple independent boundaries must survive at the same time, use named marks instead.

### Example: report where a slice started

```text
Top::AND
 => Block

Block:AND
 /\{/
 /[^}]*/
 /\}/
 -> Block[0] { start_capture_slice() }
 -> Block[2] {
   return(hash(
     "body", capture_slice(),
     "body_start_line", capture_slice_line(),
     "body_start_col", capture_slice_col()
   ))
 }
```

The line and column helpers are for diagnostics and metadata. They should replace raw newline counting in user-facing specs.

## Named mark helpers

Named marks are stable, rule-local checkpoints. Use them when one anonymous rolling boundary is not enough, when a boundary needs a name, or when two saved boundaries define a span.

| Helper | Writes or reads | Meaning |
| --- | --- | --- |
| `@mark(name)` | write | mark the current parser position at a rule slot marker. |
| `mark_input_start(name)` | write | store absolute input start. |
| `mark_input_end(name)` | write | store absolute input end. |
| `mark_here(name)` | write | store the live parser cursor now. |
| `mark_entry_start(name)` | write | store the immediate entry-match left edge. |
| `mark_entry_end(name)` | write | store the immediate entry-match right edge. |
| `mark_match_start(name)` | write | store the current local-match left edge. |
| `mark_match_end(name)` | write | store the current local-match right edge. |
| `mark_copy(target_mark, source_mark)` | write | copy one stored mark into another; clears target when source is absent. |
| `mark_capture_slice(name)` | write | copy the anonymous capture boundary into a named mark. |
| `clear_mark(name)` | write | delete a named mark. |
| `mark_exists(name)` | read | return `1` if the mark exists, else `0`. |
| `mark_pos(name)` | read | return the stored absolute position, or `undef`. |
| `mark_line(name)` | read | return the stored mark line, or `undef`. |
| `mark_col(name)` | read | return the stored mark column, or `undef`. |
| `start_capture_slice_from(name)` | bridge | reset the anonymous capture boundary from a named mark when it exists. |

Named mark span readers return `undef` when their needed mark is absent or when an invalid span would run backwards.

| Helper | Result | Right edge | Boundary movement |
| --- | --- | --- | --- |
| `capture_from(name)` | text or `undef` | current local-match left edge | none |
| `capture_len_from(name)` | width or `undef` | current local-match left edge | none |
| `capture_take(name)` | text or `undef` | current local-match left edge | advances `name` to the live cursor |
| `capture_take_len_from(name)` | width or `undef` | current local-match left edge | advances `name` to the live cursor |
| `capture_until_cursor_from(name)` | text or `undef` | live cursor | none |
| `capture_until_cursor_len_from(name)` | width or `undef` | live cursor | none |
| `capture_take_until_cursor_from(name)` | text or `undef` | live cursor | advances `name` to the live cursor |
| `capture_take_until_cursor_len_from(name)` | width or `undef` | live cursor | advances `name` to the live cursor |
| `capture_rest_from(name)` | text or `undef` | end-of-input | none |
| `capture_rest_len_from(name)` | width or `undef` | end-of-input | none |
| `capture_take_rest_from(name)` | text or `undef` | end-of-input | advances `name` to end-of-input |
| `capture_take_rest_len_from(name)` | width or `undef` | end-of-input | advances `name` to end-of-input |
| `capture_between(start_mark, end_mark)` | text or `undef` | stored `end_mark` | none |
| `capture_len_between(start_mark, end_mark)` | width or `undef` | stored `end_mark` | none |
| `capture_take_between(start_mark, end_mark)` | text or `undef` | stored `end_mark` | advances `start_mark` to `end_mark` |
| `capture_take_between_len(start_mark, end_mark)` | width or `undef` | stored `end_mark` | advances `start_mark` to `end_mark` |

### Example: capture between a named opener and the closing match

```text
Top::AND
 => Paren

Paren:AND
 /\(/
 /[^)]*/
 /\)/
 -> Paren[0] { mark_here(body_start) }
 -> Paren[2] {
   return(hash(
     "body", capture_from(body_start),
     "line", mark_line(body_start),
     "col", mark_col(body_start)
   ))
 }
```

`mark_here(body_start)` stores the cursor just after the opening delimiter. `capture_from(body_start)` later reads from that mark to the left edge of the closing delimiter, excluding the delimiter itself.

### Example: two explicit marks

```text
Top::AND
 => Pair

Pair:AND
 /\[/
 /\w+/
 /:/
 /\w+/
 /\]/
 -> Pair[0] { mark_here(body_start) }
 -> Pair[2] { mark_match_start(colon_start); left = capture_between(body_start, colon_start); mark_here(right_start) }
 -> Pair[4] {
   mark_match_start(close_start);
   return(hash(
     "left", left,
     "right", capture_between(right_start, close_start)
   ))
 }
```

If a rule needs an exact right edge, store it explicitly with `mark_match_start(name)` or `mark_match_end(name)` and use `capture_between(...)`. That avoids making the current local match carry too much meaning.

### Example: bridge anonymous and named boundaries

```text
Top::AND
 => Body

Body:AND
 /\(/
 /[^,]+/
 /,/
 /[^)]+/
 /\)/
 -> Body[0] { start_capture_slice(); mark_capture_slice(body_start) }
 -> Body[2] { first = capture_take() }
 -> Body[4] {
   second = capture_slice();
   start_capture_slice_from(body_start);
   return(hash(
     "first", first,
     "second", second,
     "whole_body", capture_slice()
   ))
 }
```

`mark_capture_slice(body_start)` promotes the anonymous boundary to a durable mark. `start_capture_slice_from(body_start)` restores it later. This is useful when the rule wants both incremental segments and the whole body.

### Example: marker syntax plus named helpers

Marker members are useful when a grammar slot itself is the boundary. The example
below sets both the anonymous capture boundary and a named mark after the opener
slot, then reads both boundaries from the closing-delimiter action.

```text
Top::AND
 => MarkerBody

MarkerBody:AND
 /foo\(/
 @capture_slice
 @mark(body_start)
 /[A-Za-z]+/
 /\)/
 -> MarkerBody[0] {
   opened = 1;
 }
 -> MarkerBody[2] {
   mark_match_start(close_start);
   return(hash(
     "anonymous", capture_slice(),
     "named", capture_from(body_start),
     "between", capture_between(body_start, close_start),
     "body_start", mark_pos(body_start),
     "close_start", mark_pos(close_start)
   ))
 }
```

With `parse_mode => "seek"`, input `foo(alpha)` returns
`[{"anonymous":"alpha","between":"alpha","body_start":4,"close_start":9,"named":"alpha"}]`.
The three text readers all see the same body span:

- `capture_slice()` reads from the anonymous boundary set by `@capture_slice`.
- `capture_from(body_start)` reads from the named mark set by `@mark(body_start)`.
- `capture_between(body_start, close_start)` reads between the marker-written
  start mark and the explicit `mark_match_start(close_start)` endpoint.

If the boundary belongs inside action code rather than at a grammar slot, prefer
`start_capture_slice()` and `mark_here(...)`; their timing is local to the block.

## Cursor and whole-input helpers

Cursor helpers read the live parser cursor. Whole-input helpers ignore the cursor and read from the entire current input.

| Helper | Result | Use it when |
| --- | --- | --- |
| `cursor_pos()` | live cursor position | machine logic needs the current parser position. |
| `cursor_line()` | live cursor line | diagnostics need the current parser line. |
| `cursor_col()` | live cursor column | diagnostics need the current parser column. |
| `cursor_rest()` | text from cursor to end-of-input, or `undef` | a rule needs the remaining input text at the live cursor. |
| `cursor_rest_len()` | width from cursor to end-of-input, or `undef` | a rule needs the remaining input width. |
| `input_text()` | whole input text | diagnostics or metadata need the full source. |
| `input_slice(start, width)` | whole-input substring, or `undef` | logic already has absolute source boundaries and needs that span as text. |
| `input_len()` | whole input width | logic needs the total width. |
| `input_end_pos()` | whole-input right-edge position | the value is a boundary rather than merely a width. |
| `input_end_line()` | whole-input right-edge line | diagnostics need where the file ends. |
| `input_end_col()` | whole-input right-edge column | diagnostics need the final column. |

`input_slice(start, width)` evaluates both boundary expressions once, then reads from the whole current input. `input_len()` and `input_end_pos()` are numerically the same today because the input starts at position zero. Use `input_len()` when the concept is width. Use `input_end_pos()` when the concept is a boundary.

Example:

```text
Top::AND
 => AtEnd

AtEnd:AND
 /END/
 -> AtEnd[0] {
   return(hash(
     "cursor_pos", cursor_pos(),
     "remaining", cursor_rest(),
     "prefix", input_slice(0, cursor_pos()),
     "source_len", input_len(),
     "source_end_line", input_end_line(),
     "source_end_col", input_end_col()
   ))
 }
```

## Entry-match helpers

Entry helpers read the immediate match that brought the action or called rule into the current context. Use them when a child rule needs data from the match that invoked it.

| Helper | Result |
| --- | --- |
| `entry_text()` | immediate match text |
| `entry_len()` | immediate match width |
| `entry_start_pos()` | immediate match left-edge position |
| `entry_end_pos()` | immediate match right-edge position |
| `entry_line()` | immediate match left-edge line |
| `entry_start_line()` | explicit alias for immediate match left-edge line |
| `entry_end_line()` | immediate match right-edge line |
| `entry_col()` | immediate match left-edge column |
| `entry_start_col()` | explicit alias for immediate match left-edge column |
| `entry_end_col()` | immediate match right-edge column |
| `entry_group(index)` | positional capture group by zero-based index, or `undef` |
| `entry_groups()` | snapshot array of all immediate-match positional capture groups |
| `entry_named(name)` | named capture value, or `undef` |
| `entry_has(name)` | `1` if that named capture exists, else `0` |
| `entry_map()` | snapshot hash of immediate-match named captures |
| `entry_named_map()` | compatibility alias for `entry_map()` |

Prefer the explicit `entry_start_*` names when the surrounding code also talks about `entry_end_*`. The shorter `entry_line()` and `entry_col()` names are still valid and mean the left edge.

`entry_group(index)` (and the `match_group(index)` counterpart below) index the **captured groups** 0-based: index `0` is the *first* capture group, not the whole match — read the whole match with `entry_text()` / `match_text()`. The numbered list is **compacted**, so a group that did not participate in the match is dropped and shifts the indices after it; prefer named groups (`entry_named(name)` / `match_named(name)`) when a pattern has optional captures. See [Regex in `.spec`](../user-model/regex-in-spec.md#capture-groups).

## Match helpers

Match helpers read the current local match being processed. Use them when the action wants the local slot's match, not the broader entry match.

| Helper | Result |
| --- | --- |
| `match_text()` | current local match text |
| `match_len()` | current local match width |
| `match_start_pos()` | current local match left-edge position |
| `match_end_pos()` | current local match right-edge position |
| `match_line()` | current local match left-edge line |
| `match_start_line()` | explicit alias for current local match left-edge line |
| `match_end_line()` | current local match right-edge line |
| `match_col()` | current local match left-edge column |
| `match_start_col()` | explicit alias for current local match left-edge column |
| `match_end_col()` | current local match right-edge column |
| `match_group(index)` | positional capture group by zero-based index, or `undef` |
| `match_groups()` | snapshot array of all current local-match positional capture groups |
| `match_named(name)` | named capture value, or `undef` |
| `match_has(name)` | `1` if that named capture exists, else `0` |
| `match_map()` | snapshot hash of current local-match named captures |
| `match_named_map()` | compatibility alias for `match_map()` |

Prefer the explicit `match_start_*` names when the surrounding code also talks about `match_end_*`. The shorter `match_line()` and `match_col()` names are still valid and mean the left edge.

## Entry versus match example

```text
Top::
 -> Name .push
 LX { return(copy(array(Top))) }

Name:AND
 /(?<head>name)/
 /\s*=\s*/
 /(?<value>[A-Za-z_]+)/
 -> Name[1] {
   eq = match_text();
 }
 -> Name[2] {
   return(hash(
     "entry_text", entry_text(),
     "entry_name", entry_named(head),
     "local_text", match_text(),
     "local_name", match_named(value),
     "entry_group_count", count(entry_groups()),
     "local_group_count", count(match_groups()),
     "separator", trim(eq)
   ))
 }
```

Read it this way:

- `entry_*` sees the captured first slot `name` from the match that brought `Name` into the current context.
- `match_*` sees the current local `Name` match, here the final slot `Alpha` when the input is `name=Alpha`.
- If this inline example is built directly, select `top_rule => Top` so the public entrypoint is explicit.

On input `name=Alpha`, the top accumulator returns
`[{"entry_group_count":1,"entry_name":"name","entry_text":"name","local_group_count":1,"local_name":"Alpha","local_text":"Alpha","separator":"="}]`.

This split is the main reason both helper families exist.

## Legacy compatibility helpers

The following older helpers remain useful when reading or migrating legacy specs:

| Helper | Preferred modern direction |
| --- | --- |
| `$CAPTURE` | `capture_slice()` or `name = capture_slice()` |
| `capture(label)` | `push(array(target), capture_slice())` when the target is explicit |
| `capture_if(label)` | `part = trim(capture_slice()); if(is_nonempty(part)) { push(array(target), part) }` for the common trimmed-and-nonempty append case; explicit `if(...)` around `capture_slice()` when custom filtering is needed |
| `CAPTURE_IF()` | `part = trim(capture_slice()); if(is_nonempty(part)) { push(array(current_rule), part) }` when replacing the legacy current-rule append shape |

The `label` argument on the legacy capture helpers is compatibility syntax. The active lowering uses the current rule context, not a new independent target selected by that label text. For `capture(label)`, `capture_if(label)`, and `CAPTURE_IF()`, that means the captured value is appended to the rule-local default accumulator array named after the current rule. New docs and examples should normally prefer explicit helper composition.

### Explicit cursor controls

Cursor-control helpers move or remember the live parser cursor. They do not
unwind parser state, do not restore side effects, and do not implement systemic
search-tree backtracking.

| Helper | Behavior | Use it when |
| --- | --- | --- |
| `save_cursor()` | Push the current live cursor onto the explicit cursor stack. | later action code may need to return to this exact cursor. |
| `restore_cursor()` | Pop the explicit cursor stack and move the live cursor to that saved position. Empty stack is a no-op. | paired code should retry or inspect from a previously saved cursor. |
| `rewind_match_start()` | Move the live cursor to the current local-match start. | the current local match was consumed only to inspect a boundary and should be re-scanned by the next rule-level match. |
| `rewind_entry_start()` | Move the live cursor to the entry/initial-match start for this context. | the whole entry match should be re-scanned by the next rule-level match. |

Keep these semantics separate. `save_cursor()` / `restore_cursor()` are an
explicit stack. `rewind_match_start()` / `rewind_entry_start()` are direct
lifecycle-anchor rewinds and do not use hidden stack state.

The previous `BACKTRACK()` / `IBACKTRACK()` and lowercase `backtrack(label)` /
`ibacktrack(label)` spellings are not current portable API. Use the explicit
helpers above in new specs.

Because a rewind is just a local cursor move, the current `parse_mode` still
applies to the next match that follows. Under `consume` mode, the next match
must succeed contiguously from the rewound cursor position. Under `seek` mode,
the parser may seek forward from the rewound position.

For open-ended captures, prefer a structural boundary when available: a
zero-width/lookahead boundary can detect that the next structural token would
match without consuming that token, capture up to the boundary, and leave the
cursor ready for the normal rule path.

## Choosing the smallest helper

Use this rule of thumb:

- Use anonymous `capture_slice*` helpers when one rolling boundary is enough.
- Use `capture_take*` when the read should also advance that rolling boundary.
- Use named `mark_*` plus `capture_*_from(...)` when multiple boundaries must survive.
- Use `capture_between(...)` when both span edges are explicit marks.
- Use `cursor_*` when the live parser cursor is the concept.
- Use `input_*` when the whole input is the concept.
- Use `entry_*` for the match that brought this context into existence.
- Use `match_*` for the current local match.

The goal is not to memorize every helper at once. The goal is to make the boundary and movement semantics visible at the call site.

## Deeper reference

For the full boundary-helper contract catalog including cursor helpers, immediate-match helpers, and whole-input helpers with emitted-Perl lowering, see `USER_GUIDE_ActionIR_Contracts.md` in the repo root. The source-boundary section there is the exhaustive working reference while this chapter remains the high-level map.
