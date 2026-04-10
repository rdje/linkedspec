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
 /name=(\w+)/ -> Value {
   declare(scalar, name);
   assign(scalar(name), entry_group(0));
   return(hash("kind", "assignment", "name", scalar(name)));
 }
```

That reads as:

- declare a working scalar
- assign it from the entry match capture group
- return a structured hash payload

The important part is not the exact emitted Perl. The important part is that the parser action expresses a portable semantic operation.

## Main helper families

The current helper surface is broad, but it is easier to learn in families:

- value and container helpers: `scalar(...)`, `array(...)`, `hash(...)`, `flat_array(...)`, `join_values(...)`
- declaration helpers: `declare(...)`, `declare_s(...)`, `declare_a(...)`, `declare_h(...)`
- assignment and mutation helpers: `assign(...)`, `push(...)`, `push_value(...)`, `push_nonempty(...)`, `set_key(...)`
- capture and mark helpers: `capture_slice()`, `capture_take()`, `mark_here(name)`, `capture_from(name)`
- source-location helpers: `cursor_line()`, `cursor_col()`, `entry_start_pos()`, `match_end_col()`
- input and match readers: `input_text()`, `entry_text()`, `match_text()`, `entry_group(index)`
- control-flow helpers: `if(...)`, `elseif(...)`, `else`, `endif`, `switch`, `case`, `default`, `endswitch`
- rule-dispatch helpers: `call(rule)` and helper-based child-result handling

The linked chapters below introduce these families in public-facing terms. The repo-root ActionIR guides remain the exhaustive working references while the book continues growing.

## What to pair with this chapter

The repo’s ActionIR-focused guides remain the deeper working references while this book grows:

- `USER_GUIDE_ActionIR_Contracts.md`
- `USER_GUIDE_ActionIR_MethodLowering.md`
- `USER_GUIDE_ActionIR_EmittedPerlReference.md`

The long-term goal is for this book to absorb that surface in progressively clearer public-facing chapters.
