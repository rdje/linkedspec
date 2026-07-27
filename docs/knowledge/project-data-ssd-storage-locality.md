---
id: project-data-ssd-storage-locality
title: LinkedSpec-owned data stays on the repository filesystem
answers:
  - where must LinkedSpec project data be stored
  - may LinkedSpec use the operating system temporary directory
  - may LinkedSpec write caches outside the repository filesystem
  - where should LinkedSpec Cargo Dart and Julia caches live
  - may supported LinkedSpec workflows read another volume
  - which cross volume accesses are allowed
  - are external compilers interpreters and system libraries project data
  - may caller supplied inputs reside on another volume
  - what happens to old project data after SSD migration
  - should old internal volume copies be deleted after migration
  - how much LinkedSpec data was found on the internal temporary filesystem
  - how many LinkedSpec files allocate through temporary defaults
  - which LinkedSpec global cache records identify the checkout
  - does LinkedSpec move shared global caches wholesale
  - what did PROJECT DATA SSD ROOTING 0 discover
  - has Perl project data been migrated to the SSD
  - do old LinkedSpec CLI workspaces remain on the internal temporary filesystem
  - has Rust project data been migrated to the SSD
  - how many Rust temporary allocation owners exist
  - is the LinkedSpec Cargo cache complete offline
  - has Dart project data been migrated to the SSD
  - how many Dart temporary allocation owners exist
  - is the LinkedSpec Dart package cache complete offline
  - were old Dart checkout cache records deleted
  - has Julia project data been migrated to the SSD
  - how many Julia temporary allocation owners exist
  - is the LinkedSpec Julia package depot complete offline
  - were old Julia temporary depots and checkout metadata deleted
  - has Lua project data been migrated to the SSD
  - how many Lua temporary allocation owners exist
  - were old Lua temporary workspaces deleted
  - has the complete project data migration ledger been reconciled
  - was an obsolete target era Cargo cache deleted
  - is managed run descendant liveness fully enforced
  - did the final off repository project data residue census pass
  - is project data storage locality structurally enforced
