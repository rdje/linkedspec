# Worked `.spec` Walkthrough

This chapter walks through one small LinkedSpec parser end to end.

The goal is deliberately modest: parse one key/value pair such as:

```text
answer = 42
```

and return a structured payload:

```text
{
  kind  => "pair",
  name  => "answer",
  value => "42",
}
```

The point is not that this grammar is impressive. The point is that it shows the basic LinkedSpec loop in one place:

- write a rule paragraph,
- choose a rule mode,
- attach an action,
- use helper DSL instead of raw host-language payload code,
- compile the spec with a backend and call the returned parser,
- understand how `seek` and `consume` change matching behavior.

The `.spec` file and everything it expresses are backend-neutral: the same source compiles and runs identically on any LinkedSpec backend. The runnable snippets below use the **Perl reference backend** (`LinkedSpec::Get(...)`, `$parser->(\$input)`); another backend would expose an equivalent compile-and-run surface in its own language.

## The full spec

Here is the complete inline `.spec`:

```text
Pair::AND
 /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/ -> Pair[0] {
   return(hash("kind", "pair", "name", match_group(0), "value", trim(match_group(1))));
 }
```

This rule has one regex slot and one action edge.

The regex slot is:

```text
/([A-Za-z_]\w*)\s*=\s*([^,\n]+)/
```

It captures two groups:

- `([A-Za-z_]\w*)` captures the left-hand name.
- `([^,\n]+)` captures the right-hand value text.

The action edge is:

```text
-> Pair[0] { ... }
```

`Pair[0]` says that the action is attached to regex slot `0`, the first and only local regex slot in this rule.

The action body is:

```text
return(hash("kind", "pair", "name", match_group(0), "value", trim(match_group(1))));
```

Read it as:

- `match_group(0)` returns the first capture group of the current local match, here `answer`.
- `match_group(1)` returns the second capture group of the current local match, here the right-hand value text.
- `trim(...)` normalizes incidental leading/trailing whitespace from that captured value text.
- `hash(...)` builds one structured hash payload.
- `return(...)` returns that payload from the rule.

The helper group indexes are zero-based. The first regex capture group is `match_group(0)`, the second is `match_group(1)`, and so on.

## Why `Pair::AND`

The rule starts with:

```text
Pair::AND
```

`Pair` is the rule name. The double-colon form is the entry-style rule spelling used here because this tiny spec has only one public entry rule.

`AND` says this is an ordered-sequence rule. This example has only one regex slot, so `AND` is not doing much yet, but it is still a good public-doc spelling because it says the rule is not a repeated choice stream.

If the rule later grows into several ordered slots, the label still reads correctly:

```text
Pair::AND
 /[A-Za-z_]\w*/
 /\s*=\s*/
 /[^,\n]+/
```

For this first walkthrough, the single-regex form keeps the action attached to one current local match, which makes `match_group(...)` behavior easy to see.

## Running it inline

A backend compiles in-memory `.spec` text and returns a runnable parser. In the Perl reference backend, `LinkedSpec::Get(...)` does this and returns a parser coderef:

```perl
use LinkedSpec;

my $spec = <<'SPEC';
Pair::AND
 /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/ -> Pair[0] {
   return(hash("kind", "pair", "name", match_group(0), "value", trim(match_group(1))));
 }
SPEC

my $parser = LinkedSpec::Get(
  \$spec,
  parse_mode => 'consume',
);

my $input = 'answer = 42';
my $ast = $parser->(\$input);
```

The returned `$ast` is a hash-like payload equivalent to:

```text
{
  kind  => "pair",
  name  => "answer",
  value => "42",
}
```

Do not depend on hash key order when printing this payload (for example with a debug dumper such as Perl's `Data::Dumper`); the semantic payload is the key/value content, not its serialization order.

## `consume` versus `seek`

The parser construction above used:

```perl
parse_mode => 'consume'
```

That means the regex must match at the current cursor position.

This input succeeds:

```text
answer = 42
```

This input fails under `consume`:

```text
junk answer = 42
```

because the current cursor starts at `j`, not at the `answer = 42` pair.

If you compile the same spec with `seek`, LinkedSpec can skip forward to the later anchor:

```perl
my $parser = LinkedSpec::Get(
  \$spec,
  parse_mode => 'seek',
);
```

Under `seek`, this input can match:

```text
junk answer = 42
```

The returned payload is still the pair:

```text
{
  kind  => "pair",
  name  => "answer",
  value => "42",
}
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
exists $descriptor->{spec}{Pair};
```

The descriptor is covered in more detail in [Descriptor Introspection](../public-api/descriptor-introspection.md). The key point here is that the same inline spec can either produce a runnable parser or a structured descriptor, depending on the option you pass.

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
$ctx{top_rule}; # Pair
```

On failure, the same context can carry structured `last_error` data with owner/stage attribution. That is preferable to scraping raw error strings.

Use this option when embedding LinkedSpec in a larger application or test harness where failures need to be explained to a user.

## Evolving the spec

The one-rule version is intentionally compact. As the grammar grows, split responsibilities rather than making one action too clever.

For example, if you want a parent rule to parse several child concepts in order, use blind calls:

```text
Assignment::AND
 => Name
 => Equals
 => Value
```

If the parent owns local regex slots and needs to reshape child data itself, use explicit `call(...)` dataflow inside an action edge:

```text
Assignment::AND
 I { declare(scalar, retv); }
 /assignment\s+/ -> Assignment[0] {
   assign(scalar(retv), call(Name));
   return(hash("kind", "assignment", "name", scalar(retv)));
 }
```

If the rule needs repeated alternatives, switch to the `OR` family:

```text
PairStream::OR
 /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/ -> PairStream[0] {
   return(hash("kind", "pair", "name", match_group(0), "value", trim(match_group(1))));
 }
```

The important habit is to change the rule label when the composition model changes. Do not leave a reader guessing whether the rule is a sequence, a choice, or a repeated extraction stream.

## What this walkthrough teaches

This small example demonstrates the default authoring loop:

- Use a rule label that names the composition model.
- Use regex capture groups when the payload is already local to one match.
- Use `match_group(...)` for current local-match captures.
- Use helper expressions such as `trim(...)`, `hash(...)`, and `return(...)` rather than raw host-language payload construction.
- Choose `consume` for strict parser behavior.
- Choose `seek` for extraction behavior.
- Use `return_descriptor => 1` when tooling needs compiler output instead of a parser coderef.
- Use `runtime_ctx_ref` when callers need structured diagnostics and compile/run identity.

From here, the next chapters to read are:

- [Rule Modes and Parse Modes](rule-modes-and-parse-modes.md) for the full rule-label and cursor-discipline matrix.
- [Blind Calls and Parser Orchestration](blind-calls-and-parser-orchestration.md) for parent/child parser composition.
- [Action Model and Helper Surface](../dsl/action-model-and-helper-surface.md) for the broader helper DSL.
