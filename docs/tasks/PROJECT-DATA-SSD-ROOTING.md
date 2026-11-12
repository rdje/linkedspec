# Task Tree — PROJECT-DATA-SSD-ROOTING

## Metadata

- Status: `completed`
- Roadmap lane: `Repository architecture / project-data storage locality`
- Created: `2026-07-26`
- Last updated: `2026-07-27` (`.6` corrects host-temp discovery and recloses the tree at 41/300 without push)
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
7. `.6` corrects the process oracle's host-temp discovery without changing SSD routing or admitting project data
   outside the repository filesystem.

## Activities and Leaves

- ID: `PROJECT-DATA-SSD-ROOTING.0`
  Status: `done` (2026-07-26; ownership, inventory, migration safety, and dependency order frozen)
  Goal: Freeze the complete storage-locality contract and exact migration inventory before changing behavior.
  Acceptance: Classify project-owned versus external/caller/inert data; inventory every tracked reader, writer,
    default, existing LinkedSpec-owned location outside the SSD, and cross-volume dependency; measure relevant
    artifact/cache sizes and source filesystems; prove why each retained external access is strictly necessary;
    identify safe move/copy/delete boundaries; record an ADR and Knowledge Map fact; split every backend/tool/cache/
    enforcement lane below; synchronize roadmap, task index, mdBook, live docs, and memory; pass doctrine/book/
    canonical gates; commit, clear the brief, verify clean, and do not push.
  Commit: `PROJECT-DATA-SSD-ROOTING.0 - freeze SSD storage migration`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.0`.

- ID: `PROJECT-DATA-SSD-ROOTING.1`
  Status: `done` (2026-07-26; environment, routing, and managed-run lifecycle complete)
  Goal: Establish one relocatable SSD-backed project storage contract.
  Depends on: `.0`
  Children: `.1.1`, `.1.2`, `.1.3`

- ID: `PROJECT-DATA-SSD-ROOTING.1.1`
  Status: `done` (2026-07-26; repo-derived storage roots and same-filesystem override validation implemented)
  Goal: Define root-relative scratch and reusable-cache directories plus one shell environment initializer.
  Acceptance: Choose ignored root-relative directories for ephemeral scratch and retained caches; derive absolute
    runtime values only from the current repository root; create directories safely; export standard temporary,
    Cargo, Dart, and Julia environment variables without persisting the SSD mount path; preserve explicit caller
    overrides only when they resolve to the repository filesystem; add focused shell tests and documentation;
    commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.1.1 - define repo-local storage roots`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.1.1`.

- ID: `PROJECT-DATA-SSD-ROOTING.1.2`
  Status: `done` (2026-07-26; 14 standard workflow boundaries route repo-filesystem project data)
  Goal: Route commit hooks, doctrine scripts, canonical CI, and standard backend runners through the initializer.
  Acceptance: Source the helper before any command can allocate temporary or cache data; cover local CI, pre-commit,
    Knowledge Map generation, mdBook verification, and Rust/Dart/Julia/Lua/Perl runner entrypoints; prove commands
    launched from outside the checkout still select the current repo's SSD-backed roots; commit cleanly without
    pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.1.2 - route standard workflows to SSD storage`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.1.2`.

- ID: `PROJECT-DATA-SSD-ROOTING.1.3`
  Status: `done` (2026-07-26; managed-run cleanup, retention, concurrency, and recovery implemented)
  Goal: Define cleanup, retention, concurrency, and interrupted-run behavior for repo-local storage.
  Acceptance: Separate reusable caches from per-run scratch; use collision-safe run directories; clean successful
    scratch while retaining diagnostically useful failed-run state only under an explicit policy; prevent one
    checkout or concurrent process from deleting another's data; document recovery; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.1.3 - harden storage lifecycle`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.1.3`.

- ID: `PROJECT-DATA-SSD-ROOTING.2`
  Status: `done` (2026-07-26; every Perl/Rust/Dart/Julia/Lua/tool migration child is complete)
  Goal: Remove every supported workflow's internal-volume project write.
  Depends on: `.1`
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`, `.2.5`, `.2.6`

