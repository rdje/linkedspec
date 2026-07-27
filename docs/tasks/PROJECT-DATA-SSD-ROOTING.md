# Task Tree — PROJECT-DATA-SSD-ROOTING

## Metadata

- Status: `active`
- Roadmap lane: `Repository architecture / project-data storage locality`
- Created: `2026-07-26`
- Last updated: `2026-07-27` (`.4.2` process proof and enforcement parent `.4` complete; `.5` next after clean commit)
- Owner: repo-local workflow

## Goal

Keep every LinkedSpec-owned durable file, generated artifact, reusable cache, package depot, build output, log, and
temporary workspace on the same SSD-backed filesystem as the movable repository. Supported workflows also avoid
cross-volume reads by default. All persisted path expressions remain relative to the repository root, and all
absolute runtime paths are derived from the current checkout.

External executables, operating-system resources, caller-owned input paths, and inert path-contract fixtures are
not project-owned data. Cross-volume access to them is legal only when explicit, minimal, and backed by a durable
necessity proof; convenience or historical defaults are insufficient. No supported LinkedSpec workflow may create
or mutate project-owned state outside the repository filesystem.

## Director Mandate

- The repository has moved to the 4-TB SSD and disk pressure is no longer a reason to discard reusable caches.
- Project data must no longer be stored on the internal system volume.
- Move every existing LinkedSpec-owned artifact to the SSD, then prevent recurrence mechanically.
- Permit no cross-volume access unless its external-system or caller-authorized role is strictly and provably
  necessary; record and gate the exact exception surface.
- Repository relocation remains critical: tracked paths are root-relative and runtime storage roots are derived
  from the current repository root rather than one concrete mount point.

## Project Data Locality and Same-Volume Storage Policy

All data owned by the project—including generated outputs, build artifacts, caches, package or dependency stores,
logs, runtime-created test fixtures, and temporary workspaces—must reside on the same filesystem volume as the
repository. Persisted paths must be relative to the repository root; tools must derive absolute paths at runtime
from the current root and must never default to `/private/tmp`, `/tmp`, user-home caches, or another off-volume
location. Cross-volume access is forbidden unless it is strictly necessary, explicitly identified, read-only where
possible, and documented with evidence, such as a required operating-system or toolchain dependency or a caller-
authorized input. Existing off-volume project data must follow copy/verify/use/delete: copy or move it to a
repository-derived location on the repository volume; verify file counts, byte sizes, hashes when material, and
successful workflow execution from the new location; then delete the exact old data and run a residue census
proving it is gone. Never delete an ambiguous shared global cache; instead populate a project-local cache, stop
accessing the shared copy, and remove only records or directories provably owned by the project.

## Dependency Order

1. `.0` freezes ownership, inventories all supported read/write paths, existing off-SSD artifacts, and necessary
   cross-volume dependencies, records the architecture decision, and splits implementation before behavior changes.
2. `.1` introduces the single repo-derived storage-root contract and routes supported entrypoints through it.
3. `.2` migrates every backend/tool family and reusable package/build cache, verifies each SSD copy, and deletes
   its exact old LinkedSpec-owned source immediately; unrelated global data remains untouched.
4. `.3` performs the complete post-migration residue audit, resolves any remaining exact owner, and proves every
   verified old LinkedSpec location has been removed.
5. `.4` adds mutation-sensitive structural/process enforcement for SSD locality and repository relocation.
6. `.5` runs the complete backend/canonical matrix, proves the internal-volume census empty, documents the public
   workflow, and closes the tree.

## Activities and Leaves

- ID: `PROJECT-DATA-SSD-ROOTING.0`
  Status: `done` (2026-07-26; ownership, inventory, migration safety, and dependency order frozen)
  Goal: Freeze the complete storage-locality contract and exact migration inventory before changing behavior.
  Depends on: `REPO-ROOT-PATH-PORTABILITY.2.1`
  Acceptance: Classify project-owned versus external/caller/inert data; inventory every tracked reader, writer,
    default, existing LinkedSpec-owned location outside the SSD, and cross-volume dependency; measure relevant
    artifact/cache sizes and source filesystems; prove why each retained external access is strictly necessary;
    identify safe move/copy/delete boundaries; record an ADR and Knowledge Map fact; split every backend/tool/cache/
    enforcement lane below; synchronize roadmap, task index, mdBook, live docs, and memory; pass doctrine/book/
    canonical gates; commit, clear the brief, verify clean, and do not push.
  Commit: `PROJECT-DATA-SSD-ROOTING.0 - freeze SSD storage migration`

  #### Acceptance Checklist

  - [x] **CLEAN PIVOT / TASK FIRST** — Completed `REPO-ROOT-PATH-PORTABILITY.2.1` at clean commit `6edf5c8a`,
    cleared the commit brief, verified 22/300 with no push, then created this task tree before any storage change.
  - [x] **FILESYSTEM RED** — The repository is on the 3.7-TB SSD filesystem while the inherited per-user OS
    temporary root is on the internal root filesystem. All `.0` generators/gates use ignored SSD task scratch.
  - [x] **LIVE DATA INVENTORY** — Froze 65 CLI workspaces plus two Julia depots, 67 directories/135,756 KiB total;
    17 CLI files/1,590 bytes; two exact Dart checkout active-root records; and one LinkedSpec entry inside a shared
    Julia usage log. The former checkout itself is absent.
  - [x] **TRACKED MECHANISM INVENTORY** — Across 1,936 tracked parent files, found 100 temporary-allocation owners:
    Perl 24, Rust 16, Dart 18, Julia 17, Lua 13, Python 3, shell 12 with overlap; 24 executable files carry explicit
    off-repository defaults; 97 Knowledge cards carry 107 old temporary/home-depot lines; 26 path-fixture files are
    inert and separately classified.
  - [x] **CACHE / NECESSITY BOUNDARY** — Measured shared Cargo 845 MB, Dart 78 MB, and Julia 13 MB caches outside
    the SSD plus existing SSD-local Rust target 2.9 GB and Dart tool state 31 MB. Eleven baseline required toolchain
    entrypoints are externally installed on the internal filesystem; they and OS libraries are necessary read-only
    dependencies, while project caches/depot/scratch are not exceptions.
  - [x] **DELETE-OLD CONTRACT** — ADR `0053` requires copy/count-byte-hash verify/use/delete for retained exact
    data, immediate deletion in the owning migration leaf, no duplicate old project data, and an independent empty-
    residue closeout. Shared ambiguous caches stay untouched but cease to be LinkedSpec inputs.
  - [x] **DEPENDENCY-COMPLETE SPLIT** — `.1-.5` own storage initialization/lifecycle, every backend/tool family,
    per-leaf migration deletion, residue reconciliation, structural/process enforcement, and complete closeout.
  - [x] **BEHAVIOR-FREE ALIGNMENT** — `.0` changes only planning/architecture/continuity/public documentation and
    Knowledge facts. Verification may populate ignored SSD-local caches, but no supported runtime, test, tool,
    cache-default, or old-data behavior changes before `.1.1`.

- ID: `PROJECT-DATA-SSD-ROOTING.1`
  Status: `done` (2026-07-26; environment, routing, and managed-run lifecycle complete)
  Goal: Establish one relocatable SSD-backed project storage contract.
  Depends on: `.0`
  Children: `.1.1`, `.1.2`, `.1.3`

- ID: `PROJECT-DATA-SSD-ROOTING.1.1`
  Status: `done` (2026-07-26; repo-derived storage roots and same-filesystem override validation implemented)
  Goal: Define root-relative scratch and reusable-cache directories plus one shell environment initializer.
  Depends on: `.0`
  Acceptance: Choose ignored root-relative directories for ephemeral scratch and retained caches; derive absolute
    runtime values only from the current repository root; create directories safely; export standard temporary,
    Cargo, Dart, and Julia environment variables without persisting the SSD mount path; preserve explicit caller
    overrides only when they resolve to the repository filesystem; add focused shell tests and documentation;
    commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.1.1 - define repo-local storage roots`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — `.0` filesystem census plus `stat` proves inherited OS temp is on another device;
    the frozen tracked inventory names temp/Cargo/Dart/Julia defaults that would keep writing there.
  - [x] **ROOT CAUSE (WHY + WHERE)** — No common pre-command environment owner existed. Standard runtime variables
    inherited caller/OS values, while `tools/run_julia_local.sh:7` and related runners explicitly fell back to
    external temp; `bash tools/test_project_data_env.sh` supplies the same hostile variables as an executable oracle.
  - [x] **FIX** — `tools/project_data_env.sh` derives `BASH_SOURCE` checkout identity, creates ignored
    `/.linkedspec-data/{scratch,cache}`, checks GNU/BSD device identity before and after creation, preserves only
    same-filesystem overrides, and exports LinkedSpec/temp/Cargo/Dart/Julia roots without a mount literal.
  - [x] **ADDRESSED (verified)** — `bash tools/test_project_data_env.sh` passes default creation/ignore/device checks,
    same-volume custom and per-tool overrides, outside-cwd hostile cross-volume replacement, execute-vs-source
    rejection, cleanup, and machine-path source scans.
  - [x] **NO REGRESSION** — `bash -n tools/project_data_env.sh tools/test_project_data_env.sh`, the focused shell
    proof, `bash scripts/check_doctrines.sh`, `mdbook build docs/linkedspec-book`, and `git diff --check` pass.
    The canonical gate passes Rust 1/1 in 83.33s, Dart 1/1, Julia 416/416 in 30.2s, primary 66x2, and Phase 0
    1,031/1,031 in 652s. Existing workflows are not behaviorally routed until `.1.2`.
  - [x] **LOCKSTEP** — README, Toolbox, mdBook, ADR, dedicated Knowledge card, roadmaps, task/live/memory docs are
    synchronized. Standard hooks/runners remain unchanged until their owning `.1.2` leaf.

- ID: `PROJECT-DATA-SSD-ROOTING.1.2`
  Status: `done` (2026-07-26; 14 standard workflow boundaries route repo-filesystem project data)
  Goal: Route commit hooks, doctrine scripts, canonical CI, and standard backend runners through the initializer.
  Depends on: `.1.1`
  Acceptance: Source the helper before any command can allocate temporary or cache data; cover local CI, pre-commit,
    Knowledge Map generation, mdBook verification, and Rust/Dart/Julia/Lua/Perl runner entrypoints; prove commands
    launched from outside the checkout still select the current repo's SSD-backed roots; commit cleanly without
    pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.1.2 - route standard workflows to SSD storage`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — An exact entrypoint scan shows the hook, doctrine/Knowledge Map scripts, canonical
    gate, mdBook command, and four backend runners do not initialize the storage environment themselves; hostile
    inherited temp/cache values therefore remain active unless every caller remembers a manual pre-step.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `.1.1` deliberately introduced only the sourceable mechanism. Supported
    workflow boundaries still start child tools directly, and no routed mdBook wrapper exists; Julia computes its
    old fallback before common initialization while Lua's explicit workspace remains separately `.2.5`-owned.
  - [x] **FIX** — Route `tools/project_data_env.sh` immediately after self-root discovery in every standard shell
    entrypoint, add a generic `KM_ENV_INITIALIZER` bundle hook plus repo config, a routed mdBook wrapper, and one
    focused static/dynamic outside-cwd workflow oracle.
  - [x] **ADDRESSED (verified)** — The workflow oracle rejects missing/late routes, launches Rust/Dart/Julia/Lua
    preflights plus doctrine/Knowledge Map/mdBook from another filesystem with hostile inherited variables, and
    proves every selected root uses the repository device; full canonical independently passes from that cwd.
  - [x] **NO REGRESSION** — Bash syntax, the `.1.1` initializer oracle, the new workflow oracle, direct routed
    doctrine/Knowledge Map/mdBook checks, `bash scripts/check_doctrines.sh`, `git diff --check`, and the complete
    canonical gate pass; canonical is Rust 1/1 77.50s, Dart 1/1, Julia 416/416 27.1s, primary 66x2, Phase 0
    1,031/1,031 662s.
  - [x] **LOCKSTEP** — README, Toolbox, mdBook, ADR, Knowledge Map, roadmaps, task/live/memory docs describe the
    routed standard workflow boundary and preserve `.1.3` lifecycle plus `.2.1-.2.6` migration ownership.

