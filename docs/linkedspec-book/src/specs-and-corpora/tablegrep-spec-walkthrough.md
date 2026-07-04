# `tablegrep.spec` Walkthrough

`specs/tablegrep.spec` is a grep-like expression parser. It parses boolean filter expressions combining field-match terms (`field !=~ /regex/`) with `&&` (AND) and `||` (OR) operators, including parenthesized grouping.

It demonstrates:

- multiple top-level alternatives with `grep::` as the entry rule,
- recursive parenthesized grouping (`group` calling itself),
- operator precedence through rule ordering (re_term before or_op before and_op),
- lifecycle hooks (`I`, `LS`, `LE`, `LX`) for per-rule state and result assembly,
- error detection with structured exit codes,
- scalar and array helpers for AST construction.

Read this after [Worked `.spec` Walkthrough](../user-model/worked-spec-walkthrough.md) and the [`Lispish.spec` Walkthrough](lispish-spec-walkthrough.md).

## How to run it

`tablegrep.spec` is the backend-neutral contract; any LinkedSpec backend can run it. The
reference (Perl) backend loads it by spec name:

```perl
use LinkedSpec;

my $parser = LinkedSpec::get_parser('tablegrep');
my $input = 'field1 =~ /pattern1/ && field2 !=~ /pattern2/';
my $ast = $parser->(\$input);
```

The parser returns an array of AST nodes, one per matched expression component, or `undef` if the expression is empty.

## Output shape

The AST is shown below in the Perl reference backend's value rendering (hashes and
arrays); another backend produces the equivalent structure in its own value types.

For `field1 =~ /foo/`:

```perl
[{type => 'TERM', field => 'field1', sens => '=~', re => 'foo'}]
```

For `(field1 =~ /foo/ || field2 =~ /bar/)`:

```perl
[{type => 'GROUP', group => [
  {type => 'TERM', field => 'field1', sens => '=~', re => 'foo'},
  {type => 'OR_OP'},
  {type => 'TERM', field => 'field2', sens => '=~', re => 'bar'},
]}]
```

Invalid inputs produce error messages and non-zero exit codes: two consecutive operators without an intervening term (exit code 1), or an empty parenthesized group (exit code 2).

## Rule inventory

| Rule | Mode | Role |
| --- | --- | --- |
| `grep::` | Top (entry) | Entry point. Delegates to all four child rules. |
| `group` | `/(/ /)/` bounded regex | Parenthesized sub-expression with recursive self-call. |
| `re_term` | Ungrounded regex with 3 capture groups | Field-match term: `field op~ /regex/`. |
| `or_op` | `/\|\|/` | OR operator literal. Returns `{type => 'OR_OP'}`. |
| `and_op` | `/\&\&/` | AND operator literal. Returns `{type => 'AND_OP'}`. |

All five rules share the `I`/`LS`/`LE`/`LX` lifecycle pattern. Each rule:

- `I { ... }` — initializes `internal = []` for accumulating child results and `prev_node_type = undef` for operator adjacency checking.
- `LS { retv = undef }` — resets the per-match return-value scalar.
- `LE { ... }` — checks for undefined child results (skip), validates that two operators are never adjacent (exit code 1 on error), pushes the child result onto the internal array, and records the node type.
- `LX { ... }` — on rule exit: returns `undef` if the internal array is empty, otherwise returns a copy of the accumulated array.

## Key design points

**Operator precedence through rule ordering.** The entry rule lists alternatives in order: `re_term`, `or_op`, `and_op`, `group`. But the parser always tries all alternatives at each position. The ordering expresses intent rather than enforcing precedence at the grammar level.

**Error detection in lifecycle hooks.** The `LE` hook checks `:prev_node_type` — set on the previous match — to detect consecutive operators. This is validation logic embedded in the parser, not in post-processing.

**`re_term` conditional logic.** The `re_term` rule uses `if/else` to distinguish field-subscript terms (`[0] !=~ /foo/`) from named-field terms. The subscript form extracts the index via `substr(:subscript, /^\[(\d+)\]$/, "$1", o)` and labels the node `STERM`.

**`I.return(...)` shorthand.** The `or_op` and `and_op` rules use the compact `I.return(...)` form — declare nothing in `I`, return immediately. This is a LinkedSpec idiom for leaf rules that produce constant-shaped output.

## Descriptor readiness

The `tablegrep.spec` compiles with `language_agnostic_ready_ratio == 1.0000` — zero language-agnostic blocked rules and zero compatibility-surface rules. All helper usage (`assign`, `declare`, `push_value`, `array_copy`, `is_empty`, `matches`, `if/else/endif`, `and`, `or`, `not`) is canonical ActionIR.

## Why this spec is interesting

Tablegrep shows LinkedSpec used as a query-language frontend rather than a file-format parser. The expression grammar is small (5 rules, 84 lines) but demonstrates recursive grouping, operator detection, error handling with exit codes, and per-rule state accumulation — all patterns that scale to larger grammars.
