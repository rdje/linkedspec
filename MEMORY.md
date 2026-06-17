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
- latest_commit: `SPEC-LANG-REFERENCE.9 — book: fix drifted §5.5 Pair example output (AND-[0] self-edge returns [] not the tagged array)` (hash backfilled by next hash-sync; ahead of origin: ~155; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc request; **PNT loop authorized** 2026-06-17) → next selectable leaf `SPEC-LANG-REFERENCE.5.3` (pending). Done: `.1`–`.4`, `.5.1`, `.5.2`, `.9`. `.10` is **BLOCKED on a user decision** (see below). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- DECISION NEEDED (`.10`, surfaced to user 2026-06-17): a single-slot `::AND -> Rule[0] { return(...) }` self-edge returns the empty accumulator `[]`, NOT the returned value (verified default/`consume`/`seek`). Several book examples assert a concrete output this way (notably the canonical `worked-spec-walkthrough.md` → claims `{kind=>"pair",…}`, actually `[]`). Fork: **engine-bug-fix** (fix Perl reference + Rust so the examples become correct) vs **doc-rewrite** (rewrite examples to the verified OR self-ref `-> Rule` form / multi-slot accumulator-snapshot idiom). `.10` owns the fix; awaiting direction.
- next_action: `SPEC-LANG-REFERENCE.5.3` — worked examples for the **Array** helper family (largest, ~33 helpers) in `appendix/helper-contract-catalog.md`. Use the **verified** scaffold `Demo:: /<re>/ -> Demo { return(<expr>) }` (bare-`::` OR self-ref surfaces the return value); compile-AND-run verify each through `LinkedSpec::Get` against the oracle (do-not-guess). `mdbook build` exit 0.
- queued_after: `.5.4` Hash+Control Flow → `.5.5` remaining families (closes `.5`) → `.6` capture/mark cross-example → `.7` KM cards → `.8` finalize → `.10` (once unblocked). Then `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
