# USER GUIDE: Rule Modes And Split Boundaries
This guide covers the current rule-shape surface, including explicit `OR`, explicit `OR+`, explicit `AND+`, bounded `OR{...}`, and bounded `AND{...}` labels.

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
explicit_repeated_choice_shorthand:OR+
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
rule:OR+
rule:OR{1,}
```

and conceptually corresponds to `OR+`.

That mapping matters because:
- bare `rule:` is the historical default repeated-alternative behavior,
- `rule:OR` is now the explicit worded spelling for that same repeated-choice family when you want to say it out loud without adding numeric bounds,
- `rule:OR+` is now the explicit shorthand spelling for that same repeated-choice family when you want repetition punctuation made visible in the label,
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
item_list:OR+
 /[A-Za-z_]\w*/ -> item_list
 /"(?:[^"\\]|\\.)*"/ -> item_list
```

and:

```text
item_list:OR{1,}
 /[A-Za-z_]\w*/ -> item_list
 /"(?:[^"\\]|\\.)*"/ -> item_list
```

`rule:OR`, `rule:OR+`, and `rule:OR{1,}` are explicit grouped-rule spellings. Bare `rule:` remains the historical default surface for that same repeated-choice baseline rather than a promise that every low-level emitted handler path is textually identical.

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

### `:OR+` explicit open-ended repeated choice shorthand
`OR+` means open-ended repeated choice too, with the same min-one repeated-choice contract as `OR` and `OR{1,}`.

Representative shape:

```text
token_stream:OR+
 /[A-Za-z_]\w*/ -> token_stream
 /"(?:[^"\\]|\\.)*"/ -> token_stream
 /'(?:[^'\\]|\\.)*'/ -> token_stream
```

Use it when you want the repeated-choice family spelled out with repetition punctuation instead of the bare worded `OR` form. It does not introduce a different execution model; it is the explicit shorthand sibling of `OR` and `OR{1,}`.

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

## Blind Calls: Direct Rule Invocation with `=>`
Blind calls are the other rule-body edge family.

They look like this:

```text
=> child_rule
```

and they mean something different from:

```text
-> child_rule
```

The short version is:
- `-> child_rule` is regex-slot oriented,
- `=> child_rule` is parser-step oriented.

### What `=> child_rule` does
When a rule uses blind calls, the parent rule is not selecting one of its own regex entry slots for that step.

Instead, it directly invokes another rule as a parser step and works with that child rule's result.

That is why blind calls are useful for wrapper and orchestration rules.

Representative shape:

```text
record:AND
 => header
 => body
 => trailer
```

The practical reading is:
- first call `header`,
- then call `body`,
- then call `trailer`,
- and treat the parent rule as the composition shell around those child parsers.

### Post-call processing after `=> child_rule`
Blind calls can also postprocess the AST/value returned by the child call.

These supported forms now all belong to the blind-call surface:
- `=> child_rule`
- `=> child_rule { ... }`
- `=> child_rule.method(...)`
- `=> child_rule .method(...).method2(...)`

The semantic center is still the same:
- first do `call(child_rule)`,
- store that child result as the current blind-call entry,
- then run any attached block or fluent post-call steps against that current entry.

So a fluent blind-call chain is now explicit sugar for post-call processing that would otherwise live in a block.

Example:

```text
wrapper:AND
 => child .return_a()
```

is equivalent in lowered meaning to:

```text
wrapper:AND
 => child { return_a(wrapper) }
```

The same idea extends to longer chains:
- `=> child .m1(...).m2(...)`
- means “call `child`, then run `m1(...)`, then run `m2(...)` on the current blind-call entry”.

### `-> child_rule` versus `=> child_rule`
This distinction is worth keeping very explicit.

`-> child_rule` means:
- match through the current rule's regex/edge machinery,
- and use `child_rule` as the action-edge target for that regex slot.

