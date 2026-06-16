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

### Example: split a comma-separated body

```text
Tuple::AND
 I { declare(array, parts); }
 /\(/
 /[^,]*/
 /,/
 /[^,]*/
 /,/
 /[^)]*/
 /\)/
 -> Tuple[0] { start_capture_slice() }
 -> Tuple[2] { push_value(array(parts), capture_take()) }
 -> Tuple[4] { push_value(array(parts), capture_take()) }
 -> Tuple[6] { push_value(array(parts), capture_slice()); return(array("?Tuple:", array_copy(array(parts)))) }
```

Reading this example:

- `start_capture_slice()` begins the anonymous slice after the opening `(`.
- The first `capture_take()` returns the text before the first comma and advances the slice boundary past that comma.
- The second `capture_take()` returns the text before the second comma and advances again.
- The final `capture_slice()` reads the last segment before the closing `)`.

Use this pattern when one rolling boundary is enough. If multiple independent boundaries must survive at the same time, use named marks instead.

### Example: report where a slice started

```text
Block::AND
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
Paren::AND
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
Pair::AND
 /\[/
 /\w+/
 /:/
 /\w+/
 /\]/
 -> Pair[0] { mark_here(body_start) }
 -> Pair[2] { mark_match_start(colon_start); assign(scalar(left), capture_between(body_start, colon_start)); mark_here(right_start) }
 -> Pair[4] {
   mark_match_start(close_start);
   return(hash(
     "left", scalar(left),
     "right", capture_between(right_start, close_start)
   ))
 }
```

If a rule needs an exact right edge, store it explicitly with `mark_match_start(name)` or `mark_match_end(name)` and use `capture_between(...)`. That avoids making the current local match carry too much meaning.

### Example: bridge anonymous and named boundaries

```text
Body::AND
 /\(/
 /[^,]*/
 /,/
 /[^,]*/
 /,/
 /[^)]*/
 /\)/
 -> Body[0] { start_capture_slice(); mark_capture_slice(body_start) }
 -> Body[2] { assign(scalar(first), capture_take()) }
 -> Body[4] { assign(scalar(second), capture_take()); start_capture_slice_from(body_start) }
 -> Body[6] {
   return(hash(
     "first", scalar(first),
     "second", scalar(second),
     "whole_body", capture_slice()
   ))
 }
```

`mark_capture_slice(body_start)` promotes the anonymous boundary to a durable mark. `start_capture_slice_from(body_start)` restores it later. This is useful when the rule wants both incremental segments and the whole body.

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
AtEnd::AND
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
Top::AND
 /(?<prefix>foo)\(/
 -> Top[0] { return(call(Child)) }

Child::AND
 /(?<name>\w+)/
 /\)/
 -> Child[0] {
   return(hash(
     "entry_text", entry_text(),
     "entry_prefix", entry_named(prefix),
     "local_text", match_text(),
     "local_name", match_named(name),
     "entry_group_count", count(entry_groups()),
     "local_group_count", count(match_groups())
   ))
 }
```

Read it this way:

- `entry_*` sees the `foo(` match that brought `Child` into the current context.
- `match_*` sees the current local `Child` match, here the word inside the parentheses.
- If this inline example is built directly, select `top_rule => Top` so the public entrypoint is explicit.

This split is the main reason both helper families exist.

## Legacy compatibility helpers

The following older helpers remain useful when reading or migrating legacy specs:

| Helper | Preferred modern direction |
| --- | --- |
| `$CAPTURE` | `capture_slice()` or `assign(scalar(name), capture_slice())` |
| `capture(label)` | `push_value(array(target), capture_slice())` when the target is explicit |
| `capture_if(label)` | `push_nonempty(array(target), trim(capture_slice()))` for the common trimmed-and-nonempty append case; explicit `if(...)` around `capture_slice()` when custom filtering is needed |
| `CAPTURE_IF()` | `push_nonempty(array(current_rule), trim(capture_slice()))` when replacing the legacy current-rule append shape |
| `ibacktrack(label)` / `IBACKTRACK()` | keep as compatibility unless a clearer parser structure removes the need to backtrack |
| `backtrack(label)` / `BACKTRACK()` | keep as compatibility unless a clearer parser structure removes the need to backtrack |

The `label` argument on the legacy capture helpers is compatibility syntax. The active lowering uses the current rule context, not a new independent target selected by that label text. For `capture(label)`, `capture_if(label)`, and `CAPTURE_IF()`, that means the captured value is appended to the rule-local default accumulator array named after the current rule. New docs and examples should normally prefer explicit helper composition.

### BACKTRACK and IBACKTRACK: local cursor rewind

`BACKTRACK()` and `IBACKTRACK()` reposition the parser cursor. They do not unwind parser state, do not pop a search-tree stack, and do not implement any kind of systemic backtracking. They are single local cursor moves (in the Perl reference backend, one-line `pos()` assignments).

- `BACKTRACK()` rewinds the cursor to just before the **parent** match that called the current handler. Concretely, in the Perl reference backend: `pos($$STRING) = $LSPOS - length $LMATCH`. Use it when an action consumed characters for inspection and wants the next rule-level match to start from before those characters.

- `IBACKTRACK()` rewinds the cursor to just before the **inner** (current) match that entered the handler. Concretely, in the Perl reference backend: `pos($$STRING) = $IPOS - length $IMATCH`. Use it when an inner rule read-ahead should be invisible to the next outer rule-level match.

Both are relevant only inside action code attached to a regex slot. The lowercase forms `backtrack(label)` and `ibacktrack(label)` are legacy compatibility spelling; the `label` argument is ignored by the active lowering — the rewind always operates on the current parse cursor, not on a different target selected by label text.

The important distinction:

- **Local cursor rewind** (`BACKTRACK`, `IBACKTRACK`): move the parser cursor backward so the next match re-scans characters that were already consumed (in the Perl reference backend, a `pos()` move). This is lightweight and does not touch any rule-match state.
- **Systemic backtracking** (not implemented): unwind a stack of partial rule matches, restore alternative-choice state, and try a different branch. LinkedSpec does not do this. The parser engine is forward-moving: a rule match either advances the cursor or leaves it unchanged on failure.

Because the rewind is just a local cursor move (a `pos()` manipulation in the Perl reference backend), the current `parse_mode` still applies to the next match that follows. Under `consume` mode, the next match must succeed contiguously from the rewound cursor position. Under `seek` mode, the parser may seek forward from the rewound position.

Use `BACKTRACK()` or `IBACKTRACK()` when an action needs to inspect input and then let the next rule-level construct re-consume it. Prefer a clearer structural arrangement (separate rules, explicit marks, or `capture_take()`) when the rewind is avoidable.

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
