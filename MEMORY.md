# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.2.2.0` — regex/split/mutation mechanism split.
- latest_commit: `59e6f977` — `LUA-BACKEND-PARITY.4.3.2.1.3 - align scalar text coercion`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.2.2.0 - split Lua regex string mechanisms`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.2.2.1`; add typed helper-regex values, governed flags, and `matches`
  through the existing in-process PCRE2 owner on both Lua ABIs.
- next_action: implement a strict helper-regex adapter (`i/m/s/x`, no-op `g/o`, reject unknown), evaluate regex
  ActionIR values, then lock function/terminal-receiver `matches` including null and invalid boundaries.
- current_proof: planning probes show Lua ActionIR already preserves regex patterns/flags and mutation targets;
  `interpreter.lua` lacks regex value evaluation and statement-context dispatch, while `matching.lua` already owns
  PCRE2 compilation. Runtime remains 72/72 on both ABIs from the prior leaf. The documented invalid-pattern
  fail-closed contract versus Perl generated-literal compile failure is recorded under active `.2.2.1`.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`.
- blockers: none. in_flight_uncommitted: none after this planning commit; generated artifacts clean.
