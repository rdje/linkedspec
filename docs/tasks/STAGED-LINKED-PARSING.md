# STAGED-LINKED-PARSING: Staged linked parse graph architecture

## Metadata

- Tree ID: `STAGED-LINKED-PARSING`
- Status: `active`
- Roadmap lane: `Overall roadmap — .spec language model / parser composition`
- Created: `2026-07-02`
- Last updated: `2026-07-02`
- Owner: repo-local workflow

## Goal

Make LinkedSpec's staged parser-composition model explicit and executable: a
stage-N `.spec` may parse only the structure that is easy to anchor, emit raw
text islands with source provenance, and route each island to one or more
next-stage `.spec` parsers that refine those payloads into deeper AST nodes.

## Non-Goals

- Do not add runtime parser-dispatch implementation in the first leaf.
- Do not add a permanent user-function grammar to the bootstrap parser.
- Do not replace the current user-function MVP surface.
- Do not conflate spec-file inclusion/composition with staged payload parsing.

## Acceptance Criteria

- The staged linked parsing doctrine is recorded as a durable decision.
- The task tree distinguishes spec imports/composition from staged parse
  dispatch.
- The public mdBook explains that `spec.spec` is the first loaded grammar for
  `.spec` language evolution and that later parsers derive from extracted
  payloads, not competing bootstrap grammar.
- Follow-up leaves are named for implementation planning: spec imports,
  parse-job annotations/metadata, parser registry/dispatch, and diagnostics.
- Live docs, roadmap, Knowledge Map, and memory are updated.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `STAGED-LINKED-PARSING`
  Status: `active`
  Goal: Adopt and then implement staged linked parsing as a first-class
    LinkedSpec architecture.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `STAGED-LINKED-PARSING.1`
  Status: `done`
  Goal: Adopt the staged linked parsing doctrine before implementation.
  Acceptance: Add ADR, task-tree index, mdBook architecture text, Knowledge
    Map fact, live-doc/roadmap/memory updates, and future-leaf split.
  Verification: **DONE 2026-07-02.** Added ADR `0012`, task-tree index row,
    roadmap/live-doc/memory entries, mdBook overview/design-rationale/pipeline
    and backend-handoff updates, and Knowledge Map fact
    `staged-linked-parsing-architecture`. Checks passed: `mdbook build
    docs/linkedspec-book`, `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1015 green).
  Commit: `STAGED-LINKED-PARSING.1 - adopt staged linked parsing doctrine`

- ID: `STAGED-LINKED-PARSING.2`
  Status: `done`
  Goal: Design spec-file imports/composition.
  Acceptance: Define import/include semantics, naming, dependency resolution,
    cycle diagnostics, and public syntax before code.
  Verification: **DONE 2026-07-02.** Added ADR `0013` for the
    language-neutral import/composition contract: future file-scope
    `import "path.spec" as alias` and `include "path.spec"` directives,
    qualified imported references, structured include merges, deterministic
    resolution, source-aware diagnostics, cycle/collision errors, descriptor
    fingerprinting, and an explicit not-yet-implemented status. Updated the
    mdBook, roadmap/live docs, task index, and Knowledge Map. Checks passed:
    `mdbook build docs/linkedspec-book`,
    `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1015 green).
  Commit: `STAGED-LINKED-PARSING.2 - specify spec import composition contract`

- ID: `STAGED-LINKED-PARSING.3`
  Status: `pending`
  Goal: Design staged parse-job annotations and AST payload metadata.
  Acceptance: Define how a rule/action marks extracted text as a parse job,
    including node kind, parser spec id, top rule, source span, and failure
    policy.
  Verification: `pending`
  Commit: `pending`

- ID: `STAGED-LINKED-PARSING.4`
  Status: `pending`
  Goal: Design parser registry and dynamic next-stage dispatch.
  Acceptance: Define deterministic parser lookup/loading, cache keys, version
    boundaries, and how multiple payload kinds in one stage route to different
    next-stage specs.
  Verification: `pending`
  Commit: `pending`

- ID: `STAGED-LINKED-PARSING.5`
  Status: `pending`
  Goal: Implement the first narrow staged-parsing prototype.
  Acceptance: Pick one self-contained payload family, parse it through a
    staged next-spec path, preserve source provenance, and prove diagnostics
    plus parity gates.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `STAGED-LINKED-PARSING.3` | `pending` | Parse-job annotations can now reference the import/composition namespace boundary without conflating grammar reuse and runtime payload parsing. |

## Decisions

- `2026-07-02`: A LinkedSpec parse is allowed to be a staged graph rather than
  one monolithic grammar. Stage N may emit extracted text islands that later
  stages parse with one or more different specs.
- `2026-07-02`: Spec imports/composition and staged parse dispatch are separate
  features. Imports compose grammar/spec files; staged dispatch parses runtime
  payload text carried by AST nodes.
- `2026-07-02`: For `.spec` language evolution, `specs/spec.spec` is the first
  authoritative grammar. Permanent syntax such as user-defined functions must
  derive from that self-hosted grammar path, not from lasting bootstrap grammar.
- `2026-07-02`: Spec-file composition will use future file-scope directives:
  `import "path.spec" as alias` for qualified references and
  `include "path.spec"` for structured unqualified composition. This is
  grammar material reuse, not staged runtime payload parsing. Current shipped
  parsers do not yet accept those directives.

## Open Questions

- Exact authoring syntax for staged parse annotations is deferred to `.3`.
- Whether staged parse jobs are declared only in `.spec` metadata or may also
  be produced by portable action helpers is deferred to `.3`.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-02` | `STAGED-LINKED-PARSING.1` | `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — mdBook builds; Knowledge Map is in sync; memory/doctrine/diff gates pass; full local CI passes with phase0 1015 green. |
| `2026-07-02` | `STAGED-LINKED-PARSING.2` | `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — mdBook builds; Knowledge Map is in sync; memory/doctrine/diff gates pass; full local CI passes with phase0 1015 green. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `STAGED-LINKED-PARSING.1` | `STAGED-LINKED-PARSING.1 - adopt staged linked parsing doctrine` | ADR/book/KM/live-doc architecture adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.2` | `STAGED-LINKED-PARSING.2 - specify spec import composition contract` | ADR/book/KM/live-doc design adoption; no runtime code change. |

## Changelog

- `2026-07-02`: `.1` done — staged linked parsing adopted as language-neutral doctrine; frontier moves to `.2`.
- `2026-07-02`: `.2` done — spec import/composition contract specified before implementation; frontier moves to `.3`.
