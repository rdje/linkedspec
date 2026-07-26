---
id: project-data-env-initializer
title: Repo-derived project-data environment initializer
answers:
  - how do I initialize LinkedSpec repository local temporary and cache storage
  - which directory contains LinkedSpec project data
  - where are LinkedSpec scratch and reusable caches stored
  - which environment variables does the project data initializer export
  - how does LinkedSpec reject cross volume temporary and cache overrides
  - may a same filesystem caller cache override be preserved
  - can the project data initializer be sourced outside the repository cwd
  - where is the LinkedSpec Cargo home
  - where is the LinkedSpec Dart package cache
  - where is the LinkedSpec Julia depot
  - does the LinkedSpec Julia depot consult the developer home depot
  - how is the project data environment tested
  - where is the LinkedSpec managed runs root
date: 2026-07-26
status: current
tags: [architecture, storage, filesystem, cache, temporary-data, environment, portability, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.1.1 adds ignored /.linkedspec-data with disposable scratch and retained cache children. Sourcing tools/project_data_env.sh derives the checkout from BASH_SOURCE, checks device identity, preserves only same-filesystem overrides, and exports temp, Cargo, Dart, and Julia roots. .1.3 adds LINKEDSPEC_RUNS_ROOT. PROJECT-DATA-SSD-ROOTING.2.2 populates Cargo for 195 locked packages; .2.3 populates Dart for 47 locked packages and proves Directory.systemTemp follows routed TMPDIR. tools/test_project_data_env.sh proves defaults, same-volume overrides, hostile cross-volume replacement, and cleanup."
reverify: "bash -n tools/project_data_env.sh tools/test_project_data_env.sh && bash tools/test_project_data_env.sh && git check-ignore .linkedspec-data/probe"
---

Source `tools/project_data_env.sh` before a workflow creates project-owned temporary or cache data. The helper
derives the physical repository root from its own current file, not from caller cwd, then creates the ignored
repository-root-relative hierarchy `/.linkedspec-data/`. `scratch/` owns disposable state and `cache/` owns retained
dependencies. The leading slash in those descriptions means relative to the repository root, not to the filesystem
root; the tracked helper stores no checkout or volume literal.

The helper exports `LINKEDSPEC_REPO_ROOT`, `LINKEDSPEC_PROJECT_DATA_ROOT`, `LINKEDSPEC_SCRATCH_ROOT`,
`LINKEDSPEC_CACHE_ROOT`, `LINKEDSPEC_RUNS_ROOT`, `TMPDIR`, `TMP`, `TEMP`, `CARGO_HOME`, `CARGO_TARGET_DIR`, `PUB_CACHE`,
`JULIA_DEPOT_PATH`, and `LINKEDSPEC_JULIA_DEPOT_PATH`. Cargo target output remains under `rust/target`; Cargo home,
Dart packages, and Julia packages/precompile state live below the retained cache root. Julia's default has one
writable repo-local depot followed by its runtime system depots; it does not consult a developer-home depot.

An explicit caller directory survives only when its existing or nearest existing ancestor and its final created
directory have the same device identity as the repository. An external or invalid override is replaced with the
corresponding repo-derived default without creating anything at the rejected destination. The focused test discovers
an available other-filesystem directory read-only, launches from it, supplies hostile values for every storage
variable, and proves all final project-owned destinations remain on the repository filesystem. Related facts:
[[project-data-run-lifecycle]], [[project-data-ssd-storage-locality]], [[rust-project-data-ssd-storage]], [[dart-project-data-ssd-storage]], [[repository-root-path-portability]].
