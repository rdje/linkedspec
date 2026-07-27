---
id: project-data-migration-reconciliation
title: Reconciled project-data migration ledger and exact old-root retirement
answers:
  - did every frozen LinkedSpec project data source get reconciled
  - what did the independent SSD migration reconciliation find
  - were the migrated Perl CLI workspaces still intact
  - were the migrated Julia depots still intact
  - did any old LinkedSpec temporary data remain after backend migration
  - was an obsolete target era Cargo cache left behind
  - why was rust target project data ssd rooting deleted
  - is the canonical Cargo cache usable after old cache deletion
  - were shared Cargo Dart and Julia caches deleted wholesale
  - which project data migration leaf follows reconciliation
date: 2026-07-26
status: current
tags: [architecture, storage, filesystem, ssd, migration, reconciliation, cleanup, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.3.1.1 reconciles the .0 census with .2.1-.2.6. Fresh destination inventories retain all 65 Perl workspace directories / 17 files / 1,590 bytes and both Julia depot copies at 346 directories / 256 files / 133,963,036 bytes and 24 directories / 15 files / 4,284,303 bytes. Both frozen operating-system temporary roots have zero linkedspec-* entries; shared Dart active-root and Julia usage-log scans have zero LinkedSpec matches; every previously named exact old path is absent. The audit found one missed same-SSD exact owner: rust/target/project-data-ssd-rooting held an obsolete 12,754-file / 2,376-directory / 371,656-KiB target-era root. Its 12,741-file Cargo cache matched the canonical cache in file count and 348,574,405 bytes, its registry tree was byte-identical, and only root-local volatile .global-cache content differed. Locked offline fetch passed from the canonical cache before deletion; the exact old root was deleted; locked fetch and the complete 17-owner Rust storage oracle passed afterward. All six backend/tool storage oracles, environment/lifecycle proofs, and zero-run census pass. Ambiguous shared multi-project caches remain untouched and unused."
reverify: "test ! -e rust/target/project-data-ssd-rooting && bash tools/test_perl_project_data_storage.sh && bash tools/test_rust_project_data_storage.sh && bash tools/test_dart_project_data_storage.sh && bash tools/test_julia_project_data_storage.sh && bash tools/test_lua_project_data_storage.sh && bash tools/test_tool_project_data_storage.sh && bash tools/project_data_run.sh --list"
---

The frozen migration ledger has one exact disposition per owned source class. Perl's 65 interrupted CLI
workspaces and both old Julia depots retain independently verified repository-relative copies. The exact Dart
checkout records, Julia usage-log stanza, disposable tool audit list, and accidental tool inventory were removed
only after ownership classification. Rust and Lua had no exact old temporary payload. Shared Cargo, Dart, and
Julia package stores remain ambiguous multi-project data: supported workflows use complete repository-local
caches and do not consult those shared stores, but that does not confer wholesale deletion authority.

The independent reconciliation found one missed exact owner on the repository filesystem rather than another
volume: `rust/target/project-data-ssd-rooting/`. Its target-era Cargo cache duplicated the canonical retained
cache, while 13 additional files were disposable scratch. Before deletion, both Cargo roots held 12,741 files and
348,574,405 bytes; their registry trees compared byte-for-byte, and the only content difference was Cargo's
root-local volatile `.global-cache`. A locked offline fetch exercised the canonical cache, the exact obsolete root
was deleted, and another locked fetch plus the complete Rust storage oracle passed afterward. The deleted old
identity is intentionally gone; all reusable package content remains recoverable from the canonical cache.

Fresh count/byte inventory also confirms the retained migration copies still match their recorded material
boundaries: Perl 65 directories / 17 files / 1,590 bytes; Julia 346 directories / 256 files / 133,963,036 bytes and
24 directories / 15 files / 4,284,303 bytes. The six Perl/Rust/Dart/Julia/Lua/tool storage oracles and common
environment/lifecycle proofs pass with no managed-run residue. `PROJECT-DATA-SSD-ROOTING.3.2` owns the separately
committed final off-repository residue proof after the descendant-liveness remediation. That leaf is now complete:
its fresh pre/post-use censuses are zero, it has zero deletion targets, and the retained copies still match these
boundaries.

Related facts: [[project-data-ssd-storage-locality]], [[perl-project-data-ssd-storage]],
[[rust-project-data-ssd-storage]], [[dart-project-data-ssd-storage]], [[julia-project-data-ssd-storage]],
[[lua-project-data-ssd-storage]], [[tool-project-data-ssd-storage]], [[project-data-descendant-liveness-gap]],
[[project-data-final-residue-proof]].
