# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)
LinkedSpec is a progressive-extraction parser DSL. This is the bounded layer-A pointer to *now*, not history.
## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Track under `docs/tasks/`/`docs/TASK_TREE.md`; follow `COMMIT.md`; use `KNOWLEDGE_MAP.md`/`TOOLBOX.md` first; require an owning leaf and run `scripts/check_memory_architecture.sh` before commit.
## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `REPO-ROOT-PATH-PORTABILITY.2.1` — structural path portability is mechanically gated.
- latest_commit: `REPO-ROOT-PATH-PORTABILITY.2.1 - gate repository path portability` (this commit).
- current_path_portability: ADR `0052` requires persisted repository-content paths to be root-relative and runtime
  roots to derive from the current script/module/executable or explicit caller root. Audit found 0 tracked current/
  former checkout literals and 0 symlinks. Perl/Dart/Julia/Lua process probes pass outside the checkout. Rust `.1.1`
  now searches executable then cwd ancestry for the bundled marker; the copied-binary RED is green with exact
  `"relocated-root"`, and explicit `run_with_context` native-resolution behavior remains unchanged. Legacy `.1.2`
  now uses relative project defaults, PATH tools, caller-owned Tcl/Tkx discovery, and configured network inputs.
  Julia `.1.3` uses PATH-selected Julia, relative operands, and runtime-composed caller-writable depots. `.2.1`
  registers one read-only 14-case doctrine over tracked parent text and all five primary runtime-anchor families.
- current_path_frontier: remediation `.1.1-.1.3` and static enforcement `.2.1` are done; `.2.2` is active on the
  recurring relocated-process oracle, four outside-cwd anchor repeats, and final closeout.
- paused_semantic_frontier: after the relocation tree closes, resume `FUTURE-PARITY-BACKLOG.10.7.3.2.1` privacy/
  failure/runtime-static/lifecycle/isolation from clean semantic commit `99a3df5b`; no semantic state was changed.
- current_semantic_introspection: neutral 6 groups/20 answers/89 mutations; rollout 5/9 and admission 4/6. Perl,
  Rust, Dart, Julia are admitted. Lua source/outcome and private static graph 12 records/14 relations/7 refs exist;
  outward privacy/failure/runtime-static/isolation remains the paused next implementation.
- current_rule_label_contract: ADR `0051` pins nonempty Unicode 17 `XID_Continue` at every position with exact
  identity and strict UTF-8. One generated class pins 806 ranges across all 12 grammar sites and five backends.
  All 9 positives/2 distinct pairs preserve identity through every route; all 8 negatives fail every trust role.
- current_closed_semantics: cursor 8+0/60; root 7+0/54; duplicate slots 7+0/59; repeated action 8+0/54; its
  checker-owned closed next owner remains `FUTURE-PARITY-BACKLOG.10.1`.
- current_signoff: `.2.1` direct/staged checker 14 cases + 5 anchors and five-doctrine driver pass; mdBook/KM
  706/5,513/43-line memory/whitespace pass. Canonical Rust 1/1 80.26s, Dart 1/1, Julia 416/416 28.6s, Perl 66x2,
  Phase 0 1,031/1,031 657s; legal caller paths remain accepted and six ledgers stay unchanged.
- latest_bootstrap_read: 2026-07-25 — README, both roadmaps, memory/bootstrap/commit/task doctrines, code/import
  and active semantic owner chain, all 46 mdBook pages, relevant KM/Toolbox/ADRs, and consumer topologies read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: hard lock at 300 new local commits; current counter 22/300 after this commit; never push per commit.
- storage: the repository is on a 4-TB SSD, so disk pressure is not urgent. Clean only unmistakable disposable
  task artifacts when useful; retain reusable caches absent a concrete problem.
- environment: use `perl -Iperl`; clear `PERL5LIB` for phase0; allow 30m for canonical; stack a writable Julia depot.
- deferred: generated parser+stimuli `.8.1`; inter-match gap/named-slot `.1-.7`; inspector `.13.1`; authoring
  `.14`/`.15`; marker repair `.22`; book drift `.23`; parenthesis-free conditions; lexical capture if justified.
- blockers: none. in_flight_uncommitted: none after this commit. next_action: from the clean `.2.1` commit, create
  the director-requested task tree that moves all LinkedSpec-owned scratch/cache/depot data to SSD-backed,
  repo-derived storage; keep `.2.2` pending behind that clean pivot and do not push.