`=> child_rule` means:
- invoke `child_rule` directly as a parser step,
- without treating this step as one of the current rule's own regex-slot action edges.

That is why blind calls feel more like parser orchestration than regex-slot dispatch.

### One Rule Should Use One Edge Family
One current contract rule is strict:
- do not mix `-> ...` action edges and `=> ...` blind calls inside the same rule.

This is invalid today:

```text
bad_rule:
 /.../
 -> child_a
 => child_b
```

Use one style or the other for a given rule body.

Current frontend validation now rejects that mixed rule shape before bootstrap parse on both:
- multiline rule paragraphs,
- and same-line packed rule paragraphs.

### Why Mixing `->` And `=>` Is A Bad Fit
This rule is not just stylistic.

The two edge families describe two different execution models.

`-> child_rule` means:
- this rule is still driven by its own regex-slot machinery,
- a local regex hit decides which slot matched,
- and the action edge then follows that regex-slot decision.

`=> child_rule` means:
- this rule is acting as a composition shell,
- the parent directly invokes another parser step,
- and the child rule, not the parent regex list, is doing the real match work for that step.

Blind calls do not use regex-slot indexing:
- `=> child_rule` is valid,
- `=> { ... }` is invalid because a blind call must still name a child rule,
- `=> child_rule-extra` is invalid because blind-call targets stay plain word rule names,
- `=> child_rule[0]` is invalid,
- and regex-slot selection stays on the action-edge side as `-> child_rule[idx]`.

So if one rule mixes both families, several semantic questions become muddy very quickly:
- is the rule mainly regex-slot driven or parser-call driven?
- what is supposed to own input progress at that point: the parent regex slot or the child parser?
- what should repeated grouping mean when one step is a local regex dispatch and the next step is a direct child-rule call?
- what should the parent return shape mean when part of the rule is edge-following and part of it is direct orchestration?

That is why the current contract stays strict:
- one rule, one execution model.

If the rule is mainly choosing among its own regex slots, use `->`.

If the rule is mainly orchestrating child parsers as building blocks, use `=>`.

That division keeps the authoring model easier to read, the runtime handler families simpler, and the resulting parser behavior much less surprising.

### Best Current Blind-Call Shapes
The most clearly documented blind-call shapes today are:
- ordered-sequence wrappers,
- repeated ordered-sequence wrappers,
- and single-choice wrappers.

#### Ordered sequence wrapper

```text
record:&
 => header
 => body
 => trailer
```

or, spelled out:

```text
record:AND
 => header
 => body
 => trailer
```

This is the cleanest blind-call authoring pattern today.

It is a good fit when:
- each child rule already owns its own anchors and local parsing,
- and the parent rule exists mainly to say “these child parsers must succeed in this order.”

#### Repeated ordered-sequence wrapper

```text
chunk_stream:AND+
 => chunk_header
 => chunk_body
```

or with bounds:

```text
chunk_stream:AND{2,4}
 => chunk_header
 => chunk_body
```

This is the natural continuation of the sequence-wrapper family when the whole blind-call sequence should repeat as one group.

#### Single-choice wrapper

```text
atom:|
 => quoted_string
 => integer_literal
 => bare_identifier
```

This is the cleanest blind-call choice pattern today.

It is a good fit when:
- the parent rule is really a wrapper around several child parsers,
- the children already know how to parse themselves,
- and the parent just needs to try them in order and keep the first one that succeeds.

### Why Blind Calls Exist
Blind calls make the most sense when the parent rule is mainly composition logic.

That happens in patterns like:
- wrapper rules,
- staged outer orchestration,
- coarse-to-fine parsing where child rules own the real local anchors,
- and “super split” or segmentation passes where the parent rule coordinates child parsers instead of owning all the regex slots itself.

Representative staged-orchestration sketch:

```text
segment_pass:AND
 => segment_open
 => segment_payload
 => segment_close
```

The point of that shape is not that the parent has its own rich regex story.

