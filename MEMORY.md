# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.0` — behavior-free Dart seam map proves exact 64/65x2,
  package 260, corpus 105, fallback/validation/failure/descriptor causality, canonical signoff, and cleanup.
- latest_commit: `41ed8300` — `FUTURE-PARITY-BACKLOG.9.1.1.2.2.3 - admit Rust root selection`
  (ahead: 214; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.0 - map Dart root selection`.
- active_work_unit: Dart parent `.9.1.1.2.3` remains active; preflight `.3.0` is fully signed off and awaiting its
  prepared commit. Core `.3.1` is not active and must wait for the clean boundary.
- next_action: commit `.3.0`, clear the brief, prove the tree clean, then activate core/descriptor `.3.1`
  task-tree-first and implement only its centralized validation/resolution/failure/identity boundary.
- current_proof: Dart primary is exactly 64/65 twice; markerless first-rule alone fails compile validation. Direct
  probes prove ordered native, normalized, generated-default, and explicit selection already work behind
  `_checkTopRuleExists`; loaded and emitted source re-enter validation. Unknown/zero failures still use untyped
  `rule_lookup`/`top_rule_selection`, descriptor root metadata lacks `entry_rule_contract`, and strict/request
  trace are already independent. Focused owners pass 97; complete Dart passes format, analysis, package 260, and
  corpus 105. Root governance stays 3/4 plus 29 mutations; mdBook and KM 604/4,336 pass. Canonical passes all four
  doctrines, Perl root 7+5, cursor 288, reference primary 65x2, and Phase 0 1,031/1,031 in 655s. Cleanup removes
  generated book/cache only. No Dart behavior/capability changed; rollout remains 3/7. No background job runs.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0046`, neutral/Perl root precedent, exact Rust owners/tests/routes, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.3-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed Dart `.3.0` map/signoff awaits its prepared commit only; core
  `.3.1` is not activated. No background job runs. Parked ignored work is untouched.