- ID: `PROJECT-DATA-SSD-ROOTING.1.3`
  Status: `done` (2026-07-26; managed-run cleanup, retention, concurrency, and recovery implemented)
  Goal: Define cleanup, retention, concurrency, and interrupted-run behavior for repo-local storage.
  Depends on: `.1.2`
  Acceptance: Separate reusable caches from per-run scratch; use collision-safe run directories; clean successful
    scratch while retaining diagnostically useful failed-run state only under an explicit policy; prevent one
    checkout or concurrent process from deleting another's data; document recovery; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.1.3 - harden storage lifecycle`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — `.1.2` routes all standard commands to one shared `scratch/tmp` root but supplies no
    invocation owner, success/failure policy, collision-proof run namespace, or guarded crash recovery; concurrent
    commands cannot safely delete that shared root.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `tools/project_data_env.sh` establishes filesystem locality, not lifetime.
    Each routed shell file starts independently, nested scripts re-source the helper, and existing EXIT traps make
    trap injection an unsafe generic ownership mechanism.
  - [x] **FIX** — Add `tools/project_data_run.sh`, one persisted path-free checkout id, `mktemp` run leaves with
    exact ownership/liveness markers, one foreground wrapper reused by nested routed commands, default deletion,
    explicit failed-run retention, and separate list/recover/purge-failed operations. Extend the generic Knowledge
    Map integration through `KM_RUN_INITIALIZER` without coupling its portable bundle to LinkedSpec.
  - [x] **ADDRESSED (verified)** — `bash tools/test_project_data_lifecycle.sh` proves success/default-failure cleanup,
    retained-cache survival, explicit failure retention/purge, non-executable shell handoff, two concurrent unique
    live runs, live-child recovery refusal, dead interruption recovery, malformed-marker/namespace-symlink refusal,
    and foreign-checkout isolation. The 14-entrypoint oracle requires environment then managed-run ordering/no residue.
  - [x] **NO REGRESSION** — Bash syntax, initializer/lifecycle/routing oracles, generic Knowledge Map portability,
    routed doctrines/Knowledge Map/mdBook, task/47-line memory, `git diff --check`, and complete canonical pass.
    Canonical is Rust 1/1 82.78s, Dart 1/1, Julia 416/416 30.1s, primary 66x2, Phase 0 1,031/1,031 639s; zero runs
    remain after both a real default-policy failure and the successful full gate.
  - [x] **LOCKSTEP** — README, Toolbox, mdBook, ADR, dedicated Knowledge card, roadmaps, task/live/memory docs define
    exact cleanup/recovery commands and keep `.2.1-.2.6` as the backend/tool migration owners.

- ID: `PROJECT-DATA-SSD-ROOTING.2`
  Status: `done` (2026-07-26; every Perl/Rust/Dart/Julia/Lua/tool migration child is complete)
  Goal: Remove every supported workflow's internal-volume project write.
  Depends on: `.1`
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`, `.2.5`, `.2.6`

- ID: `PROJECT-DATA-SSD-ROOTING.2.1`
  Status: `done` (2026-07-26; Perl allocators/traces/CLI workspaces rooted, 65 old workspaces migrated and deleted)
  Goal: Root Perl tests, CLI conformance, corpus generation, traces, and diagnostic logs on SSD storage.
  Depends on: `.1.3`
  Acceptance: Cover `File::Temp`, explicit trace/log files, and tool subprocess workspaces while retaining inert
    path-value fixtures; move any retained Perl-owned data, verify it, and delete its exact old copy in this leaf;
    pass focused Perl suites and both primary CLI matrices; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.1 - root Perl workspaces on SSD`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — The frozen owner census identifies 24 tracked Perl `File::Temp` users, while the
    internal operating-system temporary root still held 65 `linkedspec-cli-*` workspaces with 17 files/1,590
    bytes. `tools/run_primary_cli_matrix.sh` was also the remaining primary-matrix boundary without self-routing.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Perl `File::Temp` and the CLI/oracle capture owners correctly honor
    initialized `TMPDIR`, but no Perl-specific executable oracle locked that invariant and the standalone five-
    backend primary matrix could allocate before initialization. The 65 directories were interruption remnants
    from the exact `tools/run_cli_conformance.pl` workspace template, not inert path fixtures or shared cache data.
  - [x] **FIX** — The standalone primary matrix now enters the common managed run before any runtime or allocator.
    New `tools/test_perl_project_data_storage.sh` proves default/named `File::Temp`, explicit trace output, and a
    real CLI subprocess workspace share the repository device, clean up exactly, retain the 24-owner inventory,
    and preserve inert `/tmp` privacy/path values. The canonical Perl gate runs the oracle on every invocation.
  - [x] **COPY / VERIFY / USE / DELETE** — Copied all 65 exact manifest-owned directories to ignored root-relative
    `/.linkedspec-data/cache/migrated/perl-cli-workspaces/`; both sides matched 65 directories, 17 files, 1,590
    bytes, and canonical inventory SHA-256 `2a24e96043cf42b0c5e31d6b77064c64b07e36d6506ff9724d2c361f53ce8f49`.
    The copied nested-spec/input fixture executed with exact expected JSON before all 65 old directories were
    deleted; the old census is zero and the verified SSD copy remains recoverable.
  - [x] **FOCUSED REGRESSION** — Bash syntax, outside-cwd Perl storage proof, expanded workflow routing, focused
    runner/trace suites, and both 66-case Perl primary environments pass; completed managed-run census is zero.
  - [x] **SIGNOFF / CLEAN PIVOT** — Doctrines, task/memory/Knowledge Map/mdBook/whitespace, and complete canonical
    Perl gate pass. Canonical records Rust 1/1 in 77.61s, Dart 1/1, Julia 416/416 in 27.2s, primary 66x2, and
    Phase 0 1,031/1,031 in 625s. This commit lands at 27/300; the brief is cleared and no push occurs.

