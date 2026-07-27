---
id: project-data-process-locality-proof
title: Relocated process containment proves representative project I/O stays on repository storage
answers:
  - how is project data locality proved at process level
  - does LinkedSpec have a relocated process storage oracle
  - which backends are covered by the project data process oracle
  - how are hostile temporary and cache variables tested
  - can a symlink escape the repository storage policy
  - does the process oracle allow explicit caller input
  - why does the project data process oracle use sandbox exec
  - why does the process oracle not use fs usage
  - does Dart read telemetry configuration from developer home
  - why does LinkedSpec give Dart a repository local home
  - why does the Lua native builder call Apple clang directly
  - does xcrun write temporary compiler metadata outside the repository
date: 2026-07-27
status: current
tags: [architecture, storage, filesystem, process, sandbox, relocation, dart, lua, toolchain, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.4.2 adds tools/test_project_data_process_locality.sh and registers it in canonical local CI. On macOS it creates a collision-safe checkout view below managed repository scratch, starts from an outside-filesystem cwd with hostile TMPDIR/TMP/TEMP/Cargo/Dart/Julia/Python cache roots, and uses sandbox-exec to deny all writes outside the relocated checkout plus /dev/null and to deny data reads from developer HOME and both OS temporary roots except one exact read-only caller input. Real Perl, Rust, Dart, Julia, Lua, and Python-tool probes create nonempty traces or bytecode beneath the relocated root; the probe-set guard requires all six families. Deterministic mutations reject an old-volume write, a shared Cargo-cache read, a symlink escape, and a missing tool probe. fs_usage and dtruss require root on this host; sandbox-exec supplies non-root kernel containment in a normal local terminal. The first contained run exposed Dart's pre-command HOME telemetry read and Apple's cc shim xcrun_db temporary write. tools/run_dart_project_data.sh now gives only Dart a same-device repository-local HOME, all maintained Dart command surfaces use it, and the Lua builder invokes the active Apple clang plus SDK directly instead of the stateful cc shim. The final oracle passes with no denied-access or xcrun_db diagnostic."
reverify: "bash -n tools/test_project_data_process_locality.sh tools/run_dart_project_data.sh tools/build_lua_native.sh && bash tools/test_project_data_process_locality.sh && bash scripts/check_project_data_storage_locality.sh"
---

`tools/test_project_data_process_locality.sh` is the recurring process-level complement to the structural
`PROJECT-DATA-STORAGE` doctrine. It archives the current committed tree into a path containing a space below the
managed repository scratch root, overlays the current oracle/helper sources for pre-commit verification, clone-
copies the retained Dart and Julia caches plus the built Rust primary, and invokes that relocated tree while the
working directory is the runtime-derived system temporary root on another filesystem.

The macOS sandbox profile permits normal operating-system and external-tool reads, but it makes the storage
boundary kernel-enforced: writes are denied outside the relocated checkout except `/dev/null`. Data reads from the
developer home, the system temporary root, and the per-user temporary root are denied, with one exact existing
caller-owned file admitted read-only. The driver independently resolves every initialized project-data directory,
requires it beneath the relocated checkout and on the checkout device, verifies the external interpreters against
the frozen system/tool roots, and requires the exact set `caller-input dart julia lua perl rust tool`.

The retained REDs prove the policy is mutation-sensitive. An external output cannot be created, a shared
developer Cargo cache cannot be read, a symlink inside the checkout cannot redirect a write to the old volume, and
omitting the tool-family probe fails the set guard. Successful Perl, Rust, Dart, Julia, and Lua primary invocations
each write a nonempty routed trace; the Python checker writes bytecode under the routed cache. Any denied-access or
Apple `xcrun_db-` diagnostic makes the otherwise successful driver fail.

Tracing experiments established two actionable hidden accesses. `fs_usage`/`dtruss` are root-only on the current
host, so the committed oracle uses the narrower non-root `sandbox-exec` containment available in an ordinary macOS
terminal. Dartdev consulted `HOME/.dart-tool/dart-flutter-telemetry.config` before package operations honored
`PUB_CACHE`; `tools/run_dart_project_data.sh` now sets only the Dart child's HOME to
`/.linkedspec-data/cache/dart-home/`, and the structural doctrine rejects maintained bare Dart command surfaces.
Apple's `/usr/bin/cc` shim attempted to refresh `xcrun_db-*` under the per-user OS temporary root; on macOS the Lua
native builder now resolves the active developer directory, invokes its real `clang`, and supplies the active SDK
explicitly. These are process-boundary corrections; parser/runtime semantics and user-facing CLI syntax are
unchanged.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-storage-locality-doctrine]],
[[project-data-workflow-routing]], [[dart-project-data-ssd-storage]], [[lua-project-data-ssd-storage]],
[[repository-root-path-portability]].
