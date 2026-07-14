# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.16.7` — admitted and closed punctuation-light aliases.
- latest_commit: `d27beccc` — `FUTURE-PARITY-BACKLOG.16.6 - implement Lua zero-argument aliases`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.16.7 - admit punctuation-light aliases`.
- active_work_unit: clean task-tree pivot pending from completed `.16` back to `LUA-BACKEND-PARITY.4.3.6.4`.
- next_action: commit `.16.7`, verify a clean tree and zero-byte brief, then mark Lua `.4.3.6.4` in progress before
  implementing signature-governed built-in final blocks and scoped `with`.
- current_proof: The recurring composed command passes neutral 6/4/6 cases, Perl 7, Rust 5, Dart 5, Julia 55,
  PUC Lua 109, and LuaJIT 109. Capability census is 64/0/0; examples, ADR, book, roadmap, task, and KM agree.
  Parenthesis-free conditions remain excluded. Lua has no generated-source emitter; `.8.1-.8.4` remains its owner.
  Rust/Dart/Julia/Lua pre-existing `.contains()` outcomes remain under helper owner `.5`.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua built-in final blocks `.4.3.6.4`; parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.16.7` capability/script/public/task/KM/live-doc closeout awaits
  its prepared commit before the required clean pivot. Oracle timeout calibration remains `.7.0`.
