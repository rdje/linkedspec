# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL (Perl). This file is **layer A** of
`MEMORY_ARCHITECTURE.md`: the bounded, overwrite-only pointer to *now* — not a log. Its
full history lives in git (layer D); per-unit work lives in the task-trees (layer B);
durable cross-cutting facts live in `docs/decisions/` (layer C).

## How to resume
- Read `MEMORY_ARCHITECTURE.md` (the memory system — mandatory and mechanically enforced)
  and `README.md` (project objective/layout), then `SESSION_BOOTSTRAP.md`.
- Work is tracked in task-trees under `docs/tasks/` (index: `docs/TASK_TREE.md`); follow
  the commit workflow in `COMMIT.md` with the task-tree leaf id in the subject.
- Durable facts/decisions live in `docs/decisions/` (index: `INDEX.md`).
- Doctrine (non-negotiable): no change without an owning task-tree leaf first — see
  `docs/decisions/0001-task-tree-and-commit-doctrine.md`.
- Before committing, run `scripts/check_memory_architecture.sh` (git hooks + the local CI
  gate `tools/run_ci_local.sh` enforce it).

## Current state (OVERWRITE this block each update — do not append)
- latest_commit: `4c667b7` — "SPEC-SPEC-SELFHOST.2 — rewrite spec.spec as a faithful self-hosting grammar"
- active_work_unit: `SPEC-SPEC-SELFHOST` → frontier leaf: `SPEC-SPEC-SELFHOST.4` (pending — docs sync + finalize)
- next_action: fix the PRE-EXISTING RTLUtils phase0 hang (new tree, see blockers) so the gate runs; then SPEC-SPEC-SELFHOST.4 mdBook/DEVELOPMENT_NOTES self-hosting note.
- done: `.2`+`.3` committed (`4c667b7`) — `specs/spec.spec` rewritten as a faithful self-hosting grammar (spec_file -> 12 part rules, group-at-rule_header, mirrors BootstrapSpec::Core SPEC_ROOT). ratio 1.0000; 19/19 paragraph-count fidelity; cross-check 20/20; self-parses (13==13); possessive-quantifier perf hardening.
- in_flight_uncommitted: stale Rust exploration toward the superseded Rust-self-hosting target (rust expr.rs regex-flag skip, parser.rs parse_inline_body [audit: conditional capture-group bug], runtime.rs set_retv [dead] + retv, helpers.rs debug eprintln!). NOT part of this slice; decide under RUST-PARITY.
- blockers: PRE-EXISTING phase0 hang (NOT this slice) — `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils` run, 15s timeout). `perl/RTLUtils.pm` unmodified by me (last touch e6e8a96). Run phase0 only with a hard timeout until fixed. New tree needed: RTLUTILS-REGEX-HANG.
- rust-followon: RUST-PARITY.4 (Rust self-hosting) superseded; real Rust audit follow-on = retv-propagation BLOCKER, match/entry split, byte-slice UTF-8 panics, dup match arms, oracle corpus (.5/.7).