date: 2026-07-26
status: current
tags: [architecture, storage, filesystem, ssd, cache, temporary-data, portability, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.0 proves the repository and current OS temporary root are on different filesystems. It finds 65 retained CLI workspaces plus two Julia depots totalling 135,756 KiB, two Dart active-root records identifying current/former checkouts, and one LinkedSpec stanza in a shared Julia usage log. Its tracked scan reported 100 temporary-allocation files and Rust 16; .2.2 corrects the missed imported env::temp_dir spelling to Rust 17 and the initial unique total to 101. Perl .2.1 migrates/verifies/uses/deletes the 65 old CLI directories. Rust .2.2 populates a repo-local 195-package Cargo cache, proves locked offline use plus all 17 owners/relocation on repository storage, and finds zero exact old Rust temp residue. Dart .2.3 atomically moves the complete 47-package cache into its canonical root, proves all 18 owners plus generated/traced use, and deletes the two exact shared active-root records after use. Julia .2.4 supplies a complete five-package source-bearing depot, proves all 17 temporary owners plus generated/trace use, migrates and deletes both exact old depots, deletes the exact former-checkout shared-log stanza, and moves 88 existing current reverify cards onto managed wrappers. Lua .2.5 proves all 13 allocation owners, both ABI-specific native module pairs, generated v2 output, and traces stay on repository storage; it rejects cross-volume native output before creation and finds zero exact old Lua workspace residue. Tool .2.6 completes Python/shell/map/book/TAP/oracle storage. Reconciliation .3.1.1 confirms all frozen off-repository records absent, deletes one missed exact same-SSD target-era root after canonical Cargo identity/use proof, and reruns all six storage oracles. Remediation .3.1.2 closes the discovered marker-v1 descendant gap with marker-v2 process-group authority, group-drain cleanup/signals, conservative automated recovery, and focused normal/orphan proofs. Final proof .3.2 independently finds zero old-root or bounded shared-metadata match before and after all six oracles, deletes zero external paths, and reconfirms the retained Perl/Julia copies. Structural .4.1 registers PROJECT-DATA-STORAGE with 22 classifier cases across current tracked storage/command surfaces; six doctrines, 36 routed boundaries, and all six storage oracles pass. ADR 0053 requires repo-filesystem project state, necessary-only external reads, and copy/verify/use/delete migration."
reverify: "bash scripts/check_project_data_storage_locality.sh && bash scripts/check_doctrines.sh && bash tools/project_data_run.sh --list"
---

ADR `0053` makes the current repository filesystem the authority for all LinkedSpec-owned data. Tracked paths stay
root-relative; supported entrypoints compute absolute scratch/cache paths from the current checkout before any
child process allocates. An inherited temp/cache destination on another filesystem is replaced, not treated as a
convenient override.

The planning census found a real live mismatch. Sixty-five CLI workspaces and two Julia depots remained on the
internal per-user temporary filesystem, occupying 135,756 KiB. The CLI workspaces contained 17 small fixture/trace
files totalling 1,590 bytes; the depots accounted for essentially all retained size. Perl leaf `.2.1` copied those
65 exact directories into repository-relative retained cache, verified directory/file/byte identity plus canonical
hash, exercised a copied source/input fixture, and deleted the internal-volume sources. The two global Dart
active-root records were deleted by `.2.3`. Julia `.2.4` then migrated both exact old depots and deleted their
internal-volume sources plus the exact former-checkout stanza in the shared Julia usage log.

Tracked allocation is broader. The planning scan reported 100 files, including Rust 16; the Rust migration found
one imported `env::temp_dir()` spelling that the original fully-qualified pattern missed. The corrected initial
unique total is 101 and the Rust count is 17. Other family counts remain Perl 24, Dart 18, Julia 17, Lua 13,
Python three, and shell 12; multi-language harnesses overlap. Twenty-four
executable files contain explicit off-repository storage defaults. The initial audit found 97 fact cards with 107
durable old temporary/home-depot command lines; `.2.4` migrates all 88 existing current Julia cards onto supported managed
wrappers. Twenty-six backend test files contain path values
used for privacy or redaction assertions; these are inert data and are not filesystem writers.

Existing shared Cargo, Dart, and Julia caches are not moved or deleted wholesale because other projects may own
entries. LinkedSpec instead populates repo-local caches and stops reading the shared copies. Exact LinkedSpec-owned
metadata, depots, scratch, and logs follow copy/verify/use/delete: verify counts/bytes/hashes where material, run the
workflow against the SSD copy, then delete the old source in the same task leaf. Final closeout independently proves
the off-SSD project census empty.

Reconciliation `.3.1.1` now provides the complete ledger before final enforcement: every frozen off-repository
source and exact shared metadata record is absent, retained migration destinations preserve their recorded counts
and bytes, and every backend/tool storage oracle passes. The audit also found and deleted one exact same-SSD
target-era root after its duplicate Cargo cache matched canonical storage and locked offline use succeeded.
Ambiguous shared caches remain untouched and unused. The marker-version-1 descendant-liveness RED is closed by
`.3.1.2`: marker version 2 records one dedicated process group, waits for group drain, forwards interruption to the
group, and denies automated deletion for live/reused/legacy/mismatched/indeterminate authority.

Perl now has an ongoing executable guard, not only migration history. `tools/test_perl_project_data_storage.sh`
enters managed scratch, exercises default and explicit `File::Temp`, a real LinkedSpec trace file, and the neutral
CLI runner's child cwd, checks repository device identity, requires completed workspace cleanup, inventories all 24
tracked Perl owners, and preserves inert `/tmp` privacy fixtures. The standalone primary matrix is routed too.

Rust now has the same ongoing protection. `tools/run_cargo_local.sh` is the self-rooted targeted Cargo boundary,
and `tools/test_rust_project_data_storage.sh` locks all 17 tracked temporary owners, repository-device Cargo/temp/
target roots, generated child projects, traces, and a real copied-binary run. The repository Cargo home covers all
195 locked registry packages and resolves offline. No exact retained Rust-prefixed workspace exists in the old
temporary roots, so nothing ambiguous was deleted; the shared developer Cargo cache remains untouched and unused.

Dart now has equivalent ongoing protection. `tools/test_dart_project_data_storage.sh` locks all 18 tracked
`Directory.systemTemp` owners, repository-device managed temp/cache/generated/trace paths, all 47 hosted lockfile
packages and hashes, and offline resolution. The complete cache moved atomically from its old same-SSD target-era
location. Only after offline/full-gate use were the two exact shared current/former checkout `active_roots`
records and their empty shards deleted; residue is zero. Ambiguous shared package payload remains untouched and
unused by supported workflows.

Julia now has equivalent ongoing protection. `tools/run_julia_project_data.sh` is the targeted self-rooted command
boundary and `tools/test_julia_project_data_storage.sh` locks all 17 tracked temporary owners, filesystem-local
managed temp/depot/package files, five locked package trees, offline JSON3 resolution, generated v2 source, traces,
and cleanup. Both exact old depots were copied and verified on SSD storage before their sources were deleted; the
exact former-checkout shared-log stanza is gone. The shared developer depot remains untouched and unused. Only
Julia-managed system depots remain as strictly required external read-only runtime dependencies.

Lua now has equivalent ongoing protection. `tools/run_lua_project_data.sh` builds an isolated two-module native
set for the selected PUC Lua or LuaJIT ABI below managed scratch. `tools/test_lua_project_data_storage.sh` locks all
13 allocation owners, actual module/generated/trace devices, non-symlink identity, quoting through a path with a
space, native parsing, and pre-create rejection of an other-filesystem builder destination. Both exact old-root
`linkedspec-lua-*` censuses are zero, so no old Lua payload existed to copy or delete. Required interpreters,
compiler, headers, and libraries remain strictly necessary read-only external inputs.

Final migration proof is independent of those per-family records. It resolves both inherited temporary roots at
runtime, checks their bounded LinkedSpec-identifying namespace and the shared Dart/Julia metadata before and after
all six storage oracles, and finds zero candidates throughout. It therefore deletes zero external paths. The
retained Perl and Julia copies still match their frozen directory/file/byte boundaries, every canonical project
storage root shares the repository device, and the complete run leaves zero managed scratch.

Structural enforcement now makes the policy recurring. `scripts/check_project_data_storage_locality.sh` scans
tracked current code/config/test/tool surfaces, root and book command guidance, and Knowledge `reverify:` commands.
It rejects concrete external project-storage defaults while retaining explicit caller inputs, inert privacy/path
fixtures, rejection-probe reads, and necessary tool/system paths. Twenty-two embedded cases lock the boundary; the
registered doctrine runs through pre-commit and local CI, and the routing oracle covers 36 entrypoints.

Cross-volume reads are denied by default. The narrow exception is an explicit caller path or a strictly required
externally managed executable, system library, device, credential, or OS service. Those are dependencies, not
project storage, and their exact supported surface is documented and gated. Related facts:
[[perl-project-data-ssd-storage]], [[rust-project-data-ssd-storage]], [[dart-project-data-ssd-storage]],
[[julia-project-data-ssd-storage]], [[repository-root-path-portability]], [[rust-local-verification-gate]],
[[lua-project-data-ssd-storage]], [[lua-toolchain-package-policy]], [[project-data-migration-reconciliation]],
[[project-data-descendant-liveness-gap]], [[project-data-final-residue-proof]],
[[project-data-storage-locality-doctrine]].
