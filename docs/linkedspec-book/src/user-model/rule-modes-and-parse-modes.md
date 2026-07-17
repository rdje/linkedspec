# Rule Modes and Parse Modes

LinkedSpec rule execution has two independent axes:

- the rule mode, which is written on the rule label and controls how that rule composes its body,
- the parse mode, which is passed to parser construction and controls cursor discipline while the parser runs.

Keep those two ideas separate. A rule label such as `Item:AND` says "compose this rule body as an ordered sequence." A parser option such as `parse_mode => 'consume'` says "do not skip forward before matching the next anchor." They answer different questions.

> **Current behavior versus rollout target:** This chapter documents the public
> implementation that exists today. Audit `FUTURE-PARITY-BACKLOG.9.1.0` found
> that the caller-global option changes every nested rule and already creates an
> uncovered default-AND backend difference: Perl, Dart, Julia, and Lua default
> to global `seek`, while Rust defaults to its compiled AND=`consume` mode when
> no override is supplied. ADR `0044` now ratifies the replacement: OR/default families
> intrinsically seek and AND families intrinsically consume, removes the public
> global override, and retains seek/consume only as low-level matcher
> algorithms. Parent mode never
> propagates to or overrides child mode: an OR child remains seek under an AND
> parent, and an AND child remains consume under an OR parent. Mode-sensitive
> bare edges, explicit exceptions, descriptor/generated metadata, and removal
> diagnostics are also fixed below. Perl `.9.1.3.1` now parses and normalizes
> those bare edges and records derived family/cursor facts before handler
> emission. Live handlers and the public API still use the current global mode;
> neutral contract/inventory `.9.1.2` is executable at 1 complete / 7 pending;
> backend behavior remains dependency-ordered under `.9.1.3-.9`.

## Current rule-label surface

A rule label starts with a rule name and a colon form. The ordinary form uses one colon:

```text
Item:
```

The entry-style form commonly used for top-level examples uses two colons:

```text
Top::
```

For stream-of-records examples, this book often uses `::` as a no-regex entry or dispatcher wrapper and puts regex-carrying rules behind it with the ordinary single-colon form:

```text
Top::
Item:AND
```

Here `Top::` is the no-regex entry wrapper, and `Item:AND` is the regex-carrying ordered sequence. A no-regex entry or dispatcher can still carry a mode suffix when it composes child parser calls, as shown later in this chapter.