- ID: `PROJECT-DATA-SSD-ROOTING.2.2`
  Status: `done` (2026-07-26; Rust Cargo cache, 17 temporary owners, relocation, and full local gate proven on SSD)
  Goal: Root Rust build, Cargo package, test, generated-source, and relocated-oracle data on SSD storage.
  Depends on: `.2.1`
  Acceptance: Configure project-local Cargo cache/build roots through runtime-derived environment, retain the
    checked-in target layout contract where required, cover temporary integration fixtures, and prove copied-
    binary relocation without an internal-volume write; verify migrated retained data and delete each exact old
    Rust-owned copy in this leaf; pass Rust local gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.2 - root Rust workspaces on SSD`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — The default SSD-local Cargo home initially held only two lock/tag files and a clean
    `cargo fetch --locked --offline` failed at `serde_json`, proving that the 3.6-GiB SSD-local `rust/target` masked
    a missing reusable dependency cache. The internal temporary roots hold no retained Rust-prefixed workspace.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Common workflow routing initializes `TMPDIR`, `CARGO_HOME`, and
    `CARGO_TARGET_DIR`, but no Rust-specific executable oracle proves Cargo cache completeness, all integration
    scratch owners, generated child projects, traces, and copied-binary relocation. The frozen `Rust 16` count also
    missed `rust/linkedspec-core/src/trace.rs` because that unit-test helper imports `env` and calls
    `env::temp_dir()` rather than spelling `std::env::temp_dir()`; the corrected tracked owner count is 17. The
    first routed proof also exposed a synthetic relocation test whose supposed external executable lived beneath
    `std::env::temp_dir()`; after SSD rooting that path is correctly inside the real checkout, so ancestor discovery
    found the real repository. Repository discovery needed a filesystem-predicate seam for topology-only testing.
  - [x] **FIX** — `tools/run_cargo_local.sh` provides a self-rooted managed wrapper for targeted Cargo work.
    `tools/test_rust_project_data_storage.sh` validates repository-device Cargo/temp/target roots, locks all 17
    allocator owners including both `temp_dir` spellings, exercises traces and a generated child project, and runs
    a copied primary binary from managed scratch without an off-volume write. The full Rust gate invokes it.
  - [x] **CACHE / MIGRATION / DELETE** — The ignored repo-relative Cargo home now covers all 195 locked registry
    packages: 195 compressed entries, 195 unpacked source directories, 12,741 files, 371,604 KiB, and canonical
    compressed-cache hash `a51efb284d62287872f6cc2fd113b1f31c6c5c2e5c1e7d1dd5e52de1e735b399`.
    Locked offline fetch and build pass without consulting the shared developer cache. Exact Rust-prefixed residue
    across the inherited OS temporary roots is zero, so there was no unambiguous old Rust-owned source to delete;
    the ambiguous shared Cargo cache remains untouched and is no longer a supported-workflow input.
  - [x] **FOCUSED REGRESSION** — Standalone and full-gate Rust storage proofs, offline dependency resolution,
    generated-source compilation, trace creation, copied-binary relocation, the complete Rust gate, the expanded
    18-boundary outside-cwd routing oracle, the repository-path doctrine, and cleanup proofs pass with zero
    completed managed runs.
  - [x] **SIGNOFF / CLEAN PIVOT** — Doctrines, task/memory/Knowledge Map/mdBook/whitespace, and warranted canonical
    verification pass; this commit lands at 28/300, the brief is cleared, the tree is clean, and no push occurs.

- ID: `PROJECT-DATA-SSD-ROOTING.2.3`
  Status: `done` (2026-07-26; Dart cache, 18 temporary owners, generated/trace paths, and full gate proven on SSD)
  Goal: Root Dart package cache, test workspaces, and generated outputs on SSD storage.
  Depends on: `.2.2`
  Acceptance: Configure a repo-derived package cache and temporary root, preserve package resolution and primary
    behavior, verify migrated retained data and delete each exact old Dart-owned copy in this leaf, pass Dart
    package/corpus/CLI gates from inside and outside the checkout; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.3 - root Dart workspaces on SSD`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Canonical execution with the default repo-local Dart cache passes Rust then fails
    to locate package `test` offline, while a warmed noncanonical SSD cache passes. Read-only census finds 18
    tracked `Directory.systemTemp` owners, an empty canonical Dart cache, a 79,480-KiB warmed SSD cache, a
    79,484-KiB shared off-SSD cache, and exactly two shared `active_roots` records naming the current and absent
    former checkout.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Common routing exports repo-device `TMPDIR` and `PUB_CACHE`, but Dart has no
    executable storage oracle or targeted pub wrapper. The complete package cache was stranded below an earlier
    ignored target-era storage root, the canonical cache was never populated, and Dart's shared cache retained
    checkout-identity metadata. Package payload counts/bytes match; only fetched-at index metadata differs.
  - [x] **FIX** — `tools/test_dart_project_data_storage.sh` locks all 18 temporary owners, validates actual repository-device
    temp/pub/generated/trace paths, proves offline package resolution, and runs inside the complete Dart gate.
    `native_pipeline_trace_test.dart` directly proves `Directory.systemTemp` equals routed `TMPDIR`, while the
    shell oracle checks run/temp/cache device identity, exact package configuration, cleanup, and focused trace/
    generated-source execution. `tools/run_dart_local.sh` invokes the oracle after its complete package tests.
  - [x] **CACHE / MIGRATION / DELETE** — Atomically moved the 79,480-KiB warmed SSD package cache into canonical
    ignored `/.linkedspec-data/cache/dart-pub/`; the old target-era cache path is absent. Shared and SSD caches
    match at 5,903 payload files / 63,744,165 bytes / hash
    `039c5fd8728ea44f23b028ee9400846c353e71a071d46da355b8e1e0d857f29e`; their 47 index files match after removing
    only `_fetchedAt`, normalized hash `21e59ae7c96ad7a94b77f7e854a685d4729c22623486a1acea4ab444777f067b`.
    Offline use and the full gate pass before the two exact current/former shared `active_roots` records and their
    empty hash shards are deleted. Shared active-root residue is zero; ambiguous package payload remains untouched.
  - [x] **FOCUSED REGRESSION** — Standalone/reused Dart storage, 47-package offline pub, 17 focused trace/generated
    tests, complete format/analyzer/337-test package gate, primary 66x2, corpus 105/105, 19-boundary outside-cwd
    routing, and cleanup proofs pass with zero managed runs.
  - [x] **SIGNOFF / CLEAN PIVOT** — Doctrines, task/memory/Knowledge Map/mdBook/whitespace, and warranted canonical
    verification pass; this commit lands at 29/300, the brief is cleared, the tree is clean, and no push occurs.

- ID: `PROJECT-DATA-SSD-ROOTING.2.4`
  Status: `done` (2026-07-26; Julia depot, scratch, durable commands, metadata hygiene, and exact deletion complete)
  Goal: Root Julia depots, package precompile state, test scratch, and generated outputs on SSD storage.
  Depends on: `.2.3`
  Acceptance: Replace operating-system-temp and developer-home depot composition with the repo-derived retained
    depot plus read-only tool/system depots; route `mktempdir` through the SSD temporary root; normalize every
    durable reverify command; verify the migrated project depots and delete their exact old copies in this leaf;
    pass complete Julia and affected semantic gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.4 - root Julia depots and scratch on SSD`

  #### Acceptance Checklist

  - [x] **REPRODUCE / INVENTORY** — Froze 17 tracked Julia `mktempdir`/`tempdir` owners, one empty canonical depot,
    one 103,356-KiB same-SSD source-bearing depot, two exact old internal-volume depots, one exact former-checkout
    stanza in a shared usage log, five external Manifest packages, 88 current Julia reverify cards, and eight
    directly invocable Julia-consuming cross-backend checkers requiring managed routing.
  - [x] **ROOT CAUSE / POLICY** — Julia follows routed `TMPDIR`; a trailing empty `JULIA_DEPOT_PATH` entry expands
    to Julia-managed system depots, not the developer-home depot. Compiled cache alone cannot resolve JSON3 source.
    Therefore the first writable depot must retain package source/registry/precompile state on the repository
    filesystem; only interpreter-managed system depots remain strictly necessary read-only external dependencies.
  - [x] **FIX / RECURRING ORACLE** — Added self-rooted `tools/run_julia_project_data.sh` and a complete-gate storage
    oracle locking 17 owners, actual run/temp/depot/package devices, five exact package trees, no symlinks, offline
    JSON3 loading, `tempdir()` routing, generated v2 source, trace output, cleanup, and absence of machine-path
    usage metadata. Local/primary gates now require the initialized depot, default offline, and have no second
    operating-system-temp or developer-home fallback. Eight cross-backend checkers now self-route before runtime,
    and the already-routed primary matrix no longer carries a duplicate fallback; canonical tracks/syntax-checks
    the new boundaries.
  - [x] **DURABLE COMMAND MIGRATION** — Migrated 88 existing current Julia fact cards; with the new storage card,
    89 current reverify commands now use the targeted wrapper, complete gate, or self-rooted primary checker. No
    current Julia reverify command names a developer depot, concrete Julia executable, or OS-temp depot.
  - [x] **COPY / VERIFY / USE / DELETE** — Atomically promoted the warm source-bearing SSD depot into canonical
    retained cache. Copied both exact old depots to root-relative retained migration storage and verified the larger
    at 346 directories / 256 files / 133,963,036 bytes / hash
    `bddd661bcfb5e43b4cdb4f688d0de68530e8a94ee0b8f1c38ac873c89d8c9ed8` and the query depot at 24 directories /
    15 files / 4,284,303 bytes / hash `aa599da3058fc18240fad33792b0a2d006731abb8c2bc7f2348b78aeb4c3030c`.
    After full offline use, deleted both exact old sources and the one former-checkout shared-log stanza. The shared
    developer depot remains untouched and unused; old exact residue is zero.
  - [x] **FOCUSED / COMPLETE REGRESSION** — Bash syntax, standalone/reused storage proof, complete Julia package
    suite and affected semantic tests, primary process checker, corpus 105/105, and zero-run cleanup pass. The
    30-boundary hostile outside-cwd routing proof also passes with every process reaching its selected runtime
    preflight before work, and completed runs leave no residue.
  - [x] **SIGNOFF / CLEAN PIVOT** — Doctrines, task/memory/Knowledge Map/mdBook/whitespace, and canonical pass.
    Canonical records Rust semantic admission 1/1 in 77.66s, Dart 1/1, Julia 416/416 in 27.1s, primary 66x2,
    and Phase 0 1,031/1,031 in 625s. This commit lands at 30/300; the brief is cleared, the tree is clean, and no
    push occurs.

- ID: `PROJECT-DATA-SSD-ROOTING.2.5`
  Status: `done` (2026-07-26; both Lua ABIs, 13 allocation owners, generated/trace data, and exact residue proven)
  Goal: Root Lua native builds, tests, CLI matrices, and generated artifacts on SSD storage.
  Depends on: `.2.4`
  Acceptance: Remove all hard-coded operating-system temporary roots from executable Lua harnesses; use safely
    quoted repo-derived scratch; move any retained Lua-owned data, verify it, and delete its exact old copy in this
    leaf; pass PUC Lua and LuaJIT package/corpus/primary gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.5 - root Lua workspaces on SSD`

  #### Acceptance Checklist

  - [x] **REPRODUCE / INVENTORY** — Froze 13 executable Lua-family allocation owners, every hard-coded
    operating-system-temporary template/default, anonymous `io.tmpfile()` use, the direct native-build boundary,
    five Lua-specific durable verification commands, and both exact old-root `linkedspec-lua-*` censuses.
  - [x] **ROOT CAUSE / POLICY** — Routed `TMPDIR` governs standard Lua file paths but cannot rewrite hard-coded
    templates or govern C `tmpfile()`. Named managed files replace anonymous storage, and caller-selected native
    output is rejected against the repository device before directory creation. PUC Lua, LuaJIT, the C compiler,
    `pkg-config`, ABI/PCRE2 headers and libraries, and OS libraries remain necessary read-only external inputs.
  - [x] **FIX / RECURRING ORACLE** — Added self-rooted `tools/run_lua_project_data.sh` and
    `tools/test_lua_project_data_storage.sh`; made the native builder self-rooted and pre/post-create guarded; and
    routed both complete ABIs, all 13 owners, generated-source hosts, traces, and corpus capture streams through
    managed repository scratch. The oracle uses a path containing a space, builds and executes two native modules
    per ABI, rejects symlinks/device drift and hostile cross-volume output before creation, and proves cleanup.
  - [x] **DURABLE COMMAND MIGRATION** — Replaced all five Lua-owned current Knowledge Map commands that named the
    old temporary root or hand-built native adapters. The sole remaining composite command is explicitly `.2.6`-
    owned because its non-Lua Python/Rust allocator is the writer requiring migration.
  - [x] **COPY / VERIFY / USE / DELETE** — Both exact frozen old temporary roots contained zero retained
    `linkedspec-lua-*` directories before implementation and after the complete/canonical gates, so no Lua payload
    existed to copy or delete. Unrelated temporary data and installed toolchain resources were untouched.
  - [x] **FOCUSED / COMPLETE REGRESSION** — Bash syntax, standalone/reused storage proof, 33-boundary hostile
    outside-cwd routing, both complete 177/177 PUC Lua and LuaJIT suites, primary 66x2, corpus 105/105, diagnostic,
    logical-helper, root-selection, and cursor/identity/result checks pass with zero managed-run residue.
  - [x] **SIGNOFF / CLEAN PIVOT** — ADR/roadmaps/task/live/memory/Knowledge Map/mdBook are synchronized; doctrines,
    whitespace, and canonical pass. Canonical records Rust semantic admission 1/1 in 77.68s, Dart 1/1, Julia
    416/416 in 27.4s, primary 66x2, and Phase 0 1,031/1,031 in 626s. This commit lands at 31/300; the brief is
    cleared, the tree is clean, and no push occurs.

