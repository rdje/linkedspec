# USER GUIDE
This guide explains how to use LinkedSpec as a progressive extraction parser DSL.

## What LinkedSpec Is
LinkedSpec compiles `.spec` files from `specs/` into dynamic Perl parsers.
These generated parsers parse input strings and return raw AST/data structures.

LinkedSpec is intentionally optimized for:
- Nested and recursive constructs.
- Coarse-to-fine staged parsing.
- Rapid parser prototyping.

## Typical Workflow
1. Write a `.spec` grammar with rule labels, regexes, and actions.
2. Build parser:
   - `my $parser = LinkedSpec::get_parser('my_spec_name');`
3. Parse data:
   - `my $ast = $parser->(\$input_string);`
4. Optionally run additional parsing passes on selected captured substrings.

## Rule Skeleton
```text
top_rule::
 -> subrule_a
 -> subrule_b
 LX { return \@top_rule }

subrule_a: /.../
subrule_b: /.../
```

## Core Syntax
- Entry rule: `name::`
- Regular rule: `name:`
- Regex pattern(s): `/.../` (single or multiple per rule)
- Branch/action:
  - `-> rule`
  - `-> rule[idx]`
  - `-> rule { ... }`
  - `-> rule .method(args)` (method-like shorthand)
- Non-action code blocks:
  - `I { ... }` (init)
  - `LS { ... }` (loop-start hook)
  - `LE { ... }` (loop-end hook)
  - `LX { ... }` (loop-exit/fail hook)
  - Also used in advanced specs: `E`, `EX`, `IT`

## Useful Action Helpers
Inside action code, LinkedSpec supports helper forms such as:
- `call(rule)`
- `push(rule)`
- `return_a(rule)`
- `return_m(rule)`
- `return_ma(rule)`
- `$CAPTURE`
- `BACKTRACK()`, `IBACKTRACK()`

These helpers are expanded by LinkedSpec into parser runtime code.

## Multi-Pass Parsing Pattern (Recommended)
Use pass-by-pass refinement:
1. First pass: coarse anchors to chunk input.
2. Next pass(es): parse chunk content with more specialized specs.
3. Final pass: normalize/merge into final AST.

This pattern is a primary LinkedSpec strength.

## Runtime Options (current)
`LinkedSpec::Get(\$spec, %options)` supports:
- `parse_only => 1`
- `generate_only => 1`
- `pm_drive => 1` (emit generated parser code text)

## Spec Lookup Behavior (`get_parser`)
`LinkedSpec::get_parser('name')` resolves parser specs in this order:
1. If argument is already a valid file path, use it directly.
2. Try `name.spec` directly if available.
3. Try module-relative `../specs/name.spec` (relative to `perl/LinkedSpec.pm`).
4. If still unresolved, fall back to `PathSearch`.

This removes hard dependency on running from the project root.

## Known Caveats
- Current behavior is extraction-oriented and may not enforce full contiguous consumption unless spec logic does so.
- Some old specs may rely on permissive behavior.
- `specs/tclite.spec` currently has a known compile issue to be fixed.

## Debugging
- Set `LinkedSpec` verbosity via `our $DUMP_VERBOSITY`.
- Use `parse_only` and/or `pm_drive` to inspect compile/generation behavior.

## Versioning and Compatibility
- Treat existing specs as compatibility contracts.
- Before changing core semantics, validate against baseline specs and consumer modules.
