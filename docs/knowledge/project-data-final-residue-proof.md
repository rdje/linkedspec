---
id: project-data-final-residue-proof
title: Final project-data residue census is empty after retained SSD use
answers:
  - has the final LinkedSpec off repository residue proof passed
  - does any exact LinkedSpec project data remain on the old temporary filesystem
  - did PROJECT DATA SSD ROOTING 3.2 delete any old data
  - were shared Cargo Dart or Julia caches changed by final residue cleanup
  - do retained Perl and Julia migration copies still match their frozen inventories
  - did old temporary roots stay empty after all storage oracles ran
  - which storage task follows final residue proof
date: 2026-07-26
status: current
tags: [architecture, storage, filesystem, ssd, migration, residue, cleanup, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.3.2 independently resolves both frozen operating-system temporary roots at runtime and confirms they are on a different filesystem from the repository. Before and after all six storage oracles, each root contains zero top-level LinkedSpec-identifying entry; shared Dart active-root and Julia manifest-usage metadata contain zero LinkedSpec file. The superseded same-SSD target-era identity is absent. No old-data candidate exists, so .3.2 deletes zero external paths and touches no ambiguous shared package payload. Retained migration copies independently match Perl 65 directories/17 files/1,590 bytes and Julia 346 directories/256 files/133,963,036 bytes plus 24 directories/15 files/4,284,303 bytes; canonical Cargo/Dart/Julia/Python/Rust roots share the repository device; all six storage oracles pass with zero managed runs."
reverify: "rg -n 'PROJECT-DATA-SSD-ROOTING\\.3\\.2|zero deletion targets|post-use census' docs/tasks/PROJECT-DATA-SSD-ROOTING.md && bash tools/test_perl_project_data_storage.sh && bash tools/test_rust_project_data_storage.sh && bash tools/test_dart_project_data_storage.sh && bash tools/test_julia_project_data_storage.sh && bash tools/test_lua_project_data_storage.sh && bash tools/test_tool_project_data_storage.sh && bash tools/project_data_run.sh --list"
---

The final migration-residue leaf uses a fresh read-only census rather than treating reconciliation history as
proof. It derives the inherited system and per-user temporary roots at runtime, verifies both are outside the
repository filesystem, and checks their bounded top-level LinkedSpec-identifying namespace before and after real
destination use. Both censuses are zero. The separately bounded shared Dart active-root and Julia manifest-usage
metadata surfaces also have zero LinkedSpec-bearing file. Shared package payload is ambiguous multi-project data
and was neither traversed for deletion nor changed.

There was consequently no deletion target in `.3.2`: zero external files or directories were removed. This is a
positive result, not a skipped cleanup. Every exact owner found by earlier leaves had already completed
copy/verify/use/delete, and the fresh post-use census proves supported workflows did not recreate it.

The retained SSD copies remain materialized at their frozen boundaries. Perl has 65 top-level workspace
directories, 17 files, and 1,590 bytes. The two Julia copies have 346 directories / 256 files / 133,963,036 bytes
and 24 directories / 15 files / 4,284,303 bytes. They and the canonical retained Cargo, Dart, Julia, and Python
caches plus Rust target share the repository filesystem. The Perl, Rust, Dart, Julia, Lua, and tool storage
oracles all pass, and their complete run leaves zero managed scratch.

This closes existing-data migration parent `.3`. Structural prevention `.4.1` now turns the accepted storage
policy into a recurring doctrine; process-level opened-path proof `.4.2` follows.

Related facts: [[project-data-migration-reconciliation]], [[project-data-ssd-storage-locality]],
[[project-data-storage-locality-doctrine]], [[project-data-run-lifecycle]], [[perl-project-data-ssd-storage]],
[[julia-project-data-ssd-storage]].
