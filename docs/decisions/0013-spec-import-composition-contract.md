# 0013 — Spec imports compose grammar material, not runtime payload parsing

- Date: 2026-07-02
- Status: accepted
- Tags: architecture, parser-composition, spec-language, imports, language-neutral

## Context

ADR `0012` separates two mechanisms that are easy to confuse:

- staged parse dispatch, which parses runtime text payloads produced by an earlier AST
  stage; and
- spec-file composition, which lets one `.spec` reuse grammar material from another
  `.spec`.

Before parse-job annotations can reference reusable grammar fragments cleanly, LinkedSpec
needs a neutral import/composition contract. The contract must not depend on Perl `use`,
Rust modules, filesystem quirks, or any backend-specific loader.

## Decision

Adopt this design contract before implementation:

1. File-scope directives are the public syntax:

   ```text
   import "common/atoms.spec" as atoms
   include "common/lifecycle.spec"
   ```

2. `import` loads another `.spec` under an explicit alias. Imported rules are referenced
   through a qualified name such as `atoms.Identifier`.
3. `include` composes another `.spec` into the current unqualified namespace. It is a
   structured merge of parsed spec material, not raw text concatenation.
4. Directives are grammar-composition declarations only. They do not execute a parser
   over runtime payload text; staged parse jobs remain the separate mechanism for that.
5. Resolution is deterministic: first resolve relative to the containing `.spec`, then
   through configured spec search roots or registry identities in declared order. A
   backend must project the same logical spec identity regardless of host language.
6. Names are language-neutral. Aliases and rule labels use the `.spec` identifier
   grammar; qualified references are `<alias>.<rule>`. The importer's own top rule
   remains the parser entry unless the caller explicitly selects another top rule.
7. Collisions are hard diagnostics. Duplicate aliases, duplicate local rule labels, an
   `include` that introduces an already-defined rule, or an ambiguous unqualified
   reference must fail before descriptor generation.
8. Cycles are hard diagnostics. The diagnostic must print the import/include chain and
   the repeated spec identity.
9. Source provenance is preserved across composition. Diagnostics for imported rules
   name both the importing spec and the original imported spec/span.
10. Cache keys and descriptor fingerprints include the normalized spec identity and a
    content digest of every composed spec in dependency order.

This is a design contract only until an implementation leaf lands. Current shipped
parsers do not yet accept `import` or `include` directives.

## Consequences

- `specs/spec.spec` must eventually grow file-scope directive nodes for `import` and
  `include`; the hardcoded bootstrap parser must not become their permanent grammar
  owner.
- Staged parse-job annotation design can reference reusable grammar material through
  aliases without overloading parse dispatch.
- Implementations in Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or future languages
  must share the same directive syntax, resolution order, namespace rules, cycle
  diagnostics, and descriptor fingerprint semantics.
- Future implementation should land before public examples present these directives as
  usable current syntax.

## Links

- Task tree: `docs/tasks/STAGED-LINKED-PARSING.md`
- Related: ADR `0012` staged linked parsing architecture, ADR `0011` text-to-AST
  backend doctrine, `specs/spec.spec`
