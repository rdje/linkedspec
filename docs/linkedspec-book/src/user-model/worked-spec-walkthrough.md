# Worked `.spec` Walkthrough

This chapter walks through one small LinkedSpec parser end to end.

The goal is deliberately modest: parse one key/value pair such as:

```text
answer = 42
```

and return a structured payload for it. A LinkedSpec parser collects the payloads it
produces into a list, so for the single pair above the result is a one-element list:

```text
[
  { kind => "pair", name => "answer", value => "42" },
]
```

The point is not that this grammar is impressive. The point is that it shows the basic LinkedSpec loop in one place:

- write the two rule paragraphs this idiomatic shape uses (an entry rule and a matcher rule),
- choose a rule mode,
- attach an action with a lifecycle block,
- use helper DSL instead of raw host-language payload code,
- compile the spec with a backend and call the returned parser,
- understand how `seek` and `consume` change matching behavior.

The `.spec` file and everything it expresses are backend-neutral: the same source compiles and runs identically on any LinkedSpec backend. The runnable snippets below use the **Perl reference backend** (`LinkedSpec::Get(...)`, `$parser->(\$input)`); another backend would expose an equivalent compile-and-run surface in its own language.

## The full spec

Here is the complete inline `.spec`. It uses the recommended two-rule idiom — a top
**entry rule** that carries no regex, plus a normal **matcher rule** that does. (This is
the clean shape for stream-of-records parsing, not a hard minimum: `::` is just an entry
marker, and a top rule is an ordinary rule that *may* carry a regex or recurse — see
[.spec Files and Rule Paragraphs](spec-files-and-rule-paragraphs.md).)

```text
Top::
 -> Pair .push

LX { return(copy(array(Top))) }

Pair:
 /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/ I {
   return(hash("kind", "pair", "name", entry_group(0), "value", trim(entry_group(1))));
 }
```

### The entry rule

```text
Top::
 -> Pair .push

LX { return(copy(array(Top))) }
```

`Top::` is the entry rule. The double-colon `::` label marks the single top rule of the spec —
the rule a backend starts from. It carries **no regex of its own**. Instead it runs a dispatch
loop: it repeatedly hands off to the `Pair` matcher (`-> Pair`) and `.push`es each result onto
its own accumulator. When the input is exhausted, the `LX { ... }` lifecycle block returns a
snapshot of that accumulator with `copy(array(Top))` — that snapshot (a list) is the parser's
result. (The accumulator and output-shape model is covered in
[Runtime Semantics](../appendix/runtime-semantics.md).)

### The matcher rule

```text
Pair:
 /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/ I {
   return(hash("kind", "pair", "name", entry_group(0), "value", trim(entry_group(1))));
 }
```

`Pair:` is a normal rule (single colon). It carries the regex, and its action builds one payload
per match. It has one regex slot and one lifecycle action block.

The regex slot is:

```text
/([A-Za-z_]\w*)\s*=\s*([^,\n]+)/
```

It captures two groups:

- `([A-Za-z_]\w*)` captures the left-hand name.
- `([^,\n]+)` captures the right-hand value text.

The action block is:

```text
I {
  return(hash("kind", "pair", "name", entry_group(0), "value", trim(entry_group(1))));
}
```

`I { ... }` is a lifecycle action block; here it runs the payload-building helper code for the
match. Read the body as:

- `entry_group(0)` returns the first capture group of the match that **entered** this rule, here `answer`.
- `entry_group(1)` returns the second capture group of that entering match, here the right-hand value text.
- `trim(...)` normalizes incidental leading/trailing whitespace from that captured value text.
- `hash(...)` builds one structured hash payload.
- `return(...)` returns that payload from the rule, where `.push` collects it onto the entry rule's accumulator.

The helper group indexes are zero-based and captures-only. The first regex capture group is
`entry_group(0)`, the second is `entry_group(1)`, and so on (see
[Regex in `.spec`](regex-in-spec.md) for the indexing contract).