Mechanically, `::` is an **entry marker**: it designates the rule entered first. The Perl reference engine treats that rule as an ordinary rule at runtime (see [.spec Files and Rule Paragraphs](spec-files-and-rule-paragraphs.md#the-top--rule-is-an-ordinary-rule-entered-first)). After entry selection, `::` and `:` have the same rule feature surface: either form can carry regex slots, rule modes, action or blind-call edges, lifecycle blocks, and recursion. Recursion through any rule — including the top rule — must consume input before it recurses; a non-progressing (no-consume) cycle is cut so the parser terminates (see the [formal grammar §5.4](../appendix/formal-grammar.md)).

The current public suffix surface is intentionally small and exact:

- `Rule:` is the historical baseline repeated-alternative rule shape.
- `Rule::` is the entry marker for the rule entered first; its body supports the same modes and regex slots as `Rule:`.
- `Rule:&` is ordered sequence.
- `Rule:AND` is the worded ordered-sequence spelling.
- `Rule:AND+` is open-ended repeated ordered sequence with an implicit lower bound of one.
- `Rule:AND{N}` is exact bounded repeated ordered sequence.
- `Rule:AND{N,M}` is ranged bounded repeated ordered sequence.
- `Rule:AND{N,}` is repeated ordered sequence with a lower bound and no DSL-level upper bound.
- `Rule:AND{,M}` is repeated ordered sequence with an implicit lower bound of zero and an upper bound.
- `Rule:|` is single-choice dispatch.
- `Rule:+` is compact one-or-more repeated choice.
- `Rule:*` is compact zero-or-more repeated choice.
- `Rule:?` is compact zero-or-one repeated choice.
- `Rule:OR` is explicit open-ended repeated choice with an implicit lower bound of one.
- `Rule:OR+` is the explicit shorthand spelling for the same open-ended repeated-choice family.
- `Rule:OR{N}` is exact bounded repeated choice.
- `Rule:OR{N,M}` is ranged bounded repeated choice.
- `Rule:OR{N,}` is repeated choice with a lower bound and no DSL-level upper bound.
- `Rule:OR{,M}` is repeated choice with an implicit lower bound of zero and an upper bound.

Use exact spellings. `AND`, `AND+`, `AND{...}`, `OR`, `OR+`, and `OR{...}` are not fuzzy prefixes. A misspelling such as `ANDX` should fail validation rather than accidentally compiling as `AND`.

## Choice, sequence, and repetition

Most rule-mode confusion disappears if you distinguish three concepts.

Choice asks which alternative fits. With regex/action-edge rules, the alternatives are the rule's own regex slots. With blind-call rules, the alternatives are child parser calls such as `=> Header` or `=> Body`.

Sequence asks whether all configured parts fit in order. A sequence rule is not trying to pick only one part; it expects each required part to participate.

Repetition asks how many complete iterations are accepted. For repeated choice, each iteration chooses one successful alternative. For repeated sequence, each iteration repeats the whole ordered sequence as a group. Bounds such as `{2,4}` count complete iterations, not individual regex tokens in isolation.

That distinction is why `Pair:AND{2}` means "match the whole `Pair` sequence exactly twice", while `Token:OR{2}` means "collect exactly two repeated choice hits."

## Baseline repeated alternative rules

Bare single-colon rules keep LinkedSpec's historical repeated-alternative extraction model:

```text
TokenStream:
 /[A-Za-z_]\w*/ -> TokenStream
 /"(?:[^"\\]|\\.)*"/ -> TokenStream
 /'(?:[^'\\]|\\.)*'/ -> TokenStream
```

For authoring purposes, read bare `Rule:` as the historical member of the same repeated-choice family as:

```text
Rule:OR
Rule:OR+
Rule:OR{1,}
```

That is a conceptual authoring model, not a promise that every low-level emitted handler path is textually identical. The important practical point is that bare `Rule:` is not a single-choice wrapper and is not an implicit ordered sequence. If you want those meanings, say them explicitly.

For a top-level stream parser, wrap a regex-bearing baseline matcher with a no-regex entry rule:

```text
Top::
 -> Token .push
LX { return(copy(Top)) }

Token:
 /[A-Za-z_]\w*/ I.return(entry_text())
 /"[^"]*"/ I.return(entry_text())
 /'[^']*'/ I.return(entry_text())
```

Use bare labels when reading older specs or when the historical repeated-choice style is already clear in local context. Prefer explicit `OR`, `OR+`, or `OR{...}` when teaching, documenting, or writing a new spec whose repetition intent should be obvious from the label.

## Ordered sequence: `:&` and `:AND`

`:&` means ordered sequence:

```text
Pair:&
 /[A-Za-z_]\w*/ -> Pair[0]
 /\s*=\s*/
 /[^,\n]+/ -> Pair[2]
```

The rule succeeds when the parts fit in order. In this sketch the name must appear first, the equals sign second, and the value third.

`:AND` is the worded spelling for the same ordered-sequence contract:

```text
Pair:AND
 /[A-Za-z_]\w*/ -> Pair[0]
 /\s*=\s*/
 /[^,\n]+/ -> Pair[2]
```

Use `:AND` when readability matters more than compactness. It is especially useful in public examples, wrapper rules, and specs where a reader should not have to remember that `&` means ordered sequence.

A helper-style action can still shape the final result in the usual way. Because this
single-colon `Pair:AND` rule owns its regex slots, post-match edge actions read each
slot's match with the `match_*` family:

```text
Pair:AND
 I { pair = {} }
 /([A-Za-z_]\w*)\s*=\s*/ -> Pair[0] {
   set(pair, set_key(pair, "name", match_group(0)));
 }
 /([^,\n]+)/ -> Pair[1] {
   return(set_key(pair, "value", match_group(0)));
 }
```

Embed this matcher behind a no-regex `Top::` wrapper when it is part of a stream parser.
The rule mode controls the ordered matching; the action code controls what value the rule
returns. (The `\s*=\s*` separator is folded into the name slot: a bare edge-less regex slot
in an `AND` rule is a positional anchor that is not separately captured, so attach the
separator to a slot that owns an edge.)

## Single choice: `:|`

`:|` means one successful choice among the configured alternatives:

```text
Atom::|
 => QuotedString
 => IntegerLiteral
 => BareIdentifier
```

This is the clearest spelling for wrapper rules whose job is to try child parsers and keep the first one that succeeds.

The same single-choice shape can be used with regex slots:

```text
Literal:|
 /"(?:[^"\\]|\\.)*"/ -> QuotedString
 /\d+/ -> IntegerLiteral
 /[A-Za-z_]\w*/ -> BareIdentifier
```

Use `:|` when exactly one alternative should provide the rule's result. Do not use `:|` when the rule should keep collecting repeated alternatives; use the repeated-choice family for that.

## Compact repetition: `:+`, `:*`, and `:?`

`:+` is compact one-or-more repeated choice:

```text
NameRun:+
 /[A-Za-z_]\w*/ -> NameRun
```

It requires at least one successful iteration. If the first iteration cannot match, the rule fails.

`:*` is compact zero-or-more repeated choice:

```text
Whitespace:*
 /\s+/ -> Whitespace
 /#.*(?:\n|$)/ -> Whitespace
```

It can succeed with an empty collection. That is useful for ignorable material, but be careful when composing optional repetition inside another repeated rule: a zero-progress success must not become an infinite loop.

`:?` is compact zero-or-one repeated choice:

```text
OptionalComment:?
 /#.*$/ -> OptionalComment
```

It accepts no match or one match, but it does not keep collecting beyond one.

These sigils are concise and useful in established specs. For new explanatory material, the worded `OR` family is often easier to read because the label says "choice" out loud.

## Explicit repeated choice: `OR`, `OR+`, and `OR{...}`

`:OR` is explicit open-ended repeated choice with an implicit lower bound of one:

```text
TokenStream:OR
 /[A-Za-z_]\w*/ -> TokenStream
 /"(?:[^"\\]|\\.)*"/ -> TokenStream
 /'(?:[^'\\]|\\.)*'/ -> TokenStream
```

On each iteration, the rule tries the alternatives and collects one successful hit. It repeats until no configured alternative matches or until a bound stops it.

`:OR+` is the shorthand spelling for the same open-ended repeated-choice family:

```text
TokenStream:OR+
 /[A-Za-z_]\w*/ -> TokenStream
 /"(?:[^"\\]|\\.)*"/ -> TokenStream
 /'(?:[^'\\]|\\.)*'/ -> TokenStream
```

Use `:OR+` when you want the plus sign visible in the label. Use `:OR` when the bare word is clearer. Both have the same "at least one repeated choice hit" authoring contract as `OR{1,}`.

`OR{N}` requires exactly `N` successful choice iterations:

```text
HexByte:OR{2}
 /[0-9A-Fa-f]/ -> HexByte
```

`OR{N,M}` requires at least `N` and at most `M` successful choice iterations:

```text
FlagRun:OR{1,3}
 /--debug/ -> FlagRun
 /--trace/ -> FlagRun
 /--strict/ -> FlagRun
```

`OR{N,}` requires at least `N` successful choice iterations and then remains open-ended:

```text
TwoOrMoreNames:OR{2,}
 /[A-Za-z_]\w*/ -> TwoOrMoreNames
```

`OR{,M}` allows zero through `M` successful choice iterations:

```text
OptionalPrefixes:OR{,2}
 /\+/ -> OptionalPrefixes
 /-/ -> OptionalPrefixes
```

The shorthand is useful when the exact count matters:

- `OR{2}` means exactly two iterations.
- `OR{2,4}` means two, three, or four iterations.
- `OR{2,}` means two or more iterations.
- `OR{,4}` means zero, one, two, three, or four iterations.

Invalid bounds such as `OR{,}` or descending ranges such as `OR{3,2}` should be rejected. Write the count contract explicitly enough that a reader can tell what empty input, short input, and over-long input should do.

## Explicit repeated sequence: `AND+` and `AND{...}`

`:AND+` is open-ended repeated ordered sequence with an implicit lower bound of one:

```text
AssignmentStream:AND+
 /[A-Za-z_]\w*/ -> AssignmentStream[0]
 /\s*=\s*/
 /[^,\n]+/ -> AssignmentStream[2]
```

The whole ordered sequence repeats. In this example, one iteration is `name`, then `=`, then `value`. The next iteration starts over at `name`.

`AND{N}` requires exactly `N` complete sequence iterations:

```text
TwoPairs:AND{2}
 /[A-Za-z_]\w*/ -> TwoPairs[0]
 /\s*=\s*/
 /[^,\n]+/ -> TwoPairs[2]
```

`AND{N,M}` requires at least `N` and at most `M` complete sequence iterations:

```text
TwoToFourPairs:AND{2,4}
 /[A-Za-z_]\w*/ -> TwoToFourPairs[0]
 /\s*=\s*/
 /[^,\n]+/ -> TwoToFourPairs[2]
```

`AND{N,}` requires at least `N` complete sequence iterations and then remains open-ended:

```text
TwoOrMorePairs:AND{2,}
 /[A-Za-z_]\w*/ -> TwoOrMorePairs[0]
 /\s*=\s*/
 /[^,\n]+/ -> TwoOrMorePairs[2]
```

`AND{,M}` allows zero through `M` complete sequence iterations:

```text
UpToTwoPairs:AND{,2}
 /[A-Za-z_]\w*/ -> UpToTwoPairs[0]
 /\s*=\s*/
 /[^,\n]+/ -> UpToTwoPairs[2]
```

Use the repeated `AND` family when a whole group needs to recur. Do not model a repeated ordered group as a repeated choice unless each iteration should pick only one alternative.

## Blind calls follow the rule label

A blind call directly invokes another rule as a parser step:

```text
=> Header
```

That is different from an action edge:

```text
-> Header
```

The short version is:

- `-> Header` is regex-slot oriented: the current rule owns the regex slot, then the edge targets a rule/action path.
- `=> Header` is parser-step oriented: the parent directly calls the child rule and works with the child result.

Blind calls do not secretly turn a rule into a sequence. The rule label still decides the composition model.

For ordered orchestration, say `AND` or `&`:

```text
Record::AND
 => Header
 => Body
 => Trailer
```

That reads as "call `Header`, then `Body`, then `Trailer`."

For repeated ordered orchestration, use the repeated `AND` family:

```text
ChunkStream::AND+
 => ChunkHeader
 => ChunkBody
```

or with bounds:

```text
ChunkStream::AND{2,4}
 => ChunkHeader
 => ChunkBody
```

Each iteration repeats the whole child-call sequence.

For wrapper choice, say `:|`:

```text
Atom::|
 => QuotedString
 => IntegerLiteral
 => BareIdentifier
```

That reads as "try these child parsers as alternatives."

For repeated-choice blind-call behavior, say `OR`, `OR+`, `:+`, or `OR{...}`:

```text
ChunkStream::OR
 => HeaderChunk
 => BodyChunk
 => TrailerChunk
```

That reads as "on each iteration, try the child parsers as alternatives, collect the successful child result, then repeat."

The important rule is: `=> Child` tells LinkedSpec to call a child parser, but the label tells LinkedSpec whether those calls are sequenced, chosen, or repeated.

For a deeper walkthrough of `=>`, post-call processing, edge-family selection, and parser-orchestration examples, read [Blind Calls and Parser Orchestration](blind-calls-and-parser-orchestration.md).

Do not mix action edges and blind calls in the same rule body:

```text
BadRule:
 /.../ -> ChildA
 => ChildB
```

Keep one rule body on one execution model. Use `->` when the parent owns regex slots. Use `=>` when the parent is a composition shell around child parsers.

### Forward-moving, non-backtracking model

The LinkedSpec parser engine is forward-moving and non-backtracking. When a regex rule tries to match at the current cursor, one of two things happens:

- The regex succeeds and the cursor advances past the matched characters.
- The regex fails and the cursor stays where it was.

The engine does not maintain a search tree. It does not remember which alternatives were tried, does not unwind partial rule matches to try a different branch, and does not implement any form of systemic backtracking. A rule match either advances the cursor or leaves it unchanged on failure.

This means the parser will not automatically reorder alternatives to find a successful match, will not retry a different decomposition of the input, and will not explore multiple parse paths. The only way the cursor moves backward is through explicit cursor controls such as `restore_cursor()`, `rewind_match_start()`, or `rewind_entry_start()` — not search-tree operations.

This design is intentional. LinkedSpec is built for extraction and recognition, not for exhaustive ambiguity resolution. The rule modes (`AND`, `OR`, `:|`, etc.) control composition within this forward-moving framework; the parse modes (`seek`, `consume`) control cursor discipline within this framework. Neither implies systemic backtracking.

For more detail on cursor-stack helpers, anchor rewinds, and their interaction with `parse_mode`, see the [Source Boundary Helper Reference](../dsl/source-boundary-helper-reference.md#explicit-cursor-controls).

## Current implemented parse modes

Parse modes control cursor discipline at runtime. They do not change rule composition.

The public modes are:

- `seek`
- `consume`

If `parse_mode` is omitted, LinkedSpec uses `seek`.

### `seek`

`seek` preserves LinkedSpec's progressive extraction behavior: the parser can seek forward to a later anchor.

This is useful when a grammar is being used to extract structure from a larger input rather than to require the very next input byte to match.

Example:

```text
Top::
 -> Word .push
LX { return(copy(Top)) }

Word:
 /foo/ I.return(entry_text())
```

With `seek`, this input can still match:

```text
junk foo
```

The parser is allowed to move forward until it finds `foo`; this wrapper returns `["foo"]`.

### `consume`

`consume` is stricter. It requires matching to proceed contiguously from the current input position.

The same spec:

```text
Top::
 -> Word .push
LX { return(copy(Top)) }

Word:
 /foo/ I.return(entry_text())
```

rejects this input under `consume`:

```text
junk foo
```

because the current cursor is at `j`, not at `f`; this wrapper returns no matches (`[]`).

This input is acceptable under both modes:

```text
foo
```

For that input, the wrapper returns `["foo"]` under either mode.

Use `consume` when the spec should behave more like a conventional parser step and reject leading junk before the next anchor. Use `seek` when the spec should act more like an extraction grammar over a larger body of text.

## Current public option shape

`parse_mode` is a backend-neutral compile option: both inline parser construction and file-oriented parser construction accept the same value. In the Perl reference backend:

```perl
my $parser = LinkedSpec::Get(
  \$spec_text,
  parse_mode => 'consume',
);

my $parser = LinkedSpec::get_parser(
  'Lispish',
  parse_mode => 'consume',
);
```

Descriptor introspection reports the selected mode in descriptor metadata (Perl reference backend shown):

```perl
my $descriptor = LinkedSpec::Get(
  \$spec_text,
  return_descriptor => 1,
  parse_mode => 'consume',
);

my $mode = $descriptor->{meta}{parse_mode}; # consume
```

## Choosing a mode

Use `:AND` or `:&` when the rule's body is an ordered list of required parts.

Use `:|` when the rule is a one-of-many wrapper around alternatives.

Use `:OR`, `:OR+`, or `:+` when the rule should collect one or more repeated alternatives.

Use `:*`, `:?`, `OR{,M}`, or `AND{,M}` when zero successful iterations should be acceptable. Review those rules carefully inside repeated parents because empty success is semantically real.

Use `AND+` or `AND{...}` when the whole ordered group needs to repeat.

Use `OR{...}` when the repeated-choice count matters.

Use `AND{...}` when the repeated-sequence count matters.

Use `consume` when contiguity matters. Use `seek` when extraction from a larger input is the goal.

Rule modes, action/lifecycle placement, and parse modes are deliberately separate. If a rule does not behave as expected, debug those axes separately: first the label, then the body edge family (`->` versus `=>`), then the parse-mode option.

## Rule-local rollout

ADR `0044` replaces the current global option during `.9.1.3-.9` rollout. The
target is already executable, before backend changes, in
`capability_conformance/rule_local_cursor_contract.json`; run
`python3 tools/check_rule_local_cursor_contract.py` from the repository root.
The authored family becomes the only cursor authority:

| Rule family | Derived cursor policy |
| --- | --- |
| bare/default, `|`, `+`, `*`, `?`, `OR`, `OR+`, `OR{...}` | `seek` |
| `&`, `AND`, `AND+`, `AND{...}` | `consume` |

`::` remains only the marker for the rule entered first. A parent starts a
child at its current cursor, but the child then applies its own family policy.
Edge kind never overrides either family.

The four low-level combinations still have structural expressions. An ordered
landmark grammar is an AND parent over seek-owning OR/default children. An
anchored choice is an OR parent over consume-owning one-anchor AND children.
This keeps each reusable rule stable instead of reviving a caller or rule-local
escape hatch.

The Perl reference now implements the decision's bare-edge normalization. A complete bare paragraph
member such as `Child`, `Child { ... }`, or `Child.return(...)` normalizes to:

- `=> Child...` in an AND-family rule;
- `-> Child...` in an OR/default-family rule.

Explicit `->` remains legal in AND rules and explicit `=>` remains legal in
OR/default rules. After bare normalization, one rule still cannot mix action
and blind ownership. An indexed bare target in AND is invalid because blind
calls cannot index; use explicit `-> Child[N]`. A grouped bare target is valid
only in OR/default and still requires a shared block. Lifecycle markers `I`,
`LS`, `LE`, `LX`, `E`, `EX`, and `IT` retain lexical priority, so an edge to a
same-named rule must be explicit.

For example, this AND parent resolves both bare child lines as blind calls. It
consumes at the parent level, while each default child still seeks from the
cursor at which it was entered:

```text
Top::AND
 Header
 Body.return(child_result)

Header:
 /BEGIN/

Body:
 /payload=(\w+)/
```

This OR parent resolves a bare grouped line as an action edge; the shared block
is still required:

```text
Top::OR
 Header | Body { return(child_result) }
```

Cross-family exceptions remain explicit. An AND rule that intentionally owns
action edges writes every edge with `->`; an OR rule that intentionally makes
blind calls writes every edge with `=>`. Mixing a bare AND child (resolved
blind) with `-> Other` fails as `mixed_edge_ownership`. `Child[0]` in AND fails
as `bare_edge_index_requires_action`; spell `-> Child[0]` when indexed action
dispatch is intended.

Later Perl rollout slices make the derived policy drive live execution and remove
`parse_mode` / `--parse-mode` with a targeted
diagnostic rather than accepted and ignored. Descriptors replace root
`meta.parse_mode` with `meta.cursor_contract` and per-rule `meta.cursor_policy`.
Generated source moves to v2 and derives policy from its handler-family plan;
version-1 artifacts must be regenerated. Until those later implementation leaves
land, use the current option behavior documented above. Bare-edge source and
per-rule `family`, `cursor_policy`, and `edge_ownership` metadata in the Perl
reference are current; live cursor spending and outward root metadata are not yet migrated. The
neutral checker currently reports 36 family spellings, 18 edge cases, eight
parent/child cases, 91 migration files, 1 complete / 7 pending, and 27 rejected
drift mutations.
