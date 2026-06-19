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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.1 — correct framing: 65 are NOT confirmed reference defects; engine FROZEN` (hash backfilled next; ahead of origin ~13 — push threshold ~300; do NOT push mid-PNT). Prior: `3a6d25b` (.1 triage), `f9c34fe` (triage WIP).
- **FRESH SESSION RECOMMENDED (2026-06-19): prior session's focus degraded (overclaimed "engine defect"). Repo is handoff-ready at this commit.**
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (`.1` triage DONE). 173 failing phase0 subtests → **108 STALE (re-bless, TEST-ONLY) + 65 NOT-STALE but REMEDY UNRESOLVED.** The 108 STALE verdicts are solid (retired `return_*` helpers/`RETURN_A` nodes; `return(1)` is a resolved plain return) and fixable in `t/` alone.
- **The 65 are NOT confirmed reference defects.** OBSERVED FACT: for an explicit `:AND`/`::AND` multi-slot rule with a `return`-bearing indexed edge, the engine builds a parser but emits invalid Perl (`SCALAR(0x…)Rule` → `near ")Top"`) ⇒ returns undef (top) / `[]` (child). **UNRESOLVED whether this is a real defect vs. tests using a non-conformant construct:** `:AND` IS documented, but (a) NO shipped spec uses explicit `:AND` (all 183 `:` / 20 `::` are default mode), (b) the failing test specs also put regex on a `::` top rule (formal-grammar marks `:AND` "Body rule only"), (c) the book's only `:AND` example (`ThirdChild:AND`, formal-grammar.md:625) uses call edges `-> A/-> B`, NOT a `return`-bearing indexed edge. So the failing combo may be undocumented/non-idiomatic. (Defect #2 "input-boundary" was sub-agent-claimed, NOT verified — treat as unconfirmed.)
- **ENGINE FROZEN — user directive 2026-06-19: "if not broke don't fix" + "do not break the reference Perl engine."** Do NOT touch `perl/` unless a fully BOOK-CONFORMANT `:AND` spec is OBJECTIVELY shown to break AND the user explicitly authorizes. See [[and-return-edge-codegen-defect]] (reframe pending) + [[feedback_do-not-fix-reference-engine]].
- next_action: (fresh session) objectively + read-only test whether the book's OWN `:AND` examples produce their documented output (start `docs/linkedspec-book/src/appendix/formal-grammar.md:605-628` + `user-model/rule-modes-and-parse-modes.md`). If a conformant spec breaks → genuine defect (surface to user, do not auto-fix). Else → re-bless/retire the 65 (TEST-ONLY) + run `.2.x` re-bless of the 108 stale. NO `perl/` change either way without proof+OK.
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c perl/LinkedSpec.pm` OK; phase0 = 173 fail/707 pass (deterministic), reached 880/959 before the bg run was terminated (exit 144 mid-881 — re-confirm 881–959). TAP `/tmp/phase0_triage.tap` (transient).
- blockers: (1) 65 not-stale phase0 failures — **remedy UNRESOLVED (defect vs. non-conformant construct); ENGINE FROZEN**; gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`).