The point is that:
- `segment_open`, `segment_payload`, and `segment_close` already know how to parse their own anchored regions,
- and the parent rule exists to compose those parser steps into one coarser result.

That makes blind-call useful for the kind of multi-pass extraction workflow where you first isolate chunks and then parse those chunks more deeply in a second pass.

### Repeated-Choice Blind Calls
Repeated-choice blind-call is now part of the supported current surface too.

One important design point is already clear, though:
- blind-call does **not** implicitly switch a rule into ordered-sequence behavior,
- `=> child_rule` only says “compose by calling child parsers as parser steps,”
- and the rule label still decides whether those steps are composed as sequence, choice, or repeated choice.

So:
- if you want sequential orchestration, say it explicitly with `:&`, `:AND`, `:AND+`, or `:AND{...}`,
- if you want wrapper choice, say it explicitly with `:|`,
- and do not treat bare `rule:` with blind calls as meaning “AND by default.”

So the current guidance is:
- if you want blind-call orchestration, prefer the ordered-sequence blind-call family (`:&`, `:AND`, `:AND+`, `:AND{...}`),
- if you want one wrapper choice among child parsers, prefer `:|`,
- and if you want repeated-choice blind-call behavior, prefer the explicit `:OR`, `:OR+`, or `:OR{...}` spellings when you want to make that intent obvious at a glance.

The repeated-choice blind-call family now means:
- bare `rule:` with `=> child_rule` follows the repeated-choice baseline,
- `rule:OR` is the explicit worded repeated-choice blind-call spelling,
- `rule:OR+` is the explicit shorthand repeated-choice blind-call spelling,
- `rule:OR{...}` is the bounded repeated-choice blind-call spelling,
- and `rule:+` stays the compact one-or-more repeated-choice spelling.

Representative repeated-choice blind-call shape:

```text
chunk_stream:OR
 => chunk_header
 => chunk_body
 => chunk_footer
```

That means:
- on each iteration, try the child rules in order,
- keep the first child parser that succeeds for that iteration,
- collect that child result,
- then repeat until no child parser succeeds or the rule hits its upper bound.

Worked bounded/shorthand examples:

```text
entry_stream:+
 => header_line
 => body_line
```

This means:
- run one-or-more repeated-choice iterations,
- each iteration picks the first child parser that succeeds,
- and the rule fails if even the first iteration cannot find a successful child.

```text
pair_or_triplet:OR{2,3}
 => digit_pair
 => hex_pair
```

This means:
- at least two successful child-choice iterations are required,
- at most three successful child-choice iterations are collected,
- and if only one child-choice iteration succeeds, the whole rule fails.

```text
optional_prefixes:OR{,2}
 => plus_prefix
 => minus_prefix
```

This means:
- zero, one, or two successful child-choice iterations are allowed,
- the standalone rule may legitimately return an empty collection,
- but a repeated parent rule will now stop cleanly instead of looping forever if such an optional child succeeds without advancing the input.

So repeated-choice blind-call is real supported surface now, even if `:AND` and `:|` are still often the clearest starting points for day-to-day authoring.

## What Is Still Deferred
There is no extra shorthand in this immediate rule-mode family still waiting to land.

The remaining deferred work is broader grouped-rule exploration that should only move when real authoring needs justify it, not because the DSL needs every possible combinator spelling up front.

## `@capture_from_here`: The Split Boundary Cursor
`@capture_from_here` is now the preferred grammar surface for this feature.

The older spelling `@move_pos` is still supported as a compatibility alias.

There is now also a named checkpoint form:
- `@mark(name)`

That named form stores the current parser position under `name` so later `capture_from(name)` calls return the substring from that named checkpoint up to the left edge of the current match.

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

## `@mark(name)`: Named Checkpoints
`@mark(name)` is the first named checkpoint surface in the capture/mark API.

In compiler terms, it lowers to:

