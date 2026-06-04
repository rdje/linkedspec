# MEMORY-ARCHITECTURE-DOC: Adopt the durable agent-memory architecture standard

## Metadata

- Tree ID: `MEMORY-ARCHITECTURE-DOC`
- Status: `active`
- Roadmap lane: `Durable memory architecture (cross-project standard)`
- Created: `2026-06-04`
- Last updated: `2026-06-04`
- Active frontier: `MEMORY-ARCHITECTURE-DOC.1`
- Owner: repo-local workflow

## Goal

Adopt the portable, harness-agnostic `MEMORY_ARCHITECTURE.md` standard in this
repository so agent memory survives session loss, crash, machine loss, and a
switch of AI model or harness — and is hard to ignore because mechanical gates
enforce it. This mirrors the standard's own §11 adoption checklist and the
reference implementation in the sibling `specforge` project.

## Non-Goals

- Adopting the optional composed "Knowledge Map" retrieval layer
  (`KNOWLEDGE_MAP_ARCHITECTURE.md` / `knowledge-map/`). The standard treats it as
  additive; it is out of scope for this tree and may be a later follow-on.
- Re-enabling hosted GitHub Actions (it stays disabled to preserve minutes; the
  CI gate runs through `tools/run_ci_local.sh`, which `ci.yml` delegates to).
- Deleting historical `MEMORY.md` content — git already preserves it; we stop
  carrying it forward.

## Acceptance Criteria

- `MEMORY_ARCHITECTURE.md` is at the repo root and reachable from `README.md`.
- The four layers exist: A = bounded `MEMORY.md` resume pointer (≤ cap); B =
  task-trees (already present); C = `docs/decisions/` records + index; D = git.
