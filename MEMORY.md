# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.7.4` — Lua/LuaJIT generated-source v2 is verified,
  documented, cleaned, and prepared for commit.
- latest_commit: `79422858` — `FUTURE-PARITY-BACKLOG.9.1.7.3 - project Lua cursor descriptor v1`
  (ahead: 237; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.7.4 - emit Lua generated-source v2`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.9.1.7.4` is complete but uncommitted; `.5` is not active yet.
- next_action: commit `.4`, clear the brief, verify a clean handoff, then activate public option removal `.5`.
- current_lua_generated_v2: ADR/contract/admitted mechanisms and every Lua v1 owner are retrieved. Identical dual-
  ABI RED is 44/106 and green is 106/106. New modules identify v2/format 2, retain only ordered label/family rows,
  derive exact five-seek/five-consume policy, classify compact Pipe as OR, and reject stale v1 before payload decode
  with expected/actual/regeneration fields. Direct/traced/fresh execution agrees on both ABIs. Eight focused
  consumers total 2,027 assertions per ABI; package is 176/177x2 only at staged help, primary 32/65x4, corpus
  105/105x2, and governance 69/5+3/44. KM is 630/4,622; mdBook/four doctrines and canonical root 7+5, cursor 288,
  primary 65x2, and Phase 0 1,031/1,031 in 644 seconds pass. Generated book/cache/native trees are removed.
- current_lua_descriptor: Exact descriptor RED is 364/776 on each ABI and green is 875/875. Root metadata now
  names cursor v1 and omits global mode; rule metadata derives family/policy/ownership plus ordered semantic edges
  from normalized compiled state. Direct/normalized/loaded bytes and loaded AND execution agree. Seven focused
  consumers total 1,921 assertions per ABI; package 176/177x2, primary 32/65x4, corpus 105/105x2, and governance
  68/5+3/44 remain staged. KM is 629/4,611; mdBook/four doctrines pass; canonical closes root 7+5, cursor 288,
  primary 65x2, and Phase 0 1,031/1,031 in 621 seconds. Safe generated artifacts are removed.
- current_cursor_normalization: All 36 parsed/compiled family rows, 18 edge rows, six ownership sets, six portable
  diagnostics, eight parent-child mechanisms, and two structural replacements are exact. Normal entered rules
  derive policy once; children rederive independently. Descriptor v1 has no global mode and projects exact facts;
  focused descriptor proof is 809 and direct/normalized/loaded bytes agree. Generated v2 focused proof is 65;
  its five seek/five consume mapping, compact-pipe OR identity, direct/traced/fresh-loaded execution, and v1-before-
  corrupt-payload rejection are exact. Public legacy keys fail before input/user code; low-level matchers remain.
  Package is 3,291, ten processes, primary 65/65x2, corpus 105, generated governance 80/0/0, cursor 67/5+3/44,
  logical 8/0, root 4/7+34, and capability 80/0/0. KM is 621/4,512; mdBook/four doctrines pass. Canonical local CI
  exits 0 after root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 641 seconds.
- current_cursor_admission: Julia now has one exact 15-role consumer; focused composition 104, package 3,291,
  ten processes, primary 65x2, and corpus 105 pass. Only Julia advances to neutral 67/5+3/44. The complete/primary
  drivers create only the first writable entry of a stacked depot; corrected offline proof leaves no malformed
  colon-bearing directory.
- latest_bootstrap_read: 2026-07-19 — full roadmap/codebase/mdBook, active task, Knowledge Map, Toolbox, ADRs
  `0044`/`0046`, neutral/admitted cursor precedent, Lua architecture/root routes, and exact drivers reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root admission `.9.1.1.2.5-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.7-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.9.1.7.4` is fully verified/documented/cleaned and awaits only its commit;
  no background job remains.
