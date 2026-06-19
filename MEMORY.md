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
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus) — triage the ~173 pre-existing back-half core failures. **NONCORE-QUARANTINE relocation DONE** (`2baddbd`, `.1`–`.4`): ALL 36 non-core `.pm` + 13 `.plg` in `noncore/`; 37-subtest legacy block excised; `perl/` is CORE-ONLY (LinkedSpec.pm + LinkedSpec/** + LinkedRE/PathSearch/PPlugin); plugin machinery kept-for-now (`.N` POSTPONE).
- **~173 PRE-EXISTING back-half core failures (gates green phase0; NOT from this work — engine bytes unchanged, masked by the old hang).** Trace them via the EXISTING env control **`LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl <driver>`** (→ stdout, ~22k lines: ENTER/DECISION/dump). **Cluster A (parser collection-shape: `or_plus_blind_call`/`explicit_and`/`blind_call_choice`/`and_plus`/`bounded_and`/repeated, ~10+) = STALE** — reproduced: engine returns `[1,1]` (each child's `return(1)`); tests assert the retired `['?Rule:',[]]` tagged-accumulator shape → re-bless. Clusters B–E PENDING root-cause: `method_like`×75, `emit_context`×21, `named_mark`/capture/`entry_and`/`cursor`/`current_match`. **next_action: root-cause B–E with trace (judge stale-vs-real vs book/`Contracts.pm`/shipped specs), then a fix plan (re-bless vs engine-fix).** See `docs/tasks/PHASE0-BACKHALF-TRIAGE.md`.
- TRACE-OBSERVABILITY (new tree, user directive 2026-06-19): discoverable CLI trace control + comprehensive "see everything" trace (function enter/exit + if/switch/case branches). Framework EXISTS (`Trace.pm`: enter/exit/decision/levels none..debug/sinks; env `LINKEDSPEC_TRACE_LEVEL`/`_FILE`/`_MIRROR_STDOUT`/etc. — gated by `$TRACE_INITIALIZED`; bare `$DUMP_VERBOSITY` set does NOT work). Gaps: undiscoverable (no `--trace`/bin/docs) + coverage not exhaustive (esp. the generated runtime parser). `.2` (CLI+docs) = quick win; `.1` audit, `.3` extend. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- ALSO: external CPU contention — another session's `bin/fsmgen --emit-semantic-json` (100% CPU) + `t/303-*`/`t/372-*` (NOT this task; not killed) slows phase0; not the cause of the 173 (structural). **Session is very long → a fresh session is advisable; repo is handoff-ready at `2baddbd` + this WIP commit.**
- SPEC-FORMAT-TERSE (gate down until phase0 green): `.0` done (ADR `0007`); migration = **gradual alias**; book scorch PAUSED. TERSE: `assign`→`=`/`set`; no sigils; type inference; `copy()` unifies array+hash; methods; everything-is-an-expression. Open Q (call-syntax `.3.2`): uniform `callee(args)`, word+symbol, no `(op a,b)`. Reference-touching = sanctioned exception to [[feedback_do-not-fix-reference-engine]].
- verify: `perl -c perl/LinkedSpec.pm`; phase0 (now 959 subtests) runs to ~940/959 then is slowed by external contention; clean reach was 880 quickly. The 173 failures are deterministic (same count across runs). `run_perl_snippet_in_subprocess` (`t/phase0_regression.t:45946`) has no per-child timeout.
- blockers: (1) **~173 pre-existing back-half core test failures** (method_like/named_mark/emit_context/...) — gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. Decision pending. (2) external `bin/fsmgen` CPU contention (not mine). (3) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`).