- ID: `PROJECT-DATA-SSD-ROOTING.2.6`
  Status: `done` (2026-07-26; Python, shell, Knowledge Map, mdBook, conformance, TAP, and oracle output rooted)
  Goal: Root Python, shell, mdBook, Knowledge Map, conformance, and miscellaneous tool artifacts on SSD storage.
  Depends on: `.2.5`
  Acceptance: Cover Python `tempfile`, shell `mktemp`, explicit log/TAP/oracle outputs, generated book paths, and
    remaining supported writers; do not rewrite inert absolute-path privacy fixtures; move any retained tool-owned
    data, verify it, and delete its exact old copy in this leaf; pass focused tool and book gates; commit cleanly
    without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.6 - root tool artifacts on SSD`

  #### Acceptance Checklist

  - [x] **REPRODUCE / INVENTORY** — Froze the three Python temporary-allocation files, 12 actual shell `mktemp`
    owners,
    all 19 Python checker entrypoints and their bytecode behavior, Knowledge Map configured/temporary output,
    mdBook generated output and destination overrides, conformance/TAP/oracle writers, three current off-volume
    reverify commands, one stale Lua temporary-fallback statement, and exact old tool-prefix residue. Recorded the
    accidental `/tmp/linkedspec_2_6_inventory.txt` diagnostic, its immediate exact deletion, and absence proof.
  - [x] **ROOT CAUSE / POLICY** — Proved standard shell allocators were already routed after initialization while
    direct Python `tempfile`, inherited `KM_OUTPUT`, mdBook destination overrides, and Python bytecode could bypass
    that boundary. Preserved explicit caller inputs and inert privacy examples while denying project-owned output on an
    external filesystem even when a caller requests it.
  - [x] **FIX / RECURRING ORACLE** — Added `tools/run_python_project_data.sh`, retained Python bytecode, explicit
    validated Unicode-generator scratch, generic Knowledge Map output validation, mdBook destination validation,
    and `tools/test_tool_project_data_storage.sh`. The oracle locks all three/12/19 owner sets, real devices and
    nonsymlink paths, rejected external/symlink destinations before creation, generated map/book/TAP/bytecode plus
    conformance/oracle paths, cleanup, and outside-cwd use.
  - [x] **DURABLE COMMAND / GUIDANCE MIGRATION** — All 177 maintained command references across 151 current
    documents use the supported Python boundary; current mdBook commands use its wrapper; all three off-volume
    reverify commands, the stale Lua fallback, and generic off-volume Knowledge Map example are removed. Historical
    task/change evidence, inert fixtures, and nested-project records remain classified rather than rewritten.
  - [x] **COPY / VERIFY / USE / DELETE** — The accidental `/tmp/linkedspec_2_6_inventory.txt` was deleted
    immediately and proved absent. The pre-fix census found only the disposable 88-line/4,646-byte Julia audit
    list; metadata, content, hash, and repository-reference checks proved ownership, the exact file was deleted,
    and both frozen old-root censuses are zero. No retained tool payload required copy/hash migration.
  - [x] **FOCUSED / COMPLETE REGRESSION** — Bash/Python syntax, initializer/lifecycle, 35-boundary routing, storage
    oracle, every affected Python contract, Knowledge Map 716/5,653, actual mdBook, conformance/TAP/oracle checks,
    doctrines, whitespace, and zero-run proof pass. Canonical passes Rust 1/1 in 77.49s, Dart 1/1, Julia 416/416 in
    27.0s, primary 66x2, and Phase 0 1,031/1,031 in 624s.
  - [x] **SIGNOFF / CLEAN PIVOT** — ADR/roadmaps/task/live/memory/Knowledge Map/mdBook are synchronized; this commit
    lands at 32/300, clears the brief, leaves a clean exact old-data/run census, and does not push.

- ID: `PROJECT-DATA-SSD-ROOTING.3`
  Status: `done` (2026-07-26; reconciliation, descendant remediation, and empty final residue proof complete)
  Goal: Close the exact existing-data migration with a complete residue audit.
  Depends on: `.2`
  Children: `.3.1`, `.3.2`

- ID: `PROJECT-DATA-SSD-ROOTING.3.1`
  Status: `done` (2026-07-26; source reconciliation and descendant-liveness remediation complete)
  Goal: Reconcile every frozen source and close the descendant-liveness risk exposed by the verification run.
  Depends on: `.2.6`
  Children: `.3.1.1`, `.3.1.2`

- ID: `PROJECT-DATA-SSD-ROOTING.3.1.1`
  Status: `done` (2026-07-26; complete migration ledger, missed target-era root deletion, and descendant-risk split)
  Goal: Reconcile every frozen source against its verified SSD destination and deletion record.
  Depends on: `.2.6`
  Acceptance: Re-run the frozen census; prove every exact LinkedSpec-owned source was moved, byte/count/hash checked
    where material, exercised from its SSD destination, and then deleted in its owning `.2` leaf; resolve any missed
    exact owner immediately; never move or delete a shared global cache wholesale; record every source/destination/
    deletion class without persisting a concrete mount path; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.3.1.1 - reconcile SSD migration records`

  #### Acceptance Checklist

  - [x] **CLEAN PIVOT / TASK FIRST** — Began from clean `.2.6` commit `2c485819` at 32/300 with no push; froze this
    reconciliation checklist before changing any audit record or implementation.
  - [x] **FROZEN-SOURCE LEDGER** — Recovered the complete `.0` census and reconciled every exact project-owned source
    class to one owning `.2` leaf, its repository-derived destination or disposable classification, and its
    recorded count/byte/hash evidence where material.
  - [x] **DESTINATION USE / DELETION LEDGER** — Proved every retained destination was exercised before exact-source
    deletion; disposable sources and shared metadata were owner-classified; ambiguous shared caches remain
    untouched and unused. The missed target-era root was deleted only after canonical cache comparison/use.
  - [x] **INDEPENDENT RE-CENSUS** — Re-ran every frozen exact old-root and shared-metadata census without broad
    deletion or concrete mount paths in durable records. All are zero; the one missed exact same-SSD owner was
    resolved immediately, and `.3.2` inherits a reproducible empty-residue boundary after `.3.1.2`.
  - [x] **SSD DESTINATION HEALTH** — Re-ran the repository-storage initializer/lifecycle and all six backend/tool
    storage oracles needed to show retained caches, fixtures, depots, and writer destinations remain usable on the
    repository filesystem with no managed-run residue.
  - [x] **LOCKSTEP / CLEAN SIGNOFF** — Recorded the reconciled ledger and descendant RED in the task tree,
    ADR/Knowledge layer, roadmaps, live docs, Toolbox, README, and mdBook; memory, Knowledge Map 718/5,675, all five
    doctrines, book, whitespace, exact census, and relevant regression gates pass. This commit lands at 33/300,
    clears the brief, remains clean, and does not push.

  #### Reconciled Migration Ledger

  | Frozen or discovered source class | Retained destination or disposition | Verification before source deletion | Independent `.3.1.1` result |
  | --- | --- | --- | --- |
  | 65 exact Perl CLI workspace directories in the inherited temporary root | `/.linkedspec-data/cache/migrated/perl-cli-workspaces/` | 65 directories, 17 files, 1,590 bytes, canonical hash `2a24e96043cf42b0c5e31d6b77064c64b07e36d6506ff9724d2c361f53ce8f49`, copied nested fixture executed | Destination remains 65/17/1,590; both frozen old-root `linkedspec-*` censuses are zero; Perl 24-owner oracle passes |
  | Shared developer Cargo cache | Left untouched as ambiguous multi-project data; supported workflows use `/.linkedspec-data/cache/cargo-home/` | Canonical root covers 195 compressed packages and 195 sources / 12,741 files; locked offline fetch and Rust gate passed | Shared data remains untouched and unused; canonical locked fetch and 17-owner oracle pass |
  | Missed exact target-era `rust/target/project-data-ssd-rooting/` root | Canonical Cargo cache retained; 13 scratch files disposable | Audit found 12,754 files / 2,376 directories / 371,656 KiB. Its 12,741-file Cargo cache and canonical cache each held 348,574,405 bytes; registry trees were byte-identical and only volatile root-local `.global-cache` content differed; canonical locked fetch passed | Exact old root deleted after no-process proof; it is absent; canonical locked fetch and complete Rust storage oracle pass afterward. Reusable payload remains recoverable from canonical cache; old scratch/identity is intentionally unrecoverable |
  | Warmed Dart target-era cache | Atomically moved to `/.linkedspec-data/cache/dart-pub/` | 5,903 payload files / 63,744,165 bytes / hash `039c5fd8728ea44f23b028ee9400846c353e71a071d46da355b8e1e0d857f29e`; offline/full gate passed | Old target-era root remains absent; canonical 47-package/18-owner oracle passes |
  | Two exact shared Dart checkout records and empty shards | Exact metadata deleted; ambiguous shared package payload untouched | Deleted only after canonical offline/full-gate use | Shared active-root scan has zero LinkedSpec match; shared payload remains untouched and unused |
  | Two exact old Julia depots | `/.linkedspec-data/cache/migrated/julia-depots/` plus canonical source-bearing depot | 346 directories / 256 files / 133,963,036 bytes / hash `bddd661bcfb5e43b4cdb4f688d0de68530e8a94ee0b8f1c38ac873c89d8c9ed8`; 24 directories / 15 files / 4,284,303 bytes / hash `aa599da3058fc18240fad33792b0a2d006731abb8c2bc7f2348b78aeb4c3030c`; offline/full gate passed | Both retained copies still match directory/file/byte counts; exact old roots are absent; five-package/17-owner oracle passes |
  | Exact former-checkout Julia usage-log stanza | Exact stanza deleted; ambiguous shared depot/log data untouched | Ownership classified before deletion; canonical package use passed | Shared usage-log scan has zero LinkedSpec match; shared depot remains untouched and unused |
  | Lua old-root `linkedspec-lua-*` class | No retained payload existed | Initial and post-gate exact censuses zero | Both frozen old-root censuses remain zero; dual-ABI 13-owner oracle passes |
  | Disposable tool audit list and accidental inventory | Exact files deleted after ownership/content classification | Audit list 88 lines / 4,646 bytes / SHA-256 `1d6cd0b5a6661dfc2e71eb43d0ff9ee64b32147735c9ec7b43767c7d4a350dce`; both exact paths absent | Both paths and all old-root `linkedspec-*` entries remain absent; three-Python/12-shell/19-entrypoint tool oracle passes |

