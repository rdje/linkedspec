# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.0` — spec-facing aggregate-selector inventory and split.
- latest_commit: `6fa44160` — `FUTURE-PARITY-BACKLOG.11.3.4 - close Perl callable codeblocks`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.0 - split aggregate selector retirement`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.1`; adopt the neutral selector-free binding/mutation contract.
- next_action: define and check exact future fixtures for bare typed reads/mutations, absent binding creation,
  static child-rule precedence for push, mutable three-argument split, post-mutation values, `set` target return,
  portable selector diagnostic, migration spellings, and ordinary constructor classification.
- current_proof: Exact scans find 651 selector-shaped calls in 82 tracked specs, including 227 in 15 shipped specs;
  parent categories include copy/push/set/is_nonempty/split and 17 receiver forms. Toolbox lowering shows bare
  copy/read/receiver/set forms but child-rule interpretation for `push(items,value)` and unsupported bare mutable
  `split(parts,source,delimiter)`. Perl/Rust/Dart/Julia/Lua owner seams are durably split before behavior.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); Rust/Dart/Julia codeblock parity and resumed Lua work follow `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.0` inventory/task/docs/Knowledge Map split is prepared for gates
  and commit. Lua scalar numeric `.4.3.3.1.4` remains ready after the selector-retirement arc.
