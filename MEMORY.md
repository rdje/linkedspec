# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.6` — final recurring/public root-selection no-drift and
  parent `.9.1.1.2` are fully verified, documented, and cleanup-complete; the per-leaf commit is prepared.
- latest_commit: `c8583edf` — clean base `FUTURE-PARITY-BACKLOG.9.1.1.2.5.3 - admit Lua root selection`
  (ahead: 241; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.6 - close root selection parity`.
- active_work_unit: `.9.1.1.2.6` closeout only; no different task-tree is active while the worktree is dirty.
- next_action: create the prepared per-leaf commit, clear `git_message_brief.txt`, prove the tree clean, then
  select the next roadmap-aligned task-tree leaf.
- current_root_selection: ADR `0046` precedence is explicit selector > first authored `Rule::` > first authored
  `Rule:`. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT admissions plus the selected five-command/default-POSIX
  5x2x6 projection and support ledgers pass from one recurring driver. Governance is 7 complete / 0 pending,
  25 required current documents, 19 stale-claim guards, and 54 rejected mutations. No resolver or generated-plan
  behavior changed. Hand-authored selection fixtures use lifecycle `I`; the fixed request-trace fixture retains
  canonical `E` bytes.
- current_signoff: Root checker 8/3/3, Lua 139/139x2, capability 80/0/0, language coverage 246/105+1/122,
  Knowledge Map 634/4,662, mdBook, memory, whitespace, JSON/shell, and all four doctrines pass. Canonical CI
  passes primary 65/65x2 and Phase 0 1,031/1,031 in 642 seconds. Safe cleanup removes only reproducible build/
  cache/book outputs and preserves tracked `rgx` evidence.
- adjacent_no_drift: The shared primary manifest is currently 65 cases, so logical/diagnostic public governance
  now requires `5x2x65`. Root scanners name the parse-mode mdBook chapter, so cursor inventory explicitly owns
  both scanner paths at 71 files; cursor rollout/mutations remain 6 complete + 2 pending / 49.
- latest_bootstrap_read: 2026-07-19 — full roadmap/codebase/mdBook, active task, Knowledge Map, Toolbox, ADRs
  `0044`/`0046`, neutral/admitted cursor precedent, Lua architecture/root routes, and exact drivers reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.8-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.9.1.1.2.6` is verified and documented; only artifact cleanup, final
  gate rerun, commit, brief clearing, and clean-handoff verification remain. No background job is running.