```text
if ($$minfo{index} == slot_idx) {
  $$info{marks}{'current_rule'}{'name'} = pos $$STRING
}
```

That means:
- it does not capture text by itself,
- it records the current parser position under a stable name,
- the name is scoped to the current rule label,
- and later `capture_from(name)` or `capture_take(name)` in that same rule can recover the span that starts at that named point.

The most important semantic detail is this:
- `capture_from(name)` returns text from the saved mark up to the left edge of the current match,
- it does not include the current local match itself,
- `capture_from(name)` is a pure read and does not move the mark,
- `capture_take(name)` returns that same span and then advances the named mark to the current parser position,
- `capture_between(start_mark, end_mark)` returns text between two explicit named checkpoints without using the current match edge as the right boundary,
- `mark_here(name)` updates the named mark to the current parser position without first reading a span from it,
- `mark_match_start(name)` updates the named mark to the left edge of the current match instead of to the current parser position,
- `clear_mark(name)` removes that named mark from the current rule-local mark bucket,
- `mark_exists(name)` reports whether that named mark is currently present in the current rule-local mark bucket,
- so a later regex slot in the same rule usually acts as the right delimiter of the captured span.

In high/debug trace mode, mark writes now also show where that checkpoint lands inside the input:
- `@mark(name)`, `mark_here(name)`, `mark_match_start(name)`, and the advancing write inside `capture_take(name)` emit a short visible excerpt of the input string,
- and the trace prints a caret on the next line under the stored checkpoint position,
- so you can see immediately whether the rule stored a post-match parser position or the left edge of the current match.

That means the usual authoring shape is:
- match an opening anchor,
- set `@mark(name)`,
- keep matching forward,
- then on a later closing delimiter or separator in that same rule call `capture_from(name)` if the mark should stay stable,
- or call `capture_take(name)` if the mark should roll forward like a named split cursor,
- or call `capture_between(start_mark, end_mark)` if both edges should come from explicit named checkpoints,
- or call `mark_here(name)` if a later action block should move the named checkpoint explicitly without bundling the write into the read,
- or call `mark_match_start(name)` if a later action block should remember where the current match begins instead of where it ends,
- or call `clear_mark(name)` if the named checkpoint should stop being visible to later same-rule reads,
- or call `mark_exists(name)` if a later action block should branch on whether the named checkpoint is still present.

## Mark Timing: Later Slot, Not Same Slot
There is one timing rule that matters a lot in practice:

- `@mark(name)` becomes visible after the regex slot that carries it completes,
- so an action on that same slot should not expect the new mark yet,
- if you want to use the mark, do it from a later regex slot in the same rule,
- child rules do not inherit that named mark automatically.

That follows the current lowering shape:
- the mark lowers into `LECODE`,
- and `LECODE` is a later phase than the action attached to that same slot.

## Worked Example: Same-Rule Delimited Capture
This is the clearest safe checkpoint example today:

```text
semantic_chunk::AND
 I { declare(scalar, stage) }
 /foo\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> semantic_chunk[0] { assign(scalar(stage), "open") }
 -> semantic_chunk[1] { assign(scalar(stage), "body") }
 -> semantic_chunk[2] { return(array("?semantic_chunk:", capture_from(body_start))) }
```

On input:

```text
foo(bar)
```

the practical reading is:
- `/foo\(/` matches the stable opening anchor,
- `@mark(body_start)` remembers the start of the inner span,
- `/\w+/` consumes the inner content,
- `/\)/` is the right delimiter,
- `capture_from(body_start)` returns `bar`.

This is the easiest checkpoint pattern to teach:
- the rule owns the left boundary,
- the later slot in that same rule owns the right boundary,
- and the captured text is the span between them.

## Worked Example: Same-Rule Separator Capture
The current match does not have to be a closing delimiter. A separator works too.

