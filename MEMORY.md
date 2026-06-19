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
- Durable facts/decisions live in `docs/decisions/` (index: `INDEX.md`).
- Doctrine (non-negotiable): no change without an owning task-tree leaf first — see
  `docs/decisions/0001-task-tree-and-commit-doctrine.md`.
- Before committing, run `scripts/check_memory_architecture.sh` (git hooks + the local CI
  gate `tools/run_ci_local.sh` enforce it).

## Current state (OVERWRITE this block each update — do not append)
- latest_commit: `NONCORE-QUARANTINE.3+.4 — relocate 23 domain .pm + 13 .plg to noncore/ + excise their 37 phase0 subtests` (hash backfilled by next hash-sync; ahead of origin ~10 — push threshold ~300; do NOT push mid-PNT). Prior: `336bded` (.1+.2, 12 zero-ref modules), `06496b4` (LEGACY-VHDL-RETIRE).
- active_work_unit: `NONCORE-QUARANTINE`. **Relocation DONE 2026-06-19** — `.1`/`.2`/`.3`/`.4` complete: ALL 36 non-core `.pm` + 13 `.plg` are in `noncore/` (git mv, layout preserved; `noncore/README.md` ledger); the 37-subtest legacy-migration block (phase0 source lines 3312–5378) excised; emptied `perl/{HTML,HTTP,MSOffice,QC,Text,Timing,Table,Plugin}/` + `plugin/` rmdir'd. `perl -c perl/LinkedSpec.pm` OK; `git grep`=0 island refs in tests. `perl/` is now CORE-ONLY (LinkedSpec.pm + LinkedSpec/** + LinkedRE/PathSearch/PPlugin). Plugin machinery (PPlugin/PluginBridge/PluginRegistry + deprecated LinkedSpec.pm stubs) kept-for-now (`.N` POSTPONE, core-facade).
- **NEW DISCOVERY (blocks `.V`/green phase0 — NOT caused by this work):** with the island hangs gone, phase0 now runs the long-dark back half (subtests ~111+) and reveals **~173 PRE-EXISTING, REAL core-engine test failures** — structural/shape assertion mismatches (0 timeouts, 0 missing-module errors), clustered `method_like`×75, `named_mark`×25, `emit_context`×21, capture/mark/entry families. **My work changed ZERO engine bytes** (only `git mv` of non-engine files + test-subtest removal + docs), so these fail identically on the prior engine — they were masked by the original hang and never ran. Likely STALE tests (written for evolved ActionIR/handler behavior, never re-run) vs real regressions — needs a decision (a new investigation tree). **next_action: surface the 173 to the user; decide stale-vs-real + scope.**
- ALSO: external CPU contention observed — another session's `bin/fsmgen --emit-semantic-json` (100% CPU) + `t/303-*`/`t/372-*` (NOT this task; not killed) slows phase0 runs (alarm-guarded subprocess tests); not the cause of the 173 (those are structural).
- SPEC-FORMAT-TERSE (gate down until phase0 green): `.0` done (ADR `0007`); migration = **gradual alias**; book scorch PAUSED. TERSE: `assign`→`=`/`set`; no sigils; type inference; `copy()` unifies array+hash; methods; everything-is-an-expression. Open Q (call-syntax `.3.2`): uniform `callee(args)`, word+symbol, no `(op a,b)`. Reference-touching = sanctioned exception to [[feedback_do-not-fix-reference-engine]].
- verify: `perl -c perl/LinkedSpec.pm`; phase0 (now 959 subtests) runs to ~940/959 then is slowed by external contention; clean reach was 880 quickly. The 173 failures are deterministic (same count across runs). `run_perl_snippet_in_subprocess` (`t/phase0_regression.t:45946`) has no per-child timeout.
- blockers: (1) **~173 pre-existing back-half core test failures** (method_like/named_mark/emit_context/...) — gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. Decision pending. (2) external `bin/fsmgen` CPU contention (not mine). (3) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`).
