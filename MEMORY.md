# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.3` — exact 15-role Dart root admission, 34 mutations,
  package 270, primary 65x2, corpus 105, canonical signoff, parent closeout, and cleanup land at clean `31cc78ae`.
- latest_commit: `31cc78ae` — `FUTURE-PARITY-BACKLOG.9.1.1.2.3.3 - admit Dart root selection`
  (ahead: 218; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.0 - map Julia root selection`.
- active_work_unit: Behavior-free Julia root-selection preflight `.9.1.1.2.4.0` is active task-tree-first after the
  clean Dart commit; root core `.4.1` and routes `.4.2` precede cursor `.9.1.6`, then final admission `.4.3`.
- next_action: stage/commit signed-off `.4.0`, clear the brief, prove clean, then activate Julia root core `.4.1`
  task-tree-first before any behavior change.
- current_proof: Root-selection rollout stays 4 complete / 3 pending. Default-environment Julia shared primary
  fails 34/65: markerless root selection is one failure; the other 33 are the separately pending Julia cursor
  migration's help/usage/request-trace projection. Explicit ordinary override, first authored marker, unknown
  selector, and native seek/consume cases pass. Exact API probes prove marker-required validation blocks an
  otherwise-correct explicit > first marker > first rule runtime fallback; loaded/normalized/emitted routes
  re-enter validation; generated direct bypass works; zero/unknown/descriptor/trace identities remain legacy.
  `Pkg.test()` exposes the known cursor help mismatch at 56/57 in primary arguments; corpus execution passes
  105/105. Root governance remains 4/7 with 34 mutations. Roadmap 1/7 drift is repaired and mechanically parked
  for final no-drift `.6`. KM 609/4,390, mdBook, four doctrines, cursor governance, and canonical Perl root 7+5,
  cursor 288, reference primary 65x2, and Phase 0 1,031/1,031 in 641 seconds pass. Generated 11 MiB book, Python
  cache, and consumed temp log are removed; Julia compiled cache is retained for immediate `.4.1` reuse.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0046`, neutral/Perl/Rust/Dart root precedent, and exact Julia preflight seams/gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.4-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: Julia `.4.0` behavior-free task/task-index/live/memory activation; no
  Julia behavior, contract, fixture, test, capability, or rollout state changed. Exact default/POSIX primary,
  package/corpus, docs/KM, canonical, and cleanup results are consumed; commit remains. No background job runs.
  Parked ignored work is untouched.
