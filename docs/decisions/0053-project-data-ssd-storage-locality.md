# ADR 0053: Project-owned data stays on the repository filesystem

- Date: 2026-07-26
- Status: accepted; migration, final residue proof, and structural/process enforcement complete
- Tags: architecture, storage, filesystem, ssd, caches, temporary-data, portability, doctrine, tooling

## Context

The repository now resides on a 4-TB SSD, but supported workflows still inherit operating-system and language-tool
defaults that place project state elsewhere. The audit at `PROJECT-DATA-SSD-ROOTING.0` reproduced the mismatch:
the current repository and the current per-user temporary root are on different filesystems. Sixty-five retained
CLI workspaces plus two Julia depots occupy 135,756 KiB on the internal temporary filesystem. Two global Dart
active-root records identify the current and former LinkedSpec checkouts, and one shared Julia usage log retains a
former LinkedSpec manifest entry.

The tracked mechanism is broader than those current residues. The planning scan reported 100 files allocating
through default temporary APIs or explicit temporary roots. Rust migration later found that the pattern missed an
imported `env::temp_dir()` spelling; the corrected initial unique total is 101. By language/tool family, the
corrected ownership census reaches 24 Perl, 17 Rust, 18 Dart,
17 Julia, 13 Lua, three Python, and 12 shell files, with some multi-language harnesses counted in more than one
family. Twenty-four executable files contain explicit off-repository storage defaults. Ninety-seven Knowledge Map
fact cards still contain 107 old temporary/home-depot command lines. Inert redaction and path-value fixtures are a
separate class because they do not perform filesystem IO.

External toolchains and operating-system libraries are not project data. The current required Git, Perl, Python,
Rust, Dart, Julia, Lua, LuaJIT, and mdBook entrypoints are installed on the internal filesystem. Reading those
externally managed prerequisites is necessary until the caller supplies equivalents on the repository filesystem;
copying system tools into the repository would neither make them project-owned nor remove their operating-system
library dependency. Package caches, depots, temporary workspaces, logs, generated output, and checkout-identity
metadata are not necessary exceptions: LinkedSpec can own those locally.

ADR `0052` permits explicit caller paths and recognizes temporary directories as a legal filesystem data type. It
does not require project-owned temporary state to use an external temporary filesystem. This record narrows that
boundary for storage locality.

## Decision

1. The filesystem containing the current repository is the authority for all LinkedSpec-owned state. Durable
   path expressions remain relative to the repository root; absolute runtime paths are derived from that root.
2. Project-owned state includes build products, generated outputs, logs, traces, TAP/oracle dumps, temporary test
   workspaces, package/dependency caches populated for LinkedSpec, depots, and retained reproducibility artifacts.
3. Supported entrypoints establish repo-derived scratch and retained-cache roots before any child process or
   language runtime can allocate project state. An inherited temporary/cache variable is accepted only when its
   resolved destination is on the repository filesystem; otherwise LinkedSpec replaces it with the local root.
4. Supported workflows do not read another volume by default. Cross-volume access is allowed only for an explicit
   caller input/configuration or an externally managed executable, system library, device, credential, or OS
   service that the workflow strictly requires. Each default exception is documented and mechanically bounded.
5. Cargo registries, Dart packages, Julia packages/precompile state, and similar dependencies used by supported
   LinkedSpec workflows are populated into repo-local caches. The workflows stop consulting shared global caches.
   Shared caches are not moved or deleted wholesale because their contents may belong to other projects.
6. Migration is copy/verify/use/delete for retained data and delete-after-owner-proof for disposable data. File
   counts, byte sizes, and hashes are checked where material; the SSD-backed replacement is exercised before the
   exact old LinkedSpec-owned source is deleted in the same leaf. No duplicate old project data is retained.
7. Caller-supplied external paths authorize only that invocation's explicit input or output contract. They never
   become a project default, repository locator, cache/depot root, or blanket cross-volume exception.
