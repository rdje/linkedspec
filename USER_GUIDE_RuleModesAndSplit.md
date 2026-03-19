# USER GUIDE: Rule Modes And Split Boundaries
This guide covers the current rule-shape surface, including explicit `OR`, explicit `AND+`, bounded `OR{...}`, and bounded `AND{...}` labels.

Read this when you want to understand:
- what rule-label sigils already mean today,
- how much of that surface is already part of the supported contract,
- and what `@capture_from_here` actually does when you need split-like staged extraction.

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
explicit_sequence:AND
explicit_repeated_sequence:AND+
explicit_repeated_choice:OR
bounded_choice_exact:OR{2}
bounded_choice_range:OR{2,4}
bounded_choice_open_max:OR{2,}
bounded_choice_open_min:OR{,4}
bounded_sequence_exact:AND{2}
bounded_sequence_range:AND{2,4}
bounded_sequence_open_max:AND{2,}
bounded_sequence_open_min:AND{,4}
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

For authoring purposes, the clearest mental model is that bare `rule:` belongs to the same repeated-choice family as:

```text
rule:OR
rule:OR{1,}
```

and conceptually corresponds to `OR+`.

That mapping matters because:
- bare `rule:` is the historical default repeated-alternative behavior,
- `rule:OR` is now the explicit worded spelling for that same repeated-choice family when you want to say it out loud without adding numeric bounds,
- `rule:|` is the separate single-choice dispatch surface,
- and the worded `OR{...}` family makes the same repeated-choice family explicit when you need bounds.

Representative equivalence example:

```text
item_list:
 /[A-Za-z_]\w*/ -> item_list
 /"(?:[^"\\]|\\.)*"/ -> item_list
```

is the same repeated-choice idea as:

```text
item_list:OR
 /[A-Za-z_]\w*/ -> item_list
 /"(?:[^"\\]|\\.)*"/ -> item_list
```

and:

```text
item_list:OR{1,}
 /[A-Za-z_]\w*/ -> item_list
 /"(?:[^"\\]|\\.)*"/ -> item_list
```

`rule:OR` and `rule:OR{1,}` are explicit grouped-rule spellings. Bare `rule:` remains the historical default surface for that same repeated-choice baseline rather than a promise that every low-level emitted handler path is textually identical.

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

### `:AND` explicit ordered sequence
`AND` means ordered sequence too, with the same ordered-sequence contract as `:&`.

Representative shape:

```text
pair:AND
 /[A-Za-z_]\w*/ -> key
 /\s*=\s*/
 /[^,\n]+/ -> value
```

Use it when you want the ordered-sequence family spelled out explicitly instead of using the shorter `:&` sigil. It is the worded sibling of the existing ordered-sequence baseline, not a repeated-sequence form.

### `:AND+` explicit open-ended repeated sequence
`AND+` means open-ended repeated ordered sequence with the same min-one repetition contract as `AND{1,}`.

Representative shape:

```text
assignment_stream:AND+
 /[A-Za-z_]\w*/ -> assignment_stream
 /\s*=\s*/
 /[^,\n]+/ -> assignment_stream
```

Use it when you want the whole ordered sequence to repeat one or more times and you want that grouped repetition spelled out explicitly without switching to numeric bounds.

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

### `:OR` explicit repeated choice
`OR` means open-ended repeated choice with the same min-one repeated-choice contract as `OR{1,}`.

Representative shape:

```text
token_stream:OR
 /[A-Za-z_]\w*/ -> token_stream
 /"(?:[^"\\]|\\.)*"/ -> token_stream
 /'(?:[^'\\]|\\.)*'/ -> token_stream
```

Use it when you want the repeated-choice family spelled out explicitly without adding numeric bounds. It is the explicit worded sibling of the historical bare `rule:` baseline and the bounded `OR{1,}` form.

### `:OR{N}` exact bounded repeated choice
`OR{N}` means repeated alternative extraction with an exact required count.

Representative shape:

```text
pair_of_hex_digits:OR{2}
 /[0-9A-Fa-f]/ -> pair_of_hex_digits
```

Use it when the rule should match exactly `N` repeated choice iterations.

### `:OR{N,M}` bounded repeated choice
`OR{N,M}` means repeated alternative extraction with both a lower and upper bound.

Representative shape:

```text
up_to_three_flags:OR{1,3}
 /--debug/ -> up_to_three_flags
 /--trace/ -> up_to_three_flags
 /--strict/ -> up_to_three_flags
```

Use it when the rule should succeed only after at least `N` iterations and should stop collecting after `M`.

### `:OR{N,}` open-ended repeated choice
`OR{N,}` means repeated alternative extraction with a required minimum and no DSL-level upper bound beyond the current large internal repeat sentinel.