```text
left_item::AND
 I { declare(scalar, stage) }
 /\(/
 @mark(left_start)
 /[^,]+/
 /,/
 -> left_item[0] { assign(scalar(stage), "open") }
 -> left_item[1] { assign(scalar(stage), "content") }
 -> left_item[2] { return(array("?left_item:", capture_from(left_start))) }
```

On input shaped like:

```text
(alpha,beta)
```

the current match at the final comma slot is the comma. That means `capture_from(left_start)` returns the text before the comma, not including the comma itself.

This is the key generalization:
- the current match acts as the right edge,
- not only closing delimiters,
- but any later separator or anchor slot in the same rule can play that role.

## Worked Example: Advancing Named Capture
Sometimes a stable named checkpoint is not enough. In repeated separator-style parsing, you often want to read the current span and then move the named checkpoint forward so the next capture starts after the current separator.

That is what `capture_take(name)` does.

```text
csv_triplet::AND
 I { declare(scalar, stage, first, second) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /,\s*(?=gamma)/
 /gamma/
 /\)/
 -> csv_triplet[0] { assign(scalar(stage), "open") }
 -> csv_triplet[1] { assign(scalar(stage), "first_value") }
 -> csv_triplet[2] { assign(scalar(first), capture_take(body_start)) }
 -> csv_triplet[3] { assign(scalar(stage), "second_value") }
 -> csv_triplet[4] { assign(scalar(second), capture_take(body_start)) }
 -> csv_triplet[5] { assign(scalar(stage), "third_value") }
 -> csv_triplet[6] { return(array("?csv_triplet:", scalar(first), scalar(second), capture_from(body_start))) }
```

On input:

```text
foo(alpha, beta, gamma)
```

the practical reading is:
- the first `capture_take(body_start)` returns `alpha` and moves `body_start` to just after the first comma,
- the second `capture_take(body_start)` returns `beta` and moves `body_start` to just after the second comma,
- the final `capture_from(body_start)` returns `gamma` without moving the mark again.

This is the named split-cursor pattern:
- `capture_from(name)` is the stable read,
- `capture_take(name)` is the advancing read.

## Worked Example: Explicit Two-Mark Span
Sometimes the right edge should not come from the current match at all. Instead, the rule may want to remember a second explicit checkpoint and later capture the span between those two named positions.

That is what `capture_between(start_mark, end_mark)` is for.

```text
explicit_two_mark_span::AND
 I { declare(scalar, stage, first_segment) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> explicit_two_mark_span[0] { assign(scalar(stage), "open") }
 -> explicit_two_mark_span[1] { assign(scalar(stage), "first_value"); mark_here(first_end) }
 -> explicit_two_mark_span[2] { assign(scalar(stage), "separator"); assign(scalar(first_segment), capture_between(body_start, first_end)) }
 -> explicit_two_mark_span[3] { assign(scalar(stage), "second_value") }
 -> explicit_two_mark_span[4] { return(array("?explicit_two_mark_span:", scalar(first_segment), capture_from(body_start))) }
```

On input:

```text
foo(alpha,beta)
```

the practical reading is:
- `@mark(body_start)` stores the left edge just after `(`,
- `mark_here(first_end)` stores a second checkpoint just after `alpha`,
- `capture_between(body_start, first_end)` returns `alpha`,
- and the final `capture_from(body_start)` still returns `alpha,beta` because that helper still uses the current match edge.

This is the explicit-two-mark pattern:
- `capture_from(name)` uses one named checkpoint plus the current match edge,
- `capture_between(start_mark, end_mark)` uses two named checkpoints,
- and `mark_here(name)` is the usual way to establish the second explicit post-match right boundary.

## Worked Example: Left Edge of a Closing Match
Sometimes the right boundary should be the left edge of the current closing token, not the post-match parser position after that token.

That is what `mark_match_start(name)` is for.

