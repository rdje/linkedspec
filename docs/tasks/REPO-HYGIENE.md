# REPO-HYGIENE: Repository hygiene — .gitignore and untrack artifacts

## Metadata

- Tree ID: `REPO-HYGIENE`
- Status: `completed`
- Roadmap lane: `Overall roadmap — repository maintenance`
- Created: `2026-06-16`
- Last updated: `2026-06-16`
- Owner: repo-local workflow

## Goal

Stop tracking files that are tool artifacts (vim swap, git commit message scratch, macOS metadata) and bring MEMORY.md current.

## Non-Goals

- Does not change any project code, tests, docs, or book content.
- Does not touch the rgx/ submodule.

## Acceptance Criteria

- `.gitignore` has entries for `*.swp`, `.DS_Store`, and `git_message_brief.txt`.
- `perl/.PPlugin.pm.swp` and `git_message_brief.txt` are removed from the index (`--cached`).
- `MEMORY.md` latest_commit updated to reflect the current HEAD.
- Focused validation passes (memory-arch self-check, perl -c).
- Live docs updated.
- Committed per `COMMIT.md`.

## Task Tree

- ID: `REPO-HYGIENE`
  Status: `completed`
  Goal: `Repository hygiene — .gitignore and untrack artifacts`
  Children: `REPO-HYGIENE.1`

- ID: `REPO-HYGIENE.1`
  Status: `done`
  Goal: `Add .gitignore entries, untrack tool artifacts, update MEMORY.md, commit`
  Acceptance: `.gitignore` updated; `git_message_brief.txt` and `.swp` untracked; MEMORY.md current; committed`
  Verification: `memory-arch self-check exit 0; perl -c perl/LinkedSpec.pm OK; git status clean`
  Commit: `REPO-HYGIENE.1 — .gitignore: untrack tool artifacts + MEMORY.md update`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `REPO-HYGIENE.1` | `in_progress` | Only leaf — single-step administrative cleanup |

## Decisions

- `2026-06-16`: `.gitignore` entries for `*.swp`, `.DS_Store`, `git_message_brief.txt`. These are tool artifacts that should never be tracked.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `REPO-HYGIENE.1` | `scripts/check_memory_architecture.sh` exit 0; `perl -c perl/LinkedSpec.pm` OK; git status clean | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `REPO-HYGIENE.1` | `pending` | Populated after commit |

## Changelog

- `2026-06-16`: Created task tree. Completed REPO-HYGIENE.1 — .gitignore updated, tool artifacts untracked, MEMORY.md current.
