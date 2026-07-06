# Capture, Marks, and Source Locations

LinkedSpec has several helper families for reading parser spans and source positions.

This chapter explains the mental model before the exhaustive method list.

For the method-by-method public reference, read [Source Boundary Helper Reference](source-boundary-helper-reference.md) after this chapter.

## Five anchor families

Most source-boundary helpers belong to one of these families:

- `capture_*`
- `mark_*`
- `cursor_*`
- `entry_*`
- `match_*`

They are intentionally different.

## `capture_*`: the anonymous moving boundary

The anonymous capture boundary is the lightweight “current segment starts here” mechanism.

Use it when one rolling boundary is enough.

Example:

```text
Top::AND
 I { start_capture_slice(); first = undef; }
 /BEGIN/
 /END/
 -> Top[0] { first = capture_slice(); }
 -> Top[1] { return(hash("body", first)); }
```

The important distinction:

- `capture_slice()` reads from the anonymous boundary without moving it
- `capture_take()` reads from the anonymous boundary and advances it

That makes `capture_take()` useful for segmented parsing:

```text
part = capture_take();
```

Read it as:

```text
read the current segment, then roll the segment start forward
```

## `mark_*`: named checkpoints

Marks are named checkpoints.

Use them when you need to remember more than one boundary or revisit a boundary later.

Example:

```text
mark_here(body_start);
body = capture_from(body_start);
```

Named marks are better than anonymous capture state when the rule needs durable labels such as:

- `body_start`
- `header_start`
- `value_end`

Bridge helpers connect the two worlds:

```text
mark_capture_slice(saved_start);
start_capture_slice_from(saved_start);
```

Read those as:

- store the anonymous boundary into a named mark
- restore the anonymous boundary from that named mark

## `cursor_*`: the live parser cursor

The cursor is the live current parser position.

Use cursor helpers when you want to know where the parser is now:

```text
where = cursor_pos();
line = cursor_line();
col = cursor_col();
```

Tail helpers read from the cursor to end-of-input:

```text
rest = cursor_rest();
width = cursor_rest_len();
```

## `entry_*`: the immediate match that entered the rule/action

Entry helpers read the immediate match that brought the action into this context.

Examples:

```text
token = entry_text();
name = entry_group(0);
line = entry_line();
col = entry_col();
```

Use `entry_*` when the action wants the match associated with rule entry or handoff.

## `match_*`: the current local active match

Match helpers read the current local match.

Examples:

```text
text = match_text();
line = match_line();
end_col = match_end_col();
```

Use `match_*` when the action wants the local match currently being processed, not the broader entry match.

## When `entry_*` and `match_*` diverge

For a simple single-regex rule, the match that *entered* the rule and the rule's *local* match are the same span, so `entry_*` and `match_*` agree — use whichever reads best.

They **diverge** when a rule's action runs against a local match that is not the match that dispatched into it — the classic case is a **dispatched child**. Consider a parent that recognizes a `name(` opener and dispatches into a child that reads the word inside:

```text
Call::AND
 /(\w+)\(/ -> Inner

Inner::AND
 /(\w+)/ -> Inner[0] {
   return(hash("outer", entry_text(), "inner", match_text()));
 }
```

Over the input `greet(world)`, the two families read **different** spans:

- `entry_text()` reads the match that **entered** `Inner` — the parent's `greet(` opener.
- `match_text()` reads `Inner`'s **own** local match — the inner word `world`.

The split applies to every reader in both families: `entry_group(0)` / `entry_named(...)` read the entering match's captures (here `greet`), while `match_group(0)` / `match_named(...)` read the local match's captures (here `world`). The same example in reference form, reading captures by index and by name, is in [Source Boundary Helper Reference](source-boundary-helper-reference.md#entry-versus-match-example).

Choose by what you need: `entry_*` for the context that brought the action here, `match_*` for the token the action is processing right now.

## Whole-input helpers

Whole-input helpers are absolute. They do not mean cursor, entry, or local match.

Examples:

```text
source = input_text();
length = input_len();
end_pos = input_end_pos();
end_line = input_end_line();
end_col = input_end_col();
```

These are useful for diagnostics and source metadata when the rule needs to reference the full input.

## Position, line, and column

The naming is deliberate:

- `*_pos()` returns an absolute position
- `*_line()` returns a human-readable line
- `*_col()` returns a human-readable column

Use position helpers for machine logic. Use line/column helpers for diagnostics and messages that humans will read.

## Choosing the right helper

Use this quick rule:

- Need one rolling segment boundary? Use `capture_*`.
- Need a durable named checkpoint? Use `mark_*`.
- Need the live parser position? Use `cursor_*`.
- Need the match that entered this context? Use `entry_*`.
- Need the current local match? Use `match_*`.
- Need whole-source information? Use `input_*`.

That split avoids most confusion.

## Deeper reference

For the full capture/mark contract catalog with exact helper signatures, emitted-Perl shapes, and compatibility aliases, see `USER_GUIDE_ActionIR_Contracts.md` in the repo root. The capture/mark section there covers every helper in the family with its lowering contract.
