# 0035 - Universal `.spec` authoring is terse, readable, and highly expressive

- Date: 2026-07-15
- Status: accepted
- Tags: dsl, language-evolution, authoring, terseness, readability, expressiveness, composition, diagnostics

## Context

ADR `0007` adopted LinkedSpec's terse language direction and the completed `SPEC-FORMAT-TERSE` program removed
substantial declaration, wrapper, helper-name, and punctuation ceremony. ADR `0034` now makes 91 real Unicode
structured-text formats the post-parity requirements generator for future `.spec` evolution. Those formats will
pressure the language with substantially harder tokenizer, tree-construction, recovery, context, Unicode, and AST
requirements.

The director therefore made the authoring-quality objective explicit: `.spec` files must be terse, yet readable
and highly expressive. This needs a durable meaning. Without one, “terse” could be misread as minimizing character
count even when a longer name carries essential semantics, while “expressive” could be misread as permission for
format-specific shortcuts or opaque host-language escapes.

The already-landed uniform-binding design is the positive precedent. One identifier exposes one value that may be
scalar, array, harray, or codeblock; runtime kind controls valid dispatch; an incompatible mutation fails with a
typed diagnostic. The author does not select backend storage or a parallel aggregate namespace, and the runtime
does not silently coerce a wrong kind. That surface is concise because one orthogonal abstraction carries the
meaning, not because the meaning was omitted.

## Decision

1. **Treat terseness, readability, and expressiveness as one acceptance constraint.** A new `.spec` feature is
   not well designed if it improves one by materially sacrificing the other two.
2. **Define terseness as absence of redundant ceremony.** Prefer canonical forms, inferred information that is
   already unambiguous, uniform composition, and reusable defaults. Do not optimize raw character count by
   deleting semantic distinctions, weakening diagnostics, introducing context-sensitive surprises, or requiring
   external knowledge to read a rule.
3. **Preserve informative names.** Names should be as short as their exact semantics allow. In particular,
   `walk_leaves`, `map_leaves`, and `reduce_leaves` remain canonical. Their `_leaves` suffix distinguishes recursive
   root-kind traversal from conventional shallow `walk`, `map`, or `reduce`; the shorter aliases are not adopted
   and require no implementation audit.
4. **Define readability as local predictability.** A reader should be able to identify structure, evaluation
   order, value flow, mutation, recovery, and scope from the `.spec` source and its documented language contract.
   Equivalent concepts use equivalent syntax; distinct concepts stay visibly distinct. Failures remain typed,
   source-aware, and specific.
5. **Define expressiveness through small orthogonal mechanisms.** Prefer a compact set of typed primitives that
   compose across rules, values, blocks, imports, and staged parsers. Do not add a format-named special case when a
   reusable parsing mechanism exists, and do not hide the hard part in a host callback or backend-only dialect.
6. **Use uniform binding as the design precedent.** One binding surface plus runtime-kind dispatch and typed
   wrong-kind failure is preferable to type-selector syntax or implicit coercion. This is a precedent for future
   designs, not permission to collapse distinctions whose runtime meaning differs.
7. **Make real representative specs the authoring proof.** Future language-feature leaves must show the proposed
   form in realistic format excerpts, include invalid/ambiguous boundaries, and explain why it reduces repeated
   authoring structure while preserving local meaning. The post-parity format program may reject a technically
   capable primitive if it makes the resulting specs opaque or needlessly repetitive.
8. **Keep behavior claims exact.** This decision changes design governance only. It does not add syntax, aliases,
   parser/compiler/runtime behavior, format support, or a new backend.

## Consequences

- `STRUCTURED-TEXT-FORMAT-PROGRAM` gains an authoring-quality invariant and every later format/feature leaf must
  demonstrate concise, readable composition as well as conformance and performance.
- “Terse” cannot justify ambiguous punctuation, hidden coercion, or the loss of a semantic suffix. A few more
  characters are correct when they prevent a reader from confusing recursive and shallow behavior.
- “Expressive” cannot justify accumulating format-specific built-ins. Format pressure is translated into the
  smallest reusable neutral mechanism and rolled out across all current backends before use.
- Uniform binding remains a concrete example of the desired trade: fewer author-facing concepts, more uniform
  composition, and stricter typed failure.
- Detailed future mutation and nested-write semantics need their own task-tree owner and contract; this decision
  does not silently adopt autovivification or receiver-mutating `!` methods.

## Links

- Owning leaf: `docs/tasks/FUTURE-PARITY-BACKLOG.md` `.18.1`
- Structured-format program: `docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md`
- Terse direction: ADR `0007`
- Post-parity format program: ADR `0034`
- Uniform-binding fact: `docs/knowledge/uniform-binding-neutral-contract.md`