- ID: `PROJECT-DATA-SSD-ROOTING.2.1`
  Status: `done` (2026-07-26; Perl allocators/traces/CLI workspaces rooted, 65 old workspaces migrated and deleted)
  Goal: Root Perl tests, CLI conformance, corpus generation, traces, and diagnostic logs on SSD storage.
  Acceptance: Cover `File::Temp`, explicit trace/log files, and tool subprocess workspaces while retaining inert
    path-value fixtures; move any retained Perl-owned data, verify it, and delete its exact old copy in this leaf;
    pass focused Perl suites and both primary CLI matrices; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.1 - root Perl workspaces on SSD`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.2.1`.

- ID: `PROJECT-DATA-SSD-ROOTING.2.2`
  Status: `done` (2026-07-26; Rust Cargo cache, 17 temporary owners, relocation, and full local gate proven on SSD)
  Goal: Root Rust build, Cargo package, test, generated-source, and relocated-oracle data on SSD storage.
  Acceptance: Configure project-local Cargo cache/build roots through runtime-derived environment, retain the
    checked-in target layout contract where required, cover temporary integration fixtures, and prove copied-
    binary relocation without an internal-volume write; verify migrated retained data and delete each exact old
    Rust-owned copy in this leaf; pass Rust local gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.2 - root Rust workspaces on SSD`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.2.2`.

- ID: `PROJECT-DATA-SSD-ROOTING.2.3`
  Status: `done` (2026-07-26; Dart cache, 18 temporary owners, generated/trace paths, and full gate proven on SSD)
  Goal: Root Dart package cache, test workspaces, and generated outputs on SSD storage.
  Acceptance: Configure a repo-derived package cache and temporary root, preserve package resolution and primary
    behavior, verify migrated retained data and delete each exact old Dart-owned copy in this leaf, pass Dart
    package/corpus/CLI gates from inside and outside the checkout; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.3 - root Dart workspaces on SSD`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.2.3`.

- ID: `PROJECT-DATA-SSD-ROOTING.2.4`
  Status: `done` (2026-07-26; Julia depot, scratch, durable commands, metadata hygiene, and exact deletion complete)
  Goal: Root Julia depots, package precompile state, test scratch, and generated outputs on SSD storage.
  Acceptance: Replace operating-system-temp and developer-home depot composition with the repo-derived retained
    depot plus read-only tool/system depots; route `mktempdir` through the SSD temporary root; normalize every
    durable reverify command; verify the migrated project depots and delete their exact old copies in this leaf;
    pass complete Julia and affected semantic gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.4 - root Julia depots and scratch on SSD`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.2.4`.

- ID: `PROJECT-DATA-SSD-ROOTING.2.5`
  Status: `done` (2026-07-26; both Lua ABIs, 13 allocation owners, generated/trace data, and exact residue proven)
  Goal: Root Lua native builds, tests, CLI matrices, and generated artifacts on SSD storage.
  Acceptance: Remove all hard-coded operating-system temporary roots from executable Lua harnesses; use safely
    quoted repo-derived scratch; move any retained Lua-owned data, verify it, and delete its exact old copy in this
    leaf; pass PUC Lua and LuaJIT package/corpus/primary gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.5 - root Lua workspaces on SSD`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.2.5`.

- ID: `PROJECT-DATA-SSD-ROOTING.2.6`
  Status: `done` (2026-07-26; Python, shell, Knowledge Map, mdBook, conformance, TAP, and oracle output rooted)
  Goal: Root Python, shell, mdBook, Knowledge Map, conformance, and miscellaneous tool artifacts on SSD storage.
  Acceptance: Cover Python `tempfile`, shell `mktemp`, explicit log/TAP/oracle outputs, generated book paths, and
    remaining supported writers; do not rewrite inert absolute-path privacy fixtures; move any retained tool-owned
    data, verify it, and delete its exact old copy in this leaf; pass focused tool and book gates; commit cleanly
    without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.2.6 - root tool artifacts on SSD`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.2.6`.

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
  Acceptance: Re-run the frozen census; prove every exact LinkedSpec-owned source was moved, byte/count/hash checked
    where material, exercised from its SSD destination, and then deleted in its owning `.2` leaf; resolve any missed
    exact owner immediately; never move or delete a shared global cache wholesale; record every source/destination/
    deletion class without persisting a concrete mount path; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.3.1.1 - reconcile SSD migration records`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.3.1.1`.