```text
explicit_left_edge_end_mark::AND
 I { declare(scalar, stage) }
 /foo\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> explicit_left_edge_end_mark[0] { assign(scalar(stage), "open") }
 -> explicit_left_edge_end_mark[1] { assign(scalar(stage), "body") }
 -> explicit_left_edge_end_mark[2] { mark_match_start(end_mark); mark_here(after_end); return(array("?explicit_left_edge_end_mark:", capture_between(body_start, end_mark), capture_between(body_start, after_end))) }
```

On input:

```text
foo(bar)
```

the practical reading is:
- `mark_match_start(end_mark)` records the left edge of the current `)` match,
- `mark_here(after_end)` records the post-match parser position just after `)`,
- `capture_between(body_start, end_mark)` returns `bar`,
- `capture_between(body_start, after_end)` returns `bar)`.

This is the left-edge end-marker pattern:
- `mark_here(name)` stores post-match `pos $$STRING`,
- `mark_match_start(name)` stores `$LSPOS - length $LMATCH`,
- and `capture_between(...)` makes that distinction visible immediately.

## Worked Example: Stable Read, Explicit Advance
Sometimes the rule wants to read from a stable named checkpoint first and only then decide to move it.

That is what `mark_here(name)` is for.

```text
explicit_mark_move::AND
 I { declare(scalar, stage, first) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> explicit_mark_move[0] { assign(scalar(stage), "open") }
 -> explicit_mark_move[1] { assign(scalar(stage), "first_value") }
 -> explicit_mark_move[2] { assign(scalar(first), capture_from(body_start)); mark_here(body_start) }
 -> explicit_mark_move[3] { assign(scalar(stage), "second_value") }
 -> explicit_mark_move[4] { return(array("?explicit_mark_move:", scalar(first), capture_from(body_start))) }
```

On input:

```text
foo(alpha,beta)
```

the practical reading is:
- `capture_from(body_start)` reads `alpha` from the stable mark,
- `mark_here(body_start)` then moves that mark to the current parser position after the comma,
- the final `capture_from(body_start)` returns `beta`.

This is the explicit-control pattern:
- `capture_from(name)` reads without moving,
- `mark_here(name)` moves without reading,
- `capture_take(name)` combines those two operations when that is what the rule really wants.

## Worked Example: Stable Read, Explicit Clear
Sometimes the rule wants to consume one stable named span and then make that mark unavailable to later reads in the same rule.

That is what `clear_mark(name)` is for.

```text
explicit_mark_clear::AND
 I { declare(scalar, stage, first) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> explicit_mark_clear[0] { assign(scalar(stage), "open") }
 -> explicit_mark_clear[1] { assign(scalar(stage), "first_value") }
 -> explicit_mark_clear[2] { assign(scalar(first), capture_from(body_start)); clear_mark(body_start) }
 -> explicit_mark_clear[3] { assign(scalar(stage), "second_value") }
 -> explicit_mark_clear[4] { return(array("?explicit_mark_clear:", scalar(first), capture_from(body_start))) }
```

On input:

```text
foo(alpha,beta)
```

the practical reading is:
- `capture_from(body_start)` reads `alpha` from the stable mark,
- `clear_mark(body_start)` removes that named mark,
- the final `capture_from(body_start)` returns `undef` because the mark is no longer present.

This is the explicit-reset pattern:
- `capture_from(name)` reads without moving,
- `clear_mark(name)` drops the checkpoint,
- later same-rule reads see that the mark is gone.

## Worked Example: Explicit Presence Check
Sometimes the rule wants to know whether a named checkpoint is still alive without reading or moving it.

That is what `mark_exists(name)` is for.

