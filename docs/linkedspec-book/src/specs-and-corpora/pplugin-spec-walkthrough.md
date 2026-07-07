# `pplugin.spec` Walkthrough

`specs/pplugin.spec` parses LinkedSpec plugin files (`.plg`). Plugin files define Perl subroutines in a lightweight DSL that the legacy `PPlugin` runtime loads and executes. This spec is the parser that `PPlugin` itself uses to read plugin source files.

> **Perl reference implementation.** `.plg` files and the `PPlugin` runtime belong to the **Perl reference backend's** legacy plugin system, not to the portable runtime contract. This walkthrough is included because `pplugin.spec` is a real shipped parser example for a host-language format. Its current descriptor status is ready (`language_agnostic_ready_ratio = 1.0000`, zero blocked rules, zero compatibility-surface rules), while `.plg` execution still returns Perl coderefs in the reference runtime.

It demonstrates:

- the plugin-family DSL (subroutine definitions with `subname { ... }` syntax),
- recursive bracket-matching for nested `{ }` blocks,
- string-literal skipping (`dquotes`, `squotes`, `curlyb`),
- the `next()` control-flow helper for skipping ignored matches,
- `entry_named(...)` for accessing named regex capture groups,
- host-language plugin-body coderef construction in the Perl reference runtime.

Read this after the [`Lispish.spec` Walkthrough](lispish-spec-walkthrough.md).

## How to run it

`pplugin.spec` is a shipped `.spec` parser. The reference Perl backend loads it by spec name:

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

The returned payload is useful to the Perl reference runtime because it contains coderefs. A future backend may
use this file as a parser/corpus target, but compiling `.plg` bodies into executable Perl callbacks is not a
cross-backend runtime requirement.

## Output shape

On the Perl reference backend, a plugin with two subroutines returns:

```perl
{
  do_thing  => sub { ... },  # compiled coderef
  do_other  => sub { ... },
}
```

The parser returns a flat hash (name => coderef pairs) where each value is a Perl callback for the plugin body.
The hash is built by the `LX` block's `return(hash(flat_array(array(defs))))` call.

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

**Legacy `eval` inside the returned coderef.** The `subdef[1]` action edge returns
`sub {eval substr($$STRING, $IPOS, $LSPOS - $IPOS - 1)}` as the plugin-body callback. That callback is Perl
reference-runtime behavior: plugin subroutine bodies are Perl code, not LinkedSpec DSL. This host-language
payload is separate from the descriptor's compatibility-surface summary for the `.spec` parser rules.

## Descriptor readiness

The current `pplugin` descriptor reports:

- `language_agnostic_ready_ratio = 1.0000`
- `language_agnostic_blocked_rule_count = 0`
- `compatibility_surface_rule_count = 0`

That means the shipped `.spec` parser no longer depends on retired helper spellings, raw fallback statements, or
compatibility-surface rule events. It does not turn legacy `.plg` execution into a portable runtime target; it only
states that the parser rules are descriptor-ready under the current ActionIR migration metadata.

## Why this spec is interesting

Pplugin shows LinkedSpec parsing one of its historical source formats. The recursive bracket-matching with
string-literal awareness is a pattern that scales to any nested-delimiter grammar. And the `next()` helper shows how
LinkedSpec handles "skip this, try the next alternative" without needing a separate tokenizer pass.
