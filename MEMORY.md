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
- latest_commit: `LEGACY-VHDL-RETIRE.2+.3 — retire the Perl-only legacy VHDL/RTL/FSM subsystem (3 modules + 6 .plg + phase0 smoke)` (hash backfilled by next hash-sync; ahead of origin ~8 — push threshold ~300; do NOT push mid-PNT)
- active_work_unit: `LEGACY-VHDL-RETIRE` — `.1`/`.2`/`.3` **DONE** 2026-06-18 (user "Full subsystem closure"). Subsystem retired (`git rm` 3 modules + 6 `.plg`; phase0 smoke cleaned). **RTLUtils hang CLEARED** (proven via pristine-HEAD worktree: original hangs at subtest 110 `add_header_n_context_clause`/`RTLUtils.pm:104`; post-retirement runs past to 130+; the `.1` "line 746" claim was WRONG, now corrected). **next_action: user decision on a BACK-HALF fix track** (surfaced via AskUserQuestion) — see below.
- **BACK-HALF DISCOVERY (blocks the gate):** removing the RTLUtils hang unmasked the back half of phase0 (subtests 111+, previously dark). It has a SECOND pre-existing, unrelated hang — **`HTML::PathLinks::link_path_tokens` (subtest 131)** — + back-half failures. `require HTML::PathLinks`/`HTTP::FileAccess` load fine; the *call* hangs. NOT caused by the retirement (HTML::PathLinks deps are all kept modules; pristine HEAD never reached 111+). So **phase0 is still not green; the `SPEC-FORMAT-TERSE` gate stays blocked — now by the back-half, not RTLUtils.** `LEGACY-VHDL-RETIRE.4`/`.5` reblocked on a back-half fix track (likely a new tree; user to decide scope). Doc drift to fix in `.5`: `generic_fake_memory_module.plg`/`wrapgen.plg` cited but gone (`ROADMAP_V2:157`/`ARCHITECTURE_STATE:588`).
- SPEC-FORMAT-TERSE (gate still down): `.0` done (ADR `0007`); migration policy = **gradual alias**; `SPEC-LANG-REFERENCE` book scorch PAUSED. TERSE SEMANTICS: `assign(x,v)`→`x = v`/`set`; **no sigils**; type inference at init / by arg position; `copy()` unifies array+hash; arrays/hashes/numbers/strings have **methods**; **everything is an expression**. Open design Q (call-syntax, ratify in `.3.2`): my rec = uniform `callee(args)`, word canonical + symbol alias, no `(op a,b)`. Reference-touching here is a user-sanctioned exception to [[feedback_do-not-fix-reference-engine]].
- verify tool: private driver `/tmp/lsq_me/run.pl <spec> '<input>'` + `/tmp/lsq_me/runpm.pl <spec> '<input>' [mode]`; `perl -I perl`, scalar-ref input, `JSON::PP->canonical`; reproduces `["hello-world"]`. phase0 runs in true background (foreground >600s times out); back half is subprocess-heavy + hangs at subtest 131.
- blockers: (1) **NEW** phase0 back-half hang `HTML::PathLinks::link_path_tokens` (subtest 131) + back-half failures — gates `SPEC-FORMAT-TERSE`; needs a fix track. (RTLUtils hang now cleared.) (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched).