Representative shape:

```text
two_or_more_items:OR{2,}
 /[A-Za-z_]\w*/ -> two_or_more_items
 /"(?:[^"\\]|\\.)*"/ -> two_or_more_items
```

Use it when the rule should require at least `N` iterations but otherwise behave like the current repeated-alternative model.

### `:OR{,M}` upper-bounded repeated choice
`OR{,M}` means repeated alternative extraction with an implicit lower bound of `0` and an explicit upper bound of `M`.

Representative shape:

```text
optional_pair:OR{,2}
 /[A-Za-z_]\w*/ -> optional_pair
```

Use it when zero matches are allowed but you still want to cap how many alternative hits can be collected.

### `:AND{N}` exact bounded repeated sequence
`AND{N}` means ordered-sequence matching with an exact required repetition count.

Representative shape:

```text
pair_twice:AND{2}
 /[A-Za-z_]\w*/ -> pair_twice
 /\s*=\s*/
 /[^,\n]+/ -> pair_twice
```

Use it when the same ordered sequence must succeed exactly `N` times in a row.

### `:AND{N,M}` bounded repeated sequence
`AND{N,M}` means ordered-sequence matching with both a lower and upper repetition bound.

Representative shape:

```text
directive_triplets:AND{2,4}
 /BEGIN\b/ -> directive_triplets
 /\s+/
 /END\b/ -> directive_triplets
```

Use it when the whole sequence must repeat at least `N` times and at most `M` times.

### `:AND{N,}` open-ended repeated sequence
`AND{N,}` means ordered-sequence matching with a required minimum and no DSL-level upper bound beyond the current large internal repeat sentinel.

Representative shape:

```text
two_or_more_pairs:AND{2,}
 /[A-Za-z_]\w*/ -> two_or_more_pairs
 /\s*=\s*/
 /[^,\n]+/ -> two_or_more_pairs
```

Use it when at least `N` full sequence iterations are required but more are allowed.

### `:AND{,M}` upper-bounded repeated sequence
`AND{,M}` means ordered-sequence matching with an implicit lower bound of `0` and an explicit upper bound of `M`.

Representative shape:

```text
optional_pairs:AND{,2}
 /[A-Za-z_]\w*/ -> optional_pairs
 /\s*=\s*/
 /[^,\n]+/ -> optional_pairs
```

Use it when zero full sequence iterations are allowed but you still want a hard cap on how many whole sequence groups get consumed.

## Worked Repeated-Choice Examples
### Example: explicit open-ended repeated choice

```text
token_stream:OR
 /[A-Za-z_]\w*/ -> token_stream { $token_stream = $LMATCH }
 /"(?:[^"\\]|\\.)*"/ -> token_stream { $token_stream = $LMATCH }
 /'(?:[^'\\]|\\.)*'/ -> token_stream { $token_stream = $LMATCH }
```

What this means:
- at least one alternative hit is required,
- the rule keeps collecting repeated choice matches until no configured alternative matches any longer,
- and this is the explicit worded spelling for the same repeated-choice family that the historical bare `token_stream:` label belongs to.

### Example: exact repeated token pair

```text
hex_pair::OR{2}
 /[0-9A-Fa-f]/ -> hex_pair { $hex_pair = $LMATCH }
```

What this means:
- the rule runs the current alternative-choice machinery repeatedly,
- it must succeed exactly two times,
- and the returned collected value reflects exactly two matched iterations.

### Example: bounded repeated directive list

```text
directive_group:OR{2,4}
 /@include\b/ -> directive_group { $directive_group = $LMATCH }
 /@define\b/ -> directive_group { $directive_group = $LMATCH }
 /@pragma\b/ -> directive_group { $directive_group = $LMATCH }
```

What this means:
- fewer than two successful iterations fail the rule,
- two, three, or four successful iterations pass,
- the fifth possible match is not consumed by this rule because the configured maximum has already been reached.

### Example: coarse repeated extraction with open upper bound

```text
coarse_segment:OR{2,}
 /BEGIN\b/ -> coarse_segment { $coarse_segment = $LMATCH }
 /END\b/   -> coarse_segment { $coarse_segment = $LMATCH }
```

What this means:
- the rule needs at least two anchor hits,
- after that it keeps behaving like repeated alternative extraction,
- and it stays useful for coarse first-pass segmentation before a second-pass parse.

### Example: zero-to-two optional capture anchors

```text
optional_markers:OR{,2}
 /START\b/ -> optional_markers { $optional_markers = $LMATCH }
 /STOP\b/  -> optional_markers { $optional_markers = $LMATCH }
```

What this means:
- zero matches are acceptable,
- one or two matches are also acceptable,
- but the rule will not keep collecting beyond two matches.

