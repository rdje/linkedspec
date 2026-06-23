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
- latest_commit: `2b7cbd5` — `SPEC-FORMAT-TERSE.1.1 — split into .1.1.1 (Perl) + .1.1.2 (Rust parity); record auto-existing-variable design + KM card` (ahead of origin ~40 — push threshold ~300; do NOT push mid-PNT). Prior: `a9e50f3` (`TOP-RULE-AS-NORMAL.4`).
- **This commit (`.1.1` SPLIT — DOCS/TREE/KM ONLY, no engine/book change):** PNT entered the terse-format track (`SPEC-FORMAT-TERSE`). A `dump_parser_source` ground-truth pass (TOOLBOX-first; scratchpad `probe_autovar*.pl`) showed `.1.1` (auto-existing variables) is too broad for one slice → split into `.1.1.1` (Perl reference) + `.1.1.2` (Rust lockstep parity); `.1.1` is now a container; frontier → `.1.1.1`. Added KM card [[working-vars-no-strict-need-my-lexical]] (map regenerated).
- **Verified design (KM card):** a rule's `I`+edges+`LX` = ONE lexical scope; `declare(scalar/array/hash,x)`→`my $x`/`@x`/`%x` ONCE in the preamble (after `my @<label>;`), before the `while(1)` loop. Generated handlers run with **NO `use strict`** (`SpecEntry.pm` has neither) → a working var without `declare` is a **leaky package global** (state-leaks across invocations/recursion), not a loud error. `.1.1.1` design: rule-level collect typed-wrapper refs `scalar(NAME)`/`array(NAME)`/`hash(NAME)` (+ `s/a/h`), sigil FROM the wrapper (no inference — that is `.1.2`), inject one `my` in the preamble, dedup vs `@<label>` + explicit declares, preserve ratio 1.0000.
- next_action: **implement `SPEC-FORMAT-TERSE.1.1.1`** (Perl auto-existing variables) per the recorded design (tree Decisions + KM [[working-vars-no-strict-need-my-lexical]]) — rule-level var-collection → preamble `my`-injection (in `SpecEntry`/`RuleIR::EmitContext`) + phase0 locks (no-declare path works; declare path byte-identical generated source) + book note (vars auto-exist, `declare` optional; full example re-author is a later gradual leaf) + `bash tools/run_ci_local.sh` EXIT 0. **FRESH SESSION RECOMMENDED** — `.1.1.1` is signoff-critical reference-engine codegen (the hot path under all 20 specs + 965 phase0); the design is fully captured so a sharp start can implement directly. Then `.1.1.2` (Rust parity). Other lanes: `RUST-PARITY.7.5.3`, `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3` (deferred).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated handlers are NON-strict** (`SpecEntry.pm` has no `use strict`). Recursion seam: Perl `…{$rule}{handler}` closure / Rust `Engine::execute_rule`, NOT the `dump_parser_source` artifact. phase0 baseline = **965 green**.
- blockers: NONE PNT-eligible-blocking. Follow-ons: `.1.1.2` (Rust parity, depends on `.1.1.1`), `TOP-RULE-AS-NORMAL.3.2` (blocked on `RUST-PARITY`). in_flight_uncommitted: none after this commit.