8. A structural doctrine and representative process oracle enforce storage locality. The process proof uses
   hostile inherited temporary/cache variables, verifies the actual filesystem of project IO, and admits only the
   frozen necessary external-access classes.
9. Standard top-level invocations own one checkout-namespaced collision-safe run directory. Success removes exact
   scratch; failure retains it only through explicit policy. Recovery validates path-free checkout/run ownership,
   refuses live or malformed candidates, and separates abandoned-run cleanup from retained-failure deletion.

## Consequences

- Moving the repository between filesystems moves the project-data authority with it; no concrete SSD mount path is
  stored.
- Reusable caches are retained on the SSD instead of repeatedly deleted for disk pressure.
- Supported local gates become insulated from a developer home, per-user OS temporary location, and shared package
  caches.
- Direct low-level commands that bypass supported entrypoints must first initialize the repo-local environment or
  explicitly supply equivalent repo-filesystem roots.
- The implemented default hierarchy is repository-relative `/.linkedspec-data/`, split into disposable `scratch/`
  and retained `cache/`. `tools/project_data_env.sh` derives its absolute value at runtime and validates device
  identity before and after creating a caller override.
- The pre-commit hook, doctrine and Knowledge Map scripts, canonical Perl gate, Rust/Dart/Julia/Lua local gates,
  and mdBook wrapper source that helper at their self-rooted boundary. Direct lower-level commands remain explicit.
- Those boundaries then enter `tools/project_data_run.sh`: nested routed scripts reuse one foreground run,
  successful/default-failed scratch is deleted, retained `cache/` survives, and explicit recovery never scans
  another checkout namespace or removes a live wrapper/child.
- Perl migration routes the standalone five-backend primary matrix too. A recurring oracle proves all 24 tracked
  Perl temporary-allocation owners still resolve through managed `TMPDIR`, explicit trace logs share the repository
  device, real CLI subprocess workspaces clean up, and inert path/privacy values remain data rather than writers.
- The 65 exact old CLI workspace directories were copied into repository-relative retained cache, verified as 17
  files/1,590 bytes with a canonical inventory hash, exercised through a copied nested source/input fixture, and
  deleted from the internal temporary filesystem. The verified SSD copy remains available; the old census is zero.
- Rust migration adds a self-rooted targeted Cargo wrapper and a recurring storage oracle. The repo-local Cargo
  home covers all 195 locked registry packages offline (195 compressed entries, 195 source directories, 12,741
  files, 371,604 KiB; canonical compressed-cache hash
  `a51efb284d62287872f6cc2fd113b1f31c6c5c2e5c1e7d1dd5e52de1e735b399`). All 17 tracked Rust temporary owners,
  generated projects, traces, and a real copied-binary run stay on the repository device.
- The exact Rust-prefixed residue census is zero in the inherited OS temporary roots. Therefore no unambiguous old
  Rust-owned source existed to delete; the shared developer Cargo cache remains untouched because it is ambiguous
  multi-project data, and supported workflows no longer consult it.
- Dart migration adds a recurring 18-owner storage oracle to the complete Dart gate. The repository cache covers
  all 47 locked hosted packages offline; generated-source callers, traces, `Directory.systemTemp`, `TMPDIR`, and
  `PUB_CACHE` remain on the repository device. Package payload identity is 5,903 files / 63,744,165 bytes with
  hash `039c5fd8728ea44f23b028ee9400846c353e71a071d46da355b8e1e0d857f29e`.
- Process containment found Dartdev reading telemetry configuration beneath developer `HOME` before several
  subcommands honored `PUB_CACHE`. Supported Dart execution now goes through `tools/run_dart_project_data.sh`,
  which gives only Dart a same-device `LINKEDSPEC_DART_HOME` below retained repository cache. Maintained bare Dart
  command surfaces are structurally rejected; parser/CLI behavior and the public usage label are unchanged.
- The warmed Dart cache moved atomically from its old same-SSD target-era location, which no longer exists. After
  successful offline/full-gate use, the two exact current/former checkout `active_roots` records and their empty
  hash shards were deleted from the shared off-SSD cache. Its ambiguous multi-project package payload remains
  untouched and supported workflows no longer consult it.
