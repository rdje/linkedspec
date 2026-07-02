# `ebnf.spec` Walkthrough

`specs/ebnf.spec` is the shipped grammar-file parser.

It is the best second shipped-spec walkthrough after [`Lispish.spec` Walkthrough](lispish-spec-walkthrough.md) because it is still small enough to study end to end, but it exercises a different class of parser:

- file-oriented parser loading by spec name (the `get_parser` entry point),
- a stateful top-level rule named `grammar_file`,
- include directive extraction,
- semantic annotations,
- logging annotations,
- rule-definition discovery,
- rule-reference, literal, operator, regex, probability, quantifier, and return-annotation token readers,
- guard logic that rejects tokens before a containing grammar rule exists,
- descriptor metadata that proves the helper-flow migration is not blocked by raw-Perl fallback,
- real corpus parsing over `ebnf/*.ebnf`.

This parser is not trying to build a full strongly typed grammar AST. It is an EBNF-style extractor: it groups each grammar rule into an ordered token payload and leaves later stages to interpret that payload.

That design is useful for a shipped example because it shows a realistic middle ground. A LinkedSpec parser does not always need to finish every semantic analysis step. It can reliably capture a normalized intermediate representation first.

## How to run it

`ebnf.spec` is the backend-neutral contract; any LinkedSpec backend can run it. The
reference (Perl) backend loads it by spec name:

```perl
use LinkedSpec;

my $parser = LinkedSpec::get_parser('ebnf');

my $input = <<'EBNF';
Expr := Term ("+" Term)*
Term := Factor
EBNF

my $ast = $parser->(\$input);
```

The parser returns an array of grammar-rule entries:

```text
[
  [
    ['rule', 'Expr'],
    ['rule_reference', 'Term'],
    ['group_open', '('],
    ['quoted_string', '+'],
    ['rule_reference', 'Term'],
    ['group_close', ')'],
    ['operator', '*'],
  ],
  [
    ['rule', 'Term'],
    ['rule_reference', 'Factor'],
  ],
]
```

That shape is regression-locked in `t/phase0_regression.t` by the `ebnf_invariants_smoke` check.

## Output shape

The top-level result is a flat array.

Each grammar rule is represented as one array:

```text
[
  ['rule', <rule-name>],
  <zero-or-more-token-entries>
]
```

For example:

```text
Term := Factor
```

becomes:

```text
[
  ['rule', 'Term'],
  ['rule_reference', 'Factor'],
]
```

Top-level include directives are also returned as top-level entries. They are not nested under the following rule:

```text
include(foo, bar)
```

becomes:

```text
[
  'include_file',
  ['foo', 'bar'],
]
```

This means the full return is intentionally heterogeneous:

```text
[
  <include-entry>,
  <rule-entry>,
  <rule-entry>,
]
```

That is a useful design for a grammar-file extractor. It preserves file-order information without forcing include directives into fake grammar rules.

## A richer example

This input exercises most of the public surface of the shipped parser:

```text
include(foo, bar)
@generate: build_expr
Expr := Term ("+" Term)* @80% -> [$1, $2] @log_rule("expr", "term")
Term := /[a-z]+/
```

It parses as:

```text
[
  [
    'include_file',
    [
      'foo',
      'bar',
    ],
  ],
  [
    [
      'rule',
      'Expr',
    ],
    [
      'semantic_annotation',
      [
        'generate',
        'build_expr',
      ],
    ],
    [
      'rule_reference',
      'Term',
    ],
    [
      'group_open',
      '(',
    ],
    [
      'quoted_string',
      '+',
    ],
    [
      'rule_reference',
      'Term',
    ],
    [
      'group_close',
      ')',
    ],
    [
      'operator',
      '*',
    ],
    [
      'probability',
      '80',
    ],
    [
      'return_array',
      '[$1, $2]',
    ],
    [
      'logging_annotation',
      [
        'log_rule',
        [
          'expr',
          'term',
        ],
      ],
    ],
  ],
  [
    [
      'rule',
      'Term',
    ],
    [
      'regex',
      '[a-z]+',
    ],
  ],
]
```

