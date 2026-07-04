# `pplugin.spec` Walkthrough

`specs/pplugin.spec` parses LinkedSpec plugin files (`.plg`). Plugin files define Perl subroutines in a lightweight DSL that the `PPlugin` runtime loads and executes. This spec is the parser that `PPlugin` itself uses to read plugin source files.

> **Perl reference implementation.** `.plg` files and the `PPlugin` runtime belong to the **Perl reference backend's** legacy plugin system — not the backend-neutral `.spec` contract. This walkthrough is included because `pplugin.spec` is a real corpus example of parsing a host-language format; the `eval`-based compatibility surface it relies on is discussed below.

It demonstrates:

- the plugin-family DSL (subroutine definitions with `subname { ... }` syntax),
- recursive bracket-matching for nested `{ }` blocks,
- string-literal skipping (`dquotes`, `squotes`, `curlyb`),
- the `next()` control-flow helper for skipping ignored matches,
- `entry_named(...)` for accessing named regex capture groups,
- `eval`-based handler code for backward compatibility.

Read this after the [`Lispish.spec` Walkthrough](lispish-spec-walkthrough.md).

## How to run it

`pplugin.spec` is the backend-neutral contract; any LinkedSpec backend can run it. The
reference (Perl) backend loads it by spec name:

```perl
use LinkedSpec;

my $parser = LinkedSpec::get_parser('pplugin');
my $plugin_source = <<'PLUGIN';
sub do_thing {
  my ($self, @args) = @_;
  return "done";
}
PLUGIN
my $ast = $parser->(\$plugin_source);
```

## Output shape

For a plugin with two subroutines:

```perl
{
  do_thing  => sub { ... },  # compiled coderef
  do_other  => sub { ... },
}
```

The parser returns a flat hash (name => coderef pairs) where each value is the `eval`'d subroutine body. The hash is built by the `LX` block's `return(hash(flat_array(array(defs))))` call.

## Rule inventory

| Rule | Mode | Role |
| --- | --- | --- |
| `pplugin_top::` | Top (entry) | Entry point. Collects subroutine definitions. |
| `subdef` | `/\w\S*\s*(?<!\\)\{/` / `/(?<!\\)}/` bounded regex | Subroutine definition with named capture `subname`. |
| `curlyb` | `/(?<!\\)\{/` / `/(?<!\\)}/` bounded regex | Bare curly-brace block (skipped content). |
| `comment` | `/#.*/` | Comment line (consumed by `next()`). |
| `dquotes` | `/(?<!\\)".*?(?<!\\)"/` | Double-quoted string literal. |
| `squotes` | `/(?<!\\)'.*?(?<!\\)'/` | Single-quoted string literal. |

## Key design points

**Recursive bracket matching.** Both `subdef` and `curlyb` call `curlyb`, `dquotes`, and `squotes` as child rules. This means nested `{ }` blocks and string literals inside subroutine bodies are correctly skipped — the parser won't confuse a `{` inside a string with the subroutine's closing `}`. The `subdef` rule's closing-bracket edge (`subdef[1]`) fires only when the outermost matching `}` is found.

**Named capture for subroutine names.** The `subdef` rule's opening regex uses `(?<subname>\w\S*)` to capture the subroutine name. The closing edge accesses it via `entry_named(subname)` — a cleaner alternative to positional `entry_group(N)`.

**`next()` for comments.** The `pplugin_top` rule lists `-> comment { next() }` as its first alternative. `next()` is the LinkedSpec equivalent of Perl's `next` statement — it skips the current match and tries the next one. This means comments are silently consumed without affecting the accumulated `defs` array.

**`LX` accumulator pattern.** The `pplugin_top` rule accumulates `[name, coderef]` pairs in `I { defs = [] }`. Each `LE` hook pushes `[subname, coderef]` via `flat_array`. On exit (`LX`), the accumulated pairs are converted to a flat hash. This is the same accumulator pattern used by `tablegrep.spec`.

**Legacy `eval` in handler code.** The `subdef[1]` action edge uses `eval substr($$STRING, $IPOS, $LSPOS - $IPOS - 1)` — a raw Perl eval of the text between the opening `{` and closing `}`. This is one of the few remaining `eval` sites in shipped specs and exists because plugin subroutine bodies are Perl code, not LinkedSpec DSL. The long-term direction is to reduce this kind of host-language dependency.

## Descriptor readiness

The `pplugin.spec` has a `language_agnostic_ready_ratio` below 1.0000 due to the `eval` in `subdef[1]`. This rule is flagged as a compatibility-surface rule. The `eval` is necessary for the plugin system's current design (Perl subroutine bodies must be compiled), but it represents the kind of host-language coupling that future phases aim to reduce.

## Why this spec is interesting

Pplugin shows LinkedSpec parsing LinkedSpec's own plugin format — a step toward self-hosting. The recursive bracket-matching with string-literal awareness is a pattern that scales to any nested-delimiter grammar. And the `next()` helper shows how LinkedSpec handles "skip this, try the next alternative" without needing a separate tokenizer pass.
