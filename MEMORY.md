# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.2` — every loaded, serialized, generated, emitted,
  trace, diagnostic, and descriptor route now composes Rust's ordered root resolver; Rust-local and canonical
  signoff pass, and the completed leaf awaits only its prepared clean commit.
- latest_commit: `e39db876` — `FUTURE-PARITY-BACKLOG.9.1.1.2.2.1 - implement Rust root resolution`
  (ahead: 212; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.2 - converge Rust root routes`.
- active_work_unit: Rust composed-route leaf `.9.1.1.2.2.2` is done and signed off while awaiting its commit.
  Exact topology and rollout admission remain exclusively `.2.3` and are not active before that clean boundary.
- next_action: commit `.2.2`, clear and verify `git_message_brief.txt`, prove the tree clean, then activate
  topology/admission `.2.3` task-tree-first.
- current_proof: Loaded and serde-reconstructed state plus every generated/emitted direct, compatibility, trace,
  and diagnostic-output role now resolve explicit > first marker > first rule without widening format v2 or
  mutating descriptor identity. Focused routes 6, source emitter 6, root core 6, diagnostics 5, loader 5, trace 10,
  diagnostic output 7, descriptor/types, generated governance, and classifier 105 pass. Full Rust-local passes
  oracle 105/206.37s, classifier 105/235.54s, integration 197, emitted source 6/43.76s, and primary 65x2. Strict
  new-code Clippy adds no option-sibling lint; the known untouched approximate-PI test still controls exit 101.
  Canonical CI passes four doctrines, root consumers 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in
  627s. The latent logical-helper marker drift is durably repaired with all 26 mutations green. Cleanup removes
  16,558 Cargo files and reduces `rust/target` from 2.9 GiB to 99 MiB, plus the generated book/cache. Root rollout
  remains 2/7 by design. KM is 602/4,320.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0046`, neutral/Perl root precedent, exact Rust owners/tests/routes, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.2-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.2.2` is fully implemented, verified, documented, and cleanup-complete;
  only its prepared commit/brief-clear boundary remains. No background job runs. Parked ignored work is untouched.
