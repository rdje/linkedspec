# DOC-CODEBASE-ALIGNMENT: Re-align live docs and task-tree index with codebase reality

## Metadata

- Tree ID: `DOC-CODEBASE-ALIGNMENT`
- Status: `done`
- Roadmap lane: `Doc/codebase alignment (no-drift doctrine)`
- Created: `2026-06-04`
- Last updated: `2026-06-04`
- Active frontier: `none` (tree complete)
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
- `ROADMAP.md` and `ROADMAP_V2.md` agree on the status of every phase/track and on
  the fact that `ActionRewriter.pm` has been deleted.
- Focused validation: `perl -c perl/LinkedSpec.pm` stays clean and the phase-0
  regression gate stays green (sanity baseline; no code changed).
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `DOC-CODEBASE-ALIGNMENT`
  Status: `done`
  Goal: `Re-align live docs and the task-tree index with codebase reality.`
  Children: `DOC-CODEBASE-ALIGNMENT.1`, `DOC-CODEBASE-ALIGNMENT.2`, `DOC-CODEBASE-ALIGNMENT.3`, `DOC-CODEBASE-ALIGNMENT.4`, `DOC-CODEBASE-ALIGNMENT.5`

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
  Goal: `Reconcile ROADMAP_V2.md so it is internally consistent about ActionRewriter: its Phase 1A row (line ~59) must not present the deleted ActionRewriter.pm as a currently-live OwnerDispatch seam participant. V2's Phase 1 row already records the deletion as history — keep it.`
  Acceptance: `ROADMAP_V2.md no longer describes ActionRewriter as a currently-live seam participant in its Phase 1A current-state row; the Phase 1 deletion record stays intact.`
  Verification: `2026-06-04: Two surgical edits to the Phase 1A row (line 59): dropped ActionRewriter.pm from the OwnerDispatch seam-sharing list (parenthetical "the then-present thin shim ActionRewriter.pm was later deleted in Phase 1"), and reframed the "ActionRewriter now also routes its EmitContext delegation through dispatch_owner_call(...)" clause as past tense "before being deleted in Phase 1". The Phase 1 row (line 58) deletion record is untouched. Re-grep confirms both module mentions now read as historical. perl -c perl/LinkedSpec.pm OK; phase0 1004 PASS baseline holds (no code changed). Split out .5 for the broader ROADMAP.md tracker drift.`
  Commit: `pending (leaf ID in commit subject)`

- ID: `DOC-CODEBASE-ALIGNMENT.5`
  Status: `pending`
  Goal: `Reconcile ROADMAP.md's status-tracker table with ROADMAP_V2.md/reality. Discovered during .4: ROADMAP.md's tracker is frozen at an early state — Phase 1 (mostly done), 1A (mostly done), 2/3/4/5/6 (in progress), 7 (not started), Backbone (mostly done) — all of which are done per ROADMAP_V2.md. Flip those statuses to match, trim the stale "Remaining focus" prose to current state, annotate the Phase 1A planning section that ActionRewriter.pm was removed in Phase 1, and remove live-ActionRewriter-seam language from the Phase 1A tracker row while preserving the "Landed follow-up" changelog as history.`
  Acceptance: `ROADMAP.md's status tracker matches ROADMAP_V2.md for every phase/track; ROADMAP.md no longer presents ActionRewriter.pm as a currently-live module in its current-state rows; the historical changelog and planning record are preserved (planning section annotated as superseded, not deleted).`
  Verification: `2026-06-04: Rewrote 13 stale tracker rows (line-number-keyed Perl splice, single-line→single-line, line count stable at 1248) to match ROADMAP_V2.md: Phase 1/1A → done, Phase 2/3/4/5/6 → done, Phase 7 not started → done, Backbone refactor track + Item 3 → done, Method-like → mostly done, Plugin track → done; Overall stays in progress with a refreshed focus note. Each "Remaining focus" cell trimmed to a concise task-tree-referenced completion note. Annotated the Phase 1A planning section (ActionRewriter.pm bullet) that the module was deleted in Phase 1, covering the historical rollout-order mention too. Cross-check: all 15 shared phase/track statuses now match ROADMAP_V2.md. Re-grep: every ROADMAP.md ActionRewriter mention is now historical (deletion record / Landed-follow-up changelog / annotated plan); no current-state row presents it as live. perl -c perl/LinkedSpec.pm OK; phase0 1004 PASS baseline holds (no code changed). This was the final leaf — DOC-CODEBASE-ALIGNMENT tree complete (5 leaves).`
  Commit: `pending (leaf ID in commit subject)`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `DOC-CODEBASE-ALIGNMENT.1` | `done` | Index reconciled; PHASE3/4/5 metadata sub-drift also corrected. 1004 PASS baseline. |
| 2 | `DOC-CODEBASE-ALIGNMENT.2` | `done` | ARCHITECTURE_STATE.md refreshed; ActionRewriter now framed as removed. perl -c clean. |
| 3 | `DOC-CODEBASE-ALIGNMENT.3` | `done` | USER_GUIDE.md scrubbed (book already clean); all mentions framed as deleted in Phase 1. |
| 4 | `DOC-CODEBASE-ALIGNMENT.4` | `done` | ROADMAP_V2.md Phase 1A row reconciled; ActionRewriter now historical there. |
| 5 | `DOC-CODEBASE-ALIGNMENT.5` | `done` | ROADMAP.md tracker synced with ROADMAP_V2 (15/15 statuses match); planning section annotated. Final leaf — tree complete. |

