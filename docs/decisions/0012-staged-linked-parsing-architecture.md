# 0012 — Staged linked parsing is the core parser-composition architecture

- Date: 2026-07-02
- Status: accepted
- Tags: architecture, parser-composition, staged-parsing, spec-language, language-neutral, self-hosting

## Context

LinkedSpec has always favored practical extraction over a one-shot formal grammar. Many
real DSL inputs have obvious outer anchors and harder inner islands: the outer stage can
reliably find and extract the island text, while forcing the same grammar to fully parse
that island immediately would make the stage brittle.

The current user-function path shows the tension. Permanent `fn name(args) { ... }`
syntax belongs in `specs/spec.spec`, not in lasting bootstrap grammar. At the same time,
LinkedSpec already has enough mechanics to parse in stages: one spec can extract bounded
text, attach it to an AST node with provenance, and a later spec can parse that payload
into deeper structure.

Classic EBNF/PEG systems commonly require the whole file grammar to be described and
accepted in one up-front parser. LinkedSpec's identity is different: parse what is easy
and well-anchored now; carry explicit text islands forward; parse each island later with
the spec that actually owns that sublanguage.

## Decision

Adopt **staged linked parsing** as a core LinkedSpec architecture:

1. A stage-N `.spec` may emit AST nodes that contain raw extracted text payloads,
   source spans, payload kind, and parse intent.
2. Each extracted payload is a potential **parse job**. A parse job names a parser spec
   identity, optional top rule, source span, parent node path, and failure policy.
3. A stage may spawn zero, one, or many next-stage parse jobs. Stage N is not required to
   map to a single stage-N+1 spec; different extracted payload kinds may route to
   different next-stage specs.
4. The staged parse relation forms a deterministic parse graph. Results are stitched
   back into the parent AST with provenance preserved.
5. **Spec imports/composition** and **staged parse dispatch** are separate features:
   imports compose grammar/spec files; staged dispatch parses runtime payload text carried
   by AST nodes.
6. For `.spec` language evolution, `specs/spec.spec` is the first authoritative grammar.
   New permanent `.spec` syntax derives from that self-hosted grammar path. Hardcoded
   bootstrap support is temporary migration debt unless explicitly authorized otherwise.
7. The architecture is **implementation-language neutral**. It is a contract over
   `.spec`, AST nodes, parse jobs, descriptors, diagnostics, and runtime parser entry
   points. Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or any future implementation
   must implement the same neutral semantics rather than rely on host-language-specific
   parser behavior.

## Consequences

- Future staged parsing implementation must define parse-job metadata before code:
  parser spec id, top rule, source text/span, parent AST path, result insertion policy,
  and failure behavior.
- Dynamic parser loading is an intended capability, but it must be deterministic:
  resolution, cache keys, version boundaries, and cycle diagnostics must be specified.
- `specs/spec.spec` remains the permanent `.spec` grammar owner. User-defined functions
  and future `.spec` syntax must not drift into a competing bootstrap grammar.
- Backend handoff documentation must treat staged parsing as a language-neutral contract.
  The Perl reference may provide bridges, but bridges are not the language contract.
- Implementation must keep diagnostics source-aware across stages. A stage-N+1 failure
  must report the parent node, payload kind, selected next spec/top rule, and original
  source span.

## Current implementation note (2026-08-25)

The first narrow function-body parse-job family is current on Perl, Rust, Dart, Julia,
PUC Lua, and LuaJIT. It preserves exact body text plus its legacy numeric span, dispatches
one stable queue depth through the built-in `actionir-body.spec` / `action_block` adapter,
and stitches `body_ast`. General authored `parse_job(...)`, typed direct/derived source
provenance, several parser families, complete policy semantics, and recursive queues remain absent from shipped
backends. `FUTURE-PARITY-BACKLOG.14.7.2` and ADR `0088` now make their exact neutral target executable before
backend behavior: pre-resolved immutable authority, typed provenance, breadth-first queues, all result/failure
policies, bounded recursive chains, detached results, and portable diagnostics. The prototype remains evidence for
this decision, not completion of the whole architecture.

## Links

- Task tree: `docs/tasks/STAGED-LINKED-PARSING.md`
- Related: ADR `0014` staged parse-job annotation contract, ADR `0013` spec
  import/composition contract, ADR `0011` text-to-AST backend doctrine, ADR `0006`
  multi-backend vision, ADR `0007` terse `.spec` format direction
