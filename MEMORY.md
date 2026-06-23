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
- latest_commit: `TOP-RULE-AS-NORMAL.2.1 — forward-progress/consume-before-recurse termination guard (SpecEntry runtime-handler closure) + 3 phase0 locks; split .2; discover .2.2 top-recursion value gap` (hash backfilled next; ahead of origin ~33 — push threshold ~300; do NOT push mid-PNT). Prior: `7ccb61e` (`.1`).
- **This commit (ENGINE — 1 file `perl/LinkedSpec/SpecEntry.pm` + 3 phase0 locks; ADR `0010` authorized):** added the **forward-progress / consume-before-recurse termination guard** = a precise **(rule, pos) active-stack non-progress cutoff** in the single `SpecEntry::_build_runtime_handler` runtime-handler closure (the seam EVERY cross-rule call + recursion flows through — `&{$$descr{spec}{$rule}{handler}}(...)`, confirmed via `call_spec_handler_subst`/`Contracts.pm:134`, NOT the simplified `dump_parser_source` artifact). Re-entry at a position already active for that rule ⇒ `return undef` (cut). TOOLBOX ground-truth: the per-handler `while(1)` + `LinkedRE::or` `/gc` matching is **already** forward-progress-safe (no zero-width grammar hangs); the ONE reproduced engine hang was an unconditional no-consume self-tail-call (`top:: /a/ I{return(call(top))}`), now → `null`. **phase0 960→963** (3 new locks), `tools/run_ci_local.sh` **EXIT 0** ("Result: PASS"), **zero regression**. KM card [[top-rule-recursion-forward-progress-guard]].
- **DISCOVERED `.2.2` (value gap):** a recursive rule used AS the top rule returns `null` while the IDENTICAL rule as a body rule parses (`(a(b)c)`→`["a",["b"],"c"]`) — an **entry-alignment** divergence (who consumes the leading token). Split `.2` → `.2.1` (done) + `.2.2` (pending). The `.2.1` top-recursion lock pins TERMINATION only (not the wrong value).
- Active trees: **`TOP-RULE-AS-NORMAL`** (current focus) frontier **`.2.2`** (Perl engine — top re-entry VALUE correctness: make a top-recursive entry rule parse like the body form; root-cause the entry-alignment divergence then minimal engine change + tightened lock) → `.3` (cross-variant parity, Rust) → `.4` (book reconciliation, absorbs old `.6`; document the termination guarantee). Other lanes: `SPEC-FORMAT-TERSE` `.1.x` (PNT-eligible, ADR `0007`), `DOCTRINE-ENFORCEMENT-ADOPT.3` (deferred), `TRACE-OBSERVABILITY`, `RUST-PARITY.7.5.3`.
- next_action: **PAUSED for user review** (user chose: implement `.2.1`, commit, stop before `.3`/`.4`). Next leaf = **`TOP-RULE-AS-NORMAL.2.2`** — trace the runtime handler (`LINKEDSPEC_TRACE_LEVEL=debug` + `dump_parser_source` of the real `{handler}`) on the `sexpr::`-top grammar to pin the leading-token consumption off-by-one vs the body form; then a minimal regression-locked engine change. Engine-touch AUTHORIZED by ADR `0010`.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). TOOLBOX: real recursion seam is `…{$rule}{handler}` (the `SpecEntry` closure), NOT the `dump_parser_source` artifact; reproduce hangs with fork+SIGKILL (`alarm` can't interrupt them).
- VERIFY: full gate `bash tools/run_ci_local.sh` (EXIT 0; ~199s) OR phase0 `perl -Iperl t/phase0_regression.t` (`1..963`); doc slices: `mdbook build docs/linkedspec-book` + `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh`.
- blockers: NONE for phase0 / full gate (both GREEN 963/963 with the guard). `.2.2` engine change is AUTHORIZED (ADR `0010`). Open: PRE-EXISTING `cargo clippy --tests` exit-101 (Rust lane — NOT in `run_ci_local.sh`). in_flight_uncommitted: none after this commit.
