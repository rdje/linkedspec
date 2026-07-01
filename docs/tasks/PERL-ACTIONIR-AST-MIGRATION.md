# PERL-ACTIONIR-AST-MIGRATION — Perl text-to-AST migration

- Status: `active` (created 2026-07-01 by explicit user directive)
- Roadmap lane: `Overall roadmap — compiler architecture / variant contract`
- Owner: repo-local workflow

## Goal

Move the Perl reference backend away from ActionIR text-to-text lowering and toward the
same text-to-AST doctrine already used by the Rust expression runtime. The user-facing
`.spec` contract is variant-neutral: every backend must parse `.spec` helper/action
language text into typed AST/IR before lowering or execution. Broad regex macro rewriting
and host-language fallback are migration debt.

## Acceptance Criteria

- The doctrine is recorded in ADR `0011` and the variant-neutral mdBook.
- Perl migration is split before code into narrow leaves; no leaf may replace broad
  lowering behavior without focused probes, phase0 locks, and corpus/oracle checks where
  applicable.
- The first code slice introduces an AST parser seam behind existing behavior before any
  broad lowering path is replaced.
- Text-to-text fallback for supported helper/value surfaces is retired family by family,
  with diagnostics replacing accidental generated-host-language calls.
- The user-defined function implementation must consume this AST path rather than adding
  new textual macro expansion.

## Task Tree

- ID: `PERL-ACTIONIR-AST-MIGRATION`
  Status: `active`
  Goal: Migrate Perl ActionIR helper/action handling from text-to-text lowering to typed
    text-to-AST parsing and lowering.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `PERL-ACTIONIR-AST-MIGRATION.0`
  Status: `done` (2026-07-01)
  Goal: Adopt text-to-AST as the cross-variant doctrine before code.
  Acceptance: Record an ADR; update the variant-neutral mdBook; add a Knowledge Map fact;
    update live docs and frontier state. No parser/compiler/runtime code changes.
  Verification: **PASS 2026-07-01.** Wrote ADR `0011`, added Knowledge Map fact
    `text-to-ast-backend-doctrine`, updated the variant-neutral mdBook backend handoff,
    compiler pipeline, formal grammar, and architecture chapters, and synced roadmap,
    task-tree index, and live docs. Regenerated `KNOWLEDGE_MAP.md`. Checks passed:
    `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_doctrines.sh`, `mdbook build docs/linkedspec-book`, and `git diff --check`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.0 - adopt text-to-AST doctrine`

- ID: `PERL-ACTIONIR-AST-MIGRATION.1`
  Status: `pending`
  Goal: Inventory Perl text-to-text ActionIR lowering sites and define the AST node set.
  Acceptance: Enumerate current string-lowering entry points in `ActionIR::*` and
    `RuleIR::EmitContext`; map each supported expression/statement/control shape to an
    AST node; identify behavior-preserving order of replacement. No behavior change.
  Verification: `pending`
  Commit: `pending`

- ID: `PERL-ACTIONIR-AST-MIGRATION.2`
  Status: `pending`
  Goal: Introduce a Perl ActionIR AST parser seam behind existing behavior.
  Acceptance: Add focused parser modules/tests for calls, literals, variables, direct
    access, shape literals, blocks, statements, and receiver-dot chains. The seam must
    preserve existing generated behavior until consumers switch over.
  Verification: `pending`
  Commit: `pending`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3`
  Status: `pending`
  Goal: Replace value-expression and receiver-chain lowering with AST lowering.
  Acceptance: Value calls, helper composition, direct access, shape literals, blocks, and
    receiver-dot chains lower from typed AST nodes, not source-text rescans. Existing phase0
    and terse oracle fixtures remain green; accidental host-call leakage becomes a
    LinkedSpec diagnostic.
  Verification: `pending`
  Commit: `pending`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4`
  Status: `pending`
  Goal: Replace statement/control lowering with AST lowering.
  Acceptance: Assignments, appends, hash-index mutation, set_key, push helpers,
    return/return_undef, if/when/switch/while forms, and block-local returns lower from AST
    nodes. Existing behavior stays stable.
  Verification: `pending`
  Commit: `pending`

- ID: `PERL-ACTIONIR-AST-MIGRATION.5`
  Status: `pending`
  Goal: Retire supported-surface text fallback and unblock user-defined functions on AST.
  Acceptance: Supported helper/value/control surfaces no longer depend on text-to-text
    fallback; unsupported call spellings emit clear diagnostics; user-defined function
    calls are implemented through AST call nodes rather than textual macro expansion.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `PERL-ACTIONIR-AST-MIGRATION.0` | `done` 2026-07-01 | Doctrine adoption and book alignment before code. |
| 1 | `PERL-ACTIONIR-AST-MIGRATION.1` | `pending` | Inventory all text-to-text lowering sites and design AST nodes before implementation. |
| 2 | `PERL-ACTIONIR-AST-MIGRATION.2` | `pending` | Introduce parser seam behind existing behavior. |

## Decisions

- `2026-07-01`: The user explicitly rejected Perl source-text lowering as too fragile and
  adopted the Rust-style text-to-AST path as the cross-variant doctrine. Perl must migrate
  carefully; future Julia/Dart backends, and Lua if later adopted, must start from
  text-to-AST rather than text-to-text lowering.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.0` | ADR `0011`; KM fact `text-to-ast-backend-doctrine` + regenerated map; mdBook backend-handoff/pipeline/formal/architecture updates; roadmap/task-tree/live-doc sync; memory/doctrine/KM/diff checks; mdBook build | Text-to-AST adopted as a cross-variant doctrine before code. Perl ActionIR text-to-text lowering is now migration debt; future backends must parse helper/action text into typed AST/IR before lowering/execution. No parser/compiler/runtime code changed. |