The important details are:

- `include(foo, bar)` normalizes to `include_file`.
- `@generate: build_expr` is attached to the next grammar rule.
- `Expr := ...` starts a new rule entry.
- `Term` is a `rule_reference`.
- `"+"` is a `quoted_string` with quotes removed.
- `(` and `)` are explicit group tokens.
- `*` is an `operator`.
- `@80%` becomes a `probability` payload of `80`.
- `-> [$1, $2]` becomes a `return_array` payload.
- `@log_rule("expr", "term")` becomes a `logging_annotation` with its argument list normalized.
- `/[a-z]+/` becomes a `regex` payload with the slash delimiters removed.

This is not an abstract example. It is a good model for how LinkedSpec can be used as a practical extraction engine: read a real grammar-like document, normalize the tokens you care about, and keep the output simple enough for downstream passes.

## Rule inventory

The compiled descriptor currently exposes 24 rules:

```text
close_paren
comma
comment
grammar_file
grammar_rule
include_dir
include_file
logging_annotation
number
open_paren
pipe_operator
plus_operator
probability
quantifier
question_operator
quoted_string
regex
return_array
return_object
return_scalar
rule_name
semantic_annotation
star_operator
whitespace
```

The main roles are:

| Rule | Role |
| --- | --- |
| `grammar_file` | top-level parser entry; owns the current rule accumulator, include list, pending semantic annotations, and guard state. |
| `grammar_rule` | recognizes a rule declaration such as `Expr :=` or `Expr ::=`, then returns `['rule', 'Expr']`. |
| `rule_name` | recognizes bare identifiers inside a rule body and returns `['rule_reference', ...]`. |
| `quoted_string` | recognizes single- or double-quoted literals and strips their quote delimiters. |
| `number` | recognizes integer literals. |
| `quantifier` | recognizes bounded quantifiers such as `{2}` or `{1,3}` and strips braces. |
| `plus_operator` | recognizes `+` and returns it as an operator token. |
| `star_operator` | recognizes `*` and returns it as an operator token. |
| `question_operator` | recognizes `?` and returns it as an operator token. |
| `pipe_operator` | recognizes `|` and returns it as an operator token. |
| `open_paren` | recognizes `(` and returns a `group_open` token. |
| `close_paren` | recognizes `)` and returns a `group_close` token. |
| `probability` | recognizes annotations such as `@80%` and strips `@` / `%`. |
| `regex` | recognizes slash-delimited regex literals and strips the slash delimiters. |
| `return_scalar` | recognizes scalar return annotations after `->`. |
| `return_array` | recognizes bracketed return annotations after `->`, including nested bracket/brace content. |
| `return_object` | recognizes object return annotations after `->`, including nested bracket/brace content. |
| `include_dir` | recognizes `dir(...)` / `include_dir(...)` and returns `include_dir` entries. |
| `include_file` | recognizes `include(...)`, `include_file(...)`, or `file(...)` and returns `include_file` entries. |
| `semantic_annotation` | recognizes `@name:` style annotations and captures the following payload. |
| `logging_annotation` | recognizes `@log_*`, `@debug_*`, `@trace_*`, `@benchmark_*`, `@profile_*`, or `@timing_*` calls with quoted arguments. |
| `comma` | helper token for logging-annotation argument separation. |
| `whitespace` | skips whitespace. |
| `comment` | skips `#` comments. |

## The top-level state machine

The top-level rule begins:

```text
grammar_file:: I {
  declare(array, rules, rule, includes, semantic_annotations);
  declare(scalar, rule, on)
}
```

The declarations tell you how the parser thinks:

- `rules` stores completed grammar-rule entries.
- `rule` stores the rule currently being built.
- `includes` stores top-level include directives.
- `semantic_annotations` stores annotations waiting for the next grammar rule.
- `on` records whether the parser is currently inside a rule context.

