---
id: dart-project-data-ssd-storage
title: Dart packages, temporary workspaces, generated output, and traces stay on repository storage
answers:
  - where does LinkedSpec store Dart packages
  - how do I verify Dart project data stays on the repository filesystem
  - how many Dart files allocate temporary data
  - how many hosted Dart packages are locked and cached locally
  - can LinkedSpec resolve Dart dependencies offline
  - what is the LinkedSpec Dart package payload hash
  - what is the normalized Dart package index hash
  - does LinkedSpec still consult the shared developer Dart cache
  - were old Dart active root records deleted
  - does Dart Directory systemTemp follow the managed repository temporary root
  - do Dart generated source workspaces and traces stay on the SSD
  - where does Dart telemetry configuration live during LinkedSpec workflows
  - does supported Dart execution read the developer home
date: 2026-07-27
status: current
tags: [dart, pub, storage, filesystem, ssd, cache, temporary-data, generated-source, trace, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.2.3 adds tools/test_dart_project_data_storage.sh and invokes it from tools/run_dart_local.sh. The oracle locks 18 tracked Directory.systemTemp owners, verifies TMPDIR/PUB_CACHE and the managed run share the repository device, resolves all 47 hosted pubspec.lock packages and hashes offline, and exercises trace/generated-source paths. The canonical cache contains 5,903 payload files / 63,744,165 bytes with hash 039c5fd8728ea44f23b028ee9400846c353e71a071d46da355b8e1e0d857f29e; 47 package-index JSON files match the shared cache after removing only _fetchedAt, normalized hash 21e59ae7c96ad7a94b77f7e854a685d4729c22623486a1acea4ab444777f067b. Full proof passes 337 package tests, primary 66x2, corpus 105/105. After use, the two exact current/former shared active-root records are deleted and residue is zero; ambiguous shared package payload remains untouched and unused. Process proof .4.2 exposes Dartdev's pre-command HOME telemetry read and adds tools/run_dart_project_data.sh plus LINKEDSPEC_DART_HOME, so every maintained Dart command uses the repository-local Dart home without changing CLI behavior."
evidence_update_2026_07_30_callable_codeblock_emission: "FUTURE-PARITY-BACKLOG.11.5.2 adds one independently compiled emitted-Dart callable-codeblock workspace, advancing the live tracked Directory.systemTemp manifest from 18 to 19. The oracle registers that exact owner and reports its manifest size dynamically; the complete gate passes 369 tests before the storage leg."
reverify: "bash tools/test_dart_project_data_storage.sh && bash tools/run_dart_local.sh && bash tools/run_dart_project_data.sh pub get -C dart --offline"
---

LinkedSpec's supported Dart workflows use the ignored repository-relative
`/.linkedspec-data/cache/dart-pub/` cache, `/.linkedspec-data/cache/dart-home/` command metadata, and managed per-run
temporary storage. The complete `tools/run_dart_local.sh` gate invokes `tools/test_dart_project_data_storage.sh`;
a targeted command uses `bash tools/run_dart_project_data.sh ...`, which initializes storage and gives only the
Dart child the repository-local home before executing the selected Dart SDK command.

The canonical cache covers all 47 hosted packages and hashes in `dart/pubspec.lock`. Package payload identity is
5,903 files / 63,744,165 bytes with canonical hash
`039c5fd8728ea44f23b028ee9400846c353e71a071d46da355b8e1e0d857f29e`. The 47 pub index files differ from the
shared cache only in `_fetchedAt`; after removing that volatile field their canonical JSON hash is
`21e59ae7c96ad7a94b77f7e854a685d4729c22623486a1acea4ab444777f067b`.

The storage oracle locks exactly 19 tracked Dart `Directory.systemTemp` owners. A native pipeline test directly
requires `Directory.systemTemp` to resolve to routed `TMPDIR`; the shell boundary independently checks filesystem
device identity, package configuration, offline resolution, generated caller packages, traces, and cleanup. The
complete gate passes formatting, strict analysis, 369 package tests, primary 66/66 in both environments, and the
105-fixture corpus.

Migration moved the warmed SSD cache atomically from its noncanonical target-era location into the canonical
cache, so no duplicate source remains. Only after offline and full-gate use were the two exact shared
`active_roots` records—current checkout and absent former checkout—deleted with their empty hash shards. Shared
active-root residue is zero. The shared package payload is ambiguous multi-project data and remains untouched;
supported workflows no longer consult it.

The process-level oracle discovered why `PUB_CACHE` alone was insufficient: Dartdev reads its telemetry
configuration beneath `HOME/.dart-tool` before several subcommands honor the package cache. The wrapper prevents
that implicit developer-home read. All maintained gates, multi-backend matrices, documentation commands, and
Knowledge Map Dart reverification commands use this wrapper; the storage doctrine rejects a bare maintained Dart
`pub`, formatter, analyzer, test, or run command while preserving the CLI's established user-facing usage label.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-workflow-routing]],
[[project-data-env-initializer]], [[project-data-process-locality-proof]], [[dart-local-verification-gate]].
