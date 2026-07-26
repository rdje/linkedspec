---
id: rust-project-data-ssd-storage
title: Rust project data and locked Cargo dependencies stay on repository storage
answers:
  - where does LinkedSpec store Rust Cargo dependencies
  - where does LinkedSpec store Rust build output
  - how do I run a targeted Cargo command with repository local storage
  - how do I verify Rust project data stays on the repository filesystem
  - how many Rust files allocate temporary data
  - why did the Rust temporary owner count change from 16 to 17
  - how many locked Cargo registry packages are cached locally
  - what is the LinkedSpec Cargo cache inventory hash
  - does LinkedSpec still consult the shared developer Cargo cache
  - was any old Rust temporary data deleted from the internal volume
  - how is Rust copied binary relocation tested under repository local temporary storage
  - why does the Rust repository topology unit test inject a marker predicate
date: 2026-07-26
status: current
tags: [rust, cargo, storage, filesystem, ssd, cache, temporary-data, relocation, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.2.2 adds tools/run_cargo_local.sh and tools/test_rust_project_data_storage.sh. The oracle locks 17 Rust temporary-allocation owners, verifies TMPDIR/CARGO_HOME/CARGO_TARGET_DIR and a real copied-binary trace share the repository device, exercises core trace, runtime topology/trace/source-emitter paths, and resolves Cargo.lock offline. The repo-local Cargo home covers 195 compressed packages and 195 source directories, 12,741 files, 371,604 KiB, with canonical compressed-cache hash a51efb284d62287872f6cc2fd113b1f31c6c5c2e5c1e7d1dd5e52de1e735b399. Exact Rust-prefixed residue in the inherited OS temporary roots is zero; the ambiguous shared Cargo cache remains untouched and is no longer consulted by supported workflows. The complete Rust gate passes runtime 149, corpus 105, generated classifier 105, integration 197, and primary 66x2."
reverify: "bash tools/test_rust_project_data_storage.sh && bash tools/run_rust_local.sh && bash tools/run_cargo_local.sh fetch --manifest-path rust/Cargo.toml --locked --offline"
---

LinkedSpec's supported Rust commands keep reusable dependencies below the ignored repository-relative Cargo home
and build products below `rust/target`. `tools/run_cargo_local.sh` is the supported targeted-command boundary: it
self-roots, initializes repository-filesystem project data, enters a managed run, and then executes the requested
Cargo arguments. The full `tools/run_rust_local.sh` gate runs the dedicated storage oracle after its complete
package/build proof.

The retained Cargo cache covers every registry dependency in `rust/Cargo.lock`: 195 compressed cache files and
195 unpacked source directories, 12,741 files and 371,604 KiB in total. The canonical compressed-cache inventory
hash is `a51efb284d62287872f6cc2fd113b1f31c6c5c2e5c1e7d1dd5e52de1e735b399`. A locked offline fetch and build prove
the repository cache is sufficient. The shared developer Cargo cache is ambiguous multi-project data, so it was
not copied wholesale or deleted; supported workflows no longer consult it.

The exact tracked Rust temporary-owner count is 17. The planning scan reported 16 because it matched the fully
qualified `std::env::temp_dir()` spelling but missed `rust/linkedspec-core/src/trace.rs`, which imports `env` and
calls `env::temp_dir()`. The recurring oracle recognizes both spellings and `tempfile::tempdir()`, locks the exact
owner list, and checks real generated-child-project, trace, and relocated-command outputs. A read-only census of
the inherited per-user temporary root and `/private/tmp` found zero exact Rust-prefixed retained workspace, so no
unambiguous old Rust-owned datum existed to delete.

Repository-local `TMPDIR` changes topology: a path created beneath it is beneath the actual checkout and cannot
serve as a synthetic external executable. The Rust unit test therefore injects a repository-marker predicate over
relative synthetic paths to prove executable/cwd/fallback precedence without filesystem ancestry ambiguity. The
storage oracle separately copies the real built command into managed scratch, invokes it from a nested cwd, writes
a trace, and proves the command, trace, temp, Cargo home, and target all share the repository device.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-workflow-routing]],
[[repository-root-path-portability]], [[rust-local-verification-gate]].