- ID: `PROJECT-DATA-SSD-ROOTING.3.1.2`
  Status: `done` (2026-07-26; marker-v2 process-group lifecycle and recovery proof complete)
  Goal: Make managed-run cleanup and recovery respect live descendants after wrapper/direct-child interruption.
  Depends on: `.3.1.1`
  Acceptance: Retain the exact deterministic RED where a direct child exits after launching a descendant whose cwd
    remains inside managed scratch while the current wrapper deletes that run; bind each run to a portable process-
    group or equivalently complete descendant-liveness authority; forward interruption to the complete owned group;
    prevent normal cleanup, `--recover`, and `--purge-failed` from deleting scratch while any owned descendant is
    live; handle PID/process-group reuse safely; add focused success/failure/signal/orphan/grandchild/concurrency
    tests on the supported host families; update the lifecycle fact and public recovery guidance; pass routing,
    storage, doctrine, book, and warranted canonical gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.3.1.2 - guard managed-run descendants`

  #### Acceptance Checklist

  - [x] **CLEAN PIVOT / RED FIRST** — Began from clean `.3.1.1` commit `7efd48b6` at 33/300 with no push; retained the
    exact `descendant_live=yes` / `run_present=no` reproduction before lifecycle implementation changes.
  - [x] **WHOLE-RUN AUTHORITY** — Launch the managed foreground command in one portable dedicated process group,
    persist validated marker-v2 group identity, and preserve nested routed-run reuse without machine paths.
  - [x] **CLEANUP / RECOVERY SAFETY** — Wait for the owned group to drain before ordinary success/default-failure
    cleanup; require group death again immediately before recovery/purge deletion; treat a live or reused group id
    conservatively as nondeletable; reject legacy/invalid markers rather than guessing.
  - [x] **SIGNAL COMPLETENESS** — Forward HUP/INT/TERM to the complete owned group, preserve established exit status,
    and prove direct child plus descendant stop before exact scratch removal.
  - [x] **MUTATION-SENSITIVE PROOF** — Extended `tools/test_project_data_lifecycle.sh` with background-descendant wait,
    abrupt wrapper/direct-child loss, live-group recovery refusal, group drain/recovery, signal forwarding,
    marker-version/group-field rejection, concurrency, cache, namespace, and zero-residue checks.
  - [x] **LOCKSTEP / SIGNOFF** — Updated lifecycle/SSD Knowledge facts, ADR/README/Toolbox/mdBook, roadmaps, task/live/
    memory docs; Bash syntax, focused lifecycle/routing/environment, six storage oracles, all five doctrines,
    Knowledge Map, book, whitespace, and canonical gates pass; this commit lands at 34/300 and does not push.

- ID: `PROJECT-DATA-SSD-ROOTING.3.2`
  Status: `done` (2026-07-26; independent pre/post-use off-repository residue census is zero)
  Goal: Prove no exact LinkedSpec-owned residue remains outside the repository filesystem.
  Depends on: `.3.1`
  Acceptance: Delete any final exact disposable or byte-verified migrated LinkedSpec path immediately; leave
    unrelated temporary and shared global tool data untouched; prove the frozen off-SSD census is empty and the SSD
    copies remain usable; report deletion targets, verification, and recoverability; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.3.2 - retire internal-volume project data`

  #### Acceptance Checklist

  - [x] **CLEAN PIVOT / TASK FIRST** — Began from clean `.3.1.2` commit `f471d5f3` at 34/300 with zero managed runs,
    froze this checklist before census/document changes, and did not push.
  - [x] **INDEPENDENT ROOT CENSUS** — Resolved the inherited system and per-user temporary roots at runtime, proved
    their filesystem relation to the current repository, and independently enumerated exact LinkedSpec-prefixed
    entries without persisting a machine-local mount or checkout path.
  - [x] **EXACT METADATA / OLD-IDENTITY CENSUS** — Rechecked only the bounded shared Dart active-root and Julia usage-
    log metadata surfaces for current/former LinkedSpec identity; proved every named disposable/off-repository and
    superseded same-SSD exact path absent; do not scan-delete or mutate ambiguous shared package payload.
  - [x] **DELETE-OR-ZERO DISPOSITION** — Pre-use and post-use censuses both found zero candidate: `.3.2` has zero
    deletion targets, removes no external path, and leaves all unrelated/shared data untouched.
  - [x] **RETAINED SSD HEALTH** — Recounted the retained Perl and Julia migration copies against their frozen directory/
    file/byte boundaries, exercised their canonical storage paths through the relevant oracles, and proved all six
    backend/tool destinations plus lifecycle leave zero managed-run residue.
  - [x] **LOCKSTEP / CLEAN SIGNOFF** — Added the final-residue Knowledge fact and synchronized ADR/roadmaps/task/live/
    memory/public book; pass census, storage, Knowledge Map, five doctrines, mdBook, memory, and whitespace gates;
    commit at 35/300, clear the brief, remain clean, and do not push.

- ID: `PROJECT-DATA-SSD-ROOTING.4`
  Status: `done` (2026-07-27; structural and relocated process enforcement complete)
  Goal: Mechanically prevent unsupported cross-volume reads and all off-repo-filesystem project writes.
  Depends on: `.3`
  Children: `.4.1`, `.4.2`

- ID: `PROJECT-DATA-SSD-ROOTING.4.1`
  Status: `done` (2026-07-26; structural storage-locality doctrine registered and mutation-sensitive)
  Goal: Add a fast structural doctrine for project storage locality.
  Depends on: `.3.2`
  Acceptance: Scan tracked executable/config/documented command owners for forbidden internal-temp, developer-home,
    unrooted cache, and unproved cross-volume defaults while preserving inert caller path fixtures; require every
    external tool/system/caller access to match the frozen explicit necessity surface; self-test every rejected and
    accepted class; register exactly once in doctrine enforcement; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.4.1 - gate project storage locality`

  #### Acceptance Checklist

  - [x] **CLEAN PIVOT / TASK FIRST** — Began from clean `.3.2` commit `5f603104` at 35/300 with a zero-byte brief and
    zero managed runs; froze this checklist before enforcement-code changes; no push occurred.
  - [x] **STRUCTURAL OWNER INVENTORY** — Derived the tracked executable/config/documented-command surface and
    classified current storage spellings. The direct RED found exactly nine unsafe Toolbox artifact destinations;
    inert fixtures, historical evidence, explicit caller inputs, and necessary tool/system paths remain distinct.
  - [x] **EXACT POLICY CHECK** — Added `scripts/check_project_data_storage_locality.sh`, a self-rooted fast checker
    over tracked code/test/tool/configuration owners, current README/Toolbox/mdBook commands, and Knowledge
    `reverify:` lines. It rejects OS-temp, developer-home, unrooted storage, and concrete checkout defaults while
    accepting repository-derived storage and the frozen explicit necessity classes.
  - [x] **MUTATION-SENSITIVE SELF-TESTS** — Twenty-two embedded reject/accept cases cover every forbidden class,
    persisted checkout identity, caller-owned absolute inputs, inert fixtures, necessary executable/library reads,
    rejection probes, root-relative paths, and runtime-derived storage. The composed `REPO-ROOT-PATHS` doctrine
    continues to reject every persisted current/former machine identity outside this storage-specific sink model.
  - [x] **E3/E4 REGISTRY** — Registered `PROJECT-DATA-STORAGE` exactly once in `scripts/check_doctrines.sh`; the
    existing pre-commit and local-CI paths consume that one driver. Enforcement/Toolbox guidance documents the
    doctrine, and hostile outside-cwd routing now proves 36 standard entrypoints.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronized doctrine/storage/routing facts, ADR/roadmaps/task/live/memory/public
    book. The checker reports 1,651 governed files / 366,343 lines / 22 cases; all six storage oracles, 36-boundary
    routing, six doctrines, Knowledge Map, mdBook, memory, whitespace, and zero-run gates pass. No canonical rerun
    is warranted after `.3.1.2`: this leaf changes only a structural checker/current guidance and reruns every
    affected storage oracle. Commit at 36/300, clear the brief, and do not push.

- ID: `PROJECT-DATA-SSD-ROOTING.4.2`
  Status: `done` (2026-07-27; relocated six-family process containment is mutation-sensitive and canonical)
  Goal: Add process proof that representative workflows keep project IO on the repo filesystem.
  Depends on: `.4.1`
  Acceptance: Run representative Perl/Rust/Dart/Julia/Lua/tool probes with hostile external temp/cache variables;
    trace or otherwise enumerate opened project/dependency paths; verify project-owned reads and writes resolve
    beneath the dynamic repo root and share its filesystem; allow only the frozen necessary system/tool/caller
    accesses; prove outside-cwd and relocated-checkout execution; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.4.2 - prove SSD-local project writes`

  #### Acceptance Checklist

  - [x] **CLEAN PIVOT / TASK FIRST** — Began from clean `.4.1` commit `ae3b64f2` at 36/300 with a zero-byte brief
    and zero managed runs; froze this checklist before process-oracle code; no push occurred.
  - [x] **TRACE AUTHORITY / RED** — `fs_usage` and `dtruss` require root on the current macOS host; the narrower
    non-root normal-terminal authority is `sandbox-exec`. The committed oracle kernel-denies external writes and
    selected implicit project-data reads, and keeps deterministic old-volume-write/shared-cache REDs.
  - [x] **OWNERSHIP / NECESSITY MODEL** — The oracle resolves project paths and filesystem identity, freezes
    external interpreters to system/tool roots, denies developer HOME plus both OS temp roots for data reads, and
    admits only one exact existing read-only caller input. System/runtime reads remain necessary, not project data.
  - [x] **REPRESENTATIVE FIVE-BACKEND + TOOL PROOF** — The relocated driver requires the exact `caller-input dart
    julia lua perl rust tool` set. Five primary commands write nonempty local traces; the Python checker writes local
    bytecode. Hidden Dart HOME telemetry and Apple `cc`-shim `xcrun_db-*` writes were found and removed rather than
    admitted; all eight affected multi-backend parity drivers pass.
  - [x] **OUTSIDE-CWD / RELOCATED PROOF** — A collision-safe checkout view beneath managed SSD scratch receives
    clone-copied Dart/Julia caches and the built Rust primary, then runs from the runtime-derived system-temp cwd on
    another filesystem with hostile inherited temp/cache values. Root discovery replaces every hostile destination,
    project outputs share the relocated root/device, and managed cleanup removes the view.
  - [x] **MUTATION-SENSITIVE REGRESSION** — Retained mutations reject an old-volume output before creation, an
    implicit shared Cargo-cache read, a symlink escape, and a missing tool-family probe. The exact caller input and
    required external executables remain accepted; any denied-access or `xcrun_db-` diagnostic fails the driver.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronized process/storage/Dart/Lua/doctrine/routing facts, ADR/roadmaps/task/
    live/memory/public book. Process oracle, 28-case structure, 38 routing, all six storage oracles, eight affected
    parity drivers, Knowledge Map 721/5,713, six doctrines, mdBook, memory, and whitespace pass. Canonical passes
    Rust semantic admission 1/1 in 78.09s, Dart 1/1, Julia 416/416 in 27.2s, primary 66x2, nested process proof, and
    Phase 0 1,031/1,031 in 620s. Commit at 37/300, clear the brief, and do not push.

