# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)
LinkedSpec is a progressive-extraction parser DSL. This is the bounded layer-A pointer to *now*, not history.
## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Track under `docs/tasks/`/`docs/TASK_TREE.md`; follow `COMMIT.md`; use `KNOWLEDGE_MAP.md`/`TOOLBOX.md` first;
  require an owning leaf and run `scripts/check_memory_architecture.sh` before commit.
## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `PROJECT-DATA-SSD-ROOTING.1.2` — 14 hook/doctrine/KM/canonical/book/backend boundaries
  self-initialize repo-filesystem project data and pass hostile outside-cwd proof.
- latest_commit: `PROJECT-DATA-SSD-ROOTING.1.2 - route standard workflows to SSD storage` (this commit).
- current_storage_contract: ADR `0053` makes the current repository filesystem authoritative for project-owned
  build/generated output, caches/depots, logs/traces, runtime fixtures, and scratch. Durable paths are root-relative;
  absolute runtime roots derive from the current checkout. Cross-volume reads are denied except explicit caller
  inputs and documented strictly necessary external tool/OS resources. Retained migration is copy/verify/use/delete;
  shared ambiguous caches are populated locally and never deleted wholesale.
- current_storage_inventory: 65 CLI workspaces + 2 Julia depots = 67 directories/135,756 KiB; CLI content 17
  files/1,590 bytes; 2 exact Dart active-root records; 1 LinkedSpec stanza in a shared Julia log. Across 1,936
  tracked parent files, 100 allocate temporary state; family counts Perl 24/Rust 16/Dart 18/Julia 17/Lua 13/
  Python 3/shell 12 with overlap; 24 executable files have off-repository defaults; KM 97 cards/107 old lines.
- current_storage_initializer: source `tools/project_data_env.sh`; it derives its own checkout and creates ignored
  `/.linkedspec-data/{scratch,cache}`. It preserves only same-device overrides and exports LinkedSpec roots,
  TMPDIR/TMP/TEMP, Cargo home/target, Dart package cache, and local-plus-system Julia depots (no home depot).
- current_storage_routing: hook, five doctrines, KM gen/check, canonical Perl, Rust/Dart/Julia/Lua, and mdBook
  wrappers source the initializer; direct lower-level commands still source it explicitly.
- current_storage_frontier: `.1.3` is active from the clean `.1.2` commit: define collision-safe scratch/cache
  lifecycle, success/failure cleanup, concurrency isolation, and interrupted-run recovery.
- paused_path_frontier: ADR `0052` relocation remediation `.1.1-.1.3` and structural doctrine `.2.1` are done;
  `REPO-ROOT-PATH-PORTABILITY.2.2` waits behind storage `.5` so its process oracle proves SSD-local IO too.
- paused_semantic_frontier: after storage and relocation close, resume `FUTURE-PARITY-BACKLOG.10.7.3.2.1` from
  clean semantic commit `99a3df5b`; no semantic state changed. Neutral is 6/20/89, rollout 5/9, admission 4/6.
- current_closed_semantics: cursor 8+0/60; root 7+0/54; duplicate slots 7+0/59; repeated action 8+0/54; its
  checker-owned closed next owner remains `FUTURE-PARITY-BACKLOG.10.1`.
- current_signoff: `.1.2` Bash syntax, initializer/workflow outside-cwd oracles, routed mdBook, five doctrines,
  KM 709/5,548, task metadata, 45-line memory, and whitespace pass. Outside-cwd canonical passes Rust 1/1 in 77.50s,
  Dart 1/1, Julia 416/416 in 27.1s, primary 66x2, and Phase 0 1,031/1,031 in 662s. No old data change.
- latest_bootstrap_read: 2026-07-25 — README, both roadmaps, memory/bootstrap/commit/task doctrines, code/import
  and active semantic owner chain, all 46 mdBook pages, relevant KM/Toolbox/ADRs, and consumer topologies read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: hard lock at 300 new local commits; current counter 25/300 after this commit; never push per commit.
- storage: repository is on the 4-TB SSD. Retain reusable SSD caches. Do not use OS temp/home cache for project
  state; do not delete old exact data until its SSD replacement is verified and used; never delete ambiguous data.
- environment: routed commands self-initialize; source `tools/project_data_env.sh` before lower-level direct commands;
  use `perl -Iperl`; clear `PERL5LIB` for phase0; allow 30m for canonical.
- blockers: none. in_flight_uncommitted: none after this commit. next_action: from clean `.1.2`, implement
  `PROJECT-DATA-SSD-ROOTING.1.3`; verify, document, commit at 26/300, clear brief, and do not push.
