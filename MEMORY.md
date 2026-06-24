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
- latest_commit: `<pending-backfill>` — `SPEC-FORMAT-TERSE.1.4 — split into .1.4.1 (Perl reference) + .1.4.2 (Rust parity); record helper-rename lowering-site ground truth + KM card`. Prior: `5e9ef57` `.1.2.2`, `b77510a` `.1.2.1`. Ahead of origin ~52 — push threshold ~300; do NOT push mid-PNT. (Hash backfilled by the follow-on handoff commit.)
- active_work_unit: `SPEC-FORMAT-TERSE` — `.1.4` **SPLIT** 2026-06-24 → `.1.4.1` (Perl reference) + `.1.4.2` (Rust lockstep parity). TOOLBOX-first `call_spec_handler_subst` ground truth (dump-don't-guess; `perl -Iperl`): the three terse spellings are UNRECOGNIZED today — `set`→passthrough (vs `assign`→`$x = 1`), `cat`→passthrough (vs `concat`→do-block), `copy(a(x))`→`copy([items])` partial / `copy(h(x))`→passthrough (vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`). THREE shapes: `cat`=pure rename via `_normalize_method_name` (`ActionIR/MethodExpr.pm:19-26`); `set`=STATEMENT-level (`ActionIR/Contracts.pm:1749/1753` `\bassign\s*\(` + `DeclareMethod` + `MethodLowering._lower_assign_statement`) — NOT reached by normalization; `copy`=unified array-vs-hash dispatch in `MethodLowering._lower_method_value_expr` (array sym then hash sym). Rust: one `Engine::call_helper()` match (`engine.rs` assign@711/array_copy@735/concat@820/hash_copy@1833; pipe-arm aliases) — `copy` needs its own value-type arm. KM [[terse-helper-rename-lowering-sites]]. DOCS/TREE/KM only — no engine/book change; doctrine+KM gates EXIT 0. `.1.2` stays **active** (Channel 2 `.1.2.3`+ pending). User in a **PNT loop** (2026-06-23).
- next_action: **`.1.4.1`** (Perl reference) — make `set`/`cat`/`copy` lower **identically** to `assign`/`concat`/`array_copy`+`hash_copy`; OLD-name lowering byte-UNCHANGED → all 20 shipped specs byte-identical (mine-vs-stashed diff, like `.1.1.1`/`.1.2.1`); +phase0 locks (new spellings == canonical; old unchanged); ratio 1.0000; `tools/run_ci_local.sh` EXIT 0; book teach (`dsl/value-container-flow-helper-reference.md`, `appendix/helper-contract-catalog.md`, `dsl/declaration-helper-reference.md`). Resolve the `set` statement-level seam with `dump_parser_source`. Then `.1.4.2` (Rust parity). Direction ADR 0007: new names canonical, old names deprecated aliases.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); cargo baseline **252 green**, clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs`. phase0 baseline = **971 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit (+ follow-on handoff hash-backfill).