- ID: `PROJECT-DATA-SSD-ROOTING.3.1.2`
  Status: `done` (2026-07-26; marker-v2 process-group lifecycle and recovery proof complete)
  Goal: Make managed-run cleanup and recovery respect live descendants after wrapper/direct-child interruption.
  Acceptance: Retain the exact deterministic RED where a direct child exits after launching a descendant whose cwd
    remains inside managed scratch while the current wrapper deletes that run; bind each run to a portable process-
    group or equivalently complete descendant-liveness authority; forward interruption to the complete owned group;
    prevent normal cleanup, `--recover`, and `--purge-failed` from deleting scratch while any owned descendant is
    live; handle PID/process-group reuse safely; add focused success/failure/signal/orphan/grandchild/concurrency
    tests on the supported host families; update the lifecycle fact and public recovery guidance; pass routing,
    storage, doctrine, book, and warranted canonical gates; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.3.1.2 - guard managed-run descendants`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.3.1.2`.

- ID: `PROJECT-DATA-SSD-ROOTING.3.2`
  Status: `done` (2026-07-26; independent pre/post-use off-repository residue census is zero)
  Goal: Prove no exact LinkedSpec-owned residue remains outside the repository filesystem.
  Acceptance: Delete any final exact disposable or byte-verified migrated LinkedSpec path immediately; leave
    unrelated temporary and shared global tool data untouched; prove the frozen off-SSD census is empty and the SSD
    copies remain usable; report deletion targets, verification, and recoverability; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.3.2 - retire internal-volume project data`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.3.2`.

- ID: `PROJECT-DATA-SSD-ROOTING.4`
  Status: `done` (2026-07-27; structural and relocated process enforcement complete)
  Goal: Mechanically prevent unsupported cross-volume reads and all off-repo-filesystem project writes.
  Depends on: `.3`
  Children: `.4.1`, `.4.2`

- ID: `PROJECT-DATA-SSD-ROOTING.4.1`
  Status: `done` (2026-07-26; structural storage-locality doctrine registered and mutation-sensitive)
  Goal: Add a fast structural doctrine for project storage locality.
  Acceptance: Scan tracked executable/config/documented command owners for forbidden internal-temp, developer-home,
    unrooted cache, and unproved cross-volume defaults while preserving inert caller path fixtures; require every
    external tool/system/caller access to match the frozen explicit necessity surface; self-test every rejected and
    accepted class; register exactly once in doctrine enforcement; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.4.1 - gate project storage locality`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.4.1`.

- ID: `PROJECT-DATA-SSD-ROOTING.4.2`
  Status: `done` (2026-07-27; relocated six-family process containment is mutation-sensitive and canonical)
  Goal: Add process proof that representative workflows keep project IO on the repo filesystem.
  Acceptance: Run representative Perl/Rust/Dart/Julia/Lua/tool probes with hostile external temp/cache variables;
    trace or otherwise enumerate opened project/dependency paths; verify project-owned reads and writes resolve
    beneath the dynamic repo root and share its filesystem; allow only the frozen necessary system/tool/caller
    accesses; prove outside-cwd and relocated-checkout execution; commit cleanly without pushing.
  Commit: `PROJECT-DATA-SSD-ROOTING.4.2 - prove SSD-local project writes`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.4.2`.

- ID: `PROJECT-DATA-SSD-ROOTING.5`
  Status: `done` (2026-07-27; complete backend/parity/census/canonical/public closeout)
  Goal: Close the migration with complete documentation, census, and regression proof.
  Acceptance: Run all backend local gates, five-backend matrices, mdBook, Knowledge Map, doctrines, and canonical
    local CI; prove no exact LinkedSpec-owned data remains on the internal volume; prove all retained project state
    is on the repository filesystem; align ADR/roadmaps/book/live/task/memory; close this tree; resume
    `REPO-ROOT-PATH-PORTABILITY.2.2`; commit, clear the brief, verify clean, and do not push.
  Commit: `PROJECT-DATA-SSD-ROOTING.5 - close SSD storage migration`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.5`.

