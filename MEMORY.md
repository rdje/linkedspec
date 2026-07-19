# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.7.5` — Lua/LuaJIT public/global cursor option removal is
  fully verified, documented, cleaned, and committed.
- latest_commit: `e96d389e` — `FUTURE-PARITY-BACKLOG.9.1.7.5 - remove Lua global cursor overrides`
  (ahead: 239; push at threshold 300).
- prepared_commit: none.
- active_work_unit: `FUTURE-PARITY-BACKLOG.9.1.7.6` exact dual-ABI Lua cursor admission, active task-tree-first
  from clean `e96d389e`.
- next_action: finish `.9.1.7.6`: regenerate/check the final Knowledge Map and mdBook projection, remove only safe
  generated artifacts, commit, clear the brief, verify a clean handoff, then activate root admission
  `.9.1.1.2.5.3` task-tree-first.
- current_lua_option_removal: Exact pre-edit focused RED is 75/96 on PUC Lua and LuaJIT; shared primary is 32/65
  in all four ABI/default-POSIX legs. High-level engine, parse, loaded, corpus, generated, help, and request-trace
  override ownership is now removed. Legacy snake/camel keys fail with `prepare_options` /
  `parse_mode_override_removed` before input/user code; retired CLI syntax gets exact usage exit 2; low-level
  matchers remain; `--top-rule` still beats authored `Rule::` and uses lifecycle `I` proof. Green is 96/96x2,
  package 177/177x2, primary 65/65x4, corpus 105/105x2, and governance 68/5+3/44. KM is 631/4,632; complete Lua,
  mdBook build, KM, memory, and four doctrines pass. Canonical local CI passes root 7+5, cursor 288, primary
  65x2, and Phase 0 1,031/1,031 in 646 seconds. Safe cleanup removes the 11 MiB generated book and Python cache;
  no Rust, Dart, or temporary native build tree exists. The clean result is committed at `e96d389e`.
- current_lua_generated_v2: v2/format 2 keeps only label/family rows, derives exact five-seek/five-consume policy,
  classifies compact Pipe as OR, and rejects stale v1 before payload decode. Its exact proof remains 106/106x2.
- current_cursor_normalization: All 36 parsed/compiled family rows, 18 edge rows, six ownership sets, six portable
  diagnostics, eight parent-child mechanisms, and two structural replacements are exact. Normal entered rules
  derive policy once; children rederive independently. Descriptor v1 has no global mode and projects exact facts;
  focused descriptor proof is 809 and direct/normalized/loaded bytes agree. Generated v2 focused proof is 65;
  its five seek/five consume mapping, compact-pipe OR identity, direct/traced/fresh-loaded execution, and v1-before-
  corrupt-payload rejection are exact. Public legacy keys fail before input/user code; low-level matchers remain.
  Package is 3,291, ten processes, primary 65/65x2, corpus 105, generated governance 80/0/0, cursor 67/5+3/44,
  logical 8/0, root 4/7+34, and capability 80/0/0. KM is 621/4,512; mdBook/four doctrines pass. Canonical local CI
  exits 0 after root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 641 seconds.
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
- deferred: root admission `.9.1.1.2.5-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.7-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.9.1.7.6` needs final map/book, cleanup, commit, and clean verification; no job.