- ID: `PROJECT-DATA-SSD-ROOTING.5`
  Status: `pending`
  Goal: Close the migration with complete documentation, census, and regression proof.
  Depends on: `.4`
  Acceptance: Run all backend local gates, five-backend matrices, mdBook, Knowledge Map, doctrines, and canonical
    local CI; prove no exact LinkedSpec-owned data remains on the internal volume; prove all retained project state
    is on the repository filesystem; align ADR/roadmaps/book/live/task/memory; close this tree; resume
    `REPO-ROOT-PATH-PORTABILITY.2.2`; commit, clear the brief, verify clean, and do not push.
  Commit: `PROJECT-DATA-SSD-ROOTING.5 - close SSD storage migration`

## Current Frontier

| Leaf | Status | Next action |
| --- | --- | --- |
| `PROJECT-DATA-SSD-ROOTING.5` | `pending` | After the clean `.4.2` commit, freeze `.5` closeout acceptance and run the complete final matrix/census. |

## Decisions

- The filesystem containing the current repository is the storage authority; no concrete SSD mount path is durable.
- Project-owned state includes build outputs, generated products, logs, TAP/oracle dumps, temporary workspaces,
  package/dependency caches created for LinkedSpec workflows, and retained reproducibility artifacts.
- External tools and operating-system libraries are not project data, but cross-volume reads require an exact,
  durable necessity proof. Shared global caches are not moved wholesale; LinkedSpec gets a repo-local cache
  populated only with the data its supported workflows need.
- Caller-owned paths and inert privacy/path-contract values are data, not write defaults, and remain legal.
- Caller-owned paths grant access only when explicitly supplied for that invocation; they do not create a default
  exception or permit LinkedSpec-owned output on the caller's filesystem.
- Migration deletion requires an exact owner, a verified destination for retained data, and no ambiguity with other
  projects. Ambiguous shared state is copied as needed and left untouched.
- Each exact old LinkedSpec-owned source is deleted in the same leaf that verifies its SSD replacement; deletion is
  not deferred to final closeout. `.3` is an independent reconciliation and empty-residue proof.
- Reusable caches are retained on the SSD; successful per-run scratch is disposable.
- Reconciliation includes superseded same-SSD staging roots, not only the original off-volume census. Retain the
  canonical reusable cache, but delete an exact obsolete duplicate after identity/use proof.
- Wrapper/direct-child PID death is not descendant-liveness proof. Marker v2 now gives normal cleanup and recovery
  dedicated whole-run process-group authority, with live/reused/indeterminate states retained conservatively.
- The default root is `/.linkedspec-data/`: disposable `scratch/`, retained `cache/`, Cargo target at
  `rust/target`, and runtime-derived absolute exports. The leading slash here means repository-root-relative, not
  filesystem-root-absolute.
- Caller overrides are preserved only after the helper proves their resolved directory shares the repository
  device. Julia's trailing empty depot entry admits Julia-managed system depots but omits the developer-home depot.
- Thirty-six standard hook/doctrine/Knowledge Map/canonical/book/backend boundaries route the initializer before a
  runtime or allocator; the Knowledge Map indirection stays portable, direct commands explicit, and migration `.2`.
- Structural storage enforcement governs current executable/configuration owners and maintained commands, while
  cumulative history remains evidence rather than an executable default. Sink/default context—not a bare absolute
  path value—distinguishes forbidden storage from caller input, an inert fixture, or a necessary external read.
- Standard top-level boundaries then share one checkout-namespaced foreground run. Success and default failure
  delete only their validated run leaf after the marker-v2 process group drains; retained failures require explicit
  policy; cache is outside cleanup; recovery skips live/reused/indeterminate/invalid/foreign candidates and
  separates abandoned from retained-failure deletion.
- The push cadence remains 300 commits. No leaf in this tree pushes independently.

## Links

- Architecture decision: `docs/decisions/0053-project-data-ssd-storage-locality.md`
- Repository relocation decision: `docs/decisions/0052-repository-root-path-portability.md`
- Durable storage-locality fact: `docs/knowledge/project-data-ssd-storage-locality.md`
- Durable initializer fact: `docs/knowledge/project-data-env-initializer.md`
- Durable workflow-routing fact: `docs/knowledge/project-data-workflow-routing.md`
- Durable run-lifecycle fact: `docs/knowledge/project-data-run-lifecycle.md`
- Durable Rust storage fact: `docs/knowledge/rust-project-data-ssd-storage.md`
- Durable Dart storage fact: `docs/knowledge/dart-project-data-ssd-storage.md`
- Durable Julia storage fact: `docs/knowledge/julia-project-data-ssd-storage.md`
- Durable Lua storage fact: `docs/knowledge/lua-project-data-ssd-storage.md`
- Durable tool storage fact: `docs/knowledge/tool-project-data-ssd-storage.md`
- Durable migration reconciliation fact: `docs/knowledge/project-data-migration-reconciliation.md`
- Durable descendant-liveness gap fact: `docs/knowledge/project-data-descendant-liveness-gap.md`
- Durable final residue fact: `docs/knowledge/project-data-final-residue-proof.md`
- Durable structural doctrine fact: `docs/knowledge/project-data-storage-locality-doctrine.md`
- Public local-verification guide: `docs/linkedspec-book/src/development/local-ci-and-regression.md`

## Verification Log