```text
explicit_mark_presence::AND
 I { declare(scalar, stage, before_clear) }
 /foo\(/
 @mark(body_start)
 /alpha/
 /,\s*(?=beta)/
 /beta/
 /\)/
 -> explicit_mark_presence[0] { assign(scalar(stage), "open") }
 -> explicit_mark_presence[1] { assign(scalar(stage), "first_value") }
 -> explicit_mark_presence[2] { assign(scalar(before_clear), mark_exists(body_start)); clear_mark(body_start) }
 -> explicit_mark_presence[3] { assign(scalar(stage), "second_value") }
 -> explicit_mark_presence[4] { return(array("?explicit_mark_presence:", scalar(before_clear), mark_exists(body_start))) }
```

On input:

```text
foo(alpha,beta)
```

the practical reading is:
- the first `mark_exists(body_start)` returns `1` because the named mark is present,
- `clear_mark(body_start)` removes that named mark,
- the final `mark_exists(body_start)` returns `0` because the mark is now absent.

This is the explicit-presence pattern:
- `mark_exists(name)` reports presence without reading a span,
- `clear_mark(name)` still owns deletion,
- and later same-rule logic can branch on mark presence directly instead of encoding that question through a read helper.

That branching use is part of the supported surface too. In other words, this is intentionally valid:

```text
if(mark_exists(body_start)); assign(scalar(state), "present"); else; assign(scalar(state), "missing"); endif
```

and so is:

```text
if(not(mark_exists(body_start))); return(array("?state:", "gone")); endif
```

## Worked Example: Several Independent Checkpoints
Named checkpoints become more useful once one anonymous split cursor is no longer enough.

You can treat them as separate named left edges:
- `@mark(header_start)`
- `@mark(body_start)`
- `@mark(argument_start)`

Then later actions in that same rule can ask for exactly the span they want:

```text
capture_from(header_start)
capture_from(body_start)
capture_from(argument_start)
```

That is the main reason to choose `@mark(name)` over anonymous `@capture_from_here`:
- anonymous split is good when one moving capture baseline is enough,
- named marks are better when multiple checkpoints may coexist,
- named marks are also better when the same rule needs several stable named left edges.

## Worked Example: Same Name in Different Rules
Named marks are rule-local, so different rules can reuse the same mark name safely.

```text
header::AND
 I { declare(scalar, stage) }
 /\[/
 @mark(body_start)
 /\w+/
 /\]/
 -> header[0] { assign(scalar(stage), "open") }
 -> header[1] { assign(scalar(stage), "body") }
 -> header[2] { return(array("?header:", capture_from(body_start))) }

payload::AND
 I { declare(scalar, stage) }
 /\(/
 @mark(body_start)
 /\w+/
 /\)/
 -> payload[0] { assign(scalar(stage), "open") }
 -> payload[1] { assign(scalar(stage), "body") }
 -> payload[2] { return(array("?payload:", capture_from(body_start))) }
```

Both rules use `body_start`, but they do not collide because each rule keeps its own named-mark bucket.

## Worked Example: Missing Marks Are Safe
`capture_from(name)` and `capture_take(name)` are intentionally safe if the mark does not exist yet.

If the named mark is absent:
- either helper returns `undef`,
- it does not throw by itself,
- and `capture_take(name)` also leaves the missing mark untouched,
- and `mark_here(name)` can still initialize the rule-local mark explicitly at the current parser position,
- and `clear_mark(name)` stays a harmless no-op,
- so action code can branch explicitly if the mark is optional in that rule family.

That means this is legal:

```text
-> rule[0] {
     return(array("?body:", capture_from(body_start)))
   }
```

If the mark is absent, the payload becomes:

```text
["?body:", undef]
```

## Choosing Between Anonymous and Named Checkpoints
Use `@capture_from_here` when:
- one moving anonymous capture baseline is enough,
- you do not need to keep more than one checkpoint alive at once,
- and the capture flow is local enough that naming the checkpoint adds no clarity.

Use `@mark(name)` when:
- more than one checkpoint may be alive at once,
- the checkpoint meaning benefits from a real name,
- or the same rule needs more than one named left edge.

Use `capture_from(name)` when:
- the named checkpoint should stay stable for more than one later read,
- or you want to compare more than one later right boundary against the same named left edge.

