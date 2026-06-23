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
- latest_commit: `TOP-RULE-AS-NORMAL.3.1 — Rust forward-progress/consume-before-recurse termination guard (mirror of .2.1); split .3; +2 Rust locks` (hash backfilled next; ahead of origin ~36 — push threshold ~300; do NOT push mid-PNT). Prior: `baf600e` (`.2.2`), `74c5450` (handoff doc).
- **This commit (`.3.1` — RUST variant only, NO Perl/spec change):** split `.3` → `.3.1` (done) + `.3.2` (blocked) after a reproduce-first Rust diagnosis. Added the Rust mirror of `.2.1`'s `(rule,pos)` forward-progress cutoff: `recursion_active: HashSet<(String,usize)>` on `RuntimeContext` (`enter_recursion`/`exit_recursion`) + a thin `Engine::execute_rule` guard wrapper around the renamed `execute_rule_inner` (re-entry at an active `(label,pos)` ⇒ return `undef`; removed on Ok+Err paths). Files: `rust/linkedspec-runtime/src/{runtime,engine}.rs` + 2 integration locks. A no-consume cycle (`top:: /a/ I{return(call(top))}`) now **terminates cleanly → `[null]`** (= Perl `undef` wrapped one level by the Perl↔Rust accumulator output-shape rule) instead of **stack-overflow/SIGABRT**; legitimate consume-before-recurse recursion untouched.
- **DIAGNOSIS (durable):** the cross-variant gap has TWO layers — (a) termination [fixed by `.3.1`]; (b) **value** — Rust returns nulls for ALL recursive S-expr cases incl. the standard body idiom (`top:: -> sexpr` wrapper → `[[null],[null]]`), so (b) is the **general recursive-grammar parse gap** owned by `RUST-PARITY` (Lispish deferred per `rust/.../tests/corpus_oracle.rs`), NOT top-rule-specific. → `.3.2`.
- VERIFY: Rust suite **242→244 green** (`cargo test`; core/unit/corpus unchanged); changed-lib clippy clean (pre-existing `clippy --tests` exit-101 untouched). **phase0 964/964** + `bash tools/run_ci_local.sh` **EXIT 0** (Perl untouched). memory-arch + doctrine (2/2) + KM gates green.
- Active trees: **`TOP-RULE-AS-NORMAL`** (current focus) frontier **`.4`** (book reconciliation — demote "no regex on top"/"Body-rule-only" from law to idiom; document `::`=entered-first + the consume-before-recurse termination guarantee + recursive-top-rule-needs-`LX`; files in the `.4` node). `.3.2` is `blocked` (out of frontier) on `RUST-PARITY` recursive-grammar parse parity. Other lanes: `SPEC-FORMAT-TERSE` `.1.x` (PNT-eligible, ADR `0007`), `RUST-PARITY.7.5.3`, `DOCTRINE-ENFORCEMENT-ADOPT.3` (deferred), `TRACE-OBSERVABILITY`.
- next_action: **do `TOP-RULE-AS-NORMAL.4`** (book reconciliation; the new model is now landed in both variants for termination). Book is the user surface — verify every touched `.spec` example via `LinkedSpec::Get` (dump-don't-transcribe), keep variant-agnostic, `mdbook build` EXIT 0. Bootstrap first (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the `TOP-RULE-AS-NORMAL` tree + ADR `0010` + KM card [[top-rule-recursion-forward-progress-guard]]).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). Rust: build via the `rust/` workspace; depends on the sibling `rgx/` checkout (untracked here). Real recursion seam: Perl `…{$rule}{handler}` closure / Rust `Engine::execute_rule`, NOT the `dump_parser_source` artifact; reproduce Perl hangs with fork+SIGKILL (`alarm` can't interrupt them).
- blockers: NONE for the frontier (`.4` is PNT-ready). `.3.2` blocked on `RUST-PARITY` recursive-grammar parse parity. in_flight_uncommitted: none after this commit.