| Date | Leaf | Command or evidence | Result |
| --- | --- | --- | --- |
| 2026-07-26 | `.0` | filesystem identity for system temporary root and repository | RED reproduced: system temporary root is on the internal root filesystem; repository is on the 3.7-TB SSD filesystem |
| 2026-07-26 | `.0` | exact live data census | 67 directories / 135,756 KiB; 17 CLI files / 1,590 bytes; 2 Dart active roots; 1 shared-log LinkedSpec stanza |
| 2026-07-26 | `.0` | tracked allocation/default census | 1,936 parent files; temp owners 100; family counts Perl 24/Rust 16/Dart 18/Julia 17/Lua 13/Python 3/shell 12; explicit executable defaults 24; KM 97 cards/107 lines |
| 2026-07-26 | `.0` | cache/tool filesystem census | shared Cargo 845 MB, Dart 78 MB, Julia 13 MB off SSD; Rust target 2.9 GB and Dart tool state 31 MB on SSD; 11 baseline external tool entrypoints on internal filesystem |
| 2026-07-26 | `.0` | five doctrines; memory; Knowledge Map; task metadata; mdBook; whitespace | PASS; memory 40 lines; Knowledge Map 707 facts/5,528 question keys |
| 2026-07-26 | `.0` | canonical gate with SSD-local temp/Cargo/Dart/Julia caches | PASS: Rust 1/1 in 82.41s; Dart 1/1; Julia 416/416 in 29.7s; Perl primary 66x2; Phase 0 1,031/1,031 in 657s |
| 2026-07-26 | `.1.1` | `bash -n tools/project_data_env.sh tools/test_project_data_env.sh`; focused shell test | PASS; ignored default roots, same-volume preservation, hostile cross-volume replacement, outside-cwd discovery, and exact cleanup |
| 2026-07-26 | `.1.1` | five doctrines; memory; Knowledge Map; task metadata; mdBook; whitespace | PASS; memory 44 lines; Knowledge Map 708 facts/5,540 question keys |
| 2026-07-26 | `.1.1` | canonical gate sourced through initializer with warmed same-filesystem SSD caches | PASS: Rust 1/1 in 83.33s; Dart 1/1; Julia 416/416 in 30.2s; Perl primary 66x2; Phase 0 1,031/1,031 in 652s |
| 2026-07-26 | `.1.2` | Bash syntax; initializer oracle; 14-entrypoint workflow oracle from other filesystem; routed mdBook | PASS; hostile external variables replaced; every created project-data root on repository device |
| 2026-07-26 | `.1.2` | Knowledge Map; five doctrines; task metadata; memory; whitespace | PASS; Knowledge Map 709 facts/5,548 question keys; memory 45 lines |
| 2026-07-26 | `.1.2` | canonical gate launched from other-filesystem cwd with retained SSD caches | PASS: Rust 1/1 in 77.50s; Dart 1/1; Julia 416/416 in 27.1s; Perl primary 66x2; Phase 0 1,031/1,031 in 662s |
| 2026-07-26 | `.1.3` | Bash syntax; initializer, lifecycle, and strengthened 14-entrypoint routing oracles | PASS: exact cleanup/retention/cache/concurrency/recovery/checkout isolation; every completed routed run leaves no managed run leaf |
| 2026-07-26 | `.1.3` | generic Knowledge Map override; five doctrines; routed mdBook; task/memory/whitespace | PASS: Knowledge Map 710 facts/5,560 question keys; memory 47 lines; portable bundle stays project-agnostic |
| 2026-07-26 | `.1.3` | first outside-cwd canonical attempt with valid but unpopulated new Cargo cache | Expected environmental failure: sandbox DNS blocks registry refresh at Rust admission; default failure policy cleans the exact run and `--list` reports zero |
| 2026-07-26 | `.1.3` | outside-cwd canonical with retained repository-relative warm caches and Cargo offline | PASS: Rust 1/1 in 82.78s; Dart 1/1; Julia 416/416 in 30.1s; Perl primary 66x2; Phase 0 1,031/1,031 in 639s; zero completed-run residue |
| 2026-07-26 | `.2.1` | Bash syntax; outside-cwd Perl storage oracle; expanded 16-entrypoint routing oracle; focused runner/trace; primary default/POSIX | PASS: 24 `File::Temp` owners, explicit trace, CLI subprocess workspace, inert fixtures, zero completed residue, focused 9 tests, primary 66x2 |
| 2026-07-26 | `.2.1` | exact CLI workspace copy/verify/use/delete | PASS: 65 directories, 17 files, 1,590 bytes, canonical hash `2a24e96043cf42b0c5e31d6b77064c64b07e36d6506ff9724d2c361f53ce8f49`; copied fixture executed; old census zero; SSD copy retained |
| 2026-07-26 | `.2.1` | doctrines; Knowledge Map; task/memory; mdBook; whitespace; complete canonical | PASS: Rust 1/1 in 77.61s; Dart 1/1; Julia 416/416 in 27.2s; primary 66x2; Phase 0 1,031/1,031 in 625s; zero managed runs |
| 2026-07-26 | `.2.2` | repo-relative Cargo cache inventory and locked offline fetch | PASS: 195/195 compressed packages and source directories; 12,741 files / 371,604 KiB; canonical compressed-cache hash `a51efb284d62287872f6cc2fd113b1f31c6c5c2e5c1e7d1dd5e52de1e735b399` |
| 2026-07-26 | `.2.2` | standalone Rust storage oracle; 18-boundary outside-cwd routing; repository-path doctrine | PASS: 17 exact owners, generated child project, traces, actual copied binary, same-device outputs, offline Cargo resolution, zero old Rust temp residue, zero managed runs |
| 2026-07-26 | `.2.2` | complete `tools/run_rust_local.sh` | PASS: core and runtime packages; runtime 149; corpus 105; generated classifier 105; integration 197; semantic admission; storage oracle; primary 66x2 |
| 2026-07-26 | `.2.2` | canonical default-cache attempt, then same-filesystem warmed Dart/Julia override | First attempt passed Rust 1/1 in 77.61s then exposed the still-empty `.2.3`-owned Dart cache and cleaned its run; rerun PASS: Rust 1/1 in 77.85s, Dart 1/1, Julia 416/416 in 27.1s, primary 66x2, Phase 0 1,031/1,031 in 624s; zero runs |
| 2026-07-26 | `.2.3` | Dart cache payload/index comparison and atomic SSD move | PASS: 5,903 payload files / 63,744,165 bytes / hash `039c5fd8728ea44f23b028ee9400846c353e71a071d46da355b8e1e0d857f29e`; 47 normalized index files / hash `21e59ae7c96ad7a94b77f7e854a685d4729c22623486a1acea4ab444777f067b`; old warmed path absent |
| 2026-07-26 | `.2.3` | exact shared Dart metadata deletion | PASS: current and absent-former checkout records classified exactly after canonical offline/full-gate use; two records plus empty hash shards deleted; shared active-root residue zero; shared package payload untouched |
| 2026-07-26 | `.2.3` | standalone storage oracle; 19-boundary routing; complete Dart gate | PASS: 18 exact owners, 47 locked packages/hashes offline, focused 17, format/analyzer, package 337, primary 66x2, corpus 105/105, zero managed runs |
| 2026-07-26 | `.2.3` | canonical default-Dart-cache signoff with same-SSD warmed Julia override | PASS: Rust 1/1 in 77.57s, Dart 1/1 from canonical 47-package cache, Julia 416/416 in 27.1s, primary 66x2, Phase 0 1,031/1,031 in 624s; zero managed runs |
| 2026-07-26 | `.2.4` | Julia package inventory, durable-command migration, standalone/reused storage oracle | PASS: 17 owners; 5 package trees / 146 files / 710,665 bytes / hash `6840ce825c96acd208d308fc58baac1306dcfd64afe1dc4b365f1eccfe906af1`; 88 existing cards migrated / 89 current managed commands; temp/generated/trace/depot paths on repository device; usage metadata absent |
| 2026-07-26 | `.2.4` | exact Julia depot copy/verify/use/delete and shared metadata cleanup | PASS: 346 directories / 256 files / 133,963,036 bytes and 24 directories / 15 files / 4,284,303 bytes copied and hash-matched; canonical offline full gate used; both old sources plus exact former-checkout shared-log stanza deleted; ambiguous shared depot untouched |
| 2026-07-26 | `.2.4` | complete `tools/run_julia_local.sh` | PASS: package and affected semantic suites, 17-owner storage oracle, primary CLI conformance, corpus 105/105, and zero completed-run residue |
| 2026-07-26 | `.2.4` | 30-boundary outside-cwd routing with hostile temp/cache roots | PASS: targeted Julia wrapper/oracle/primary, primary matrix, and all eight Julia-consuming cross-backend checkers self-route and reach their configured runtime preflight before work; zero completed-run residue |
| 2026-07-26 | `.2.4` | doctrines; Knowledge Map; task/memory; mdBook; whitespace; complete canonical | PASS: Knowledge Map 714 facts/5,627 question keys; Rust semantic admission 1/1 in 77.66s; Dart 1/1; Julia 416/416 in 27.1s; primary 66x2; Phase 0 1,031/1,031 in 625s; zero managed runs |
| 2026-07-26 | `.2.5` | Lua inventory, standalone/reused storage oracle, and exact old-root census | PASS: 13 owners; both two-module ABI sets build below a path containing a space; actual devices/non-symlinks/native parse/generated v2/trace/pre-create hostile-output rejection/cleanup proven; both initial and final old-root `linkedspec-lua-*` censuses zero |
| 2026-07-26 | `.2.5` | complete Lua gate and 33-boundary hostile outside-cwd routing | PASS: PUC Lua 177/177; LuaJIT 177/177; primary 66x2; corpus 105/105; diagnostic/logical/root/cursor/identity/result consumers pass; every selected process reaches runtime preflight after routing; zero managed runs |
| 2026-07-26 | `.2.5` | doctrines; Knowledge Map; task/memory; mdBook; whitespace; complete canonical | PASS: Knowledge Map 715 facts/5,640 question keys; Rust semantic admission 1/1 in 77.68s; Dart 1/1; Julia 416/416 in 27.4s; primary 66x2; Phase 0 1,031/1,031 in 626s; zero managed runs |
| 2026-07-26 | `.2.6` | inventory, Python/tool storage oracle, affected Python contracts, 35-boundary outside-cwd routing | PASS: exact 3 Python temp / 12 shell allocator / 19 Python entrypoint inventories; real bytecode/map/book/CLI/TAP/oracle storage; external and symlink outputs rejected before creation; zero managed runs |
| 2026-07-26 | `.2.6` | current command/guidance migration and exact old-root deletion | PASS: 177 current Python-wrapper references across 151 documents; three old-volume reverify commands, stale Lua fallback, generic KM example, and bare current mdBook commands removed; exact 88-line/4,646-byte audit list deleted after classification; both old roots zero |
| 2026-07-26 | `.2.6` | Knowledge Map; doctrines; task/memory; mdBook; whitespace; complete canonical | PASS: Knowledge Map 716 facts/5,653 question keys; Rust semantic admission 1/1 in 77.49s; Dart 1/1; Julia 416/416 in 27.0s; primary 66x2; Phase 0 1,031/1,031 in 624s; zero managed runs |
| 2026-07-26 | `.3.1.1` | frozen source/destination/deletion ledger and independent residue census | PASS: Perl retained 65 directories/17 files/1,590 bytes; Julia retained 346/256/133,963,036 and 24/15/4,284,303; both old temp roots and shared Dart/Julia metadata have zero LinkedSpec match; every named old path absent |
| 2026-07-26 | `.3.1.1` | missed target-era root compare/use/delete/reuse | PASS: 12,754 files/2,376 directories/371,656 KiB; old/canonical Cargo each 12,741 files/348,574,405 bytes with byte-identical registries; locked fetch before deletion; exact root absent; locked fetch and Rust oracle pass after; no process/run residue |
| 2026-07-26 | `.3.1.1` | environment/lifecycle plus six backend/tool destination-health oracles | PASS: Perl 24, Rust 17/195 packages, Dart 18/47 packages, Julia 17/5 package trees, Lua 13/dual ABI, tool 3 Python/12 shell/19 entrypoints; zero managed runs and bounded logs removed |
| 2026-07-26 | `.3.1.1` | descendant-liveness root-cause RED and split | RED retained: real interrupted compiler descendant outlived recorded PIDs; deterministic probe returned `descendant_live=yes`, `run_present=no`; `.3.1.2` owns portable process-group/equivalent remediation before `.3.2` |
| 2026-07-26 | `.3.1.1` | Knowledge Map; five doctrines; memory; task metadata; mdBook; whitespace | PASS: Knowledge Map 718 facts/5,675 question keys; memory 58 lines; public/current docs aligned; no canonical rerun warranted for audit/docs plus verified ignored-cache deletion |
| 2026-07-26 | `.3.1.2` | Bash syntax; lifecycle/environment/35-boundary routing oracles | PASS: marker v2, normal descendant drain, group-wide TERM, abrupt wrapper/direct-child loss, live orphan-group retention, post-drain recovery, legacy/mismatch/indeterminate refusal; all standard workflows route; zero managed runs |
| 2026-07-26 | `.3.1.2` | all six backend/tool storage oracles | PASS: Perl 24, Rust 17/195 packages, Dart 18/47 packages, Julia 17/5 package trees, Lua 13/dual ABI, tool Python/shell/KM/book/TAP/oracle writers; zero managed runs |
| 2026-07-26 | `.3.1.2` | Knowledge Map; memory; doctrines; mdBook; whitespace; complete canonical | PASS: Knowledge Map 718 facts/5,675 question keys; Rust 1/1 in 77.46s; Dart 1/1; Julia 416/416 in 27.1s; primary 66x2; Phase 0 1,031/1,031 in 625s; zero managed runs |
| 2026-07-26 | `.3.2` | pre/post-use runtime-derived old-root and bounded shared-metadata census | PASS: two off-repository temp roots each zero LinkedSpec candidates; Dart active-root and Julia usage metadata zero LinkedSpec files; superseded same-SSD identity absent; zero deletion targets; no shared/unrelated mutation |
| 2026-07-26 | `.3.2` | retained migration and canonical destination inventory | PASS: Perl 65 directories/17 files/1,590 bytes; Julia 346/256/133,963,036 and 24/15/4,284,303; canonical Cargo/Dart/Julia/Python/Rust roots share repository device |
| 2026-07-26 | `.3.2` | all six backend/tool storage oracles and post-use cleanup | PASS: Perl 24, Rust 17/195 packages, Dart 18/47 packages, Julia 17/5 package trees, Lua 13/dual ABI, tool writers; post-use old-root/metadata census remains zero; zero managed runs; captured log removed |
| 2026-07-26 | `.3.2` | Knowledge Map; memory; five doctrines; mdBook; whitespace | PASS: Knowledge Map 719 facts/5,683 question keys; memory 60 lines; all five doctrines; public book; diff whitespace; zero managed runs |
| 2026-07-26 | `.4.1` | structural inventory and direct RED-to-green storage checker | PASS: nine unsafe Toolbox artifact paths migrated; final checker governs 1,651 tracked files / 366,343 lines and passes 22 rejected/accepted classifier cases |
| 2026-07-26 | `.4.1` | six-doctrine registry and hostile outside-cwd workflow routing | PASS: `PROJECT-DATA-STORAGE` registered exactly once through the E3/E4 driver; all six doctrines pass; 36 standard routes initialize repository storage |
| 2026-07-26 | `.4.1` | all six backend/tool storage oracles | PASS: Perl 24, Rust 17/195 packages, Dart 18/47 packages, Julia 17/5 package trees, Lua 13/dual ABI, and tool writers; zero managed runs |
| 2026-07-26 | `.4.1` | Knowledge Map; memory; six doctrines; mdBook; whitespace | PASS: Knowledge Map 720 facts/5,695 question keys; memory 60 lines; no canonical rerun warranted for structural-checker/current-guidance scope after complete `.3.1.2` canonical plus every affected storage oracle |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `74138903` — `PROJECT-DATA-SSD-ROOTING.0 - freeze SSD storage migration` | Ownership, exact inventory, migration safety, and implementation order only. |
| `.1.1` | `e33ed191` — `PROJECT-DATA-SSD-ROOTING.1.1 - define repo-local storage roots` | Sourceable root derivation, same-filesystem validation, complete standard exports, and focused hostile-override proof. |
| `.1.2` | `671592ef` — `PROJECT-DATA-SSD-ROOTING.1.2 - route standard workflows to SSD storage` | Fourteen routed boundaries, mdBook wrapper, hostile outside-cwd oracle, and full canonical proof. |
| `.1.3` | `18c64726` — `PROJECT-DATA-SSD-ROOTING.1.3 - harden storage lifecycle` | Managed foreground runs, exact lifecycle policy, guarded recovery, concurrency/checkout isolation, and focused oracle. |
| `.2.1` | `269b3fbf` — `PROJECT-DATA-SSD-ROOTING.2.1 - root Perl workspaces on SSD` | Perl storage oracle, routed primary matrix, exact 65-directory copy/verify/use/delete, and canonical proof. |
| `.2.2` | `59c15453` — `PROJECT-DATA-SSD-ROOTING.2.2 - root Rust workspaces on SSD` | Complete repo-local Cargo cache, 17-owner storage oracle, generated/trace/relocation proof, and full Rust gate. |
| `.2.3` | `a8a73aa9` — `PROJECT-DATA-SSD-ROOTING.2.3 - root Dart workspaces on SSD` | Canonical 47-package cache, 18-owner storage oracle, exact shared metadata deletion, and full Dart gate. |
| `.2.4` | `ee1bb0c3` — `PROJECT-DATA-SSD-ROOTING.2.4 - root Julia depots and scratch on SSD` | Source-bearing offline depot, 17-owner oracle, 88-card command migration, usage-log hygiene, exact old-data deletion, and full Julia gate. |
| `.2.5` | `7942a5b4` — `PROJECT-DATA-SSD-ROOTING.2.5 - root Lua workspaces on SSD` | Dual-ABI native isolation, 13-owner storage oracle, five-command migration, exact zero old residue, and full Lua/canonical gates. |
| `.2.6` | `2c485819` — `PROJECT-DATA-SSD-ROOTING.2.6 - root tool artifacts on SSD` | Python/tool wrapper and oracle, 35 routed boundaries, validated KM/mdBook/TAP/oracle output, exact old residue deletion, and canonical proof. |
| `.3.1.1` | `7efd48b6` — `PROJECT-DATA-SSD-ROOTING.3.1.1 - reconcile SSD migration records` | Complete ledger, missed target-era root deletion, all storage oracles, and descendant-liveness RED split. |
| `.3.1.2` | `f471d5f3` — `PROJECT-DATA-SSD-ROOTING.3.1.2 - guard managed-run descendants` | Marker-v2 process-group lifecycle, normal/orphan descendant safety, group signals, conservative recovery, and canonical proof. |
| `.3.2` | `5f603104` — `PROJECT-DATA-SSD-ROOTING.3.2 - retire internal-volume project data` | Independent zero residue, zero deletions, exact retained-copy inventory, six destination oracles, and post-use zero proof. |
| `.4.1` | `PROJECT-DATA-SSD-ROOTING.4.1 - gate project storage locality` (this commit) | Structural storage doctrine, 22 classifier cases, nine current-command remediations, six-doctrine registry, and 36-boundary routing. |

