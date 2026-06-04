# DOC-CODEBASE-ALIGNMENT: Re-align live docs and task-tree index with codebase reality

## Metadata

- Tree ID: `DOC-CODEBASE-ALIGNMENT`
- Status: `active`
- Roadmap lane: `Doc/codebase alignment (no-drift doctrine)`
- Created: `2026-06-04`
- Last updated: `2026-06-04`
- Owner: repo-local workflow

## Goal

Close the drift discovered during the 2026-06-04 session bootstrap so the
roadmap, the codebase, the task-tree ledger, and the user-facing docs are locked
together with no contradictions. Specifically, stop describing the deleted
`perl/LinkedSpec/ActionRewriter.pm` module as a live architectural participant,
and make `docs/TASK_TREE.md` an accurate index of the real task-file statuses.

## Non-Goals

- No parser/compiler/runtime behavior change. This tree is documentation and
  task-ledger alignment only.
- Do not rewrite legitimate historical change records (the commit/changelog
  entries that correctly state `ActionRewriter.pm` was removed must remain as
  history).
- Do not activate the proposed `PLUGIN-ACTION-MIGRATION` tree.

## Acceptance Criteria

- `docs/TASK_TREE.md` lists every existing `docs/tasks/*.md` tree in the correct
  table with a status matching that tree file's own `Status:` field.
- No live/current-state doc presents `ActionRewriter.pm` (or the `ActionRewriter`
  package) as a module that currently exists in the codebase.
- `ROADMAP.md` and `ROADMAP_V2.md` agree on Phase 1A status and on the fact that
  `ActionRewriter.pm` has been deleted.
- Focused validation: `perl -c perl/LinkedSpec.pm` stays clean and the phase-0
  regression gate stays green (sanity baseline; no code changed).
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `DOC-CODEBASE-ALIGNMENT`
  Status: `active`
  Goal: `Re-align live docs and the task-tree index with codebase reality.`
  Children: `DOC-CODEBASE-ALIGNMENT.1`, `DOC-CODEBASE-ALIGNMENT.2`, `DOC-CODEBASE-ALIGNMENT.3`, `DOC-CODEBASE-ALIGNMENT.4`

- ID: `DOC-CODEBASE-ALIGNMENT.1`
  Status: `done`
  Goal: `Reconcile docs/TASK_TREE.md index with actual task-file statuses: register this new active tree, move PHASE7-SELF-HOSTED-SPEC from Active to Completed, and add the done trees missing from the index entirely (PHASE1-PARSER-CORE-ISOLATION, METHOD-LIKE-DSL-MIGRATION, BOOK-DOCUMENTATION-SYNC).`
  Acceptance: `Every docs/tasks/*.md tree appears in docs/TASK_TREE.md under a table whose status matches that file's own Status field; PHASE7 is no longer listed as active; the Active table contains only genuinely active trees.`
  Verification: `2026-06-04: TASK_TREE.md Active table now lists only DOC-CODEBASE-ALIGNMENT (frontier .1); Completed table gained PHASE7-SELF-HOSTED-SPEC, PHASE1-PARSER-CORE-ISOLATION, METHOD-LIKE-DSL-MIGRATION, BOOK-DOCUMENTATION-SYNC. Also corrected a discovered sub-drift: PHASE3/4/5 metadata Status was 'active' while their top task-tree nodes already said 'completed' — flipped the metadata to 'completed' to match. Cross-check script: all 13 task files indexed under a table matching their own Status field. Baseline gate (no code changed): perl -c perl/LinkedSpec.pm OK; perl -c -Iperl t/phase0_regression.t OK; prove phase0 = Files=1, Tests=1004, Result: PASS.`
  Commit: `pending (leaf ID in commit subject)`

