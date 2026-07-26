# Task Tree — PROJECT-DATA-SSD-ROOTING

## Metadata

- Status: `active`
- Roadmap lane: `Repository architecture / project-data storage locality`
- Created: `2026-07-26`
- Last updated: `2026-07-26` (`.1.1` initializer implemented and verified; `.1.2` workflow routing active)
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
  Status: `active`
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
  Status: `active`
  Goal: Route commit hooks, doctrine scripts, canonical CI, and standard backend runners through the initializer.
  Depends on: `.1.1`
  Acceptance: Source the helper before any command can allocate temporary or cache data; cover local CI, pre-commit,
    Knowledge Map generation, mdBook verification, and Rust/Dart/Julia/Lua/Perl runner entrypoints; prove commands
    launched from outside the checkout still select the current repo's SSD-backed roots; commit cleanly without
    pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.1.2 - route standard workflows to SSD storage`

- ID: `PROJECT-DATA-SSD-ROOTING.1.3`
  Status: `pending`
  Goal: Define cleanup, retention, concurrency, and interrupted-run behavior for repo-local storage.
  Depends on: `.1.2`
  Acceptance: Separate reusable caches from per-run scratch; use collision-safe run directories; clean successful
    scratch while retaining diagnostically useful failed-run state only under an explicit policy; prevent one
    checkout or concurrent process from deleting another's data; document recovery; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.1.3 - harden storage lifecycle`

- ID: `PROJECT-DATA-SSD-ROOTING.2`
  Status: `pending`
  Goal: Remove every supported workflow's internal-volume project write.
  Depends on: `.1`
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`, `.2.5`, `.2.6`

- ID: `PROJECT-DATA-SSD-ROOTING.2.1`
  Status: `pending`
  Goal: Root Perl tests, CLI conformance, corpus generation, traces, and diagnostic logs on SSD storage.
  Depends on: `.1.3`
  Acceptance: Cover `File::Temp`, explicit trace/log files, and tool subprocess workspaces while retaining inert
    path-value fixtures; move any retained Perl-owned data, verify it, and delete its exact old copy in this leaf;
    pass focused Perl suites and both primary CLI matrices; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.1 - root Perl workspaces on SSD`

- ID: `PROJECT-DATA-SSD-ROOTING.2.2`
  Status: `pending`
  Goal: Root Rust build, Cargo package, test, generated-source, and relocated-oracle data on SSD storage.
  Depends on: `.2.1`
  Acceptance: Configure project-local Cargo cache/build roots through runtime-derived environment, retain the
    checked-in target layout contract where required, cover temporary integration fixtures, and prove copied-
    binary relocation without an internal-volume write; verify migrated retained data and delete each exact old
    Rust-owned copy in this leaf; pass Rust local gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.2 - root Rust workspaces on SSD`

- ID: `PROJECT-DATA-SSD-ROOTING.2.3`
  Status: `pending`
  Goal: Root Dart package cache, test workspaces, and generated outputs on SSD storage.
  Depends on: `.2.2`
  Acceptance: Configure a repo-derived package cache and temporary root, preserve package resolution and primary
    behavior, verify migrated retained data and delete each exact old Dart-owned copy in this leaf, pass Dart
    package/corpus/CLI gates from inside and outside the checkout; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.3 - root Dart workspaces on SSD`

- ID: `PROJECT-DATA-SSD-ROOTING.2.4`
  Status: `pending`
  Goal: Root Julia depots, package precompile state, test scratch, and generated outputs on SSD storage.
  Depends on: `.2.3`
  Acceptance: Replace operating-system-temp and developer-home depot composition with the repo-derived retained
    depot plus read-only tool/system depots; route `mktempdir` through the SSD temporary root; normalize every
    durable reverify command; verify the migrated project depots and delete their exact old copies in this leaf;
    pass complete Julia and affected semantic gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.4 - root Julia depots and scratch on SSD`

- ID: `PROJECT-DATA-SSD-ROOTING.2.5`
  Status: `pending`
  Goal: Root Lua native builds, tests, CLI matrices, and generated artifacts on SSD storage.
  Depends on: `.2.4`
  Acceptance: Remove all hard-coded operating-system temporary roots from executable Lua harnesses; use safely
    quoted repo-derived scratch; move any retained Lua-owned data, verify it, and delete its exact old copy in this
    leaf; pass PUC Lua and LuaJIT package/corpus/primary gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.5 - root Lua workspaces on SSD`

