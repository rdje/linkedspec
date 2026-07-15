# 0040 - Backend implementation details live in linked companion books

- Date: 2026-07-15
- Status: accepted direction; implementation dependency-gated
- Tags: documentation, mdbook, backends, architecture, public-api, maintenance, drift

## Context

LinkedSpec's public mdBook is intentionally backend-neutral: it defines the universal `.spec` language, portable
behavior, shared AST/runtime contracts, and the cross-backend product. As the five implementations mature, that
book also accumulates useful host-specific facts about native APIs, runtime/ABI choices, loading, embedding,
tracing, generated artifacts, performance, and troubleshooting. Those details help users of one backend but can
obscure the portable contract and do not belong as normative language documentation.

The director proposed maintaining separate backend-variant books in addition to the common neutral book. Five
fully copied manuals would create severe drift and six competing sources of truth, while keeping every
implementation detail in one book makes the neutral product harder to navigate.

## Decision

1. **Keep one normative neutral book.** It is the sole owner of `.spec`/ActionIR semantics, portable values,
   parser/runtime behavior, AST and diagnostic contracts, conformance policy, and backend-neutral examples.
2. **Add five implementation companions.** Perl, Rust, Dart, Julia, and Lua each receive an independently buildable
   mdBook for user-relevant host-specific implementation and embedding material.
3. **Companions explain how, not what.** They may document setup/toolchains/ABIs, idiomatic APIs and types,
   frontend/compiler/runtime/staged/loading architecture, trace/debug workflows, generated/native artifacts,
   performance/caching/deployment, troubleshooting, and precise variant limitations.
4. **Link instead of copy.** Every companion topic links to its canonical neutral semantic owner. Shared normative
   prose is not duplicated. Generated includes are permissible only when they preserve one tracked source.
5. **Keep ordinary users in the neutral book.** Portable concepts and common workflows stay self-contained there;
   a companion is optional reading for choosing, embedding, operating, or understanding a specific backend.
6. **Gate structure and drift before migration.** Independent builds, navigation, canonical-owner metadata, and
   a registered check for forbidden copied normative material precede population of the five books.
7. **Do not interrupt backend parity.** `BACKEND-COMPANION-BOOKS.1+` remains dependency-gated until the current
   Perl/Rust/Dart/Julia/Lua parity program is complete. Existing docs must stay accurate meanwhile.

## Consequences

- The neutral book becomes clearer without losing implementation guidance.
- Variant users gain deeper idiomatic API, deployment, performance, and debugging documentation.
- Maintaining six books is accepted only with a shared template, explicit routing rules, and mechanical gates.
- Existing backend-specific passages are not moved opportunistically; `.1` first classifies retain/move/link/remove
  ownership page by page.
- No book scaffold, content migration, parser/runtime behavior, or current documentation path changes in the
  adoption slice.

## Links

- Detailed tree: `docs/tasks/BACKEND-COMPANION-BOOKS.md`
- Neutral book: `docs/linkedspec-book/`
- Backend parity order: ADR `0021`
- Native embedding contract: ADR `0022`
- Documentation/task doctrine: ADR `0001`
