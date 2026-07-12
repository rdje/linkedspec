# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.2.1.3` — typed scalar-to-text parity.
- latest_commit: this block is prepared for commit
  `LUA-BACKEND-PARITY.4.3.2.1.3 - align scalar text coercion`; previous HEAD is
  `5a3686bd LUA-BACKEND-PARITY.4.3.2.1.2.4 - admit six-variant Unicode casing`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.2.2`; regex-aware scalar matching/substitution, split bridges,
  flags, replacement expansion, and statement mutation are next.
- next_action: inspect the `.4.3.2.2` acceptance boundary and use LinkedSpec probes to split it if one signoff-level
  implementation commit would combine distinct regex/split/mutation mechanisms.
- current_proof: `linkedspec-scalar-text-v1` passes Perl/Rust/Dart/Julia/PUC Lua/LuaJIT. Full Rust, Dart, Julia,
  dual-ABI Lua, and canonical local CI gates pass; Phase 0 is `1..1030`, Rust/Dart corpus is 105/105, and Lua is
  72/72. Strings are unchanged, booleans are `1`/`0`, finite numbers have stable decimal text, and non-text kinds
  yield null. Retired `concat` remains rejected; codeblock syntax stays under `FUTURE-PARITY-BACKLOG.11.1`.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`.
- blockers: none. in_flight_uncommitted: none after this commit; generated artifacts clean.
