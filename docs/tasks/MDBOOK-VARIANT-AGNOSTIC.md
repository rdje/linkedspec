# MDBOOK-VARIANT-AGNOSTIC: Audit and Remediate mdBook for Variant-Agnostic Language

## Metadata

- Tree ID: `MDBOOK-VARIANT-AGNOSTIC`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-16`
- Last updated: `2026-06-16`
- Owner: repo-local workflow

## Goal

Make the mdBook (`docs/linkedspec-book/src/`) variant-agnostic: describe LinkedSpec concepts,
DSL syntax, semantics, and helper contracts in language-neutral terms that apply equally to
all backend variants (Perl, Rust, Julia, Dart, …). Implementation-specific details are
minimized in user-facing chapters and clearly labeled when present.

## Non-Goals

- Rewriting the book from scratch
- Removing all mention of Perl — the Perl implementation is the reference and architecture
  chapters legitimately reference it
- Changing the repo's internal continuity docs (CHANGES.md, DEVELOPMENT_NOTES.md, etc.)
- Adding new technical content — this is about language framing, not new features

## Acceptance Criteria

- User-facing overview chapters (what-is-linkedspec, design-rationale, project-status)
  describe LinkedSpec as a multi-backend system with Perl as reference implementation
- User-model chapters (spec-files, rule-paragraphs, etc.) use `.spec` DSL syntax examples
  without implying a single backend
- DSL chapters describe helper contracts and semantics in backend-neutral terms
- Public API chapters acknowledge Perl API while framing it as one backend's surface
- Architecture chapters remain accurate about the Perl owner tree while distinguishing
  between "Perl implementation detail" and "LinkedSpec concept"
- Book builds cleanly (mdBook build succeeds)
- Live docs updated (CHANGES.md, ROADMAP_V2.md, MEMORY.md)
- Each completed leaf committed through `COMMIT.md`

## Task Tree

- ID: `MDBOOK-VARIANT-AGNOSTIC`
  Status: `active`
  Goal: Audit and remediate mdBook for variant-agnostic language
  Children: `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `MDBOOK-VARIANT-AGNOSTIC.1`
  Status: `pending`
  Goal: Complete audit — catalog every Perl-centric sentence, paragraph, and section across all 27 source files
  Acceptance: Audit document listing each file, the Perl-specific passages, and a recommended remediation for each
  Verification: `pending`
  Commit: `pending`

- ID: `MDBOOK-VARIANT-AGNOSTIC.2`
  Status: `pending`
  Goal: Remediate overview chapters — index.md, what-is-linkedspec.md, design-rationale.md, documentation-layers.md, project-status.md
  Acceptance: Overview chapters rewritten to be variant-agnostic; Perl framed as reference implementation
  Verification: `pending`
  Commit: `pending`

- ID: `MDBOOK-VARIANT-AGNOSTIC.3`
  Status: `pending`
  Goal: Remediate user-model chapters — spec-files-and-rule-paragraphs.md, worked-spec-walkthrough.md, rule-modes-and-parse-modes.md, blind-calls-and-parser-orchestration.md, runtime-context-and-tracing.md
  Acceptance: User-model chapters use .spec DSL syntax, not Perl API calls, as primary examples
  Verification: `pending`
  Commit: `pending`

- ID: `MDBOOK-VARIANT-AGNOSTIC.4`
  Status: `pending`
  Goal: Remediate public API chapters — get-and-get-parser.md, descriptor-introspection.md, trace-api.md, plugin-registry.md
  Acceptance: API chapters clearly label Perl as one backend; mention Rust API entry points where applicable
  Verification: `pending`
  Commit: `pending`

- ID: `MDBOOK-VARIANT-AGNOSTIC.5`
  Status: `pending`
  Goal: Remediate DSL and compiler/architecture chapters — action-model, lowering, helpers, pipeline, state-model, handlers, diagnostics, owner-tree
  Acceptance: DSL chapters use backend-neutral contract language; architecture chapters distinguish concept from Perl implementation
  Verification: `pending`
  Commit: `pending`

- ID: `MDBOOK-VARIANT-AGNOSTIC.6`
  Status: `pending`
  Goal: Remediate appendix, specs-and-corpora, and development chapters
  Acceptance: Appendix and walkthrough chapters framed for multi-backend readers; development chapters explain Perl is reference
  Verification: `pending`
  Commit: `pending`

- ID: `MDBOOK-VARIANT-AGNOSTIC.7`
  Status: `pending`
  Goal: Final verification — build book, cross-check all chapters, update live docs
  Acceptance: mdBook build succeeds; cross-chapter consistency verified; ROADMAP_V2.md, CHANGES.md, MEMORY.md updated
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `MDBOOK-VARIANT-AGNOSTIC.1` | `pending` | Audit first — must know exact scope before editing |
| 2 | `MDBOOK-VARIANT-AGNOSTIC.2` | `pending` | Overview is the reader's first impression |
| 3 | `MDBOOK-VARIANT-AGNOSTIC.3` | `pending` | User-model is where most readers learn LinkedSpec |
| 4 | `MDBOOK-VARIANT-AGNOSTIC.4` | `pending` | API chapters need backend labeling |
| 5 | `MDBOOK-VARIANT-AGNOSTIC.5` | `pending` | DSL/compiler chapters are the deepest content |
| 6 | `MDBOOK-VARIANT-AGNOSTIC.6` | `pending` | Appendix and walkthroughs |
| 7 | `MDBOOK-VARIANT-AGNOSTIC.7` | `pending` | Final verification and docs sync |

## Decisions

- `2026-06-16`: Created task tree. Audit-first approach to avoid piecemeal edits that create inconsistency. Overview chapters prioritized because they set the reader's mental frame.

## Open Questions

- None yet — audit leaf will identify any.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `pending` | `MDBOOK-VARIANT-AGNOSTIC.1` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `pending` | `pending` | `pending` |

## Changelog

- `2026-06-16`: Created task tree.