- Julia migration adds a targeted self-rooted command wrapper and a recurring 17-owner storage oracle. The
  repository depot retains the five external package trees locked by `julia/Manifest.toml` plus the General
  registry, resolves offline, and owns package source/precompile writes while Julia-managed system depots remain
  strictly required read-only runtime dependencies. Managed `tempdir()`/`mktempdir()` data, generated v2 source,
  traces, and every package file share the repository filesystem.
- Both exact old Julia depots were copied into root-relative retained migration storage, independently verified by
  directory/file/byte/hash identity, and deleted from the internal temporary filesystem after the canonical
  offline/full gate passed. The exact former-checkout stanza in the shared developer usage log was deleted;
  ambiguous shared depot data remains untouched and supported workflows no longer consult it.
- Eighty-eight existing current Julia reverify cards now use managed self-rooted boundaries. Supported package commands
  remove the disposable depot `manifest_usage.toml`, which otherwise retains runtime absolute checkout and
  managed-run paths; package sources, registry, and compiled cache remain retained.
- Lua migration adds a self-rooted targeted PUC Lua/LuaJIT wrapper and a recurring 13-owner storage oracle. The
  complete gate and guarded builder place each ABI's PCRE2/filesystem native modules, every test workspace,
  generated v2 source, trace, CLI capture, and corpus capture below managed repository `TMPDIR`. The builder checks
  the nearest existing output ancestor before creation and the resolved directory afterward, so an explicit
  another-filesystem destination is rejected without writing there.
- The exact initial and final old-root census contains zero retained `linkedspec-lua-*` directories, so no exact
  Lua-owned payload existed to migrate or delete. PUC Lua/LuaJIT, `cc`, `pkg-config`, Lua/PCRE2 development files,
  and operating-system libraries remain necessary read-only external toolchain inputs. Supported workflows create
  no LuaRocks or global-module state.
- The first contained Lua native build caught Apple's `/usr/bin/cc` shim attempting an `xcrun_db-*` write beneath
  the per-user OS temporary root. On macOS the default builder now resolves the active developer tree and invokes
  its real `clang` with the active SDK. This keeps compiler/SDK/header/library reads as the documented necessary
  exception while eliminating the hidden tool-selection cache write.
- Tool migration adds a targeted repository-relative Python wrapper, retained `PYTHONPYCACHEPREFIX`, and explicit
  same-device temporary roots for both Unicode generators. Knowledge Map's portable host hook validates configured
  output before use and after writing; mdBook resolves and validates its default, environment, and command-line
  destinations before launch and checks the realized directory afterward.
- The recurring tool oracle freezes three Python temporary owners, 12 shell allocator owners, and 19 Python checker
  entrypoints. It exercises bytecode, generated maps/books, CLI workspaces, TAP, and oracle capture storage on the
  repository device and proves hostile output roots are rejected before creation. The only initial exact old-tool
  residue was one disposable 88-line/4,646-byte Julia audit list; ownership classification preceded exact deletion,
  and the follow-up census of both frozen old roots is zero.
- Independent reconciliation found one missed exact same-SSD owner at root-relative
  `rust/target/project-data-ssd-rooting/`: a target-era 12,741-file Cargo cache plus 13 disposable scratch files.
  The cache matched the canonical root in file count and bytes, its registry tree was byte-identical, and locked
  offline fetch succeeded from the canonical root before deletion. The exact 12,754-file/2,376-directory old root
  was deleted; locked fetch and the full Rust storage oracle pass afterward. All frozen off-repository exact paths
  and shared-metadata matches are now absent, while ambiguous shared caches remain untouched and unused.
