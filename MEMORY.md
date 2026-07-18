# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.5.5` — Dart exposes no caller-global cursor override, passes
  exact 260/63x2/105 plus neutral/canonical signoff, and awaits only its clean commit.
- latest_commit: `79c51a21` — `FUTURE-PARITY-BACKLOG.9.1.5.4 - emit Dart generated-source v2`
  (ahead: 204; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.5.5 - remove Dart global cursor overrides`.
- active_work_unit: Dart `.9.1.5.5` is complete and verified but uncommitted; no pivot is allowed until its clean
  commit. Root-selection `.9.1.1.2.0` is the next leaf; Dart admission remains staged for `.9.1.5.6`.
- next_action: rerun lightweight post-evidence checks, clean generated artifacts, commit `.9.1.5.5` per `COMMIT.md`,
  clear the brief, verify clean, then activate root-selection decision leaf `.9.1.1.2.0` task-tree-first.
- current_proof: caller-global cursor authority is removed from the Dart engine, loader, corpus, staged parser,
  runtime context, primary help/options/execution, and request trace. Retired `--parse-mode` returns exact usage 2;
  `--top-rule` remains and its existing ordinary-rule test explicitly locks priority over authored markers. Strict
  analysis, affected 120/120, complete package 260/260, primary 63/63 default+POSIX, corpus 105/105, generated and
  logical recurring gates pass. Neutral inventory is 66 files at 3/5 with all 34 mutations rejected. Director
  root-selection precedence (explicit selector > first `::` > first `:` if no marker) is durably split under
  pending `.9.1.1.2`; current Dart/Rust/Julia/Lua validators still require `::`, so `.5` introduces no divergence.
  Knowledge Map is 594/4,235; governance/mdBook pass. Canonical CI passes Perl admission 288, reference primary
  63x2, and Phase 0 1,031/1,031 in 627 seconds, exit 0. No background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, neutral/admitted references, Dart generated/live/descriptor/CLI seams, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection `.9.1.1.2` becomes the next pivot after clean `.9.1.5.5`; generated parser+stimuli `.8.1`;
  cursor `.9.1.5.6-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.9.1.5.5` implementation, tests, docs, Knowledge facts, root-selection
  follow-up split, and signoff evidence are owned and uncommitted. Parked ignored work is untouched.
