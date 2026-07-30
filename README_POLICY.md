# README Policy

## Purpose

The root `README.md` is LinkedSpec's stable landing page. It should let a new reader understand the project,
verify one minimal first use, and reach the canonical documentation without becoming a second manual, roadmap,
status ledger, or change history.

This policy is normative for README changes. ADR `0063` records why it was adopted and how its initial budgets
were selected.

## What belongs in README

README may contain only stable entry material:

- project purpose, intended audience, and scope;
- prerequisites and one minimal, verified quick start;
- stable top-level architecture and repository invariants;
- concise links to canonical documentation, contribution, support, and status owners; and
- the project license state and essential notices.

README changes are warranted only when project purpose, the first-use path, top-level architecture, repository
invariants, or canonical navigation changes. A feature or milestone does not automatically warrant a README edit.

## What belongs elsewhere

Route changing or detailed material before removing a duplicate from README:

| Material | Canonical owner |
| --- | --- |
| Public behavior, concepts, examples, and backend status | `docs/linkedspec-book/` and `USER_GUIDE.md` |
| Direction, sequencing, and active work | `ROADMAP.md`, `ROADMAP_V2.md`, and `docs/tasks/` |
| Current implementation ownership | `ARCHITECTURE_STATE.md` |
| Commands, diagnostics, gate composition, and troubleshooting | `TOOLBOX.md` and the mdBook local-CI chapter |
| Durable rationale and structural facts | `docs/decisions/` and `docs/knowledge/` |
| Change history | `CHANGES.md` and git history |
| Session state and handoff | `MEMORY.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `SESSION_BOOTSTRAP.md` |
| Contribution and commit mechanics | `AGENTS.md`, `docs/TASK_TREE.md`, and `COMMIT.md` |

Prefer one link to the canonical owner over copied detail. Never delete unique information merely to satisfy a
budget: move it to the correct owner first, verify the destination, then shorten README.

## Mechanical budgets

- Machine line cap: `128`
- Machine byte cap: `6144`

Both are hard ceilings, including headings, code fences, blank lines, and the final newline. They were chosen
from a reviewed 105-line / 5,072-byte lossless landing-page prototype, leaving modest maintenance headroom.

Increasing either cap requires a new accepted and indexed decision record. That record must state the previous
and new line and byte caps, explain why routing or editing cannot meet the need, and identify the new stable
landing-page responsibility. An ordinary feature slice may not raise a cap.

The initial admission is governed by ADR `0063`, whose machine-auditable transition markers are:

- Previous README line cap: `unbounded`
- New README line cap: `128`
- Previous README byte cap: `unbounded`
- New README byte cap: `6144`

## Enforcement

`scripts/check_readme_stability.sh` is the read-only, repository-rooted source of truth. It:

- enforces both caps;
- requires the stable landing-page sections and canonical navigation anchors;
- rejects reintroduced status/history/inventory section classes;
- self-tests exact-limit acceptance and line, byte, and combined overflow rejection; and
- requires a newly added, indexed ADR when staged policy caps increase relative to `HEAD`.

Doctrine `README-STABILITY` is registered in `scripts/check_doctrines.sh`. The registry runs from the local
pre-commit hook and `tools/run_ci_local.sh`; hosted GitHub Actions remain disabled, so the canonical local gate is
the backstop.

Run the focused check from any working directory:

```sh
bash scripts/check_readme_stability.sh
```

## Adoption checklist

- Deliberately trim and route the existing README before setting budgets.
- Verify one minimal quick start and every retained link.
- Add the policy, checker, self-tests, doctrine registry row, and enforcement-document mirror together.
- Wire discovery through README, contributor bootstrap, Toolbox, decision record, Knowledge Map, and mdBook.
- Run the focused checker and canonical local gate; commit under an owning task-tree leaf.
