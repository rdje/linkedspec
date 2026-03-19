# USER GUIDE: Rule Modes And Split Boundaries
This guide covers the current rule-shape surface that exists before any future `OR{N,M}` or `AND{N,M}` extension work.

Read this when you want to understand:
- what rule-label sigils already mean today,
- how much of that surface is already part of the supported contract,
- and what `@move_pos` actually does when you need split-like staged extraction.

## Current Rule Label Surface
Today, rule labels support a small, explicit set of suffix modes.

Baseline labels:

```text
top_rule::
regular_rule:
```

Current mode suffixes:

```text
sequence_rule:&
choice_rule:|
one_or_more_rule:+
zero_or_more_rule:*
optional_rule:?
```

Those are the current supported sigils. They are not placeholders for future grouped syntax. They are the current surface.

## What Each Current Mode Means
### Default rule shape
The default label shape stays on the current repeated-alternative extraction model.

Examples:

```text
top_rule::
 -> section_header
 -> section_body
 -> section_footer
```

```text
token_stream:
 /.../ -> token
 -> comment
 -> whitespace
```

Treat that as the current baseline LinkedSpec rule model. It is the baseline we should keep explicit and stable before layering richer grouped repetition on top.

### `:&` ordered sequence
`:&` means ordered sequence.

Representative shape:

```text
pair:&
 /[A-Za-z_]\w*/ -> key
 /\s*=\s*/
 /[^,\n]+/ -> value
```

Use it when the rule should succeed only if the expected pieces arrive in sequence.

### `:|` choice
`:|` means single-choice dispatch.

Representative shape:

```text
item:|
 /"(?:[^"\\]|\\.)*"/ -> quoted_string
 /\d+/ -> integer_literal
 /[A-Za-z_]\w*/ -> bare_identifier
```

Use it when the rule is a choice among alternatives rather than an ordered chain.

### `:+` one or more
`:+` is the current one-or-more repetition surface.

Representative shape:

```text
argument_list:+
 /[A-Za-z_]\w*/ -> argument_item
```

Think of it as the current repetition mode for “repeat until this rule stops matching, but require at least one successful iteration.”

### `:*` zero or more
`:*` is the current zero-or-more repetition surface.

Representative shape:

```text
separator_noise:*
 /\s+/
 /#.*\n/
```

Use it when the rule may match nothing at all and that still counts as success.

### `:?` zero or one
`:?` is the current optional repetition surface.

Representative shape:

```text
optional_trailing_comment:?
 /#.*$/
```

Use it when the rule should either match once or not match at all.

## What Is Not Supported Yet
These are still deferred future work, not current syntax:

```text
OR{N,M}
OR{N}
OR{N,}
OR{,M}
AND+
AND{N,M}
AND{N}
AND{N,}
AND{,M}
```

The roadmap still treats those as future grouped-rule exploration, not current authoring syntax.

## `@move_pos`: The Split Boundary Cursor
`@move_pos` is already part of the current grammar surface.

It is easy to misunderstand what it does, so here is the precise version:
- it does not collect text by itself,
- it does not return an AST node by itself,
- it advances the capture-start cursor used by later `$CAPTURE`-style span extraction.

In compiler terms, it lowers to:

```text
$IPOS = pos $$STRING
```

That means:
- before `@move_pos`, a later capture starts from the earlier rule-entry boundary,
- after `@move_pos`, a later capture starts from the point where the parser had already advanced,
- so the next capture becomes “text since the last anchor” instead of “text since the beginning of the rule.”

That is why it is useful for split-like staged parsing.

## Why `@move_pos` Matters
This feature is especially useful when:
- the full structure is awkward to parse in one pass,
- but the file has reliable anchors,
- and you want to extract raw inner chunks first and parse them in a second pass.

That is a real LinkedSpec strength:
1. use stable outer anchors to capture coarse segments,
2. build a first-level AST that preserves those raw substrings,
3. parse those substrings with a second `.spec` or another follow-up parser.

This is exactly the kind of coarse-to-fine workflow LinkedSpec is good at.

## Real In-Tree Example
A real current example already exists in [`specs/ebnf.spec`](specs/ebnf.spec):

```text
logging_annotation: /@((?:log|debug|trace|benchmark|profile|timing)_\w+)\s*\(\s*/ /\s*\)/ 	@move_pos
I {$IMATCH =~ s/@|\s*\(//go}

-> quoted_string {
  push @logging_annotation, call(quoted_string)->[1]
}
-> comma.capture_if
-> logging_annotation[1] {
  CAPTURE_IF();
  return ['logging_annotation', [$IMATCH, [@logging_annotation]]]
}
```

Why that shape matters:
- the outer anchors find the logging annotation and its closing `)`,
- `@move_pos` moves the capture baseline forward,
- later capture logic can treat the content between anchors as the meaningful span,
- and the rule can build a coarse structured result from that anchored slice.

## Split-Style Mental Model
If you like a more intuitive description, this is a good one:

- `@move_pos` turns the current parser position into the new left edge of the next capture span.

That makes it useful as a split-boundary marker.

It is still better to think “capture cursor move” than “magic split operator,” because the cursor explanation matches what the compiler actually emits.

## Practical Pattern: Coarse Outer Pass, Finer Inner Pass
A staged parsing workflow can look like this:

```text
outer_rule:
  1. match a stable opening anchor,
  2. move the capture boundary,
  3. keep scanning until a stable closing anchor,
  4. capture the raw middle region,
  5. store that region in the first-pass AST,
  6. parse that stored region with another rule family or another parser.
```

That pattern is especially valuable when:
- the inner region has its own mini-language,
- delimiter nesting is irregular,
- or the inner syntax is easier to parse once isolated from surrounding boilerplate.

## Current Contract
The current supported contract is:
- `:&`, `:|`, `:+`, `:*`, and `:?` are real current rule-mode sigils,
- `@move_pos` is a real current split-boundary cursor feature,
- and richer grouped forms like `OR{N,M}` or `AND{N,M}` are still future work.

That gives us a stable baseline before we expand the rule-grouping surface further.
