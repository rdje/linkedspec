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
- latest_commit: `SPEC-LANG-REFERENCE.10.3 — book: redo Scalar+Numeric helper examples + preambles with the valid 2-rule idiom (entry_group; re-verified outputs)` (hash backfilled by next hash-sync; ahead of origin: ~158; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc; PNT loop authorized 2026-06-17). Remediation `.10`: **`.10.3` done** — the `.5.2` §2 Scalar + §5 Numeric examples (all 33) + both "Worked examples" preambles in `appendix/helper-contract-catalog.md` redone with the verified 2-rule idiom; every output re-verified through `LinkedSpec::Get`. Next selectable leaf: `SPEC-LANG-REFERENCE.10.4`. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- **STRUCTURAL INVARIANT (governs all remediation):** a `.spec` **top (`::`) rule has NO regex** — it is the `_INITIAL` `while(1)` dispatch loop matching the regexes of the **non-top (`:`) rules**; a valid `.spec` needs **≥2 rules** (top entry + ≥1 normal rule carrying the regex). NO engine bug (the `.10.1` "AND_SINGLE_ACODE regression" verdict was WRONG); **Perl reference is authoritative and NOT to be touched** ([[feedback_do-not-fix-reference-engine]], [[feedback_spec-structure-top-plus-normal]]). KM card: `docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md`.
- VERIFIED 2-rule idiom (use for ALL remaining remediation): `demo::  -> value  .push` / `LX { return(array_copy(a(demo))) }` + `value : /<re>/  I.return(<expr>)` reading **`entry_group(N)`** (entry match), NOT `match_group(N)` (unset in the child `I` block). Output = top rule's one-element accumulator snapshot (e.g. `["hello-world"]`, `[5]`, `[null]`). Caution: avoid empty-matchable regexes (e.g. `/(\w*)(\S*)/`) — the top loop matches twice.
- next_action: `SPEC-LANG-REFERENCE.10.4` — redo the `.9` §5.5 `runtime-semantics.md` Pair example with the valid 2-rule idiom (replace the single-rule `Pair:: /…/ -> Pair {…}` form); re-verify through `LinkedSpec::Get`; `mdbook build` exit 0.
- queued_after: `.10.5` (audit other chapters using a regex-on-top-rule example: `worked-spec-walkthrough.md` etc.) → `.5.3` Array → `.5.4` Hash+Control Flow → `.5.5` (closes `.5`) → `.6` → `.7` KM cards → `.8` finalize. Then `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
