# `Lispish.spec` Walkthrough

`specs/Lispish.spec` is the best first shipped-spec walkthrough.

It is compact, but it is not a toy. It demonstrates:

- file-oriented parser loading by spec name (the `get_parser` entry point),
- a real top-level rule named `Lispish`,
- recursive parenthesized parsing,
- child-rule calls from action edges,
- helper-style scalar/array/hash construction,
- comments and whitespace handling,
- string/bracket/brace token readers,
- descriptor metadata that proves the helper-flow migration is no longer blocked by raw-Perl fallback.

Read this chapter after [Worked `.spec` Walkthrough](../user-model/worked-spec-walkthrough.md) if you want to see the same concepts in a shipped parser.

For a Rust application's complete submodule, build, UTF-8 file, result-adaptation
and deployment path, use [the Rust integration guide](../public-api/integration-rust.md).

## Current document and token limits

The shipped grammar extracts the first parenthesized form; it does not validate
the whole file. Native Rust and independently checked Perl examples both return
the first form for `prefix (a) suffix` and `(a)(b)`. Empty input and `(a b` return
no value; a leading unmatched `)` produces an error. A returned value alone is
therefore insufficient to establish valid, fully consumed input.

The rules can skip malformed token delimiters: `("abc)` returns an `abc` atom,
`([])` has the empty-form result, and `(a ;comment)` returns `a` and `comment`
because comments require a terminating newline. Double-quoted escapes retain
their literal backslash characters; they are not decoded. Numeric text stays
text, and the parent rules do not preserve symbol/string/number token kinds.
These outcomes were characterized directly on Rust; nine selected Perl values
agree. They are not an all-backend malformed-input guarantee.

The Rust guide supplies the exact tested cases and an adapter, but that adapter
cannot recover skipped text or missing token distinctions. Strict document/token
parsing is pending under `SESSION-STARTUP-READING.83.1-.83.3`. The walkthrough's
valid examples below retain their historical head/tail representation.

## Multiline quoted text

Double-quoted strings preserve actual line feeds, carriage returns, indentation,
and blank lines. Parentheses inside such strings are data and do not close a form:

```text
(r (a "p
   q) r") (b "z"))
```

The historical head/tail result is:

```json
["r",[["a",["p\n   q) r"]],["b",["z"]]]]
```

Here `\n` is JSON's representation of an actual line feed. An authored backslash
followed by `n` remains those two literal characters; Lispish does not decode
escapes. CRLF remains CR followed by LF. Adjacent fragments still concatenate:

```text
(adjacent a"x
y"[z]{w})
```

This returns `["adjacent",["ax\ny[z]w"]]` in the historical representation.

Both quote readers use the inline `(?s)` regex flag so their content captures
include newlines. The brace reader uses both readers:

```text
(brace-single {before 'x
 }y' after} tail)
```

The inner `}` stays inside the quoted text. The result is
`["brace-single",["before 'x\n }y' after","tail"]]`: the outer braces are removed,
and the single quotes are retained. Single quotes in ordinary parenthesized forms
remain atom characters: `('x y')` returns the two atoms `'x` and `y'`.

The regression fixture `tests/lispish/quoted-newlines.json` covers multiline
payloads, both quote readers through matched parent edges, siblings, embedded
delimiters, escapes, comments, Unicode, empty strings and historical adjacent-fragment behavior. Phase0's
`lispish_ast_smoke` consumes the same expectations as the native CLI matrix.
This fixes SEMULITH/LS-001; the document-validation and atom-kind limitations above
remain separately owned.

## Planned complete-document variant

ADR0124 accepts the design of a separate `SExprDocumentV1.spec`; implementation
and cross-backend admission are pending. The shipped Lispish behavior above remains
available with its existing representation.

The planned result has a `format` of `linkedspec-sexpr-v1` and an ordered `forms`
array. Lists contain tagged `items`. Atoms retain their kind and full source
`lexeme`, including string quotes and escape spelling. For `(v 1 "1")`, the
planned result is:

```json
{
  "format": "linkedspec-sexpr-v1",
  "forms": [{"kind": "list", "items": [
    {"kind": "symbol", "lexeme": "v"},
    {"kind": "number", "lexeme": "1"},
    {"kind": "string", "lexeme": "\"1\""}
  ]}]
}
```

The new entry will return every parenthesized top-level form, accept empty and
comment-only documents, and reject unmatched delimiters and unrecognized leading,
interstitial or trailing text. Lexemes permit token-preserving reconstruction;
inter-token whitespace and comments are omitted. Numeric spelling is retained
without numeric conversion, and strings retain escapes without decoding.

The design prototype reproduced Rust's warning/drop compiler defect. The shared
error-propagation repair is now verified under `SESSION-STARTUP-READING.45.1`;
carrier verification and canonical closeout remain `.45.2/.45.3`. Grammar,
native file-consumer delivery and final admission then remain `.83.2.2/.83.2.3/.83.3`.

## How to run it

`Lispish.spec` is the backend-neutral contract; any LinkedSpec backend can run it. The
reference (Perl) backend loads it by spec name:

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
I { word = []; tail = []; retv = undef; head = undef; has_head = undef }
```

The opening and closing regexes are the parenthesis anchors. The `I { ... }` lifecycle block initializes the working state for one invocation:

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
  if(has_head);
   if(is_nonempty(tail));
    return(array(head, copy(tail)));
   else();
    return(array(head, undef));
   endif();
  else();
   return([undef]);
  endif()
}
```

The value forms matter:

- `head` and `tail` are bare typed bindings; their runtime values determine their kinds.
- `copy(tail)` snapshots the tail elements into the returned array shape.
- `return(array(...))` returns an array payload.
- `[undef]` is the unambiguous one-element array literal; it is not a storage selector.

This is a good real example of why helper DSL matters. The rule contains recursion, accumulation, conditional flow, child calls, array pushes, and structured returns without falling back to ad hoc raw Perl for the core dataflow.

## Token readers

The token readers are intentionally small.

Double-quoted strings:

```text
dquotes: /(?s)"(.*?)(?<!\\)"/     I.return(hash("type", "DQUOTES", "content", entry_group(0)))
```

Single-quoted strings:

```text
squotes: /(?s)'(.*?)(?<!\\)'/     I.return(hash("type", "SQUOTES", "content", entry_group(0)))
```

Ordinary atoms:

```text
others: /[^\s\"\{\}\(\)\[\];]+/  I.return(hash("type", "OTHERS", "content", entry_text()))
```

These rules return typed hashes, but the parent `parenthesis` rule usually extracts only the `content` field:

```text
retv["content"]
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
comments: /;.*\n/           I.return(hash("type", "COMMENTS", "content", entry_text()))
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

The repository also ships `perl/Lispish.pm`. This is a **Perl reference-backend**
convenience module, not part of the backend-neutral `.spec` contract — a different
backend would provide its own equivalent (or none).

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
- `retv["content"]` for reading child-result fields,
- descriptor-mode readiness checks,
- the difference between a shipped parser and a tiny tutorial parser.

Do not treat every stylistic choice in this historical shipped spec as the ideal spelling for new specs. For new public teaching examples, prefer the clearer helper-style patterns in [Worked `.spec` Walkthrough](../user-model/worked-spec-walkthrough.md), then come back to Lispish to see how those ideas appear in a real recursive parser.
