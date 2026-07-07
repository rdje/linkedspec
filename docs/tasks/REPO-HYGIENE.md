# REPO-HYGIENE: Repository hygiene — .gitignore and untrack artifacts

## Metadata

- Tree ID: `REPO-HYGIENE`
- Status: `completed`
- Roadmap lane: `Overall roadmap — repository maintenance`
- Created: `2026-06-16`
- Last updated: `2026-07-07` (`REPO-HYGIENE.3` done: generated artifact cleanup)
- Owner: repo-local workflow

## Goal

Stop tracking files that are tool/local artifacts (vim swap, git commit message scratch, macOS metadata, and local
agent state) and bring MEMORY.md current.

## Non-Goals

- Does not change any project code, tests, docs, or book content.
- Does not delete source, fixtures, checked-in docs, or any user-authored working-tree content.
- Does not remove the `rgx/` submodule.

## Acceptance Criteria

- `.gitignore` has entries for `*.swp`, `.DS_Store`, `git_message_brief.txt`, and `.claude/projects/`.
- `perl/.PPlugin.pm.swp` and `git_message_brief.txt` are removed from the index (`--cached`).
- `rgx` remains tracked as a submodule/gitlink, and `.gitmodules` carries the intended local-dirt ignore policy so
  nested submodule worktree dirt does not dirty the parent status.
- `MEMORY.md` latest_commit updated to reflect the current HEAD.
- Focused validation passes (memory-arch self-check, perl -c).
- Live docs updated.
- Generated build/book artifacts are deleted only when they are rebuildable and safe to remove.
- Committed per `COMMIT.md`.

## Task Tree

- ID: `REPO-HYGIENE`
  Status: `completed`
  Goal: `Repository hygiene — .gitignore and untrack artifacts`
  Children: `REPO-HYGIENE.1`, `REPO-HYGIENE.2`, `REPO-HYGIENE.3`

- ID: `REPO-HYGIENE.1`
  Status: `done`
  Goal: `Add .gitignore entries, untrack tool artifacts, update MEMORY.md, commit`
  Acceptance: `.gitignore` updated; `git_message_brief.txt` and `.swp` untracked; MEMORY.md current; committed`
  Verification: `memory-arch self-check exit 0; perl -c perl/LinkedSpec.pm OK; git status clean`
  Commit: `REPO-HYGIENE.1 — .gitignore: untrack tool artifacts + MEMORY.md update`

- ID: `REPO-HYGIENE.2`
  Status: `done` (2026-07-06)
  Goal: `Make local .claude/projects/ and rgx submodule dirt disappear from parent git status`
  Acceptance: `.claude/projects/` is ignored; `rgx` remains a tracked submodule/gitlink; `.gitmodules` keeps the
    `rgx` submodule and records `ignore = dirty`; local `rgx/` content is not deleted; parent `git status` no
    longer reports either local agent state or dirty submodule worktree state.
  Surfaced finding: `2026-07-06`: `rgx` is tracked as a `160000` gitlink/submodule, so `.gitignore` alone cannot
    suppress dirty status for it. The correct cleanup is to keep `rgx` in `.gitmodules` and set the submodule
    ignore policy for local dirt, while ignoring only `.claude/projects/`.
  Verification: `git status --ignored` shows `.claude/projects/` ignored; `git ls-files --stage rgx` shows
    `160000 8763a0e... rgx`; `git submodule status -- rgx` reports the pinned submodule; parent `git status`
    does not report dirty `rgx`; memory/doctrine/Knowledge Map/diff checks pass.
  Commit: `pending`

- ID: `REPO-HYGIENE.3`
  Status: `done` (2026-07-07)
  Goal: `Remove safe generated artifacts to reclaim disk space`
  Acceptance: Scan for generated logs, macBinary `.bin` archives, common temp artifacts, mdBook output, and Rust
    target directories; delete only rebuildable generated artifacts that are safe to remove; record reclaimed-size
    evidence; keep source, fixtures, checked-in docs, and user-authored content intact; repo returns to a clean
    handoff state after commit.
  Verification: `done` — read-only scans found no `.log`, `.bin`, `.tmp`, `.bak`, `.DS_Store`, or `.swp` artifacts
    in the main checkout outside `.git`, ignored `rust/target`, and the `rgx` submodule. The only main-checkout
    rebuildable artifacts were ignored/untracked `rust/target` (5.2G) and `docs/linkedspec-book/book` (7.0M);
    both were removed. `.log`/`.bin` hits under `rgx/` were left intact because they live in submodule fixture,
    stimulus, or issue-artifact trees and are not 100% safe parent-repo cleanup targets.
  Commit: `REPO-HYGIENE.3 - remove generated artifacts`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `REPO-HYGIENE.3` | `done` | User-requested urgent cleanup of safe generated artifacts, including Rust target directories and mdBook output |

## Decisions

- `2026-06-16`: `.gitignore` entries for `*.swp`, `.DS_Store`, `git_message_brief.txt`. These are tool artifacts that should never be tracked.
- `2026-07-06`: `.claude/projects/` is local agent state. `rgx/` is a real submodule; because it is tracked as a
  gitlink, it should not be `.gitignore`d or untracked. Local dirt inside it is handled by `.gitmodules`
  `ignore = dirty`.
- `2026-07-07`: Rust `target/` trees and mdBook `book/` output are generated/rebuildable artifacts and may be
  deleted for disk-space recovery when the repo is otherwise handoff-ready.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-06` | `REPO-HYGIENE.2` | `.gitignore` update; `.gitmodules` `ignore = dirty`; `git status --ignored`; `git ls-files --stage rgx`; `git submodule status -- rgx`; memory/doctrine/Knowledge Map/diff checks | `.claude/projects/` is ignored; `rgx` remains a tracked submodule/gitlink at `8763a0e`; dirty submodule worktree state no longer dirties parent status. |
