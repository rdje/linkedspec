# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.3.1` — Perl authored families, typed bare edges, declaration-set
  normalization, portable ownership diagnostics, and per-rule cursor-policy facts are implemented and verified.
- latest_commit: `ae43163c` — `FUTURE-PARITY-BACKLOG.9.1.3.0 - audit Perl cursor rollout boundaries`
  (ahead: 184; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.3.1 - normalize Perl rule edges`.
- active_work_unit: none until the verified `.9.1.3.1` slice is committed cleanly; live handler cursor execution
  remains separately gated under pending `.9.1.3.2`.
- next_action: commit `.9.1.3.1`, clear `git_message_brief.txt`, prove a clean handoff, then activate `.9.1.3.2`
  before changing live HandlerIR/LinkedRE cursor spending.
- current_proof: The source contract passes 272 assertions over all 36 family spellings, 18 edge cases, and six
  ownership sets; RuleIR trace 5/5 and validation fuzz 5/5 pass. The neutral checker remains 36/18/8/91 at 1/7
  with 27 rejected mutations; KM is 580/4077. Canonical local CI passes doctrines, capability 80/0/0, generated
  v1, logical and diagnostic 8/0, coverage 246/105+1/122, reference CLI 63/63 twice, and Phase 0 `1..1031` in
  641 seconds. HandlerIR/LinkedRE, public options, generated source, CLI, and fixture cursor behavior are unchanged.
- latest_bootstrap_read: 2026-07-17 — full required roadmap, codebase ownership seams, mdBook, active task, Knowledge
  Map, Toolbox facts, and ADR context reviewed before the Perl implementation slice.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR implementation `.9.1.2-.9` after logical;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.9.1.3.1` implementation, tests, and synchronized durable records
  awaiting the prepared commit; no background job. Live cursor execution remains unchanged; parked mutation work
  and ignored `rgx/subs/pgen` work are untouched.
