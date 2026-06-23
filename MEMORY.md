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
- latest_commit: `TOP-RULE-AS-NORMAL.2.2 — confirm top re-entry recursion works with the LX accumulator idiom (NO engine defect; engine frozen); +1 phase0 lock; close .2` (hash backfilled next; ahead of origin ~34 — push threshold ~300; do NOT push mid-PNT). Prior: `c2814da` (`.2.1`).
- **This commit (`.2.2` — TEST+DOC only, +1 phase0 lock, NO engine/spec change):** CONFIRMED (via `probe9.pl`, dump-don't-transcribe) that **top re-entry recursion already works** — a recursive rule used AS the top rule parses with an `LX` accumulator-return (`(a(b)c)`→`[["a",["b"],"c"]]`, `(a) (b)`→`[["a"],["b"]]`). The earlier `null` was the **missing-`LX` authoring case** (a bare accumulating top rule's outermost frame loops to EOF and hits the default `lxcode = return undef`, discarding its accumulator). TOP vs BODY are **different grammars (different arity)**: TOP accumulates the SEQUENCE of top-level forms, BODY (`top:: -> sexpr {return(call(sexpr))}`) returns ONE form (`["a"]` for `(a) (b)`). So ADR `0010`'s goal is **met by the engine**; the authorized engine change was NOT needed for the value (only `.2.1`'s termination guard was). Added phase0 lock `top_rule_as_normal_recursion_with_lx_parses_sequence`. **`.2` and `.2.2` DONE.**
- **Prior commit `c2814da` (`.2.1` — ENGINE, 1 file `perl/LinkedSpec/SpecEntry.pm`):** the forward-progress / consume-before-recurse termination guard — a (rule,pos) active-stack non-progress cutoff in the `_build_runtime_handler` closure (every cross-rule call + recursion flows through it); a no-consume cycle → `undef` instead of hang. +3 phase0 locks. KM card [[top-rule-recursion-forward-progress-guard]].
- VERIFY: phase0 **960→963 (`.2.1`) →964 (`.2.2`)** green; `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 964) at both. `perl -c` clean. memory-arch + doctrine (2/2) + KM gates green.
- Active trees: **`TOP-RULE-AS-NORMAL`** (current focus) frontier **`.3`** (cross-variant parity — Rust: mirror `.2.1`'s termination guard + the top-recursion-with-`LX` behavior; track Julia/Dart; Perl is reference) → `.4` (book reconciliation, absorbs old `.6`: document the termination guarantee + that a recursive rule CAN be the top rule and needs an `LX` accumulator-return). Other lanes: `SPEC-FORMAT-TERSE` `.1.x` (PNT-eligible, ADR `0007`), `DOCTRINE-ENFORCEMENT-ADOPT.3` (deferred), `TRACE-OBSERVABILITY`, `RUST-PARITY.7.5.3`.
- next_action: **PAUSED for user direction** (`.2` complete; user's earlier intent was to review before `.3`/`.4`). Next leaf = **`TOP-RULE-AS-NORMAL.3`** (Rust cross-variant parity for the termination guard + top-recursion-with-`LX`) OR `.4` (book) — user's call. NOTE: `.2.1` IS a Perl engine change, so `.3` parity matters (does the Rust variant terminate a no-consume cycle? does it parse top-recursion-with-`LX` identically?).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). TOOLBOX: real recursion seam is `…{$rule}{handler}` (the `SpecEntry` closure), NOT the `dump_parser_source` artifact; reproduce hangs with fork+SIGKILL (`alarm` can't interrupt them).
- blockers: NONE — phase0 + full gate GREEN 964/964. Open: PRE-EXISTING `cargo clippy --tests` exit-101 (Rust lane — NOT in `run_ci_local.sh`; relevant to `.3`). in_flight_uncommitted: none after this commit.
