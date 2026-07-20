# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.8` — recurring six-runtime cursor admission is fully verified,
  documented, cleaned, and committed.
- latest_commit: `a1911ec6` — `FUTURE-PARITY-BACKLOG.9.1.8 - admit recurring cursor parity`
  (ahead: 243; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.0 - audit duplicate regex slot identity`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.9.1.8.1.0` duplicate-slot identity audit is signoff-complete from
  clean `a1911ec6`; parent `.8.1` remains split through neutral/backend/closeout children `.0-.7`.
- next_action: commit the completed behavior-free `.0` audit, clear and verify `git_message_brief.txt`, prove a
  clean handoff, and only then activate neutral contract `.1` task-tree-first.
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
- current_cursor_admission: One recurring driver composes Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, five selected
  primary cases across default/POSIX environments, and all support ledgers. Exact runtime proof passes at Perl
  288, Julia 104, Lua 119x2, primary 5x2x5, capability 80/0/0, and coverage 246/105+1/122. Governance is
  72 migration files / 7 complete + 1 pending / 56 mutations; no semantic path changed. KM 635/4,670, mdBook,
  four doctrines, canonical primary 65x2, and Phase 0 1,031/1,031 in 631 seconds pass; cleanup is complete.
- latest_bootstrap_read: 2026-07-19 — full roadmap/codebase/mdBook, active task, Knowledge Map, Toolbox, ADRs
  `0044`/`0046`, neutral/admitted cursor precedent, Lua architecture/root routes, and exact drivers reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor duplicate-regex identity `.9.1.8.1` and public no-drift `.9.1.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.9.1.8.1.0` exact audit and lockstep docs/KM are focused-green; no
  behavior edit exists. Canonical local CI passes primary 65x2 and Phase 0 1,031/1,031 in 619 seconds; exact
  generated-output cleanup is complete and no background job remains. Only the prepared commit is in flight.
