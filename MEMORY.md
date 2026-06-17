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
- latest_commit: `SPEC-LANG-REFERENCE.10 — correction: top rule has no regex; .5.2/.9 examples are structurally invalid (not an engine bug); retract .10.1, plan remediation (.10.3-.5)` (hash backfilled by next hash-sync; ahead of origin: ~157; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc; PNT loop authorized 2026-06-17). Done: `.1`–`.4`, `.5.1`, `.5.2`, `.9`, `.10.1`. **`.5.2` + `.9` are now known STRUCTURALLY INVALID and must be redone** (see correction). `.10.2` superseded. Next selectable leaf: `SPEC-LANG-REFERENCE.10.3`. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- **MAJOR CORRECTION (user, 2026-06-17):** a `.spec` **top (`::`) rule has NO regex** — it is the `_INITIAL` entry/dispatch loop that matches the regexes of the **non-top (`:`) rules**; a valid `.spec` needs **≥2 rules** (top + ≥1 normal rule carrying the regex). Verified vs `BootstrapSpec/Core.pm:414,417`, `RuleIR.pm:193-195`, audit of all 20 `specs/*.spec`. So `.5.2`'s 35 examples + catalog preamble AND `.9`'s §5.5 used the INVALID `Demo:: /re/ -> Demo {…}` form (regex on the top rule) → `[]`. **There is NO engine bug** (the earlier `.10.1` "AND_SINGLE_ACODE regression" verdict was WRONG); the **Perl reference is authoritative and NOT to be touched** ([[feedback_do-not-fix-reference-engine]], [[feedback_spec-structure-top-plus-normal]]). KM card: `docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md`.
- VERIFIED 2-rule idiom (use for ALL remediation; modeled on `lib_reader.spec`/`tclite.spec`): `demo_top::  -> word_pair  .push` / `LX {return(array_copy(a(demo_top)))}` + `word_pair : /(\w+) (\w+)/  I.return(concat(entry_group(0), "-", entry_group(1)))` → `["hello-world"]`. KEY: the normal rule reads **`entry_group(N)`** (entry match), NOT `match_group(N)` (unset in the child `I` block → `[null]`).
- next_action (FRESH SESSION recommended): `SPEC-LANG-REFERENCE.10.3` — redo the `.5.2` Scalar+Numeric examples + the catalog "Worked examples" preamble with the verified 2-rule idiom; re-derive + re-verify each output through `LinkedSpec::Get`. Then `.10.4` (redo `.9` §5.5), `.10.5` (audit other chapters: `worked-spec-walkthrough.md` etc.), then resume `.5.3`+.
- queued_after: `.10.4` → `.10.5` → `.5.3` Array → `.5.4` Hash+Control Flow → `.5.5` (closes `.5`) → `.6` → `.7` KM cards → `.8` finalize. Then `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
