# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.7.5` — add Lua boundary capture.
- latest_commit: `10f10ddd` — `LUA-BACKEND-PARITY.4.3.7.2 - add Lua anonymous capture helpers`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.7.5 - add Lua boundary capture`.
- active_work_unit: verified `.4.3.7.5` executes non-consuming earliest usable compiled-rule boundary lookahead
  with consume-mode independence, EOF fallback, and state-preserving unusable behavior.
- next_action: commit `.4.3.7.5`, clear the brief, verify a clean tree, then cleanly pivot to neutral plus Perl/Rust
  complete named-mark `FUTURE-PARITY-BACKLOG.17.1`.
- current_proof: One multibyte test locks bare/quoted rules, reversed argument order, unresolved/regex-free targets,
  Unicode cursor values, unconsumed rest, receiver continuation, EOF fallback, and zero/all-unusable no-op. The
  dual-ABI Lua gate passes 117/117 plus syntax/process/manifest checks. Toolbox probing routes Perl's zero-argument
  undefined-handler failure versus typed-backend null to `.5`; no inventory/corpus/generated/capability changed.
  Full local CI passes capability 64/0/0, CLI 61/61 twice, and phase0 `1..1031` in 862 seconds.
- latest_bootstrap_read: 2026-07-13 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.4.3.7.5` runtime/test/docs passed final gates and await the
  prepared commit. Oracle timeout calibration remains future backlog `.7.0`.
