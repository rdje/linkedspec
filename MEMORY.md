# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.5.2` — normal Dart live/loaded/reconstructed rule entries
  derive cursor plus structure locally; generated v1 stays staged; full canonical signoff passes.
- latest_commit: `fc31fc12` — `FUTURE-PARITY-BACKLOG.9.1.5.1 - normalize Dart rule edges`
  (ahead: 201; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.5.2 - derive Dart rule-local cursor execution`.
- active_work_unit: Dart `.9.1.5.2` implementation and full signoff are complete; commit workflow is in progress.
- next_action: prepare the brief, stage/commit `.9.1.5.2`, clear it, verify a clean tree, then activate descriptor
  `.9.1.5.3` task-tree-first.
- current_proof: normal Dart entry derives AND consume/sequence and OR-default seek/choice once per entered rule;
  nested action/blind/call/recursion re-derives child policy. Live, loaded, normalized JSON, and trace consume all
  36 family, eight parent/child, and two structural rows. Generated v1 alone retains bounded compatibility.
  Strict analysis passes; affected five suites 82/82; broader eleven suites 142/142; corpus 105/105; complete
  package 253/1 only at staged shared help; primary remains exact 30/63x2. Neutral remains 68 files, 3/5 rollout,
  34 rejected mutations. Canonical CI repeats Perl admission 288, reference primary 63x2, and Phase 0 1,031/1,031
  in 629 seconds, then exits 0. No background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, neutral/admitted references, Dart generated/live/descriptor/CLI seams, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.6-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed/verified `.9.1.5.2` source, tests, Knowledge Map, task, live docs,
  and mdBook await the commit workflow. Parked ignored work is untouched.