- That reconciliation run also proved marker-version-1 liveness was incomplete after abrupt interruption. A
  descendant could outlive both recorded wrapper/direct-child PIDs; an exact RED kept its cwd inside managed
  scratch, let the direct child return, and observed `descendant_live=yes` after the wrapper had deleted the run.
  `PROJECT-DATA-SSD-ROOTING.3.1.2` closes the gap with one dedicated child-led process group and marker version 2.
  Normal cleanup waits for group drain, HUP/INT/TERM target the group, and recovery/purge repeat group liveness
  immediately before deletion. Live or reused groups are retained conservatively; legacy, mismatched, malformed,
  and interrupted `starting` markers cannot authorize automated deletion.
- Final residue proof independently resolves both inherited temporary roots at runtime and checks them before and
  after all six storage oracles. Both roots, the bounded shared Dart/Julia metadata surfaces, and the superseded
  same-SSD target identity are empty. No candidate exists, so the final leaf deletes zero external paths and leaves
  ambiguous shared data untouched. Retained Perl and Julia copies still match their frozen count/byte boundaries.
- Structural enforcement registers `scripts/check_project_data_storage_locality.sh` exactly once as `PROJECT-DATA-
  STORAGE`. It scans tracked current code/config/test/tool and command-guidance surfaces, including Knowledge
  scalar/list-form `reverify:` commands, and runs 28 rejected/accepted classifier cases. It distinguishes off-repository project
  storage defaults from caller inputs, inert path/privacy fixtures, rejection-probe reads, and necessary external
  tools/libraries. The driver, hook/local-CI wiring, 38-boundary routing, and all six storage oracles pass.
- Process enforcement uses macOS `sandbox-exec` because `fs_usage` and `dtruss` require root on the current host.
  It runs a collision-safe relocated checkout view from an outside-filesystem cwd under hostile temp/cache values;
  the kernel denies writes outside that checkout and developer-home/OS-temp data reads except one exact caller
  input. Real Perl, Rust, Dart, Julia, Lua, and Python-tool probes must all emit local traces or bytecode. Retained
  mutations reject an external write, shared-cache read, symlink escape, and incomplete probe set, while any denied
  access or `xcrun_db-` attempt makes the otherwise successful driver fail.
- Final closeout reruns all backend local gates and the complete maintained supported-variant surface. Primary CLI
  behavior is 660/660 across five backends and two option environments; the Unicode self-hosted manifest is 10/10;
  diagnostic, logical, root, cursor, duplicate-slot, repeated-action, punctuation-light, and six-runtime
  scalar/numeric matrices pass. A fresh post-proof census again finds zero old-volume candidate or shared
  Dart/Julia identity, every named obsolete root absent, exact retained Perl/Julia inventories, six same-device
  canonical roots, no Julia usage metadata, and zero managed runs. Canonical local CI passes Phase 0 1,031/1,031.
  Migration, residue retirement, structural/process enforcement, and closeout are complete.
- External compiler/interpreter and system-library reads remain visible necessary dependencies, not hidden storage
  defaults. Installing caller-selected toolchains on the SSD can reduce that exception surface later.
- ADR `0052` remains authoritative for repository identity and explicit caller paths; ADR `0053` supersedes any
  interpretation that project-owned scratch may default to an external temporary filesystem.

## Links

- Task tree: `docs/tasks/PROJECT-DATA-SSD-ROOTING.md`
- Repository relocation: `docs/decisions/0052-repository-root-path-portability.md`
- Managed-run lifecycle: `docs/knowledge/project-data-run-lifecycle.md`
- Rust storage: `docs/knowledge/rust-project-data-ssd-storage.md`
- Dart storage: `docs/knowledge/dart-project-data-ssd-storage.md`
- Julia storage: `docs/knowledge/julia-project-data-ssd-storage.md`
- Lua storage: `docs/knowledge/lua-project-data-ssd-storage.md`
- Tool storage: `docs/knowledge/tool-project-data-ssd-storage.md`
- Process locality: `docs/knowledge/project-data-process-locality-proof.md`
- Final closeout: `docs/knowledge/project-data-ssd-storage-closeout.md`
- Local verification: `docs/linkedspec-book/src/development/local-ci-and-regression.md`
- Doctrine registry: `DOCTRINE_ENFORCEMENT.md`
