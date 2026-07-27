# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)
LinkedSpec is a progressive-extraction parser DSL. This is the bounded layer-A pointer to *now*, not history.
## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Track under `docs/tasks/`/`docs/TASK_TREE.md`; follow `COMMIT.md`; use `KNOWLEDGE_MAP.md`/`TOOLBOX.md` first;
  require an owning leaf and run `scripts/check_memory_architecture.sh` before commit.
## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `PROJECT-DATA-SSD-ROOTING.3.2` — independent pre/post-use old-root and bounded shared-
  metadata censuses are zero; no external deletion target exists; retained SSD copies and all six oracles pass.
- latest_commit: `PROJECT-DATA-SSD-ROOTING.3.2 - retire internal-volume project data` (this commit).
- current_storage_contract: ADR `0053` makes the current repository filesystem authoritative for project-owned
  build/generated output, caches/depots, logs/traces, runtime fixtures, and scratch. Durable paths are root-relative;
  absolute runtime roots derive from the current checkout. Cross-volume reads are denied except explicit caller
  inputs and documented strictly necessary external tool/OS resources. Retained migration is copy/verify/use/delete;
  shared ambiguous caches are populated locally and never deleted wholesale.
- current_storage_inventory: fresh pre/post-use censuses find zero LinkedSpec owner in both runtime-derived old temp
  roots, bounded Dart/Julia metadata, and the superseded same-SSD target identity. `.3.2` therefore deletes zero
  external paths. Retained Perl 65/17/1,590-byte and Julia 346/256/133,963,036-byte plus 24/15/4,284,303-byte copies
  remain exact; ambiguous shared caches remain untouched and unused.
- current_storage_initializer: source `tools/project_data_env.sh`; it derives its own checkout and creates ignored
  `/.linkedspec-data/{scratch,cache}`. It preserves only same-device overrides and exports LinkedSpec roots,
  managed-runs root, TMPDIR/TMP/TEMP, Cargo home/target, Dart cache, and local-plus-system Julia depots (no home).
- current_storage_routing: 35 hook/doctrine/KM/canonical/backend/book/matrix/storage boundaries self-root and enter
  one run; targeted Cargo/Julia/Lua/Python use supported root-relative wrappers.
- current_storage_lifecycle: marker v2 binds each command/descendants to one dedicated process group, waits for
  drain, signals group-wide, rechecks before deletion, and retains live/reused/invalid/indeterminate authority.
- current_storage_perl: `tools/test_perl_project_data_storage.sh` proves all 24 owners, implicit/explicit
  `File::Temp`, explicit trace, real CLI child cwd/cleanup, repository device, and preserved inert path values.
- current_storage_rust: `tools/test_rust_project_data_storage.sh` proves all 17 owners, complete locked offline Cargo
  cache, generated child projects, traces, real copied-binary relocation, same device, and zero old temp residue.
- current_storage_dart: `tools/test_dart_project_data_storage.sh` proves all 18 owners, all 47 locked packages
  offline, generated callers/traces, same device, zero old warmed-cache duplicate, and zero shared active roots.
- current_storage_julia: `tools/test_julia_project_data_storage.sh` proves all 17 owners, five package trees, offline
  JSON3, generated v2/trace paths, same device, and no disposable machine-path usage metadata. Exact old residue is
  zero; only Julia-managed system depots remain necessary external read-only inputs.
- current_storage_lua: `tools/test_lua_project_data_storage.sh` proves 13 owners, both ABI module pairs, quoting,
  native/generated/trace use, hostile-output rejection, cleanup, and zero old residue; toolchain reads are external.
- current_storage_tools: tool oracle freezes 3 Python temp/12 shell allocator/19 checker owners; bytecode/map/book/
  CLI/TAP/oracle output is same-device, and external/symlink output is pre-rejected.
- current_storage_frontier: migration/residue parent `.3` is complete. `.4.1` adds the structural storage-locality
  doctrine before process-level IO proof `.4.2`.
- paused_path_frontier: ADR `0052` relocation remediation `.1.1-.1.3` and structural doctrine `.2.1` are done;
  `REPO-ROOT-PATH-PORTABILITY.2.2` waits behind storage `.5` so its process oracle proves SSD-local IO too.
- paused_semantic_frontier: after storage and relocation close, resume `FUTURE-PARITY-BACKLOG.10.7.3.2.1` from
  clean semantic commit `99a3df5b`; no semantic state changed. Neutral is 6/20/89, rollout 5/9, admission 4/6.
- closed_contract_handoff_guard: retain historical next owner `FUTURE-PARITY-BACKLOG.10.1` in bounded memory until
  tracked governance repair `.22` moves the repeated-action checker's immutable handoff to a stable governed home.
- current_closed_semantics: cursor 8+0/60; root 7+0/54; duplicate slots 7+0/59; repeated action 8+0/54.
- current_signoff: `.3.2` independent pre/post-use censuses, inventories, six storage oracles, Knowledge Map
  719/5,683, mdBook, five doctrines, 60-line memory, whitespace, and zero runs pass. No canonical rerun was warranted
  after `.3.1.2` canonical because `.3.2` changes audit/docs only and reruns every affected storage oracle.
- latest_bootstrap_read: 2026-07-25 — README, both roadmaps, memory/bootstrap/commit/task doctrines, code/import
  and active semantic owner chain, all 46 mdBook pages, relevant KM/Toolbox/ADRs, and consumer topologies read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: hard lock at 300 new local commits; current counter 35/300 after this commit; never push per commit.
- storage: repository is on the 4-TB SSD. Retain reusable SSD caches. Do not use OS temp/home cache for project
  state; do not delete old exact data until its SSD replacement is verified and used; never delete ambiguous data.
- environment: routed commands self-initialize; source `tools/project_data_env.sh` before lower-level direct commands;
  use `perl -Iperl`; clear `PERL5LIB` for phase0; allow 30m for canonical.
- blockers: none. in_flight_uncommitted: none after commit. next_action: execute `PROJECT-DATA-SSD-ROOTING.4.1`; commit at 36/300; do not push.
