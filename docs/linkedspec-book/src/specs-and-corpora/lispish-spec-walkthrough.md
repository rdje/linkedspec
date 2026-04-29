# `Lispish.spec` Walkthrough

`specs/Lispish.spec` is the best first shipped-spec walkthrough.

It is compact, but it is not a toy. It demonstrates:

- file-oriented parser loading through `LinkedSpec::get_parser('Lispish')`,
- a real top-level rule named `Lispish`,
- recursive parenthesized parsing,
- child-rule calls from action edges,
- helper-style scalar/array/hash construction,
- comments and whitespace handling,
- string/bracket/brace token readers,
- descriptor metadata that proves the helper-flow migration is no longer blocked by raw-Perl fallback.

Read this chapter after [Worked `.spec` Walkthrough](../user-model/worked-spec-walkthrough.md) if you want to see the same concepts in a shipped parser.

## How to run it

Use the named parser path:

```perl
use LinkedSpec;

my $parser = LinkedSpec::get_parser('Lispish');

my $input = '(a (b c) d)';
my $ast = $parser->(\$input);
```

The parser returns an array-tree:

```text
[
  'a',
  [
    [
      'b',
      ['c'],
    ],
    'd',
  ],
]
```

That shape is regression-locked in `t/phase0_regression.t` as the `lispish_ast_smoke` baseline.

## Output shape

Lispish forms are parenthesized arrays.

The first element is the head. The second element is the tail when one exists:

```text
(a b c)
```

parses as:

```text
[
  'a',
  [
    'b',
    'c',
  ],
]
```

A one-item form preserves the head and uses `undef` for the absent tail:

```text
(a)
```

parses as:

```text
[
  'a',
  undef,
]
```

Nested forms become nested arrays:

```text
((a))
```

parses as:

```text
[
  [
    'a',
    undef,
  ],
  undef,
]
```

The empty form:

```text
()
```

parses as:

```text
[
  undef,
]
```

That shape is historical but important: many older consumers use `perl/Lispish.pm` helpers to walk and transform these array trees.

## Rule inventory

The compiled descriptor currently exposes these rules:

```text
Lispish
comments
curlyb
dquotes
others
parenthesis
sbrackets
spaces
squotes
```

The main roles are:

| Rule | Role |
| --- | --- |
| `Lispish` | top-level parser entry rule; dispatches into `parenthesis` and keeps a syntax-error path for unmatched close-paren style failures. |
| `parenthesis` | recursive form parser; owns head/tail accumulation and nested child calls. |
| `dquotes` | double-quoted string token reader. |
| `squotes` | single-quoted string token reader. |
| `sbrackets` | square-bracket token reader. |
| `curlyb` | brace-delimited recursive token reader. |
| `spaces` | whitespace reader used as a separator/flush point. |
| `others` | ordinary non-delimiter atom reader. |
| `comments` | semicolon-to-newline comment reader. |

## The top-level rule

The file begins:

```text
Lispish::
 -> parenthesis     {return(call(parenthesis))}
 -> parenthesis[1]  {say("(Lispish) -E- Syntax Error"); exit_now(1)}
 -> comments
```

The important ideas are:

- `Lispish::` is the public entry-style rule.
- The normal path calls `parenthesis` and returns that child parser's result through `return(call(...))`.
- The `parenthesis[1]` edge is an explicit syntax-error path.
- Comments can appear at the top level.

This is compact helper authoring style, but it now stays on the modern helper surface: the normal branch uses helper-form child return flow, and the fatal syntax-error branch uses `exit_now(1)` instead of host `exit` syntax.

## The recursive `parenthesis` rule

The core rule starts like this:

```text
parenthesis: /\(/ /\)/
I {declare(array, word, tail); declare(scalar, retv, head, has_head)}
```

The opening and closing regexes are the parenthesis anchors. The `I { ... }` lifecycle block declares the working state for one invocation:

- `word` collects adjacent atom fragments until the rule sees a separator or nested structure.
- `tail` collects all elements after the head.
- `retv` stores child parser results.
- `head` stores the first completed item.
- `has_head` records whether the rule has already assigned the head.

The rule then uses action edges to process each possible thing inside the parentheses:

```text
-> parenthesis
-> spaces
-> dquotes
-> sbrackets
-> curlyb
-> others
-> comments
-> parenthesis[1]
```

The recursive edge:

```text
-> parenthesis
```

calls the same rule again when a nested form appears.

The atom readers:

```text
-> dquotes
-> sbrackets
-> curlyb
-> others
```

call child token rules, read their `{content}` field, and push that content into `word`.

The spaces edge flushes accumulated word fragments into either `head` or `tail`.

