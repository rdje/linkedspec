# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.10.3` — Dart repeated-action-result admission is committed and
  clean at `128ead52`.
- latest_commit: `128ead52` — `FUTURE-PARITY-BACKLOG.9.1.10.3 - admit Dart repeated action results`
  (ahead: 256; push at threshold 300).
- active_work_unit: `FUTURE-PARITY-BACKLOG.9.1.10.4` — Julia repeated-action classification/collection and exact
  admission are implementation- and signoff-complete from the clean Dart boundary; lockstep/commit is in flight.
- next_action: finish Julia live-doc/mdBook/Knowledge Map synchronization, rerun final doctrine/diff checks,
  remove reproducible caches, commit `.4`, clear the brief, and hand off clean to dual-ABI Lua `.9.1.10.5`.
- current_duplicate_slot: ADR `0047` and all backend mechanisms are admitted. One recurring driver composes Perl
  12 roles, Rust/Dart/Julia 15 roles, Lua 112x2, selected primary 5x2x1, and three support ledgers. The checker
  reports 5 fixtures / 2 diagnostics / 6 runtime rows / 7 complete + 0 pending / 22 public documents /
  12 stale-current denials / 59 mutations. Generated-source v2 remains unchanged.
- current_repeated_action: `linkedspec-explicit-repetition-action-result-v1` locks 8 mode + 10 special cases,
  result/cursor/slot modeling, descriptor/generated-v2/trace/routes, one corpus bundle, 6 runtime rows, and 32
  mutations. Perl passes 10 roles and Rust/Dart/Julia 15 each; rollout is 5 complete + 3 pending. Those three
  newer backends use minimum-one bare-OR `rep_acode`/`rep_bcode` and collect per hit; Lua plus `.6-.7` remain.
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
- current_signoff: Julia `.4` passes checker 8/10/5+3/32, focused 162/162, package 3,711, repaired adjacent
  generated/cursor matrices, fresh isolated emitted direct/traced host, primary 65x2, corpus 105/105, canonical
  Perl primary 65x2, and Phase 0 1,031/1,031 in 638 seconds. Final docs/checks/cleanup/commit remain.
- latest_bootstrap_read: 2026-07-20 — README, memory architecture/resume pointer, roadmap, codebase, mdBook, active
  task, Knowledge Map, Toolbox, ADRs `0044`/`0047`/`0048`, public cursor surfaces, and recurring precedents read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; repeated-action rollout `.9.1.10.5-.7`; inter-match gap/named-slot
  contract `.1-.7` has its cursor prerequisite but still requires explicit activation; semantic/MCP `.10.1`;
  inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.9.1.10.4` Julia implementation, exact consumer, adjacent expectation
  alignment, checker/CI registration, and signoff are complete; lockstep docs, final checks, cleanup, and commit remain.