- ID: `PROJECT-DATA-SSD-ROOTING.6`
  Status: `done` (2026-07-27; exact post-routing host-temp discovery RED corrected and canonical green)
  Goal: Make the relocated process oracle identify host temporary storage independently of routed project scratch.
  Acceptance: Preserve the pre-routing inherited operating-system temporary root through the common initializer as
    invocation-local runtime state; do not persist it or use it for project output. Make the process oracle consume
    only that preserved host root, reject absent/same-device authority, and continue denying host-temp reads and all
    off-repository writes. Add focused mutation-sensitive environment/oracle proof; pass all storage/routing/path/
    doctrine checks and the complete canonical local gate; synchronize the task/index, ADR-aligned Knowledge fact,
    live docs, memory, roadmaps, and mdBook; close the tree; commit, clear the brief, verify clean, and do not push.
  Commit: `PROJECT-DATA-SSD-ROOTING.6 - correct process host-temp discovery`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.32`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.32 --id PROJECT-DATA-SSD-ROOTING.6`.

## Current Frontier

| Leaf | Status | Next action |
| --- | --- | --- |
| — | — | Tree complete; resume semantic closeout `FUTURE-PARITY-BACKLOG.10.7.3.2.1.2` after the clean `.6` commit. |

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
- The initializer captures inherited pre-routing `TMPDIR` once as invocation-local host authority before replacing
  project destinations. Nested managed entrypoints preserve that value. It is never a project output location or
  durable path; the process oracle alone uses it to deny the actual other-filesystem host temporary namespace.
