# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)
LinkedSpec is a progressive-extraction parser DSL. This is the bounded layer-A pointer to *now*, not history.
## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Track under `docs/tasks/`/`docs/TASK_TREE.md`; follow `COMMIT.md`; use `KNOWLEDGE_MAP.md`/`TOOLBOX.md` first;
  require an owning leaf and run `scripts/check_memory_architecture.sh` before commit.
## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.10.9.3.4`; repository HEAD after commit with subject
  `FUTURE-PARITY-BACKLOG.10.9.3.4 - close Rust MCP implementation`, based on clean `13d9ce17`.
- active_leaf: none after the `.10.9.3.4` completion commit; activate Dart MCP `.10.9.4` only from its clean tree.
- active_scope: no in-flight work. Perl and Rust parents are closed at 2/5 implementations + 2/6 runtimes; shared
  MCP rollout remains pending, and no server behavior, ledger status, or transport-contract bytes changed in the
  Rust closeout.
- active_exclusions: no executable, SDK/network/async transport, source bootstrap, semantic/
  parser/compiler/executor/trace/cache/primary-CLI behavior, ledger status, rollout, aggregator, or legacy adapter.
- next_after_clean_commit: activate Dart native MCP `.10.9.4` task-tree-first from the clean closeout commit; no
  push.
- current_storage_contract: ADR `0053` makes the current repository filesystem authoritative for project-owned
  output, caches/depots, logs/traces, runtime fixtures, and scratch. Durable paths are root-relative and absolute
  runtime roots derive from the current checkout. Cross-volume reads require explicit/documented authority.
- current_storage_lifecycle: marker v2 binds each command/descendants to one process group, waits for drain,
  signals group-wide, rechecks before deletion, and retains live/reused/invalid/indeterminate authority.
- current_storage_routing: 40 hook/doctrine/KM/canonical/backend/book/matrix/storage/path boundaries self-root and
  enter one managed run; Cargo/Dart/Julia/Lua/Python use supported root-relative wrappers.
- current_storage_backends: Perl 24, Rust 17, Dart 18, Julia 17, and Lua 16 owner proofs route project data to the
  repository volume; only documented read-only toolchain/OS resources remain external.
- current_storage_tools: tool oracle freezes 3 Python temp / 13 shell allocator / 24 tool owners; bytecode/map/
  book/CLI/TAP/oracle output is same-device, and external/symlink output is pre-rejected.
- current_storage_doctrine: `PROJECT-DATA-STORAGE` governs current tracked sinks/defaults and commands; 28 cases
  pass. Its process complement locks six required families, hostile inputs, relocation, and kernel denial.
- current_path_contract: ADR `0052`, structural `REPO-ROOT-PATHS`, and moved-process proof lock root-relative
  identity plus exact outside-checkout Perl/Dart/Julia/Lua named-spec and Rust executable-root behavior.
- current_semantic_governance: six groups / 20 responses / 105 mutations; rollout 7/9; native admission 6/6;
  capability census 80 implemented / 0 partial / 0 missing.
- closed_contract_handoff_guard: retain historical next owner `FUTURE-PARITY-BACKLOG.10.1` until tracked `.22`
  moves the repeated-action checker's immutable handoff to a stable governed home.
- current_closed_semantics: cursor 8+0/60; root 7+0/54; duplicate slots 7+0/59; repeated action 8+0/54.
- current_future_direction: director-approved ADR `0056` remains pending under `.14.1-.8`; ADR `0045` retains sole
  inter-match-gap ownership. Neither is the current leaf.
- latest_bootstrap_read: 2026-07-29 — required bootstrap, code owners, all 46 mdBook pages, KM/Toolbox/ADRs read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, clear brief, and prove clean first.
- push_policy: hard lock at 300 new local commits; counter 77/300 after this commit; never push per commit.
- storage: repository is on the 4-TB SSD. Retain reusable SSD caches. Do not use OS temp/home cache for project
  state; never delete ambiguous data; use copy/verify/use/delete for exact owned migrations.
- environment: routed commands self-initialize; source `tools/project_data_env.sh` before lower-level commands;
  use `perl -Iperl`; clear `PERL5LIB` for phase0; canonical needs nested macOS sandbox permission and up to 30m.
- canonical_state: Rust MCP 15 + 3 + 4 + admission 1, semantic Rust 1/1 in 80.73s, Dart 1/1, Julia 416/416 in
  28.8s, CLI 66x2, RAM 67%, and Phase 0 1,031/1,031 in 650s pass; MCP 35/10/10/68 and ledger 2/5 + 2/6 exact.
- blockers: none. next: activate Dart native MCP `.10.9.4` task-tree-first from clean HEAD.
