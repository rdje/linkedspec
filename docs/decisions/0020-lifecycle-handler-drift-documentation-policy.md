# 0020 - Lifecycle handler-shape drift is documented caveat until separately owned implementation

- Date: 2026-07-08
- Status: accepted
- Tags: lifecycle, perl-reference, generated-handlers, documentation, parity

## Context

`SPEC-LANG-REFERENCE.10.5.9` found a current Perl reference handler-shape drift while
fixing lifecycle examples in the mdBook. Focused `LinkedSpec::Get` and
`dump_parser_source` probes showed two related behaviors:

1. A lifecycle block that omits explicit `return(...)` can expose the host-language
   value of its final statement in some generated handler shapes.
2. A direct default-rule shape such as `Top::` plus `I`, a regex slot, and `E { ... }`
   can emit generated source containing only the `I` body; the regex and `E` finalizer
   path are absent from that generated handler.

The portable lifecycle contract remains statement-oriented: lifecycle blocks are not
expression-valued, and public examples should use explicit `return(...)` when a rule or
action is meant to produce a value. Rust tests model that intended statement-block
contract, while the current Perl reference still has legacy generated-handler shapes.

## Decision

Treat this as a documented current Perl-reference caveat in the language-reference closeout,
not as an implicit authorization to change the Perl engine inside
`SPEC-LANG-REFERENCE.10.5.20`.

1. Public mdBook examples must avoid relying on final-statement leakage.
2. Public mdBook examples must avoid presenting direct default-rule `E { ... }`
   finalization as universally reliable on the current Perl reference.
3. Use explicit `return(...)` for lifecycle-produced values.
4. Any behavior change to normalize Perl lifecycle final-value/direct-`E` handling
   requires a separate implementation task-tree leaf with focused Perl evidence,
   regression locks, cross-variant parity review, and updated docs/Knowledge Map.
5. Until that implementation owner exists, the Perl reference remains untouched and the
   caveat is part of the documented current-backend behavior.

## Consequences

- `SPEC-LANG-REFERENCE.10.5.20` can close as a documentation/decision slice.
- The language reference stays truthful: it teaches the portable authoring style and
  names the Perl caveat instead of implying current handler shapes are all equivalent.
- Future work can still choose to fix the Perl generated-handler behavior, but it must
  be owned explicitly rather than smuggled into a book closeout.

## Links

- Task tree: `docs/tasks/SPEC-LANG-REFERENCE.md` (`SPEC-LANG-REFERENCE.10.5.20`)
- Knowledge: `docs/knowledge/perl-lifecycle-final-value-e-drift.md`
- Related: ADR `0008` reference-engine defect-fix authorization; ADR `0010` top-rule
  engine exception and parity requirements
