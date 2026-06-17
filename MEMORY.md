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
- latest_commit: `SPEC-LANG-REFERENCE.10.6 — record: retract the inaccurate "regex-on-top → []" premise; reframe the .10 rationale as the 2-rule authoring doctrine` (hash backfilled by next hash-sync; ahead of origin: ~159; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc; PNT loop authorized 2026-06-17). Done: `.10.3` (catalog §2/§5 examples → 2-rule idiom, all 33 re-verified), `.10.6` (corrected the durable record). Next selectable leaf: `SPEC-LANG-REFERENCE.10.4`. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- **AUTHORING DOCTRINE (governs all remediation; [[feedback_spec-structure-top-plus-normal]]):** write a `.spec` as a top (`::`) entry rule with **NO regex** (the `_INITIAL` dispatch loop) + **≥1 normal (`:`) rule** carrying the regex(es). **Never put a regex on the top rule.** All 20 shipped specs do this. Perl reference authoritative + untouched ([[feedback_do-not-fix-reference-engine]]). KM card: `docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md`.
- VERIFIED 2-rule idiom: `demo::  -> value  .push` / `LX { return(array_copy(a(demo))) }` + `value : /<re>/  I.return(<expr>)` reading **`entry_group(N)`** (not `match_group(N)`). Output = top rule's one-element accumulator snapshot (e.g. `["hello-world"]`, `[5]`, `[null]`). Avoid empty-matchable regexes (top loop matches twice) and the `::AND … -> Rule[N] { return }` shape (drops its return → `[]`, the `.10.1` finding; do NOT use in examples). NOTE: the engine is permissive (regex-on-top actually runs/returns a value) — don't reason about malformed-spec output; just follow the doctrine.
- next_action: `SPEC-LANG-REFERENCE.10.5` — **WHOLE-BOOK SCORCH** (user directive 2026-06-17): exhaustively audit EVERY `.spec` snippet in `docs/linkedspec-book/src/**` for doctrine-validity (no regex on a top `::` rule; ≥2 rules) + output-correctness (claimed I/O matches `LinkedSpec::Get`), then remediate. Audit-as-decomposition (read-only fan-out hunt → per-chapter fix sub-leaves `.10.5.1…`; subsumes the `.10.4` §5.5 Pair fix). A preliminary hunt already confirmed violations are WIDESPREAD (rule-modes, regex-in-spec, dsl helper refs, `worked-spec-walkthrough` §kind=pair→`[]`, `get-and-get-parser` minimal example, §5.5) — see the tree changelog; re-run the full hunt fresh.
- queued_after: `.10.4` §5.5 Pair (folded into `.10.5`) → `.5.3` Array → `.5.4` Hash+Control Flow → `.5.5` (closes `.5`) → `.6` → `.7` KM cards → `.8` finalize. Then `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (hard timeout; Perl-side, doesn't gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Neither gates the doc work.