- ID: `DOC-CODEBASE-ALIGNMENT.2`
  Status: `done`
  Goal: `Refresh ARCHITECTURE_STATE.md: remove the two stale references that present deleted ActionRewriter.pm as a live owner-dispatch participant (lines ~162 and ~224), note that Phase 1 deleted it, and update the Last refreshed date.`
  Acceptance: `ARCHITECTURE_STATE.md contains no statement implying ActionRewriter.pm currently exists; the snapshot date reflects this refresh; perl -c perl/LinkedSpec.pm still clean.`
  Verification: `2026-06-04: Last refreshed → 2026-06-04 with an explicit refresh note. The line-163 bullet now states the ActionRewriter module was deleted in Phase 1 and that rewrite_action_code_for_compat lives solely in RuleIR::EmitContext. The owner-dispatch "shares that seam" list (line ~225) no longer names ActionRewriter.pm as a live participant (parenthetical notes it was deleted). All three remaining mentions are framed as removed/historical. perl -c perl/LinkedSpec.pm OK. No code changed → phase0 1004 PASS baseline from .1 holds.`
  Commit: `pending (leaf ID in commit subject)`

- ID: `DOC-CODEBASE-ALIGNMENT.3`
  Status: `done`
  Goal: `Scrub stale live ActionRewriter module references from user-facing docs (USER_GUIDE.md; verify docs/linkedspec-book/). Present ActionRewriter as removed in Phase 1, not as a retained compatibility wrapper surface.`
  Acceptance: `USER_GUIDE.md and the public book no longer tell users ActionRewriter.pm exists as a live/compatibility module; any necessary mention is framed as historical/removed.`
  Verification: `2026-06-04: docs/linkedspec-book/ already had zero ActionRewriter references (no edit needed). USER_GUIDE.md had 7 references across two clusters (load-time-cleanup notes ~260-263, compile-pipeline owner-path notes ~1209-1219) that presented ActionRewriter.pm as a live module retained "as compatibility wrapper surface for direct legacy callers". Reworked all of them: ActionRewriter is now described as a forwarding shim deleted in Phase 1 (PHASE1-PARSER-CORE-ISOLATION.2), with the focused helper-rewrite entrypoint identified as RuleIR::EmitContext::rewrite_action_code_for_compat(...). Also dropped two now-misleading "ActionRewriter-facing default callback map" labels and corrected the LinkedSpec::Deps note (Deps was removed entirely). Re-grep: all 5 remaining USER_GUIDE.md mentions are framed "deleted in Phase 1"; book clean. perl -c perl/LinkedSpec.pm OK; phase0 1004 PASS baseline holds (no code changed).`
  Commit: `pending (leaf ID in commit subject)`