| `2026-07-07` | `REPO-HYGIENE.3` | `du -sh rust/target docs/linkedspec-book/book`; ignored/tracked checks; artifact scans for `.log`, `.bin`, `.tmp`, `.bak`, `.DS_Store`, and `.swp`; `rm -rf rust/target docs/linkedspec-book/book`; post-clean existence/status checks; memory/KM/doctrine/diff gates | PASS — removed ignored/untracked `rust/target` (5.2G) and `docs/linkedspec-book/book` (7.0M). Main checkout has no remaining safe log/bin/temp artifact hits outside `.git`, ignored targets, and `rgx`. Submodule `rgx` log/bin hits were preserved as fixture/stimulus/issue corpus material. Cargo/mdBook were not run because they would recreate the removed artifacts. |
| `2026-06-16` | `REPO-HYGIENE.1` | `scripts/check_memory_architecture.sh` exit 0; `perl -c perl/LinkedSpec.pm` OK; git status clean | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `REPO-HYGIENE.2` | `REPO-HYGIENE.2 - ignore Claude project state and rgx local dirt` | `.claude/projects/` ignore plus `rgx` submodule local-dirt ignore. |
| `REPO-HYGIENE.3` | `REPO-HYGIENE.3 - remove generated artifacts` | Removed ignored/untracked `rust/target` and mdBook build output; left `rgx` corpus artifacts intact. |
| `REPO-HYGIENE.1` | `pending` | Populated after commit |

## Changelog

- `2026-06-16`: Created task tree. Completed REPO-HYGIENE.1 — .gitignore updated, tool artifacts untracked, MEMORY.md current.
- `2026-07-06`: Completed REPO-HYGIENE.2 — `.claude/projects/` ignored and `rgx` kept as a submodule with
  `ignore = dirty` for local worktree noise.
- `2026-07-07`: Completed REPO-HYGIENE.3 — removed ignored/untracked `rust/target` and mdBook build output,
  reclaiming roughly 5.2G plus 7.0M; preserved `rgx` submodule `.log`/`.bin` corpus artifacts.
