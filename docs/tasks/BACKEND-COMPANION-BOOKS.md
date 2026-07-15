# BACKEND-COMPANION-BOOKS: Variant Implementation Guides

## Metadata

- Tree ID: `BACKEND-COMPANION-BOOKS`
- Status: `proposed` (implementation dependency-gated on full current-backend parity)
- Roadmap lane: `Documentation architecture - backend implementation companions`
- Created: `2026-07-15`
- Last updated: `2026-07-15` (architecture adoption `.0` complete; inventory `.1` dependency-gated)
- Owner: repo-local workflow

## Goal

Maintain one canonical backend-neutral mdBook for LinkedSpec semantics and portable behavior, plus one linked
implementation companion for each current backend: Perl, Rust, Dart, Julia, and Lua. A companion documents
user-relevant host-specific facts that do not belong in the neutral book without duplicating the language contract.

## Non-Goals

- Do not fork `.spec` syntax, helper semantics, AST contracts, portable diagnostics, or conformance policy by book.
- Do not copy neutral chapters into five repositories of prose.
- Do not turn internal source tours with no user value into public documentation.
- Do not interrupt the current backend-parity program to scaffold unstable companion content.
- Do not replace task-trees, Knowledge Map cards, decision records, or live continuity docs with a book.

## Content-Routing Invariants

The neutral book remains the sole normative home for:

1. `.spec` and ActionIR language semantics;
2. portable parser/runtime behavior and value contracts;
3. cross-backend conformance, capability, and compatibility policy;
4. backend-neutral public concepts and examples; and
5. the shared roadmap-level product story.

Each companion may own only user-relevant backend-specific material:

1. installation, supported runtime/toolchain/ABI targets, packaging, and native dependencies;
2. idiomatic host-language APIs, embedding patterns, types, errors, and lifecycle;
3. how the variant implements frontend/compiler/runtime/staging/loading/trace/code generation;
4. backend-specific performance, caching, threading/reentrancy, memory, and deployment guidance;
5. generated/native artifacts, inspection/debugging workflows, and troubleshooting;
6. precise backend-specific limitations or temporary parity boundaries; and
7. worked host-language examples that link to, rather than restate, the neutral semantic contract.

When a topic contains both layers, the neutral book defines what; the companion explains how that backend exposes
or implements it. Every companion page links to its canonical neutral owner. The neutral book links back only when
the variant detail materially helps a user choose or embed a backend.

## Shared Leaf Acceptance

Every implementation leaf must:

1. have an owning task-tree leaf before edits;
2. classify moved/linked/retained content explicitly;
3. build the neutral book and every affected companion;
4. preserve one normative semantic owner and reject copied normative prose;
5. update the relevant backend slice and companion together when user-visible variant behavior changes;
6. add navigation from the neutral book and backend README without making a companion required reading for
   portable semantics; and
7. update live docs, Knowledge Map, task/index, and commit history.

## Task Tree

- ID: `BACKEND-COMPANION-BOOKS`
  Status: `proposed`
  Goal: Deliver governed backend-specific implementation companions around one canonical neutral mdBook.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`
  Acceptance: All five companions build, route content by the invariant above, cross-link the canonical book, and
    have automated structure/drift checks without duplicating portable semantics.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-COMPANION-BOOKS.0`
  Status: `done`
  Goal: Adopt the companion-book architecture and dependency-correct rollout before implementation.
  Dependencies: none
  Acceptance: Record the user proposal, canonical-versus-companion boundary, five-book scope, parity dependency,
    implementation leaves, drift risks, and one unambiguous future frontier in task/index/roadmaps/ADR/KM/live
    docs; make no book scaffold or content migration.
  Verification: **PASS 2026-07-15.** User proposal, current neutral-book/backend-README layout, and parity sequence
    were reviewed. ADR `0040`, the detailed tree, parent backlog `.21`, task index, roadmaps, live docs, public
    project-status page, and Knowledge Map agree on one normative neutral owner, five optional implementation
    companions, precise content routing, parity dependency, read-only inventory first, shared scaffold/build/link/
    canonical-owner/drift gates before migration, and no scaffold/content move now. Memory architecture, task
    metadata, Knowledge Map, doctrines, mdBook, and whitespace checks pass.
  Commit: `FUTURE-PARITY-BACKLOG.21.0 - plan backend companion books`