The closing parenthesis edge finalizes the current form:

```text
-> parenthesis[1] {
  ...
  if(s(has_head));
   if(is_nonempty(a(tail)));
    return(a(s(head), array_copy(a(tail))));
   else();
    return(a(s(head), undef));
   endif();
  else();
   return(a(undef));
  endif()
}
```

The short aliases matter:

- `s(head)` means scalar variable `head`.
- `a(tail)` means array variable `tail`.
- `array_copy(a(tail))` snapshots the tail elements into the returned array shape.
- `return(a(...))` returns an array payload.

This is a good real example of why helper DSL matters. The rule contains recursion, accumulation, conditional flow, child calls, array pushes, and structured returns without falling back to ad hoc raw Perl for the core dataflow.

## Token readers

The token readers are intentionally small.

Double-quoted strings:

```text
dquotes: /"(.*?)(?<!\\)"/     I.return(h("type", "DQUOTES", "content", entry_group(0)))
```

Single-quoted strings:

```text
squotes: /'(.*?)(?<!\\)'/     I.return(h("type", "SQUOTES", "content", entry_group(0)))
```

Ordinary atoms:

```text
others: /[^\s\"\{\}\(\)\[\];]+/  I.return(h("type", "OTHERS", "content", entry_text()))
```

These rules return typed hashes, but the parent `parenthesis` rule usually extracts only the `content` field:

```text
scalaref(retv, {content})
```

That is why:

```text
("x y")
```

returns:

```text
[
  'x y',
  undef,
]
```

and:

```text
([square])
```

returns:

```text
[
  '[square]',
  undef,
]
```

while:

```text
({curly})
```

returns:

```text
[
  'curly',
  undef,
]
```

The square-bracket reader preserves the brackets as content. The curly-brace reader captures inside the braces.

## Comments

The comment rule is:

```text
comments: /;.*\n/           I.return(h("type", "COMMENTS", "content", entry_text()))
```

Inside `parenthesis`, comments are called but not pushed into the head/tail content:

```text
-> comments          {call(comments)}
```

That means this input:

```text
(a ;comment
 b)
```

parses as:

```text
[
  'a',
  [
    'b',
  ],
]
```

The comment is recognized and consumed, but it is not part of the returned Lispish array-tree.

## Descriptor readiness

`Lispish.spec` is also a useful migration-quality example.

Descriptor mode:

```perl
my $descriptor = LinkedSpec::get_parser(
  'Lispish',
  return_descriptor => 1,
);
```

currently reports all nine Lispish rules as ActionIR-ready on the migration metadata path:

```text
raw_perl_dependency_count == 0
unresolved_helper_count == 0
language_agnostic_action_ir_ready == true
```

The descriptor-level migration summary reports:

```text
language_agnostic_blocked_rule_count == 0
language_agnostic_top_blocked_rule == undef
compatibility_surface_rule_count == 0
```

The regression suite locks those facts in the Lispish helper-flow migration checks.

This does not mean the spec is stylistically perfect or finished forever. It means the shipped parser is currently a strong example of the helper DSL and ActionIR migration direction: its active rule actions are no longer blocked by raw fallback dependencies or compatibility-surface syntax.

## The convenience module

The repository also ships `perl/Lispish.pm`.

That module is a thin convenience layer around the named parser plus array-tree helpers:

- `Lispish::single($string_ref)` parses one Lispish form.
- `Lispish::multi($path_or_string_ref)` parses every form from a path or scalar reference.
- `Lispish::recurse(...)` walks the returned array tree.
- `Lispish::flatten(...)` flattens a Lispish array tree.
- `Lispish::substitute(...)` transforms scalar leaves.
- `Lispish::ascii(...)` prints an indented view.
- `Lispish::grep(...)` collects nodes whose head matches a pattern.

The important modern architectural detail is that `Lispish.pm` now calls:

```perl
LinkedSpec::get_parser('Lispish')
```

directly, instead of routing through legacy plugin parser lookup.

## What to learn from this spec

Use `Lispish.spec` as a compact example of:

- recursive child parser calls,
- action-local accumulator state,
- helper-style assignment and array mutation,
- `entry_text()` versus `entry_group(...)` in token readers,
- `scalaref(retv, {content})` for reading child-result fields,
- descriptor-mode readiness checks,
- the difference between a shipped parser and a tiny tutorial parser.

Do not treat every stylistic choice in this historical shipped spec as the ideal spelling for new specs. For new public teaching examples, prefer the clearer helper-style patterns in [Worked `.spec` Walkthrough](../user-model/worked-spec-walkthrough.md), then come back to Lispish to see how those ideas appear in a real recursive parser.
