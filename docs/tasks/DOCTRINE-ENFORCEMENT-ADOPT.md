# DOCTRINE-ENFORCEMENT-ADOPT: adopt the portable Doctrine-Enforcement architecture + a LinkedSpec TOOLBOX.md

## Metadata

- Tree ID: `DOCTRINE-ENFORCEMENT-ADOPT`
- Status: `done` (created 2026-06-22; closed 2026-07-08)
- Roadmap lane: `Overall roadmap — durable architecture / doctrine enforcement (cross-project standard)`
- Created: `2026-06-22`
- Last updated: `2026-07-08` (`.3.3` **DONE** — docs/KM/no-drift closeout complete; tree closed)
- Owner: repo-local workflow

## Goal

User directive (2026-06-22): **adopt the new system `DOCTRINE_ENFORCEMENT.md`** (the 4th portable
architecture, sibling of `MEMORY_ARCHITECTURE.md` + the Knowledge Map), and **add a `TOOLBOX.md` that
lists the tools LinkedSpec uses to pinpoint issues.** Doctrine-enforcement turns each written rule into
a *mechanically-gated* check run from one driver/registry (`scripts/check_doctrines.sh`), gated by the
git hook (E3) + CI (E4) — so compliance is provable and re-checkable, never "trust me". The standard
itself is `pgen/DOCTRINE_ENFORCEMENT.md` (the authoritative source we replay here).

## Non-Goals

