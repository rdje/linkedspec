# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)
LinkedSpec is a progressive-extraction parser DSL. This is the bounded layer-A pointer to *now*, not history.
## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Track under `docs/tasks/`/`docs/TASK_TREE.md`; follow `COMMIT.md`; use `KNOWLEDGE_MAP.md`/`TOOLBOX.md` first;
  require an owning leaf and run `scripts/check_memory_architecture.sh` before commit.
## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.10.9.1.2`; `(this commit)` independently validates the exact MCP contract.
- current_storage_contract: ADR `0053` makes the current repository filesystem authoritative for project-owned
  build/generated output, caches/depots, logs/traces, runtime fixtures, and scratch. Durable paths are root-relative;
  absolute runtime roots derive from the current checkout. Cross-volume reads are denied except explicit caller
  inputs and documented strictly necessary external tool/OS resources. Retained migration is copy/verify/use/delete;
  shared ambiguous caches are populated locally and never deleted wholesale.
- current_storage_inventory: `.5` fresh pre/post-proof censuses find zero LinkedSpec owner in both old temp roots,
  bounded Dart/Julia metadata, or named obsolete paths, so delete zero external paths. Retained Perl 65/17/1,590
  and Julia 346/256/133,963,036 plus 24/15/4,284,303 remain exact; six canonical roots are same-device.
- current_storage_initializer: source `tools/project_data_env.sh`; it derives its checkout, creates ignored
  `/.linkedspec-data/{scratch,cache}`, preserves only same-device destinations, and exports all managed roots.
  Inherited host `TMPDIR` is captured once before routing as runtime-only process-oracle authority, never output.
- current_storage_routing: 40 hook/doctrine/KM/canonical/backend/book/matrix/storage/path boundaries self-root and
  enter one run; targeted Cargo/Dart/Julia/Lua/Python use supported root-relative wrappers.
- current_storage_lifecycle: marker v2 binds each command/descendants to one dedicated process group, waits for
  drain, signals group-wide, rechecks before deletion, and retains live/reused/invalid/indeterminate authority.
- current_storage_perl: `tools/test_perl_project_data_storage.sh` proves all 24 owners, implicit/explicit
  `File::Temp`, explicit trace, real CLI child cwd/cleanup, repository device, and preserved inert path values.
- current_storage_rust: `tools/test_rust_project_data_storage.sh` proves all 17 owners, complete locked offline Cargo
  cache, generated child projects, traces, real copied-binary relocation, same device, and zero old temp residue.
- current_storage_dart: `tools/test_dart_project_data_storage.sh` proves all 18 owners, all 47 locked packages
  offline, local child HOME, generated callers/traces, same device, zero duplicate, and zero shared active roots.
- current_storage_julia: all 17 owners and five package trees use the SSD-local writable depot; offline means
  network-free resolution there. Generated/trace paths are same-device and usage metadata absent. Only the
  interpreter and Julia-managed read-only system depots remain necessary external toolchain inputs.
- current_storage_lua: `tools/test_lua_project_data_storage.sh` proves 16 owners, both ABI module pairs, quoting,
  native/generated/trace use, hostile-output rejection, cleanup, and zero old residue; macOS invokes clang directly.
- current_storage_tools: tool oracle freezes 3 Python temp/13 shell allocator/21 tool owners; bytecode/map/book/
  CLI/TAP/oracle output is same-device, and external/symlink output is pre-rejected.
- current_storage_doctrine: `PROJECT-DATA-STORAGE` governs current tracked storage sinks/defaults and commands;
  28 cases pass. Its process complement locks six required families, hostile inputs, relocation, and kernel denial.
- current_path_contract: ADR `0052` is complete. Structural `REPO-ROOT-PATHS` plus
  `tools/test_repo_root_process_portability.sh` lock root-relative tracked identity, Rust executable-over-cwd moved
  selection/marker failure, and exact Perl/Dart/Julia/Lua named-spec execution from outside the checkout.
- current_semantic_frontier: `.10.9.1.2` is complete from clean machine-contract commit `20741bbd`. A separate
  self-contained validator meta-validates the exact schema profile, reconstructs 28 accepted and seven rejected
  frames, executes 10 raw/10 lifecycle/4 handle/4 policy cases, and rejects 68 mutations across 14 categories
  without importing the materializer or adding a server. No-change `.10.9.1.3` is next; native servers remain `.2-.7`.
- closed_contract_handoff_guard: retain historical next owner `FUTURE-PARITY-BACKLOG.10.1` in bounded memory until
  tracked governance repair `.22` moves the repeated-action checker's immutable handoff to a stable governed home.
- current_closed_semantics: cursor 8+0/60; root 7+0/54; duplicate slots 7+0/59; repeated action 8+0/54.
- current_signoff: `.10.9.1.2` validator/materializer, task/KM 739/5,943/doctrines/book/diff/semantic 6/20/105 at
  7/9 + 6/6, storage 1,689/377,476/28, and tool locality 3/13/21 pass. Canonical passes Perl 18, Rust 1/1 82.63s,
  Dart 1/1, Julia 416/416 29.7s, containment, moved root, primary 66x2, RAM 53%, and Phase 0 1,031/1,031 642s;
  exact 13,208-KiB rendered-book plus one empty-run cleanup passes. No server/native semantic/CLI/rollout/admission behavior moves.
- latest_bootstrap_read: 2026-07-29 — required bootstrap, code owners, all 46 mdBook pages, KM/Toolbox/ADRs read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: hard lock at 300 new local commits; current counter 65/300 after this commit; never push per commit.
- storage: repository is on the 4-TB SSD. Retain reusable SSD caches. Do not use OS temp/home cache for project
  state; do not delete old exact data until its SSD replacement is verified and used; never delete ambiguous data.
- environment: routed commands self-initialize; source `tools/project_data_env.sh` before lower-level direct commands;
  use `perl -Iperl`; clear `PERL5LIB` for phase0; allow 30m for canonical.
- blockers: none. next: activate no-change MCP contract closeout `.10.9.1.3` task-tree-first after clean commit; no push.