- ID: `DOC-CODEBASE-ALIGNMENT.4`
  Status: `pending`
  Goal: `Reconcile ROADMAP_V2.md Phase 1A row and ROADMAP.md so both agree ActionRewriter.pm is deleted and Phase 1A status matches (ROADMAP.md currently says "mostly done", ROADMAP_V2 says "done"). Keep the Phase 1 deletion record intact as history.`
  Acceptance: `ROADMAP.md and ROADMAP_V2.md agree on Phase 1A status and no longer describe ActionRewriter as a currently live seam participant in their current-state rows; historical changelog entries are preserved.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `DOC-CODEBASE-ALIGNMENT.1` | `done` | Index reconciled; PHASE3/4/5 metadata sub-drift also corrected. 1004 PASS baseline. |
| 2 | `DOC-CODEBASE-ALIGNMENT.2` | `done` | ARCHITECTURE_STATE.md refreshed; ActionRewriter now framed as removed. perl -c clean. |
| 3 | `DOC-CODEBASE-ALIGNMENT.3` | `done` | USER_GUIDE.md scrubbed (book already clean); all mentions framed as deleted in Phase 1. |
| 4 | `DOC-CODEBASE-ALIGNMENT.4` | `pending` | Lock the two roadmap docs together with the codebase and each other. |

## Decisions

- `2026-06-04`: Treat the deleted-`ActionRewriter.pm` references as drift to correct only in **current-state** prose. Historical records of its removal (commit log, CHANGES.md, ROADMAP.md "Landed follow-up" changelog) are accurate history and stay.
- `2026-06-04`: Split the alignment into four leaves by document family so each can be reviewed and committed independently.

## Open Questions

- None blocking. The proposed `PLUGIN-ACTION-MIGRATION` tree remains out of scope and stays `proposed`.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-04` | `DOC-CODEBASE-ALIGNMENT.1` | Index/file cross-check (13 trees, status match); `perl -c perl/LinkedSpec.pm`; `perl -c -Iperl t/phase0_regression.t`; `prove -Iperl t/phase0_regression.t`. | Pass — index reconciled, PHASE3/4/5 metadata fixed, phase0 Files=1 Tests=1004 PASS (no code changed). Frontier → `.2`. |
| `2026-06-04` | `DOC-CODEBASE-ALIGNMENT.2` | `grep ActionRewriter ARCHITECTURE_STATE.md` (all 3 mentions framed as removed/historical); `perl -c perl/LinkedSpec.pm`. | Pass — ARCHITECTURE_STATE.md refreshed; no live-module claim remains; perl -c OK; phase0 1004 PASS baseline holds (no code changed). Frontier → `.3`. |
| `2026-06-04` | `DOC-CODEBASE-ALIGNMENT.3` | `grep ActionRewriter docs/linkedspec-book/` (clean); `grep ActionRewriter USER_GUIDE.md` (all 5 remaining mentions framed "deleted in Phase 1"); `perl -c perl/LinkedSpec.pm`. | Pass — USER_GUIDE.md scrubbed; book already clean; perl -c OK; phase0 1004 PASS baseline holds (no code changed). Frontier → `.4`. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `DOC-CODEBASE-ALIGNMENT.1` | `Reconcile task-tree index with task-file statuses (DOC-CODEBASE-ALIGNMENT.1)` | Hash `5277df9`. |
| `DOC-CODEBASE-ALIGNMENT.2` | `Refresh ARCHITECTURE_STATE.md: ActionRewriter.pm removed (DOC-CODEBASE-ALIGNMENT.2)` | Hash `14006e3`. |
| `DOC-CODEBASE-ALIGNMENT.3` | `Scrub deleted-ActionRewriter live claims from USER_GUIDE.md (DOC-CODEBASE-ALIGNMENT.3)` | Hash backfilled later if useful. |

## Changelog

- `2026-06-04`: Completed `DOC-CODEBASE-ALIGNMENT.3` — scrubbed the deleted-`ActionRewriter.pm` live claims from `USER_GUIDE.md` (two clusters, 7 references) so it reads as removed in Phase 1; verified `docs/linkedspec-book/` was already clean; corrected the `LinkedSpec::Deps`-removed note. Active frontier: `.4`.
- `2026-06-04`: Completed `DOC-CODEBASE-ALIGNMENT.2` — refreshed `ARCHITECTURE_STATE.md` so the deleted `ActionRewriter.pm` is no longer presented as a live owner-dispatch participant (updated Last-refreshed date + refresh note, rewrote the line-163 bullet, and dropped it from the "shares that seam" list). Active frontier: `.3`.
- `2026-06-04`: Completed `DOC-CODEBASE-ALIGNMENT.1` — reconciled `docs/TASK_TREE.md` (registered this active tree, moved PHASE7 to Completed, added PHASE1-PARSER-CORE-ISOLATION / METHOD-LIKE-DSL-MIGRATION / BOOK-DOCUMENTATION-SYNC), and corrected the PHASE3/4/5 metadata `Status` sub-drift (`active` → `completed`). 1004 PASS baseline. Active frontier: `.2`.
- `2026-06-04`: Created task tree from template during session bootstrap after detecting deleted-`ActionRewriter.pm` references in live docs and a stale `docs/TASK_TREE.md` index.