- Tool-neutral bootstrap pointers (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`,
  `.github/copilot-instructions.md`) each route to `MEMORY_ARCHITECTURE.md` + `README.md`.
- Enforcement is live and demonstrably biting: `scripts/check_memory_architecture.sh`
  (E2) wired into `.githooks/` (E3, `core.hooksPath`) and `tools/run_ci_local.sh` /
  `ci.yml` (E4); the commit-msg gate accepts linkedspec's real subject scheme and
  rejects non-compliant subjects.
- `COMMIT.md` reconciled: `MEMORY.md` is documented as the overwrite-only bounded
  resume pointer, not a cumulative log.
- Local CI gate green end-to-end (memory-arch check first, then phase0 regression).
- Each leaf committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `MEMORY-ARCHITECTURE-DOC`
  Status: `active`
  Goal: `Adopt the durable agent-memory architecture standard in this repo.`
  Children: `MEMORY-ARCHITECTURE-DOC.1`, `MEMORY-ARCHITECTURE-DOC.2`, `MEMORY-ARCHITECTURE-DOC.3`, `MEMORY-ARCHITECTURE-DOC.4`, `MEMORY-ARCHITECTURE-DOC.5`

- ID: `MEMORY-ARCHITECTURE-DOC.1`
  Status: `done`
  Goal: `Author the portable standard: add MEMORY_ARCHITECTURE.md (project-agnostic, verbatim from the cross-project standard) at the repo root, and add doc-map pointers from README.md (and the SESSION_BOOTSTRAP.md chain) so the tool-neutral entrypoint reaches it.`
  Acceptance: `MEMORY_ARCHITECTURE.md present at root; README.md documentation map references it; SESSION_BOOTSTRAP.md routes to it. No behavior/code change.`
  Verification: `2026-06-04: MEMORY_ARCHITECTURE.md copied verbatim (419 lines, byte-identical to the cross-project source) with one added note marking the optional Knowledge Map (§5) as not-adopted-here to avoid a dangling reference. README.md updated in three places: a new "durable memory architecture" + docs/decisions layer bullet under Documentation Layers, MEMORY.md reframed as the bounded layer-A resume pointer, ramp-up map item 1 now points to MEMORY_ARCHITECTURE.md, and the top-level docs path map lists MEMORY_ARCHITECTURE.md / docs/decisions/ / AGENTS.md+mirrors. SESSION_BOOTSTRAP.md now reads MEMORY_ARCHITECTURE.md first and references docs/decisions/. No code touched — perl -c perl/LinkedSpec.pm OK; phase0 1004 PASS baseline holds.`
  Commit: `pending (leaf ID in commit subject)`

- ID: `MEMORY-ARCHITECTURE-DOC.2`
  Status: `done`
  Goal: `Create layer C: docs/decisions/ with INDEX.md and seed it by migrating durable cross-cutting facts out of harness-only/home-dir memory and buried MEMORY.md prose into dated ADR-style records (Context → Decision → Consequences). At minimum: the task-tree-ownership + commit doctrine (currently in ~/.claude harness memory), the all-target language_agnostic_ready_ratio==1.0000 corpus invariant, and the no-drift roadmap/codebase/book rule.`
  Acceptance: `docs/decisions/INDEX.md plus the seed records exist; each record is dated with Context/Decision/Consequences and linked from the relevant task-trees/docs.`
  Verification: `2026-06-04: Created docs/decisions/ with INDEX.md (layer C) plus 4 dated ADR records: 0001 task-tree-ownership + strict commit workflow + zero-drift doctrine (migrated out of harness ~/.claude memory into the tracked repo), 0002 all-target ActionIR-ready invariant (ratio==1.0000, zero compatibility-surface rules), 0003 raw-Perl-free .spec authoring policy, 0004 hosted-CI-disabled / local-gate-is-source-of-truth. Each is Context→Decision→Consequences→Links and points at the authoritative tracked docs rather than duplicating them. INDEX rows match the 4 record files exactly. No code change — perl -c OK; phase0 1004 PASS baseline holds.`
  Commit: `pending (leaf ID in commit subject)`

- ID: `MEMORY-ARCHITECTURE-DOC.3`
  Status: `pending`
  Goal: `Demote MEMORY.md (currently 5202 lines, cumulative) to the bounded overwrite-only resume-pointer template (≤ ~50–60 lines), with history preserved in git. Reconcile COMMIT.md, which currently mandates MEMORY.md as "cumulative and not reset", to the new resume-pointer role.`
  Acceptance: `MEMORY.md matches the §6 resume-pointer template and is ≤ the line cap; COMMIT.md describes MEMORY.md as the overwrite-only bounded resume pointer (history in git + task-trees + decisions). No prior MEMORY.md content lost (it remains in git history).`
  Verification: `pending`
  Commit: `pending`

- ID: `MEMORY-ARCHITECTURE-DOC.4`
  Status: `pending`
  Goal: `Install enforcement (§9). Add scripts/check_memory_architecture.sh (E2, knobs adapted: line cap, docs/tasks, docs/decisions, AGENTS.md+CLAUDE.md). Add .githooks/pre-commit (runs the self-check) and .githooks/commit-msg (E3) with a regex adapted to linkedspec's commit scheme (unit-id token anywhere in subject OR first body line, OR a maintenance prefix like "Docs:"). Set core.hooksPath .githooks. Add the four bootstrap pointers (E1). Wire the self-check into tools/run_ci_local.sh and reflect it in ci.yml (E4). Prove the gates bite (reject a bad subject / over-cap MEMORY.md; accept a compliant one).`
  Acceptance: `Hooks active via core.hooksPath; the self-check passes on the compliant tree and fails on an injected violation; commit-msg accepts a real linkedspec subject and rejects a non-compliant one; run_ci_local.sh runs the self-check before the regression gate; the .4 install commit itself passes through the now-active hooks.`
  Verification: `pending`
  Commit: `pending`

- ID: `MEMORY-ARCHITECTURE-DOC.5`
  Status: `pending`
  Goal: `Verify end-to-end: run the full local CI gate (memory-arch self-check first, then perl -c + phase0 regression), confirm green; sync the live docs (CHANGES.md, DEVELOPMENT_NOTES.md, MEMORY.md resume pointer, LIVE_ACHIEVEMENT_STATUS.md, docs/TASK_TREE.md); close the tree.`
  Acceptance: `tools/run_ci_local.sh exits 0 with the memory-arch check passing and phase0 PASS; live docs synced; tree marked done and moved to Completed in docs/TASK_TREE.md.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `MEMORY-ARCHITECTURE-DOC.1` | `done` | Standard added at root + README/SESSION_BOOTSTRAP routed to it. perl -c OK. |
| 2 | `MEMORY-ARCHITECTURE-DOC.2` | `done` | docs/decisions/ + INDEX + 4 seed records created. perl -c OK. |
| 3 | `MEMORY-ARCHITECTURE-DOC.3` | `pending` | MEMORY.md must be ≤ cap before the pre-commit self-check can pass. |
| 4 | `MEMORY-ARCHITECTURE-DOC.4` | `pending` | Enforcement is installed only once the layers it checks are all in place. |
| 5 | `MEMORY-ARCHITECTURE-DOC.5` | `pending` | Final end-to-end verification + live-doc sync + close. |

## Decisions

- `2026-06-04`: Adopt the standard verbatim (`MEMORY_ARCHITECTURE.md` is project-agnostic by design); customize only the documented knobs — line cap (60), commit-msg unit-id regex (linkedspec's hyphenated tree-id `.leaf` scheme + "Docs:"-style maintenance prefixes), and the tasks-dir / commit-workflow-doc names.
- `2026-06-04`: Exclude the optional Knowledge Map layer (matches specforge's 5-leaf memory-architecture adoption; the bootstrap pointers here omit Knowledge Map references). May revisit as a follow-on tree.
- `2026-06-04`: Reconcile the existing COMMIT.md rule "MEMORY.md is cumulative and not reset" — it conflicts with the bounded overwrite-only resume-pointer model. COMMIT.md is updated in `.3`; history is preserved in git, so no information is lost.
- `2026-06-04`: Order leaves so each gate's preconditions exist before the gate is activated: standard (.1) → decisions (.2) → bounded MEMORY.md (.3) → enforcement (.4) → verify/close (.5). This lets the `.4` install commit pass through its own newly-active hooks.

## Open Questions

- None blocking.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-04` | `MEMORY-ARCHITECTURE-DOC.1` | `diff -q` vs source (byte-identical 419 lines); README/SESSION_BOOTSTRAP pointer review; `perl -c perl/LinkedSpec.pm`. | Pass — standard at root + discoverable; no code change; phase0 1004 PASS baseline holds. Frontier → `.2`. |
| `2026-06-04` | `MEMORY-ARCHITECTURE-DOC.2` | `ls docs/decisions/` + INDEX↔files cross-check (4/4 match); `perl -c perl/LinkedSpec.pm`. | Pass — layer C created with 4 seed ADR records; no code change; phase0 1004 PASS baseline holds. Frontier → `.3`. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `MEMORY-ARCHITECTURE-DOC.1` | `Add MEMORY_ARCHITECTURE.md standard + README/bootstrap pointers (MEMORY-ARCHITECTURE-DOC.1)` | Hash `119665a`. |
| `MEMORY-ARCHITECTURE-DOC.2` | `Add docs/decisions/ layer C + 4 seed decision records (MEMORY-ARCHITECTURE-DOC.2)` | Hash backfilled later if useful. |

## Changelog

- `2026-06-04`: Completed `MEMORY-ARCHITECTURE-DOC.2` — created `docs/decisions/` (layer C) with `INDEX.md` and 4 dated ADR records (0001 doctrine, 0002 ActionIR-ready invariant, 0003 raw-Perl-free policy, 0004 hosted-CI-disabled). Migrated the doctrine out of harness-home-dir memory into the tracked repo. Active frontier: `.3`.
- `2026-06-04`: Completed `MEMORY-ARCHITECTURE-DOC.1` — added `MEMORY_ARCHITECTURE.md` at the repo root (verbatim project-agnostic standard; Knowledge Map §5 marked not-adopted) and wired the doc-map pointers in `README.md` + `SESSION_BOOTSTRAP.md`. Active frontier: `.2`.
- `2026-06-04`: Created task tree to adopt the durable agent-memory architecture standard in linkedspec, mirroring the sibling specforge adoption (5 leaves), after the user directed implementing "everything the standard recommends" here.