- Re-deriving the standard — it is `DOCTRINE_ENFORCEMENT.md` (copied verbatim; only the §10 instance
  table is adapted to LinkedSpec's registry).
- Inventing new LinkedSpec doctrines in the same slice — start by registering the **existing** structural
  checks (memory-architecture, Knowledge Map); add LinkedSpec-specific checks as later leaves.
- Touching the reference engine.

## Acceptance Criteria

- `DOCTRINE_ENFORCEMENT.md` present at repo root; its §10 instance table reflects LinkedSpec's registry.
- `scripts/check_doctrines.sh` (driver + registry) runs every registered check, reports per-doctrine
  PASS/FAIL, exits nonzero on any breach, and meta-checks that each registered check exists + is
  executable. Registry initially = `MEMORY-ARCH` + `KNOWLEDGE-MAP` (LinkedSpec's existing checks).
- `.githooks/pre-commit` regenerates+stages the derived Knowledge Map, then calls the driver (replacing
  the ad-hoc check stack with the one registry). `commit-msg` already enforces the work-unit-id scheme.
- `TOOLBOX.md` catalogs LinkedSpec's issue-pinpointing tools (WHAT/WHEN/HOW/OUTPUT per tool) + the
  task-acceptance checklist template, with the symptom→tool chooser and diagnosis protocols.
- Discovery (E1): `README.md` + the bootstrap pointers (`AGENTS.md`/`CLAUDE.md`) name
  `DOCTRINE_ENFORCEMENT.md` + `TOOLBOX.md`.
- ADR records the adoption. The driver passes (`bash scripts/check_doctrines.sh` → exit 0) and a real
  commit exercises the rewired hook successfully.

## Task Tree

- ID: `DOCTRINE-ENFORCEMENT-ADOPT` · Status: `done` (closed 2026-07-08) · Children: `.1`, `.2`, `.3`
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.1` · Status: `done` (2026-06-22)
  Goal: Write `TOOLBOX.md` — LinkedSpec's **own** diagnostic/debug toolbox catalog + the task-acceptance
    checklist template + symptom→tool chooser + diagnosis protocols.
  Result: `TOOLBOX.md` written, centered on LinkedSpec's OWN tools (per the user's "should contain
    LinkedSpec own debug tools"): §1 facade probes (`Get`/`get_parser`/`call_spec_handler_subst`/
    `build_compiled_rule_table`); §2 introspection options (`return_descriptor`, `dump_parser_source`/
    `parser_source_ref`, `parse_only`/`generate_only`, `return_state`, `runtime_ctx_ref`); §3 the
    `LINKEDSPEC_TRACE_LEVEL` trace framework (+ all env knobs); §4 the `tools/*` scripts; §5 the gates +
    KM grep. General supporting techniques (`comm` set-diff, focused-`Test::More` harness, fork+SIGKILL
    census, `perl -c`, the `PERL5LIB`/`-Iperl` hazard) demoted to §6. All tool/option names verified
    against `perl/` (not guessed). Each entry has WHAT/WHEN/HOW(exact cmd)/OUTPUT.
  Verification: tool surfaces audited (`tools/`, `LINKEDSPEC_*` env, `$option->{…}`); links resolve.
    Commit: (this commit, with `.2`)
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.2` · Status: `done` (2026-06-22)
  Goal: Adopt the enforcement kit — `DOCTRINE_ENFORCEMENT.md`; `scripts/check_doctrines.sh` (driver +
    registry); rewrite `.githooks/pre-commit` to call the driver; wire `tools/run_ci_local.sh` (E4) to
    the driver; discovery pointers; adoption ADR.
  Result: `DOCTRINE_ENFORCEMENT.md` at root (§10 = LinkedSpec instance; honest E4/CI note per ADR 0004).
    `scripts/check_doctrines.sh` (registry = `MEMORY-ARCH` + `KNOWLEDGE-MAP`; meta-checks each enforcer
    exists+executable) — `bash scripts/check_doctrines.sh` → exit 0, both PASS. `.githooks/pre-commit`
    regenerates+stages the KM then calls the driver (replacing the direct two-check stack);
    `tools/run_ci_local.sh` now calls the driver (E4) + audits the new files tracked. Discovery: README +
    AGENTS + CLAUDE name `DOCTRINE_ENFORCEMENT.md` + `TOOLBOX.md`. ADR `0009` + INDEX row.
  Verification: `bash scripts/check_doctrines.sh` exit 0 (2/2 PASS); `bash -n` clean on pre-commit +
    run_ci_local; KM in sync; the commit itself exercised the rewired pre-commit hook (driver) green.
    Commit: (this commit, with `.1`)
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.3` · Status: `done` (split and closed 2026-07-08)
  Goal: Add a LinkedSpec EVIDENCE/TASK-ACCEPTANCE doctrine — adapt `check_diagnosis_evidence.sh`
    (define LinkedSpec's "what counts as a code change" globs + the tool-output signature regexes from
    `TOOLBOX.md`) and register it so a code change's task leaf must carry a tool-backed WHY+WHERE +
    measured verification.
  Acceptance: met  ·  Verification: `.3.1`-`.3.3` complete  ·  Commit: `.3.1`-`.3.3`
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.3.1` · Status: `done` (2026-07-08)
  Goal: Split/design the evidence gate before implementation so the hard-gate avoids false positives.
  Result: `.3` is split into a narrow staged sequence:
    `.3.2` implements a scope-aware staged-change checker and registers `TASK-ACCEPTANCE`;
    `.3.3` reconciles docs, Knowledge Map, and no-drift state after the gate exists.
    The design keeps the first checker presence/shape-based: it governs staged code/spec/test/tooling changes,
    requires a staged owning task file, and requires a real task-acceptance checklist with LinkedSpec-tool
    signatures for issue/reproduction, WHY+WHERE, verification, no-regression, and lockstep docs. It deliberately
    does not try to re-run arbitrary cited commands in the hook; that oracle leg stays with the local CI gate.
  Verification: task-tree split review; Knowledge Map search found no existing evidence-gate fact beyond ADR
    `0009` / this task; relevant enforcement owner paths read (`scripts/check_doctrines.sh`,
    `scripts/check_task_tree_metadata.sh`, `.githooks/pre-commit`, `tools/run_ci_local.sh`, `TOOLBOX.md`).
  Commit: `6c1d6258 DOCTRINE-ENFORCEMENT-ADOPT.3.1 - split evidence gate before code`.
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.3.2` · Status: `done` (2026-07-08)
  Goal: Implement and register `scripts/check_diagnosis_evidence.sh` as the `TASK-ACCEPTANCE` doctrine.
  Result: Added executable `scripts/check_diagnosis_evidence.sh`, registered `TASK-ACCEPTANCE` in
    `scripts/check_doctrines.sh`, updated `DOCTRINE_ENFORCEMENT.md`, `TOOLBOX.md`, `tools/run_ci_local.sh`,
    the mdBook local-CI chapter, ADR `0009`, and a Knowledge fact card. The check inspects staged changes,
    passes when no governed code/spec/test/tooling paths are staged, and otherwise requires a staged
    `docs/tasks/*.md` file with a completed `TOOLBOX.md` acceptance checklist plus LinkedSpec-tool, WHY/WHERE,
    and verification signatures.
  Acceptance: met.
  Verification: `bash scripts/check_diagnosis_evidence.sh` (no staged governed changes); staged self-check with
    this `.3.2` commit content; `bash scripts/check_doctrines.sh`; `bash scripts/check_memory_architecture.sh`;
    `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `git diff --check`.
  Commit: `135f7bbb DOCTRINE-ENFORCEMENT-ADOPT.3.2 - implement task acceptance evidence gate`.

### Acceptance Checklist — DOCTRINE-ENFORCEMENT-ADOPT.3.2
- [x] **REPRODUCE / ISSUE** — `rg -n "TASK-ACCEPTANCE|check_diagnosis_evidence|Acceptance Checklist" scripts DOCTRINE_ENFORCEMENT.md TOOLBOX.md docs/tasks` showed the evidence gate was still planned/deferred or absent before this slice.
- [x] **ROOT CAUSE (WHY + WHERE)** — `DOCTRINE_ENFORCEMENT.md:242`, `TOOLBOX.md:33`, and `scripts/check_doctrines.sh:35` showed the missing mechanism: the driver had no `TASK-ACCEPTANCE` registry entry and no staged task-file evidence checker.
- [x] **FIX** — Added `scripts/check_diagnosis_evidence.sh`, registered `TASK-ACCEPTANCE`, and synced `DOCTRINE_ENFORCEMENT.md`, `TOOLBOX.md`, `tools/run_ci_local.sh`, mdBook local-CI docs, ADR `0009`, and Knowledge Map source facts.
- [x] **ADDRESSED (verified)** — `bash scripts/check_diagnosis_evidence.sh` passes for no staged governed paths and passes with this staged `.3.2` task checklist while `scripts/check_doctrines.sh` reports all registered doctrines PASS.
- [x] **NO REGRESSION** — `bash scripts/check_doctrines.sh`, `bash scripts/check_memory_architecture.sh`, `bash scripts/check_task_tree_metadata.sh`, `mdbook build docs/linkedspec-book`, and `git diff --check` pass.
- [x] **LOCKSTEP** — `DOCTRINE_ENFORCEMENT.md`, `TOOLBOX.md`, `docs/linkedspec-book/src/development/local-ci-and-regression.md`, ADR `0009`, `docs/knowledge/task-acceptance-evidence-gate-boundary.md`, this task tree, and live docs are updated together.
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.3.3` · Status: `done` (2026-07-08)
  Goal: Close evidence-gate docs/no-drift after `.3.2`.
  Result: Closed the evidence-gate no-drift pass. `DOCTRINE_ENFORCEMENT.md`, `TOOLBOX.md`, the mdBook local-CI
    chapter, ADR `0009`, the Knowledge fact card, the task-tree index, and live resume docs now agree that
    `TASK-ACCEPTANCE` is a staged evidence-shape gate. The false-positive path is explicit: inspect
    `git diff --cached --name-only`, then unstage unrelated governed files, stage/update the owning task leaf, or
    split the work. The known limit is also explicit: the check proves staged evidence shape/ownership, not
    truthfulness or historical completeness.
  Acceptance: met.
  Verification: `rg -n "TASK-ACCEPTANCE|check_diagnosis_evidence|false-positive|git diff --cached --name-only"`
    across root docs, mdBook, ADR, Knowledge, and this task tree; `knowledge-map/scripts/gen_knowledge_map.sh`;
    `bash scripts/check_doctrines.sh`; `bash scripts/check_memory_architecture.sh`;
    `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `git diff --check`.
  Commit: pending this slice.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `.1` | `done` 2026-06-22 | `TOOLBOX.md` written (LinkedSpec's OWN tools foregrounded; supporting techniques demoted to §6). Landed atomically with `.2`. |
| — | `.2` | `done` 2026-06-22 | Enforcement kit landed: `DOCTRINE_ENFORCEMENT.md` + driver (`scripts/check_doctrines.sh`, 2/2 PASS) + pre-commit→driver + run_ci_local→driver + discovery + ADR `0009`. |
| — | `.3.1` | `done` 2026-07-08 | Split/design completed; `.3` is now implementation/closeout children. |
| — | `.3.2` | `done` 2026-07-08 | Implemented/registered the scope-aware staged `TASK-ACCEPTANCE` evidence checker. |
| — | `.3.3` | `done` 2026-07-08 | Closed docs/KM/no-drift after the checker landed; no current frontier remains. |

## Decisions

- `2026-06-22`: Replay the `pgen/DOCTRINE_ENFORCEMENT.md` standard rather than re-derive it. Start the
  registry with the two EXISTING structural checks (memory-arch, Knowledge Map) so the driver is honest
  and green from day one; grow LinkedSpec-specific doctrines incrementally. The evidence-archetype gate
  (`.3`) is deferred because its signatures + change-scope globs must be designed for LinkedSpec's tools
  to avoid false-positives.
- `2026-07-08`: Reactivate `.3` by splitting before code. The first implementation should be staged-set and
  checklist-shape aware, not a broad historical task-tree audit. It should avoid running arbitrary pasted commands
  from a hook; the reproducibility/oracle leg remains the broader local gate.
- `2026-07-08`: Ship `.3.2` as a staged evidence-shape check. It governs `.github/workflows/`, `.githooks/`,
  `bin/`, `perl/`, `rust/`, `specs/`, `t/`, `tools/`, and `scripts/` paths, requires a staged task checklist,
  and deliberately leaves arbitrary command re-execution to focused validation and the local CI gate.
- `2026-07-08`: Close `.3.3` by aligning root docs, mdBook, ADR, Knowledge, task-tree index, and live docs on
  the shipped `TASK-ACCEPTANCE` boundary, including the false-positive escape path and known limits. No executable
  behavior changed.

## Open Questions

- Which LinkedSpec-specific doctrines beyond memory-arch + Knowledge Map deserve a mechanical check
  (e.g. the all-spec ActionIR-ready invariant `ADR 0002`; the engine-frozen doctrine; phase0 greenness
  once `.5.2` is resolved)? Capture as `.3+` candidates.

## Blockers

- None for `.1`/`.2`. `.3` is deferred (design care), not blocked.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-22` | `.1` | tool-surface audit (`ls tools/`, `LINKEDSPEC_*` env grep, `$option->{…}` grep) so every entry is real not guessed; link check | `done` — `TOOLBOX.md` centered on LinkedSpec's own tools |
| `2026-06-22` | `.2` | `bash scripts/check_doctrines.sh` (exit 0, 2/2 PASS); `bash -n` on pre-commit + run_ci_local; `check_knowledge_map.sh` in sync; the commit's own pre-commit run (driver) | `done` — kit live; driver green; hooks valid |
| `2026-07-08` | `.3.1` | Bootstrap/read review; Knowledge Map search for existing evidence-gate facts; task-tree split/design review; relevant enforcement owner paths read | `done` — `.3` split into `.3.2` implementation and `.3.3` closeout |
| `2026-07-08` | `.3.2` | `bash scripts/check_diagnosis_evidence.sh`; staged self-check; `bash scripts/check_doctrines.sh`; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `git diff --check` | `done` — `TASK-ACCEPTANCE` gate implemented and registered |
| `2026-07-08` | `.3.3` | no-drift `rg` scans for `TASK-ACCEPTANCE`, `check_diagnosis_evidence`, false-positive/known-limit wording, and `git diff --cached --name-only`; Knowledge Map regeneration; doctrine, memory-architecture, task-tree metadata, mdBook, whitespace gates | `done` — docs/KM/no-drift closeout complete |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1`+`.2` | `DOCTRINE-ENFORCEMENT-ADOPT.1+.2 — adopt Doctrine-Enforcement architecture (driver+registry+gates) + LinkedSpec TOOLBOX.md` | this commit (landed atomically — mutual references) |
| `.3.1` | `6c1d6258 DOCTRINE-ENFORCEMENT-ADOPT.3.1 - split evidence gate before code` | split/design slice |
| `.3.2` | `135f7bbb DOCTRINE-ENFORCEMENT-ADOPT.3.2 - implement task acceptance evidence gate` | implementation slice |
| `.3.3` | `pending` | docs/KM/no-drift closeout slice |

## Changelog

- `2026-06-22`: Created on the user directive to adopt `DOCTRINE_ENFORCEMENT.md` + add a LinkedSpec
  `TOOLBOX.md`. Decomposed into `.1` (TOOLBOX.md), `.2` (enforcement kit), `.3` (deferred evidence gate).
  Kit read from `pgen/` (driver, evidence check, hooks, TOOLBOX template).
- `2026-06-22`: `.1` + `.2` **DONE** (landed atomically — mutually referential). `.1`: wrote `TOOLBOX.md`
  centered on LinkedSpec's OWN debug tools (after the user's clarification "should contain LinkedSpec own
  debug tools") — facade probes, introspection options, the trace framework, the `tools/*` scripts, the
  gates; generic techniques demoted to §6; every tool/option verified against `perl/`. `.2`: adopted the
  kit — `DOCTRINE_ENFORCEMENT.md` (§10 = LinkedSpec instance), `scripts/check_doctrines.sh` (driver +
  registry = `MEMORY-ARCH` + `KNOWLEDGE-MAP`, meta-checked), `.githooks/pre-commit` → driver,
  `tools/run_ci_local.sh` → driver (E4), discovery pointers (README/AGENTS/CLAUDE), ADR `0009` + INDEX.
  Driver 2/2 PASS; hooks `bash -n` clean. `.3` (evidence/task-acceptance hard-gate) deferred. Frontier → `.3`.
- `2026-07-08`: `.3.1` **DONE**. Reactivated the deferred evidence gate by splitting it before code:
  `.3.2` will implement/register the scope-aware staged `TASK-ACCEPTANCE` checker, and `.3.3` will close docs,
  Knowledge Map, and no-drift state. The design explicitly avoids a broad historical metadata audit and keeps
  command re-execution out of the hook; presence/signature checks run locally while the broader local CI gate
  remains the reproducibility oracle. Frontier → `.3.2`.
- `2026-07-08`: `.3.2` **DONE**. Added and registered `scripts/check_diagnosis_evidence.sh` as the
  `TASK-ACCEPTANCE` doctrine. Synced the standard/toolbox/local gate/mdBook/ADR/KM/task/live docs with the
  shipped staged evidence-shape boundary. Frontier → `.3.3`.
- `2026-07-08`: `.3.3` **DONE**. Closed docs/KM/no-drift for the shipped `TASK-ACCEPTANCE` gate and closed
  `DOCTRINE-ENFORCEMENT-ADOPT`; no frontier remains in this tree.