The lifecycle exit block finalizes the last open rule and returns the public payload:

```text
LX {
  if(scalar(rule));
    push_value(array(rules), array(scalar(rule), flat_array(rule)));
  endif();

  return(array(flat_array(includes), flat_array(rules)))
}
```

Read this as:

- if a current rule exists, flush it into `rules`,
- then return all include entries followed by all rule entries.

The helper names matter:

- `scalar(rule)` reads the scalar variable `rule`.
- `array(rules)` reads the array variable `rules`.
- `push_value(...)` appends one constructed value into an array variable.
- `flat_array(rule)` expands the current rule array into a returned entry.
- `return(array(...))` returns an array payload.

This is the same helper-first direction used throughout the modern LinkedSpec refactor. The rule still has historical shape in places, but the core top-level accumulator flow is helper-visible and descriptor-ready.

## Starting a new grammar rule

The `grammar_file` rule starts a new rule entry through this action edge:

```text
-> grammar_rule   {
  if(scalar(rule));
    push_value(array(rules), array(scalar(rule), flat_array(rule)));
  endif();

  set(array(rule), array(flat_array(semantic_annotations)));
  set(array(semantic_annotations), array());

  $rule = call(grammar_rule);
  set(scalar(on), 1)
}
```

The flow is:

- if a previous rule is open, flush it,
- seed the new rule with pending semantic annotations,
- clear the pending annotation array,
- call `grammar_rule` to read the new rule name,
- set `on` so later token edges know a container rule exists.

That is why this input:

```text
@generate: build_expr
Expr := Term
```

returns the semantic annotation inside the `Expr` rule:

```text
[
  [
    ['rule', 'Expr'],
    ['semantic_annotation', ['generate', 'build_expr']],
    ['rule_reference', 'Term'],
  ],
]
```

The parser intentionally treats semantic annotations as pending metadata for the next grammar rule.

## Guarded rule-body tokens

Most token readers are guarded by the `on` scalar.

For example:

```text
-> rule_name
  .if(scalar(on))
    .push(rule_name, rule)
  .else()
    .say("Error: Rule name '$LMATCH' reference with no container rule context")
    .return_undef()
  .endif()
```

The same pattern appears for quoted strings, numbers, quantifiers, operators, return annotations, parentheses, probabilities, regex literals, and logging annotations.

The rationale is simple: `Term` should be a rule reference only after a containing rule has started. If the parser sees a body token before any `grammar_rule` has created a container, the parse should fail with a clear guard message instead of silently producing an orphan token.

This action-edge fluent chain is portable on the Perl reference and Rust backend: the child reader runs only in
the active branch, `.push(rule_name, rule)` appends the child return to the `rule` accumulator, `.say(...)`
emits the guard diagnostic in the fallback branch, and `.return_undef()` stops that action edge without adding
an orphan token.

This is a useful pattern for users writing their own file parsers:

- keep a small scalar state flag,
- accept child tokens only when the surrounding container exists,
- return `undef` with a clear message when a token appears in the wrong structural position.

## Terminal token readers

The terminal rules normalize text immediately.

The rule-name reader:

```text
grammar_rule: /(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=/  I.return(array("rule", entry_group(0)))
```

captures the left-hand rule name and returns a two-element token:

```text
['rule', 'Expr']
```

The rule-reference reader:

```text
rule_name: /\b[[:alpha:]_]\w*/ I.return(array("rule_reference", entry_text()))
```

returns:

```text
['rule_reference', 'Term']
```

The quoted-string reader:

```text
quoted_string: /"[^"]*"|'[^']*'/  I.declare(scalar, value=entry_text()).substr(scalar(value), "^(?:'|\")|(?:'|\")$", "", go).return(array("quoted_string", scalar(value)))
```

normalizes:

```text
"+"
```

into:

