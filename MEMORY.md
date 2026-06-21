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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.2.2.2.1 — re-bless cluster B1-array (33 return_array→return(array), TEST-ONLY); 17 cleared` (hash backfilled next; ahead of origin ~21 — push threshold ~300; do NOT push mid-PNT). Prior: `91b5113` (.2.2.2.1 recon).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; `.3`+`.4` engine fixes DONE (ADR `0008`); `.2.1`/`.2.2.1`/`.2.2.2.1` DONE; `.2.2`/`.2.2.2` SPLIT. Frontier → **`.2.2.2.2`**.
- **`.2.2.2.1` DONE (TEST-ONLY):** 33 in-range `return_array(<Top,> semantic_annotation, X)` → `return(array("semantic_annotation", X))` (matching-paren-aware, line-scoped to the 17 failing ranges — `return_array` is 74× file-wide, byte-identical across failing+passing, so NEVER global). Recon's "34" was 33. The 2 BOTH subtests (@17289/@20105) DO pin a literal `RETURN_A` hit-hash (recon said they didn't) → re-blessed `RETURN 2→3` / drop `RETURN_A`, empirically dumped before writing.
- next_action: **`.2.2.2.2`** — rewrite the 4 `return_a`/`return_m` subtests (`method_like_action_chain_parses_into_multiple_helper_events` @~39195 [3rd BOTH], `method_like_fluent_and_structured_blocks_lower_equivalently` @~39213, `method_like_structured_blocks_accept_optional_semicolons` @~39276, `blind_call_fluent_post_call_chain_matches_block_form` @~6337) per KM [[retired-return-helpers-canonical-rewrite]]: `return_a(L)`→`return(array("?L:", array_copy(array(L))))`, `return_m(L)`→`return(array("?L:", entry_groups()))`; re-dump + re-bless node/hit assertions (per-test retire-vs-rebless judgment); **highest risk — empirical dump first**. Then `.2.3` (C `emit_context` ×20), `.2.4` (F=3+G=2), `.5` green-phase0 (+ corpus tail), `.6` book `:AND`.
- phase0 now **30 failing** = 4 method_like `return_a`/blind_call (`.2.2.2.2`) + 20 `emit_context` (`.2.3`) + 5 other (F=3+G=2 `.2.4` + `corpus_regression` tail `.5`). `comm` name set-diff is the reliable proof. NOTE: `parser_invalid_input_fails_at_runtime_parser_boundary` (a `Lispish` `open3` subprocess test) is CPU-contention **flaky** — a clean re-run passes (`ok 137`); not a regression source.
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c -Iperl t/phase0_regression.t` OK; `perl -c perl/LinkedSpec.pm` OK; phase0 = 30 fail after `.2.2.2.1` (full `comm` name set-diff = exactly the 17 B1-array cleared, 0 regressions).
- blockers: (1) phase0 not yet green — 29 STALE re-bless (`.2.2.2.2`/`.2.3`/`.2.4`, TEST-ONLY) + corpus tail (`.5`); gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `RTLUtils`/`VHDL::ConstantEval` retired/gone) — docs-only refresh pending.
