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
- latest_commit: `TOP-RULE-AS-NORMAL.1 — own the lane + read-only investigation; ADR 0010 (authorize engine change); supersede PHASE0-BACKHALF-TRIAGE.6 + close the tree (DOC-ONLY)` (hash backfilled next; ahead of origin ~32 — push threshold ~300; do NOT push mid-PNT). Prior: `869b0f6` (`.5.3.2.2`).
- **This commit (DOC-ONLY — ADR + task trees + KM cards + live docs; NO engine/spec/book change):** the user escalated the book `:AND` reconciliation into an **engine change** and **authorized touching the Perl variant** (ADR `0010`) — treat the top rule as an ordinary rule **merely entered first** (`::` = entry marker); the no-regex dispatch loop is **idiom not law**; recursion into the top allowed under a **consume-before-recurse** termination rule; cross-variant parity required. Read-only investigation (`TOP-RULE-AS-NORMAL.1`): the regex/codegen dimension is **already uniform** (top = `&{$descr->{spec}{$top_rule}}(...)` `Compiler.pm:1006`; `while(1)` is mode-driven; `Pair::AND`+regex emits a normal AND handler) — the OPEN gap is **top re-entry recursion + termination** (naive top-recursion hangs; Lispish body-recursion is green). Superseded `PHASE0-BACKHALF-TRIAGE.6` → `TOP-RULE-AS-NORMAL`; **`PHASE0-BACKHALF-TRIAGE` tree now DONE** (`.1`–`.5` done, `.6` superseded). KM: new [[top-rule-is-ordinary-rule-entered-first]] + corrected [[spec-top-rule-no-regex-two-rule-minimum]] (the `[]` claim was fixed by `.3`; doctrine = idiom).
- Active trees: **`TOP-RULE-AS-NORMAL`** (current focus) frontier **`.2`** (Perl engine: confirm the {mode}×{regex}×{recursion} matrix + enable top re-entry recursion + forward-progress guard + phase0 locks — **signoff-critical codegen; recommend a FRESH SESSION**) → `.3` (cross-variant parity, Rust) → `.4` (book reconciliation, absorbs old `.6`). Other lanes: `SPEC-FORMAT-TERSE` `.1.x` (PNT-eligible, ADR `0007`), `DOCTRINE-ENFORCEMENT-ADOPT.3` (deferred), `TRACE-OBSERVABILITY`, `RUST-PARITY.7.5.3`.
- next_action: **`TOP-RULE-AS-NORMAL.2`** — first `dump_parser_source` a correct consume-before-recurse top-recursive grammar vs the shipped `Lispish` body-recursive pattern to pin exactly where top re-entry diverges; then enable it + add the forward-progress guard + phase0 locks. Engine-touch AUTHORIZED by ADR `0010`. **Do it in a fresh, sharp session** (codegen + cross-variant parity).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout (`rgx/subs/pgen/fx/perl`); always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). TOOLBOX: `generate_only`+`dump_parser_source`+`runtime_ctx_ref` shows emitted handler source.
- VERIFY: full gate `bash tools/run_ci_local.sh` (EXIT 0; ~198s) OR phase0 `perl -Iperl t/phase0_regression.t` (`1..960`); doc slices: `mdbook build docs/linkedspec-book` + `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh`.
- blockers: NONE for phase0 / full gate (both GREEN 960/960). `.2` engine change is AUTHORIZED (ADR `0010`); recommend a fresh session for signoff codegen. Open: PRE-EXISTING `cargo clippy --tests` exit-101 (Rust lane — NOT in `run_ci_local.sh`). in_flight_uncommitted: none after this commit.
