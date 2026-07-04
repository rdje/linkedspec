# 0018 - Declaration helpers remain legacy compatibility after the terse migration

- Date: 2026-07-04
- Status: accepted
- Tags: dsl, compatibility, spec-format-terse, declaration, migration

## Context

`SPEC-FORMAT-TERSE.6` migrated live `.spec` authoring away from `declare(...)`.
Shipped specs no longer use active declaration helpers, current-facing examples now
prefer auto-existing variables and terse assignment/mutation forms, and the root
corpus no longer teaches declaration helpers as normal authoring syntax.

The implementation still has compatibility behavior that existing specs can depend on:
the Perl reference lowers declaration helpers to per-invocation working variables, and
the Rust runtime/oracle corpus keeps declare/no-declare convergence fixtures such as
`autoexist_scalar_declare` and `autoexist_array_declare`. Removing those helpers now
would turn a source migration into a compatibility break and would also remove useful
regression evidence that auto-existing variables match the old explicit form.

## Decision

Keep declaration helper support as legacy compatibility:

1. `declare(...)` and its declaration aliases remain accepted compatibility syntax for
   existing specs.
2. They are not part of the current authoring surface. New shipped specs, public
   examples, and current corpus examples must use terse replacements such as
   `name = value`, `items = []`, `meta = { ... }`, `items += value`,
   `meta[key] = value`, `set(...)`, typed wrappers, and `:name`.
3. Compatibility support must not be expanded into new declaration features. New
   language work should use the terse surface.
4. Any future removal or diagnostic hardening requires a separate focused task-tree
   leaf and must update Perl, Rust, oracle fixtures, mdBook, and Knowledge Map in one
   locked slice.
5. Documentation may keep declaration examples only in explicit legacy/reference
   sections that point to the terse replacements.

## Consequences

- `SPEC-FORMAT-TERSE.6` can close without code removal.
- Existing legacy specs keep compiling while users are directed to the terse surface.
- The declare/no-declare oracle fixtures remain useful compatibility locks.
- Drift checks should classify declaration helper hits by location: no active shipped
  specs or current-facing examples; legacy/reference docs and compatibility fixtures
  are intentional.

## Links

- Task tree: `docs/tasks/SPEC-FORMAT-TERSE.md` (`SPEC-FORMAT-TERSE.6.4`)
- Related: ADR `0007` terse format direction, ADR `0003` raw-Perl-free spec authoring