A matcher rule reached by dispatch reads the **entering** match with the `entry_*` family. The
`match_*` family reads the rule's *own local* match, which is not set in this single-slot
matcher — so `match_group(0)` here would be empty. See
[Capture, Marks, and Source Locations](../dsl/capture-marks-and-source-locations.md) for when
`entry_*` and `match_*` diverge.

## Why two rules

The top `::` entry rule and the normal `:` matcher rule play different roles:

- The **entry rule** (`Top::`) names the whole parser and owns the result. It carries no regex —
  it loops, dispatches to matchers, collects their payloads, and returns the collection. There is
  exactly one entry rule per spec.
- The **matcher rule** (`Pair:`) carries the regex and turns one match into one payload.

In this idiom the regex lives on the normal `:` matcher rule and the `::` entry rule
just dispatches and collects. That is a style choice for clarity, not a constraint — a
`::` rule is an ordinary rule that *can* carry a regex, take a mode, or recurse. See
[.spec Files and Rule Paragraphs](spec-files-and-rule-paragraphs.md) for the paragraph
model and the entry-rule-is-ordinary explanation.

`Pair:` uses the default rule mode: one regex slot, one match. If the matcher later grows into
several ordered slots, give it the `AND` mode so the label still reads correctly:

```text
Pair:AND
 /[A-Za-z_]\w*/
 /\s*=\s*/
 /[^,\n]+/
```

The full rule-label and cursor-discipline matrix is in
[Rule Modes and Parse Modes](rule-modes-and-parse-modes.md).

## Running it inline

A backend compiles in-memory `.spec` text and returns a runnable parser. In the Perl reference backend, `LinkedSpec::Get(...)` does this and returns a parser coderef:

```perl
use LinkedSpec;

my $spec = <<'SPEC';
Top::
 -> Pair .push

LX { return(copy(array(Top))) }

Pair:
 /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/ I {
   return(hash("kind", "pair", "name", entry_group(0), "value", trim(entry_group(1))));
 }
SPEC

my $parser = LinkedSpec::Get(
  \$spec,
  parse_mode => 'consume',
);

my $input = 'answer = 42';
my $ast = $parser->(\$input);
```

The returned `$ast` is a list with one pair payload, equivalent to:

```text
[
  { kind => "pair", name => "answer", value => "42" },
]
```

The entry rule collects one payload per matched pair, so an input that exposes several
pairs to the cursor produces a longer list. For `'a = 1, b = 2'` the two-element result
is:

```text
[
  { kind => "pair", name => "a", value => "1" },
  { kind => "pair", name => "b", value => "2" },
]
```

That two-pair result is what the `seek` parser (built below) returns: after the first
pair the cursor sits on the `, ` separator, and `seek` skips forward to the next `b = 2`
anchor. The **strict `consume` parser built above** instead returns only the first pair
`[{ kind => "pair", name => "a", value => "1" }]`, because `consume` will not skip the
separator — the cursor stops at `,` and no further pair matches contiguously. This is the
`consume` versus `seek` distinction in miniature; the next section makes it explicit.

