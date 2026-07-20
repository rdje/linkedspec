# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.10.2` — Rust repeated-action-result admission is committed and
  clean at `293b10ea`.
- latest_commit: `293b10ea` — `FUTURE-PARITY-BACKLOG.9.1.10.2 - admit Rust repeated action results`
  (ahead: 255; push at threshold 300).
- active_work_unit: `FUTURE-PARITY-BACKLOG.9.1.10.3` — Dart repeated-action classification/collection and exact
  15-role admission are implemented; final lockstep docs, cleanup, and commit are in flight.
- next_action: finish lockstep/cleanup, commit and clean `.9.1.10.3`, then activate Julia child `.9.1.10.4`
  task-tree-first.
- current_duplicate_slot: ADR `0047` and all backend mechanisms are admitted. One recurring driver composes Perl
  12 roles, Rust/Dart/Julia 15 roles, Lua 112x2, selected primary 5x2x1, and three support ledgers. The checker
  reports 5 fixtures / 2 diagnostics / 6 runtime rows / 7 complete + 0 pending / 22 public documents /
  12 stale-current denials / 59 mutations. Generated-source v2 remains unchanged.
- current_repeated_action: `linkedspec-explicit-repetition-action-result-v1` locks 8 mode + 10 special cases,
  result/cursor/slot modeling, descriptor/generated-v2/trace/routes, one corpus bundle, 6 runtime rows, and 29
  mutations. Perl passes 10 roles and Rust/Dart 15 each; rollout is 4 complete + 4 pending. Rust and Dart bare OR
  are minimum-one `rep_acode`/`rep_bcode` and repeated action returns collect per hit; Julia/Lua plus `.6-.7`
  remain.
- current_root_selection: ADR `0046` precedence is explicit selector > first authored `Rule::` > first authored
  `Rule:`. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT admissions plus the selected five-command/default-POSIX
  5x2x6 projection and support ledgers pass from one recurring driver. Governance is 7 complete / 0 pending,
  25 required current documents, 19 stale-claim guards, and 54 rejected mutations. No resolver or generated-plan
  behavior changed. Hand-authored selection fixtures use lifecycle `I`; the fixed request-trace fixture retains
  canonical `E` bytes.
- current_cursor_admission: One recurring driver composes Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, five selected
  primary cases across default/POSIX environments, and all support ledgers. Exact runtime proof passes at Perl
  288, Julia 104, Lua 119x2, primary 5x2x5, capability 80/0/0, and coverage 246/105+1/122. Governance is
  75 migration files / 8 complete + 0 pending / 60 mutations with 29 required public documents and 26 exact
  stale-current denials. The closeout changes no semantic cursor path.
- current_signoff: Checker passes 8/10/4+4/29; focused Dart 3/3, analyzer, package 276, repaired adjacent generated/
  cursor matrices, primary 65x2, and corpus 105/105 pass. Canonical CI passes Perl primary 65x2 and Phase 0
  1,031/1,031 in 635 seconds. Final docs/gates, exact cleanup, commit, and brief reset remain before Julia `.4`.
- latest_bootstrap_read: 2026-07-20 — README, memory architecture/resume pointer, roadmap, codebase, mdBook, active
  task, Knowledge Map, Toolbox, ADRs `0044`/`0047`, public cursor surfaces, and recurring precedents read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; repeated-action rollout `.9.1.10.4-.7`; inter-match gap/named-slot
  contract `.1-.7` has its cursor prerequisite but still requires explicit activation; semantic/MCP `.10.1`;
  inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.9.1.10.3` Dart AST/runtime/generated behavior, exact consumer, contract,
  adjacent expectations, checker/driver, Knowledge Map, roadmap/live/task/changes/notes, and mdBook await final
  lockstep, cleanup, and commit.