```text
['quoted_string', '+']
```

The regex reader:

```text
regex: /(?<!\\)\/.+?(?<!\\)\// I.declare(scalar, value=entry_text()).substr(scalar(value), "^/|/$", "", go).return(array("regex", scalar(value)))
```

normalizes:

```text
/[a-z]+/
```

into:

```text
['regex', '[a-z]+']
```

The probability reader:

```text
probability: /@\d+%?/ I.declare(scalar, value=entry_text()).substr(scalar(value), "@|%", "", go).return(array("probability", scalar(value)))
```

normalizes:

```text
@80%
```

into:

```text
['probability', '80']
```

The repeated pattern is deliberate:

- read the immediate match with `entry_text()` or `entry_group(...)`,
- set it into a named scalar when cleanup is needed,
- normalize with `substr(...)`,
- return a typed array token.

This keeps small lexical readers easy to audit.

## Return annotations

`ebnf.spec` recognizes three return-annotation families after `->`:

```text
return_scalar
return_array
return_object
```

Examples:

```text
Expr := Term -> $1
Expr := Term -> [$1, $2]
Expr := Term -> {name: $1, tail: $2}
```

Those become:

```text
['return_scalar', '$1']
['return_array', '[$1, $2]']
['return_object', '{name: $1, tail: $2}']
```

The array and object readers use recursive regex definitions so nested bracket/brace content can be kept together as one payload.

That is an important limitation and strength at the same time:

- the parser does not deeply parse the return expression in this spec,
- it does keep the whole balanced return payload together so a later stage can parse it.

## Include directives

The include readers normalize several spellings:

```text
include(foo, bar)
include_file(foo, bar)
file(foo, bar)
dir(grammars)
include_dir(grammars)
```

The file-oriented forms return `include_file`:

```text
[
  'include_file',
  ['foo', 'bar'],
]
```

The directory-oriented forms return `include_dir`:

```text
[
  'include_dir',
  ['grammars'],
]
```

These rules still look more host-Perl-shaped than newer helper-only examples because they split and trim comma-separated lists in a compact historical idiom. The descriptor still reports them as ActionIR-ready today:

```text
include_dir raw=0 unresolved=0 ready=1 nodes=ASSIGN|REGEX_SUBST|RETURN
include_file raw=0 unresolved=0 ready=1 nodes=ASSIGN|REGEX_SUBST|RETURN
```

That distinction matters. The public direction is helper-first authoring, but the shipped parser is also a migration artifact. The regression suite locks whether a historical-looking construct is still understood by the canonical ActionIR path.

## Semantic annotations

Semantic annotations use this shape:

```text
@generate: build_expr
```

The parser returns:

```text
['semantic_annotation', ['generate', 'build_expr']]
```

The rule is:

```text
semantic_annotation: /@(\w+)\s*:\s*/
-> semantic_annotation | grammar_rule {BACKTRACK(); declare(scalar, c=capture_slice()); substr(scalar(c), "\s*$", "", o); substr(scalar(c), "^\"|\"$", "", go); return(array("semantic_annotation", array(entry_group(0), scalar(c))))}
```

The key ideas are:

- the first regex reads the annotation name and colon,
- the following action captures the payload until the next semantic annotation or grammar rule,
- `BACKTRACK()` positions the parser so the next structural token can be processed by its own rule,
- the payload is trimmed before returning,
- the action is written entirely in canonical helper DSL (`capture_slice()`, `substr(...)`, `entry_group(0)`, `return(array(...))`) — no raw host-language code, which is why the descriptor below reports this rule as ActionIR-ready.

This rule is a good example of why capture-boundary helpers matter. It is parsing an open-ended payload where the right edge is not a fixed delimiter; it is the beginning of the next structural thing.

## Logging annotations

Logging annotations use a call-like shape:

```text
@log_rule("expr", "term")
```

The parser returns:

```text
['logging_annotation', ['log_rule', ['expr', 'term']]]
```

