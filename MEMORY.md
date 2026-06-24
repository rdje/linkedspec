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
- latest_commit: `223723d` — `SPEC-FORMAT-TERSE.1.4.1 — Perl recognize terse renames set/cat/copy lowering identically to assign/concat/array_copy+hash_copy (engine + book + 4 phase0 locks)`. Prior: `5e93af3` `.1.4` split, `5e9ef57` `.1.2.2`, `b77510a` `.1.2.1`. Ahead of origin ~55 — push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — **`.1.4.1` DONE 2026-06-24** (Perl reference). `set`/`cat`/`copy` now lower **byte-identically** to `assign`/`concat`/`array_copy`+`hash_copy` in EVERY position. Implemented: `cat`→`concat`+`set`→`assign` in `_normalize_method_name` (`ActionIR/MethodExpr.pm`); `set` raw-text statement recognition extended (`\b(?:assign|set)\s*\(`) at `Contracts.pm` `assign_value` + its scanner `Scanner/PrimitivePipelineRules.pm` + bare-arg auto-`my` collector `RuleIR/EmitContext.pm` (`.1.2.1` parity); dedicated array-then-hash `copy` dispatch in `MethodLowering._lower_method_value_expr` + `copy` at `DeclareMethod` 136/163, `MethodLowering` 1650/1658, `FlowExpr.pm:270`, `BootstrapSpec/Core.pm` (`cat`), and the four `looks_like_{array,hash}_value_expr` recognizers (`MethodLowering`+`FlowExpr`, copy kind array-first). Proof: 4 headline + 11 composed `call_spec_handler_subst` forms byte-equal; `set`==`assign` ASSIGN node; terse spec runs == canonical twin end-to-end (`["a!","b!","c!"]`); **all 20 specs byte-identical (0 diff)**; +4 phase0 locks → **975 green**; `tools/run_ci_local.sh` EXIT 0; ratio 1.0000; mdbook EXIT 0; book 3 pages taught; KM [[terse-helper-rename-lowering-sites]] updated. `.1.2` also stays **active** (Channel 2 `.1.2.3`+ pending). User in a **PNT loop** (2026-06-23).
- next_action: **`.1.4.2`** (Rust lockstep parity for `.1.4.1`, ADR 0006) — `Engine::call_helper()` (`rust/linkedspec-runtime/src/engine.rs`): pipe `"assign" | "set"` (@711) and `"concat" | "cat"` (@820) onto the canonical arms, and add a dedicated value-type-dispatching `"copy"` arm (Array→clone, Hash→clone, else resolve named target — a literal can't repeat across array_copy@735 / hash_copy@1833). Lock with oracle fixtures (`tools/gen_oracle_corpus.pl`) + integration tests mirroring `.1.2.2`; cargo green; clippy zero-new; phase0 975 untouched (Perl); gate EXIT 0; no book change (variant-agnostic). The `.1.4.1` change is landed against the universal contract only once `.1.4.2` closes.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); cargo baseline **252 green**, clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs`. phase0 baseline = **971 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit (+ follow-on handoff hash-backfill).
