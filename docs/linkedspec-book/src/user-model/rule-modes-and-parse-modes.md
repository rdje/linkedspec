# Rule Modes and Parse Modes

LinkedSpec has more than one axis of behavior.

## Rule modes

Rule modes describe how a rule composes its internal structure.

Examples include the `AND` and `OR` families. These are about rule composition.

In plain terms:

- `AND`-style rules describe rule bodies where multiple parts are expected to participate.
- `OR`-style rules describe rule bodies where alternatives can participate.

The exact suffixes are part of the `.spec` rule-start syntax. Current public docs should treat the supported worded forms as exact spellings, not fuzzy prefixes:

- `AND`
- `AND+`
- `AND{...}`
- `OR`
- `OR+`
- `OR{...}`

That exactness matters because permissive prefix matching creates confusing grammars. A misspelling should be a useful validation error, not a surprising partial success.

## Parse modes

Parse modes describe cursor discipline at runtime.

The current public model is:

- `seek`
- `consume`

These are about how matching progresses through input, not about how rule alternatives are composed.

### `seek`

`seek` is the default. It preserves LinkedSpec’s progressive extraction behavior: the parser can seek forward to a later anchor.

This is useful when the grammar is being used to extract structure from a larger input rather than to require the very next input byte to match.

### `consume`

`consume` is stricter. It requires matching to proceed contiguously from the current input position.

This is useful when a rule should behave more like a conventional parser step and reject leading junk before the next anchor.

## Example

Consider this tiny spec:

```text
Top::
 /foo/ { return_a(Top) }
```

With `seek`, an input like this can still find the anchor:

```text
junk foo
```

With `consume`, the same input is rejected because matching must start at the current cursor position rather than skipping forward to `foo`.

An input like this is acceptable under both modes:

```text
foo
```

## Why the distinction matters

Rule composition and cursor discipline are separate concerns.

That separation is important because it keeps the runtime model explainable:

- `AND`/`OR` tells you how the rule behaves structurally
- `seek`/`consume` tells you how the parser moves through input

This distinction is part of LinkedSpec’s effort to make behavior explicit rather than accidental.

## Public option shape

Inline and file-oriented parser construction both use the same public parse-mode option:

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

If `parse_mode` is omitted, LinkedSpec uses `seek`.

If you request descriptor introspection, the selected mode is visible in descriptor metadata:

```perl
my $descr = LinkedSpec::Get(
  \$spec_text,
  return_descriptor => 1,
  parse_mode => 'consume',
);

my $mode = $descr->{meta}{parse_mode}; # consume
```
