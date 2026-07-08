# DOCTRINE-ENFORCEMENT-ADOPT: adopt the portable Doctrine-Enforcement architecture + a LinkedSpec TOOLBOX.md

## Metadata

- Tree ID: `DOCTRINE-ENFORCEMENT-ADOPT`
- Status: `active` (created 2026-06-22)
- Roadmap lane: `Overall roadmap — durable architecture / doctrine enforcement (cross-project standard)`
- Created: `2026-06-22`
- Last updated: `2026-07-08` (`.3.1` **DONE** — evidence gate split/design; frontier → `.3.2`)
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

- ID: `DOCTRINE-ENFORCEMENT-ADOPT` · Status: `active` · Children: `.1`, `.2`, `.3`
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
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.3` · Status: `active` (split 2026-07-08)
  Goal: Add a LinkedSpec EVIDENCE/TASK-ACCEPTANCE doctrine — adapt `check_diagnosis_evidence.sh`
    (define LinkedSpec's "what counts as a code change" globs + the tool-output signature regexes from
    `TOOLBOX.md`) and register it so a code change's task leaf must carry a tool-backed WHY+WHERE +
    measured verification.
  Acceptance: `pending`  ·  Verification: split into `.3.1`-`.3.3`  ·  Commit: `pending`
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
  Commit: pending this slice.
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.3.2` · Status: `pending`
  Goal: Implement and register `scripts/check_diagnosis_evidence.sh` as the `TASK-ACCEPTANCE` doctrine.
  Acceptance: The check obeys `DOCTRINE_ENFORCEMENT.md` §4, is deterministic, mutates nothing, inspects the staged
    set, exempts non-code-only commits, fails governed changes without a staged task-file checklist, recognizes
    the `TOOLBOX.md` checklist labels, and uses conservative LinkedSpec-tool/output signatures rather than broad
    prose guesses. `scripts/check_doctrines.sh`, `DOCTRINE_ENFORCEMENT.md` §10, and `TOOLBOX.md` stay in lockstep.
  Verification: pending.
  Commit: pending.
- ID: `DOCTRINE-ENFORCEMENT-ADOPT.3.3` · Status: `pending`
  Goal: Close evidence-gate docs/no-drift after `.3.2`.
  Acceptance: mdBook development workflow/local-CI wording, root live docs, task-tree index, Knowledge Map, and
    any new fact card agree on the shipped `TASK-ACCEPTANCE` boundary; false-positive escape hatches and known
    limits are explicit.
  Verification: pending.
  Commit: pending.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `.1` | `done` 2026-06-22 | `TOOLBOX.md` written (LinkedSpec's OWN tools foregrounded; supporting techniques demoted to §6). Landed atomically with `.2`. |
| — | `.2` | `done` 2026-06-22 | Enforcement kit landed: `DOCTRINE_ENFORCEMENT.md` + driver (`scripts/check_doctrines.sh`, 2/2 PASS) + pre-commit→driver + run_ci_local→driver + discovery + ADR `0009`. |
| — | `.3.1` | `done` 2026-07-08 | Split/design completed; `.3` is now implementation/closeout children. |
| 1 | `.3.2` | `pending` | Implement/register the scope-aware staged `TASK-ACCEPTANCE` evidence checker. |
| 2 | `.3.3` | `pending` | Close docs/KM/no-drift after the checker lands. |

## Decisions

- `2026-06-22`: Replay the `pgen/DOCTRINE_ENFORCEMENT.md` standard rather than re-derive it. Start the
  registry with the two EXISTING structural checks (memory-arch, Knowledge Map) so the driver is honest
  and green from day one; grow LinkedSpec-specific doctrines incrementally. The evidence-archetype gate
  (`.3`) is deferred because its signatures + change-scope globs must be designed for LinkedSpec's tools
  to avoid false-positives.
- `2026-07-08`: Reactivate `.3` by splitting before code. The first implementation should be staged-set and
  checklist-shape aware, not a broad historical task-tree audit. It should avoid running arbitrary pasted commands
  from a hook; the reproducibility/oracle leg remains the broader local gate.

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

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1`+`.2` | `DOCTRINE-ENFORCEMENT-ADOPT.1+.2 — adopt Doctrine-Enforcement architecture (driver+registry+gates) + LinkedSpec TOOLBOX.md` | this commit (landed atomically — mutual references) |
| `.3.1` | `pending` | split/design slice |

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
