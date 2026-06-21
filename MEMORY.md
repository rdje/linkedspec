# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL (Perl). This file is **layer A** of
`MEMORY_ARCHITECTURE.md`: the bounded, overwrite-only pointer to *now* — not a log. Its
full history lives in git (layer D); per-unit work lives in the task-trees (layer B);
durable cross-cutting facts live in `docs/decisions/` (layer C).

## How to resume
- Read `MEMORY_ARCHITECTURE.md` (the memory system — mandatory and mechanically enforced)
  and `README.md` (project objective/layout), then `SESSION_BOOTSTRAP.md`.
- Work is tracked in task-trees under `docs/tasks/` (index: `docs/TASK_TREE.md`); follow
  the commit workflow in `COMMIT.md` with the task-tree leaf id in the subject.
- Durable facts/decisions live in `docs/decisions/` (index: `INDEX.md`); fact cards in
  `docs/knowledge/` (retrieval index `KNOWLEDGE_MAP.md`).
- Doctrine (non-negotiable): no change without an owning task-tree leaf first — see
  `docs/decisions/0001-task-tree-and-commit-doctrine.md`.
- Before committing, run `scripts/check_memory_architecture.sh` (git hooks + the local CI
  gate `tools/run_ci_local.sh` enforce it).

## Current state (OVERWRITE this block each update — do not append)
- latest_commit: `PHASE0-BACKHALF-TRIAGE.2.2 — split cluster B into .2.2.1 (B2 token re-bless) + .2.2.2 (B1 helper rewrites)` (hash backfilled next; ahead of origin ~17 — push threshold ~300; do NOT push mid-PNT). Prior: `07c4eb7` (.2.1 cluster A).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; `.3`+`.4` engine fixes DONE (ADR `0008`); `.2.1` DONE (cluster A re-bless, 7 TEST-ONLY). **`.2.2` SPLIT 2026-06-21** (recon + empirical probe — decomposition slice, no test change).
- **`.2.2` (cluster B = 76) split → `.2.2.1` + `.2.2.2`:** recon = B1 18 (retired helper in spec body) / B2 55 (retired `RETURN_A` token in assertion) / BOTH 3 (subtests @17289, @20105, @39213). Empirical: canonical return node is now **`RETURN`** (not `RETURN_A`/`RETURN_M`); `return_a/return_m/return_ma/return_imatch/return_im/return_array` retired → **`RAW_PERL`** passthrough. **Scope hazard:** `RETURN_A` appears 90× across B + C (`emit_context` 12400/12588/12628) + passing helper-event tests (39526/39553/39581) → NOT a global replace. KM [[actionir-return-node-retired-to-return]].
- next_action: **`.2.2.1`** — re-bless `RETURN_A` → `RETURN` in the 55 pure-B2 `method_like*` subtests ONLY (scoped; in `canonical_action_ir_nodes` greps + `canonical_action_ir_hits` keys; **merge** when a hits hash has both `RETURN` and `RETURN_A`, e.g. @39434/39435). EXCLUDE the 3 BOTH + cluster-C + the passing helper-event sites. Then `.2.2.2` (B1 21 helper-rewrites, judgment-heavy — needs the canonical mapping of each retired helper), `.2.3` (C `emit_context` ×20), `.2.4` (F=3+G=2), `.5` green-phase0 (+ corpus tail = missing `plugin/` dir, rmdir'd by NONCORE-QUARANTINE), `.6` book `:AND`.
- phase0 still **102 failing** = 101 STALE (`.2.2.x`/`.2.3`/`.2.4`) + 1 `corpus_regression` tail (`.5`). Baseline TAP `/tmp/phase0_pnt.tap`; recon work-list in `docs/tasks/PHASE0-BACKHALF-TRIAGE.md` (`.2.2.1`/`.2.2.2` nodes). NOTE: external `bin/fsmgen` (another session) ~99% CPU SIGALRM-kills the gate at the corpus tail — runs still reach subtest 941; `comm` set-diff is the reliable proof.
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c -Iperl t/phase0_regression.t` OK; phase0 = 102 fail (deterministic) after `.2.1`.
- blockers: (1) phase0 not yet green — 101 STALE re-bless (`.2.2`–`.2.4`, TEST-ONLY) + corpus tail (`.5`); gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `RTLUtils`/`VHDL::ConstantEval` retired/gone) — docs-only refresh pending.
