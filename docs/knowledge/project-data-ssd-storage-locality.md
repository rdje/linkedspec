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
date: 2026-07-26
status: current
tags: [architecture, storage, filesystem, ssd, cache, temporary-data, portability, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.0 proves the repository and current OS temporary root are on different filesystems. It finds 65 retained CLI workspaces plus two Julia depots totalling 135,756 KiB, two Dart active-root records identifying current/former checkouts, and one LinkedSpec stanza in a shared Julia usage log. A tracked census finds 100 temporary-allocation files: Perl 24, Rust 16, Dart 18, Julia 17, Lua 13, Python 3, shell 12 with cross-family overlap; 24 executable files contain explicit off-repository defaults; 97 fact cards contain 107 old temporary/home-depot command lines. ADR 0053 requires repo-filesystem project state, necessary-only external reads, and copy/verify/use/delete migration."
reverify: "git status --short && git ls-files -- . ':(exclude)rgx' | wc -l && rg --no-config -l 'File::Temp|tempdir\\(|tempfile\\(|TemporaryDirectory|NamedTemporaryFile|mktempdir\\(|Directory\\.systemTemp|std::env::temp_dir|tempfile::tempdir|mktemp -d' t tools julia lua dart rust knowledge-map .githooks | wc -l"
---

ADR `0053` makes the current repository filesystem the authority for all LinkedSpec-owned data. Tracked paths stay
root-relative; supported entrypoints compute absolute scratch/cache paths from the current checkout before any
child process allocates. An inherited temp/cache destination on another filesystem is replaced, not treated as a
convenient override.

The planning census found a real live mismatch. Sixty-five CLI workspaces and two Julia depots remained on the
internal per-user temporary filesystem, occupying 135,756 KiB. The CLI workspaces contain 17 small fixture/trace
files totalling 1,590 bytes; the depots account for essentially all retained size. Two global Dart active-root
records point at current/former LinkedSpec checkouts. A shared Julia usage log has one former LinkedSpec manifest
stanza alongside another project's data, so only the LinkedSpec stanza is an eligible deletion target.

Tracked allocation is broader: 100 files use default temp APIs or explicit temp roots. Family counts are Perl 24,
Rust 16, Dart 18, Julia 17, Lua 13, Python three, and shell 12; multi-language harnesses overlap. Twenty-four
executable files contain explicit off-repository storage defaults. Ninety-seven fact cards contain 107 durable
commands that still select old temporary/home depot composition. Twenty-six backend test files contain path values
used for privacy or redaction assertions; these are inert data and are not filesystem writers.

Existing shared Cargo, Dart, and Julia caches are not moved or deleted wholesale because other projects may own
entries. LinkedSpec instead populates repo-local caches and stops reading the shared copies. Exact LinkedSpec-owned
metadata, depots, scratch, and logs follow copy/verify/use/delete: verify counts/bytes/hashes where material, run the
workflow against the SSD copy, then delete the old source in the same task leaf. Final closeout independently proves
the off-SSD project census empty.

Cross-volume reads are denied by default. The narrow exception is an explicit caller path or a strictly required
externally managed executable, system library, device, credential, or OS service. Those are dependencies, not
project storage, and their exact supported surface is documented and gated. Related facts:
[[repository-root-path-portability]], [[rust-local-verification-gate]], [[lua-toolchain-package-policy]].