- Thirty-eight standard hook/doctrine/Knowledge Map/canonical/book/backend boundaries route the initializer before a
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
| 2026-07-27 | `.4.2` | relocated six-family kernel containment and deterministic negative controls | PASS: exact caller-input/Dart/Julia/Lua/Perl/Rust/tool set writes five traces plus Python bytecode below the relocated root; external write, shared Cargo read, symlink escape, missing family, denied diagnostic, and `xcrun_db-` controls reject |
| 2026-07-27 | `.4.2` | structural/routing/storage/affected-parity proof | PASS: 28 classifier cases; 38 routes; all six storage oracles; eight affected multi-backend drivers; zero managed runs |
| 2026-07-27 | `.4.2` | Knowledge Map; memory; six doctrines; mdBook; whitespace; complete canonical | PASS: Knowledge Map 721/5,713; Rust 1/1 in 78.09s; Dart 1/1; Julia 416/416 in 27.2s; primary 66x2; nested containment; Phase 0 1,031/1,031 in 620s |
| 2026-07-27 | `.5` | fresh pre-proof runtime-derived census and retained destination inventory | PASS: both off-repository temp roots zero; shared Dart/Julia metadata zero; named obsolete roots absent; zero deletion targets; retained Perl 65/17/1,590 and Julia 346/256/133,963,036 plus 24/15/4,284,303; six canonical roots share repository device; zero runs |
| 2026-07-27 | `.5` | environment/lifecycle/routing, six storage oracles, structural and relocated process enforcement | PASS: marker-v2 lifecycle; 38 routes; Perl 24, Rust 17/195, Dart 18/47, Julia 17/5, Lua 13/dual ABI, tool writers; 28 cases; exact six-family contained process set plus four REDs; zero runs |
| 2026-07-27 | `.5` | complete Rust/Dart/Julia/dual-ABI Lua local gates | PASS: Rust core 193/runtime 149/corpus 105/classifier 105/integration 197/semantic 1 in 78.12s/primary 66x2; Dart 337/primary 66x2/corpus 105; Julia 9,297/primary process/corpus 105; PUC Lua and LuaJIT 177 each, PUC primary 66x2/corpus 105; all storage legs and zero runs pass |
| 2026-07-27 | `.5` | complete maintained supported-variant parity matrix | PASS: primary default/POSIX 660/660; Unicode self-hosted 10/10; diagnostic 10/10; logical 10/10; root 60/60; cursor 50/50; duplicate 10/10; repeated 10/10; punctuation complete across five backends and both Lua ABIs; scalar numeric 55/55 across six runtimes; every native/generated/public/capability/corpus boundary passes |
| 2026-07-27 | `.5` | fresh post-proof runtime-derived census and retained destination inventory | PASS: both off-repository temp roots zero; shared Dart/Julia metadata zero; named obsolete roots absent; zero deletion targets; retained Perl 65/17/1,590 and Julia 346/256/133,963,036 plus 24/15/4,284,303; six canonical roots share repository device; canonical Julia usage metadata absent; zero runs |
| 2026-07-27 | `.5` | complete canonical local CI | PASS: all six doctrines; Rust semantic admission 1/1 in 80.02s; Dart 1/1; Julia 416/416 in 28.3s; Perl primary 66/66 default plus 66/66 POSIX; relocated process containment; Phase 0 1,031/1,031 in 638s; local CI gate passed |
| 2026-07-27 | `.5` | final Knowledge Map, mdBook, doctrines, memory, task metadata, whitespace, and zero-run closeout | PASS: Knowledge Map 722 facts/5,724 question keys; public book rendered to validated repository storage; all six doctrines and current-document gates pass; zero managed runs |
| 2026-07-27 | `.6` | exact host-temp RED plus environment/process mutations | PASS: post-routing `getconf` reproduced managed scratch; one-time pre-routing capture preserves unset/same-device/other-device and nested cases; missing and repository-device authority are rejected |
| 2026-07-27 | `.6` | lifecycle, 39-route, repository-path, six storage, structural, and relocated process proof | PASS: process oracle contains exact Perl/Rust/Dart/Julia/Lua/tool set; 1,659 files / 367,755 lines / 28 storage cases; all six doctrines pass; zero off-repository project write |
| 2026-07-27 | `.6` | complete canonical local CI | PASS: all six doctrines; semantic owners including Rust/Dart/Julia/Lua; Perl primary 66/66 default plus 66/66 POSIX; relocated containment and moved-root proof; Phase 0 1,031/1,031 in 626s; local CI gate passed |

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
| `.4.1` | `ae3b64f2` — `PROJECT-DATA-SSD-ROOTING.4.1 - gate project storage locality` | Structural storage doctrine, 22 classifier cases, nine current-command remediations, six-doctrine registry, and 36-boundary routing. |
| `.4.2` | `8e341068` — `PROJECT-DATA-SSD-ROOTING.4.2 - prove SSD-local project writes` | Relocated six-family kernel containment, targeted Dart HOME, direct macOS clang, 28 structural cases, 38 routes, and canonical proof. |
| `.5` | `PROJECT-DATA-SSD-ROOTING.5 - close SSD storage migration` (this commit) | Fresh zero residue, every backend gate, complete maintained parity, canonical/public proof, and tree closeout. |
| `.6` | `PROJECT-DATA-SSD-ROOTING.6 - correct process host-temp discovery` (this commit) | Pre-routing runtime host authority, mutation-sensitive resolver, focused storage proof, and complete canonical rebuild. |

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
- `2026-07-27`: Completed `.4.2`; a relocated six-family macOS kernel-containment oracle rejects external writes,
  shared-cache reads, symlink escapes, missing probes, and denied diagnostics. Dart uses a repository-local child
  HOME; Lua native builds bypass the stateful Apple `cc` shim. Twenty-eight structural cases, 38 routed boundaries,
  all storage oracles, eight affected parity drivers, and canonical pass; final closeout `.5` becomes active.
- `2026-07-27`: Completed `.5`; fresh pre/post censuses remain zero, retained migration inventories and all six
  same-device canonical roots stay exact, every backend gate and maintained variant matrix passes, and canonical/
  public signoff is green. The storage migration tree closes at 38/300 without push;
  `REPO-ROOT-PATH-PORTABILITY.2.2` is the next action after this clean commit.
- `2026-07-27`: Completed `.6`; the initializer now preserves inherited pre-routing host temp authority before
  SSD routing and nested sources keep it unchanged. The process oracle consumes only that runtime value, rejects
  missing or repository-device substitutions, and no longer asks `getconf` to rediscover authority after routing.
  Focused environment/process/storage proof and complete canonical local CI pass; the tree recloses at 41/300
  without push and semantic closeout `.10.7.3.2.1.2` resumes after the clean commit.
