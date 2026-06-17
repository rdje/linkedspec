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
- latest_commit: `SPEC-LANG-REFERENCE.10.1 — investigation: single-slot AND drops its edge return ([]) is a Perl-reference regression, not intended (KM card + verdict)` (hash backfilled by next hash-sync; ahead of origin: ~156; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc request; PNT loop authorized 2026-06-17 but **HELD by user** until `.10` decided). Done: `.1`–`.4`, `.5.1`, `.5.2`, `.9`, `.10.1`. `.10.2` (fix) **BLOCKED on a user DIRECTION decision**. Next selectable once unblocked: `.5.3`. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- DECISION NEEDED (`.10.2` direction, awaiting user; `.10.1` investigation answered the bug-vs-intended sub-question): **VERDICT — the single-slot `::AND -> Rule[0] { return(...) }` → `[]` behavior is an accidental REGRESSION in the Perl reference** (`AND_SINGLE_ACODE` emitter never `push`es the edge acode — `perl/LinkedSpec/HandlerVariantEmitter.pm:575-582`; from MEDIUM-IMPACT.3.4.x; pre-documented gap; no test pins `[]`). Several book examples assert a concrete output this way (notably `worked-spec-walkthrough.md`). Fork for `.10.2`: (A) **engine-fix** (restore edge-return path + sibling `\$"` bug + full regression + Rust parity; intuitive examples become correct) vs (B) **doc-rewrite** (rewrite to verified idioms) vs (C) **both sequenced**. Recommend (A) or (C); engine-fix → dedicated engine tree (not doc work). KM card: `docs/knowledge/and-single-acode-edge-return-dropped.md`.
- next_action: AWAIT the user's `.10.2` direction. Then (if unblocked) resume PNT at `SPEC-LANG-REFERENCE.5.3` — Array-family worked examples in `helper-contract-catalog.md` via the verified `Demo:: /<re>/ -> Demo { return(<expr>) }` scaffold, compile-AND-run verified through `LinkedSpec::Get`.
- queued_after: `.5.3` Array → `.5.4` Hash+Control Flow → `.5.5` remaining (closes `.5`) → `.6` capture/mark cross-example → `.7` KM cards → `.8` finalize; `.10.2` once direction set. Then `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
