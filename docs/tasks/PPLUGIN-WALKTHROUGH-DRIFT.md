# PPLUGIN-WALKTHROUGH-DRIFT: Align the pplugin walkthrough with current compatibility status

## Metadata

- Tree ID: `PPLUGIN-WALKTHROUGH-DRIFT`
- Status: `active`
- Roadmap lane: `Overall roadmap - documentation and book sync`
- Created: `2026-07-07`
- Last updated: `2026-07-07`
- Owner: repo-local workflow

## Goal

Close a narrow mdBook drift found during the user-directed bootstrap/book/code alignment pass:
`docs/linkedspec-book/src/specs-and-corpora/pplugin-spec-walkthrough.md` still describes
`pplugin.spec` as having a below-1.0000 language-agnostic readiness ratio and a compatibility-surface
rule due to host-language `eval`. The current descriptor and phase0 regression gate report the shipped
target specs, including `pplugin`, at `language_agnostic_ready_ratio = 1.0000`,
`language_agnostic_blocked_rule_count = 0`, and `compatibility_surface_rule_count = 0`.

## Non-Goals

- Changing `specs/pplugin.spec` parser behavior.
- Changing the legacy Perl `.plg` runtime or plugin machinery.
- Making `.plg` plugin execution a backend-neutral target.
- Resuming broad roadmap/architecture drift work owned by `ROADMAP-DRIFT-RECONCILE`.
- Reopening deferred plugin-modernization work.

## Acceptance Criteria

- The task-tree owner exists and is committed before the pplugin walkthrough is edited.
- The pplugin walkthrough no longer claims that the current descriptor readiness ratio is below 1.0000
  or that `pplugin.spec` has current compatibility-surface rules.
- The walkthrough clearly separates the `.spec` parser example from the legacy Perl `.plg` runtime.
- A durable Knowledge Map fact records the current descriptor/legacy-runtime boundary so future sessions
  do not re-derive it from descriptor probes.
- Focused descriptor and stale-wording checks pass.
- `mdbook build docs/linkedspec-book` passes.
- `scripts/check_memory_architecture.sh`, `knowledge-map/scripts/check_knowledge_map.sh`, and
  `scripts/check_doctrines.sh` pass.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `PPLUGIN-WALKTHROUGH-DRIFT`
  Status: `active`
  Goal: Align the pplugin mdBook walkthrough with current descriptor status and legacy-runtime boundaries.
  Children: `.0`, `.1`

- ID: `PPLUGIN-WALKTHROUGH-DRIFT.0`
  Status: `done`
  Goal: Create and register the task tree so the pplugin walkthrough drift is owned before edits.
  Acceptance: This file exists, `docs/TASK_TREE.md` registers the active tree, live recovery docs point
    to `.1` as the next leaf, and no pplugin book content or parser/runtime code is changed in this
    tracking-only slice.
  Verification: `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`;
    `bash scripts/check_doctrines.sh`; `git diff --check`
  Commit: `PPLUGIN-WALKTHROUGH-DRIFT.0 - create pplugin walkthrough drift tree`

- ID: `PPLUGIN-WALKTHROUGH-DRIFT.1`
  Status: `pending`
  Goal: Update the pplugin walkthrough, Knowledge Map fact, and live docs to the current descriptor status.
  Acceptance: The walkthrough describes `pplugin.spec` as a current descriptor-ready shipped spec while still
    identifying `.plg` execution as legacy Perl runtime behavior; stale below-1.0000 and compatibility-surface
    wording is gone; Knowledge Map and live docs are updated; focused descriptor/stale-wording checks, mdBook,
    memory, Knowledge Map, doctrine, and diff checks pass.
  Verification: pending.
  Commit: pending.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PPLUGIN-WALKTHROUGH-DRIFT.1` | `pending` | Tracking owner is in place; next slice can update the pplugin walkthrough and durable fact. |

## Decisions

- `2026-07-07`: Treat the pplugin walkthrough wording as public mdBook drift, not parser/runtime work. A focused
  descriptor probe reports `ratio=1.0000`, `blocked=0`, `compat=0`, `top=undef` for `LinkedSpec::get_parser("pplugin",
  return_descriptor => 1)`, while the current walkthrough still says the descriptor readiness ratio is below 1.0000
  because of `eval`.
- `2026-07-07`: Keep `.plg` execution explicitly scoped to the legacy Perl runtime. The book may use
  `pplugin.spec` as a shipped parser example, but must not imply that compiling plugin bodies into Perl coderefs is
  a backend-neutral runtime contract.

## Open Questions

- None blocking.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-07` | `PPLUGIN-WALKTHROUGH-DRIFT.0` | `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check` | PASS — tracking-only tree registered, live docs updated, no pplugin book content or parser/runtime code changed |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `PPLUGIN-WALKTHROUGH-DRIFT.0` | `PPLUGIN-WALKTHROUGH-DRIFT.0 - create pplugin walkthrough drift tree` | Tracking-only; no pplugin book content or parser/runtime changes. |

## Changelog

- `2026-07-07`: Created tree to own pplugin walkthrough drift before making any book edits.
