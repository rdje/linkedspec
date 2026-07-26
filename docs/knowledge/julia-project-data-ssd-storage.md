---
id: julia-project-data-ssd-storage
title: Julia packages, precompile state, scratch, generated output, and traces stay on repository storage
answers:
  - where does LinkedSpec store Julia packages
  - where does LinkedSpec store Julia precompile output
  - how do I run a targeted Julia command with repository local storage
  - how do I verify Julia project data stays on the repository filesystem
  - how many Julia files allocate temporary data
  - how many external Julia packages are locked and cached locally
  - can LinkedSpec resolve Julia dependencies offline
  - what is the LinkedSpec Julia package payload hash
  - does LinkedSpec still consult the shared developer Julia depot
  - which external Julia depots remain necessary
  - were the old Julia temporary depots deleted
  - was the stale shared Julia manifest usage record deleted
  - why does LinkedSpec delete Julia manifest usage metadata
  - do Julia generated source workspaces and traces stay on the SSD
  - how many Julia Knowledge Map commands use the managed wrapper
date: 2026-07-26
status: current
tags: [julia, depot, storage, filesystem, ssd, cache, temporary-data, generated-source, trace, portability, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.2.4 adds tools/run_julia_project_data.sh and tools/test_julia_project_data_storage.sh. The oracle locks 17 tracked mktempdir/tempdir owners, verifies managed temp and the writable depot share the repository device, rejects an explicit developer-home depot, requires all five external Manifest package trees plus the General registry, and exercises generated v2 source and trace paths. The five package trees contain 146 files / 710,665 bytes with canonical hash 6840ce825c96acd208d308fc58baac1306dcfd64afe1dc4b365f1eccfe906af1. The complete package/primary/corpus gate passes offline with 105/105 corpus fixtures. Two old exact depots were copied, count/byte/hash verified, used through the canonical cache, and deleted; the one exact former-checkout shared usage-log stanza was deleted while ambiguous shared data remained untouched. Eighty-eight existing current Julia reverify cards and eight directly invocable Julia-consuming cross-backend checkers now use self-rooted managed boundaries."
reverify: "bash tools/test_julia_project_data_storage.sh && bash tools/run_julia_local.sh && test ! -e .linkedspec-data/cache/julia-depot/logs/manifest_usage.toml"
---

Supported Julia workflows use the ignored repository-relative retained depot and managed per-run temporary
storage. For a targeted command, use the same self-rooted boundary as the durable Knowledge Map commands:

```console
$ bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3'
```

The writable depot contains the five external package trees locked by `julia/Manifest.toml`: JSON3, Parsers,
PrecompileTools, Preferences, and StructTypes. Their exact source payload is 146 files / 710,665 bytes with
canonical hash `6840ce825c96acd208d308fc58baac1306dcfd64afe1dc4b365f1eccfe906af1`. The General registry is retained too,
so package tests and loading resolve offline without the shared developer depot. Julia's trailing empty depot entry
adds only its externally managed system depots. Those interpreter resources are strictly required, read-only
runtime dependencies rather than project storage.

`tools/test_julia_project_data_storage.sh` freezes all 17 tracked `mktempdir()`/`tempdir()` owners, checks actual
filesystem device identity for managed scratch, the writable depot, and every package file, rejects package
symlinks and explicit external depot entries, and proves JSON3 resolves from the first depot. Its runtime probe
requires Julia's `tempdir()` to equal routed `TMPDIR`, creates generated v2 source and a trace under `mktempdir()`,
and leaves no completed `jl_*` workspace. `julia/test/runtests.jl` independently locks the temp-root contract.

The warmed source-bearing depot moved atomically from a noncanonical same-SSD cache root into the canonical cache.
The two exact old internal-volume depots were first copied into repository-relative retained migration storage and
verified independently: the larger tree was 346 directories / 256 files / 133,963,036 bytes with hash
`bddd661bcfb5e43b4cdb4f688d0de68530e8a94ee0b8f1c38ac873c89d8c9ed8`; the query tree was 24 directories / 15
files / 4,284,303 bytes with hash `aa599da3058fc18240fad33792b0a2d006731abb8c2bc7f2348b78aeb4c3030c`.
Only after the canonical offline and complete gates passed were both old sources deleted. Their internal-volume
residue is zero.

The shared developer depot is ambiguous multi-project data and remains untouched and unused. Only the exact
former-checkout stanza in its manifest-usage log was deleted. Julia also generates the same kind of log inside the
canonical depot with absolute checkout and managed-run paths; it is disposable package-GC metadata, so the
targeted wrapper removes it after supported package operations while retaining packages, registry, and compiled
cache. Eighty-eight existing current Julia Knowledge Map cards now invoke one of the managed self-rooted Julia boundaries;
all eight directly invocable Julia-consuming cross-backend checkers self-route before their first runtime or
allocator as well.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-workflow-routing]],
[[repository-root-path-portability]], [[julia-local-verification-gate]],
[[julia-depot-layering-after-cache-cleanup]], [[julia-stacked-depot-driver-boundary]].
