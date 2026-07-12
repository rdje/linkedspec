# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.2.2.1` — strict Lua helper regex and `matches`.
- latest_commit: `a263556d` — `LUA-BACKEND-PARITY.4.3.2.2.0 - split Lua regex string mechanisms`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.2.2.1 - add Lua helper regex matches`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.2.2.2`; implement pure literal/regex split values and string-to-array
  receiver continuation without mutation.
- next_action: use the typed helper-regex adapter for pure split, preserve leading/trailing empty fields, implement
  Unicode-character empty-delimiter splitting, and continue returned arrays through compatible receiver helpers.
- current_proof: function/terminal-receiver `matches` applies PCRE2 `i/m/s/x`, accepts no-op `g/o`, and returns
  false for null/non-regex/unknown/invalid inputs. Full PUC Lua and LuaJIT gates pass 73/73. The Perl invalid-literal
  generation boundary remains recorded, not treated as authorization for a reference-engine pivot.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`.
- blockers: none. in_flight_uncommitted: none after this planning commit; generated artifacts clean.