All leaves complete — tree `done`. No leaves remain in the frontier.

## Decisions

- `2026-06-04`: Treat the deleted-`ActionRewriter.pm` references as drift to correct only in **current-state** prose. Historical records of its removal (commit log, CHANGES.md, ROADMAP.md "Landed follow-up" changelog) are accurate history and stay.
- `2026-06-04`: Split the alignment into four leaves by document family so each can be reviewed and committed independently.
- `2026-06-04`: While starting `.4`, discovered `ROADMAP.md`'s status tracker is frozen at an early state (every phase/track stale vs `ROADMAP_V2.md`/reality), far broader than the Phase 1A/ActionRewriter drift `.4` was scoped for. Split per the workflow's splitting rule: `.4` stays narrow (ROADMAP_V2 internal ActionRewriter consistency) and new `.5` owns the full ROADMAP.md tracker reconciliation. `ROADMAP_V2.md` mandates updating both roadmaps in the same slice, satisfied by doing `.4` then `.5` back-to-back.

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
| `2026-06-04` | `DOC-CODEBASE-ALIGNMENT.4` | `grep ActionRewriter ROADMAP_V2.md` (module mentions on lines 58/59 now historical); `perl -c perl/LinkedSpec.pm`. | Pass — ROADMAP_V2.md Phase 1A row reconciled; split out `.5` for ROADMAP.md tracker drift; perl -c OK; phase0 1004 PASS baseline holds (no code changed). Frontier → `.5`. |
| `2026-06-04` | `DOC-CODEBASE-ALIGNMENT.5` | Line-number Perl splice of 13 tracker rows (line count stable 1248); ROADMAP.md↔ROADMAP_V2.md status cross-check (15/15 match); `grep ActionRewriter ROADMAP.md` (all historical); `perl -c perl/LinkedSpec.pm`. | Pass — ROADMAP.md tracker synced; planning section annotated; perl -c OK; phase0 1004 PASS baseline holds (no code changed). Tree complete (5 leaves). |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `DOC-CODEBASE-ALIGNMENT.1` | `Reconcile task-tree index with task-file statuses (DOC-CODEBASE-ALIGNMENT.1)` | Hash `5277df9`. |
| `DOC-CODEBASE-ALIGNMENT.2` | `Refresh ARCHITECTURE_STATE.md: ActionRewriter.pm removed (DOC-CODEBASE-ALIGNMENT.2)` | Hash `14006e3`. |
| `DOC-CODEBASE-ALIGNMENT.3` | `Scrub deleted-ActionRewriter live claims from USER_GUIDE.md (DOC-CODEBASE-ALIGNMENT.3)` | Hash `b64a1e7`. |
| `DOC-CODEBASE-ALIGNMENT.4` | `Reconcile ROADMAP_V2.md Phase 1A row: ActionRewriter historical (DOC-CODEBASE-ALIGNMENT.4)` | Hash `8ac1ce9`. |
| `DOC-CODEBASE-ALIGNMENT.5` | `Sync ROADMAP.md status tracker with ROADMAP_V2/reality (DOC-CODEBASE-ALIGNMENT.5)` | Hash backfilled later if useful. |

## Changelog

- `2026-06-04`: Completed `DOC-CODEBASE-ALIGNMENT.5` — synced ROADMAP.md's status-tracker table with ROADMAP_V2.md/reality (13 rows flipped to current status; Phase 1A planning section annotated that ActionRewriter.pm was removed in Phase 1). **DOC-CODEBASE-ALIGNMENT tree COMPLETE (5 leaves).** No active trees remain; the proposed `PLUGIN-ACTION-MIGRATION` tree stays `proposed`.
- `2026-06-04`: Completed `DOC-CODEBASE-ALIGNMENT.4` — reconciled `ROADMAP_V2.md`'s Phase 1A row so the deleted `ActionRewriter.pm` is framed as historical rather than a live OwnerDispatch seam participant. While starting this, discovered `ROADMAP.md`'s status tracker is broadly stale (every phase/track) and split that into new leaf `.5`. Active frontier: `.5`.
- `2026-06-04`: Completed `DOC-CODEBASE-ALIGNMENT.3` — scrubbed the deleted-`ActionRewriter.pm` live claims from `USER_GUIDE.md` (two clusters, 7 references) so it reads as removed in Phase 1; verified `docs/linkedspec-book/` was already clean; corrected the `LinkedSpec::Deps`-removed note. Active frontier: `.4`.
- `2026-06-04`: Completed `DOC-CODEBASE-ALIGNMENT.2` — refreshed `ARCHITECTURE_STATE.md` so the deleted `ActionRewriter.pm` is no longer presented as a live owner-dispatch participant (updated Last-refreshed date + refresh note, rewrote the line-163 bullet, and dropped it from the "shares that seam" list). Active frontier: `.3`.
- `2026-06-04`: Completed `DOC-CODEBASE-ALIGNMENT.1` — reconciled `docs/TASK_TREE.md` (registered this active tree, moved PHASE7 to Completed, added PHASE1-PARSER-CORE-ISOLATION / METHOD-LIKE-DSL-MIGRATION / BOOK-DOCUMENTATION-SYNC), and corrected the PHASE3/4/5 metadata `Status` sub-drift (`active` → `completed`). 1004 PASS baseline. Active frontier: `.2`.
- `2026-06-04`: Created task tree from template during session bootstrap after detecting deleted-`ActionRewriter.pm` references in live docs and a stale `docs/TASK_TREE.md` index.