## Worked Bounded-AND Examples
### Example: exact repeated key/value pairs

```text
pair_list:AND{2}
 /[A-Za-z_]\w*/ -> pair_list { $pair_list = $LMATCH }
 /\s*=\s*/
 /[^,\n]+/ -> pair_list { $pair_list = $LMATCH }
```

What this means:
- the rule does not repeat individual alternatives,
- it repeats the whole ordered sequence,
- and the returned collected value is grouped by full sequence iteration rather than flattened as one repeated-choice stream.

### Example: two-to-four repeated BEGIN/END marker groups

```text
segments:AND{2,4}
 /BEGIN\b/ -> segments { $segments = $LMATCH }
 /.*?\n/
 /END\b/   -> segments { $segments = $LMATCH }
```

What this means:
- fewer than two full `BEGIN ... END` groups fail the rule,
- two, three, or four full groups pass,
- and the fifth possible group is left for later parsing because this rule has already reached its configured maximum.

### Example: zero-to-two optional sequence groups

```text
optional_assignments:AND{,2}
 /[A-Za-z_]\w*/ -> optional_assignments { $optional_assignments = $LMATCH }
 /\s*=\s*/
 /[^,\n]+/ -> optional_assignments { $optional_assignments = $LMATCH }
```

What this means:
- zero full sequence groups are acceptable,
- one or two full groups are also acceptable,
- but the rule will not keep consuming beyond two complete ordered groups.

### Example: explicit open-ended repeated sequence shorthand

```text
assignment_stream:AND+
 /[A-Za-z_]\w*/ -> assignment_stream { $assignment_stream = $LMATCH }
 /\s*=\s*/
 /[^,\n]+/ -> assignment_stream { $assignment_stream = $LMATCH }
```

What this means:
- the whole ordered sequence must succeed at least once,
- after the first full sequence group it keeps repeating the same ordered-sequence contract,
- and this is the shorthand grouped spelling for the same family as `AND{1,}`.

## What Is Still Deferred
There is no extra shorthand in this immediate rule-mode family still waiting to land.

The remaining deferred work is broader grouped-rule exploration that should only move when real authoring needs justify it, not because the DSL needs every possible combinator spelling up front.

## `@capture_from_here`: The Split Boundary Cursor
`@capture_from_here` is now the preferred grammar surface for this feature.

The older spelling `@move_pos` is still supported as a compatibility alias.

It is easy to misunderstand what it does, so here is the precise version:
- it does not collect text by itself,
- it does not return an AST node by itself,
- it advances the capture-start cursor used by later `$CAPTURE`-style span extraction.

In compiler terms, it lowers to:

```text
$IPOS = pos $$STRING
```

That means:
- before `@capture_from_here`, a later capture starts from the earlier rule-entry boundary,
- after `@capture_from_here`, a later capture starts from the point where the parser had already advanced,
- so the next capture becomes “text since the last anchor” instead of “text since the beginning of the rule.”

That is why it is useful for split-like staged parsing.

## Why `@capture_from_here` Matters
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
logging_annotation: /@((?:log|debug|trace|benchmark|profile|timing)_\w+)\s*\(\s*/ /\s*\)/ 	@capture_from_here
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
- `@capture_from_here` moves the capture baseline forward,
- later capture logic can treat the content between anchors as the meaningful span,
- and the rule can build a coarse structured result from that anchored slice.

If you are reading older specs or older notes, this may still appear as `@move_pos`. That legacy spelling still works and lowers to the same internal `MOVE_POS` event.

## Split-Style Mental Model
If you like a more intuitive description, this is a good one:

- `@capture_from_here` turns the current parser position into the new left edge of the next capture span.
- older specs may still say `@move_pos`, but the meaning is the same.

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
- explicit ordered-sequence label `AND` is now supported on top of the same ordered-sequence family,
- explicit repeated-sequence label `AND+` is now supported on top of the same repeated-sequence family as `AND{1,}`,
- explicit repeated-choice label `OR` is now supported on top of the same repeated-choice family,
- bounded repeated-choice labels `OR{N,M}`, `OR{N}`, `OR{N,}`, and `OR{,M}` are supported on top of the current repeated-alternative model,
- bounded repeated-sequence labels `AND{N,M}`, `AND{N}`, `AND{N,}`, and `AND{,M}` are supported on top of the current ordered-sequence model,
- the validation layer now recognizes that same current rule-label surface for earlier syntax diagnostics instead of only understanding the older `name::` subset,
- `@capture_from_here` is the preferred split-boundary cursor feature,
- `@move_pos` remains a supported compatibility alias for the same lowering,
- and any further grouped-rule strategy expansion is demand-driven future work rather than part of the current syntax contract.

That gives us a stable baseline before we expand the remaining rule-grouping surface further.
