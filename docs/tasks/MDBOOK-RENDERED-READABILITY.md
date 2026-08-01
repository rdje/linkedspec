# MDBOOK RENDERED READABILITY

Roadmap lane: non-blocking documentation quality / sole-facing rendered mdBook

Status: `proposed` / recorded for later execution without changing the active roadmap order

## Objective

Prevent rendered mdBook chapters or sections from presenting several logically distinct paragraphs as one dense
wall-of-text blob. Audit the rendered HTML—not Markdown source alone—then repair confirmed readability defects
without weakening technical accuracy, examples, anchors, navigation, or mechanically governed current claims.

## Scope boundary

This tree owns rendered prose segmentation, adjacent heading/list/code-block spacing when it materially affects
reading flow, a complete rendered-book census, and a durable regression boundary if a low-noise mechanical check
is feasible. It does not own language behavior, technical-content simplification, removal of necessary detail,
theme redesign, navigation redesign, unrelated styling, or current roadmap reprioritization.

The director recorded this observation on 2026-08-01 so it would not be forgotten and explicitly classified it as
non-urgent. Current exclusion-governance work therefore continues first.

## Task Tree

- ID: `MDBOOK-RENDERED-READABILITY.0`
  Status: `done`
  Goal: Preserve the director's rendered wall-of-text observation as a durable, scoped future work owner.
  Acceptance: Record the visual defect against rendered HTML, distinguish it from Markdown-only review, freeze
    the non-urgent priority and no-content-loss boundary, split audit from repair, and keep the current roadmap
    frontier unchanged.
  Verification: Clean task-tree-first intake from `5bc31609`; task/index, roadmaps, continuity, changes, and
    development notes agree; no mdBook source, theme, checker, production code, or behavior changes.
  Commit: `MDBOOK-RENDERED-READABILITY.0 - queue rendered prose audit`

### `MDBOOK-RENDERED-READABILITY.0` Acceptance Checklist

- [x] **DIRECTOR INTENT** — Preserve the observation that rendered chapters/sections can become painful dense
  paragraph blobs and the explicit clarification that this is important future quality work, not urgent work.
- [x] **TASK-TREE FIRST** — Create this owner from clean callable-count commit `5bc31609` before changing any
  projection, with no active implementation or visual-audit claim.
- [x] **SPLIT BEFORE REPAIR** — Assign complete rendered audit/evidence to `.1` and evidence-bounded repairs plus
  any justified no-drift guard to `.2`.
- [x] **PRIORITY / SCOPE LOCK** — Keep exclusion governance `.24.1` as the next active roadmap slice; change no
  book source, theme, technical content, checker, runtime, capability, root README, or push state.
- [x] **LOCKSTEP / COMMIT / CLEAN** — Align the task index, roadmaps, bounded memory, changes, and development
  notes; pass task/memory/doctrine/whitespace checks; commit, clear the brief, and prove clean before `.24.1`.

- ID: `MDBOOK-RENDERED-READABILITY.1`
  Status: `pending`
  Goal: Audit every rendered mdBook chapter for dense paragraph blobs and freeze exact evidence before edits.
  Dependencies: `.0`
  Acceptance: Build the complete book through the repository-local route; inspect rendered HTML at representative
    desktop and narrow reading widths with the in-app browser when available; inventory every confirmed offender
    by source path, rendered route, section, viewport, and exact symptom; distinguish prose-density defects from
    intentional code, tables, lists, and compact reference material; define the smallest evidence-based repair
    set without editing book prose or theme in this leaf.

- ID: `MDBOOK-RENDERED-READABILITY.2`
  Status: `pending`
  Goal: Repair the confirmed rendered readability defects and prevent recurrence where feasible.
  Dependencies: `.1`
  Acceptance: Split or structure only confirmed dense prose while preserving exact technical meaning, examples,
    anchors, links, searchability, and governed status claims; rebuild and visually re-review every affected page
    plus adjacent navigation; add a low-noise source/rendered regression check only if `.1` proves a reliable
    signal; synchronize the sole-facing book and live project records; remove generated output after verification.

## Current Frontier

No active frontier. `.1` remains a non-blocking future audit until selected after higher-priority roadmap work.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-08-01` | `MDBOOK-RENDERED-READABILITY.0` | Clean base `5bc31609`; director observation and non-urgent priority; exact rendered-HTML/content-preservation boundary; task/index/roadmap/memory/live projection review; memory/task/whitespace/seven doctrines. | PASS. The issue is durable and split into evidence-first audit plus bounded repair without changing the book or current `.24.1` priority. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `MDBOOK-RENDERED-READABILITY.0` | `MDBOOK-RENDERED-READABILITY.0 - queue rendered prose audit` | Durable non-urgent rendered wall-of-text audit/repair split; no book or behavior change. |

## Changelog

- `2026-08-01`: The director's rendered mdBook wall-of-text observation is durably queued without reprioritizing
  current work. `.1` owns complete visual evidence; `.2` owns only confirmed repairs and any proven low-noise
  regression guard. Technical content, book source/theme, runtime behavior, root README, and push state do not move.