Use `capture_take(name)` when:
- you want the named checkpoint to roll forward after each read,
- the rule behaves like a named split cursor,
- or a repeated separator/delimiter pattern should keep consuming successive fields.

Use `capture_between(start_mark, end_mark)` when:
- both span boundaries should come from named checkpoints,
- the rule wants to compare an explicit two-mark span with a current-match-edge span,
- or the right edge should be remembered earlier than the final read site.

Use `mark_here(name)` when:
- the rule should decide explicitly when a named checkpoint moves,
- you want stable read first and explicit advance second,
- or the mark should be updated even when no current capture string is being returned.

Use `mark_match_start(name)` when:
- the mark should store the left edge of the current match,
- a closing token or delimiter should be excluded from a later `capture_between(...)` span,
- or the rule needs both the left edge and the post-match edge of the same current match.

Use `clear_mark(name)` when:
- the rule should decide explicitly when a named checkpoint disappears,
- one stable read should be followed by an explicit drop,
- or later same-rule reads should see that the mark is no longer present.

Use `mark_exists(name)` when:
- the rule should ask whether a named checkpoint is currently present,
- later logic should distinguish “mark still alive” from “mark already cleared,”
- or the rule wants explicit presence metadata without reading or mutating the capture span itself.

Documentation note:
- this guide prefers backend-neutral helper forms such as `return(payload)`, `assign(...)`, and `call(rule)` in code blocks,
- while [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md) is the place that shows the Perl lowering explicitly.

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
- explicit repeated-choice shorthand `OR+` is now supported on top of the same repeated-choice family as `OR` and `OR{1,}`,
- bounded repeated-choice labels `OR{N,M}`, `OR{N}`, `OR{N,}`, and `OR{,M}` are supported on top of the current repeated-alternative model,
- bounded repeated-sequence labels `AND{N,M}`, `AND{N}`, `AND{N,}`, and `AND{,M}` are supported on top of the current ordered-sequence model,
- blind-call `=> child_rule` is a real current advanced rule-body surface and should not be mixed with `-> child_rule` inside one rule,
- the clearest documented blind-call shapes today are ordered-sequence wrappers (`:&`, `:AND`, `:AND+`, `:AND{...}`) and single-choice wrappers (`:|`),
- repeated-choice blind-call use on `rule:`, `:OR`, `:OR+`, `:+`, and `:OR{...}` is now supported current surface too, with label-driven repeated-choice semantics rather than implicit sequence semantics,
- the validation layer now recognizes that same current rule-label surface for earlier syntax diagnostics instead of only understanding the older `name::` subset,
- `@capture_from_here` is the preferred split-boundary cursor feature,
- `@mark(name)` is the preferred named checkpoint surface,
- `@move_pos` remains a supported compatibility alias for the same lowering,
- `capture_from(name)` currently means “text from the named checkpoint up to the left edge of the current match,”
- `capture_take(name)` means “return that same span and then advance the named checkpoint to the current parser position,”
- `capture_between(start_mark, end_mark)` means “text between two explicit named checkpoints in the current rule-local mark bucket,”
- `mark_here(name)` means “set or overwrite that named checkpoint at the current parser position without first reading from it,”
- `mark_match_start(name)` means “set or overwrite that named checkpoint at the left edge of the current match,”
- `clear_mark(name)` means “delete that named checkpoint from the current rule-local mark bucket,”
- `mark_exists(name)` means “return `1` if that named checkpoint is currently present in the current rule-local mark bucket, otherwise `0`,”
- named marks are rule-local, so different rules can reuse the same mark name without colliding,
- and marks are a later-slot surface, so same-slot actions should not expect a freshly written mark yet,
- and any further grouped-rule strategy expansion is demand-driven future work rather than part of the current syntax contract.

That gives us a stable baseline before we expand the remaining rule-grouping surface further.
