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
- latest_commit: `(this commit)` — `TOP-RULE-AS-NORMAL.4 — book reconciliation to the top-rule-as-ordinary model (law→idiom across 6 book files; ::=entry-marker + §5.4 termination + recursive-top-rule-needs-LX; de-footgun Pair::AND; fix multi-pair consume/seek bug); +1 phase0 lock; KM card` (ahead of origin ~39 — push threshold ~300; do NOT push mid-PNT). Prior: `e85ae5c` (handoff backfill), `808ce0d` (`.3.1`).
- **This commit (`.4` — BOOK+TEST+DOC, NO engine/spec change):** reconciled the mdBook to ADR `0010`. Demoted law→idiom across **6 files** (`user-model/{spec-files-and-rule-paragraphs,rule-modes-and-parse-modes,worked-spec-walkthrough}.md`, `appendix/{formal-grammar,helper-contract-catalog}.md`, `overview/what-is-linkedspec.md`). Documented: `::`=entry-marker / ordinary-rule-entered-first; `entry_*`(entering match) vs `match_*`(own match, post-match edge); **consume-before-recurse termination** (`formal-grammar.md` §5.4, backend MUST); recursive-top-rule-needs-`LX`. **De-footgunned** `Pair::AND` (`entry_text()`→`match_group(0)`; folded bare `\s*=\s*` slot). **Fixed** the worked-walkthrough multi-pair bug (two pairs is a `seek` result, not `consume`).
- VERIFY: all examples via `LinkedSpec::Get` (dump-don't-transcribe, scratchpad `verify4*.pl`); `mdbook build` EXIT 0 (anchor checked from generated HTML); **phase0 964→965 green** (+1 lock `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family`, 3 assertions); KM card [[top-rule-reads-own-match-with-match-family]] (map regenerated); doctrine driver 2/2 PASS; `bash tools/run_ci_local.sh` **EXIT 0**. Book variant-agnostic.
- **`TOP-RULE-AS-NORMAL` acceptance MET**; tree stays `active` only because `.3.2` (Rust value parity) is `blocked` on `RUST-PARITY`; **frontier EMPTY** (`.4` was the last executable leaf). Discovered (tracked open Q, out of scope): a bare edge-less `AND` middle slot is a positional anchor not separately consumed (illustrative sketches only).
- next_action: **PNT into the next active tree — `SPEC-FORMAT-TERSE` `.1.x`** (PNT-eligible, ADR `0007`; first: `.1.1` auto-existing variables; implementation gate already CLEARED, migration = gradual-alias). Other lanes: `RUST-PARITY.7.5.3` (also unblocks `TOP-RULE-AS-NORMAL.3.2`), `DOCTRINE-ENFORCEMENT-ADOPT.3` (deferred), `TRACE-OBSERVABILITY`. Bootstrap first (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the chosen tree + relevant ADRs/KM cards).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). Real recursion seam: Perl `…{$rule}{handler}` closure / Rust `Engine::execute_rule`, NOT the `dump_parser_source` artifact; reproduce Perl hangs with fork+SIGKILL (`alarm` can't interrupt them). **Top-rule authoring: a top rule has no entering match → read its OWN regex with `match_*` from a post-match edge, not `entry_*`/an `I` block.**
- blockers: NONE PNT-eligible-blocking. `.3.2` blocked on `RUST-PARITY`. in_flight_uncommitted: none after this commit.