- ID: `PROJECT-DATA-SSD-ROOTING.2.6`
  Status: `pending`
  Goal: Root Python, shell, mdBook, Knowledge Map, conformance, and miscellaneous tool artifacts on SSD storage.
  Depends on: `.2.5`
  Acceptance: Cover Python `tempfile`, shell `mktemp`, explicit log/TAP/oracle outputs, generated book paths, and
    remaining supported writers; do not rewrite inert absolute-path privacy fixtures; move any retained tool-owned
    data, verify it, and delete its exact old copy in this leaf; pass focused tool and book gates; commit cleanly
    without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.6 - root tool artifacts on SSD`

- ID: `PROJECT-DATA-SSD-ROOTING.3`
  Status: `pending`
  Goal: Close the exact existing-data migration with a complete residue audit.
  Depends on: `.2`
  Children: `.3.1`, `.3.2`

- ID: `PROJECT-DATA-SSD-ROOTING.3.1`
  Status: `pending`
  Goal: Reconcile every frozen source against its verified SSD destination and deletion record.
  Depends on: `.2.6`
  Acceptance: Re-run the frozen census; prove every exact LinkedSpec-owned source was moved, byte/count/hash checked
    where material, exercised from its SSD destination, and then deleted in its owning `.2` leaf; resolve any missed
    exact owner immediately; never move or delete a shared global cache wholesale; record every source/destination/
    deletion class without persisting a concrete mount path; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.3.1 - reconcile SSD migration records`

- ID: `PROJECT-DATA-SSD-ROOTING.3.2`
  Status: `pending`
  Goal: Prove no exact LinkedSpec-owned residue remains outside the repository filesystem.
  Depends on: `.3.1`
  Acceptance: Delete any final exact disposable or byte-verified migrated LinkedSpec path immediately; leave
    unrelated temporary and shared global tool data untouched; prove the frozen off-SSD census is empty and the SSD
    copies remain usable; report deletion targets, verification, and recoverability; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.3.2 - retire internal-volume project data`

- ID: `PROJECT-DATA-SSD-ROOTING.4`
  Status: `pending`
  Goal: Mechanically prevent unsupported cross-volume reads and all off-repo-filesystem project writes.
  Depends on: `.3`
  Children: `.4.1`, `.4.2`

- ID: `PROJECT-DATA-SSD-ROOTING.4.1`
  Status: `pending`
  Goal: Add a fast structural doctrine for project storage locality.
  Depends on: `.3.2`
  Acceptance: Scan tracked executable/config/documented command owners for forbidden internal-temp, developer-home,
    unrooted cache, and unproved cross-volume defaults while preserving inert caller path fixtures; require every
    external tool/system/caller access to match the frozen explicit necessity surface; self-test every rejected and
    accepted class; register exactly once in doctrine enforcement; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.4.1 - gate project storage locality`

- ID: `PROJECT-DATA-SSD-ROOTING.4.2`
  Status: `pending`
  Goal: Add process proof that representative workflows keep project IO on the repo filesystem.
  Depends on: `.4.1`
  Acceptance: Run representative Perl/Rust/Dart/Julia/Lua/tool probes with hostile external temp/cache variables;
    trace or otherwise enumerate opened project/dependency paths; verify project-owned reads and writes resolve
    beneath the dynamic repo root and share its filesystem; allow only the frozen necessary system/tool/caller
    accesses; prove outside-cwd and relocated-checkout execution; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.4.2 - prove SSD-local project writes`

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
| `PROJECT-DATA-SSD-ROOTING.1.2` | `active` | From the clean `.1.1` commit, source the initializer in hooks, canonical CI, Knowledge Map/mdBook flows, and standard backend runners; prove outside-cwd selection. |

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
- The default root is `/.linkedspec-data/`: disposable `scratch/`, retained `cache/`, Cargo target at
  `rust/target`, and runtime-derived absolute exports. The leading slash here means repository-root-relative, not
  filesystem-root-absolute.
- Caller overrides are preserved only after the helper proves their resolved directory shares the repository
  device. Julia's trailing empty depot entry admits Julia-managed system depots but omits the developer-home depot.
- The push cadence remains 300 commits. No leaf in this tree pushes independently.

## Links

- Architecture decision: `docs/decisions/0053-project-data-ssd-storage-locality.md`
- Repository relocation decision: `docs/decisions/0052-repository-root-path-portability.md`
- Durable storage-locality fact: `docs/knowledge/project-data-ssd-storage-locality.md`
- Durable initializer fact: `docs/knowledge/project-data-env-initializer.md`
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

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `74138903` — `PROJECT-DATA-SSD-ROOTING.0 - freeze SSD storage migration` | Ownership, exact inventory, migration safety, and implementation order only. |
| `.1.1` | `PROJECT-DATA-SSD-ROOTING.1.1 - define repo-local storage roots` (this commit) | Sourceable root derivation, same-filesystem validation, complete standard exports, and focused hostile-override proof. |

## Changelog

- `2026-07-26`: Opened the task tree after the director required every LinkedSpec-owned datum to move to the SSD.
  The internal temporary filesystem mismatch is reproduced; `.0` owns the complete read-only census and plan.
- `2026-07-26`: Completed `.0` planning: ADR `0053`, exact live/tracked/cache/tool inventories, necessary-only
  cross-volume reads, immediate verified source deletion, and the `.1-.5` migration/enforcement order are frozen.
  `.1.1` becomes the clean implementation frontier after commit.
- `2026-07-26`: Completed `.1.1`; the ignored project-data hierarchy, sourceable environment initializer,
  pre/post-create filesystem checks, temp/Cargo/Dart/Julia exports, same-volume override policy, and focused shell
  proof are implemented. `.1.2` becomes the clean workflow-routing frontier after commit.
