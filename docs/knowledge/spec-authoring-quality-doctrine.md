---
id: spec-authoring-quality-doctrine
title: Terse spec authoring removes ceremony but preserves semantic signal
answers:
  - what does terse mean for LinkedSpec spec files
  - must spec files be readable as well as concise
  - what does highly expressive mean for the spec language
  - is shortest syntax always preferred in LinkedSpec
  - why are walk_leaves map_leaves and reduce_leaves not shortened
  - will LinkedSpec add walk map and reduce aliases
  - why is uniform binding a good spec language precedent
  - how will real formats evaluate future spec syntax quality
date: 2026-07-15
status: current
tags: [dsl, authoring, terseness, readability, expressiveness, composition, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "Director/engineer agreement on 2026-07-15; ADR 0035; FUTURE-PARITY-BACKLOG.18.1; structured-format Program Invariant 10; public structured-format architecture chapter. The planning slice adds no syntax, alias, parser/compiler/runtime behavior, backend, or format support."
reverify: "rg -n 'redundant ceremony|semantic signal|walk_leaves|uniform binding|representative format' docs/decisions/0035-terse-readable-expressive-spec-authoring.md docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md docs/linkedspec-book/src/architecture/structured-format-program.md"
---

# Spec authoring quality doctrine

LinkedSpec treats **terse**, **readable**, and **highly expressive** as one design constraint. Terseness means
removing redundant declarations, wrappers, punctuation, and repeated structure when the omitted information is
already unambiguous. It does not mean minimizing character count at the expense of meaning, diagnostic precision,
or predictable parsing.

Readability keeps structure, value flow, evaluation order, mutation, scope, and recovery locally visible in the
`.spec` source and documented language contract. Expressiveness comes from a small set of typed, orthogonal
mechanisms that compose across rules, values, codeblocks, imports, and staged parsers. Format-specific built-ins,
backend-only dialects, and opaque host callbacks do not satisfy that goal.

The current uniform-binding contract is the positive precedent: one identifier holds a scalar, array, harray, or
codeblock; runtime kind selects valid operations; an incompatible mutation produces a typed error. The author gets
one concise abstraction without hidden coercion or a parallel host-storage namespace.

Semantic words remain when they disambiguate behavior. `walk_leaves`, `map_leaves`, and `reduce_leaves` recurse
through leaves according to the receiver's root kind. Their `_leaves` suffix distinguishes that contract from the
conventional shallow meaning of plain `walk`, `map`, or `reduce`. The shorter aliases are therefore not adopted
and no implementation audit is required for them.

Future format-driven language proposals must include representative `.spec` excerpts and invalid or ambiguous
boundaries. A mechanism is acceptable only if it expresses the required format behavior accurately while keeping
the resulting sole-source spec compact and understandable.

## Links

- Decision: ADR `0035`.
- Owner: [[FUTURE-PARITY-BACKLOG]] `.18.1`.
- Program: [[STRUCTURED-TEXT-FORMAT-PROGRAM]].
- Precedent: [[uniform-binding-neutral-contract]].
