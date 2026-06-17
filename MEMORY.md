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
- latest_commit: `SPEC-LANG-REFERENCE.10.5.1 — audit: whole-book .spec-snippet scorch …` (hash backfilled by next hash-sync; origin synced through `9f511ac` earlier; ahead of origin: a few — push threshold ~300; do NOT push mid-PNT)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc; PNT loop authorized 2026-06-17). Now in the **whole-book scorch** (`.10.5`). Audit `.10.5.1` DONE. Next selectable leaf: `SPEC-LANG-REFERENCE.10.5.2`. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- **AUTHORING DOCTRINE (governs all remediation; [[feedback_spec-structure-top-plus-normal]]):** write a `.spec` as a top (`::`) entry rule with **NO regex** (the `_INITIAL` dispatch loop) + **≥1 normal (`:`) rule** carrying the regex(es). **Never put a regex on the top rule.** Perl reference authoritative + untouched ([[feedback_do-not-fix-reference-engine]]). KM card: `docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md`. ENGINE FACT (verified `.10.5.1`): `::`≡`:` on a non-first rule; only the first rule is the entry — so this is a STYLE doctrine, not an engine error.
- VERIFIED 2-rule idiom: `demo::  -> value  .push` / `LX { return(array_copy(a(demo))) }` + `value : /<re>/  I.return(<expr>)` reading **`entry_group(N)`** (not `match_group(N)`). Output = top rule's one-element accumulator snapshot. Avoid empty-matchable regexes (top loop matches twice) and the `::AND … -> Rule[N] { return }` shape (drops its return → `[]`). Verify EVERY fix via the private driver `/tmp/lsq_me/run.pl <spec> '<input>'` (`perl -I perl`, scalar-ref input; reproduces `["hello-world"]`).
- next_action: `SPEC-LANG-REFERENCE.10.5.2` — fix `docs/linkedspec-book/src/overview/what-is-linkedspec.md` minimal key/value example (`Top::AND+ /…/ -> Top[0]` single-rule → compile-fail/`null`) to the verified 2-rule idiom; a verified replacement yields `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`. Then `.10.5.3` … `.10.5.19` per the frontier (one file per leaf, commit each). **User decision: FULL BOOK-WIDE SCORCH** (rewrite every worked example incl. DSL fragments; correct all outputs).
- audit_artifact: full findings table + engine facts in `docs/tasks/SPEC-LANG-REFERENCE.md` ("Audit Findings (`.10.5.1`)"); ~105 `::`-mode headers / ~20 files; CLEAN = compiler/arch/dev chapters, helper-catalog §2/§5, lispish/ebnf/pplugin walkthroughs (ebnf "richer example" verified to compile — preliminary "doesn't compile" was wrong).
- queued_after: `.10.5.2`–`.10.5.19` (scorch) → `.5.3` Array → `.5.4` Hash+Control Flow → `.5.5` → `.6` → `.7` KM cards → `.8` finalize. Then `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (hard timeout; Perl-side, doesn't gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Neither gates the doc work.
