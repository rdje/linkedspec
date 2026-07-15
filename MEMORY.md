# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.3.0.1` — adopted descriptor-v3 and completion-time census policy.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.3.0.1 - settle descriptor and census policy`.
- prepared_commit: `none`.
- active_work_unit: executable descriptor contract and Lua emission `LUA-BACKEND-PARITY.5.3.1`.
- next_action: extend the neutral executable outward union/checker with exact final-codeblock-v3 fields, then make
  Lua consume it before one-emitter full-pipeline trace `.5.3.2` and census-preserving closeout `.5.3.3`.
- current_proof: ADR `0041` makes final-codeblock functions outward descriptor v3 over fixed `params`/`arity` plus
  sole final `parameter_kinds[name] = "codeblock"`; fixed-v1/variadic-v2 stay exact. Lua remains outside the
  four-backend all-pass census until sole expansion owner `.8.4`. No source, emitted descriptor, capability,
  status, or test expectation changed; preceding Lua proof remains 153/153 on both ABIs, capability 64/0/0, and
  canonical CLI 61x2 plus Phase 0 `1..1031`. Mutation testing remains manual-only and was not run. Artifact audit
  removed reproducible Rust/Dart caches and deinitialized eight verified-clean nested pgen stimulus submodules;
  restore them with `git -C rgx/subs/pgen submodule update --init --recursive` when pgen corpus work needs them.
- latest_bootstrap_read: 2026-07-15 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.5.3.1`; the neutral executable contract/checker must precede backend emitter code.
  in_flight_uncommitted: none after the `.5.3.0.1` decision commit; mutation campaigns remain parked and no mutant
  run belongs to ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
