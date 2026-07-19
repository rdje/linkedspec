# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.7.2` — intrinsic PUC Lua/LuaJIT runtime is verified,
  documented, cleaned, and prepared for commit.
- latest_commit: `67909eb6` — `FUTURE-PARITY-BACKLOG.9.1.7.1 - normalize Lua cursor edges`
  (ahead: 235; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.7.2 - derive Lua rule-local runtime` from clean base `67909eb6`.
- active_work_unit: none after prepared `.9.1.7.2`; do not activate descriptor `.9.1.7.3` before the clean commit.
- next_action: commit prepared `.9.1.7.2`, clear `git_message_brief.txt`, verify clean, then activate descriptor
  v1 `.9.1.7.3` task-tree-first from the new commit.
- current_proof: PUC Lua and LuaJIT shared identical 44/110 runtime RED failures and now pass 110/110 each over all
  36 families, 8/8 parent-child mechanisms, 2/2 structural replacements, loaded/normalized/recursive/trace, and
  explicit outer/generated-v1 isolation. Six focused consumers pass 1,046 assertions per ABI. Missing engine
  policy is intrinsic at every entered rule; children rederive. Explicit outer policy remains staged for `.5`,
  generated v1 retains historical seek/family semantics for `.4`, and descriptor/public/rollout do not move.
  Package remains 176/177x2 with only staged help; primary remains 32/65x4, corpus 105/105x2, governance is
  68/5+3/44 after registering the execution consumer. KM is 628/4,600; mdBook/all four doctrines pass; canonical
  closes root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 624 seconds. Safe artifacts are removed.
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
- blockers: none. in_flight_uncommitted: fully verified prepared `.9.1.7.2` commit only.