Do not depend on hash key order when printing these payloads (for example with a debug dumper such as Perl's `Data::Dumper`); the semantic payload is the key/value content of each hash, not its serialization order.

## `consume` versus `seek`

The parser construction above used:

```perl
parse_mode => 'consume'
```

That means the regex must match at the current cursor position.

This input matches the pair and returns the one-element list:

```text
answer = 42
```

This input extracts nothing under `consume`:

```text
junk answer = 42
```

The current cursor starts at `j`, not at the `answer = 42` pair, so no match occurs at the
cursor and the parser returns an empty list `[]`.

If you compile the same spec with `seek`, LinkedSpec can skip forward to the later anchor:

```perl
my $parser = LinkedSpec::Get(
  \$spec,
  parse_mode => 'seek',
);
```

Under `seek`, this input matches:

```text
junk answer = 42
```

The returned payload is still the one-element list of the pair:

```text
[
  { kind => "pair", name => "answer", value => "42" },
]
```

Use `consume` when the spec is acting as a strict parser. Use `seek` when the spec is acting as an extractor over a larger text body.

## Inspecting the descriptor instead of building a parser

Sometimes tooling needs to inspect the compiled spec rather than run it immediately.

Use `return_descriptor => 1`:

```perl
my $descriptor = LinkedSpec::Get(
  \$spec,
  return_descriptor => 1,
  parse_mode => 'consume',
);
```

The result is a descriptor hash, not a parser coderef.

For this walkthrough, the useful checks are:

```perl
ref($descriptor) eq 'HASH';
$descriptor->{meta}{parse_mode} eq 'consume';
exists $descriptor->{spec}{Top};   # the entry rule
exists $descriptor->{spec}{Pair};  # the matcher rule
```

The descriptor lists every rule in the spec — both the `Top` entry rule and the `Pair` matcher.
It is covered in more detail in [Descriptor Introspection](../public-api/descriptor-introspection.md). The key point here is that the same inline spec can either produce a runnable parser or a structured descriptor, depending on the option you pass.

## Capturing runtime context

For diagnostics and tooling, pass `runtime_ctx_ref`:

```perl
my %ctx;

my $parser = LinkedSpec::Get(
  \$spec,
  parse_mode => 'consume',
  runtime_ctx_ref => \%ctx,
);
```

On a successful compile, the context can record useful run identity such as the selected top rule:

```perl
$ctx{top_rule}; # Top
```

The top rule is the spec's entry rule (`Top`), not the matcher. On failure, the same context can carry structured `last_error` data with owner/stage attribution. That is preferable to scraping raw error strings.

Use this option when embedding LinkedSpec in a larger application or test harness where failures need to be explained to a user.

## Evolving the spec

The two-rule version is intentionally compact. As the grammar grows, split responsibilities across more rules rather than making one action too clever.

For example, if you want a parent rule to parse several child concepts in order, use blind calls (a parent rule carries no regex — it only dispatches):

```text
Assignment::AND
 => Name
 => Equals
 => Value
```

If a matcher owns a local regex slot and needs to reshape child data itself, use explicit `call(...)` dataflow inside its action block — call a sibling rule and use its result directly (sketch — it needs a sibling `Name` rule to run):

```text
Assignment:
 /assignment\s+/ I {
   return(hash("kind", "assignment", "name", call(Name)));
 }
```

If a single pair can be written several ways, give the matcher the `OR` mode with one regex slot per alternative, and attach the action the same way as before:

```text
Pair:OR
 /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/
 /([A-Za-z_]\w*)\s*:\s*([^,\n]+)/
```

The important habit is to change the rule label when the composition model changes. Do not leave a reader guessing whether the rule is a sequence, a choice, or a repeated extraction stream.

## What this walkthrough teaches

This small example demonstrates the default authoring loop:

- Write a top `::` entry rule (no regex) plus one or more normal `:` matcher rules that carry the regex.
- Use a rule label that names the composition model.
- Use regex capture groups when the payload is already local to one match.
- Use `entry_group(...)` to read the capture groups of the match that entered a dispatched rule.
- Use helper expressions such as `trim(...)`, `hash(...)`, and `return(...)` rather than raw host-language payload construction.
- Let the entry rule collect each returned payload (`-> Pair .push`) and return the snapshot (`LX { return(copy(array(Top))) }`).
- Choose `consume` for strict parser behavior.
- Choose `seek` for extraction behavior.
- Use `return_descriptor => 1` when tooling needs compiler output instead of a parser coderef.
- Use `runtime_ctx_ref` when callers need structured diagnostics and compile/run identity.

From here, the next chapters to read are:

- [Rule Modes and Parse Modes](rule-modes-and-parse-modes.md) for the full rule-label and cursor-discipline matrix.
- [Blind Calls and Parser Orchestration](blind-calls-and-parser-orchestration.md) for parent/child parser composition.
- [Action Model and Helper Surface](../dsl/action-model-and-helper-surface.md) for the broader helper DSL.
