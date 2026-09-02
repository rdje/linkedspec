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
  - why can a bare dart test make the repository wrapper wait before test discovery
date: 2026-09-02
status: current
tags: [dart, pub, storage, filesystem, ssd, cache, temporary-data, generated-source, trace, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.2.3 adds tools/test_dart_project_data_storage.sh and invokes it from tools/run_dart_local.sh. The oracle locks 18 tracked Directory.systemTemp owners, verifies TMPDIR/PUB_CACHE and the managed run share the repository device, resolves all 47 hosted pubspec.lock packages and hashes offline, and exercises trace/generated-source paths. The canonical cache contains 5,903 payload files / 63,744,165 bytes with hash 039c5fd8728ea44f23b028ee9400846c353e71a071d46da355b8e1e0d857f29e; 47 package-index JSON files match the shared cache after removing only _fetchedAt, normalized hash 21e59ae7c96ad7a94b77f7e854a685d4729c22623486a1acea4ab444777f067b. Full proof passes 337 package tests, primary 66x2, corpus 105/105. After use, the two exact current/former shared active-root records are deleted and residue is zero; ambiguous shared package payload remains untouched and unused. Process proof .4.2 exposes Dartdev's pre-command HOME telemetry read and adds tools/run_dart_project_data.sh plus LINKEDSPEC_DART_HOME, so every maintained Dart command uses the repository-local Dart home without changing CLI behavior."
evidence_update_2026_07_30_callable_codeblock_emission: "FUTURE-PARITY-BACKLOG.11.5.2 adds one independently compiled emitted-Dart callable-codeblock workspace, advancing the live tracked Directory.systemTemp manifest from 18 to 19. The oracle registers that exact owner and reports its manifest size dynamically; the complete gate passes 369 tests before the storage leg."
evidence_update_2026_08_07_bare_test_recovery: "During FUTURE-PARITY-BACKLOG.14.2.3.0.1, an accidental bare dart test regenerated ignored dart/.dart_tool/package_config.json with file roots under the user-global Pub cache. The maintained wrapper then waited before discovery because its repository-local PUB_CACHE disagreed with that graph. bash tools/run_dart_project_data.sh pub get -C dart --offline restored every root to /.linkedspec-data/cache/dart-pub; shared active-root residue for this checkout was already zero; the 20-owner/47-package oracle and wrapped alias test pass. This confirms the existing rule: never run a bare maintained Dart command."
evidence_update_2026_08_11_transaction_owner: "FUTURE-PARITY-BACKLOG.14.3.4.1 finds that atomic 193 added a dormant emitted-source test using Directory.systemTemp but the pre-commit storage oracle enumerated only git ls-files, so that untracked first-commit file was invisible until the next clean commit. The oracle now registers the exact 21st owner and derives its census from cached plus non-ignored untracked Dart sources in C-locale order. This closes the first-commit gap without scanning ignored package/build data; the emitted workspace remains under managed repository scratch and uses its own local PUB_CACHE."
verification_update_2026_08_11_transaction_owner: "Corrected complete Dart proof passes format 100/0, strict analysis, ordinary 383/383, storage 21 owners / 47 packages, CLI 66x2, corpus 105/105, and the exact Dart success marker. Definitive CI then passes repository containment/relocation and Phase 0 1,031/1,031."
evidence_update_2026_08_15_current_owner_census: "INTER-MATCH-GAP-CAPTURE.4.0 re-verifies the complete Dart gate and corrects the stale 21-owner projection. The already-admitted semantic_introspection_dart_admission_test.dart emitted workspace is the exact 22nd maintained Directory.systemTemp owner; it was created by atomic a0946c01 and has been present in the storage oracle's original inventory since a8a73aa9. Current proof passes format 101/0, strict analysis, 400/400 tests, storage 22 owners / 47 packages, CLI 66x2, and corpus 105/105. No storage or Dart behavior changes in this correction."
evidence_update_2026_09_02_write_vivification_owner: "FUTURE-PARITY-BACKLOG.19.4.1 adds the independently analyzed and executed emitted-Dart nested-write vivification workspace as the exact 24th maintained Directory.systemTemp owner. The activation manifest already contained 23 owners; its historical prose had not counted the inter-match-gap emitted workspace added by 6a554312. The new owner inherits the managed-run TMPDIR, uses a workspace-local PUB_CACHE, and removes its exact workspace in finally. The first complete Dart gate passes format/analyze and 450/450 tests before correctly stopping on 23-to-24 inventory drift; the registered 24-owner rerun is the required proof."
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

The storage oracle locks exactly 24 maintained Dart `Directory.systemTemp` owners. Its census includes cached and
non-ignored untracked Dart source, so a new first-commit owner cannot evade the manifest before `git add`; ignored
package/build state remains outside the source inventory. A native pipeline test directly requires
`Directory.systemTemp` to resolve to routed `TMPDIR`; the shell boundary independently checks filesystem device
identity, package configuration, offline resolution, generated caller packages, traces, and cleanup.

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

A bare `dart test` may also regenerate the ignored root `package_config.json` against the developer Pub cache.
Running a later wrapped test with the repository-local `PUB_CACHE` can then wait before discovery because the two
authorities disagree. Recovery is non-destructive: run wrapped offline `pub get` from the Dart package, verify all
package roots point below `/.linkedspec-data/cache/dart-pub/`, confirm no checkout-owned shared active-root residue,
then rerun the storage oracle. Never delete the ambiguous shared package payload.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-workflow-routing]],
[[project-data-env-initializer]], [[project-data-process-locality-proof]], [[dart-local-verification-gate]].
