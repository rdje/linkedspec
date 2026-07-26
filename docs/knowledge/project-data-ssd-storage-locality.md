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
date: 2026-07-26
status: current
tags: [architecture, storage, filesystem, ssd, cache, temporary-data, portability, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.0 proves the repository and current OS temporary root are on different filesystems. It finds 65 retained CLI workspaces plus two Julia depots totalling 135,756 KiB, two Dart active-root records identifying current/former checkouts, and one LinkedSpec stanza in a shared Julia usage log. Its tracked scan reported 100 temporary-allocation files and Rust 16; PROJECT-DATA-SSD-ROOTING.2.2 corrects the missed imported env::temp_dir spelling to Rust 17 and the initial unique total to 101. Perl .2.1 migrates, verifies, exercises, and deletes the 65 old CLI directories. Rust .2.2 populates a repo-local 195-package Cargo cache, proves locked offline use plus all 17 owners/relocation on repository storage, and finds zero exact old Rust temp residue. ADR 0053 requires repo-filesystem project state, necessary-only external reads, and copy/verify/use/delete migration."
reverify: "git status --short && git ls-files -- . ':(exclude)rgx' | wc -l && rg --no-config -l 'File::Temp|tempdir\\(|tempfile\\(|TemporaryDirectory|NamedTemporaryFile|mktempdir\\(|Directory\\.systemTemp|std::env::temp_dir|tempfile::tempdir|mktemp -d' t tools julia lua dart rust knowledge-map .githooks | wc -l"
---

ADR `0053` makes the current repository filesystem the authority for all LinkedSpec-owned data. Tracked paths stay
root-relative; supported entrypoints compute absolute scratch/cache paths from the current checkout before any
child process allocates. An inherited temp/cache destination on another filesystem is replaced, not treated as a
convenient override.

The planning census found a real live mismatch. Sixty-five CLI workspaces and two Julia depots remained on the
internal per-user temporary filesystem, occupying 135,756 KiB. The CLI workspaces contained 17 small fixture/trace
files totalling 1,590 bytes; the depots accounted for essentially all retained size. Perl leaf `.2.1` copied those
65 exact directories into repository-relative retained cache, verified directory/file/byte identity plus canonical
hash, exercised a copied source/input fixture, and deleted the internal-volume sources. Two global Dart active-root
records and a former LinkedSpec stanza in a shared Julia log remain separately owned by later migration leaves.

Tracked allocation is broader. The planning scan reported 100 files, including Rust 16; the Rust migration found
one imported `env::temp_dir()` spelling that the original fully-qualified pattern missed. The corrected initial
unique total is 101 and the Rust count is 17. Other family counts remain Perl 24, Dart 18, Julia 17, Lua 13,
Python three, and shell 12; multi-language harnesses overlap. Twenty-four
executable files contain explicit off-repository storage defaults. Ninety-seven fact cards contain 107 durable
commands that still select old temporary/home depot composition. Twenty-six backend test files contain path values
used for privacy or redaction assertions; these are inert data and are not filesystem writers.

Existing shared Cargo, Dart, and Julia caches are not moved or deleted wholesale because other projects may own
entries. LinkedSpec instead populates repo-local caches and stops reading the shared copies. Exact LinkedSpec-owned
metadata, depots, scratch, and logs follow copy/verify/use/delete: verify counts/bytes/hashes where material, run the
workflow against the SSD copy, then delete the old source in the same task leaf. Final closeout independently proves
the off-SSD project census empty.

Perl now has an ongoing executable guard, not only migration history. `tools/test_perl_project_data_storage.sh`
enters managed scratch, exercises default and explicit `File::Temp`, a real LinkedSpec trace file, and the neutral
CLI runner's child cwd, checks repository device identity, requires completed workspace cleanup, inventories all 24
tracked Perl owners, and preserves inert `/tmp` privacy fixtures. The standalone primary matrix is routed too.

Rust now has the same ongoing protection. `tools/run_cargo_local.sh` is the self-rooted targeted Cargo boundary,
and `tools/test_rust_project_data_storage.sh` locks all 17 tracked temporary owners, repository-device Cargo/temp/
target roots, generated child projects, traces, and a real copied-binary run. The repository Cargo home covers all
195 locked registry packages and resolves offline. No exact retained Rust-prefixed workspace exists in the old
temporary roots, so nothing ambiguous was deleted; the shared developer Cargo cache remains untouched and unused.

Cross-volume reads are denied by default. The narrow exception is an explicit caller path or a strictly required
externally managed executable, system library, device, credential, or OS service. Those are dependencies, not
project storage, and their exact supported surface is documented and gated. Related facts:
[[perl-project-data-ssd-storage]], [[rust-project-data-ssd-storage]], [[repository-root-path-portability]], [[rust-local-verification-gate]],
[[lua-toolchain-package-policy]].
