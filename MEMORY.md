# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.6.4` — executed built-in final blocks and scoped `with`.
- latest_commit: `4a2adda9` — `FUTURE-PARITY-BACKLOG.16.7 - admit punctuation-light aliases`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.6.4 - execute Lua built-in final blocks`.
- active_work_unit: verified `.4.3.6.4` closeout; `.4.3.6.5.1` is the prepared clean-pivot frontier.
- next_action: commit `.4.3.6.4`, verify a clean tree and zero-byte brief, then implement the shared scoped callback
  frame and deterministic harray leaf traversal under `.4.3.6.5.1`.
- current_proof: Copied built-in metadata governs helper/receiver `with` and later tree callbacks. Attached and
  parenthesized `with` forms execute identically through copied/restored uniform scope; prior/absent bindings
  restore after success, local return, callback error, and result-copy error. PUC Lua and LuaJIT pass 112/112 plus
  corpus/CLI scaffolding; Perl toolbox lowering/execution agrees. Capability remains 64/0/0 because complete
  cross-backend generic callable blocks are still future.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.4.3.6.4` runtime/test/public/task/KM/live-doc closeout awaits
  its prepared commit before the required clean pivot to `.4.3.6.5.1`. Oracle timeout calibration remains `.7.0`.
