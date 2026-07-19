# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.7.6` — Lua/LuaJIT rule-local cursor admission and parent
  `.9.1.7` are fully verified, documented, cleaned, and committed.
- latest_commit: `7dd70a2d` — `FUTURE-PARITY-BACKLOG.9.1.7.6 - admit Lua rule-local cursor contract`
  (ahead: 240; push at threshold 300).
- prepared_commit: none.
- active_work_unit: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.3` exact dual-ABI Lua root-selection admission, active
  task-tree-first from clean `7dd70a2d`.
- next_action: commit signoff-complete root admission `.5.3`, clear the brief, verify clean, then activate final
  root public no-drift `.9.1.1.2.6` task-tree-first.
- current_lua_root_admission: Retrieval followed ADR `0046` and every exact peer/Lua/driver/primary/governance
  pointer. One shared-source exact 15-role consumer uses lifecycle `I` for authored selection proof and preserves
  the fixed request-trace fixture's `E` bytes. Exact pre-contract RED is 3/3 per ABI; green is 139/139 per ABI.
  Complete package passes 177/177x2, primary 65/65 in all four ABI/default-POSIX legs, corpus 105/105x2, and root
  governance advances only Lua to 6 complete + 1 pending / 44 mutations. KM is 633/4,653; mdBook/four doctrines
  and canonical root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 641 seconds pass. Safe cleanup
  removes book/Python/Julia-compiled caches and four closed LinkedSpec logs; tracked `rgx` evidence is preserved.
- current_lua_generated_v2: v2/format 2 keeps only label/family rows, derives exact five-seek/five-consume policy,
  classifies compact Pipe as OR, and rejects stale v1 before payload decode. Its exact proof remains 106/106x2.
- current_cursor_admission: Lua now has one exact 15-role consumer run from identical source on PUC Lua and
  LuaJIT. Exact pre-contract RED is 3/3 per ABI and green is 119/119 per ABI. The complete dual-ABI driver passes
  package 177/177 per ABI, primary passes 65/65 in all four ABI/default-POSIX legs, and corpus passes 105/105 per
  ABI. Only Lua advances; neutral governance is 69 files / 6 complete + 2 pending / 49 mutations. Adjacent root,
  generated, logical, capability, memory, and doctrine checks pass. KM is 632/4,642; mdBook/four doctrines and
  canonical root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 647 seconds pass.
- latest_bootstrap_read: 2026-07-19 — full roadmap/codebase/mdBook, active task, Knowledge Map, Toolbox, ADRs
  `0044`/`0046`, neutral/admitted cursor precedent, Lua architecture/root routes, and exact drivers reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: final root no-drift `.9.1.1.2.6`; generated parser+stimuli `.8.1`; cursor `.9.1.8-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.9.1.1.2.5.3` and parent `.5` are signoff-complete; only the prepared
  per-leaf commit and brief cleanup remain. No background job is running.
