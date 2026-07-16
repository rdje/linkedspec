# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.1.1` — ADR `0042` and the neutral diagnostic-output event
  contract are verified without backend behavior claims.
- latest_commit: `9aec48c1` — `FUTURE-PARITY-BACKLOG.5.1.0 - split diagnostic output parity` (ahead of origin: 159;
  push at documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.1.1 - ratify diagnostic output events` — complete verified staged
  candidate; actual commit hash will be recorded on the clean pivot.
- active_work_unit: commit closeout for neutral executable diagnostic-output contract
  `FUTURE-PARITY-BACKLOG.5.1.1`; successor Perl native seam `.5.1.2` is tracker-active but untouched.
- next_action: commit the verified `.5.1.1` candidate, clear/verify `git_message_brief.txt`, confirm the repo is
  clean, then pivot to `.5.1.2` and record the actual commit hash before Perl code changes.
- current_proof: the neutral checker independently passes three exact helpers, 11 render rows, five invalid
  arities, six event/sink/exit scenarios, eight pending rollout legs, and eight drift mutations. Capability remains
  80/0/0; memory architecture, Knowledge Map, mdBook, shell syntax, and whitespace pass. Canonical local CI passes
  primary CLI 61x2 plus Phase 0 true reach `1..1031` in 609 seconds. No backend behavior or conformance claim changed.
- latest_bootstrap_read: 2026-07-16 — startup corpus, diagnostic Knowledge Map cards, TOOLBOX, ADR 0024, all five
  runtime/helper seams, generated entrypoints, primary adapters, current native tests, and public helper docs.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.5.1.1`; parity dependency is closed. in_flight_uncommitted: complete verified staged
  `.5.1.1` candidate plus commit-message/commit/actual-hash pivot steps; no backend runtime/generated/CLI behavior change is authorized;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