The shipped rule is:

```text
logging_annotation: /@((?:log|debug|trace|benchmark|profile|timing)_\w+)\s*\(\s*/ /\s*\)/ I {declare(scalar, logging_name=entry_group(0)); start_capture_slice()}
```

and then:

```text
-> quoted_string {
  push(quoted_string, 1);
  start_capture_slice()
}
-> comma {
  push_nonempty(array(logging_annotation), trim(capture_slice()));
  start_capture_slice()
}
-> logging_annotation[1] {
  push_nonempty(array(logging_annotation), trim(capture_slice()));
  return(array("logging_annotation", array(scalar(logging_name), array_copy(array(logging_annotation)))))
}
```

This is a useful advanced example because it combines:

- a two-regex rule,
- explicit anonymous capture-boundary movement,
- a child call into `quoted_string`,
- `push(...)` for the indexed quoted-string child result,
- comma handling,
- `push_nonempty(...)` for trimmed optional capture appends,
- a normalized typed return payload.

The current regression suite locks this runtime behavior because the optional comma and closing-edge spans are real parser data only after trimming. `push_nonempty(array(logging_annotation), trim(capture_slice()))` makes that intention explicit: read the current anonymous capture slice, trim it, and append it only when the result is not empty. This replaces the old `capture_if(...)` / `CAPTURE_IF()` surface in the live `ebnf.spec` rule while keeping the same runtime shape for nonempty argument fragments.

```text
push_nonempty(array(logging_annotation), trim(capture_slice()));
```

That is not incidental. The helper is short enough to use in a spec, but explicit enough to expose all three concepts the parser author cares about: the capture boundary, the normalization step, and the accumulator append rule. The regression exists so logging annotations remain a real parser feature, not just descriptor metadata.

## Corpus relationship

The repository also ships real `.ebnf` files:

```text
ebnf/builtin_return_annotation.ebnf
ebnf/builtin_semantic_annotation.ebnf
ebnf/ebnf.ebnf
ebnf/json.ebnf
ebnf/regex.ebnf
ebnf/return_annotation.ebnf
ebnf/semantic_annotation.ebnf
```

The regression suite parses that directory with `ebnf.spec` and expects array ASTs.

At the time of this walkthrough, a direct probe returns:

```text
ebnf/builtin_return_annotation.ebnf ARRAY entries=32
ebnf/builtin_semantic_annotation.ebnf ARRAY entries=7
ebnf/ebnf.ebnf ARRAY entries=122
ebnf/json.ebnf ARRAY entries=19
ebnf/regex.ebnf ARRAY entries=78
ebnf/return_annotation.ebnf ARRAY entries=30
ebnf/semantic_annotation.ebnf ARRAY entries=111
```

This pairing is important:

```text
specs/ebnf.spec parses ebnf/*.ebnf
```

It means `ebnf.spec` is not only an isolated demonstration file. It is part of a shipped parser-plus-corpus quality loop.

## Descriptor readiness

You can ask the reference (Perl) backend for the descriptor instead of a parser:

```perl
use LinkedSpec;

my $descr = LinkedSpec::get_parser(
  'ebnf',
  return_descriptor => 1,
);
```

The descriptor currently reports 24 rules, no language-agnostic ActionIR blockers, and no compatibility-surface rules:

```text
rules=24
blocked=0
compatibility_surface_rules=0
top_blocked=<undef>
```

Selected rule metadata:

