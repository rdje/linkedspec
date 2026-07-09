# BACKTRACK-SURFACE-RUST-ALIGNMENT: Replace Backtrack Surface With Cursor Controls

## Metadata

- Tree ID: `BACKTRACK-SURFACE-RUST-ALIGNMENT`
- Status: `active`
- Roadmap lane: `.spec language evolution / backend parity no-drift`
- Created: `2026-07-09`
- Last updated: `2026-07-09`
- Owner: repo-local workflow

## Goal

Replace the ambiguous public `BACKTRACK` helper family with explicit cursor
control primitives across all current and future variants:

- `save_cursor()` / `restore_cursor()` for explicit stack-based cursor save and
  restore.
- `rewind_match_start()` / `rewind_entry_start()` for immediate rewinds to the
  current local-match and entry/initial-match anchors.
- A zero-width/lookahead boundary primitive so specs can detect the next
  structural token without consuming it and capture up to that boundary without
  manual rewind.

## Non-Goals

- Do not make `save_cursor()` / `restore_cursor()` cover lifecycle-anchor rewind
  semantics.
- Do not make `rewind_match_start()` / `rewind_entry_start()` use hidden cursor
  stack state.
- Do not make zero-width/lookahead boundary support another spelling of rewind;
  it must leave cursor ownership explicit.
- Do not change unrelated capture helper compatibility forms.

## Acceptance Criteria

- Perl, Rust, and Dart expose `save_cursor()` / `restore_cursor()` as the
  stack-based cursor primitive formerly represented by Rust's `BACKTRACK()` /
  `IBACKTRACK()` behavior.
- Perl, Rust, and Dart expose `rewind_match_start()` / `rewind_entry_start()` as
  the lifecycle-anchor rewind primitive formerly represented by Perl/Dart
  `BACKTRACK()` / `IBACKTRACK()` behavior.
- Perl, Rust, and Dart expose a zero-width/lookahead boundary primitive that can
  detect a structural boundary without consuming it; current EBNF semantic
  annotation parsing is migrated away from consume-then-rewind when the boundary
  primitive lands.
- `BACKTRACK()`, `IBACKTRACK()`, `backtrack(label)`, and `ibacktrack(label)` are
  not presented as current user-facing helpers.
- mdBook, task-tree/live docs, and Knowledge Map facts define all three cursor
  control capabilities as mandatory for present and future variants.
- Focused scans and tests prove active specs use current helper names, and
  broader checks pass where warranted.
- The completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `BACKTRACK-SURFACE-RUST-ALIGNMENT`
  Status: `active`
  Goal: Replace the broad BACKTRACK surface with explicit cursor-stack, anchor-rewind, and zero-width boundary controls.
  Children: `.1`, `.2`

- ID: `BACKTRACK-SURFACE-RUST-ALIGNMENT.1`
  Status: `done`
  Goal: Land cross-variant cursor-stack and anchor-rewind helper names.
  Acceptance: Perl, Rust, and Dart support `save_cursor()` / `restore_cursor()` plus
    `rewind_match_start()` / `rewind_entry_start()`; old `BACKTRACK`/`IBACKTRACK`
    and lowercase label helper forms are absent from the current user-facing surface;
    active specs and tests use the current names; docs and Knowledge Map define the
    split semantics.
  Verification: Perl syntax checks, standalone phase0, local CI, Rust core/runtime tests, Dart tests, mdBook, Knowledge Map, doctrine, and whitespace checks pass.
  Commit: `BACKTRACK-SURFACE-RUST-ALIGNMENT.1 - replace backtrack surface`

- ID: `BACKTRACK-SURFACE-RUST-ALIGNMENT.2`
  Status: `pending`
  Goal: Land cross-variant zero-width/lookahead boundary support.
  Acceptance: Perl, Rust, and Dart can detect a named structural boundary without
    consuming it; EBNF semantic annotations use the boundary primitive instead of
    consume-then-rewind; docs explain when to prefer boundary lookahead over cursor
    save/restore or anchor rewind; future-backend parity notes require the same
    primitive for new variants.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `BACKTRACK-SURFACE-RUST-ALIGNMENT.1` | `done` | User directive satisfied: all current variants have explicit cursor-stack and lifecycle-anchor rewind helpers, with old backtrack spellings retired from the current surface. |
| 2 | `BACKTRACK-SURFACE-RUST-ALIGNMENT.2` | `pending` | User directive: all present and future variants must also support a zero-width/lookahead boundary primitive. |

## Decisions

- `2026-07-09`: The Rust helper surface is the reference for lowercase backtrack label forms. Because Rust exposes
  uppercase `BACKTRACK()` / `IBACKTRACK()` only, Perl and Dart should not preserve lowercase `backtrack(label)` /
  `ibacktrack(label)` as accepted user-facing compatibility syntax.
- `2026-07-09`: Director approved splitting the ambiguous backtrack family into
  three explicit capabilities: stack-based `save_cursor()` / `restore_cursor()`,
  lifecycle-anchor `rewind_match_start()` / `rewind_entry_start()`, and
  zero-width/lookahead boundary detection. The old broad `BACKTRACK` /
  `IBACKTRACK` names and lowercase label forms are not current user-facing API.

## Open Questions

- None blocking `.1`.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `BACKTRACK-SURFACE-RUST-ALIGNMENT.1` | Perl syntax checks for edited ActionIR modules and `t/phase0_regression.t`; `PERL5LIB= perl -Iperl t/phase0_regression.t`; `bash tools/run_ci_local.sh`; `cargo fmt --all --check`; `cargo test -p linkedspec-core`; `cargo test -p linkedspec-runtime`; Dart format/analyze/test/CLI/corpus runner; `mdbook build docs/linkedspec-book`; Knowledge Map, memory architecture, doctrine, active old-helper scan, and `git diff --check` | PASS |
| `2026-07-09` | `BACKTRACK-SURFACE-RUST-ALIGNMENT.2` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `BACKTRACK-SURFACE-RUST-ALIGNMENT.1` | `BACKTRACK-SURFACE-RUST-ALIGNMENT.1 - replace backtrack surface` | Pending commit in this slice. |
| `BACKTRACK-SURFACE-RUST-ALIGNMENT.2` | `pending` | `pending` |

## Changelog

- `2026-07-09`: Created task tree for Rust-reference BACKTRACK surface alignment.
- `2026-07-09`: Rescoped the tree after director review: current work now retires
  broad backtrack names in favor of explicit cursor-stack, anchor-rewind, and
  zero-width/lookahead boundary capabilities required of all variants.
- `2026-07-09`: `.1` done. Perl, Rust, and Dart now support explicit cursor-stack and
  anchor-rewind helpers under current names; old broad backtrack spellings are no longer the
  current user-facing API. Frontier advances to `.2` zero-width/lookahead boundary support.
