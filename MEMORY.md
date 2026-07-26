# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)
LinkedSpec is a progressive-extraction parser DSL. This is the bounded layer-A pointer to *now*, not history.
## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Track under `docs/tasks/`/`docs/TASK_TREE.md`; follow `COMMIT.md`; use `KNOWLEDGE_MAP.md`/`TOOLBOX.md` first;
  require an owning leaf and run `scripts/check_memory_architecture.sh` before commit.
## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `PROJECT-DATA-SSD-ROOTING.2.4` — repo-local Julia depot supplies all five external
  Manifest packages offline; all 17 temporary owners, generated output, traces, and package commands use managed
  SSD storage, and 88 existing current Julia reverify cards use supported self-rooted commands.
- latest_commit: `PROJECT-DATA-SSD-ROOTING.2.4 - root Julia depots and scratch on SSD` (this commit).
- current_storage_contract: ADR `0053` makes the current repository filesystem authoritative for project-owned
  build/generated output, caches/depots, logs/traces, runtime fixtures, and scratch. Durable paths are root-relative;
  absolute runtime roots derive from the current checkout. Cross-volume reads are denied except explicit caller
  inputs and documented strictly necessary external tool/OS resources. Retained migration is copy/verify/use/delete;
  shared ambiguous caches are populated locally and never deleted wholesale.
- current_storage_inventory: the 65 old CLI workspaces are retained only in root-relative SSD cache and old residue
  is zero. Rust cache is 195 compressed + 195 source dirs, 12,741 files/371,604 KiB, hash `a51efb...735b399`;
  exact old Rust temp residue is zero. Dart has 47 locked packages and zero old warmed-cache/shared-record residue.
  Julia's five package trees are 146 files/710,665 bytes/hash `6840ce...906af1`; both old depots and the exact
  former-checkout shared-log record were migrated/deleted. Ambiguous shared caches remain untouched and unused.
- current_storage_initializer: source `tools/project_data_env.sh`; it derives its own checkout and creates ignored
  `/.linkedspec-data/{scratch,cache}`. It preserves only same-device overrides and exports LinkedSpec roots,
  managed-runs root, TMPDIR/TMP/TEMP, Cargo home/target, Dart cache, and local-plus-system Julia depots (no home).
- current_storage_routing: 30 hook/doctrine/KM/canonical/backend/book/matrix/storage boundaries self-root and enter
  one run; targeted Cargo and Julia use `tools/run_cargo_local.sh` and `tools/run_julia_project_data.sh`.
- current_storage_lifecycle: `tools/project_data_run.sh` deletes success/default-failure scratch, retains failure
  only explicitly, never deletes cache, and liveness/marker/checkout-guards list/recover/purge-failed operations.
- current_storage_perl: `tools/test_perl_project_data_storage.sh` proves all 24 owners, implicit/explicit
  `File::Temp`, explicit trace, real CLI child cwd/cleanup, repository device, and preserved inert path values.
- current_storage_rust: `tools/test_rust_project_data_storage.sh` proves all 17 owners, complete locked offline Cargo
  cache, generated child projects, traces, real copied-binary relocation, same device, and zero old temp residue.
- current_storage_dart: `tools/test_dart_project_data_storage.sh` proves all 18 owners, all 47 locked packages
  offline, generated callers/traces, same device, zero old warmed-cache duplicate, and zero shared active roots.
- current_storage_julia: `tools/test_julia_project_data_storage.sh` proves all 17 owners, five package trees, offline
  JSON3, generated v2/trace paths, same device, and no disposable machine-path usage metadata. Exact old residue is
  zero; only Julia-managed system depots remain necessary external read-only inputs.
- current_storage_frontier: `.2.5` is active after `.2.4`: root Lua native builds, tests, matrices, generated
  artifacts, and temporary workspaces; migrate/verify/delete any exact old Lua-owned data and pass both ABIs.
- paused_path_frontier: ADR `0052` relocation remediation `.1.1-.1.3` and structural doctrine `.2.1` are done;
  `REPO-ROOT-PATH-PORTABILITY.2.2` waits behind storage `.5` so its process oracle proves SSD-local IO too.
- paused_semantic_frontier: after storage and relocation close, resume `FUTURE-PARITY-BACKLOG.10.7.3.2.1` from
  clean semantic commit `99a3df5b`; no semantic state changed. Neutral is 6/20/89, rollout 5/9, admission 4/6.
- current_closed_semantics: cursor 8+0/60; root 7+0/54; duplicate slots 7+0/59; repeated action 8+0/54; its
  checker-owned closed next owner remains `FUTURE-PARITY-BACKLOG.10.1`.
- current_signoff: `.2.4` standalone/reused Julia storage, package/semantic suites, primary, corpus 105/105,
  30-boundary routing, doctrines, Knowledge Map 714/5,627, mdBook, and whitespace pass. Canonical: Rust semantic
  admission 1/1 in 77.66s, Dart 1/1, Julia 416/416 in 27.1s, primary 66x2, Phase 0 1,031/1,031 in 625s; exact old
  Julia depot/shared-log residue, disposable usage metadata, and managed runs are zero.
- latest_bootstrap_read: 2026-07-25 — README, both roadmaps, memory/bootstrap/commit/task doctrines, code/import
  and active semantic owner chain, all 46 mdBook pages, relevant KM/Toolbox/ADRs, and consumer topologies read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: hard lock at 300 new local commits; current counter 30/300 after this commit; never push per commit.
- storage: repository is on the 4-TB SSD. Retain reusable SSD caches. Do not use OS temp/home cache for project
  state; do not delete old exact data until its SSD replacement is verified and used; never delete ambiguous data.
- environment: routed commands self-initialize; source `tools/project_data_env.sh` before lower-level direct commands;
  use `perl -Iperl`; clear `PERL5LIB` for phase0; allow 30m for canonical.
- blockers: none. in_flight_uncommitted: none after this commit. next_action: from clean `.2.4`, implement
  `PROJECT-DATA-SSD-ROOTING.2.5`; audit/root Lua project data for both ABIs, commit at 31/300, and do not push.
