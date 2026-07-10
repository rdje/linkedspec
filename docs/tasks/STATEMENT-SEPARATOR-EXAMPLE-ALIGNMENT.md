# STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT: Separator-Only Example Style

## Metadata

- Tree ID: `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT`
- Status: `done`
- Roadmap lane: `.spec language evolution / documentation and test no-drift`
- Created: `2026-07-10`
- Last updated: `2026-07-10`
- Owner: repo-local workflow

## Goal

Keep executable `.spec` examples aligned with the established statement-separator contract:
newlines separate statements on different physical lines, while `;` appears only between
adjacent statements on one physical line and never as a trailing line terminator.

## Non-Goals

- Do not change parser or runtime separator behavior.
- Do not mechanically rewrite intentional same-line multi-statement fixtures.
- Do not broaden this correction beyond the director-identified Dart hash-helper example.

## Acceptance Criteria

- The identified multiline Dart `.spec` fixture has no redundant line-ending semicolons.
- The fixture still parses and executes with the same expected output.
- The durable task/live-doc state records that this is example alignment, not a grammar change.
- The completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT`
  Status: `done`
  Goal: Align the director-identified executable example with separator-only semicolon style.
  Children: `.1`

- ID: `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1`
  Status: `done`
  Goal: Remove redundant trailing semicolons from the multiline Dart hash-helper fixture.
  Acceptance: Each statement remains newline-separated with no trailing semicolon, the focused Dart runtime
    test passes unchanged, and separator-contract docs remain accurate.
  Verification: `PASS` - the eight multiline statements now use newline separation without trailing semicolons;
    the focused Dart runtime test passes with unchanged expected output, and the mdBook/KM contract is explicit.
  Commit: `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1 - align separator example style`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1` | `done` | Redundant line-ending semicolons are removed and focused execution passes. |

## Decisions

- `2026-07-10`: Treat `;` strictly as an infix same-line statement separator. The final statement on a line,
  including a line containing several statements, has no trailing semicolon.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-10` | `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1` | Focused Dart runtime test; mdBook/KM contract audit; memory/task-tree/doctrine/whitespace gates. | PASS. Newlines separate the eight statements, no line ends with `;`, and runtime output is unchanged. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1` | `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1 - align separator example style` | Correct the director-identified executable example without changing grammar/runtime behavior. |

## Changelog

- `2026-07-10`: Created the corrective task tree before editing the identified fixture.
- `2026-07-10`: Removed the redundant terminator-style semicolons, verified unchanged execution, and closed the tree.