```text
grammar_file raw=0 unresolved=0 ready=1 nodes=ASSIGN|CALL|DECLARE|ELSE|ENDIF|IF|PUSH|RETURN|SAY
grammar_rule raw=0 unresolved=0 ready=1 nodes=IMATCH_GROUP_READ|RETURN
rule_name raw=0 unresolved=0 ready=1 nodes=IMATCH_TEXT_READ|RETURN
quoted_string raw=0 unresolved=0 ready=1 nodes=DECLARE|IMATCH_TEXT_READ|REGEX_SUBST|RETURN
quantifier raw=0 unresolved=0 ready=1 nodes=DECLARE|IMATCH_TEXT_READ|REGEX_SUBST|RETURN
probability raw=0 unresolved=0 ready=1 nodes=DECLARE|IMATCH_TEXT_READ|REGEX_SUBST|RETURN
regex raw=0 unresolved=0 ready=1 nodes=DECLARE|IMATCH_TEXT_READ|REGEX_SUBST|RETURN
include_dir raw=0 unresolved=0 ready=1 nodes=DECLARE|FILTER_NONEMPTY|IMATCH_TEXT_READ|REGEX_SUBST|RETURN|SPLIT|TRIM_EACH
include_file raw=0 unresolved=0 ready=1 nodes=DECLARE|FILTER_NONEMPTY|IMATCH_TEXT_READ|REGEX_SUBST|RETURN|SPLIT|TRIM_EACH
semantic_annotation raw=0 unresolved=0 ready=1 nodes=BACKTRACK|CAPTURE_SLICE|DECLARE|IMATCH_GROUP_READ|REGEX_SUBST|RETURN
logging_annotation raw=0 unresolved=0 ready=1 nodes=CAPTURE_SLICE|CAPTURE_SLICE_START|DECLARE|IMATCH_GROUP_READ|PUSH|RETURN
```

The key public reading is:

- `raw=0` means the ActionIR classifier does not report raw-Perl fallback dependency for that rule.
- `unresolved=0` means helper recognition is not leaving unresolved helper calls behind.
- `ready=1` means the rule is considered language-agnostic ActionIR-ready by current metadata.
- `nodes=...` shows the canonical ActionIR concepts the rule exercises.

This is why `ebnf.spec` is useful in the book. It shows a shipped parser that still has historical texture, but whose major token readers and top-level accumulator flow are now visible to the helper/ActionIR migration machinery.

## What the regression suite locks

`t/phase0_regression.t` currently locks several important `ebnf.spec` promises:

- descriptor build succeeds through `LinkedSpec::get_parser('ebnf', return_descriptor => 1)`,
- `grammar_file` no longer reports raw-Perl fallback dependency,
- terminal token readers such as `grammar_rule`, `rule_name`, `quoted_string`, `quantifier`, `probability`, and `regex` are ActionIR-ready,
- the source spec uses canonical wrappers such as `scalar(...)` and `array(...)` in the core method-DSL band,
- `logging_annotation` uses explicit `start_capture_slice()` boundary movement,
- `logging_annotation` uses `push_nonempty(...)` instead of the older `capture_if(...)` / `CAPTURE_IF()` helper surface,
- the full `ebnf` descriptor reports zero compatibility-surface rules,
- `@log_rule("expr", "term")` parses at runtime into a normalized `logging_annotation` payload,
- `ebnf/*.ebnf` corpus files parse through `ebnf.spec` and return array ASTs,
- the small `Expr` / `Term` smoke input preserves the expected top rule names.

That is the standard the public book should follow: when it documents shipped behavior, it should point at behavior the project actually validates.

## How to read this spec

When reading `specs/ebnf.spec`, read it in this order:

1. Start with `grammar_file` and understand the accumulator state.
2. Read the `grammar_rule` edge to see how previous rules are flushed and new rules are started.
3. Read one guarded token edge, then notice the same guard pattern repeated across the body-token family.
4. Read the small terminal token readers and their typed return payloads.
5. Read `semantic_annotation` for open-ended capture and backtracking.
6. Read `logging_annotation` for two-regex capture-boundary parsing and quoted argument collection.
7. Read the descriptor metadata to understand which historical-looking pieces are still covered by ActionIR readiness.

The practical lesson is not "copy this spec exactly." The practical lesson is that a medium-sized grammar extractor can stay understandable when each rule has a narrow job and the top-level rule owns the lifecycle of the accumulated structure.
