# 0016 — Staged parsing artifacts remain implementation-language neutral

- Date: 2026-07-02
- Status: accepted
- Tags: architecture, staged-parsing, portability, language-neutral, backends

## Context

ADRs `0012` through `0015` adopt staged linked parsing, spec-file composition,
parse-job metadata, and deterministic parser registry dispatch. The project also
targets several implementation languages: Perl5, Raku, Rust, Julia, Lua, Dart,
Zig, Go, and future backends.

The user clarified that every part of this architecture must be 100%
implementation-language neutral. The first prototype may be built through an existing
implementation path, but that implementation must not become the language contract.

## Decision

Every staged linked parsing artifact is defined in implementation-language-neutral
terms:

1. Authoring syntax is `.spec` syntax, not Perl5, Raku, Rust, Julia, Lua, Dart, Zig,
   Go, or any other host-language syntax.
2. AST shape, parse-job metadata, source provenance, result policies, failure policies,
   cache identities, registry operations, and diagnostics are specified as neutral data
   and behavior.
3. Backend-specific loaders, module systems, callback APIs, memory models, error types,
   and parser internals are adapters only. They may prove a slice, but they do not define
   observable semantics.
4. A prototype may land in one implementation first only when its task-tree acceptance
   also records the neutral contract and the follow-up parity path.
5. User-facing mdBook text describes neutral behavior first. It may mention the current
   implementation status, but it must not present one backend's mechanics as the model.
6. Tests for staged parsing should use language-neutral fixtures or assertions wherever
   possible, so future backends can validate the same contract without inheriting one
   host implementation.

## Consequences

- Each staged linked parsing implementation leaf must name the neutral contract it is
  proving before code changes.
- A backend-specific shortcut is acceptable only as temporary bridge debt when the task
  tree records how the neutral contract will replace or hide it.
- Diagnostics must remain portable: messages can include backend implementation context
  when useful, but required diagnostic fields are the neutral staged fields from ADRs
  `0014` and `0015`.
- Documentation, Knowledge Map cards, and roadmap entries must use backend-neutral
  vocabulary for staged parsing. Perl/Rust examples are evidence, not doctrine.

## Links

- Task tree: `docs/tasks/STAGED-LINKED-PARSING.md`
- Related: ADR `0012` staged linked parsing architecture, ADR `0013` spec
  import/composition contract, ADR `0014` staged parse-job annotation contract,
  ADR `0015` staged parser registry/dispatch contract, ADR `0006` multi-backend
  vision, ADR `0011` text-to-AST backend doctrine