## Changelog

- `2026-07-26`: Opened the task tree after the director required every LinkedSpec-owned datum to move to the SSD.
  The internal temporary filesystem mismatch is reproduced; `.0` owns the complete read-only census and plan.
- `2026-07-26`: Completed `.0` planning: ADR `0053`, exact live/tracked/cache/tool inventories, necessary-only
  cross-volume reads, immediate verified source deletion, and the `.1-.5` migration/enforcement order are frozen.
  `.1.1` becomes the clean implementation frontier after commit.
- `2026-07-26`: Completed `.1.1`; the ignored project-data hierarchy, sourceable environment initializer,
  pre/post-create filesystem checks, temp/Cargo/Dart/Julia exports, same-volume override policy, and focused shell
  proof are implemented. `.1.2` becomes the clean workflow-routing frontier after commit.
- `2026-07-26`: Completed `.1.2`; 14 supported workflow boundaries self-initialize the environment, the routed
  mdBook wrapper and outside-cwd oracle pass, and complete canonical proof is green. `.1.3` becomes the clean
  lifecycle/concurrency frontier after commit.
- `2026-07-26`: Completed `.1.3`; standard boundaries reuse checkout-namespaced collision-safe scratch, exact
  success/default-failure cleanup preserves caches, failed retention is explicit, interrupted recovery is
  liveness/marker guarded, and concurrency/checkout isolation is executable. `.2.1` becomes the clean Perl
  migration/deletion frontier after commit.
- `2026-07-26`: Completed `.2.1`; all 24 Perl temporary-allocation owners, explicit trace output, CLI workspaces,
  and the standalone primary matrix are executable under managed SSD storage. The 65 exact old CLI directories
  were copied, count/byte/hash verified, exercised, and deleted; inert path fixtures remain. `.2.2` becomes the
  clean Rust storage/cache migration frontier after commit.
- `2026-07-26`: Completed `.2.2`; the retained Cargo home now resolves all 195 locked registry dependencies
  offline, the exact 17-owner Rust storage oracle proves generated projects, traces, and real copied-binary
  relocation remain on the repository filesystem, and no exact old Rust temp residue exists. The shared developer
  cache remains untouched and unused. `.2.3` becomes the clean Dart storage migration frontier after commit.
- `2026-07-26`: Completed `.2.3`; the verified 47-package Dart cache moved atomically into the canonical retained
  root, all 18 temporary owners plus generated/trace paths are executable under managed SSD storage, and full Dart
  package/primary/corpus proof passes offline. The two exact shared checkout records were deleted after use; shared
  package payload remains untouched and unused. `.2.4` becomes the clean Julia storage migration frontier.
- `2026-07-26`: Completed `.2.4`; the source-bearing five-package Julia depot is canonical, all 17 temporary
  owners plus generated/trace paths are executable under managed SSD storage, 88 durable command cards use the
  self-rooted boundary, and machine-path usage metadata is disposable. Both exact old depots and the former-
  checkout shared-log stanza were deleted after count/byte/hash and full offline-use proof; ambiguous shared depot
  data remains untouched and unused. Thirty-boundary routing and canonical signoff pass; `.2.5` becomes the clean
  Lua storage migration frontier after commit.
- `2026-07-26`: Completed `.2.5`; both PUC Lua and LuaJIT build isolated native modules below managed repository
  scratch, all 13 allocation owners plus generated/trace/corpus paths are routed, five durable commands use the
  supported wrapper/gate, and the exact old Lua workspace census remains zero. The 33-boundary routing proof,
  both 177/177 backend suites, primary 66x2, corpus 105/105, affected cross-backend checks, and canonical signoff
  pass; `.2.6` becomes the clean Python/shell/book/Knowledge Map/conformance/tool storage frontier after commit.
- `2026-07-26`: Completed `.2.6`; all three Python temp owners, 12 shell allocator owners, and 19 Python checker
  entrypoints are frozen behind managed repository storage. Python bytecode, Knowledge Map, mdBook, conformance,
  TAP, and oracle output are same-device validated; hostile external/symlink destinations are rejected before
  creation; current commands use supported wrappers. The one exact disposable old audit list was classified and
  deleted, both frozen old roots are zero, 35-boundary/focused/canonical proof passes, and `.3.1` becomes the clean
  source/destination/deletion reconciliation frontier after commit.
- `2026-07-26`: Split `.3.1` after reconciliation found a lifecycle risk independent of migration records.
  Completed `.3.1.1`: every frozen source is reconciled, all off-repository exact records are absent, one missed
  same-SSD target-era root is verified/deleted, and all destination oracles pass. The deterministic live-descendant
  deletion RED is durable; `.3.1.2` becomes the clean process-liveness remediation frontier before `.3.2`.
- `2026-07-26`: Completed `.3.1.2`; marker version 2 launches the managed command as a dedicated process-group
  leader, waits for group drain, and forwards HUP/INT/TERM group-wide. Recovery/purge double-check live ownership;
  reused groups and interrupted starting state retain conservatively; legacy/malformed/mismatched markers cannot
  authorize deletion. Normal and abrupt-orphan descendant proofs, all six storage oracles, and canonical pass;
  `.3.1` closes and `.3.2` becomes the clean final-residue frontier after commit.
- `2026-07-26`: Completed `.3.2`; fresh pre/post-use censuses find zero LinkedSpec-identifying entry in either
  runtime-derived old temporary root and zero LinkedSpec file in bounded shared Dart/Julia metadata. No deletion
  target exists, so no external/shared path was changed. Retained Perl/Julia copies match frozen counts/bytes,
  every canonical root shares the repository filesystem, and all six storage oracles pass with zero runs. Parent
  `.3` closes; structural doctrine `.4.1` becomes the clean frontier after commit.
- `2026-07-26`: Completed `.4.1`; `PROJECT-DATA-STORAGE` now rejects off-repository storage defaults across current
  executable/configuration owners and maintained commands with 22 mutation-sensitive classifier cases. Nine unsafe
  Toolbox diagnostic paths moved to repository-derived scratch. All six doctrines, 36-boundary outside-cwd routing,
  and every backend/tool storage oracle pass with zero runs; process proof `.4.2` becomes the clean frontier.