- ID: `BACKEND-COMPANION-BOOKS.1`
  Status: `pending`
  Goal: Inventory and classify current backend-specific content in the neutral book and backend READMEs.
  Dependencies: `.0`, complete current Perl/Rust/Dart/Julia/Lua parity
  Acceptance: Produce a page-level retain/move/link/remove map; identify normative mixed-layer passages and one
    canonical owner for each; measure duplication before migration; make no content move in this leaf.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-COMPANION-BOOKS.2`
  Status: `pending`
  Goal: Add the shared companion template, independent builds, navigation, and mechanical governance.
  Dependencies: `.1`
  Acceptance: Define identical top-level information architecture with backend-owned optional sections; scaffold
    five independently buildable mdBooks; add neutral/companion cross-links; add registered checks for summary,
    build, canonical-owner metadata, and forbidden copied normative sections.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-COMPANION-BOOKS.3`
  Status: `pending`
  Goal: Populate the Perl reference-backend companion.
  Dependencies: `.2`
  Acceptance: Document reference embedding, loader compatibility boundary, generated source, tracing/debugging,
    runtime/tooling choices, performance/deployment notes, and limitations without restating neutral semantics.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-COMPANION-BOOKS.4`
  Status: `pending`
  Goal: Populate the Rust backend companion.
  Dependencies: `.2`
  Acceptance: Document crates/types/embedding, interpreted runtime, native loading, diagnostics/trace, generated
    source, toolchain/build/deployment, performance, and manual-only mutation campaign routing.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-COMPANION-BOOKS.5`
  Status: `pending`
  Goal: Populate the Dart backend companion.
  Dependencies: `.2`
  Acceptance: Document package APIs/types/embedding, loading, runtime/trace, generated source, Dart toolchain and
    deployment surfaces, performance, and exact backend-specific boundaries.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-COMPANION-BOOKS.6`
  Status: `pending`
  Goal: Populate the Julia backend companion.
  Dependencies: `.2`
  Acceptance: Document module APIs/types/embedding, package/depot setup, loading, staged functions, runtime/trace,
    generated source, performance/caching, and exact backend-specific boundaries.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-COMPANION-BOOKS.7`
  Status: `pending`
  Goal: Populate the Lua backend companion.
  Dependencies: `.2`
  Acceptance: Document PUC Lua/LuaJIT ABI support, native modules, module APIs/types/embedding, loading/staging,
    runtime/trace, generated-source status, cache/packaging/deployment, performance, and exact boundaries.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-COMPANION-BOOKS.8`
  Status: `pending`
  Goal: Close cross-book navigation, canonical ownership, recurring gates, and maintenance doctrine.
  Dependencies: `.3`, `.4`, `.5`, `.6`, `.7`
  Acceptance: All six books build; every companion chapter has one neutral owner/link classification; duplicated
    normative prose is absent; README/book navigation is complete; doctrine check is registered in pre-commit and
    local CI; task/index/roadmap/live/KM state agrees.
  Verification: `pending`
  Commit: `pending`

### BACKEND-COMPANION-BOOKS.0 Acceptance Checklist

- REPRODUCE / ISSUE: the neutral mdBook must stay authoritative and readable while backend users need substantially
  deeper implementation, embedding, ABI/toolchain, trace, deployment, and troubleshooting guidance.
- ROOT CAUSE: portable semantics and host-specific implementation guidance serve different audiences and have
  different change boundaries; one undifferentiated book dilutes the neutral contract, while copied books drift.
- FIX: ADR `0040` and this tree adopt one normative neutral book plus five linked, non-normative implementation
  companions, dependency-gated until full current-backend parity.
- ADDRESSED: content routing, scope, rollout order, canonical ownership, migration inventory, build/link/drift
  governance, five backend leaves, and closeout are explicit.
- NO REGRESSION: this planning leaf adds no scaffold, moves no content, changes no parser/runtime behavior, and
  preserves every current documentation path; governance and neutral-book checks pass.
- LOCKSTEP: task/index, ADR/index, roadmaps, architecture/live docs, public project-status page, Knowledge Map,
  memory pointer, and commit history describe the same adopted-but-deferred architecture.

## Current Frontier

Dependency-gated. After full current-backend parity, start `BACKEND-COMPANION-BOOKS.1` with a read-only content
inventory. Until then, backend-specific material continues to be documented accurately in the neutral book and
backend READMEs; no companion scaffold exists.

## Decisions

- The idea is adopted because backend implementation and embedding material is useful but dilutes a neutral book.
- The architecture is one normative neutral book plus five non-normative implementation companions.
- Implementation is deliberately parked until current backend parity is complete.
- Independent books are preferred over five large subsections in the neutral book, provided mechanical
  canonical-owner/drift checks exist before content migration.

## Risks

- Semantic duplication could create six conflicting truths; canonical-owner metadata and drift checks are gates.
- Five books multiply maintenance cost; a shared template and optional sections keep structure consistent without
  forcing meaningless content.
- Premature scaffolding could fossilize incomplete Lua behavior; parity is an explicit dependency.
- Moving too much could make ordinary users hunt across books; portable concepts and common workflows stay neutral.

## Blockers

- Implementation only: full current-backend parity is not yet complete.
- Planning/adoption: none.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-15` | `BACKEND-COMPANION-BOOKS.0` | User proposal/layout/parity review; ADR 0040; task/index/roadmap/live/book/KM sync; memory architecture; task metadata; Knowledge Map; doctrines; mdBook; whitespace. | PASS. One neutral normative book plus five linked implementation companions is adopted and dependency-gated; no scaffold or migration. |

## Commit Log

| Leaf | Commit | Summary |
| --- | --- | --- |
| `BACKEND-COMPANION-BOOKS.0` | `FUTURE-PARITY-BACKLOG.21.0 - plan backend companion books` | Adopt one neutral book plus five governed implementation companions. |

## Changelog

- `2026-07-15`: Created the dependency-gated architecture task from the user's companion-book proposal.
