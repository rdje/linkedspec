# NONCURRENT-HELPER-CODE-PURGE: Remove Non-Current Helper Spellings From Code

## Metadata

- Tree ID: `NONCURRENT-HELPER-CODE-PURGE`
- Status: `active`
- Roadmap lane: `.spec language evolution / codebase no-drift`
- Created: `2026-07-09`
- Last updated: `2026-07-09`
- Owner: repo-local workflow

## Goal

Remove explicit non-current helper spelling support, diagnostics, fixtures, labels, and source references from
the Perl and Rust codebases so removed helper names are not recognized, specially parsed, or preserved as
runtime/test/tool source surface. Helper-looking calls outside the current contract must flow through generic
unknown-helper handling, not through a name-specific removal compatibility layer.

## Non-Goals

- Do not change current helper semantics or accepted current aliases.
- Do not broaden the `.spec` language or add compatibility aliases.
- Do not rewrite historical project documentation in this tree unless it blocks code/test verification.
- Do not touch the Dart `.3.3` function-registry work until this directive is either exhausted or explicitly
  reprioritized after a clean commit boundary.

## Acceptance Criteria

- Perl source no longer contains explicit recognition paths, diagnostic helpers, or source-preservation logic for
  the non-current helper spelling set owned by `SPEC-FORMAT-TERSE.8`.
- Rust source no longer contains explicit recognition paths, diagnostic helpers, or source-preservation logic for
  the same non-current helper spelling set.
- Active Perl/Rust tests and tool-generated fixtures no longer embed those spellings as helper calls or code
  examples; equivalent current-surface tests use current spellings or generic invented unknown-helper names.
- Checked-in `.spec` grammar labels, helper strings, and generated corpus inputs are renamed or migrated where
  they collide with removed helper names, with expected-output drift reviewed deliberately.
- Focused scans over `perl/`, `rust/`, `t/`, `tools/`, `bin/`, and `specs/` are clean for the owned spelling set,
  excluding only generic language words that are not helper names in context.
- Focused Perl/Rust checks and the broader gate pass where the blast radius warrants it.
- Live docs, task-tree status, and Knowledge Map facts stay aligned after each leaf.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `NONCURRENT-HELPER-CODE-PURGE`
  Status: `active`
  Goal: Remove non-current helper spelling support/references from Perl and Rust code surfaces.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `NONCURRENT-HELPER-CODE-PURGE.1`
  Status: `done`
  Goal: Inventory and split the Perl/Rust code purge before implementation.
  Acceptance: Read-only scans identify the source/test/tool/spec owner categories; executable leaves are split
    before any parser/runtime code edits.
  Verification: **PASS 2026-07-09.** Read-only scans over `perl`, `rust`, `t`, `tools`, `scripts`, `bin`, and
    `specs` show explicit non-current helper handling in Perl ActionIR owners, Rust runtime diagnostics, active
    test fixtures, oracle-generation tooling, inspection tooling, and checked-in `.spec` grammar labels/outputs.
    The broad string scan also produces many false positives from generic language words, so implementation leaves
    must use context-aware scans rather than blind replacement.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.1 - split code purge task tree`

- ID: `NONCURRENT-HELPER-CODE-PURGE.2`
  Status: `pending`
  Goal: Remove Perl source recognition and diagnostic paths for non-current helper spellings.
  Acceptance: Perl ActionIR parser/lowering/runtime source stops branching on the removed helper names; current
    helpers still lower; non-current helper-looking calls use generic unknown-helper behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `NONCURRENT-HELPER-CODE-PURGE.3`
  Status: `pending`
  Goal: Remove Rust source recognition and diagnostic paths for non-current helper spellings.
  Acceptance: Rust parser/runtime source stops branching on the removed helper names; current helpers still parse
    and execute; non-current helper-looking calls use generic unknown-helper behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `NONCURRENT-HELPER-CODE-PURGE.4`
  Status: `pending`
  Goal: Migrate active tests, tools, generated fixtures, and checked-in `.spec` labels away from non-current helper
    spellings.
  Acceptance: Active Perl/Rust test strings, tooling fixtures, generated corpus inputs, and checked-in `.spec`
    labels/source strings no longer carry the removed helper spellings except unavoidable generic-language false
    positives.
  Verification: `pending`
  Commit: `pending`

- ID: `NONCURRENT-HELPER-CODE-PURGE.5`
  Status: `pending`
  Goal: Final no-drift scan and documentation closeout for the Perl/Rust code purge.
  Acceptance: Focused scans and gates prove no remaining code/test/tool/spec references to the removed helper
    spelling set, and live docs/KM record the current generic unknown-helper policy.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `NONCURRENT-HELPER-CODE-PURGE.2` | `pending` | Perl ActionIR still carries explicit name-specific handling; remove that before Rust parity cleanup. |

## Decisions

- `2026-07-09`: The director clarified that removed helper spellings must not appear in new Dart code and must
  also be deleted from the Perl and Rust codebases. Because the Dart `.3.2` tree was dirty at the time, the
  pivot waited until `DART-BACKEND-PARITY.3.2` was committed clean.
- `2026-07-09`: This tree treats the `SPEC-FORMAT-TERSE.8` non-current helper set as the source of truth without
  re-encoding the spelling list into new implementation code.
- `2026-07-09`: Broad textual scans are diagnostic only. Several words in the historical denylist are common
  implementation terms, so each implementation leaf must confirm context before editing.

## Open Questions

- None blocking `.2`. The Perl source owners are visible from the read-only scan and can be edited first.

## Blockers

- None known before `.2`.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.1` | Read-only scans over `perl`, `rust`, `t`, `tools`, `scripts`, `bin`, and `specs`; task-tree split. | PASS. Owner categories are known; implementation starts with Perl source. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `NONCURRENT-HELPER-CODE-PURGE.1` | `NONCURRENT-HELPER-CODE-PURGE.1 - split code purge task tree` | Inventory/split before code edits. |

## Changelog

- `2026-07-09`: Created task tree after the director's Perl/Rust code purge directive and split implementation
  into Perl source, Rust source, active tests/tools/spec fixtures, and final no-drift closeout.
