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
- latest_commit: `NONCORE-QUARANTINE.1 — dependency inventory + create noncore/ + relocate 12 zero-ref modules (.1+.2)` (hash backfilled by next hash-sync; ahead of origin ~9 — push threshold ~300; do NOT push mid-PNT). Prior: `LEGACY-VHDL-RETIRE.2+.3` (06496b4) retired the VHDL subsystem (RTLUtils hang cleared).
- active_work_unit: `NONCORE-QUARANTINE` (current focus). User direction: keep only what `LinkedSpec.pm` uses; **relocate (`git mv`) non-core `.pm`/`.plg` to `noncore/`, NOT delete** (preserve refactor/port/publish/delete options; `noncore/README.md` = parked fate ledger). The prize is the Rust/Julia/Dart ports — don't get blocked. `.1` inventory + `.2` (12 zero-ref modules → `noncore/`) **DONE** 2026-06-19. **next_action: `.3` relocate the 24 domain `.pm` per cluster (Timing/QC/Table/Web+Text/MSOffice/Lisp/misc) + remove their phase0 subtests (clears the back-half hangs) → `.4` 13 `.plg` → `.N` plugin machinery (POSTPONE, core-facade) → `.V` verify green phase0.**
- INVENTORY (`.1`): **41 KEEP** = `LinkedSpec.pm` closure (`LinkedSpec/**` owner tree via OwnerDispatch + `LinkedRE`/`PathSearch`/`RuleIR`/`HandlerVariantEmitter` + ActionIR(20) + plugin machinery `PPlugin`/`PluginBridge`/`PluginRegistry` reachable ONLY via deprecated stubs → kept-for-now). **36 non-core `.pm`** + **all 13 `.plg`** relocate to `noncore/`. Zero core→domain edges (verified). The phase0 back-half hangs (e.g. `HTML::PathLinks::link_path_tokens`, subtest 131) live in the non-core island → removing its subtests greens phase0. Lesson: dynamic edges matter (`Lispish.pm`→`get_parser('Lispish')`→PathSearch→`Lispish.spec`); reachability is directional+rooted. Fate hints in `noncore/README.md`: revive-candidate (Lispish/LispML/LibReader), replaceable (HUtils/Table*/HTML/HTTP/Text/Global/…), likely-rm (vendor-timing/Timing::*/QC::*/Tk*/MSOffice/+13 .plg).
- SPEC-FORMAT-TERSE (gate down until phase0 green): `.0` done (ADR `0007`); migration = **gradual alias**; book scorch PAUSED. TERSE: `assign`→`=`/`set`; no sigils; type inference; `copy()` unifies array+hash; methods; everything-is-an-expression. Open design Q (call-syntax, `.3.2`): uniform `callee(args)`, word+symbol, no `(op a,b)`. Reference-touching = user-sanctioned exception to [[feedback_do-not-fix-reference-engine]].
- verify: `perl -c perl/LinkedSpec.pm`; compile shipped specs; phase0 (996 subtests) runs in true background only (foreground >600s times out) and STALLS at the first non-core hang (`run_perl_snippet_in_subprocess` `t/phase0_regression.t:45946` has no timeout) — per-batch verification = phase0's stall point advancing.
- blockers: (1) phase0 not green — the non-core island's subtests hang/fail; cleared incrementally by `NONCORE-QUARANTINE.3`/`.4`. Gates `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched).
